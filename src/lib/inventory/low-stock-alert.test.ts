import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  crossedBelowReorderPoint,
  deliverLowStockDigest,
  lowStockDigest,
  type LowStockAlertLine,
} from "./low-stock-alert.ts";

const line: LowStockAlertLine = {
  materialCode: "F002-125",
  fabricName: "lime mesh",
  availableM: 1.5,
  reorderPointM: 2,
  pageUrl: "https://studio.example/inventory/F002-125",
  thumbUrl: "https://photos.example/thumb",
};

describe("reorder point crossing", () => {
  it("alerts only when known stock moves from above the point to at or below it", () => {
    assert.equal(crossedBelowReorderPoint(5, 2, 2), true);
    assert.equal(crossedBelowReorderPoint(5, 1.5, 2), true);
    assert.equal(crossedBelowReorderPoint(2, 1, 2), false);
    assert.equal(crossedBelowReorderPoint(5, 3, 2), false);
    assert.equal(crossedBelowReorderPoint(null, 1, 2), false);
    assert.equal(crossedBelowReorderPoint(5, null, 2), false);
  });
});

describe("low-stock digest", () => {
  it("lists the fabric, metres, reorder point, and page, with no prices", () => {
    const digest = lowStockDigest([line]);
    assert.equal(digest.subject, "Low fabric: F002-125");
    assert.match(digest.text, /lime mesh/);
    assert.match(digest.text, /Available 1.5 m/);
    assert.match(digest.text, /Reorder point 2 m/);
    assert.match(digest.text, /https:\/\/studio.example\/inventory\/F002-125/);
    assert.match(digest.html, /https:\/\/photos.example\/thumb/);
    assert.equal(digest.text.includes("$"), false);
    assert.equal(/price|supplier/i.test(digest.text), false);
    assert.equal(/price|supplier/i.test(digest.html), false);
  });

  it("leaves the picture out when the fabric has no photo", () => {
    const digest = lowStockDigest([{ ...line, thumbUrl: null }, line]);
    assert.equal(digest.subject, "Low fabric: 2 materials");
    const parts = digest.html.split("</p>");
    assert.equal((parts[1] ?? "").includes("<img"), false);
    assert.equal((parts[2] ?? "").includes("<img"), true);
  });

  it("does not call the mailer when the key is missing or there is nothing to send", async () => {
    let calls = 0;
    const send = async () => {
      calls += 1;
      return { ok: true };
    };
    assert.equal(
      await deliverLowStockDigest({
        apiKey: undefined,
        from: "Dance Barre <onboarding@resend.dev>",
        to: "designstudio.dancebarre@gmail.com",
        lines: [line],
        send,
      }),
      "missing-key",
    );
    assert.equal(
      await deliverLowStockDigest({
        apiKey: "  ",
        from: "Dance Barre <onboarding@resend.dev>",
        to: "designstudio.dancebarre@gmail.com",
        lines: [line],
        send,
      }),
      "missing-key",
    );
    assert.equal(
      await deliverLowStockDigest({
        apiKey: "re_test",
        from: "Dance Barre <onboarding@resend.dev>",
        to: "designstudio.dancebarre@gmail.com",
        lines: [],
        send,
      }),
      "empty",
    );
    assert.equal(calls, 0);
  });

  it("sends one message and reports failure without throwing", async () => {
    let calls = 0;
    assert.equal(
      await deliverLowStockDigest({
        apiKey: "re_test",
        from: "Dance Barre <onboarding@resend.dev>",
        to: "designstudio.dancebarre@gmail.com",
        lines: [line],
        send: async () => {
          calls += 1;
          return { ok: true };
        },
      }),
      "sent",
    );
    assert.equal(calls, 1);
    assert.equal(
      await deliverLowStockDigest({
        apiKey: "re_test",
        from: "Dance Barre <onboarding@resend.dev>",
        to: "designstudio.dancebarre@gmail.com",
        lines: [line],
        send: async () => {
          throw new Error("network");
        },
      }),
      "failed",
    );
  });
});
