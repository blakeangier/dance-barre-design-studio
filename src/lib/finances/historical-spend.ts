import { cents } from "./money.ts";

export const HISTORICAL_PROGRAMS = [
  "Elite Company",
  "Recreational",
  "CREW",
  "ABC",
  "Kickstart",
] as const;

export const PAST_SPEND_PROGRAM_FILTERS = [
  "Elite Company",
  "Recreational",
  "CREW",
  "Other",
  "ABC",
  "Kickstart",
] as const;

export type PastSpendProgramFilter =
  (typeof PAST_SPEND_PROGRAM_FILTERS)[number];

// Studio fiscal year is 1 Jun–31 May. This row is Design Studio
// outside-costume spend, not a line from the historical studio ledger.
export const CURRENT_OUTSIDE_SEASON = "2026-27";
export const CURRENT_OUTSIDE_START = "2026-06-01";
export const CURRENT_OUTSIDE_END = "2027-05-31";

export type HistoricalSpendLine = {
  id: number;
  season: string;
  program: string;
  txnDate: string;
  payee: string;
  sourceRef: string | null;
  jeNumber: string;
  debit: number;
  credit: number;
  net: number;
};

export type SeasonSpend = {
  season: string;
  elite: number;
  recreational: number;
  crew: number;
  other: number;
  total: number;
};

function columnFor(
  program: string,
): keyof Omit<SeasonSpend, "season" | "total"> {
  if (program === "Elite Company") return "elite";
  if (program === "Recreational") return "recreational";
  if (program === "CREW") return "crew";
  return "other";
}

export function summarizeBySeason(
  rows: readonly Pick<HistoricalSpendLine, "season" | "program" | "net">[],
): SeasonSpend[] {
  const seasons = new Map<string, SeasonSpend>();
  for (const row of rows) {
    const current = seasons.get(row.season) ?? {
      season: row.season,
      elite: 0,
      recreational: 0,
      crew: 0,
      other: 0,
      total: 0,
    };
    current[columnFor(row.program)] += row.net;
    current.total += row.net;
    seasons.set(row.season, current);
  }
  return [...seasons.values()]
    .map((row) => ({
      season: row.season,
      elite: cents(row.elite),
      recreational: cents(row.recreational),
      crew: cents(row.crew),
      other: cents(row.other),
      total: cents(row.total),
    }))
    .sort((left, right) => (left.season < right.season ? -1 : 1));
}

export function isCreditLine(row: { credit: number; net: number }): boolean {
  return row.credit > 0 || row.net < 0;
}

export function isPastSpendProgramFilter(
  value: string,
): value is PastSpendProgramFilter {
  return (PAST_SPEND_PROGRAM_FILTERS as readonly string[]).includes(value);
}

export function cleanSeasonFilter(value: string): string {
  return /^[0-9]{4}-[0-9]{2}$/.test(value) ? value : "";
}

export function cleanProgramFilter(value: string): string {
  return isPastSpendProgramFilter(value) ? value : "";
}

export function programMatches(program: string, filter: string): boolean {
  if (!filter) return true;
  if (filter === "Other") return program === "ABC" || program === "Kickstart";
  return program === filter;
}

export function filterHistoricalLines<
  T extends { season: string; program: string },
>(rows: readonly T[], filter: { season: string; program: string }): T[] {
  return rows.filter((row) => {
    if (filter.season && row.season !== filter.season) return false;
    return programMatches(row.program, filter.program);
  });
}

export function topPayees(
  rows: readonly { season: string; payee: string; net: number }[],
  season: string,
  limit = 8,
): { payee: string; net: number; lines: number }[] {
  const totals = new Map<string, { net: number; lines: number }>();
  for (const row of rows) {
    if (row.season !== season) continue;
    const current = totals.get(row.payee) ?? { net: 0, lines: 0 };
    current.net += row.net;
    current.lines += 1;
    totals.set(row.payee, current);
  }
  return [...totals.entries()]
    .map(([payee, value]) => ({
      payee,
      net: cents(value.net),
      lines: value.lines,
    }))
    .sort(
      (left, right) =>
        right.net - left.net || left.payee.localeCompare(right.payee),
    )
    .slice(0, limit);
}

export type CurrentOutsideLine = {
  program: string;
  amount: number | null;
  currency: "CAD" | "USD";
  purchasedOn: string | null;
  refund: boolean;
  archived: boolean;
  duplicate: boolean;
  canceled: boolean;
};

export type CurrentOutsideComparison = {
  season: typeof CURRENT_OUTSIDE_SEASON;
  start: typeof CURRENT_OUTSIDE_START;
  end: typeof CURRENT_OUTSIDE_END;
  eliteCad: number;
  crewCad: number;
  totalCad: number;
  eliteUsd: number;
  crewUsd: number;
  totalUsd: number;
  skippedUndated: number;
  skippedOutsideWindow: number;
};

function inCurrentSeason(date: string): boolean {
  return date >= CURRENT_OUTSIDE_START && date <= CURRENT_OUTSIDE_END;
}

function signedAmount(row: CurrentOutsideLine): number | null {
  if (row.amount === null || !Number.isFinite(row.amount)) return null;
  return row.refund && row.amount > 0 ? -row.amount : row.amount;
}

export function currentOutsideComparison(
  rows: readonly CurrentOutsideLine[],
): CurrentOutsideComparison {
  let eliteCad = 0;
  let crewCad = 0;
  let eliteUsd = 0;
  let crewUsd = 0;
  let skippedUndated = 0;
  let skippedOutsideWindow = 0;
  for (const row of rows) {
    if (row.program !== "Elite Company" && row.program !== "CREW") continue;
    if (row.archived || row.duplicate || row.canceled) continue;
    const amount = signedAmount(row);
    if (amount === null) continue;
    if (!row.purchasedOn) {
      skippedUndated += 1;
      continue;
    }
    if (!inCurrentSeason(row.purchasedOn)) {
      skippedOutsideWindow += 1;
      continue;
    }
    if (row.currency === "USD") {
      if (row.program === "Elite Company") eliteUsd += amount;
      else crewUsd += amount;
    } else if (row.program === "Elite Company") eliteCad += amount;
    else crewCad += amount;
  }
  return {
    season: CURRENT_OUTSIDE_SEASON,
    start: CURRENT_OUTSIDE_START,
    end: CURRENT_OUTSIDE_END,
    eliteCad: cents(eliteCad),
    crewCad: cents(crewCad),
    totalCad: cents(eliteCad + crewCad),
    eliteUsd: cents(eliteUsd),
    crewUsd: cents(crewUsd),
    totalUsd: cents(eliteUsd + crewUsd),
    skippedUndated,
    skippedOutsideWindow,
  };
}

export function pastSpendHref(season = "", program = ""): string {
  const params = new URLSearchParams();
  if (season) params.set("season", season);
  if (program) params.set("program", program);
  const query = params.toString();
  return query ? `/finances/past-spend?${query}` : "/finances/past-spend";
}
