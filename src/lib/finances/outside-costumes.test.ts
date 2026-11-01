import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  looksLikeFullCardNumber,
  outsideCostumeRowHash,
  outsideCostumeSpend,
} from "./outside-costumes.ts";

describe("outside costumes", () => {
  it("keeps a stable hash and rejects a full card number", () => {
    const row = {
      sourceTab: "SAMPLE",
      sourceRow: 4,
      rawDate: "Aug. 19",
      vendor: "SAMPLE Shop",
      itemDescription: "SAMPLE skirt",
      paymentMethod: "6261",
    };
    assert.equal(outsideCostumeRowHash(row), outsideCostumeRowHash(row));
    assert.notEqual(
      outsideCostumeRowHash(row),
      outsideCostumeRowHash({ ...row, sourceRow: 5 }),
    );
    assert.equal(looksLikeFullCardNumber("6261"), false);
    assert.equal(looksLikeFullCardNumber("4111111111111111"), true);
  });

  it("sums SAMPLE purchases without mixing CAD and USD, and flags gaps", () => {
    const spend = outsideCostumeSpend([
      {
        vendor: "SAMPLE Shop",
        amount: 20,
        currency: "CAD",
        purchasedOn: "2026-08-19",
        rawDate: "Aug. 19",
        refund: false,
        archived: false,
      },
      {
        vendor: "SAMPLE Shop",
        amount: 5,
        currency: "CAD",
        purchasedOn: "2026-08-20",
        rawDate: "Aug. 20",
        refund: true,
        archived: false,
      },
      {
        vendor: "SAMPLE USD",
        amount: 8,
        currency: "USD",
        purchasedOn: null,
        rawDate: "Aug. 19",
        refund: false,
        archived: false,
      },
      {
        vendor: "SAMPLE Shop",
        amount: null,
        currency: "CAD",
        purchasedOn: null,
        rawDate: null,
        refund: false,
        archived: false,
      },
      {
        vendor: "SAMPLE Shop",
        amount: 99,
        currency: "CAD",
        purchasedOn: "2026-01-01",
        rawDate: "Jan. 1",
        refund: false,
        archived: true,
      },
    ]);
    assert.equal(spend.cad, 15);
    assert.equal(spend.usd, 8);
    assert.equal(spend.missingAmount, 1);
    assert.equal(spend.missingDate, 1);
    assert.equal(spend.byVendor[0]?.vendor, "SAMPLE Shop");
    assert.equal(
      spend.byMonth.some((month) => month.month === "No date"),
      true,
    );
  });
});
