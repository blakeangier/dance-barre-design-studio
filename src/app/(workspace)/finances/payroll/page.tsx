import { Suspense } from "react";
import {
  archiveContractorContract,
  archiveContractorPayment,
  archivePayrollActual,
  saveContractorContract,
  saveContractorPayment,
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
  contractProgress,
  employeeGross,
  monthlyAmount,
  rateOn,
  recurringCoveredByContract,
  type Frequency,
} from "@/lib/finances/money";
import { includeInPayrollExport } from "@/lib/payroll/export-csv";
import { minutesBetween, payPeriodContaining } from "@/lib/schedule/hours";
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
  source_note: string;
};

async function Payroll({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const notice = firstQueryValue((await searchParams).notice);
  const today = todayInToronto();
  const month = today.slice(0, 7);
  const year = today.slice(0, 4);
  const supabase = await createClient();
  const settingsResult = await supabase
    .from("payroll_settings")
    .select("pay_period_anchor, rounding_minutes")
    .eq("id", true)
    .maybeSingle();
  const anchor =
    (settingsResult.data as { pay_period_anchor: string | null } | null)
      ?.pay_period_anchor ?? null;
  const rounding =
    (settingsResult.data as { rounding_minutes: number } | null)
      ?.rounding_minutes ?? 0;
  const period = payPeriodContaining(anchor, today);
  const [
    actualsResult,
    contractorsResult,
    sheetsResult,
    peopleResult,
    contractResult,
    paymentResult,
  ] = await Promise.all([
    supabase
      .from("payroll_actuals")
      .select(
        "id, period_start, period_end, gross_cad, employer_cpp_cad, employer_ei_cad, notes, source_note",
      )
      .is("archived_at", null)
      .order("period_start", { ascending: false }),
    supabase
      .from("recurring_costs")
      .select(
        "id, name, amount_cad, hst_cad, frequency, contractor_profile_id, finance_categories!inner(name)",
      )
      .is("archived_at", null)
      .eq("finance_categories.name", "Contractors"),
    supabase
      .from("timesheets")
      .select("id, profile_id, period_start, period_end, status")
      .in("status", ["approved", "sent", "processed"]),
    supabase
      .from("profiles")
      .select("id, full_name")
      .eq("employment_type", "contractor")
      .eq("is_active", true)
      .order("full_name"),
    supabase
      .from("contractor_contracts")
      .select(
        "id, contractor_id, total_amount_cad, hst_amount_cad, start_date, end_date, payout, notes, source_note",
      )
      .is("archived_at", null)
      .order("start_date"),
    supabase
      .from("contractor_payments")
      .select(
        "id, contract_id, paid_on, amount_cad, hst_cad, notes, source_note, payment_method",
      )
      .is("archived_at", null)
      .order("paid_on", { ascending: false, nullsFirst: true }),
  ]);
  const actuals = (actualsResult.data ?? []) as Actual[];
  const sums = summarize(actuals, period, month, year);
  const timesheetGross = await grossFromTimesheets(
    sheetsResult.error ? [] : ((sheetsResult.data ?? []) as Timesheet[]),
    !sheetsResult.error,
    period,
    rounding,
  );

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Payroll</h1>
      <FinanceTabs />
      {notice === "saved" ? <StatusNote>Saved.</StatusNote> : null}
      {notice === "failed" ? (
        <StatusNote tone="error">That did not save.</StatusNote>
      ) : null}
      <p className="text-sm text-muted">
        Current pay period{" "}
        {period ? `${period.start} to ${period.end}` : "is not set yet"}. Hours
        come from approved timesheets, with unpaid breaks already taken off, and
        contractors left out the same way as the payroll export. Employer CPP
        and EI come from the remittances you enter.
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
      <h2 className="font-serif text-2xl text-ink">Contractor contracts</h2>
      <ContractList
        today={today}
        people={
          (peopleResult.data ?? []) as { id: string; full_name: string }[]
        }
        contracts={(contractResult.data ?? []) as ContractRow[]}
        payments={(paymentResult.data ?? []) as PaymentRow[]}
      />
      <h2 className="font-serif text-2xl text-ink">
        Recurring contractor lines
      </h2>
      <ul className="flex flex-col gap-2 text-sm">
        {(
          (contractorsResult.data ?? []) as {
            id: number;
            name: string;
            amount_cad: number | string;
            hst_cad: number | string;
            frequency: Frequency;
            contractor_profile_id: string | null;
          }[]
        ).map((row) => (
          <li key={row.id}>
            {row.name} · {money(Number(row.amount_cad))} pre-tax · HST{" "}
            {money(Number(row.hst_cad))} ·{" "}
            {money(monthlyAmount(Number(row.amount_cad), row.frequency))} a
            month
            {recurringCoveredByContract(
              row.contractor_profile_id,
              new Set(
                (
                  (contractResult.data ?? []) as { contractor_id: string }[]
                ).map((contract) => contract.contractor_id),
              ),
            )
              ? " · left out of the projection while the contract is open"
              : ""}
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
            <p className="text-muted">
              Source:{" "}
              {row.source_note?.trim() ? row.source_note : "Not recorded"}
            </p>
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
  period: { start: string; end: string } | null,
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
    if (period && row.period_start === period.start) add(sums.period, piece);
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

async function grossFromTimesheets(
  sheets: Timesheet[],
  ready: boolean,
  period: { start: string; end: string } | null,
  rounding: number,
) {
  const empty = { all: 0, period: 0, month: 0, year: 0 };
  if (!ready || sheets.length === 0) return empty;
  const today = todayInToronto();
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
      .filter((person) => !includeInPayrollExport(person.employment_type))
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
    if (!sheet || entry.not_worked) continue;
    if (!entry.actual_starts_at || !entry.actual_ends_at) continue;
    const minutes = minutesBetween(
      entry.actual_starts_at,
      entry.actual_ends_at,
      entry.actual_break_minutes,
      rounding,
    );
    const hours = (minutes ?? 0) / 60;
    const line = {
      hours,
      rate: rateOn(ratesByPerson.get(sheet.profile_id) ?? [], entry.work_date),
      contractor: contractors.has(sheet.profile_id),
    };
    lines.all.push(line);
    if (period && sheet.period_start === period.start) lines.period.push(line);
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

type ContractRow = {
  id: number;
  contractor_id: string;
  total_amount_cad: number | string;
  hst_amount_cad: number | string;
  start_date: string;
  end_date: string;
  payout: "spread" | "lump_sums";
  notes: string | null;
  source_note: string;
};

type PaymentRow = {
  id: number;
  contract_id: number;
  paid_on: string | null;
  amount_cad: number | string;
  hst_cad: number | string;
  notes: string | null;
  source_note: string;
};

function ContractList({
  today,
  people,
  contracts,
  payments,
}: {
  today: string;
  people: { id: string; full_name: string }[];
  contracts: ContractRow[];
  payments: PaymentRow[];
}) {
  const names = new Map(people.map((person) => [person.id, person.full_name]));
  return (
    <div className="flex flex-col gap-3">
      {contracts.map((contract) => {
        const rows = payments.filter(
          (payment) => payment.contract_id === contract.id,
        );
        const progress = contractProgress(
          Number(contract.total_amount_cad),
          Number(contract.hst_amount_cad),
          rows.map((payment) => ({
            paidOn: payment.paid_on,
            amount: Number(payment.amount_cad),
            hst: Number(payment.hst_cad),
          })),
          today,
        );
        return (
          <article
            key={contract.id}
            className="rounded-2xl border border-line bg-card p-4 text-sm"
          >
            <p className="font-medium text-ink">
              {names.get(contract.contractor_id) ?? "Contractor"} ·{" "}
              {contract.start_date} to {contract.end_date}
            </p>
            <p>
              {money(Number(contract.total_amount_cad))} pre-tax · HST{" "}
              {money(Number(contract.hst_amount_cad))}
            </p>
            <p>
              Paid {money(progress.paid)} · Remaining{" "}
              {money(progress.remaining)} · {progress.percent}% paid
            </p>
            <p className="text-muted">
              {contract.payout === "lump_sums"
                ? "Future payments stay on their dates."
                : "The remaining balance is spread over production days left in the contract."}
            </p>
            {contract.notes ? <p>{contract.notes}</p> : null}
            <p className="text-muted">
              Source:{" "}
              {contract.source_note?.trim()
                ? contract.source_note
                : "Not recorded"}
            </p>
            <ul className="mt-2 flex flex-col gap-1">
              {rows.map((payment) => (
                <li
                  key={payment.id}
                  className="flex items-center justify-between gap-2"
                >
                  <span>
                    {payment.paid_on ?? "Date unknown"} ·{" "}
                    {money(Number(payment.amount_cad))} pre-tax · HST{" "}
                    {money(Number(payment.hst_cad))}
                    {payment.paid_on && payment.paid_on > today
                      ? " · scheduled"
                      : ""}
                    {payment.notes ? ` · ${payment.notes}` : ""}
                    {" · Source: "}
                    {payment.source_note?.trim()
                      ? payment.source_note
                      : "Not recorded"}
                  </span>
                  <form action={archiveContractorPayment}>
                    <input type="hidden" name="id" value={payment.id} />
                    <button type="submit" className="min-h-11 font-medium">
                      Archive
                    </button>
                  </form>
                </li>
              ))}
            </ul>
            <form action={archiveContractorContract} className="mt-2">
              <input type="hidden" name="id" value={contract.id} />
              <button type="submit" className="min-h-11 font-medium">
                Archive contract
              </button>
            </form>
          </article>
        );
      })}
      <form
        action={saveContractorContract}
        className="flex flex-col gap-2 rounded-2xl border border-line bg-card p-4"
      >
        <h3 className="font-serif text-2xl">Add a contract</h3>
        <select
          name="contractorId"
          required
          className="min-h-12 rounded-xl border border-line px-3"
        >
          {people.map((person) => (
            <option key={person.id} value={person.id}>
              {person.full_name}
            </option>
          ))}
        </select>
        <input
          name="totalAmount"
          required
          inputMode="decimal"
          placeholder="Contract total, pre-tax"
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <input
          name="hstAmount"
          inputMode="decimal"
          placeholder="HST"
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <input
          name="startDate"
          type="date"
          required
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <input
          name="endDate"
          type="date"
          required
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <select
          name="payout"
          defaultValue="spread"
          className="min-h-12 rounded-xl border border-line px-3"
        >
          <option value="spread">Spread the remaining balance</option>
          <option value="lump_sums">Use scheduled lump sums</option>
        </select>
        <textarea
          name="notes"
          placeholder="Notes"
          className="min-h-20 rounded-xl border border-line px-3 py-2"
        />
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
        >
          Save contract
        </button>
      </form>
      <form
        action={saveContractorPayment}
        className="flex flex-col gap-2 rounded-2xl border border-line bg-card p-4"
      >
        <h3 className="font-serif text-2xl">Add a payment</h3>
        <select
          name="contractId"
          required
          className="min-h-12 rounded-xl border border-line px-3"
        >
          {contracts.map((contract) => (
            <option key={contract.id} value={contract.id}>
              {names.get(contract.contractor_id) ?? "Contract"} ·{" "}
              {contract.start_date}
            </option>
          ))}
        </select>
        <input
          name="paidOn"
          type="date"
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <label className="flex min-h-11 items-center gap-2 text-sm">
          <input type="checkbox" name="dateUnknown" />
          Date unknown
        </label>
        <p className="text-sm text-muted">
          A future date is a scheduled lump sum. Leave it blank, or tick Date
          unknown, for a payment already made.
        </p>
        <input
          name="amount"
          required
          inputMode="decimal"
          placeholder="Amount, pre-tax"
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <input
          name="hst"
          inputMode="decimal"
          placeholder="HST"
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <textarea
          name="notes"
          placeholder="Notes"
          className="min-h-20 rounded-xl border border-line px-3 py-2"
        />
        <button
          type="submit"
          className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium"
        >
          Save payment
        </button>
      </form>
    </div>
  );
}
