import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { fabricNeeded } from "../production/fabric-need.ts";
import {
  countsForStyle,
  gridTotals,
  longSizeCsv,
  orderGridCsv,
  wideSizeCsv,
} from "./size-grid.ts";

describe("order size grid", () => {
  const columns = ["SC", "MC", "SA"];
  const rows = [
    { label: "Girls leo", qty: { SC: 2, MC: 1, SA: null } },
    { label: "Women's leo", qty: { SC: null, MC: null, SA: 11 } },
  ];

  it("totals each style, each size, and the order", () => {
    const totals = gridTotals(columns, rows);
    assert.deepEqual(totals.rowTotals, [3, 11]);
    assert.deepEqual(totals.columnTotals, [2, 1, 11]);
    assert.equal(totals.grand, 14);
  });

  it("writes a grid CSV that Google Sheets can import", () => {
    const csv = orderGridCsv({ columns, rows });
    assert.equal(csv.charCodeAt(0), 0xfeff);
    assert.match(csv, /Style,SC,MC,SA,Total\r\n/);
    assert.match(csv, /Girls leo,2,1,,3\r\n/);
    assert.match(csv, /Total,2,1,11,14\r\n/);
  });

  it("exports every order long and wide", () => {
    const long = longSizeCsv([
      {
        orderNumber: "005",
        program: "Recreational",
        style: "Girls leo",
        size: "MC",
        quantity: 2,
      },
    ]);
    assert.match(
      long,
      /Order,Program,Style,Size,Quantity\r\n005,Recreational,Girls leo,MC,2\r\n/,
    );
    const wide = wideSizeCsv({
      columns,
      rows: [
        {
          orderNumber: "005",
          program: "Recreational",
          style: "Girls leo",
          qty: { SC: 2, MC: 1, SA: null },
        },
      ],
    });
    assert.match(wide, /005,Recreational,Girls leo,2,1,,3\r\n/);
  });
});

describe("sized fabric from the grid", () => {
  it("uses one style's quantities and not the other styles on the order", () => {
    const sizes = [
      { styleId: 1, sizeCode: "SC", count: 4 },
      { styleId: 2, sizeCode: "SC", count: 10 },
    ];
    const girls = countsForStyle(sizes, 1);
    const need = fabricNeeded({
      sizePieces: [{ sizeCode: "SC", metresPerPiece: 0.5 }],
      sizeCounts: girls,
      wastePercent: null,
      estimateMetresPerPiece: null,
      isEstimate: false,
    });
    assert.equal(need.metres, 2);
    assert.equal(countsForStyle(sizes, null)[0]?.count, 14);
  });
});
