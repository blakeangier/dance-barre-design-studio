import { Suspense } from "react";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canSeeCosts } from "@/lib/auth/permissions";
import { gateArea } from "@/lib/auth/session";
import { metres, money } from "@/lib/inventory/format";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Purchases" };

type LineRow = {
  id: number;
  line_code: string;
  material_code_raw: string | null;
  fabric_name_as_written: string | null;
  qty_ordered_m: number | null;
  needs_review: boolean;
  purchase_orders: {
    po_ref: string;
    supplier_as_written: string | null;
  } | null;
};

type PriceRow = {
  line_id: number;
  price_per_m: number | null;
  line_total: number | null;
};

export default function PurchasesPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <PurchasesScreen />
    </Suspense>
  );
}

async function PurchasesScreen() {
  const gate = await gateArea("purchases");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const supabase = await createClient();
  const linesResult = await supabase
    .from("purchase_order_lines")
    .select(
      "id, line_code, material_code_raw, fabric_name_as_written, qty_ordered_m, needs_review, purchase_orders(po_ref, supplier_as_written)",
    )
    .order("line_code");
  const pricesResult = canSeeCosts(gate.profile)
    ? await supabase
        .from("purchase_line_prices")
        .select("line_id, price_per_m, line_total")
    : { data: [] };
  const prices = new Map(
    ((pricesResult.data ?? []) as PriceRow[]).map((row) => [row.line_id, row]),
  );

  return (
    <div className="flex flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Purchases</h1>
      <ul className="flex flex-col gap-3">
        {((linesResult.data ?? []) as unknown as LineRow[]).map((line) => {
          const price = prices.get(line.id);
          return (
            <li
              key={line.id}
              className="rounded-2xl border border-line bg-card p-4"
            >
              <p className="font-medium text-ink">
                {line.line_code}
                {line.material_code_raw ? ` · ${line.material_code_raw}` : ""}
              </p>
              <p className="text-sm text-muted">
                {line.purchase_orders?.supplier_as_written ??
                  "Supplier not named"}{" "}
                · {line.purchase_orders?.po_ref}
              </p>
              <p className="text-sm text-muted">
                {line.fabric_name_as_written} · {metres(line.qty_ordered_m)}
              </p>
              {line.needs_review ? (
                <p className="mt-1 text-xs font-medium text-ink">
                  Needs review
                </p>
              ) : null}
              {price ? (
                <p className="mt-1 text-sm text-muted">
                  {money(price.price_per_m)} / m · Line{" "}
                  {money(price.line_total)}
                </p>
              ) : null}
            </li>
          );
        })}
      </ul>
    </div>
  );
}
