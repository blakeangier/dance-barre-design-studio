import { Suspense } from "react";
import {
  archiveRecurringCost,
  saveRecurringCost,
} from "@/app/(workspace)/finances/actions";
import { ownerGate } from "@/app/(workspace)/finances/guard";
import { FinanceTabs } from "@/components/finances/tabs";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { firstQueryValue } from "@/lib/auth/notices";
import { money } from "@/lib/inventory/format";
import { todayInToronto } from "@/lib/inventory/usage";
import {
  annualized,
  monthlyAmount,
  type Frequency,
} from "@/lib/finances/money";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Running costs" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function RunningPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Running searchParams={props.searchParams} />
    </Suspense>
  );
}

async function Running({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const notice = firstQueryValue((await searchParams).notice);
  const today = todayInToronto();
  const supabase = await createClient();
  const [categoriesResult, rowsResult] = await Promise.all([
    supabase
      .from("finance_categories")
      .select("id, name")
      .is("archived_at", null)
      .order("sort_order"),
    supabase
      .from("recurring_costs")
      .select(
        "id, name, amount_cad, hst_cad, frequency, start_date, end_date, notes, finance_categories(name)",
      )
      .is("archived_at", null)
      .order("name"),
  ]);
  const categories = (categoriesResult.data ?? []) as {
    id: number;
    name: string;
  }[];
  const rows = (rowsResult.data ?? []) as {
    id: number;
    name: string;
    amount_cad: number | string;
    hst_cad: number | string;
    frequency: Frequency;
    start_date: string;
    end_date: string | null;
    notes: string | null;
    finance_categories: { name: string } | { name: string }[] | null;
  }[];
  const active = rows.filter(
    (row) =>
      row.start_date <= today &&
      (row.end_date === null || row.end_date >= today),
  );
  const month = active.reduce(
    (sum, row) => sum + monthlyAmount(Number(row.amount_cad), row.frequency),
    0,
  );
  const monthHst = active.reduce(
    (sum, row) => sum + monthlyAmount(Number(row.hst_cad), row.frequency),
    0,
  );

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Running costs</h1>
      <FinanceTabs current="running" />
      {notice === "saved" ? <StatusNote>Saved.</StatusNote> : null}
      {notice === "failed" ? (
        <StatusNote tone="error">That did not save.</StatusNote>
      ) : null}
      <p className="text-sm text-ink">
        Active lines are {money(month)} a month pre-tax,{" "}
        {money(annualized(month))} a year. HST is {money(monthHst)} a month.
      </p>
      <form
        action={saveRecurringCost}
        className="flex flex-col gap-2 rounded-2xl border border-line bg-card p-4"
      >
        <h2 className="font-serif text-2xl">Add a recurring cost</h2>
        <input
          name="name"
          required
          placeholder="Name"
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
          name="frequency"
          className="min-h-12 rounded-xl border border-line px-3"
          defaultValue="monthly"
        >
          <option value="monthly">Monthly</option>
          <option value="quarterly">Quarterly</option>
          <option value="yearly">Yearly</option>
          <option value="bi-weekly">Bi-weekly</option>
          <option value="per_pay_period">Per pay period</option>
        </select>
        <input
          name="startDate"
          type="date"
          required
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <input
          name="endDate"
          type="date"
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
          Save
        </button>
      </form>
      <ul className="flex flex-col gap-2">
        {rows.map((row) => (
          <li
            key={row.id}
            className="rounded-2xl border border-line bg-card p-3 text-sm"
          >
            <p className="font-medium text-ink">
              {row.name} · {categoryLabel(row.finance_categories)}
            </p>
            <p className="text-muted">
              {money(Number(row.amount_cad))} pre-tax · HST{" "}
              {money(Number(row.hst_cad))} · {row.frequency} ·{" "}
              {money(monthlyAmount(Number(row.amount_cad), row.frequency))} a
              month
            </p>
            <p className="text-muted">
              {row.start_date}
              {row.end_date ? ` to ${row.end_date}` : " onward"}
            </p>
            {row.notes ? <p>{row.notes}</p> : null}
            <form action={archiveRecurringCost}>
              <input type="hidden" name="id" value={row.id} />
              <button type="submit" className="min-h-11 text-sm font-medium">
                Archive
              </button>
            </form>
          </li>
        ))}
      </ul>
    </div>
  );
}

function categoryLabel(
  value: { name: string } | { name: string }[] | null,
): string {
  if (!value) return "Uncategorized";
  return Array.isArray(value)
    ? (value[0]?.name ?? "Uncategorized")
    : value.name;
}
