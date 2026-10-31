export const SHOP_TIME_ZONE = "America/Toronto";
export const PAY_PERIOD_DAYS = 14;

export type ClockShift = {
  date: string;
  start: string;
  end: string;
  breakMinutes: number;
};

export type PayPeriod = {
  start: string;
  end: string;
};

function parts(instant: Date, timeZone: string) {
  const formatted = new Intl.DateTimeFormat("en-US", {
    timeZone,
    hourCycle: "h23",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  }).formatToParts(instant);
  const value: Record<string, string> = {};
  for (const part of formatted) {
    if (part.type !== "literal") value[part.type] = part.value;
  }
  let hour = Number(value.hour);
  const day = Number(value.day);
  if (hour === 24) hour = 0;
  return {
    year: Number(value.year),
    month: Number(value.month),
    day,
    hour,
    minute: Number(value.minute),
    second: Number(value.second),
  };
}

function offsetMinutes(instant: Date, timeZone: string): number {
  const wall = parts(instant, timeZone);
  const asUtc = Date.UTC(
    wall.year,
    wall.month - 1,
    wall.day,
    wall.hour,
    wall.minute,
    wall.second,
  );
  return Math.round((asUtc - instant.getTime()) / 60000);
}

export function localToUtc(
  date: string,
  time: string,
  timeZone = SHOP_TIME_ZONE,
): Date {
  const [year, month, day] = date.split("-").map(Number);
  const [hour, minute] = time.split(":").map(Number);
  if (
    year === undefined ||
    month === undefined ||
    day === undefined ||
    hour === undefined ||
    minute === undefined
  ) {
    throw new Error("Enter a date and a time.");
  }
  let utc = Date.UTC(year, month - 1, day, hour, minute);
  for (let attempt = 0; attempt < 4; attempt += 1) {
    const adjusted = utc - offsetMinutes(new Date(utc), timeZone) * 60_000;
    if (adjusted === utc) break;
    utc = adjusted;
  }
  return new Date(utc);
}

export function addDays(date: string, days: number): string {
  const [year, month, day] = date.split("-").map(Number);
  const utc = new Date(Date.UTC(year!, month! - 1, day! + days));
  return utc.toISOString().slice(0, 10);
}

export function mondayOf(date: string): string {
  const [year, month, day] = date.split("-").map(Number);
  const utc = new Date(Date.UTC(year!, month! - 1, day!));
  const weekday = utc.getUTCDay();
  const fromMonday = weekday === 0 ? 6 : weekday - 1;
  return addDays(date, -fromMonday);
}

function endDate(shift: ClockShift): string {
  return shift.end <= shift.start ? addDays(shift.date, 1) : shift.date;
}

export function elapsedMinutes(
  shift: ClockShift,
  timeZone = SHOP_TIME_ZONE,
): number | null {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(shift.date)) return null;
  if (!/^\d{2}:\d{2}$/.test(shift.start) || !/^\d{2}:\d{2}$/.test(shift.end)) {
    return null;
  }
  if (!Number.isInteger(shift.breakMinutes) || shift.breakMinutes < 0) {
    return null;
  }
  if (shift.end === shift.start) return null;
  const start = localToUtc(shift.date, shift.start, timeZone);
  const end = localToUtc(endDate(shift), shift.end, timeZone);
  const span = Math.round((end.getTime() - start.getTime()) / 60000);
  const worked = span - shift.breakMinutes;
  if (worked <= 0) return null;
  return worked;
}

export function roundMinutes(minutes: number, increment: number): number {
  if (!Number.isInteger(increment) || increment <= 0) return minutes;
  return Math.round(minutes / increment) * increment;
}

export function payableMinutes(
  shift: ClockShift,
  roundingMinutes = 0,
  timeZone = SHOP_TIME_ZONE,
): number | null {
  const worked = elapsedMinutes(shift, timeZone);
  if (worked === null) return null;
  const rounded = roundMinutes(worked, roundingMinutes);
  return rounded > 0 ? rounded : null;
}

export function minutesBetween(
  startIso: string,
  endIso: string,
  breakMinutes: number,
  roundingMinutes = 0,
): number | null {
  const span =
    Math.round(
      (new Date(endIso).getTime() - new Date(startIso).getTime()) / 60000,
    ) - breakMinutes;
  if (span <= 0) return null;
  const rounded = roundMinutes(span, roundingMinutes);
  return rounded > 0 ? rounded : null;
}

export function torontoParts(iso: string): { date: string; time: string } {
  const wall = parts(new Date(iso), SHOP_TIME_ZONE);
  const date = `${wall.year}-${String(wall.month).padStart(2, "0")}-${String(wall.day).padStart(2, "0")}`;
  const time = `${String(wall.hour).padStart(2, "0")}:${String(wall.minute).padStart(2, "0")}`;
  return { date, time };
}

export function hoursFromMinutes(minutes: number): number {
  return Math.round((minutes / 60) * 100) / 100;
}

export function formatHours(minutes: number): string {
  const hours = hoursFromMinutes(minutes);
  return `${hours} h`;
}

export function payPeriodContaining(
  anchor: string | null,
  day: string,
): PayPeriod | null {
  if (!anchor) return null;
  if (!/^\d{4}-\d{2}-\d{2}$/.test(anchor) || !/^\d{4}-\d{2}-\d{2}$/.test(day)) {
    return null;
  }
  if (day < anchor) return null;
  const [ay, am, ad] = anchor.split("-").map(Number);
  const [dy, dm, dd] = day.split("-").map(Number);
  const anchorUtc = Date.UTC(ay!, am! - 1, ad!);
  const dayUtc = Date.UTC(dy!, dm! - 1, dd!);
  const days = Math.floor((dayUtc - anchorUtc) / 86_400_000);
  const index = Math.floor(days / PAY_PERIOD_DAYS);
  const start = addDays(anchor, index * PAY_PERIOD_DAYS);
  return { start, end: addDays(start, PAY_PERIOD_DAYS - 1) };
}

export function datesInRange(start: string, end: string): string[] {
  const dates: string[] = [];
  let cursor = start;
  while (cursor <= end) {
    dates.push(cursor);
    cursor = addDays(cursor, 1);
  }
  return dates;
}
