import { Suspense } from "react";
import { updateCardTransaction } from "@/app/(workspace)/finances/actions";
import { ownerGate } from "@/app/(workspace)/finances/guard";
import { FinanceTabs } from "@/components/finances/tabs";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { firstQueryValue } from "@/lib/auth/notices";
import { money } from "@/lib/inventory/format";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Card transactions" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function CardsPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Cards searchParams={props.searchParams} />
    </Suspense>
  );
}

async function Cards({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const params = await searchParams;
  const notice = firstQueryValue(params.notice);
  const category = firstQueryValue(params.category) ?? "";
  const statement = firstQueryValue(params.statement) ?? "";
  const supabase = await createClient();
  const categoriesResult = await supabase
    .from("finance_categories")
    .select("id, name")
    .is("archived_at", null)
    .order("sort_order");
  let query = supabase
    .from("card_transactions")
    .select(
      "id, statement_period, transaction_date, merchant, amount_cad, hst_cad, original_currency, original_amount, category_id, notes, source_note, is_startup, excluded, purchase_line_id",
    )
    .is("archived_at", null)
    .order("transaction_date", { ascending: false })
    .limit(200);
  if (category) query = query.eq("category_id", Number(category));
  if (statement) query = query.eq("statement_period", statement);
  const rowsResult = await query;
  const categories = (categoriesResult.data ?? []) as {
    id: number;
    name: string;
  }[];
  const rows = (rowsResult.data ?? []) as {
    id: number;
    statement_period: string | null;
    transaction_date: string;
    merchant: string;
    amount_cad: number | string;
    hst_cad: number | string;
    original_currency: string;
    original_amount: number | string | null;
    category_id: number | null;
    notes: string | null;
    source_note: string;
    is_startup: boolean;
    excluded: boolean;
    purchase_line_id: number | null;
  }[];
  const statements = [
    ...new Set(
      rows
        .map((row) => row.statement_period)
        .filter((value): value is string => Boolean(value)),
    ),
  ];

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Card transactions</h1>
      <FinanceTabs />
      {notice === "saved" ? <StatusNote>Saved.</StatusNote> : null}
      {notice === "failed" ? (
        <StatusNote tone="error">
          That file or change did not save. Check the header and category names.
        </StatusNote>
      ) : null}
      <p className="text-sm text-muted">
        CSV columns: date, merchant, amount_cad, category, note. Amount is
        pre-tax CAD. HST can be added after import.
      </p>
      <form
        action="/finances/cards/import"
        method="post"
        encType="multipart/form-data"
        className="flex flex-col gap-2 rounded-2xl border border-line bg-card p-4"
      >
        <label className="text-sm font-medium" htmlFor="statementPeriod">
          Statement period
        </label>
        <input
          id="statementPeriod"
          name="statementPeriod"
          placeholder="2026-10"
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <label className="flex min-h-11 items-center gap-2 text-sm">
          <input type="checkbox" name="isStartup" />
          These lines are startup costs
        </label>
        <input
          name="file"
          type="file"
          accept=".csv,text/csv"
          required
          className="text-sm"
        />
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
        >
          Import CSV
        </button>
      </form>
      <form className="grid gap-2 sm:grid-cols-2" method="get">
        <select
          name="category"
          defaultValue={category}
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <option value="">Every category</option>
          {categories.map((item) => (
            <option key={item.id} value={item.id}>
              {item.name}
            </option>
          ))}
        </select>
        <select
          name="statement"
          defaultValue={statement}
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <option value="">Every statement</option>
          {statements.map((item) => (
            <option key={item} value={item}>
              {item}
            </option>
          ))}
        </select>
        <button
          type="submit"
          className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium"
        >
          Filter
        </button>
      </form>
      <ul className="flex flex-col gap-3">
        {rows.map((row) => (
          <li
            key={row.id}
            className="rounded-2xl border border-line bg-card p-3 text-sm"
          >
            <p className="font-medium text-ink">
              {row.transaction_date} · {row.merchant}
            </p>
            <p className="text-muted">
              {money(Number(row.amount_cad))} pre-tax
              {row.original_currency !== "CAD"
                ? ` · ${row.original_amount ?? ""} ${row.original_currency}`
                : ""}
              {row.statement_period ? ` · ${row.statement_period}` : ""}
            </p>
            <form
              action={updateCardTransaction}
              className="mt-2 flex flex-col gap-2"
            >
              <input type="hidden" name="id" value={row.id} />
              <select
                name="categoryId"
                defaultValue={row.category_id ?? ""}
                className="min-h-12 rounded-xl border border-line px-3"
              >
                <option value="">No category</option>
                {categories.map((item) => (
                  <option key={item.id} value={item.id}>
                    {item.name}
                  </option>
                ))}
              </select>
              <input
                name="hstCad"
                inputMode="decimal"
                defaultValue={row.hst_cad}
                placeholder="HST CAD"
                className="min-h-12 rounded-xl border border-line px-3"
              />
              <input
                name="notes"
                defaultValue={row.notes ?? ""}
                placeholder="Note"
                className="min-h-12 rounded-xl border border-line px-3"
              />
              <input
                name="sourceNote"
                defaultValue={row.source_note ?? ""}
                placeholder="Source"
                className="min-h-12 rounded-xl border border-line px-3"
              />
              <input
                name="purchaseLineId"
                defaultValue={row.purchase_line_id ?? ""}
                placeholder="Purchase line id"
                className="min-h-12 rounded-xl border border-line px-3"
              />
              <label className="flex min-h-11 items-center gap-2">
                <input
                  type="checkbox"
                  name="isStartup"
                  defaultChecked={row.is_startup}
                />
                Startup
              </label>
              <label className="flex min-h-11 items-center gap-2">
                <input
                  type="checkbox"
                  name="excluded"
                  defaultChecked={row.excluded}
                />
                Excluded from totals
              </label>
              <button type="submit" className="min-h-11 text-sm font-medium">
                Save line
              </button>
            </form>
          </li>
        ))}
      </ul>
    </div>
  );
}
