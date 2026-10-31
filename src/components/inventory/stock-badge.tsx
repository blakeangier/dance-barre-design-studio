import { metres } from "@/lib/inventory/format";

export function StockBadge({
  onHand,
  reserved,
  available,
  low,
}: {
  onHand: number | string | null;
  reserved: number | string | null;
  available: number | string | null;
  low: boolean;
}) {
  return (
    <p
      className={`mt-2 flex flex-wrap gap-2 text-xs ${low ? "rounded-xl bg-orange px-2 py-2 text-ink" : "text-muted"}`}
    >
      <span>On hand {metres(onHand)}</span>
      <span>Reserved {metres(reserved)}</span>
      <span className="font-medium text-ink">
        Available {metres(available)}
        {low ? " · Low" : ""}
      </span>
    </p>
  );
}
