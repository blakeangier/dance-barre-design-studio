import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { financesStatus } from "./access.ts";
import {
  annualized,
  averageMonthlyPayroll,
  currentBiweeklyPeriod,
  employeeGross,
  monthlyAmount,
  monthlyCategorySpend,
  parseCardCsv,
  recurringMonthly,
  variableMonthly,
  workedHours,
} from "./money.ts";

describe("owner finances access", () => {
  it("returns 403 for every role except owner", () => {
    assert.equal(financesStatus("owner"), 200);
    for (const role of [
      "production_manager",
      "payroll_admin",
      "employee",
      "program_director",
      null,
    ]) {
      assert.equal(financesStatus(role), 403);
    }
  });
});

describe("run rate", () => {
  it("normalizes recurring costs to a month and leaves HST separate", () => {
    const monthly = recurringMonthly(
      [
        {
          amount: 1200,
          hst: 156,
          frequency: "yearly",
          start: "2026-01-01",
          end: null,
          excluded: false,
        },
        {
          amount: 300,
          hst: 0,
          frequency: "quarterly",
          start: "2026-01-01",
          end: null,
          excluded: false,
        },
        {
          amount: 999,
          hst: 0,
          frequency: "monthly",
          start: "2026-01-01",
          end: null,
          excluded: true,
        },
      ],
      "2026-10-31",
    );
    assert.equal(monthly.pretax, 200);
    assert.equal(monthly.hst, 13);
    assert.equal(
      monthlyAmount(260, "bi-weekly"),
      monthlyAmount(260, "per_pay_period"),
    );
    assert.equal(annualized(200), 2400);
    assert.equal(
      averageMonthlyPayroll([
        {
          start: "2026-10-06",
          end: "2026-10-19",
          gross: 1000,
          cpp: 60,
          ei: 20,
        },
      ]),
      1080,
    );
  });

  it("averages the last 90 days of variable card spend and skips startup and excluded lines", () => {
    const variable = variableMonthly(
      [
        {
          date: "2026-10-01",
          amount: 300,
          hst: 39,
          excluded: false,
          startup: false,
          categoryExcluded: false,
        },
        {
          date: "2026-09-01",
          amount: 50,
          hst: 0,
          excluded: false,
          startup: true,
          categoryExcluded: false,
        },
        {
          date: "2026-10-15",
          amount: 80,
          hst: 0,
          excluded: true,
          startup: false,
          categoryExcluded: false,
        },
        {
          date: "2026-10-20",
          amount: 40,
          hst: 0,
          excluded: false,
          startup: false,
          categoryExcluded: true,
        },
      ],
      "2026-10-31",
    );
    assert.equal(variable.pretax, 100);
    assert.equal(variable.hst, 13);
  });
});

describe("payroll and the card file", () => {
  it("pays approved employee hours and leaves contractors out", () => {
    assert.equal(
      workedHours("2026-10-01T13:00:00Z", "2026-10-01T21:00:00Z", 30, false),
      7.5,
    );
    assert.equal(
      employeeGross([
        { hours: 10, rate: 20, contractor: false },
        { hours: 8, rate: 40, contractor: true },
        { hours: 5, rate: null, contractor: false },
      ]),
      200,
    );
  });

  it("reads a SAMPLE card file and groups spend with HST beside it", () => {
    const parsed = parseCardCsv(
      "date,merchant,amount_cad,category,note\n2026-10-02,SAMPLE Shop,25.00,Fabric,SAMPLE swatch\n",
    );
    assert.equal(parsed.ok, true);
    if (!parsed.ok) return;
    assert.equal(parsed.rows[0]?.merchant, "SAMPLE Shop");
    assert.equal(parseCardCsv("merchant,amount\nSAMPLE,1").ok, false);
    const chart = monthlyCategorySpend([
      {
        month: "2026-10",
        category: "Fabric",
        pretax: 25,
        hst: 3.25,
        excluded: false,
      },
      {
        month: "2026-10",
        category: "Not a Design Studio cost",
        pretax: 9,
        hst: 0,
        excluded: true,
      },
    ]);
    assert.equal(chart[0]?.pretax, 25);
    assert.equal(chart[0]?.hst, 3.25);
    assert.deepEqual(currentBiweeklyPeriod("2026-01-05"), {
      start: "2026-01-05",
      end: "2026-01-18",
    });
  });
});
