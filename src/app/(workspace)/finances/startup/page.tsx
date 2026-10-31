import { Suspense } from "react";
import {
  archiveStartupCost,
  saveStartupCost,
} from "@/app/(workspace)/finances/actions";
import { ownerGate } from "@/app/(workspace)/finances/guard";
import { FinanceTabs } from "@/components/finances/tabs";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { firstQueryValue } from "@/lib/auth/notices";
import { money } from "@/lib/inventory/format";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Startup costs" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function StartupPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Startup searchParams={props.searchParams} />
    </Suspense>
  );
}

type Category = { id: number; name: string };

async function Startup({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const notice = firstQueryValue((await searchParams).notice);
  const supabase = await createClient();
  const [categoriesResult, rowsResult] = await Promise.all([
    supabase
      .from("finance_categories")
      .select("id, name")
      .is("archived_at", null)
      .order("sort_order"),
    supabase
      .from("startup_costs")
      .select(
        "id, occurred_on, description, vendor, category_id, amount_cad, hst_cad, notes, source, source_note, startup_share_percent, finance_categories(name)",
      )
      .is("archived_at", null)
      .order("occurred_on", { ascending: false, nullsFirst: true }),
  ]);
  const categories = (categoriesResult.data ?? []) as Category[];
  const rows = (rowsResult.data ?? []) as {
    id: number;
    occurred_on: string | null;
    description: string;
    vendor: string | null;
    category_id: number;
    amount_cad: number | string;
    hst_cad: number | string;
    notes: string | null;
    source: string;
    source_note: string;
    startup_share_percent: number | string;
    finance_categories: { name: string } | { name: string }[] | null;
  }[];
  const groups = new Map<string, typeof rows>();
  for (const row of rows) {
    const name = categoryName(row.finance_categories);
    groups.set(name, [...(groups.get(name) ?? []), row]);
  }

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Startup costs</h1>
      <FinanceTabs />
      {notice === "saved" ? <StatusNote>Saved.</StatusNote> : null}
      {notice === "failed" ? (
        <StatusNote tone="error">That did not save.</StatusNote>
      ) : null}
      <CostForm categories={categories} />
      {[...groups.entries()].map(([name, lines]) => {
        const subtotal = lines.reduce(
          (sum, line) => sum + Number(line.amount_cad),
          0,
        );
        const hst = lines.reduce((sum, line) => sum + Number(line.hst_cad), 0);
        return (
          <section key={name} className="flex flex-col gap-2">
            <h2 className="font-serif text-2xl text-ink">
              {name} · {money(subtotal)}
            </h2>
            <p className="text-sm text-muted">HST {money(hst)}</p>
            {lines.map((line) => (
              <article
                key={line.id}
                className="rounded-2xl border border-line bg-card p-3 text-sm"
              >
                <p className="font-medium text-ink">
                  {line.occurred_on ?? "Date unknown"} · {line.description}
                </p>
                <p className="text-muted">
                  {line.vendor ?? "No vendor"} ·{" "}
                  {money(Number(line.amount_cad))} pre-tax · HST{" "}
                  {money(Number(line.hst_cad))} · {line.source}
                </p>
                <p className="text-muted">
                  Startup share {line.startup_share_percent}% · Source:{" "}
                  {line.source_note?.trim() ? line.source_note : "Not recorded"}
                </p>
                {line.notes ? <p>{line.notes}</p> : null}
                <form action={archiveStartupCost}>
                  <input type="hidden" name="id" value={line.id} />
                  <button
                    type="submit"
                    className="min-h-11 text-sm font-medium"
                  >
                    Archive
                  </button>
                </form>
              </article>
            ))}
          </section>
        );
      })}
    </div>
  );
}

function categoryName(
  value: { name: string } | { name: string }[] | null,
): string {
  if (!value) return "Uncategorized";
  return Array.isArray(value)
    ? (value[0]?.name ?? "Uncategorized")
    : value.name;
}

function CostForm({ categories }: { categories: Category[] }) {
  return (
    <form
      action={saveStartupCost}
      className="flex flex-col gap-2 rounded-2xl border border-line bg-card p-4"
    >
      <h2 className="font-serif text-2xl text-ink">Add a line</h2>
      <label className="text-sm font-medium" htmlFor="occurredOn">
        Date
      </label>
      <input
        id="occurredOn"
        name="occurredOn"
        type="date"
        className="min-h-12 rounded-xl border border-line px-3"
      />
      <label className="flex min-h-11 items-center gap-2 text-sm">
        <input type="checkbox" name="dateUnknown" />
        Date unknown
      </label>
      <input
        name="description"
        required
        placeholder="Description"
        className="min-h-12 rounded-xl border border-line px-3"
      />
      <input
        name="vendor"
        placeholder="Vendor"
        className="min-h-12 rounded-xl border border-line px-3"
      />
      <select
        name="categoryId"
        required
        className="min-h-12 rounded-xl border border-line px-3"
      >
        {categories.map((category) => (
          <option key={category.id} value={category.id}>
            {category.name}
          </option>
        ))}
      </select>
      <input
        name="amountCad"
        required
        inputMode="decimal"
        placeholder="Pre-tax CAD"
        className="min-h-12 rounded-xl border border-line px-3"
      />
      <input
        name="hstCad"
        inputMode="decimal"
        placeholder="HST CAD"
        className="min-h-12 rounded-xl border border-line px-3"
      />
      <select
        name="source"
        className="min-h-12 rounded-xl border border-line px-3"
      >
        <option value="manual">Manual</option>
        <option value="card_statement">Card statement</option>
      </select>
      <input
        name="startupShare"
        inputMode="decimal"
        placeholder="Startup share %, default 100"
        className="min-h-12 rounded-xl border border-line px-3"
      />
      <input
        name="sourceNote"
        placeholder="Source"
        className="min-h-12 rounded-xl border border-line px-3"
      />
      <textarea
        name="notes"
        placeholder="Notes"
        className="min-h-20 rounded-xl border border-line px-3 py-2"
      />
      <button
        type="submit"
        className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
      >
        Save line
      </button>
    </form>
  );
}
