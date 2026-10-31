export const CARD_CSV_HEADER = [
  "date",
  "merchant",
  "amount_cad",
  "category",
  "note",
] as const;

export type CardCsvRow = {
  date: string;
  merchant: string;
  amountCad: number;
  category: string;
  note: string;
};

export type Frequency =
  "monthly" | "quarterly" | "yearly" | "bi-weekly" | "per_pay_period";

const MONTHLY_FACTOR: Record<Frequency, number> = {
  monthly: 1,
  quarterly: 1 / 3,
  yearly: 1 / 12,
  "bi-weekly": 26 / 12,
  per_pay_period: 26 / 12,
};

export function cents(value: number): number {
  return Math.round(value * 100) / 100;
}

export function monthlyAmount(amount: number, frequency: Frequency): number {
  return cents(amount * MONTHLY_FACTOR[frequency]);
}

export function isActiveOn(
  start: string,
  end: string | null,
  today: string,
): boolean {
  if (start > today) return false;
  if (end && end < today) return false;
  return true;
}

function shiftDays(isoDate: string, days: number): string {
  const [year, month, day] = isoDate.split("-").map(Number);
  const date = new Date(Date.UTC(year ?? 0, (month ?? 1) - 1, day ?? 1));
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString().slice(0, 10);
}

export function inLastDays(
  isoDate: string,
  today: string,
  days: number,
): boolean {
  return isoDate <= today && isoDate >= shiftDays(today, -days);
}

export type RecurringInput = {
  amount: number;
  hst: number;
  frequency: Frequency;
  start: string;
  end: string | null;
  excluded: boolean;
};

export function recurringMonthly(
  rows: readonly RecurringInput[],
  today: string,
): { pretax: number; hst: number } {
  let pretax = 0;
  let hst = 0;
  for (const row of rows) {
    if (row.excluded || !isActiveOn(row.start, row.end, today)) continue;
    pretax += monthlyAmount(row.amount, row.frequency);
    hst += monthlyAmount(row.hst, row.frequency);
  }
  return { pretax: cents(pretax), hst: cents(hst) };
}

export type CardSpend = {
  date: string;
  amount: number;
  hst: number;
  excluded: boolean;
  startup: boolean;
  categoryExcluded: boolean;
};

export function variableMonthly(
  rows: readonly CardSpend[],
  today: string,
): { pretax: number; hst: number } {
  let pretax = 0;
  let hst = 0;
  for (const row of rows) {
    if (row.excluded || row.startup || row.categoryExcluded) continue;
    if (!inLastDays(row.date, today, 90)) continue;
    pretax += row.amount;
    hst += row.hst;
  }
  return { pretax: cents(pretax / 3), hst: cents(hst / 3) };
}

export function annualized(monthly: number): number {
  return cents(monthly * 12);
}

export type RunMode = "year_round" | "production_only";

export type SeasonSpan = { start: string; end: string };

function isoParts(isoDate: string): {
  year: number;
  month: number;
  day: number;
} {
  const [year, month, day] = isoDate.split("-").map(Number);
  return { year: year ?? 0, month: month ?? 1, day: day ?? 1 };
}

function dayIndex(isoDate: string): number {
  const { year, month, day } = isoParts(isoDate);
  return Math.floor(Date.UTC(year, month - 1, day) / 86_400_000);
}

export function daysInMonth(year: number, month: number): number {
  return new Date(Date.UTC(year, month, 0)).getUTCDate();
}

export function productionDaysInMonth(
  year: number,
  month: number,
  seasons: readonly SeasonSpan[],
): number {
  const days = daysInMonth(year, month);
  const monthStart = dayIndex(`${year}-${String(month).padStart(2, "0")}-01`);
  const covered = new Set<number>();
  for (const season of seasons) {
    const from = Math.max(monthStart, dayIndex(season.start));
    const to = Math.min(monthStart + days - 1, dayIndex(season.end));
    for (let day = from; day <= to; day += 1) covered.add(day);
  }
  return covered.size;
}

export function upcomingMonths(
  today: string,
  count = 12,
): { year: number; month: number; label: string }[] {
  const { year, month } = isoParts(today);
  return Array.from({ length: count }, (_, index) => {
    const date = new Date(Date.UTC(year, month - 1 + index, 1));
    const nextYear = date.getUTCFullYear();
    const nextMonth = date.getUTCMonth() + 1;
    return {
      year: nextYear,
      month: nextMonth,
      label: `${nextYear}-${String(nextMonth).padStart(2, "0")}`,
    };
  });
}

export type ProjectionCost = {
  monthlyPretax: number;
  monthlyHst: number;
  runs: RunMode;
  category: string;
};

export function projectRunningYear(input: {
  today: string;
  recurring: readonly ProjectionCost[];
  payrollMonthly: number;
  payrollRuns: RunMode;
  variableMonthly: number;
  variableHstMonthly: number;
  variableRuns: RunMode;
  seasons: readonly SeasonSpan[];
}): {
  costPerProductionMonth: number;
  costPerProductionMonthHst: number;
  months: {
    month: string;
    pretax: number;
    hst: number;
    productionDays: number;
    days: number;
  }[];
  yearPretax: number;
  seasonPretax: number;
  offSeasonPretax: number;
} {
  let yearRound = 0;
  let yearRoundHst = 0;
  let production = 0;
  let productionHst = 0;
  for (const cost of input.recurring) {
    const runs = cost.category === "WSIB" ? input.payrollRuns : cost.runs;
    if (runs === "production_only") {
      production += cost.monthlyPretax;
      productionHst += cost.monthlyHst;
    } else {
      yearRound += cost.monthlyPretax;
      yearRoundHst += cost.monthlyHst;
    }
  }
  if (input.payrollRuns === "production_only")
    production += input.payrollMonthly;
  else yearRound += input.payrollMonthly;
  if (input.variableRuns === "production_only") {
    production += input.variableMonthly;
    productionHst += input.variableHstMonthly;
  } else {
    yearRound += input.variableMonthly;
    yearRoundHst += input.variableHstMonthly;
  }
  yearRound = cents(yearRound);
  yearRoundHst = cents(yearRoundHst);
  production = cents(production);
  productionHst = cents(productionHst);

  let seasonPretax = 0;
  let offSeasonPretax = 0;
  const months = upcomingMonths(input.today).map(({ year, month, label }) => {
    const days = daysInMonth(year, month);
    const productionDays = productionDaysInMonth(year, month, input.seasons);
    const fraction = days === 0 ? 0 : productionDays / days;
    const pretax = cents(yearRound + production * fraction);
    const hst = cents(yearRoundHst + productionHst * fraction);
    seasonPretax += (yearRound + production) * fraction;
    offSeasonPretax += yearRound * (1 - fraction);
    return { month: label, pretax, hst, productionDays, days };
  });
  const season = cents(seasonPretax);
  const offSeason = cents(offSeasonPretax);
  return {
    costPerProductionMonth: cents(yearRound + production),
    costPerProductionMonthHst: cents(yearRoundHst + productionHst),
    months,
    yearPretax: cents(season + offSeason),
    seasonPretax: season,
    offSeasonPretax: offSeason,
  };
}

export function averageMonthlyPayroll(
  rows: readonly {
    start: string;
    end: string;
    gross: number;
    cpp: number;
    ei: number;
  }[],
): number {
  if (rows.length === 0) return 0;
  let total = 0;
  const months = new Set<string>();
  for (const row of rows) {
    total += row.gross + row.cpp + row.ei;
    months.add(row.start.slice(0, 7));
    months.add(row.end.slice(0, 7));
  }
  return cents(total / months.size);
}

export type StartupSource = "manual" | "card";

export type StartupLine = {
  category: string;
  pretax: number;
  hst: number;
  source: StartupSource;
  excluded: boolean;
};

export function startupSummary(lines: readonly StartupLine[]): {
  pretax: number;
  hst: number;
  manual: number;
  card: number;
  byCategory: {
    category: string;
    pretax: number;
    hst: number;
    manual: number;
    card: number;
  }[];
} {
  const categories = new Map<
    string,
    { pretax: number; hst: number; manual: number; card: number }
  >();
  let pretax = 0;
  let hst = 0;
  let manual = 0;
  let card = 0;
  for (const line of lines) {
    if (line.excluded) continue;
    pretax += line.pretax;
    hst += line.hst;
    if (line.source === "card") card += line.pretax;
    else manual += line.pretax;
    const current = categories.get(line.category) ?? {
      pretax: 0,
      hst: 0,
      manual: 0,
      card: 0,
    };
    current.pretax += line.pretax;
    current.hst += line.hst;
    if (line.source === "card") current.card += line.pretax;
    else current.manual += line.pretax;
    categories.set(line.category, current);
  }
  return {
    pretax: cents(pretax),
    hst: cents(hst),
    manual: cents(manual),
    card: cents(card),
    byCategory: [...categories.entries()]
      .map(([category, value]) => ({
        category,
        pretax: cents(value.pretax),
        hst: cents(value.hst),
        manual: cents(value.manual),
        card: cents(value.card),
      }))
      .sort((left, right) => right.pretax - left.pretax),
  };
}

export type SpendSlice = {
  month: string;
  category: string;
  pretax: number;
  hst: number;
  excluded: boolean;
  startup?: boolean;
};

export function monthlyCategorySpend(rows: readonly SpendSlice[]): {
  month: string;
  pretax: number;
  hst: number;
  byCategory: { category: string; pretax: number; startupPretax: number }[];
}[] {
  const months = new Map<
    string,
    {
      pretax: number;
      hst: number;
      categories: Map<string, { pretax: number; startupPretax: number }>;
    }
  >();
  for (const row of rows) {
    if (row.excluded) continue;
    const month = months.get(row.month) ?? {
      pretax: 0,
      hst: 0,
      categories: new Map<string, { pretax: number; startupPretax: number }>(),
    };
    month.pretax += row.pretax;
    month.hst += row.hst;
    const category = month.categories.get(row.category) ?? {
      pretax: 0,
      startupPretax: 0,
    };
    category.pretax += row.pretax;
    if (row.startup) category.startupPretax += row.pretax;
    month.categories.set(row.category, category);
    months.set(row.month, month);
  }
  return [...months.entries()]
    .sort(([left], [right]) => (left < right ? -1 : 1))
    .map(([month, value]) => ({
      month,
      pretax: cents(value.pretax),
      hst: cents(value.hst),
      byCategory: [...value.categories.entries()]
        .map(([category, amounts]) => ({
          category,
          pretax: cents(amounts.pretax),
          startupPretax: cents(amounts.startupPretax),
        }))
        .sort((left, right) => right.pretax - left.pretax),
    }));
}

export function workedHours(
  startIso: string | null,
  endIso: string | null,
  breakMinutes: number,
  notWorked: boolean,
): number {
  if (notWorked || !startIso || !endIso) return 0;
  const span = Date.parse(endIso) - Date.parse(startIso);
  if (!Number.isFinite(span) || span <= 0) return 0;
  return Math.max(0, span / 3_600_000 - breakMinutes / 60);
}

export function rateOn(
  rates: readonly {
    from: string;
    to: string | null;
    rate: number;
    currency: string;
  }[],
  day: string,
): number | null {
  const matches = rates
    .filter(
      (rate) =>
        rate.currency === "CAD" &&
        rate.from <= day &&
        (rate.to === null || rate.to >= day),
    )
    .sort((left, right) => (left.from < right.from ? 1 : -1));
  return matches[0]?.rate ?? null;
}

export function employeeGross(
  lines: readonly { hours: number; rate: number | null; contractor: boolean }[],
): number {
  let total = 0;
  for (const line of lines) {
    if (line.contractor || line.rate === null) continue;
    total += line.hours * line.rate;
  }
  return cents(total);
}

export function parseCardCsv(
  text: string,
): { ok: true; rows: CardCsvRow[] } | { ok: false; notice: string } {
  const lines = text
    .replace(/^\uFEFF/, "")
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0);
  const header = lines[0]?.split(",").map((cell) => cell.trim().toLowerCase());
  if (!header || header.join(",") !== CARD_CSV_HEADER.join(",")) {
    return {
      ok: false,
      notice: "The header must be date, merchant, amount_cad, category, note.",
    };
  }
  const rows: CardCsvRow[] = [];
  for (const line of lines.slice(1)) {
    const cells = line.split(",").map((cell) => cell.trim());
    const [date, merchant, amount, category, note] = cells;
    if (!date || !merchant || !amount || !category) {
      return {
        ok: false,
        notice: "Each row needs a date, merchant, amount, and category.",
      };
    }
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      return { ok: false, notice: "Dates must be YYYY-MM-DD." };
    }
    const amountCad = Number(amount);
    if (!Number.isFinite(amountCad)) {
      return { ok: false, notice: "Amount must be a number." };
    }
    rows.push({
      date,
      merchant,
      amountCad,
      category,
      note: note ?? "",
    });
  }
  if (rows.length === 0) return { ok: false, notice: "The file has no lines." };
  return { ok: true, rows };
}

export function currentBiweeklyPeriod(
  today: string,
  anchor = "2026-01-05",
): { start: string; end: string } {
  const startMs = Date.parse(`${anchor}T00:00:00Z`);
  const todayMs = Date.parse(`${today}T00:00:00Z`);
  const days = Math.floor((todayMs - startMs) / 86_400_000);
  const offset = Math.floor(days / 14) * 14;
  const start = shiftDays(anchor, offset);
  return { start, end: shiftDays(start, 13) };
}
