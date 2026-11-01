import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  compareOrderNumbers,
  embeddedProgramName,
  groupOrdersForSelect,
  orderChoiceLabel,
} from "./label.ts";

describe("orderChoiceLabel", () => {
  it("joins number, song, and program", () => {
    assert.equal(
      orderChoiceLabel({
        orderNumber: "001",
        song: "Sing Sing Sing",
        program: "Elite Company",
      }),
      "001 · Sing Sing Sing · Elite Company",
    );
  });

  it("drops a missing program or song", () => {
    assert.equal(
      orderChoiceLabel({
        orderNumber: "015",
        song: "Wang Dang",
        program: null,
      }),
      "015 · Wang Dang",
    );
    assert.equal(
      orderChoiceLabel({
        orderNumber: "015",
        song: "  ",
        program: "CREW",
      }),
      "015 · CREW",
    );
    assert.equal(
      orderChoiceLabel({ orderNumber: "015", song: null, program: null }),
      "015",
    );
  });

  it("hides a program the query could not see", () => {
    assert.equal(embeddedProgramName(null), null);
    assert.equal(embeddedProgramName([]), null);
    assert.equal(embeddedProgramName({ name: "  " }), null);
    assert.equal(
      embeddedProgramName([{ name: "Petite Elite" }]),
      "Petite Elite",
    );
  });
});

describe("groupOrdersForSelect", () => {
  it("sorts by program, then order number, and keeps a no-program group last", () => {
    const groups = groupOrdersForSelect([
      { id: 2, orderNumber: "010", song: "Later", program: "CREW" },
      { id: 1, orderNumber: "002", song: "Early", program: "CREW" },
      { id: 4, orderNumber: "015", song: "Wang Dang", program: null },
      { id: 3, orderNumber: "001", song: "Sing", program: "Elite Company" },
    ]);
    assert.deepEqual(
      groups.map((group) => ({
        label: group.label,
        numbers: group.orders.map((order) => order.orderNumber),
      })),
      [
        { label: "CREW", numbers: ["002", "010"] },
        { label: "Elite Company", numbers: ["001"] },
        { label: "No program", numbers: ["015"] },
      ],
    );
    assert.equal(compareOrderNumbers("2", "10") < 0, true);
  });

  it("does not invent a group when no order has a program", () => {
    const groups = groupOrdersForSelect([
      { id: 2, orderNumber: "10", song: null, program: null },
      { id: 1, orderNumber: "2", song: "Solo", program: " " },
    ]);
    assert.equal(groups.length, 1);
    assert.equal(groups[0]?.label, null);
    assert.deepEqual(
      groups[0]?.orders.map((order) => order.orderNumber),
      ["2", "10"],
    );
  });
});
