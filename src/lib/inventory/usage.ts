export const USAGE_STEP_M = 0.1;
export const REVERSAL_WINDOW_MS = 24 * 60 * 60 * 1000;

export type UsagePurpose = "sample" | "production";
export type UsageUnit = "m" | "cm";

export type FabricOrderOption = {
  id: number;
  orderNumber: string;
  label: string;
};

export type FabricStyleOption = {
  id: number;
  orderId: number | null;
  label: string;
};

export type FabricLineOption = {
  id: number;
  orderId: number | null;
  styleId: number | null;
  materialId: number | null;
  label: string;
};

export type ReservationSlice = {
  id: number;
  materialId: number;
  orderId: number;
  txnType: "reserve" | "use" | "adjust" | "receive" | "return";
  qtyM: number | null;
  usageKind: UsagePurpose | null;
  waste: boolean;
  drawdownM: number | null;
  reversesId: number | null;
};

export type OrderFabricPosition = {
  reservedM: number;
  usedM: number;
  wasteM: number;
  drawnM: number;
};

export type FabricUsePlan = {
  useM: number;
  wasteM: number;
  drawdownUseM: number;
  drawdownWasteM: number;
  onHandAfter: number;
  reservedAfter: number | null;
  availableAfter: number;
  warnsNegativeOnHand: boolean;
  warnsExceedsReservation: boolean;
};

export function roundMetres(metres: number): number {
  return Math.round(metres * 10000) / 10000;
}

export function toMetres(
  value: number | string | null | undefined,
): number | null {
  if (value === null || value === undefined || value === "") return null;
  const number = typeof value === "number" ? value : Number(value);
  if (!Number.isFinite(number)) return null;
  return roundMetres(number);
}

export function cmToMetres(cm: number): number {
  return roundMetres(cm / 100);
}

export function metresToCm(metres: number): number {
  return Math.round(metres * 100);
}

export function parseUsageAmount(raw: string, unit: UsageUnit): number | null {
  const value = Number(raw.trim());
  if (!Number.isFinite(value) || value <= 0) return null;
  const metres = unit === "cm" ? cmToMetres(value) : roundMetres(value);
  return metres > 0 ? metres : null;
}

export function todayInToronto(now = new Date()): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "America/Toronto",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(now);
  const year = parts.find((part) => part.type === "year")?.value;
  const month = parts.find((part) => part.type === "month")?.value;
  const day = parts.find((part) => part.type === "day")?.value;
  if (!year || !month || !day) return "";
  return `${year}-${month}-${day}`;
}

export function isIsoDate(value: string): boolean {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const year = Number(value.slice(0, 4));
  const month = Number(value.slice(5, 7));
  const day = Number(value.slice(8, 10));
  const date = new Date(Date.UTC(year, month - 1, day));
  return (
    date.getUTCFullYear() === year &&
    date.getUTCMonth() === month - 1 &&
    date.getUTCDate() === day
  );
}

export function orderFabricPosition(
  rows: readonly ReservationSlice[],
  materialId: number,
  orderId: number,
): OrderFabricPosition {
  const reversed = new Set(
    rows
      .filter((row) => row.reversesId !== null)
      .map((row) => row.reversesId as number),
  );
  let reserved = 0;
  let used = 0;
  let waste = 0;
  let drawn = 0;
  for (const row of rows) {
    if (row.materialId !== materialId || row.orderId !== orderId) continue;
    if (row.txnType === "reserve" && row.qtyM !== null) reserved += row.qtyM;
    if (
      row.txnType === "use" &&
      row.usageKind === "production" &&
      row.qtyM !== null &&
      !reversed.has(row.id)
    ) {
      if (row.waste) waste += row.qtyM;
      else used += row.qtyM;
    }
    if (row.txnType === "use" && row.drawdownM) drawn += row.drawdownM;
    if (row.txnType === "adjust" && row.reversesId !== null && row.drawdownM) {
      drawn -= row.drawdownM;
    }
  }
  return {
    reservedM: roundMetres(reserved),
    usedM: roundMetres(used),
    wasteM: roundMetres(waste),
    drawnM: roundMetres(drawn),
  };
}

export function remainingReserved(position: OrderFabricPosition): number {
  return Math.max(0, roundMetres(position.reservedM - position.drawnM));
}

export function planFabricUse(input: {
  onHandM: number | null;
  reservedM: number | null;
  purpose: UsagePurpose;
  position: OrderFabricPosition | null;
  useM: number;
  wasteM: number;
}): FabricUsePlan {
  const useM = roundMetres(input.useM);
  const wasteM = input.wasteM > 0 ? roundMetres(input.wasteM) : 0;
  let drawdownUseM = 0;
  let drawdownWasteM = 0;
  let warnsExceedsReservation = false;
  if (
    input.purpose === "production" &&
    input.position &&
    input.position.reservedM > 0
  ) {
    const remaining = remainingReserved(input.position);
    drawdownUseM = roundMetres(Math.min(remaining, useM));
    const afterUse = roundMetres(remaining - drawdownUseM);
    drawdownWasteM = roundMetres(Math.min(afterUse, wasteM));
    if (roundMetres(useM + wasteM) > remaining) warnsExceedsReservation = true;
  }
  const onHandAfter = roundMetres((input.onHandM ?? 0) - useM - wasteM);
  const drawdown = roundMetres(drawdownUseM + drawdownWasteM);
  const reservedAfter =
    input.reservedM === null && drawdown === 0
      ? null
      : roundMetres(Math.max(0, (input.reservedM ?? 0) - drawdown));
  return {
    useM,
    wasteM,
    drawdownUseM,
    drawdownWasteM,
    onHandAfter,
    reservedAfter,
    availableAfter: roundMetres(onHandAfter - (reservedAfter ?? 0)),
    warnsNegativeOnHand: onHandAfter < 0,
    warnsExceedsReservation,
  };
}

export function canReverseUsage(input: {
  createdBy: string | null;
  createdAt: Date;
  alreadyReversed: boolean;
  actorId: string;
  actorCanCorrectAny: boolean;
  now: Date;
}): boolean {
  if (input.alreadyReversed) return false;
  if (input.actorCanCorrectAny) return true;
  if (input.createdBy !== input.actorId) return false;
  return input.now.getTime() - input.createdAt.getTime() < REVERSAL_WINDOW_MS;
}

export function stockAfterReversal(input: {
  onHandM: number | null;
  reservedM: number | null;
  qtyM: number;
  drawdownM: number;
}): { onHandM: number; reservedM: number | null; availableM: number } {
  const onHandM = roundMetres((input.onHandM ?? 0) + input.qtyM);
  const reservedM =
    input.reservedM === null && input.drawdownM === 0
      ? null
      : roundMetres((input.reservedM ?? 0) + input.drawdownM);
  return {
    onHandM,
    reservedM,
    availableM: roundMetres(onHandM - (reservedM ?? 0)),
  };
}

export type UsageTotalSource = {
  orderId: number | null;
  styleId: number | null;
  purpose: UsagePurpose;
  waste: boolean;
  qtyM: number;
  reversed: boolean;
};

export type OrderUsageTotal = {
  orderId: number;
  usedM: number;
  wasteM: number;
};

export type StyleUsageTotal = {
  styleId: number;
  sampleUsedM: number;
  sampleWasteM: number;
  productionUsedM: number;
  productionWasteM: number;
};

export function summarizeUsage(rows: readonly UsageTotalSource[]): {
  orders: OrderUsageTotal[];
  styles: StyleUsageTotal[];
} {
  const orders = new Map<number, OrderUsageTotal>();
  const styles = new Map<number, StyleUsageTotal>();
  for (const row of rows) {
    if (row.reversed || row.qtyM <= 0) continue;
    if (row.purpose === "production" && row.orderId !== null) {
      const order = orders.get(row.orderId) ?? {
        orderId: row.orderId,
        usedM: 0,
        wasteM: 0,
      };
      if (row.waste) order.wasteM = roundMetres(order.wasteM + row.qtyM);
      else order.usedM = roundMetres(order.usedM + row.qtyM);
      orders.set(row.orderId, order);
    }
    if (row.styleId !== null) {
      const style = styles.get(row.styleId) ?? {
        styleId: row.styleId,
        sampleUsedM: 0,
        sampleWasteM: 0,
        productionUsedM: 0,
        productionWasteM: 0,
      };
      if (row.purpose === "sample") {
        if (row.waste)
          style.sampleWasteM = roundMetres(style.sampleWasteM + row.qtyM);
        else style.sampleUsedM = roundMetres(style.sampleUsedM + row.qtyM);
      } else if (row.waste) {
        style.productionWasteM = roundMetres(style.productionWasteM + row.qtyM);
      } else {
        style.productionUsedM = roundMetres(style.productionUsedM + row.qtyM);
      }
      styles.set(row.styleId, style);
    }
  }
  return {
    orders: [...orders.values()],
    styles: [...styles.values()],
  };
}

export type UsageLogFilters = {
  material: string;
  order: string;
  style: string;
  personId: string | null;
  from: string | null;
  to: string | null;
  kind: "all" | UsagePurpose;
};

export type UsageLogEntry = {
  id: number;
  createdBy: string | null;
  occurredOn: string | null;
  purpose: UsagePurpose | null;
  materialCode: string;
  materialName: string | null;
  orderNumber: string | null;
  styleLabel: string | null;
  qtyM: number;
};

export function filterUsageLog<T extends UsageLogEntry>(
  entries: readonly T[],
  filters: UsageLogFilters,
): T[] {
  const material = filters.material.trim().toLowerCase();
  const order = filters.order.trim().toLowerCase();
  const style = filters.style.trim().toLowerCase();
  return entries.filter((entry) => {
    if (filters.personId && entry.createdBy !== filters.personId) return false;
    if (filters.kind !== "all" && entry.purpose !== filters.kind) return false;
    if (material) {
      const haystack =
        `${entry.materialCode} ${entry.materialName ?? ""}`.toLowerCase();
      if (!haystack.includes(material)) return false;
    }
    if (order && !(entry.orderNumber ?? "").toLowerCase().includes(order)) {
      return false;
    }
    if (style && !(entry.styleLabel ?? "").toLowerCase().includes(style)) {
      return false;
    }
    if (
      filters.from &&
      (!entry.occurredOn || entry.occurredOn < filters.from)
    ) {
      return false;
    }
    if (filters.to && (!entry.occurredOn || entry.occurredOn > filters.to)) {
      return false;
    }
    return true;
  });
}
