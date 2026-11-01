import { createHash } from "node:crypto";

export type OutsidePurchase = {
  vendor: string;
  amount: number | null;
  currency: "CAD" | "USD";
  purchasedOn: string | null;
  rawDate: string | null;
  refund: boolean;
  archived: boolean;
};

export function outsideCostumeRowHash(input: {
  sourceTab: string;
  sourceRow: number;
  rawDate: string;
  vendor: string;
  itemDescription: string;
  paymentMethod: string;
}): string {
  const canonical = [
    input.sourceTab.trim(),
    String(input.sourceRow),
    input.rawDate.trim(),
    input.vendor.trim(),
    input.itemDescription.trim(),
    input.paymentMethod.trim(),
  ].join("\u001f");
  return createHash("sha256").update(canonical).digest("hex");
}

export function looksLikeFullCardNumber(value: string): boolean {
  return /[0-9]{8,}/.test(value);
}

export function outsideCostumeSpend(rows: readonly OutsidePurchase[]): {
  cad: number;
  usd: number;
  missingAmount: number;
  missingDate: number;
  byVendor: { vendor: string; cad: number; usd: number }[];
  byMonth: { month: string; cad: number; usd: number }[];
} {
  const vendors = new Map<string, { cad: number; usd: number }>();
  const months = new Map<string, { cad: number; usd: number }>();
  let cad = 0;
  let usd = 0;
  let missingAmount = 0;
  let missingDate = 0;
  for (const row of rows) {
    if (row.archived) continue;
    const dated = Boolean(row.purchasedOn) || Boolean(row.rawDate?.trim());
    if (!dated) missingDate += 1;
    if (row.amount === null) {
      missingAmount += 1;
      continue;
    }
    const signed = row.refund && row.amount > 0 ? -row.amount : row.amount;
    if (row.currency === "USD") usd += signed;
    else cad += signed;
    const vendor = vendors.get(row.vendor) ?? { cad: 0, usd: 0 };
    const monthKey = row.purchasedOn?.slice(0, 7) ?? "No date";
    const month = months.get(monthKey) ?? { cad: 0, usd: 0 };
    if (row.currency === "USD") {
      vendor.usd += signed;
      month.usd += signed;
    } else {
      vendor.cad += signed;
      month.cad += signed;
    }
    vendors.set(row.vendor, vendor);
    months.set(monthKey, month);
  }
  const round = (value: number) => Math.round(value * 100) / 100;
  return {
    cad: round(cad),
    usd: round(usd),
    missingAmount,
    missingDate,
    byVendor: [...vendors.entries()]
      .map(([vendor, totals]) => ({
        vendor,
        cad: round(totals.cad),
        usd: round(totals.usd),
      }))
      .sort((left, right) => right.cad + right.usd - (left.cad + left.usd)),
    byMonth: [...months.entries()]
      .map(([month, totals]) => ({
        month,
        cad: round(totals.cad),
        usd: round(totals.usd),
      }))
      .sort((left, right) => (left.month < right.month ? -1 : 1)),
  };
}
