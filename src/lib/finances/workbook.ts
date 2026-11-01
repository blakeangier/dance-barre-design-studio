import { cents } from "./money.ts";

export const WEEKS_PER_MONTH = 4.33;
export const ONTARIO_HST_RATE = 0.13;

export const PAID_FROM = [
  ["card", "Card ending"],
  ["e-transfer", "E-transfer"],
  ["carm_credit", "CARM credit"],
  ["personal_card_reimbursed", "Personal card reimbursed"],
  ["payroll_eft", "Payroll EFT"],
  ["lease", "Lease"],
  ["not_recorded", "Not recorded"],
] as const;

export const EXPENSE_CATEGORIES = [
  ["equipment_tools", "Equipment & tools"],
  ["studio_build_out", "Studio build-out"],
  ["fabric_supplies", "Fabric & supplies"],
  ["website", "Website"],
  ["people", "People"],
  ["admin_fees", "Admin & fees"],
  ["equipment_repair", "Equipment repair"],
  ["supplies_reimbursed", "Supplies reimbursed"],
] as const;

export const SPEND_SECTIONS = [
  ["design_co", "Design Co"],
  ["outside_costumes", "Outside costumes (studio)"],
] as const;

export type SpendSection = (typeof SPEND_SECTIONS)[number][0];
export type PaidFrom = (typeof PAID_FROM)[number][0];
export type ExpenseCategory = (typeof EXPENSE_CATEGORIES)[number][0];

export function labelOf(
  pairs: readonly (readonly [string, string])[],
  key: string,
): string {
  return pairs.find((pair) => pair[0] === key)?.[1] ?? key;
}

export function percentOf(part: number, total: number): number {
  if (total === 0) return 0;
  return Math.round((part / total) * 1000) / 10;
}

export function sourceText(note: string | null | undefined): string {
  const trimmed = note?.trim();
  return trimmed ? trimmed : "Not recorded";
}

export type SpendLine = {
  section: SpendSection;
  label: string;
  amount: number;
  href: string | null;
  sourceNote: string;
};

export function spendToDate(lines: readonly SpendLine[]) {
  const total = cents(lines.reduce((sum, line) => sum + line.amount, 0));
  const sections = SPEND_SECTIONS.map(([section, title]) => {
    const rows = lines.filter((line) => line.section === section);
    const subtotal = cents(rows.reduce((sum, line) => sum + line.amount, 0));
    return {
      section,
      title,
      subtotal,
      rows: rows.map((line) => ({
        ...line,
        percent: percentOf(line.amount, total),
      })),
    };
  });
  return { total, sections };
}

export type FundingLine = {
  paidFrom: string;
  label: string;
  amount: number;
  sourceNote: string;
};

export function fundingCheck(spent: number, sources: readonly FundingLine[]) {
  const total = cents(sources.reduce((sum, line) => sum + line.amount, 0));
  return {
    total,
    rows: sources.map((line) => ({
      ...line,
      percent: percentOf(line.amount, total),
    })),
    difference: cents(total - spent),
    balances: cents(total) === cents(spent),
  };
}

export function startupCounted(
  amount: number,
  hst: number,
  sharePercent: number,
): { pretax: number; hst: number } {
  const share = sharePercent / 100;
  return { pretax: cents(amount * share), hst: cents(hst * share) };
}

export function costComparison(input: {
  startup: number;
  make: number;
  purchased: number;
  startupOwed: number;
  units: number | null;
  costPerUnit: number | null;
}) {
  const all = cents(input.startup + input.make + input.purchased);
  return {
    all,
    startupShare: percentOf(input.startup, all),
    makeShare: percentOf(input.make, all),
    purchasedShare: percentOf(input.purchased, all),
    seasonCostumes: cents(input.make + input.purchased),
    units: input.units,
    costPerUnit: input.costPerUnit,
    extendedUnits:
      input.units === null || input.costPerUnit === null
        ? null
        : cents(input.units * input.costPerUnit),
    fullStartup: cents(input.startup + input.startupOwed),
  };
}

export function monthKey(value: string): string {
  return value.slice(0, 7);
}

export function nextTwelveMonths(today: string): string[] {
  const [yearText, monthText] = monthKey(today).split("-");
  const year = Number(yearText);
  const month = Number(monthText);
  return Array.from({ length: 12 }, (_, index) => {
    const cursor = new Date(Date.UTC(year, month - 1 + index, 1));
    const y = cursor.getUTCFullYear();
    const m = String(cursor.getUTCMonth() + 1).padStart(2, "0");
    return `${y}-${m}-01`;
  });
}

function monthBounds(month: string): { start: string; end: string } {
  const [yearText, monthText] = monthKey(month).split("-");
  const year = Number(yearText);
  const monthNumber = Number(monthText);
  const last = new Date(Date.UTC(year, monthNumber, 0)).getUTCDate();
  const mm = String(monthNumber).padStart(2, "0");
  return {
    start: `${year}-${mm}-01`,
    end: `${year}-${mm}-${String(last).padStart(2, "0")}`,
  };
}

function overlaps(month: string, start: string, end: string): boolean {
  const bounds = monthBounds(month);
  return bounds.start <= end && bounds.end >= start;
}

export function defaultSeasonWindows(
  year: number,
): { start: string; end: string }[] {
  return [
    { start: `${year}-02-01`, end: `${year}-04-15` },
    { start: `${year}-08-01`, end: `${year}-12-05` },
  ];
}

export function monthIsProduction(
  month: string,
  seasons: readonly { start: string; end: string }[],
  override: boolean | null,
): boolean {
  if (override !== null) return override;
  const year = Number(monthKey(month).slice(0, 4));
  const windows = seasons.length > 0 ? seasons : defaultSeasonWindows(year);
  return windows.some((window) => overlaps(month, window.start, window.end));
}

export function teamMonthly(row: {
  payKind: "hourly_weekly" | "fixed_biweekly";
  hoursPerWeek: number | null;
  rate: number;
  addsHst: boolean;
}): { weekly: number; pretax: number; hst: number; total: number } {
  const weekly =
    row.payKind === "hourly_weekly"
      ? (row.hoursPerWeek ?? 0) * row.rate
      : row.rate / 2;
  const pretax = cents(weekly * WEEKS_PER_MONTH);
  const hst = row.addsHst ? cents(pretax * ONTARIO_HST_RATE) : 0;
  return { weekly: cents(weekly), pretax, hst, total: cents(pretax + hst) };
}

export function otherMonthly(
  row: {
    amount: number;
    period: "month" | "year";
    runs: "every_month" | "production_only";
  },
  production: boolean,
): number {
  if (row.runs === "production_only" && !production) return 0;
  return cents(row.period === "year" ? row.amount / 12 : row.amount);
}

export function monthsThrough(start: string, end: string): string[] {
  if (monthKey(end) < monthKey(start)) return [];
  const months: string[] = [];
  let cursor = `${monthKey(start)}-01`;
  const last = `${monthKey(end)}-01`;
  while (cursor <= last) {
    months.push(cursor);
    const [yearText, monthText] = monthKey(cursor).split("-");
    const next = new Date(Date.UTC(Number(yearText), Number(monthText), 1));
    const y = next.getUTCFullYear();
    const m = String(next.getUTCMonth() + 1).padStart(2, "0");
    cursor = `${y}-${m}-01`;
  }
  return months;
}

export function splitEvenly(total: number, parts: number): number[] {
  if (parts <= 0) return [];
  const totalCents = Math.round(total * 100);
  const base = Math.trunc(totalCents / parts);
  const amounts = Array.from({ length: parts }, () => base / 100);
  const drift = totalCents - base * parts;
  amounts[parts - 1] = cents((amounts[parts - 1] ?? 0) + drift / 100);
  return amounts;
}

export function contractSpread(input: {
  remaining: number;
  start: string;
  end: string;
  today: string;
}): { month: string; amount: number }[] {
  const from = input.start > input.today ? input.start : input.today;
  const months = monthsThrough(from, input.end);
  const amounts = splitEvenly(input.remaining, months.length);
  return months.map((month, index) => ({
    month,
    amount: amounts[index] ?? 0,
  }));
}

export type ProjectionTeam = {
  name: string;
  role: string;
  payKind: "hourly_weekly" | "fixed_biweekly";
  hoursPerWeek: number | null;
  rate: number;
  addsHst: boolean;
  runs: "every_month" | "production_only";
  sourceNote: string;
};

export type ProjectionOther = {
  label: string;
  amount: number;
  period: "month" | "year";
  runs: "every_month" | "production_only";
  sourceNote: string;
};

export type ProjectionContract = {
  label: string;
  remaining: number;
  start: string;
  end: string;
  sourceNote: string;
};

export function projectWorkbook(input: {
  today: string;
  months: readonly { month: string; production: boolean }[];
  team: readonly ProjectionTeam[];
  others: readonly ProjectionOther[];
  contracts: readonly ProjectionContract[];
}) {
  const teamRates = input.team.map((person) => ({
    ...person,
    monthly: teamMonthly(person),
  }));
  const contractMonths = input.contracts.map((contract) => ({
    ...contract,
    byMonth: new Map(
      contractSpread({
        remaining: contract.remaining,
        start: contract.start,
        end: contract.end,
        today: input.today,
      }).map((part) => [monthKey(part.month), part.amount]),
    ),
  }));
  const months = input.months.map((column) => {
    const key = monthKey(column.month);
    const team = cents(
      teamRates.reduce((sum, person) => {
        if (person.runs === "production_only" && !column.production) return sum;
        return sum + person.monthly.total;
      }, 0),
    );
    const other = cents(
      input.others.reduce(
        (sum, row) => sum + otherMonthly(row, column.production),
        0,
      ),
    );
    const contracts = cents(
      contractMonths.reduce(
        (sum, contract) => sum + (contract.byMonth.get(key) ?? 0),
        0,
      ),
    );
    return {
      month: column.month,
      production: column.production,
      team,
      other,
      contracts,
      total: cents(team + other + contracts),
    };
  });
  const yearTotal = cents(months.reduce((sum, month) => sum + month.total, 0));
  const productionMonths = months.filter((month) => month.production);
  const productionTotal = cents(
    productionMonths.reduce((sum, month) => sum + month.total, 0),
  );
  return {
    teamRates,
    contractMonths,
    months,
    yearTotal,
    averageMonth: cents(yearTotal / (months.length || 1)),
    averageProductionMonth:
      productionMonths.length === 0
        ? 0
        : cents(productionTotal / productionMonths.length),
  };
}

export function invoiceSummary(
  rows: readonly {
    hours: number | null;
    expected: number | null;
    paid: number | null;
    hst: number;
  }[],
) {
  const count = rows.length;
  const expected = cents(
    rows.reduce((sum, row) => sum + (row.expected ?? 0), 0),
  );
  const paid = cents(rows.reduce((sum, row) => sum + (row.paid ?? 0), 0));
  const hours = cents(rows.reduce((sum, row) => sum + (row.hours ?? 0), 0));
  const underpaid = rows.filter(
    (row) =>
      row.expected !== null && row.paid !== null && row.paid < row.expected,
  ).length;
  const average = (value: number) => (count === 0 ? 0 : cents(value / count));
  return {
    count,
    expected,
    paid,
    difference: cents(paid - expected),
    hours,
    hst: cents(rows.reduce((sum, row) => sum + row.hst, 0)),
    underpaid,
    averageExpected: average(expected),
    averagePaid: average(paid),
    averageHours: average(hours),
  };
}

export function contractStanding(input: {
  phases: readonly { beforeHst: number; hst: number }[];
  fallbackBeforeHst: number;
  fallbackHst: number;
  payments: readonly { amount: number; hst: number; paidOn: string | null }[];
  end: string;
  today: string;
}) {
  const phaseIncl =
    input.phases.length === 0
      ? cents(input.fallbackBeforeHst + input.fallbackHst)
      : cents(
          input.phases.reduce(
            (sum, phase) => sum + phase.beforeHst + phase.hst,
            0,
          ),
        );
  const paid = cents(
    input.payments.reduce((sum, payment) => {
      const counts = payment.paidOn === null || payment.paidOn <= input.today;
      return counts ? sum + payment.amount + payment.hst : sum;
    }, 0),
  );
  const remaining = cents(phaseIncl - paid);
  const monthsLeft = monthsThrough(input.today, input.end).length;
  return {
    inclHst: phaseIncl,
    paid,
    remaining,
    paymentsLeft: remaining === 0 ? 0 : monthsLeft,
    monthsLeft,
    averagePerMonth:
      monthsLeft === 0 ? remaining : cents(remaining / monthsLeft),
  };
}

export function equipmentSavings(
  newPrice: number | null,
  preownedPrice: number | null,
): number | null {
  if (newPrice === null || preownedPrice === null) return null;
  return cents(newPrice - preownedPrice);
}

export function addMonths(date: string, months: number): string {
  const [yearText, monthText, dayText] = date.split("-");
  const year = Number(yearText);
  const month = Number(monthText);
  const day = Number(dayText);
  const cursor = new Date(Date.UTC(year, month - 1 + months, 1));
  const last = new Date(
    Date.UTC(cursor.getUTCFullYear(), cursor.getUTCMonth() + 1, 0),
  ).getUTCDate();
  const y = cursor.getUTCFullYear();
  const m = String(cursor.getUTCMonth() + 1).padStart(2, "0");
  const d = String(Math.min(day, last)).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

export function leaseStanding(input: {
  termMonths: number;
  monthly: number;
  hst: number;
  upfront: number;
  paymentsMade: number;
  startedOn: string | null;
}) {
  const remainingPayments = Math.max(0, input.termMonths - input.paymentsMade);
  return {
    paidToDate: cents(
      input.upfront + input.paymentsMade * (input.monthly + input.hst),
    ),
    remainingPayments,
    finalMonth: input.startedOn
      ? monthKey(addMonths(input.startedOn, input.termMonths - 1))
      : null,
  };
}

export function outsideCostumeSummary(
  rows: readonly {
    program: string;
    vendorType: string;
    vendor: string;
    amount: number | null;
    currency: "CAD" | "USD";
    refund: boolean;
    duplicate: boolean;
    canceled: boolean;
    owing: boolean;
    archived: boolean;
  }[],
) {
  const signed = (row: (typeof rows)[number]) => {
    if (row.amount === null) return 0;
    return row.refund && row.amount > 0 ? -row.amount : row.amount;
  };
  const active = rows.filter(
    (row) =>
      !row.archived && !row.duplicate && !row.canceled && row.amount !== null,
  );
  const group = (key: "program" | "vendorType" | "vendor") => {
    const totals = new Map<string, { cad: number; usd: number }>();
    for (const row of active) {
      const name = row[key].trim() || "Not recorded";
      const current = totals.get(name) ?? { cad: 0, usd: 0 };
      if (row.currency === "USD") current.usd += signed(row);
      else current.cad += signed(row);
      totals.set(name, current);
    }
    return [...totals.entries()]
      .map(([name, totalsForName]) => ({
        name,
        cad: cents(totalsForName.cad),
        usd: cents(totalsForName.usd),
      }))
      .sort((left, right) => right.cad + right.usd - (left.cad + left.usd));
  };
  const owing = cents(
    rows
      .filter(
        (row) => row.owing && !row.archived && !row.duplicate && !row.canceled,
      )
      .reduce((sum, row) => sum + signed(row), 0),
  );
  return {
    byProgram: group("program"),
    byVendorType: group("vendorType"),
    byVendor: group("vendor"),
    owing,
  };
}

export function localFinanceHref(
  href: string | null | undefined,
): string | null {
  if (!href || !href.startsWith("/finances")) return null;
  return href;
}
