import { Suspense } from "react";
import { FinanceTabs } from "@/components/finances/tabs";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { ownerGate } from "@/app/(workspace)/finances/guard";
import { money } from "@/lib/inventory/format";
import { todayInToronto } from "@/lib/inventory/usage";
import {
  annualized,
  averageMonthlyPayroll,
  monthlyCategorySpend,
  recurringMonthly,
  variableMonthly,
  type Frequency,
} from "@/lib/finances/money";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Finances" };

export default function FinancesPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Overview />
    </Suspense>
  );
}

type CategoryLink = { name: string; excludes_from_totals: boolean };

function categoryOf(
  value: CategoryLink | CategoryLink[] | null,
): CategoryLink | null {
  if (!value) return null;
  return Array.isArray(value) ? (value[0] ?? null) : value;
}

async function Overview() {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const today = todayInToronto();
  const supabase = await createClient();
  const [startupResult, recurringResult, cardResult, payrollResult] =
    await Promise.all([
      supabase
        .from("startup_costs")
        .select(
          "occurred_on, amount_cad, hst_cad, finance_categories(name, excludes_from_totals)",
        )
        .is("archived_at", null),
      supabase
        .from("recurring_costs")
        .select(
          "amount_cad, hst_cad, frequency, start_date, end_date, finance_categories(name, excludes_from_totals)",
        )
        .is("archived_at", null),
      supabase
        .from("card_transactions")
        .select(
          "transaction_date, amount_cad, hst_cad, excluded, is_startup, finance_categories(name, excludes_from_totals)",
        )
        .is("archived_at", null),
      supabase
        .from("payroll_actuals")
        .select(
          "period_start, period_end, gross_cad, employer_cpp_cad, employer_ei_cad",
        )
        .is("archived_at", null),
    ]);
  const startup = (startupResult.data ?? []) as {
    occurred_on: string;
    amount_cad: number | string;
    hst_cad: number | string;
    finance_categories: CategoryLink | CategoryLink[] | null;
  }[];
  const startupPretax = startup.reduce((sum, row) => {
    const category = categoryOf(row.finance_categories);
    if (category?.excludes_from_totals) return sum;
    return sum + Number(row.amount_cad);
  }, 0);
  const startupHst = startup.reduce((sum, row) => {
    const category = categoryOf(row.finance_categories);
    if (category?.excludes_from_totals) return sum;
    return sum + Number(row.hst_cad);
  }, 0);
  const recurring = recurringMonthly(
    (
      (recurringResult.data ?? []) as {
        amount_cad: number | string;
        hst_cad: number | string;
        frequency: Frequency;
        start_date: string;
        end_date: string | null;
        finance_categories: CategoryLink | CategoryLink[] | null;
      }[]
    ).map((row) => ({
      amount: Number(row.amount_cad),
      hst: Number(row.hst_cad),
      frequency: row.frequency,
      start: row.start_date,
      end: row.end_date,
      excluded: Boolean(
        categoryOf(row.finance_categories)?.excludes_from_totals,
      ),
    })),
    today,
  );
  const cards = (cardResult.data ?? []) as {
    transaction_date: string;
    amount_cad: number | string;
    hst_cad: number | string;
    excluded: boolean;
    is_startup: boolean;
    finance_categories: CategoryLink | CategoryLink[] | null;
  }[];
  const variable = variableMonthly(
    cards.map((row) => ({
      date: row.transaction_date,
      amount: Number(row.amount_cad),
      hst: Number(row.hst_cad),
      excluded: row.excluded,
      startup: row.is_startup,
      categoryExcluded: Boolean(
        categoryOf(row.finance_categories)?.excludes_from_totals,
      ),
    })),
    today,
  );
  const payroll = averageMonthlyPayroll(
    (
      (payrollResult.data ?? []) as {
        period_start: string;
        period_end: string;
        gross_cad: number | string;
        employer_cpp_cad: number | string;
        employer_ei_cad: number | string;
      }[]
    ).map((row) => ({
      start: row.period_start,
      end: row.period_end,
      gross: Number(row.gross_cad),
      cpp: Number(row.employer_cpp_cad),
      ei: Number(row.employer_ei_cad),
    })),
  );
  const monthly = recurring.pretax + variable.pretax + payroll;
  const chart = monthlyCategorySpend([
    ...startup.map((row) => ({
      month: row.occurred_on.slice(0, 7),
      category: categoryOf(row.finance_categories)?.name ?? "Uncategorized",
      pretax: Number(row.amount_cad),
      hst: Number(row.hst_cad),
      excluded: Boolean(
        categoryOf(row.finance_categories)?.excludes_from_totals,
      ),
    })),
    ...cards
      .filter((row) => !row.is_startup && !row.excluded)
      .map((row) => ({
        month: row.transaction_date.slice(0, 7),
        category: categoryOf(row.finance_categories)?.name ?? "Uncategorized",
        pretax: Number(row.amount_cad),
        hst: Number(row.hst_cad),
        excluded: Boolean(
          categoryOf(row.finance_categories)?.excludes_from_totals,
        ),
      })),
  ]);
  const widest = Math.max(1, ...chart.map((month) => month.pretax));

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Finances</h1>
      <FinanceTabs current="overview" />
      <p className="text-sm text-muted">
        Amounts are CAD. Pre-tax and HST are separate. Not a Design Studio cost
        is left out.
      </p>
      <section className="grid gap-3 sm:grid-cols-2">
        <figure className="rounded-2xl border border-line bg-card p-4">
          <figcaption className="text-sm text-muted">
            Startup, pre-tax
          </figcaption>
          <p className="font-serif text-3xl text-ink">{money(startupPretax)}</p>
          <p className="text-sm text-muted">HST {money(startupHst)}</p>
        </figure>
        <figure className="rounded-2xl border border-line bg-card p-4">
          <figcaption className="text-sm text-muted">
            Monthly run rate, pre-tax
          </figcaption>
          <p className="font-serif text-3xl text-ink">{money(monthly)}</p>
          <p className="text-sm text-muted">
            Recurring {money(recurring.pretax)} · Payroll {money(payroll)} ·
            Card average {money(variable.pretax)}
          </p>
          <p className="text-sm text-muted">
            HST about {money(recurring.hst + variable.hst)} a month
          </p>
        </figure>
        <figure className="rounded-2xl border border-line bg-card p-4">
          <figcaption className="text-sm text-muted">
            Annualized run rate, pre-tax
          </figcaption>
          <p className="font-serif text-3xl text-ink">
            {money(annualized(monthly))}
          </p>
        </figure>
        <figure className="rounded-2xl border border-line bg-card p-4">
          <figcaption className="text-sm text-muted">
            Startup beside a year of running costs
          </figcaption>
          <p className="text-sm text-ink">
            Startup {money(startupPretax)} · One year of run rate{" "}
            {money(annualized(monthly))}
          </p>
        </figure>
      </section>
      <section className="flex flex-col gap-3">
        <h2 className="font-serif text-2xl text-ink">
          Monthly spend by category
        </h2>
        {chart.length === 0 ? (
          <p className="text-sm text-muted">No spend recorded yet.</p>
        ) : (
          chart.map((month) => (
            <div key={month.month} className="flex flex-col gap-1">
              <p className="text-sm font-medium text-ink">
                {month.month} · {money(month.pretax)} pre-tax · HST{" "}
                {money(month.hst)}
              </p>
              {month.byCategory.map((category) => (
                <div
                  key={category.category}
                  className="flex items-center gap-2 text-sm"
                >
                  <span className="w-40 shrink-0 text-muted">
                    {category.category}
                  </span>
                  <span
                    className="h-3 rounded-full bg-teal"
                    style={{
                      width: `${Math.max(4, (category.pretax / widest) * 100)}%`,
                    }}
                  />
                  <span>{money(category.pretax)}</span>
                </div>
              ))}
            </div>
          ))
        )}
      </section>
    </div>
  );
}
