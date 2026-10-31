export const EMPLOYMENT_TYPES = [
  { value: "", label: "Not set" },
  { value: "full-time", label: "Full-time" },
  { value: "part-time", label: "Part-time" },
] as const;

export const ORDER_STATUSES = [
  { value: "", label: "In progress" },
  { value: "cancelled", label: "Cancelled" },
] as const;

export const REVIEW_STATUSES = [
  { value: "open", label: "Open" },
  { value: "answered", label: "Answered" },
  { value: "closed", label: "Closed" },
] as const;

export const STAGE_NAMES = [
  "Pattern Complete",
  "Sample Completed",
  "Fit Test",
  "Corrections",
  "Approved",
  "Grading",
  "Marker",
  "Fabrics in stock",
  "Notions in stock",
  "Cut Ticket Created",
  "Ready to Cut",
] as const;

export const SIZE_CODES = [
  "SC",
  "IC",
  "IC-L",
  "MC",
  "MC-L",
  "LC",
  "XLC",
  "XSA",
  "SA",
  "SA-L",
  "MA",
  "LA",
  "XLA",
  "XXLA",
] as const;

export type FieldResult<T> =
  { ok: true; value: T } | { ok: false; notice: string };

function text(value: FormDataEntryValue | null | undefined): string {
  return typeof value === "string" ? value.trim() : "";
}

export function optionalText(
  value: FormDataEntryValue | null | undefined,
  max: number,
): FieldResult<string | null> {
  const trimmed = text(value);
  if (!trimmed) return { ok: true, value: null };
  if (trimmed.length > max) return { ok: false, notice: "long" };
  return { ok: true, value: trimmed };
}

export function requiredText(
  value: FormDataEntryValue | null | undefined,
  max: number,
): FieldResult<string> {
  const trimmed = text(value);
  if (!trimmed) return { ok: false, notice: "required" };
  if (trimmed.length > max) return { ok: false, notice: "long" };
  return { ok: true, value: trimmed };
}

export function personName(
  value: FormDataEntryValue | null | undefined,
): FieldResult<string> {
  const result = requiredText(value, 120);
  if (!result.ok)
    return result.notice === "long" ? result : { ok: false, notice: "name" };
  return result;
}

export function employmentType(
  value: FormDataEntryValue | null | undefined,
): FieldResult<"full-time" | "part-time" | null> {
  const trimmed = text(value);
  if (!trimmed) return { ok: true, value: null };
  if (trimmed === "full-time" || trimmed === "part-time") {
    return { ok: true, value: trimmed };
  }
  return { ok: false, notice: "employment" };
}

export function personalEmail(
  value: FormDataEntryValue | null | undefined,
): FieldResult<string | null> {
  const trimmed = text(value);
  if (!trimmed) return { ok: true, value: null };
  if (
    trimmed.length > 200 ||
    !trimmed.includes("@") ||
    trimmed.startsWith("@")
  ) {
    return { ok: false, notice: "email" };
  }
  return { ok: true, value: trimmed };
}

export function phoneNumber(
  value: FormDataEntryValue | null | undefined,
): FieldResult<string | null> {
  const result = optionalText(value, 40);
  if (!result.ok) return { ok: false, notice: "phone" };
  return result;
}

export function optionalId(
  value: FormDataEntryValue | null | undefined,
): FieldResult<number | null> {
  const trimmed = text(value);
  if (!trimmed) return { ok: true, value: null };
  if (!/^\d+$/.test(trimmed)) return { ok: false, notice: "failed" };
  return { ok: true, value: Number(trimmed) };
}

export function optionalNumber(
  value: FormDataEntryValue | null | undefined,
): FieldResult<number | null> {
  const trimmed = text(value);
  if (!trimmed) return { ok: true, value: null };
  if (!/^-?\d+(\.\d+)?$/.test(trimmed)) return { ok: false, notice: "number" };
  const number = Number(trimmed);
  if (!Number.isFinite(number)) return { ok: false, notice: "number" };
  return { ok: true, value: number };
}

export function optionalDate(
  value: FormDataEntryValue | null | undefined,
): FieldResult<string | null> {
  const trimmed = text(value);
  if (!trimmed) return { ok: true, value: null };
  if (!/^\d{4}-\d{2}-\d{2}$/.test(trimmed))
    return { ok: false, notice: "date" };
  const parts = trimmed.split("-").map(Number);
  const year = parts[0];
  const month = parts[1];
  const day = parts[2];
  if (year === undefined || month === undefined || day === undefined) {
    return { ok: false, notice: "date" };
  }
  const parsed = new Date(Date.UTC(year, month - 1, day));
  if (
    parsed.getUTCFullYear() !== year ||
    parsed.getUTCMonth() !== month - 1 ||
    parsed.getUTCDate() !== day
  ) {
    return { ok: false, notice: "date" };
  }
  return { ok: true, value: trimmed };
}

export function orderStatus(
  value: FormDataEntryValue | null | undefined,
): FieldResult<string | null> {
  const trimmed = text(value);
  if (!trimmed) return { ok: true, value: null };
  if (trimmed === "cancelled") return { ok: true, value: "cancelled" };
  return { ok: false, notice: "status" };
}

export function reviewStatus(
  value: FormDataEntryValue | null | undefined,
): FieldResult<"open" | "answered" | "closed"> {
  const trimmed = text(value);
  if (trimmed === "open" || trimmed === "answered" || trimmed === "closed") {
    return { ok: true, value: trimmed };
  }
  return { ok: false, notice: "status" };
}

export function stageYes(
  value: FormDataEntryValue | null | undefined,
): FieldResult<boolean | null> {
  const trimmed = text(value);
  if (!trimmed) return { ok: true, value: null };
  if (trimmed === "yes") return { ok: true, value: true };
  if (trimmed === "no") return { ok: true, value: false };
  return { ok: false, notice: "status" };
}

export function checked(value: FormDataEntryValue | null | undefined): boolean {
  return value === "on" || value === "true" || value === "1";
}

export const EDIT_NOTICES: Record<
  string,
  { tone: "ok" | "error"; text: string }
> = {
  saved: { tone: "ok", text: "Saved." },
  "record-saved": { tone: "ok", text: "Saved." },
  required: { tone: "error", text: "Fill in the required fields." },
  name: { tone: "error", text: "Enter a name, up to 120 characters." },
  phone: { tone: "error", text: "Phone numbers can be up to 40 characters." },
  long: { tone: "error", text: "That text is too long." },
  number: { tone: "error", text: "Enter a plain number, or leave it blank." },
  date: {
    tone: "error",
    text: "Enter a date as YYYY-MM-DD, or leave it blank.",
  },
  status: { tone: "error", text: "Choose a status from the list." },
  employment: {
    tone: "error",
    text: "Choose full-time, part-time, or leave the type blank.",
  },
  email: {
    tone: "error",
    text: "Enter a personal email with an @, or leave it blank.",
  },
  duplicate: {
    tone: "error",
    text: "That code is already used. Choose another.",
  },
  denied: { tone: "error", text: "You can't change that." },
  failed: { tone: "error", text: "That did not save. Try again." },
  missing: { tone: "error", text: "That record could not be found." },
};
