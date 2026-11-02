import { addDays, mondayOf } from "./hours.ts";

export function weekStarting(day: string | undefined, today: string): string {
  const chosen = day && /^\d{4}-\d{2}-\d{2}$/.test(day) ? day : today;
  return mondayOf(chosen);
}

export function weekDays(start: string): string[] {
  return Array.from({ length: 7 }, (_, index) => addDays(start, index));
}

export const WEEKDAY_LABELS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

const MONTH_LABELS = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

const SUNDAY_FIRST = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

function utcWeekday(year: number, month: number, day: number): number {
  const offsets = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4];
  const adjustedYear = month < 3 ? year - 1 : year;
  return (
    (adjustedYear +
      Math.floor(adjustedYear / 4) -
      Math.floor(adjustedYear / 100) +
      Math.floor(adjustedYear / 400) +
      (offsets[month - 1] ?? 0) +
      day) %
    7
  );
}

export function shiftDayLabel(iso: string): string {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(iso)) return iso;
  const year = Number(iso.slice(0, 4));
  const month = Number(iso.slice(5, 7));
  const day = Number(iso.slice(8, 10));
  if (month < 1 || month > 12 || day < 1 || day > 31) return iso;
  const weekday = SUNDAY_FIRST[utcWeekday(year, month, day)] ?? "";
  return `${weekday}, ${MONTH_LABELS[month - 1]} ${day}`;
}

export function shiftFormTitle(
  mode: "add" | "edit",
  person: string,
  iso: string,
): string {
  const verb = mode === "add" ? "Adding" : "Editing";
  return `${verb} shift for ${person} · ${shiftDayLabel(iso)}`;
}

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
