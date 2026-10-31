import { Suspense } from "react";
import {
  archivePayrollActual,
  savePayrollActual,
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
  currentBiweeklyPeriod,
  employeeGross,
  monthlyAmount,
  rateOn,
  workedHours,
  type Frequency,
} from "@/lib/finances/money";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Payroll" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function PayrollPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Payroll searchParams={props.searchParams} />
    </Suspense>
  );
}

type Actual = {
  id: number;
  period_start: string;
  period_end: string;
  gross_cad: number | string;
  employer_cpp_cad: number | string;
  employer_ei_cad: number | string;
  notes: string | null;
};

async function Payroll({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const notice = firstQueryValue((await searchParams).notice);
  const today = todayInToronto();
  const period = currentBiweeklyPeriod(today);
  const month = today.slice(0, 7);
  const year = today.slice(0, 4);
  const supabase = await createClient();
  const [actualsResult, contractorsResult, sheetsResult] = await Promise.all([
    supabase
      .from("payroll_actuals")
      .select(
        "id, period_start, period_end, gross_cad, employer_cpp_cad, employer_ei_cad, notes",
      )
      .is("archived_at", null)
      .order("period_start", { ascending: false }),
    supabase
      .from("recurring_costs")
      .select(
        "id, name, amount_cad, hst_cad, frequency, finance_categories!inner(name)",
      )
      .is("archived_at", null)
      .eq("finance_categories.name", "Contractors"),
    supabase
      .from("timesheets")
      .select("id, profile_id, period_start, period_end, status")
      .in("status", ["approved", "sent", "processed"]),
  ]);
  const actuals = (actualsResult.data ?? []) as Actual[];
  const sums = summarize(actuals, period, month, year);
  const timesheetGross = await grossFromTimesheets(
    sheetsResult.error ? [] : ((sheetsResult.data ?? []) as Timesheet[]),
    !sheetsResult.error,
  );

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Payroll</h1>
      <FinanceTabs current="payroll" />
      {notice === "saved" ? <StatusNote>Saved.</StatusNote> : null}
      {notice === "failed" ? (
        <StatusNote tone="error">That did not save.</StatusNote>
      ) : null}
      <p className="text-sm text-muted">
        Current pay period {period.start} to {period.end}. Employer CPP and EI
        come from the remittances you enter. Contractors are listed separately
        and are not included in payroll.
      </p>
      {!sheetsResult.error ? (
        <p className="text-sm text-ink">
          Approved timesheet gross, where a CAD rate exists:{" "}
          {money(timesheetGross.all)} all time, {money(timesheetGross.period)}{" "}
          this period, {money(timesheetGross.month)} this month,{" "}
          {money(timesheetGross.year)} this year.
        </p>
      ) : (
        <p className="text-sm text-muted">
          Approved timesheets are not in this database yet. Gross below is from
          the remittances you enter.
        </p>
      )}
      <ul className="grid gap-2 text-sm sm:grid-cols-2">
        <li>This period gross {money(sums.period.gross)}</li>
        <li>This period CPP {money(sums.period.cpp)}</li>
        <li>This period EI {money(sums.period.ei)}</li>
        <li>Month to date gross {money(sums.month.gross)}</li>
        <li>Year to date gross {money(sums.year.gross)}</li>
        <li>Year to date CPP {money(sums.year.cpp)}</li>
        <li>Year to date EI {money(sums.year.ei)}</li>
        <li>Payroll to date gross {money(sums.all.gross)}</li>
        <li>Payroll to date CPP {money(sums.all.cpp)}</li>
        <li>Payroll to date EI {money(sums.all.ei)}</li>
      </ul>
      <h2 className="font-serif text-2xl text-ink">Contractors</h2>
      <ul className="flex flex-col gap-2 text-sm">
        {(
          (contractorsResult.data ?? []) as {
            id: number;
            name: string;
            amount_cad: number | string;
            hst_cad: number | string;
            frequency: Frequency;
          }[]
        ).map((row) => (
          <li key={row.id}>
            {row.name} · {money(Number(row.amount_cad))} pre-tax · HST{" "}
            {money(Number(row.hst_cad))} ·{" "}
            {money(monthlyAmount(Number(row.amount_cad), row.frequency))} a
            month
          </li>
        ))}
      </ul>
      <form
        action={savePayrollActual}
        className="flex flex-col gap-2 rounded-2xl border border-line bg-card p-4"
      >
        <h2 className="font-serif text-2xl">Enter a remittance</h2>
        <input
          name="periodStart"
          type="date"
          required
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <input
          name="periodEnd"
          type="date"
          required
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <input
          name="grossCad"
          required
          inputMode="decimal"
          placeholder="Gross CAD"
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <input
          name="employerCpp"
          inputMode="decimal"
          placeholder="Employer CPP"
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <input
          name="employerEi"
          inputMode="decimal"
          placeholder="Employer EI"
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
          Save remittance
        </button>
      </form>
      <ul className="flex flex-col gap-2">
        {actuals.map((row) => (
          <li
            key={row.id}
            className="rounded-2xl border border-line bg-card p-3 text-sm"
          >
            <p className="font-medium text-ink">
              {row.period_start} to {row.period_end}
            </p>
            <p>
              Gross {money(Number(row.gross_cad))} · CPP{" "}
              {money(Number(row.employer_cpp_cad))} · EI{" "}
              {money(Number(row.employer_ei_cad))}
            </p>
            {row.notes ? <p>{row.notes}</p> : null}
            <form action={archivePayrollActual}>
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

function summarize(
  rows: Actual[],
  period: { start: string; end: string },
  month: string,
  year: string,
) {
  const empty = () => ({ gross: 0, cpp: 0, ei: 0 });
  const sums = { period: empty(), month: empty(), year: empty(), all: empty() };
  for (const row of rows) {
    const piece = {
      gross: Number(row.gross_cad),
      cpp: Number(row.employer_cpp_cad),
      ei: Number(row.employer_ei_cad),
    };
    add(sums.all, piece);
    if (row.period_start.slice(0, 4) === year) add(sums.year, piece);
    if (row.period_start.slice(0, 7) === month) add(sums.month, piece);
    if (row.period_start === period.start) add(sums.period, piece);
  }
  return sums;
}

function add(
  target: { gross: number; cpp: number; ei: number },
  piece: { gross: number; cpp: number; ei: number },
) {
  target.gross += piece.gross;
  target.cpp += piece.cpp;
  target.ei += piece.ei;
}

type Timesheet = {
  id: number;
  profile_id: string;
  period_start: string;
  period_end: string;
  status: string;
};

async function grossFromTimesheets(sheets: Timesheet[], ready: boolean) {
  const empty = { all: 0, period: 0, month: 0, year: 0 };
  if (!ready || sheets.length === 0) return empty;
  const today = todayInToronto();
  const period = currentBiweeklyPeriod(today);
  const supabase = await createClient();
  const ids = sheets.map((sheet) => sheet.id);
  const profileIds = [...new Set(sheets.map((sheet) => sheet.profile_id))];
  const [entriesResult, ratesResult, peopleResult] = await Promise.all([
    supabase
      .from("timesheet_entries")
      .select(
        "timesheet_id, work_date, actual_starts_at, actual_ends_at, actual_break_minutes, not_worked, status",
      )
      .in("timesheet_id", ids)
      .eq("status", "active"),
    supabase
      .from("employee_compensation")
      .select("profile_id, hourly_rate, currency, effective_from, effective_to")
      .in("profile_id", profileIds),
    supabase
      .from("profiles")
      .select("id, employment_type")
      .in("id", profileIds),
  ]);
  if (entriesResult.error) return empty;
  const contractors = new Set(
    (
      (peopleResult.data ?? []) as {
        id: string;
        employment_type: string | null;
      }[]
    )
      .filter((person) => person.employment_type === "contractor")
      .map((person) => person.id),
  );
  const ratesByPerson = new Map<
    string,
    { from: string; to: string | null; rate: number; currency: string }[]
  >();
  for (const rate of (ratesResult.data ?? []) as {
    profile_id: string;
    hourly_rate: number | string;
    currency: string;
    effective_from: string;
    effective_to: string | null;
  }[]) {
    const list = ratesByPerson.get(rate.profile_id) ?? [];
    list.push({
      from: rate.effective_from,
      to: rate.effective_to,
      rate: Number(rate.hourly_rate),
      currency: rate.currency,
    });
    ratesByPerson.set(rate.profile_id, list);
  }
  const sheetById = new Map(sheets.map((sheet) => [sheet.id, sheet]));
  const lines = {
    all: [] as { hours: number; rate: number | null; contractor: boolean }[],
    period: [] as { hours: number; rate: number | null; contractor: boolean }[],
    month: [] as { hours: number; rate: number | null; contractor: boolean }[],
    year: [] as { hours: number; rate: number | null; contractor: boolean }[],
  };
  for (const entry of (entriesResult.data ?? []) as {
    timesheet_id: number;
    work_date: string;
    actual_starts_at: string | null;
    actual_ends_at: string | null;
    actual_break_minutes: number;
    not_worked: boolean;
  }[]) {
    const sheet = sheetById.get(entry.timesheet_id);
    if (!sheet) continue;
    const hours = workedHours(
      entry.actual_starts_at,
      entry.actual_ends_at,
      entry.actual_break_minutes,
      entry.not_worked,
    );
    const line = {
      hours,
      rate: rateOn(ratesByPerson.get(sheet.profile_id) ?? [], entry.work_date),
      contractor: contractors.has(sheet.profile_id),
    };
    lines.all.push(line);
    if (sheet.period_start === period.start) lines.period.push(line);
    if (entry.work_date.slice(0, 7) === today.slice(0, 7))
      lines.month.push(line);
    if (entry.work_date.slice(0, 4) === today.slice(0, 4))
      lines.year.push(line);
  }
  return {
    all: employeeGross(lines.all),
    period: employeeGross(lines.period),
    month: employeeGross(lines.month),
    year: employeeGross(lines.year),
  };
}
