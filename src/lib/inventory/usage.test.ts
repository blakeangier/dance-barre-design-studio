import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  canReverseUsage,
  cmToMetres,
  filterUsageLog,
  metresToCm,
  orderFabricPosition,
  parseUsageAmount,
  planFabricUse,
  remainingReserved,
  stockAfterReversal,
  summarizeUsage,
  todayInToronto,
  type ReservationSlice,
} from "./usage.ts";

const HOUR = 60 * 60 * 1000;

describe("fabric use amounts", () => {
  it("converts centimetres and rejects a blank or zero amount", () => {
    assert.equal(cmToMetres(150), 1.5);
    assert.equal(cmToMetres(10), 0.1);
    assert.equal(metresToCm(1.5), 150);
    assert.equal(parseUsageAmount("1.5", "m"), 1.5);
    assert.equal(parseUsageAmount("15", "cm"), 0.15);
    assert.equal(parseUsageAmount("0", "m"), null);
    assert.equal(parseUsageAmount("-1", "cm"), null);
    assert.equal(parseUsageAmount("  ", "m"), null);
  });

  it("uses the Toronto calendar date", () => {
    assert.equal(
      todayInToronto(new Date("2026-01-15T03:30:00Z")),
      "2026-01-14",
    );
    assert.equal(
      todayInToronto(new Date("2026-07-15T03:30:00Z")),
      "2026-07-14",
    );
  });
});

describe("reservation drawdown", () => {
  const position = {
    reservedM: 4,
    usedM: 0,
    wasteM: 0,
    drawnM: 0,
  };

  it("takes a production use from the reservation and leaves available unchanged", () => {
    const plan = planFabricUse({
      onHandM: 10,
      reservedM: 4,
      purpose: "production",
      position,
      useM: 3,
      wasteM: 0,
    });
    assert.equal(plan.drawdownUseM, 3);
    assert.equal(plan.onHandAfter, 7);
    assert.equal(plan.reservedAfter, 1);
    assert.equal(plan.availableAfter, 6);
    assert.equal(plan.warnsExceedsReservation, false);
    assert.equal(plan.warnsNegativeOnHand, false);
  });

  it("draws the use first and then the waste, and warns when that exceeds the reservation", () => {
    const plan = planFabricUse({
      onHandM: 10,
      reservedM: 4,
      purpose: "production",
      position,
      useM: 3,
      wasteM: 2,
    });
    assert.equal(plan.drawdownUseM, 3);
    assert.equal(plan.drawdownWasteM, 1);
    assert.equal(plan.onHandAfter, 5);
    assert.equal(plan.reservedAfter, 0);
    assert.equal(plan.availableAfter, 5);
    assert.equal(plan.warnsExceedsReservation, true);
  });

  it("does not draw a sample, and does not warn when nothing is reserved", () => {
    const sample = planFabricUse({
      onHandM: 10,
      reservedM: 4,
      purpose: "sample",
      position,
      useM: 1,
      wasteM: 0,
    });
    assert.equal(sample.drawdownUseM, 0);
    assert.equal(sample.reservedAfter, 4);
    assert.equal(sample.availableAfter, 5);
    assert.equal(sample.warnsExceedsReservation, false);

    const unreserved = planFabricUse({
      onHandM: 10,
      reservedM: 0,
      purpose: "production",
      position: { reservedM: 0, usedM: 1, wasteM: 0, drawnM: 0 },
      useM: 2,
      wasteM: 0,
    });
    assert.equal(unreserved.drawdownUseM, 0);
    assert.equal(unreserved.warnsExceedsReservation, false);
    assert.equal(unreserved.availableAfter, 8);
  });

  it("warns when the use would take on-hand below zero and still plans the entry", () => {
    const plan = planFabricUse({
      onHandM: 1,
      reservedM: null,
      purpose: "sample",
      position: null,
      useM: 2,
      wasteM: 0,
    });
    assert.equal(plan.onHandAfter, -1);
    assert.equal(plan.warnsNegativeOnHand, true);
    assert.equal(plan.reservedAfter, null);
  });

  it("nets used and drawn metres from the ledger, including a reversal", () => {
    const rows: ReservationSlice[] = [
      {
        id: 1,
        materialId: 7,
        orderId: 3,
        txnType: "reserve",
        qtyM: 4,
        usageKind: null,
        waste: false,
        drawdownM: null,
        reversesId: null,
      },
      {
        id: 2,
        materialId: 7,
        orderId: 3,
        txnType: "use",
        qtyM: 2,
        usageKind: "production",
        waste: false,
        drawdownM: 2,
        reversesId: null,
      },
      {
        id: 3,
        materialId: 7,
        orderId: 3,
        txnType: "adjust",
        qtyM: 2,
        usageKind: null,
        waste: false,
        drawdownM: 2,
        reversesId: 2,
      },
      {
        id: 4,
        materialId: 7,
        orderId: 3,
        txnType: "use",
        qtyM: 0.5,
        usageKind: "production",
        waste: true,
        drawdownM: 0.5,
        reversesId: null,
      },
    ];
    const position = orderFabricPosition(rows, 7, 3);
    assert.deepEqual(position, {
      reservedM: 4,
      usedM: 0,
      wasteM: 0.5,
      drawnM: 0.5,
    });
    assert.equal(remainingReserved(position), 3.5);
  });
});

describe("reversing a fabric use", () => {
  const now = new Date("2026-10-31T15:00:00Z");
  const recent = new Date(now.getTime() - HOUR);
  const old = new Date(now.getTime() - 24 * HOUR);

  it("lets a person undo their own entry inside 24 hours", () => {
    assert.equal(
      canReverseUsage({
        createdBy: "person",
        createdAt: recent,
        alreadyReversed: false,
        actorId: "person",
        actorCanCorrectAny: false,
        now,
      }),
      true,
    );
    assert.equal(
      canReverseUsage({
        createdBy: "person",
        createdAt: old,
        alreadyReversed: false,
        actorId: "person",
        actorCanCorrectAny: false,
        now,
      }),
      false,
    );
    assert.equal(
      canReverseUsage({
        createdBy: "someone-else",
        createdAt: recent,
        alreadyReversed: false,
        actorId: "person",
        actorCanCorrectAny: false,
        now,
      }),
      false,
    );
  });

  it("lets an owner or production manager undo any entry, once", () => {
    assert.equal(
      canReverseUsage({
        createdBy: "someone-else",
        createdAt: old,
        alreadyReversed: false,
        actorId: "owner",
        actorCanCorrectAny: true,
        now,
      }),
      true,
    );
    assert.equal(
      canReverseUsage({
        createdBy: "someone-else",
        createdAt: recent,
        alreadyReversed: true,
        actorId: "owner",
        actorCanCorrectAny: true,
        now,
      }),
      false,
    );
  });

  it("puts the metres and the reservation back", () => {
    assert.deepEqual(
      stockAfterReversal({
        onHandM: 7,
        reservedM: 1,
        qtyM: 3,
        drawdownM: 3,
      }),
      { onHandM: 10, reservedM: 4, availableM: 6 },
    );
  });
});

describe("usage totals", () => {
  it("keeps sample metres apart from production metres", () => {
    const totals = summarizeUsage([
      {
        orderId: 3,
        styleId: 9,
        purpose: "production",
        waste: false,
        qtyM: 2,
        reversed: false,
      },
      {
        orderId: 3,
        styleId: 9,
        purpose: "production",
        waste: true,
        qtyM: 0.4,
        reversed: false,
      },
      {
        orderId: null,
        styleId: 9,
        purpose: "sample",
        waste: false,
        qtyM: 1.2,
        reversed: false,
      },
      {
        orderId: 3,
        styleId: 9,
        purpose: "production",
        waste: false,
        qtyM: 5,
        reversed: true,
      },
    ]);
    assert.deepEqual(totals.orders, [{ orderId: 3, usedM: 2, wasteM: 0.4 }]);
    assert.deepEqual(totals.styles, [
      {
        styleId: 9,
        sampleUsedM: 1.2,
        sampleWasteM: 0,
        productionUsedM: 2,
        productionWasteM: 0.4,
      },
    ]);
  });

  it("filters the log by fabric, order, style, person, date, and kind", () => {
    const entries = [
      {
        id: 1,
        createdBy: "elaine",
        occurredOn: "2026-10-01",
        purpose: "production" as const,
        materialCode: "F002-125",
        materialName: "lime mesh",
        orderNumber: "005",
        styleLabel: "skirt",
        qtyM: 2,
      },
      {
        id: 2,
        createdBy: "alex",
        occurredOn: "2026-10-20",
        purpose: "sample" as const,
        materialCode: "F002-125",
        materialName: "lime mesh",
        orderNumber: null,
        styleLabel: "bodice",
        qtyM: 0.5,
      },
    ];
    assert.deepEqual(
      filterUsageLog(entries, {
        material: "125",
        order: "005",
        style: "",
        personId: null,
        from: "2026-10-01",
        to: "2026-10-31",
        kind: "production",
      }).map((entry) => entry.id),
      [1],
    );
    assert.deepEqual(
      filterUsageLog(entries, {
        material: "",
        order: "",
        style: "bodice",
        personId: "alex",
        from: null,
        to: null,
        kind: "sample",
      }).map((entry) => entry.id),
      [2],
    );
  });
});
