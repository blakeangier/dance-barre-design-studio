import { addDays, SHOP_TIME_ZONE } from "../schedule/hours.ts";

export const DEFAULT_WINDOW_START = "08:00";
export const DEFAULT_WINDOW_END = "21:00";
export const DEFAULT_PUSH_TIME_ZONE = SHOP_TIME_ZONE;

export const PUSH_TIME_ZONES = [
  "America/St_Johns",
  "America/Halifax",
  "America/Toronto",
  "America/Winnipeg",
  "America/Edmonton",
  "America/Vancouver",
  "UTC",
] as const;

export type QuietWindow = {
  start: string;
  end: string;
  timeZone: string;
};

export type QuietPlan =
  { action: "send" } | { action: "queue"; deliverAt: Date };

export function isKnownTimeZone(value: string): boolean {
  try {
    Intl.DateTimeFormat("en-CA", { timeZone: value }).format(new Date());
    return true;
  } catch {
    return false;
  }
}

export function parseClock(value: string): number | null {
  const match = /^(\d{2}):(\d{2})/.exec(value.trim());
  if (!match) return null;
  const hour = Number(match[1]);
  const minute = Number(match[2]);
  if (hour > 23 || minute > 59) return null;
  return hour * 60 + minute;
}

export function clockText(value: string | null | undefined): string | null {
  const minutes = value ? parseClock(value) : null;
  if (minutes === null) return null;
  const hour = Math.floor(minutes / 60);
  const minute = minutes % 60;
  return `${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}`;
}

// A window that starts and ends at the same minute stays open all day.
// When the end is earlier than the start, the open hours cross midnight.
export function minuteInWindow(
  minute: number,
  start: number,
  end: number,
): boolean {
  if (start === end) return true;
  if (start < end) return minute >= start && minute < end;
  return minute >= start || minute < end;
}

export function isQuietHoursOpen(instant: Date, window: QuietWindow): boolean {
  const zone = safeZone(window.timeZone);
  const start = parseClock(window.start) ?? parseClock(DEFAULT_WINDOW_START)!;
  const end = parseClock(window.end) ?? parseClock(DEFAULT_WINDOW_END)!;
  const clock = wallClock(instant, zone);
  return minuteInWindow(clock.hour * 60 + clock.minute, start, end);
}

export function nextWindowStart(instant: Date, window: QuietWindow): Date {
  const zone = safeZone(window.timeZone);
  const startText = clockText(window.start) ?? DEFAULT_WINDOW_START;
  const endText = clockText(window.end) ?? DEFAULT_WINDOW_END;
  const normalized = { start: startText, end: endText, timeZone: zone };
  if (isQuietHoursOpen(instant, normalized)) return instant;
  const startMin = parseClock(startText)!;
  const endMin = parseClock(endText)!;
  if (startMin === endMin) return instant;

  const clock = wallClock(instant, zone);
  const today = dateText(clock);
  const nowMin = clock.hour * 60 + clock.minute;
  let date = today;
  if (startMin < endMin && nowMin >= endMin) date = addDays(today, 1);

  for (let extra = 0; extra < 3; extra += 1) {
    const at = zonedTimeToUtc(date, startText, zone);
    if (
      at.getTime() + 1000 >= instant.getTime() &&
      isQuietHoursOpen(at, normalized)
    ) {
      return at;
    }
    date = addDays(date, 1);
  }
  return zonedTimeToUtc(addDays(today, 1), startText, zone);
}

function zonedTimeToUtc(date: string, time: string, timeZone: string): Date {
  const [year, month, day] = date.split("-").map(Number);
  const [hour, minute] = time.split(":").map(Number);
  const desired = Date.UTC(year!, month! - 1, day!, hour, minute);
  let guess = desired;
  for (let attempt = 0; attempt < 4; attempt += 1) {
    const next = desired - offsetMinutes(new Date(guess), timeZone) * 60_000;
    if (next === guess) return new Date(next);
    guess = next;
  }
  return new Date(guess);
}

function offsetMinutes(instant: Date, timeZone: string): number {
  const clock = wallClock(instant, timeZone);
  const asUtc = Date.UTC(
    clock.year,
    clock.month - 1,
    clock.day,
    clock.hour,
    clock.minute,
    clock.second,
  );
  return Math.round((asUtc - instant.getTime()) / 60_000);
}

export function quietPlan(input: {
  now: Date;
  start: string;
  end: string;
  timeZone: string;
  urgent: boolean;
  urgentBypass: boolean;
}): QuietPlan {
  if (input.urgent && input.urgentBypass) return { action: "send" };
  const window = {
    start: input.start,
    end: input.end,
    timeZone: input.timeZone,
  };
  if (isQuietHoursOpen(input.now, window)) return { action: "send" };
  return { action: "queue", deliverAt: nextWindowStart(input.now, window) };
}

export function shouldDeliverQueued(
  masterOn: boolean,
  deliverAt: Date,
  now: Date,
): boolean {
  return masterOn && deliverAt.getTime() <= now.getTime();
}

export function summarizeQueued(
  items: readonly { title: string; body: string }[],
): { title: string; body: string } {
  const first = items[0];
  if (!first) return { title: "Update", body: "Update" };
  if (items.length === 1) {
    return { title: clip(first.title, 80), body: clip(first.body, 200) };
  }
  const titles = items.map((item) => item.title.trim()).filter(Boolean);
  const shown = titles.slice(0, 3).join(", ");
  const more = titles.length > 3 ? ` +${titles.length - 3} more` : "";
  const body = clip(`${items.length} updates: ${shown}${more}`, 200);
  return { title: clip(`${items.length} updates`, 80), body };
}

function safeZone(value: string): string {
  return isKnownTimeZone(value) ? value : DEFAULT_PUSH_TIME_ZONE;
}

function wallClock(instant: Date, timeZone: string) {
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
  if (hour === 24) hour = 0;
  return {
    year: Number(value.year),
    month: Number(value.month),
    day: Number(value.day),
    hour,
    minute: Number(value.minute),
    second: Number(value.second),
  };
}

function dateText(clock: { year: number; month: number; day: number }): string {
  return `${String(clock.year).padStart(4, "0")}-${String(clock.month).padStart(2, "0")}-${String(clock.day).padStart(2, "0")}`;
}

function clip(value: string, max: number): string {
  const trimmed = value.trim();
  if (!trimmed) return "Update";
  return trimmed.length <= max ? trimmed : trimmed.slice(0, max);
}
