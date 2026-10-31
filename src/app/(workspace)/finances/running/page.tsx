import { Suspense } from "react";
import {
  archiveProductionSeason,
  archiveRecurringCost,
  saveProductionSeason,
  saveRecurringCost,
  saveRunSettings,
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
  monthlyAmount,
  type Frequency,
  type RunMode,
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
  const [
    categoriesResult,
    rowsResult,
    seasonsResult,
    settingsResult,
    peopleResult,
  ] = await Promise.all([
    supabase
      .from("finance_categories")
      .select("id, name")
      .is("archived_at", null)
      .order("sort_order"),
    supabase
      .from("recurring_costs")
      .select(
        "id, name, amount_cad, hst_cad, frequency, runs, start_date, end_date, notes, finance_categories(name)",
      )
      .is("archived_at", null)
      .order("name"),
    supabase
      .from("production_seasons")
      .select("id, name, start_date, end_date")
      .is("archived_at", null)
      .order("start_date"),
    supabase
      .from("finance_run_settings")
      .select("payroll_runs, variable_spend_runs")
      .eq("id", true)
      .maybeSingle(),
    supabase
      .from("profiles")
      .select("id, full_name")
      .eq("employment_type", "contractor")
      .eq("is_active", true)
      .order("full_name"),
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
    runs: RunMode | null;
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
  const seasons = (seasonsResult.data ?? []) as {
    id: number;
    name: string;
    start_date: string;
    end_date: string;
  }[];
  const settings = settingsResult.data as {
    payroll_runs: RunMode;
    variable_spend_runs: RunMode;
  } | null;

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Running costs</h1>
      <FinanceTabs current="running" />
      {notice === "saved" ? <StatusNote>Saved.</StatusNote> : null}
      {notice === "failed" ? (
        <StatusNote tone="error">That did not save.</StatusNote>
      ) : null}
      <p className="text-sm text-ink">
        A full production month of these lines is {money(month)} pre-tax. HST is{" "}
        {money(monthHst)}. Production-only lines, payroll, and the card average
        are charged only on days inside a season. WSIB follows payroll.
      </p>
      <section className="flex flex-col gap-2">
        <h2 className="font-serif text-2xl text-ink">Production seasons</h2>
        {seasons.length === 0 ? (
          <p className="text-sm text-muted">No seasons entered yet.</p>
        ) : (
          seasons.map((season) => (
            <div
              key={season.id}
              className="flex items-center justify-between gap-3 text-sm"
            >
              <p>
                {season.name} · {season.start_date} to {season.end_date}
              </p>
              <form action={archiveProductionSeason}>
                <input type="hidden" name="id" value={season.id} />
                <button type="submit" className="min-h-11 font-medium">
                  Archive
                </button>
              </form>
            </div>
          ))
        )}
        <form action={saveProductionSeason} className="flex flex-col gap-2">
          <input
            name="name"
            required
            placeholder="Season name"
            className="min-h-12 rounded-xl border border-line bg-card px-3"
          />
          <input
            name="startDate"
            type="date"
            required
            className="min-h-12 rounded-xl border border-line bg-card px-3"
          />
          <input
            name="endDate"
            type="date"
            required
            className="min-h-12 rounded-xl border border-line bg-card px-3"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium"
          >
            Add season
          </button>
        </form>
      </section>
      <form
        action={saveRunSettings}
        className="flex flex-col gap-2 rounded-2xl border border-line bg-card p-4"
      >
        <h2 className="font-serif text-2xl">Payroll and card spend</h2>
        <label className="text-sm font-medium" htmlFor="payrollRuns">
          Payroll
        </label>
        <select
          id="payrollRuns"
          name="payrollRuns"
          defaultValue={settings?.payroll_runs ?? "production_only"}
          className="min-h-12 rounded-xl border border-line px-3"
        >
          <option value="production_only">Production only</option>
          <option value="year_round">Year-round</option>
        </select>
        <label className="text-sm font-medium" htmlFor="variableRuns">
          Card spend average
        </label>
        <select
          id="variableRuns"
          name="variableRuns"
          defaultValue={settings?.variable_spend_runs ?? "production_only"}
          className="min-h-12 rounded-xl border border-line px-3"
        >
          <option value="production_only">Production only</option>
          <option value="year_round">Year-round</option>
        </select>
        <p className="text-sm text-muted">WSIB uses the payroll setting.</p>
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white"
        >
          Save
        </button>
      </form>
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
        <label className="text-sm font-medium" htmlFor="contractorId">
          Contractor, if this line is their retainer
        </label>
        <select
          id="contractorId"
          name="contractorId"
          className="min-h-12 rounded-xl border border-line px-3"
          defaultValue=""
        >
          <option value="">Not linked</option>
          {(
            (peopleResult.data ?? []) as { id: string; full_name: string }[]
          ).map((person) => (
            <option key={person.id} value={person.id}>
              {person.full_name}
            </option>
          ))}
        </select>
        <label className="text-sm font-medium" htmlFor="runs">
          Runs
        </label>
        <select
          id="runs"
          name="runs"
          defaultValue="year_round"
          className="min-h-12 rounded-xl border border-line px-3"
        >
          <option value="year_round">Year-round</option>
          <option value="production_only">Production only</option>
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
              full month ·{" "}
              {categoryLabel(row.finance_categories) === "WSIB"
                ? "follows payroll"
                : row.runs === "production_only"
                  ? "production only"
                  : "year-round"}
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
