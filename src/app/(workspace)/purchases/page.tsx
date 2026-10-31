import Link from "next/link";
import { Suspense } from "react";
import { ListHeader } from "@/components/records/list-header";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canRecordPurchase, canSeeCosts } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
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

type PurchasesProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function PurchasesPage(props: PurchasesProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <PurchasesScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function PurchasesScreen({
  searchParams,
}: {
  searchParams: PurchasesProps["searchParams"];
}) {
  const gate = await gateArea("purchases");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const showArchived = firstQueryValue((await searchParams).archived) === "1";
  const supabase = await createClient();
  let linesQuery = supabase
    .from("purchase_order_lines")
    .select(
      "id, line_code, material_code_raw, fabric_name_as_written, qty_ordered_m, needs_review, purchase_orders(po_ref, supplier_as_written)",
    )
    .order("line_code");
  if (!showArchived) linesQuery = linesQuery.is("archived_at", null);
  const linesResult = await linesQuery;
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
      <ListHeader
        title="Purchases"
        newHref="/purchases/new"
        newLabel="New purchase"
        showArchived={showArchived}
        canCreate={canRecordPurchase(gate.profile)}
      />
      <ul className="flex flex-col gap-3">
        {((linesResult.data ?? []) as unknown as LineRow[]).map((line) => {
          const price = prices.get(line.id);
          return (
            <li
              key={line.id}
              className="rounded-2xl border border-line bg-card p-4"
            >
              <Link
                href={`/purchases/${encodeURIComponent(line.line_code)}`}
                className="inline-flex min-h-11 items-center font-medium text-ink"
              >
                {line.line_code}
                {line.material_code_raw ? ` · ${line.material_code_raw}` : ""}
              </Link>
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
