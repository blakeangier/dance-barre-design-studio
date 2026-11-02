import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  cleanProgramFilter,
  cleanSeasonFilter,
  currentOutsideComparison,
  filterHistoricalLines,
  isCreditLine,
  pastSpendHref,
  summarizeBySeason,
  topPayees,
  type CurrentOutsideLine,
} from "./historical-spend.ts";

describe("historical costume spend", () => {
  it("sums SAMPLE seasons into Elite, Recreational, CREW, and Other", () => {
    const summary = summarizeBySeason([
      { season: "2024-25", program: "CREW", net: 7 },
      { season: "2023-24", program: "Elite Company", net: 10 },
      { season: "2023-24", program: "Elite Company", net: 0.1 },
      { season: "2023-24", program: "Elite Company", net: 0.2 },
      { season: "2023-24", program: "Recreational", net: 3 },
      { season: "2023-24", program: "CREW", net: 4 },
      { season: "2023-24", program: "ABC", net: 1 },
      { season: "2023-24", program: "Kickstart", net: 2 },
      { season: "2023-24", program: "Elite Company", net: -1 },
    ]);
    assert.equal(summary[0]?.season, "2023-24");
    assert.equal(summary[0]?.elite, 9.3);
    assert.equal(summary[0]?.recreational, 3);
    assert.equal(summary[0]?.crew, 4);
    assert.equal(summary[0]?.other, 3);
    assert.equal(summary[0]?.total, 19.3);
    assert.equal(summary[1]?.season, "2024-25");
    assert.equal(summary[1]?.crew, 7);
    assert.equal(summary[1]?.total, 7);
  });

  it("treats a SAMPLE credit as a refund and ranks payees on net", () => {
    assert.equal(isCreditLine({ credit: 1, net: -1 }), true);
    assert.equal(isCreditLine({ credit: 0, net: -2 }), true);
    assert.equal(isCreditLine({ credit: 0, net: 5 }), false);
    assert.deepEqual(
      topPayees(
        [
          { season: "2024-25", payee: "SAMPLE Shop", net: 10 },
          { season: "2024-25", payee: "SAMPLE Shop", net: -2 },
          { season: "2024-25", payee: "SAMPLE Other", net: 4 },
          { season: "2023-24", payee: "SAMPLE Shop", net: 100 },
        ],
        "2024-25",
      ),
      [
        { payee: "SAMPLE Shop", net: 8, lines: 2 },
        { payee: "SAMPLE Other", net: 4, lines: 1 },
      ],
    );
  });

  it("keeps SAMPLE 2026-27 CAD outside spend to Elite and CREW", () => {
    const cad = (
      program: string,
      amount: number | null,
      purchasedOn: string | null,
      flags: Partial<CurrentOutsideLine> = {},
    ): CurrentOutsideLine => ({
      program,
      amount,
      currency: "CAD",
      purchasedOn,
      refund: false,
      archived: false,
      duplicate: false,
      canceled: false,
      ...flags,
    });
    const comparison = currentOutsideComparison([
      cad("Elite Company", 10, "2026-06-02"),
      cad("Elite Company", 4, "2026-07-01", { refund: true }),
      cad("CREW", 6, "2027-05-31"),
      cad("Recreational", 99, "2026-08-01"),
      cad("Petite Elite", 50, "2026-08-01"),
      cad("Elite Company", 3, "2026-05-31"),
      cad("Elite Company", 8, null),
      {
        program: "Elite Company",
        amount: 2,
        currency: "USD",
        purchasedOn: "2026-09-01",
        refund: false,
        archived: false,
        duplicate: false,
        canceled: false,
      },
      cad("CREW", 20, "2026-09-01", { archived: true }),
      cad("CREW", 20, "2026-09-01", { duplicate: true }),
      cad("CREW", 20, "2026-09-01", { canceled: true }),
      cad("Elite Company", null, "2026-09-01"),
    ]);
    assert.equal(comparison.eliteCad, 6);
    assert.equal(comparison.crewCad, 6);
    assert.equal(comparison.totalCad, 12);
    assert.equal(comparison.eliteUsd, 2);
    assert.equal(comparison.crewUsd, 0);
    assert.equal(comparison.totalUsd, 2);
    assert.equal(comparison.skippedUndated, 1);
    assert.equal(comparison.skippedOutsideWindow, 1);
  });

  it("filters SAMPLE lines by season and the Other column", () => {
    const rows = [
      { season: "2023-24", program: "ABC" },
      { season: "2023-24", program: "Kickstart" },
      { season: "2023-24", program: "CREW" },
      { season: "2024-25", program: "ABC" },
    ];
    assert.equal(
      filterHistoricalLines(rows, { season: "2023-24", program: "Other" })
        .length,
      2,
    );
    assert.equal(
      filterHistoricalLines(rows, { season: "2023-24", program: "" }).length,
      3,
    );
    assert.equal(cleanSeasonFilter("2023-24"), "2023-24");
    assert.equal(cleanSeasonFilter("all"), "");
    assert.equal(cleanProgramFilter("Other"), "Other");
    assert.equal(cleanProgramFilter("Petite Elite"), "");
    assert.equal(
      pastSpendHref("2023-24", "Elite Company"),
      "/finances/past-spend?season=2023-24&program=Elite+Company",
    );
  });
});
