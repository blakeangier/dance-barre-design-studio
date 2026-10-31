import { Suspense } from "react";
import { FinanceTabs } from "@/components/finances/tabs";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { ownerGate } from "@/app/(workspace)/finances/guard";
import { money } from "@/lib/inventory/format";
import { todayInToronto } from "@/lib/inventory/usage";
import {
  averageMonthlyPayroll,
  contractProgress,
  monthlyAmount,
  monthlyCategorySpend,
  projectRunningYear,
  recurringCoveredByContract,
  startupSummary,
  variableMonthly,
  type RunMode,
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
  const [
    startupResult,
    recurringResult,
    cardResult,
    payrollResult,
    seasonResult,
    settingsResult,
    contractResult,
    paymentResult,
  ] = await Promise.all([
    supabase
      .from("startup_costs")
      .select(
        "occurred_on, amount_cad, hst_cad, source, finance_categories(name, excludes_from_totals)",
      )
      .is("archived_at", null),
    supabase
      .from("recurring_costs")
      .select(
        "amount_cad, hst_cad, frequency, runs, contractor_profile_id, start_date, end_date, finance_categories(name, excludes_from_totals)",
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
    supabase
      .from("production_seasons")
      .select("start_date, end_date")
      .is("archived_at", null),
    supabase
      .from("finance_run_settings")
      .select("payroll_runs, variable_spend_runs")
      .eq("id", true)
      .maybeSingle(),
    supabase
      .from("contractor_contracts")
      .select(
        "id, contractor_id, total_amount_cad, hst_amount_cad, start_date, end_date, payout",
      )
      .is("archived_at", null),
    supabase
      .from("contractor_payments")
      .select("contract_id, paid_on, amount_cad, hst_cad")
      .is("archived_at", null),
  ]);
  const startup = (startupResult.data ?? []) as {
    occurred_on: string | null;
    amount_cad: number | string;
    hst_cad: number | string;
    source: string;
    finance_categories: CategoryLink | CategoryLink[] | null;
  }[];
  const recurringRows = (
    (recurringResult.data ?? []) as {
      amount_cad: number | string;
      hst_cad: number | string;
      frequency: Frequency;
      runs: RunMode | null;
      contractor_profile_id: string | null;
      start_date: string;
      end_date: string | null;
      finance_categories: CategoryLink | CategoryLink[] | null;
    }[]
  ).filter(
    (row) =>
      row.start_date <= today &&
      (row.end_date === null || row.end_date >= today) &&
      !categoryOf(row.finance_categories)?.excludes_from_totals &&
      !recurringCoveredByContract(
        row.contractor_profile_id,
        new Set(
          ((contractResult.data ?? []) as { contractor_id: string }[]).map(
            (contract) => contract.contractor_id,
          ),
        ),
      ),
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
  const startupLines = [
    ...startup.map((row) => ({
      category: categoryOf(row.finance_categories)?.name ?? "Uncategorized",
      pretax: Number(row.amount_cad),
      hst: Number(row.hst_cad),
      source:
        row.source === "card_statement"
          ? ("card" as const)
          : ("manual" as const),
      excluded: Boolean(
        categoryOf(row.finance_categories)?.excludes_from_totals,
      ),
    })),
    ...cards
      .filter((row) => row.is_startup)
      .map((row) => ({
        category: categoryOf(row.finance_categories)?.name ?? "Uncategorized",
        pretax: Number(row.amount_cad),
        hst: Number(row.hst_cad),
        source: "card" as const,
        excluded:
          row.excluded ||
          Boolean(categoryOf(row.finance_categories)?.excludes_from_totals),
      })),
  ];
  const startupTotal = startupSummary(startupLines);
  const runSettings = settingsResult.data as {
    payroll_runs: RunMode;
    variable_spend_runs: RunMode;
  } | null;
  const projection = projectRunningYear({
    today,
    recurring: recurringRows.map((row) => ({
      monthlyPretax: monthlyAmount(Number(row.amount_cad), row.frequency),
      monthlyHst: monthlyAmount(Number(row.hst_cad), row.frequency),
      runs: row.runs === "production_only" ? "production_only" : "year_round",
      category: categoryOf(row.finance_categories)?.name ?? "Uncategorized",
    })),
    payrollMonthly: payroll,
    payrollRuns:
      runSettings?.payroll_runs === "year_round"
        ? "year_round"
        : "production_only",
    variableMonthly: variable.pretax,
    variableHstMonthly: variable.hst,
    variableRuns:
      runSettings?.variable_spend_runs === "year_round"
        ? "year_round"
        : "production_only",
    seasons: (
      (seasonResult.data ?? []) as { start_date: string; end_date: string }[]
    ).map((season) => ({ start: season.start_date, end: season.end_date })),
    contracts: (
      (contractResult.data ?? []) as {
        id: number;
        total_amount_cad: number | string;
        hst_amount_cad: number | string;
        start_date: string;
        end_date: string;
        payout: "spread" | "lump_sums";
      }[]
    ).map((contract) => {
      const payments = (
        (paymentResult.data ?? []) as {
          contract_id: number;
          paid_on: string | null;
          amount_cad: number | string;
          hst_cad: number | string;
        }[]
      ).filter((payment) => payment.contract_id === contract.id);
      const progress = contractProgress(
        Number(contract.total_amount_cad),
        Number(contract.hst_amount_cad),
        payments.map((payment) => ({
          paidOn: payment.paid_on,
          amount: Number(payment.amount_cad),
          hst: Number(payment.hst_cad),
        })),
        today,
      );
      return {
        start: contract.start_date,
        end: contract.end_date,
        payout: contract.payout,
        remainingPretax: progress.remaining,
        remainingHst: progress.remainingHst,
        futurePayments: payments.flatMap((payment) =>
          payment.paid_on && payment.paid_on > today
            ? [
                {
                  date: payment.paid_on,
                  pretax: Number(payment.amount_cad),
                  hst: Number(payment.hst_cad),
                },
              ]
            : [],
        ),
      };
    }),
  });
  const chart = monthlyCategorySpend([
    ...startup.flatMap((row) => {
      if (!row.occurred_on) return [];
      return [
        {
          month: row.occurred_on.slice(0, 7),
          category: categoryOf(row.finance_categories)?.name ?? "Uncategorized",
          pretax: Number(row.amount_cad),
          hst: Number(row.hst_cad),
          excluded: Boolean(
            categoryOf(row.finance_categories)?.excludes_from_totals,
          ),
          startup: false,
        },
      ];
    }),
    ...cards
      .filter((row) => !row.excluded)
      .map((row) => ({
        month: row.transaction_date.slice(0, 7),
        category: categoryOf(row.finance_categories)?.name ?? "Uncategorized",
        pretax: Number(row.amount_cad),
        hst: Number(row.hst_cad),
        excluded: Boolean(
          categoryOf(row.finance_categories)?.excludes_from_totals,
        ),
        startup: row.is_startup,
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
          <p className="font-serif text-3xl text-ink">
            {money(startupTotal.pretax)}
          </p>
          <p className="text-sm text-muted">HST {money(startupTotal.hst)}</p>
          <p className="text-sm text-muted">
            Manual {money(startupTotal.manual)} · Card{" "}
            {money(startupTotal.card)}
          </p>
          <ul className="mt-2 flex flex-col gap-1 text-sm">
            {startupTotal.byCategory.map((category) => (
              <li key={category.category}>
                {category.category} · {money(category.pretax)}
                {category.manual > 0
                  ? ` · manual ${money(category.manual)}`
                  : ""}
                {category.card > 0 ? ` · card ${money(category.card)}` : ""}
              </li>
            ))}
          </ul>
        </figure>
        <figure className="rounded-2xl border border-line bg-card p-4">
          <figcaption className="text-sm text-muted">
            Cost per production month, pre-tax
          </figcaption>
          <p className="font-serif text-3xl text-ink">
            {money(projection.costPerProductionMonth)}
          </p>
          <p className="text-sm text-muted">
            HST {money(projection.costPerProductionMonthHst)} in a full
            production month. Payroll {money(payroll)} · card average{" "}
            {money(variable.pretax)}. Those two default to production days only.
          </p>
        </figure>
        <figure className="rounded-2xl border border-line bg-card p-4">
          <figcaption className="text-sm text-muted">
            Next 12 months, pre-tax
          </figcaption>
          <p className="font-serif text-3xl text-ink">
            {money(projection.yearPretax)}
          </p>
          <p className="text-sm text-muted">
            In season {money(projection.seasonPretax)} · Off season{" "}
            {money(projection.offSeasonPretax)}
          </p>
        </figure>
        <figure className="rounded-2xl border border-line bg-card p-4">
          <figcaption className="text-sm text-muted">
            Startup beside the next year of running costs
          </figcaption>
          <p className="text-sm text-ink">
            Startup {money(startupTotal.pretax)} · Projected running cost{" "}
            {money(projection.yearPretax)}
          </p>
        </figure>
      </section>
      <section className="flex flex-col gap-3">
        <h2 className="font-serif text-2xl text-ink">Next 12 months</h2>
        <ul className="flex flex-col gap-1 text-sm">
          {projection.months.map((month) => (
            <li key={month.month}>
              {month.month} · {money(month.pretax)} · {month.productionDays} of{" "}
              {month.days} production days
            </li>
          ))}
        </ul>
        <h2 className="font-serif text-2xl text-ink">
          Monthly spend by category
        </h2>
        <p className="text-sm text-muted">
          Every card line is here unless it is excluded. Startup charges are
          marked. A startup estimate with no date stays in the startup total and
          is not placed in a month. The run-rate card average still leaves
          startup charges out.
        </p>
        {chart.length === 0 ? (
          <p className="text-sm text-muted">No spend recorded yet.</p>
        ) : (
          chart.map((month) => (
            <div key={month.month} className="flex flex-col gap-1">
              <p className="text-sm font-medium text-ink">
                {month.month} · {money(month.pretax)} pre-tax · HST{" "}
                {money(month.hst)}
              </p>
              {month.byCategory.map((category) => {
                const running = category.pretax - category.startupPretax;
                return (
                  <div
                    key={category.category}
                    className="flex items-center gap-2 text-sm"
                  >
                    <span className="w-40 shrink-0 text-muted">
                      {category.category}
                    </span>
                    {running > 0 ? (
                      <span
                        className="h-3 rounded-full bg-teal"
                        style={{
                          width: `${Math.max(4, (running / widest) * 100)}%`,
                        }}
                      />
                    ) : null}
                    {category.startupPretax > 0 ? (
                      <span
                        className="h-3 rounded-full bg-orange"
                        style={{
                          width: `${Math.max(4, (category.startupPretax / widest) * 100)}%`,
                        }}
                      />
                    ) : null}
                    <span>
                      {money(category.pretax)}
                      {category.startupPretax > 0 ? " · startup" : ""}
                    </span>
                  </div>
                );
              })}
            </div>
          ))
        )}
      </section>
    </div>
  );
}
