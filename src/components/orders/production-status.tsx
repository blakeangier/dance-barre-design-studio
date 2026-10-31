import {
  PRODUCTION_STATUSES,
  productionStatusIndex,
  productionStatusLabel,
  productionStatusPill,
} from "@/lib/orders/production-status";

export function StatusPill({
  status,
  cancelled = false,
}: {
  status: string | null;
  cancelled?: boolean;
}) {
  if (cancelled) {
    return (
      <span className="inline-flex min-h-7 items-center rounded-full border border-line bg-paper px-3 text-xs font-medium text-ink">
        Cancelled
      </span>
    );
  }
  return (
    <span
      className={`inline-flex min-h-7 items-center rounded-full px-3 text-xs font-medium ${productionStatusPill(status)}`}
    >
      {productionStatusLabel(status)}
    </span>
  );
}

export function ProductionSteps({ status }: { status: string | null }) {
  const current = productionStatusIndex(status);
  return (
    <ol className="mt-2 flex gap-1" aria-label="Production progress">
      {PRODUCTION_STATUSES.map((step, index) => (
        <li
          key={step.value}
          title={step.label}
          className={`h-2 flex-1 rounded-full ${index <= current ? "bg-ink" : "bg-line"}`}
        />
      ))}
    </ol>
  );
}
