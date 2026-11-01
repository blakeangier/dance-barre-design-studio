import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  contractSpread,
  contractStanding,
  costComparison,
  equipmentSavings,
  fundingCheck,
  invoiceSummary,
  leaseStanding,
  monthIsProduction,
  otherMonthly,
  outsideCostumeSummary,
  percentOf,
  projectWorkbook,
  spendToDate,
  startupCounted,
  teamMonthly,
} from "./workbook.ts";

describe("finance workbook", () => {
  it("groups SAMPLE spend and checks that funding matches", () => {
    const spent = spendToDate([
      {
        section: "design_co",
        label: "SAMPLE tools",
        amount: 75,
        href: "/finances/startup",
        sourceNote: "SAMPLE",
      },
      {
        section: "outside_costumes",
        label: "SAMPLE skirts",
        amount: 25,
        href: "/finances/outside-costumes",
        sourceNote: "SAMPLE",
      },
    ]);
    assert.equal(spent.total, 100);
    assert.equal(spent.sections[0]?.subtotal, 75);
    assert.equal(spent.sections[0]?.rows[0]?.percent, 75);
    assert.equal(spent.sections[1]?.subtotal, 25);
    const funding = fundingCheck(spent.total, [
      {
        paidFrom: "card",
        label: "SAMPLE 6261",
        amount: 60,
        sourceNote: "SAMPLE",
      },
      {
        paidFrom: "e-transfer",
        label: "SAMPLE transfer",
        amount: 40,
        sourceNote: "SAMPLE",
      },
    ]);
    assert.equal(funding.balances, true);
    assert.equal(funding.difference, 0);
    assert.equal(percentOf(1, 0), 0);
  });

  it("counts a SAMPLE startup share and the season costume cost", () => {
    const counted = startupCounted(200, 26, 50);
    assert.equal(counted.pretax, 100);
    assert.equal(counted.hst, 13);
    const comparison = costComparison({
      startup: 100,
      make: 40,
      purchased: 60,
      startupOwed: 15,
      units: 4,
      costPerUnit: 25,
    });
    assert.equal(comparison.all, 200);
    assert.equal(comparison.startupShare, 50);
    assert.equal(comparison.seasonCostumes, 100);
    assert.equal(comparison.extendedUnits, 100);
    assert.equal(comparison.fullStartup, 115);
  });

  it("uses Fall and Spring as the SAMPLE production default, then an override", () => {
    assert.equal(monthIsProduction("2026-01-01", [], null), false);
    assert.equal(monthIsProduction("2026-08-01", [], null), true);
    assert.equal(monthIsProduction("2026-12-01", [], null), true);
    assert.equal(monthIsProduction("2026-05-01", [], null), false);
    assert.equal(monthIsProduction("2026-01-01", [], true), true);
    assert.equal(
      monthIsProduction(
        "2026-08-01",
        [{ start: "2026-06-01", end: "2026-06-30" }],
        null,
      ),
      false,
    );
  });

  it("prices SAMPLE team rows at weekly times 4.33 and spreads a contract", () => {
    const hourly = teamMonthly({
      payKind: "hourly_weekly",
      hoursPerWeek: 10,
      rate: 2,
      addsHst: false,
    });
    assert.equal(hourly.weekly, 20);
    assert.equal(hourly.pretax, 86.6);
    const fixed = teamMonthly({
      payKind: "fixed_biweekly",
      hoursPerWeek: null,
      rate: 20,
      addsHst: true,
    });
    assert.equal(fixed.weekly, 10);
    assert.equal(fixed.pretax, 43.3);
    assert.equal(fixed.hst, 5.63);
    assert.equal(
      otherMonthly(
        { amount: 12, period: "year", runs: "production_only" },
        false,
      ),
      0,
    );
    assert.equal(
      otherMonthly({ amount: 12, period: "year", runs: "every_month" }, false),
      1,
    );
    const spread = contractSpread({
      remaining: 120,
      start: "2026-10-01",
      end: "2026-12-31",
      today: "2026-10-15",
    });
    assert.deepEqual(
      spread.map((part) => part.amount),
      [40, 40, 40],
    );
    const grid = projectWorkbook({
      today: "2026-10-15",
      months: [
        { month: "2026-10-01", production: true },
        { month: "2026-11-01", production: false },
      ],
      team: [
        {
          name: "SAMPLE Maker",
          role: "SAMPLE",
          payKind: "hourly_weekly",
          hoursPerWeek: 10,
          rate: 2,
          addsHst: false,
          runs: "production_only",
          sourceNote: "SAMPLE",
        },
      ],
      others: [],
      contracts: [
        {
          label: "SAMPLE contract",
          remaining: 120,
          start: "2026-10-01",
          end: "2026-12-31",
          sourceNote: "SAMPLE",
        },
      ],
    });
    assert.equal(grid.months[0]?.team, 86.6);
    assert.equal(grid.months[1]?.team, 0);
    assert.equal(grid.months[0]?.contracts, 40);
    assert.equal(grid.months[1]?.contracts, 40);
    assert.equal(grid.months[0]?.total, 126.6);
  });

  it("flags a SAMPLE underpayment and the contract balance", () => {
    const invoices = invoiceSummary([
      { hours: 4, expected: 40, paid: 30, hst: 0 },
      { hours: 2, expected: 20, paid: 20, hst: 2 },
    ]);
    assert.equal(invoices.underpaid, 1);
    assert.equal(invoices.difference, -10);
    assert.equal(invoices.averageHours, 3);
    const standing = contractStanding({
      phases: [
        { beforeHst: 80, hst: 10 },
        { beforeHst: 20, hst: 0 },
      ],
      fallbackBeforeHst: 0,
      fallbackHst: 0,
      payments: [
        { amount: 30, hst: 0, paidOn: "2026-10-01" },
        { amount: 50, hst: 0, paidOn: "2026-12-01" },
      ],
      end: "2026-12-31",
      today: "2026-10-15",
    });
    assert.equal(standing.inclHst, 110);
    assert.equal(standing.paid, 30);
    assert.equal(standing.remaining, 80);
    assert.equal(standing.monthsLeft, 3);
    assert.equal(standing.paymentsLeft, 3);
  });

  it("prices SAMPLE equipment and the chosen lease", () => {
    assert.equal(equipmentSavings(80, 50), 30);
    assert.equal(equipmentSavings(null, 50), null);
    const lease = leaseStanding({
      termMonths: 6,
      monthly: 10,
      hst: 1.3,
      upfront: 22.6,
      paymentsMade: 2,
      startedOn: "2026-10-01",
    });
    assert.equal(lease.paidToDate, 45.2);
    assert.equal(lease.remainingPayments, 4);
    assert.equal(lease.finalMonth, "2027-03");
  });

  it("summarizes SAMPLE outside costumes and leaves out canceled rows", () => {
    const summary = outsideCostumeSummary([
      {
        program: "SAMPLE Crew",
        vendorType: "SAMPLE retailer",
        vendor: "SAMPLE Shop",
        amount: 20,
        currency: "CAD",
        refund: false,
        duplicate: false,
        canceled: false,
        owing: false,
        archived: false,
      },
      {
        program: "SAMPLE Crew",
        vendorType: "SAMPLE retailer",
        vendor: "SAMPLE Shop",
        amount: 8,
        currency: "USD",
        refund: false,
        duplicate: false,
        canceled: false,
        owing: true,
        archived: false,
      },
      {
        program: "SAMPLE Crew",
        vendorType: "SAMPLE retailer",
        vendor: "SAMPLE Shop",
        amount: 99,
        currency: "CAD",
        refund: false,
        duplicate: false,
        canceled: true,
        owing: false,
        archived: false,
      },
    ]);
    assert.equal(summary.byProgram[0]?.cad, 20);
    assert.equal(summary.byProgram[0]?.usd, 8);
    assert.equal(summary.byVendorType[0]?.name, "SAMPLE retailer");
    assert.equal(summary.owing, 8);
  });
});
