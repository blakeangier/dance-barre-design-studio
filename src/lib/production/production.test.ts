import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { dancerLabel, SEWING_ROUTE } from "./dancer.ts";
import {
  fabricNeeded,
  reserveQuantity,
  shortageMetres,
} from "./fabric-need.ts";
import { DEFAULT_QC_ITEMS, qcBlocksPickup } from "./qc.ts";
import { monthDays, orderTimingFlag } from "./schedule.ts";

describe("sized fabric need", () => {
  it("adds size quantities times costume counts and waste", () => {
    const need = fabricNeeded({
      sizePieces: [
        { sizeCode: "SC", metresPerPiece: 0.5 },
        { sizeCode: "MC", metresPerPiece: 0.8 },
      ],
      sizeCounts: [
        { sizeCode: "SC", count: 4 },
        { sizeCode: "MC", count: 2 },
      ],
      wastePercent: 10,
      estimateMetresPerPiece: 1,
      isEstimate: true,
    });
    assert.equal(need.estimate, false);
    assert.equal(need.metres, 3.96);
  });

  it("keeps an Order 005 line as a flagged estimate when no sizes are entered", () => {
    const need = fabricNeeded({
      sizePieces: [],
      sizeCounts: [{ sizeCode: "SC", count: 10 }],
      wastePercent: null,
      estimateMetresPerPiece: 0.4,
      isEstimate: true,
    });
    assert.equal(need.estimate, true);
    assert.equal(need.metres, 4);
    assert.equal(shortageMetres(4, 1.5), 2.5);
    assert.equal(shortageMetres(4, null), null);
    assert.equal(reserveQuantity(4, 1), 3);
  });
});

describe("quality check gate", () => {
  it("blocks pickup until every item passes and open rework is resolved", () => {
    assert.equal(
      qcBlocksPickup({
        templateNames: ["Seams secure"],
        checks: [],
        hasOverride: false,
      }),
      true,
    );
    assert.equal(
      qcBlocksPickup({
        templateNames: [...DEFAULT_QC_ITEMS],
        checks: DEFAULT_QC_ITEMS.map((itemName) => ({
          itemName,
          result: "pass" as const,
          resolved: false,
        })),
        hasOverride: false,
      }),
      false,
    );
    assert.equal(
      qcBlocksPickup({
        templateNames: ["Seams secure"],
        checks: [{ itemName: "Seams secure", result: "fail", resolved: false }],
        hasOverride: false,
      }),
      true,
    );
    assert.equal(
      qcBlocksPickup({
        templateNames: ["Seams secure"],
        checks: [{ itemName: "Seams secure", result: "fail", resolved: false }],
        hasOverride: true,
      }),
      false,
    );
  });
});

describe("due dates", () => {
  it("marks an order late when a later milestone date has passed", () => {
    assert.equal(
      orderTimingFlag("2026-11-01", "cutting", [
        { status: "sewing", targetOn: "2026-10-20" },
      ]),
      "late",
    );
    assert.equal(
      orderTimingFlag("2026-11-01", "sewing", [
        { status: "sewing", targetOn: "2026-11-03" },
      ]),
      "at_risk",
    );
    assert.equal(
      orderTimingFlag("2026-11-01", "delivered", [
        { status: "sewing", targetOn: "2026-10-01" },
      ]),
      null,
    );
    assert.equal(monthDays(2026, 11).length, 30);
  });
});

describe("dancer names and the sewing route", () => {
  it("keeps a first name and one last initial", () => {
    assert.equal(dancerLabel("Ava", "m"), "Ava M");
    assert.equal(dancerLabel("Ava", "Moore"), null);
    assert.deepEqual(SEWING_ROUTE[0], "Prep");
    assert.equal(SEWING_ROUTE.at(-1), "QC");
  });
});
