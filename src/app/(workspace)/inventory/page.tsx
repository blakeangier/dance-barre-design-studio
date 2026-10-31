import Link from "next/link";
import { Suspense } from "react";
import { StockBadge } from "@/components/inventory/stock-badge";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { gateArea } from "@/lib/auth/session";
import { firstQueryValue } from "@/lib/auth/notices";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Inventory" };

type InventoryProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type MaterialRow = {
  id: number;
  material_code: string;
  fabric_name: string | null;
  colour_name: string | null;
  fabric_type: string | null;
  content: string | null;
  bin_location: string | null;
  needs_review: boolean;
};

type StockRow = {
  material_id: number;
  on_hand_m: number | null;
  reserved_m: number | null;
  available_m: number | null;
  is_low_stock: boolean;
};

export default function InventoryPage(props: InventoryProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <InventoryScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function InventoryScreen({
  searchParams,
}: {
  searchParams: InventoryProps["searchParams"];
}) {
  const gate = await gateArea("inventory");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;

  const params = await searchParams;
  const query = (firstQueryValue(params.q) ?? "").trim().toLowerCase();
  const type = (firstQueryValue(params.type) ?? "").trim().toLowerCase();
  const lowOnly = firstQueryValue(params.low) === "1";
  const reviewOnly = firstQueryValue(params.review) === "1";
  const supabase = await createClient();
  const [materialsResult, stockResult] = await Promise.all([
    supabase
      .from("materials")
      .select(
        "id, material_code, fabric_name, colour_name, fabric_type, content, bin_location, needs_review",
      )
      .order("material_code"),
    supabase
      .from("material_availability")
      .select("material_id, on_hand_m, reserved_m, available_m, is_low_stock"),
  ]);

  const stock = new Map(
    ((stockResult.data ?? []) as StockRow[]).map((row) => [
      row.material_id,
      row,
    ]),
  );
  const materials = ((materialsResult.data ?? []) as MaterialRow[]).filter(
    (material) => {
      const levels = stock.get(material.id);
      const haystack = [
        material.material_code,
        material.fabric_name,
        material.colour_name,
        material.content,
        material.bin_location,
      ]
        .join(" ")
        .toLowerCase();
      if (query && !haystack.includes(query)) return false;
      if (type) {
        const kind =
          `${material.fabric_type ?? ""} ${material.content ?? ""}`.toLowerCase();
        if (!kind.includes(type)) return false;
      }
      if (lowOnly && !levels?.is_low_stock) return false;
      if (reviewOnly && !material.needs_review) return false;
      return true;
    },
  );

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="font-serif text-3xl text-ink">Inventory</h1>
        <p className="mt-2 text-sm text-muted">
          {materials.length} materials. On hand and reserved come from the stock
          ledger.
        </p>
      </div>
      <form
        className="grid gap-3 rounded-2xl border border-line bg-card p-4"
        method="get"
      >
        <label className="text-sm font-medium" htmlFor="q">
          Search
        </label>
        <input
          id="q"
          name="q"
          defaultValue={firstQueryValue(params.q) ?? ""}
          className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
        />
        <label className="text-sm font-medium" htmlFor="type">
          Type or content
        </label>
        <input
          id="type"
          name="type"
          defaultValue={firstQueryValue(params.type) ?? ""}
          className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
        />
        <label className="flex min-h-11 items-center gap-2 text-sm">
          <input
            type="checkbox"
            name="low"
            value="1"
            defaultChecked={lowOnly}
          />
          Low stock
        </label>
        <label className="flex min-h-11 items-center gap-2 text-sm">
          <input
            type="checkbox"
            name="review"
            value="1"
            defaultChecked={reviewOnly}
          />
          Needs review
        </label>
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
        >
          Apply
        </button>
      </form>
      {materialsResult.error ? (
        <p className="text-sm text-muted">The inventory list did not load.</p>
      ) : (
        <ul className="flex flex-col gap-3">
          {materials.map((material) => {
            const levels = stock.get(material.id);
            return (
              <li
                key={material.id}
                className="rounded-2xl border border-line bg-card p-4"
              >
                <Link
                  href={`/inventory/${encodeURIComponent(material.material_code)}`}
                  className="font-medium text-ink"
                >
                  {material.material_code}
                </Link>
                <p className="text-sm text-muted">
                  {[
                    material.fabric_name,
                    material.colour_name,
                    material.content,
                  ]
                    .filter(Boolean)
                    .join(" · ")}
                </p>
                {material.bin_location ? (
                  <p className="text-sm text-muted">
                    Bin {material.bin_location}
                  </p>
                ) : null}
                {material.needs_review ? (
                  <p className="mt-1 text-xs font-medium text-ink">
                    Needs review
                  </p>
                ) : null}
                <StockBadge
                  onHand={levels?.on_hand_m ?? null}
                  reserved={levels?.reserved_m ?? null}
                  available={levels?.available_m ?? null}
                  low={levels?.is_low_stock ?? false}
                />
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
