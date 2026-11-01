import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  materialIdForBom,
  normalizeOrderStatus,
  parseMetres,
} from "./parse-lib.mjs";

describe("parseMetres", () => {
  it("keeps a single quantity, including a trailing m", () => {
    assert.deepEqual(parseMetres("100.0"), {
      metres: 100,
      raw: "100.0",
      needsReview: false,
    });
    assert.deepEqual(parseMetres("15m"), {
      metres: 15,
      raw: "15m",
      needsReview: false,
    });
    assert.deepEqual(parseMetres(""), {
      metres: null,
      raw: null,
      needsReview: false,
    });
  });

  it("does not guess a free-text stock figure", () => {
    const parsed = parseMetres("27.5m + 40m");
    assert.equal(parsed.metres, null);
    assert.equal(parsed.raw, "27.5m + 40m");
    assert.equal(parsed.needsReview, true);

    const joined = parseMetres("15m+ 105m");
    assert.equal(joined.metres, null);
    assert.equal(joined.needsReview, true);

    const uncertain = parseMetres("1m?");
    assert.equal(uncertain.metres, null);
    assert.equal(uncertain.needsReview, true);
  });
});

describe("material id conflicts", () => {
  it("does not link the Order 005 contrast lines to F002-125 or F002-25", () => {
    const written =
      "F002-125 (Order Form, Registry, Purchases) / F002-25 (Order 005 sheet)";
    const linked = materialIdForBom("", written);
    assert.equal(linked.materialCode, null);
    assert.equal(linked.needsReview, true);
    assert.match(linked.reason, /not linked/);
  });

  it("keeps a known material id when the written id agrees", () => {
    const linked = materialIdForBom("F001-06", "F001-06");
    assert.equal(linked.materialCode, "F001-06");
    assert.equal(linked.needsReview, false);
  });
});

describe("order status", () => {
  it("normalises cancelled wording and keeps the original text", () => {
    assert.deepEqual(normalizeOrderStatus("cancelled"), {
      status: "cancelled",
      raw: "cancelled",
    });
    assert.deepEqual(normalizeOrderStatus("Cancelled-purchasing"), {
      status: "cancelled",
      raw: "Cancelled-purchasing",
    });
    assert.deepEqual(normalizeOrderStatus(""), {
      status: null,
      raw: null,
    });
  });
});
