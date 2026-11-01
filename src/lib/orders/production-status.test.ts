import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  PRODUCTION_STATUSES,
  productionStatusIndex,
  productionStatusLabel,
} from "./production-status.ts";

describe("production status", () => {
  it("keeps the shop steps in order", () => {
    assert.deepEqual(
      PRODUCTION_STATUSES.map((status) => status.label),
      [
        "Not started",
        "Design and samples",
        "Fabric ordered",
        "Ready to cut",
        "Cutting",
        "Sewing",
        "Finishing and quality check",
        "Ready for pickup",
        "Delivered",
      ],
    );
    assert.equal(productionStatusIndex("delivered"), 8);
    assert.equal(productionStatusIndex("not_started"), 0);
    assert.equal(productionStatusLabel("sewing"), "Sewing");
    assert.equal(productionStatusLabel(null), "Not started");
  });
});
