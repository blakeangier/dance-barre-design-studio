import { addDays, mondayOf } from "./hours.ts";

export function weekStarting(day: string | undefined, today: string): string {
  const chosen = day && /^\d{4}-\d{2}-\d{2}$/.test(day) ? day : today;
  return mondayOf(chosen);
}

export function weekDays(start: string): string[] {
  return Array.from({ length: 7 }, (_, index) => addDays(start, index));
}

export const WEEKDAY_LABELS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

export function clockMinutes(value: string): number | null {
  const match = /^(\d{2}):(\d{2})/.exec(value);
  if (!match) return null;
  const hour = Number(match[1]);
  const minute = Number(match[2]);
  if (hour > 23 || minute > 59) return null;
  return hour * 60 + minute;
}

// Same-day shifts only. Breaks are unpaid. A shift that does not fit returns null.
export function staffShiftMinutes(
  start: string,
  end: string,
  breakMinutes: number,
): number | null {
  const startMinutes = clockMinutes(start);
  const endMinutes = clockMinutes(end);
  if (startMinutes === null || endMinutes === null) return null;
  if (endMinutes <= startMinutes) return null;
  if (!Number.isInteger(breakMinutes) || breakMinutes < 0) return null;
  const worked = endMinutes - startMinutes - breakMinutes;
  return worked > 0 ? worked : null;
}

export function shiftsOverlap(
  left: { start: string; end: string },
  right: { start: string; end: string },
): boolean {
  return left.start < right.end && right.start < left.end;
}

export type CopyCandidate = {
  profileId: string;
  date: string;
  start: string;
  end: string;
};

export function copyShiftDates(
  previous: readonly CopyCandidate[],
  existing: readonly CopyCandidate[],
): CopyCandidate[] {
  const taken = new Set(
    existing.map((shift) =>
      [
        shift.profileId,
        shift.date,
        shift.start.slice(0, 5),
        shift.end.slice(0, 5),
      ].join("|"),
    ),
  );
  const copies: CopyCandidate[] = [];
  for (const shift of previous) {
    const date = addDays(shift.date, 7);
    const key = [
      shift.profileId,
      date,
      shift.start.slice(0, 5),
      shift.end.slice(0, 5),
    ].join("|");
    if (taken.has(key)) continue;
    taken.add(key);
    copies.push({ ...shift, date });
  }
  return copies;
}
