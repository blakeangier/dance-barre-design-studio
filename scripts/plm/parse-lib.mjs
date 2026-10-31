// Turns Elaine's tracker cells into structured values.
// A cell is structured only when it is one clean value. Anything else stays
// as the original text and is marked for review.

const STAGE_NAMES = [
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
];

const SIZE_CODES = [
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
];

export function blank(value) {
  return value === undefined || value === null || String(value).trim() === "";
}

export function text(value) {
  if (blank(value)) return null;
  return String(value).trim();
}

export function parseMetres(value) {
  const raw = text(value);
  if (raw === null) return { metres: null, raw: null, needsReview: false };
  const plain = raw.match(/^(-?\d+(?:\.\d+)?)$/);
  if (plain) {
    return { metres: Number(plain[1]), raw, needsReview: false };
  }
  const withUnit = raw.match(/^(-?\d+(?:\.\d+)?)\s*m$/i);
  if (withUnit) {
    return { metres: Number(withUnit[1]), raw, needsReview: false };
  }
  return {
    metres: null,
    raw,
    needsReview: true,
    reason: "Not a single quantity in metres.",
  };
}

export function parseNumber(value) {
  const raw = text(value);
  if (raw === null) return { number: null, raw: null, needsReview: false };
  if (/^-?\d+(?:\.\d+)?$/.test(raw)) {
    return { number: Number(raw), raw, needsReview: false };
  }
  return {
    number: null,
    raw,
    needsReview: true,
    reason: "Not a single number.",
  };
}

export function parseInteger(value) {
  const parsed = parseNumber(value);
  if (parsed.number === null) {
    return {
      integer: null,
      raw: parsed.raw,
      needsReview: parsed.needsReview,
      reason: parsed.reason,
    };
  }
  if (!Number.isInteger(parsed.number)) {
    return {
      integer: null,
      raw: parsed.raw,
      needsReview: true,
      reason: "Not a whole number.",
    };
  }
  return { integer: parsed.number, raw: parsed.raw, needsReview: false };
}

export function parseDate(value) {
  const raw = text(value);
  if (raw === null) return { date: null, raw: null, needsReview: false };
  const match = raw.match(/^(\d{4}-\d{2}-\d{2})(?:\s+00:00:00)?$/);
  if (match) return { date: match[1], raw, needsReview: false };
  return { date: null, raw, needsReview: true, reason: "Not a calendar date." };
}

export function normalizeOrderStatus(value) {
  const raw = text(value);
  if (raw === null) return { status: null, raw: null };
  if (raw.toLowerCase().startsWith("cancelled")) {
    return { status: "cancelled", raw };
  }
  return {
    status: null,
    raw,
    needsReview: true,
    reason: "Status was not normalised.",
  };
}

export function parseStageCell(value) {
  const raw = text(value);
  if (raw === null) {
    return { cellText: null, interpretedOn: null, interpretedYes: null };
  }
  const dated = raw.match(/^(\d{4}-\d{2}-\d{2})(?:\s+00:00:00)?$/);
  if (dated) {
    return { cellText: raw, interpretedOn: dated[1], interpretedYes: null };
  }
  if (/^(yes|no)$/i.test(raw)) {
    return {
      cellText: raw,
      interpretedOn: null,
      interpretedYes: raw.toLowerCase() === "yes",
    };
  }
  return { cellText: raw, interpretedOn: null, interpretedYes: null };
}

export function parseCheckCell(value) {
  const raw = text(value);
  if (raw === null) return { checkText: null, checkYes: null };
  if (raw === "1" || raw === "0") {
    return { checkText: raw, checkYes: raw === "1" };
  }
  return { checkText: raw, checkYes: null };
}

// Order 005 contrast lines name both F002-125 and F002-25. Do not pick one.
export function materialIdForBom(materialId, fabricAsWritten) {
  const written = text(fabricAsWritten) ?? "";
  const conflict = /F002-125/i.test(written) && /F002-25(?!\d)/i.test(written);
  if (conflict || blank(materialId)) {
    return {
      materialCode: null,
      needsReview: conflict || blank(materialId),
      reason: conflict
        ? "F002-125 and F002-25 are both named. The line is not linked to either."
        : null,
    };
  }
  return { materialCode: text(materialId), needsReview: false, reason: null };
}

export function isSizeDataRow(row) {
  const key = text(row[0]);
  if (key === null) return false;
  if (key === "TOTAL") return false;
  if (key === "Style Key" || key === "Group") return false;
  if (/^order\b/i.test(key) || /size breakdown/i.test(key)) return false;
  return key.includes("|");
}

export function containsEmail(value) {
  return /@/.test(text(value) ?? "");
}

export { STAGE_NAMES, SIZE_CODES };
