import Link from "next/link";
import {
  addSizeCode,
  saveOrderSizeGrid,
} from "@/app/(workspace)/records/size-grid-actions";
import { gridTotals } from "@/lib/orders/size-grid";
import { createClient } from "@/lib/supabase/server";

type StyleRow = {
  id: number;
  style_key: string;
  garment_description: string | null;
};

export async function SizeGrid({
  orderId,
  orderNumber,
  canEdit,
  canEditScale,
}: {
  orderId: number;
  orderNumber: string;
  canEdit: boolean;
  canEditScale: boolean;
}) {
  const supabase = await createClient();
  const [scaleResult, stylesResult, sizesResult] = await Promise.all([
    supabase
      .from("size_scale")
      .select("size_code, sort_order")
      .is("archived_at", null)
      .order("sort_order"),
    supabase
      .from("styles")
      .select("id, style_key, garment_description")
      .eq("order_id", orderId)
      .is("archived_at", null)
      .order("style_key"),
    supabase
      .from("order_sizes")
      .select("style_id, size_code, qty")
      .eq("order_id", orderId),
  ]);
  const columns = ((scaleResult.data ?? []) as { size_code: string }[]).map(
    (size) => size.size_code,
  );
  const styles = (stylesResult.data ?? []) as StyleRow[];
  const stored = new Map<string, number | null>();
  for (const row of (sizesResult.data ?? []) as {
    style_id: number;
    size_code: string;
    qty: number | null;
  }[]) {
    stored.set(`${row.style_id}:${row.size_code}`, row.qty);
  }
  const extraCodes = [
    ...new Set(
      ((sizesResult.data ?? []) as { size_code: string }[])
        .map((row) => row.size_code)
        .filter((code) => !columns.includes(code)),
    ),
  ];
  const allColumns = [...columns, ...extraCodes];
  const rows = styles.map((style) => ({
    label: style.garment_description ?? style.style_key,
    qty: Object.fromEntries(
      allColumns.map((code) => [
        code,
        stored.get(`${style.id}:${code}`) ?? null,
      ]),
    ),
  }));
  const totals = gridTotals(allColumns, rows);
  const csv = `/production-orders/${encodeURIComponent(orderNumber)}/sizes/export`;

  return (
    <section className="flex flex-col gap-3">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <h2 className="font-serif text-2xl text-ink">Size grid</h2>
        <div className="flex flex-wrap gap-2 text-sm">
          <a className="inline-flex min-h-11 items-center text-ink" href={csv}>
            Download CSV
          </a>
          <a
            className="inline-flex min-h-11 items-center text-ink"
            href={`${csv}?sheets=1`}
          >
            Export to Google Sheets
          </a>
        </div>
      </div>
      <p className="text-sm text-muted">
        One row per costume. In Google Sheets, choose File, then Import, then
        Upload.
      </p>
      <Link href="/production-orders/sizes" className="text-sm text-ink">
        All orders
      </Link>
      {styles.length === 0 ? (
        <p className="text-sm text-muted">No costumes on this order yet.</p>
      ) : (
        <GridForm
          orderId={orderId}
          orderNumber={orderNumber}
          canEdit={canEdit}
          styles={styles}
          columns={allColumns}
          stored={stored}
          totals={totals}
        />
      )}
      {canEditScale ? (
        <form action={addSizeCode} className="flex flex-col gap-2">
          <input type="hidden" name="orderNumber" value={orderNumber} />
          <label className="text-sm font-medium" htmlFor="new-size">
            Add a size
          </label>
          <input
            id="new-size"
            name="sizeCode"
            required
            placeholder="Size code"
            className="min-h-12 rounded-xl border border-line bg-card px-3"
          />
          <input
            name="sortOrder"
            inputMode="numeric"
            placeholder="Order (blank adds it at the end)"
            className="min-h-12 rounded-xl border border-line bg-card px-3"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium"
          >
            Save size
          </button>
        </form>
      ) : null}
    </section>
  );
}

function GridForm({
  orderId,
  orderNumber,
  canEdit,
  styles,
  columns,
  stored,
  totals,
}: {
  orderId: number;
  orderNumber: string;
  canEdit: boolean;
  styles: StyleRow[];
  columns: string[];
  stored: Map<string, number | null>;
  totals: { rowTotals: number[]; columnTotals: number[]; grand: number };
}) {
  const table = (
    <div className="overflow-x-auto">
      <table className="border-collapse text-sm">
        <thead>
          <tr>
            <th className="sticky left-0 bg-card px-2 py-2 text-left">Style</th>
            {columns.map((code) => (
              <th key={code} className="px-2 py-2 text-left font-medium">
                {code}
              </th>
            ))}
            <th className="px-2 py-2 text-left">Total</th>
          </tr>
        </thead>
        <tbody>
          {styles.map((style, index) => (
            <tr key={style.id} className="border-t border-line">
              <th className="sticky left-0 bg-card px-2 py-2 text-left font-medium">
                {style.garment_description ?? style.style_key}
              </th>
              {columns.map((code) => {
                const qty = stored.get(`${style.id}:${code}`);
                return (
                  <td key={code} className="px-1 py-1">
                    {canEdit ? (
                      <input
                        name={`qty_${style.id}_${code}`}
                        inputMode="numeric"
                        defaultValue={qty ?? ""}
                        aria-label={`${style.garment_description ?? style.style_key} ${code}`}
                        className="h-11 w-16 rounded-lg border border-line bg-card px-2 text-center"
                      />
                    ) : (
                      <span className="inline-flex h-11 w-16 items-center justify-center">
                        {qty ?? ""}
                      </span>
                    )}
                  </td>
                );
              })}
              <td className="px-2 py-2">{totals.rowTotals[index] ?? 0}</td>
            </tr>
          ))}
          <tr className="border-t border-line font-medium">
            <th className="sticky left-0 bg-card px-2 py-2 text-left">Total</th>
            {totals.columnTotals.map((total, index) => (
              <td key={columns[index] ?? index} className="px-2 py-2">
                {total}
              </td>
            ))}
            <td className="px-2 py-2">{totals.grand}</td>
          </tr>
        </tbody>
      </table>
    </div>
  );

  if (!canEdit) return table;
  return (
    <form action={saveOrderSizeGrid} className="flex flex-col gap-3">
      <input type="hidden" name="orderNumber" value={orderNumber} />
      <input type="hidden" name="orderId" value={orderId} />
      {table}
      <button
        type="submit"
        className="min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white"
      >
        Save quantities
      </button>
    </form>
  );
}
