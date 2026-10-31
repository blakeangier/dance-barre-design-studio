export const PRODUCTION_STATUSES = [
  { value: "not_started", label: "Not started" },
  { value: "design_samples", label: "Design and samples" },
  { value: "fabric_ordered", label: "Fabric ordered" },
  { value: "ready_to_cut", label: "Ready to cut" },
  { value: "cutting", label: "Cutting" },
  { value: "sewing", label: "Sewing" },
  { value: "finishing_qc", label: "Finishing and quality check" },
  { value: "ready_for_pickup", label: "Ready for pickup" },
  { value: "delivered", label: "Delivered" },
] as const;

export type ProductionStatus = (typeof PRODUCTION_STATUSES)[number]["value"];

const PILL: Record<ProductionStatus, string> = {
  not_started: "border border-line bg-paper text-ink",
  design_samples: "bg-pink text-ink",
  fabric_ordered: "bg-orange text-ink",
  ready_to_cut: "bg-lime text-ink",
  cutting: "bg-teal text-ink",
  sewing: "bg-pink text-ink",
  finishing_qc: "bg-orange text-ink",
  ready_for_pickup: "bg-lime text-ink",
  delivered: "bg-teal text-ink",
};

export function isProductionStatus(value: string): value is ProductionStatus {
  return PRODUCTION_STATUSES.some((status) => status.value === value);
}

export function productionStatusLabel(
  value: string | null | undefined,
): string {
  const match = PRODUCTION_STATUSES.find((status) => status.value === value);
  return match?.label ?? "Not started";
}

export function productionStatusIndex(
  value: string | null | undefined,
): number {
  const index = PRODUCTION_STATUSES.findIndex(
    (status) => status.value === value,
  );
  return index < 0 ? 0 : index;
}

export function productionStatusPill(value: string | null | undefined): string {
  if (value && isProductionStatus(value)) return PILL[value];
  return PILL.not_started;
}
