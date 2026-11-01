import {
  PRODUCTION_STATUSES,
  productionStatusIndex,
} from "../orders/production-status.ts";

export type Milestone = { status: string; targetOn: string };

export type TimingFlag = "late" | "at_risk";

function addDays(isoDate: string, days: number): string {
  const [year, month, day] = isoDate.split("-").map(Number);
  const date = new Date(Date.UTC(year ?? 0, (month ?? 1) - 1, day ?? 1));
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString().slice(0, 10);
}

export function orderTimingFlag(
  today: string,
  currentStatus: string,
  milestones: readonly Milestone[],
): TimingFlag | null {
  const current = productionStatusIndex(currentStatus);
  const horizon = addDays(today, 3);
  let atRisk = false;
  for (const milestone of milestones) {
    if (
      !PRODUCTION_STATUSES.some((status) => status.value === milestone.status)
    ) {
      continue;
    }
    const step = productionStatusIndex(milestone.status);
    if (step < current) continue;
    if (milestone.targetOn < today) return "late";
    if (milestone.targetOn <= horizon) atRisk = true;
  }
  return atRisk ? "at_risk" : null;
}

export function monthDays(year: number, month: number): string[] {
  const days: string[] = [];
  const cursor = new Date(Date.UTC(year, month - 1, 1));
  while (cursor.getUTCMonth() === month - 1) {
    days.push(cursor.toISOString().slice(0, 10));
    cursor.setUTCDate(cursor.getUTCDate() + 1);
  }
  return days;
}
