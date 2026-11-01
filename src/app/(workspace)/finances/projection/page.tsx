import { Suspense } from "react";
import {
  saveProjectionCost,
  saveProjectionMonth,
  saveProjectionPerson,
} from "@/app/(workspace)/finances/workbook-actions";
import { ownerGate } from "@/app/(workspace)/finances/guard";
import {
  ArchiveForm,
  FinanceFrame,
  financeButton,
  financeField,
} from "@/components/finances/frame";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { firstQueryValue } from "@/lib/auth/notices";
import { money } from "@/lib/inventory/format";
import { todayInToronto } from "@/lib/inventory/usage";
import { sourceText } from "@/lib/finances/workbook";
import {
  contractStanding,
  monthIsProduction,
  monthKey,
  nextTwelveMonths,
  otherMonthly,
  projectWorkbook,
  type ProjectionContract,
  type ProjectionOther,
  type ProjectionTeam,
} from "@/lib/finances/workbook";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "12-month projection" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function ProjectionPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Projection searchParams={props.searchParams} />
    </Suspense>
  );
}

function monthLabel(month: string): string {
  return new Intl.DateTimeFormat("en-CA", {
    month: "short",
    year: "numeric",
    timeZone: "UTC",
  }).format(new Date(`${month.slice(0, 10)}T00:00:00Z`));
}

async function Projection({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const notice = firstQueryValue((await searchParams).notice);
  const today = todayInToronto();
  const months = nextTwelveMonths(today);
  const supabase = await createClient();
  const [
    monthResult,
    teamResult,
    costResult,
    contractResult,
    phaseResult,
    paymentResult,
    seasonResult,
  ] = await Promise.all([
    supabase
      .from("finance_projection_months")
      .select("id, month_start, is_production, source_note")
      .is("archived_at", null),
    supabase
      .from("finance_projection_team")
      .select(
        "id, person_name, role_label, pay_kind, hours_per_week, rate, adds_hst, runs, source_note",
      )
      .is("archived_at", null)
      .order("sort_order"),
    supabase
      .from("finance_projection_costs")
      .select("id, label, amount, period, runs, source_note")
      .is("archived_at", null)
      .order("sort_order"),
    supabase
      .from("contractor_contracts")
      .select(
        "id, total_amount_cad, hst_amount_cad, start_date, end_date, source_note, profiles(full_name)",
      )
      .is("archived_at", null),
    supabase
      .from("contractor_contract_phases")
      .select("contract_id, amount_before_hst, hst")
      .is("archived_at", null),
    supabase
      .from("contractor_payments")
      .select("contract_id, paid_on, amount_cad, hst_cad")
      .is("archived_at", null),
    supabase
      .from("production_seasons")
      .select("start_date, end_date")
      .is("archived_at", null),
  ]);
  const overrides = new Map(
    (
      (monthResult.data ?? []) as {
        month_start: string;
        is_production: boolean;
      }[]
    ).map((row) => [monthKey(row.month_start), row.is_production]),
  );
  const seasons = (
    (seasonResult.data ?? []) as { start_date: string; end_date: string }[]
  ).map((row) => ({ start: row.start_date, end: row.end_date }));
  const columns = months.map((month) => ({
    month,
    production: monthIsProduction(
      month,
      seasons,
      overrides.has(monthKey(month))
        ? Boolean(overrides.get(monthKey(month)))
        : null,
    ),
  }));
  const team = (
    (teamResult.data ?? []) as {
      id: number;
      person_name: string;
      role_label: string | null;
      pay_kind: "hourly_weekly" | "fixed_biweekly";
      hours_per_week: number | string | null;
      rate: number | string;
      adds_hst: boolean;
      runs: "every_month" | "production_only";
      source_note: string;
    }[]
  ).map((row) => ({
    id: row.id,
    name: row.person_name,
    role: row.role_label ?? "",
    payKind: row.pay_kind,
    hoursPerWeek:
      row.hours_per_week === null ? null : Number(row.hours_per_week),
    rate: Number(row.rate),
    addsHst: row.adds_hst,
    runs: row.runs,
    sourceNote: row.source_note,
  }));
  const others = (
    (costResult.data ?? []) as {
      id: number;
      label: string;
      amount: number | string;
      period: "month" | "year";
      runs: "every_month" | "production_only";
      source_note: string;
    }[]
  ).map((row) => ({
    id: row.id,
    label: row.label,
    amount: Number(row.amount),
    period: row.period,
    runs: row.runs,
    sourceNote: row.source_note,
  }));
  const phases = (phaseResult.data ?? []) as {
    contract_id: number;
    amount_before_hst: number | string;
    hst: number | string;
  }[];
  const payments = (paymentResult.data ?? []) as {
    contract_id: number;
    paid_on: string | null;
    amount_cad: number | string;
    hst_cad: number | string;
  }[];
  const contracts = (
    (contractResult.data ?? []) as {
      id: number;
      total_amount_cad: number | string;
      hst_amount_cad: number | string;
      start_date: string;
      end_date: string;
      source_note: string;
      profiles: { full_name: string } | { full_name: string }[] | null;
    }[]
  ).map((row) => {
    const standing = contractStanding({
      phases: phases
        .filter((phase) => phase.contract_id === row.id)
        .map((phase) => ({
          beforeHst: Number(phase.amount_before_hst),
          hst: Number(phase.hst),
        })),
      fallbackBeforeHst: Number(row.total_amount_cad),
      fallbackHst: Number(row.hst_amount_cad),
      payments: payments
        .filter((payment) => payment.contract_id === row.id)
        .map((payment) => ({
          amount: Number(payment.amount_cad),
          hst: Number(payment.hst_cad),
          paidOn: payment.paid_on,
        })),
      end: row.end_date,
      today,
    });
    const profile = Array.isArray(row.profiles)
      ? row.profiles[0]
      : row.profiles;
    return {
      label: profile?.full_name || `Contract ${row.id}`,
      remaining: standing.remaining,
      start: row.start_date,
      end: row.end_date,
      sourceNote: row.source_note,
    } satisfies ProjectionContract;
  });
  const grid = projectWorkbook({
    today,
    months: columns,
    team,
    others,
    contracts,
  });

  return (
    <FinanceFrame
      title="12-month projection"
      current="projection"
      notice={notice}
      wide
      lede="A production month is 1. With no seasons stored, Fall is Aug 1–Dec 5 and Spring is Feb 1–Apr 15. An override replaces that month. Monthly pay is the weekly amount times 4.33. HST is 13% when a person adds HST. Contract balances spread over the months left until the contract ends."
    >
      <div className="overflow-x-auto">
        <table className="w-full min-w-[72rem] text-left text-sm">
          <thead>
            <tr className="text-muted">
              <th className="sticky left-0 bg-card py-2 pr-3 font-medium">
                Row
              </th>
              {grid.months.map((column) => (
                <th key={column.month} className="py-2 pr-3 font-medium">
                  {monthLabel(column.month)}
                </th>
              ))}
              <th className="py-2 font-medium">Source</th>
            </tr>
          </thead>
          <tbody>
            <tr className="border-t border-line">
              <th className="sticky left-0 bg-card py-2 pr-3 text-left font-medium">
                Production month
              </th>
              {grid.months.map((column) => (
                <td key={column.month} className="py-2 pr-3">
                  <form
                    action={saveProjectionMonth}
                    className="flex flex-col gap-1"
                  >
                    <input type="hidden" name="month" value={column.month} />
                    <select
                      name="isProduction"
                      defaultValue={column.production ? "1" : "0"}
                      aria-label={`Production month ${monthLabel(column.month)}`}
                      className={financeField}
                    >
                      <option value="1">1</option>
                      <option value="0">0</option>
                    </select>
                    <button
                      type="submit"
                      className="min-h-11 text-xs font-medium"
                    >
                      Save
                    </button>
                  </form>
                </td>
              ))}
              <td className="py-2">Season or override</td>
            </tr>
            {grid.teamRates.map((person, index) => (
              <TeamRow
                key={team[index]?.id ?? person.name}
                person={person}
                id={team[index]?.id ?? 0}
                columns={grid.months}
              />
            ))}
            {grid.contractMonths.map((contract) => (
              <tr key={contract.label} className="border-t border-line">
                <th className="sticky left-0 bg-card py-2 pr-3 text-left font-medium">
                  {contract.label}
                </th>
                {grid.months.map((column) => (
                  <td key={column.month} className="py-2 pr-3">
                    {money(contract.byMonth.get(monthKey(column.month)) ?? 0)}
                  </td>
                ))}
                <td className="py-2">{sourceText(contract.sourceNote)}</td>
              </tr>
            ))}
            {others.map((row) => (
              <OtherRow
                key={row.id}
                row={row}
                columns={grid.months}
                id={row.id}
              />
            ))}
            <tr className="border-t border-line font-medium">
              <th className="sticky left-0 bg-card py-2 pr-3 text-left">
                Cash out
              </th>
              {grid.months.map((column) => (
                <td key={column.month} className="py-2 pr-3">
                  {money(column.total)}
                </td>
              ))}
              <td />
            </tr>
          </tbody>
        </table>
      </div>
      <p className="text-sm text-ink">
        12-month total {money(grid.yearTotal)} · Average month{" "}
        {money(grid.averageMonth)} · Average production month{" "}
        {money(grid.averageProductionMonth)}
      </p>
      <form action={saveProjectionPerson} className="grid gap-2 sm:grid-cols-2">
        <input
          name="personName"
          required
          placeholder="Person"
          className={financeField}
        />
        <input name="roleLabel" placeholder="Role" className={financeField} />
        <select name="payKind" className={financeField}>
          <option value="hourly_weekly">Hours per week</option>
          <option value="fixed_biweekly">Fixed pay per 2 weeks</option>
        </select>
        <input
          name="hoursPerWeek"
          inputMode="decimal"
          placeholder="Hours per week"
          className={financeField}
        />
        <input
          name="rate"
          required
          inputMode="decimal"
          placeholder="Rate"
          className={financeField}
        />
        <select name="runs" className={financeField}>
          <option value="every_month">Every month</option>
          <option value="production_only">Production months only</option>
        </select>
        <label className="flex min-h-11 items-center gap-2 text-sm">
          <input type="checkbox" name="addsHst" />
          Adds HST
        </label>
        <input
          name="sourceNote"
          placeholder="Source"
          className={financeField}
        />
        <button type="submit" className={financeButton}>
          Add person
        </button>
      </form>
      <form action={saveProjectionCost} className="grid gap-2 sm:grid-cols-2">
        <input
          name="label"
          required
          placeholder="Other cost"
          className={financeField}
        />
        <input
          name="amount"
          required
          inputMode="decimal"
          placeholder="Amount"
          className={financeField}
        />
        <select name="period" className={financeField}>
          <option value="month">Per month</option>
          <option value="year">Per year</option>
        </select>
        <select name="runs" className={financeField}>
          <option value="every_month">Every month</option>
          <option value="production_only">Production months only</option>
        </select>
        <input
          name="sourceNote"
          placeholder="Source"
          className={financeField}
        />
        <button type="submit" className={financeButton}>
          Add other cost
        </button>
      </form>
    </FinanceFrame>
  );
}

function TeamRow({
  person,
  id,
  columns,
}: {
  person: ProjectionTeam & { monthly: { total: number } };
  id: number;
  columns: { month: string; production: boolean }[];
}) {
  return (
    <tr className="border-t border-line">
      <th className="sticky left-0 bg-card py-2 pr-3 text-left font-medium">
        {person.name}
        <span className="block font-normal text-muted">
          {person.role || "Role not recorded"} ·{" "}
          {person.payKind === "hourly_weekly"
            ? `${person.hoursPerWeek ?? 0} h/week`
            : "Fixed / 2 weeks"}{" "}
          · {money(person.rate)}
          {person.addsHst ? " · HST" : ""}
        </span>
        <ArchiveForm
          table="finance_projection_team"
          id={id}
          back="/finances/projection"
        />
      </th>
      {columns.map((column) => (
        <td key={column.month} className="py-2 pr-3">
          {person.runs === "production_only" && !column.production
            ? money(0)
            : money(person.monthly.total)}
        </td>
      ))}
      <td className="py-2">{sourceText(person.sourceNote)}</td>
    </tr>
  );
}

function OtherRow({
  row,
  columns,
  id,
}: {
  row: ProjectionOther;
  columns: { month: string; production: boolean }[];
  id: number;
}) {
  return (
    <tr className="border-t border-line">
      <th className="sticky left-0 bg-card py-2 pr-3 text-left font-medium">
        {row.label}
        <span className="block font-normal text-muted">
          {money(row.amount)} per {row.period === "year" ? "year" : "month"} ·{" "}
          {row.runs === "production_only" ? "Production only" : "Every month"}
        </span>
        <ArchiveForm
          table="finance_projection_costs"
          id={id}
          back="/finances/projection"
        />
      </th>
      {columns.map((column) => (
        <td key={column.month} className="py-2 pr-3">
          {money(otherMonthly(row, column.production))}
        </td>
      ))}
      <td className="py-2">{sourceText(row.sourceNote)}</td>
    </tr>
  );
}
