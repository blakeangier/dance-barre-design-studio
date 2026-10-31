import Link from "next/link";
import { Suspense } from "react";
import {
  reserveOrderFabric,
  saveBomSizeQty,
} from "@/app/(workspace)/records/production-actions";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { metres } from "@/lib/inventory/format";
import { SIZE_CODES } from "@/lib/records/edit";
import { fabricNeeded, shortageMetres } from "@/lib/production/fabric-need";
import { orderFabricPosition } from "@/lib/inventory/usage";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Fabric needed" };

type PageProps = {
  params: Promise<{ orderNumber: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function FabricPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <FabricScreen params={props.params} searchParams={props.searchParams} />
    </Suspense>
  );
}

async function FabricScreen({ params, searchParams }: PageProps) {
  const gate = await gateArea("production-orders");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const orderNumber = decodeURIComponent((await params).orderNumber);
  const notice = firstQueryValue((await searchParams).notice);
  const editor = canEditInventory(gate.profile);
  const supabase = await createClient();
  const { data: order } = await supabase
    .from("costume_orders")
    .select("id, order_number")
    .eq("order_number", orderNumber)
    .maybeSingle();
  if (!order) {
    return <h1 className="font-serif text-3xl text-ink">Order not found</h1>;
  }
  const [linesResult, sizesResult, stockResult, ledgerResult] =
    await Promise.all([
      supabase
        .from("bom_lines")
        .select(
          "id, line_code, component, fabric_name, material_id, consumption_per_unit_m, waste_percent, is_estimate, flag",
        )
        .eq("order_id", order.id)
        .is("archived_at", null),
      supabase
        .from("order_sizes")
        .select("size_code, qty")
        .eq("order_id", order.id),
      supabase.from("material_availability").select("material_id, available_m"),
      supabase
        .from("stock_transactions")
        .select(
          "id, material_id, order_id, txn_type, qty_m, usage_kind, is_waste, reservation_drawdown_m, reverses_id",
        )
        .eq("order_id", order.id),
    ]);
  const sizeQtyResult = await supabase
    .from("bom_size_qty")
    .select("bom_line_id, size_code, metres_per_piece")
    .is("archived_at", null);
  const counts = (
    (sizesResult.data ?? []) as { size_code: string; qty: number | null }[]
  )
    .filter((row) => row.qty)
    .map((row) => ({ sizeCode: row.size_code, count: row.qty ?? 0 }));
  const pieces = (sizeQtyResult.data ?? []) as {
    bom_line_id: number;
    size_code: string;
    metres_per_piece: number | string;
  }[];
  const available = new Map(
    (
      (stockResult.data ?? []) as {
        material_id: number;
        available_m: number | string | null;
      }[]
    ).map((row) => [row.material_id, Number(row.available_m)]),
  );
  const lines = (linesResult.data ?? []) as {
    id: number;
    line_code: string;
    component: string | null;
    fabric_name: string | null;
    material_id: number | null;
    consumption_per_unit_m: number | string | null;
    waste_percent: number | string | null;
    is_estimate: boolean;
    flag: string | null;
  }[];

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link
        href={`/production-orders/${encodeURIComponent(orderNumber)}`}
        className="text-sm text-muted"
      >
        {orderNumber}
      </Link>
      <h1 className="font-serif text-3xl text-ink">
        Fabric needed vs available
      </h1>
      {notice === "saved" ? <StatusNote>Saved.</StatusNote> : null}
      {notice === "failed" ? (
        <StatusNote tone="error">That did not save.</StatusNote>
      ) : null}
      {lines.length === 0 ? (
        <p className="text-sm text-muted">No fabric lines on this order yet.</p>
      ) : (
        lines.map((line) => {
          const need = fabricNeeded({
            sizePieces: pieces
              .filter((piece) => piece.bom_line_id === line.id)
              .map((piece) => ({
                sizeCode: piece.size_code,
                metresPerPiece: Number(piece.metres_per_piece),
              })),
            sizeCounts: counts,
            wastePercent:
              line.waste_percent === null ? null : Number(line.waste_percent),
            estimateMetresPerPiece:
              line.consumption_per_unit_m === null
                ? null
                : Number(line.consumption_per_unit_m),
            isEstimate: line.is_estimate,
          });
          const onHand =
            line.material_id === null
              ? null
              : (available.get(line.material_id) ?? null);
          const short = shortageMetres(need.metres, onHand);
          const position =
            line.material_id === null
              ? null
              : orderFabricPosition(
                  (
                    (ledgerResult.data ?? []) as {
                      id: number;
                      material_id: number;
                      order_id: number;
                      txn_type:
                        "reserve" | "use" | "adjust" | "receive" | "return";
                      qty_m: number | string | null;
                      usage_kind: "sample" | "production" | null;
                      is_waste: boolean;
                      reservation_drawdown_m: number | string | null;
                      reverses_id: number | null;
                    }[]
                  ).map((row) => ({
                    id: row.id,
                    materialId: row.material_id,
                    orderId: row.order_id,
                    txnType: row.txn_type,
                    qtyM: row.qty_m === null ? null : Number(row.qty_m),
                    usageKind: row.usage_kind,
                    waste: row.is_waste,
                    drawdownM:
                      row.reservation_drawdown_m === null
                        ? null
                        : Number(row.reservation_drawdown_m),
                    reversesId: row.reverses_id,
                  })),
                  line.material_id,
                  order.id,
                );
          return (
            <section
              key={line.id}
              className="flex flex-col gap-2 rounded-2xl border border-line bg-card p-4"
            >
              <h2 className="font-medium text-ink">
                {line.line_code}
                {line.component ? ` · ${line.component}` : ""}
              </h2>
              <p className="text-sm text-muted">
                {line.fabric_name ?? "Unlinked fabric"}
                {need.estimate ? " · Estimate" : ""}
              </p>
              <p className="text-sm text-ink">
                Needed {metres(need.metres)} · Available{" "}
                {onHand === null ? "unknown" : metres(onHand)}
              </p>
              {short !== null && short > 0 ? (
                <p className="text-sm font-medium text-ink">
                  Short {metres(short)}
                </p>
              ) : null}
              {editor && line.material_id && need.metres > 0 ? (
                <form action={reserveOrderFabric}>
                  <input type="hidden" name="orderNumber" value={orderNumber} />
                  <input
                    type="hidden"
                    name="materialId"
                    value={line.material_id}
                  />
                  <input type="hidden" name="needed" value={need.metres} />
                  <input
                    type="hidden"
                    name="reserved"
                    value={position?.reservedM ?? 0}
                  />
                  <button
                    type="submit"
                    className="min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white"
                  >
                    Reserve fabric for this order
                  </button>
                </form>
              ) : null}
              {editor ? (
                <form action={saveBomSizeQty} className="flex flex-col gap-2">
                  <input type="hidden" name="orderNumber" value={orderNumber} />
                  <input type="hidden" name="lineId" value={line.id} />
                  <label
                    className="text-sm font-medium"
                    htmlFor={`size-${line.id}`}
                  >
                    Metres per costume
                  </label>
                  <select
                    id={`size-${line.id}`}
                    name="sizeCode"
                    className="min-h-12 rounded-xl border border-line bg-card px-3"
                  >
                    {SIZE_CODES.map((code) => (
                      <option key={code} value={code}>
                        {code}
                      </option>
                    ))}
                  </select>
                  <input
                    name="metres"
                    inputMode="decimal"
                    required
                    placeholder="Metres for one costume"
                    className="min-h-12 rounded-xl border border-line bg-card px-3"
                  />
                  <input
                    name="wastePercent"
                    inputMode="decimal"
                    placeholder="Waste % (optional)"
                    defaultValue={line.waste_percent ?? ""}
                    className="min-h-12 rounded-xl border border-line bg-card px-3"
                  />
                  <button
                    type="submit"
                    className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium"
                  >
                    Save size quantity
                  </button>
                </form>
              ) : null}
            </section>
          );
        })
      )}
    </div>
  );
}
