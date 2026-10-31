import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { includeInPayrollExport, payrollCsv } from "./export-csv.ts";

describe("payroll csv", () => {
  it("says this is not an ADP file and does not include dollars", () => {
    const csv = payrollCsv([
      {
        employeeName: "Sample, Person",
        periodStart: "2026-01-05",
        periodEnd: "2026-01-18",
        regularHours: 7.5,
        totalHours: 7.5,
        notes: "Overtime is not calculated.",
      },
    ]);
    assert.match(csv, /Not an ADP import file/);
    assert.match(csv, /Unpaid breaks are already subtracted/);
    assert.match(csv, /"Sample, Person"/);
    assert.equal(csv.includes("$"), false);
  });

  it("leaves contractors out of the payroll file", () => {
    assert.equal(includeInPayrollExport("contractor"), false);
    assert.equal(includeInPayrollExport("full-time"), true);
    assert.equal(includeInPayrollExport("part-time"), true);
    assert.equal(includeInPayrollExport(null), true);
  });
});
