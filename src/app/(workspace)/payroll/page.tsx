import { Suspense } from "react";
import {
  processPeriod,
  savePayrollSettings,
} from "@/app/(workspace)/scheduling/hours/actions";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canProcessPayroll } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { EDIT_NOTICES } from "@/lib/records/edit";
import {
  formatHours,
  minutesBetween,
  payPeriodContaining,
} from "@/lib/schedule/hours";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Payroll" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type SheetRow = {
  id: number;
  profile_id: string;
  period_start: string;
  period_end: string;
  status: string;
  profiles: { full_name: string } | { full_name: string }[] | null;
};

export default function PayrollPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <PayrollScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

function personName(value: SheetRow["profiles"]): string {
  const row = Array.isArray(value) ? value[0] : value;
  return row?.full_name ?? "Someone";
}

async function PayrollScreen({
  searchParams,
}: {
  searchParams: PageProps["searchParams"];
}) {
  const gate = await gateArea("payroll");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  if (!canProcessPayroll(gate.profile)) return <NoAccess reason="denied" />;
  const notice =
    EDIT_NOTICES[firstQueryValue((await searchParams).notice) ?? ""];
  const supabase = await createClient();
  const { data: settings, error } = await supabase
    .from("payroll_settings")
    .select("pay_period_anchor, rounding_minutes, overtime_weekly_hours")
    .eq("id", true)
    .maybeSingle();
  if (error) {
    return (
      <p className="text-sm text-muted">
        Payroll is not available until the schedule migration is applied.
      </p>
    );
  }
  const today = new Date().toLocaleDateString("en-CA", {
    timeZone: "America/Toronto",
  });
  const period = payPeriodContaining(
    settings?.pay_period_anchor ?? null,
    today,
  );
  const sheetsResult = period
    ? await supabase
        .from("timesheets")
        .select(
          "id, profile_id, period_start, period_end, status, profiles(full_name)",
        )
        .eq("period_start", period.start)
        .in("status", ["approved", "sent", "processed"])
        .order("profile_id")
    : { data: [] };
  const sheets = (sheetsResult.data ?? []) as unknown as SheetRow[];
  const entryResult =
    sheets.length > 0
      ? await supabase
          .from("timesheet_entries")
          .select(
            "timesheet_id, actual_starts_at, actual_ends_at, actual_break_minutes, not_worked, status",
          )
          .in(
            "timesheet_id",
            sheets.map((sheet) => sheet.id),
          )
      : { data: [] };
  const totals = new Map<number, number>();
  for (const entry of entryResult.data ?? []) {
    if (entry.status !== "active" || entry.not_worked) continue;
    if (!entry.actual_starts_at || !entry.actual_ends_at) continue;
    const minutes =
      minutesBetween(
        entry.actual_starts_at,
        entry.actual_ends_at,
        entry.actual_break_minutes,
        settings?.rounding_minutes ?? 0,
      ) ?? 0;
    totals.set(
      entry.timesheet_id,
      (totals.get(entry.timesheet_id) ?? 0) + minutes,
    );
  }
  const periodStatus = period
    ? (
        await supabase
          .from("pay_periods")
          .select("status")
          .eq("period_start", period.start)
          .maybeSingle()
      ).data?.status
    : null;

  return (
    <div className="flex flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Payroll</h1>
      <p className="text-sm text-muted">
        Dance Barre Design Studio Inc. · CAD · every two weeks. Times are
        Toronto. Paid hours already leave out the unpaid break. This is not an
        ADP file yet. The first pay-period date and the overtime threshold stay
        blank until they are confirmed.
      </p>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      {!settings?.pay_period_anchor ? (
        <section className="rounded-2xl border border-orange bg-card p-4">
          <h2 className="font-serif text-2xl text-ink">
            Set the first pay period start date
          </h2>
          <p className="mt-2 text-sm text-muted">
            Leave this blank until you know the date the first bi-weekly period
            begins. The app will not guess.
          </p>
        </section>
      ) : null}
      <form
        action={savePayrollSettings}
        className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
      >
        <h2 className="font-serif text-2xl text-ink">Settings</h2>
        <label className="text-sm font-medium" htmlFor="anchor">
          First pay period starts
        </label>
        <input
          id="anchor"
          name="anchor"
          type="date"
          required
          defaultValue={settings?.pay_period_anchor ?? ""}
          className="min-h-12 rounded-xl border border-line px-3 text-base"
        />
        <label className="text-sm font-medium" htmlFor="rounding">
          Round hours
        </label>
        <select
          id="rounding"
          name="rounding"
          defaultValue={String(settings?.rounding_minutes ?? 0)}
          className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
        >
          <option value="0">None</option>
          <option value="5">Nearest 5 minutes</option>
          <option value="15">Nearest 15 minutes</option>
        </select>
        <label className="text-sm font-medium" htmlFor="overtime">
          Weekly overtime threshold (hours)
        </label>
        <input
          id="overtime"
          name="overtime"
          inputMode="decimal"
          defaultValue={settings?.overtime_weekly_hours ?? ""}
          className="min-h-12 rounded-xl border border-line px-3 text-base"
        />
        <p className="text-sm text-muted">
          Leave the threshold blank. Overtime rules are not confirmed, so hours
          are not split into overtime.
        </p>
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
        >
          Save settings
        </button>
      </form>
      {period ? (
        <section className="flex flex-col gap-3">
          <h2 className="font-serif text-2xl text-ink">
            {period.start} to {period.end}
          </h2>
          <p className="text-sm text-muted">
            {periodStatus === "processed" ? "Processed" : "Open"}
          </p>
          <ul className="flex flex-col gap-2">
            {sheets.map((sheet) => (
              <li
                key={sheet.id}
                className="rounded-2xl border border-line bg-card p-4"
              >
                <p className="font-medium text-ink">
                  {personName(sheet.profiles)}
                </p>
                <p className="text-sm text-muted">
                  {sheet.status} · {formatHours(totals.get(sheet.id) ?? 0)}
                </p>
              </li>
            ))}
          </ul>
          <a
            href={`/payroll/export?period=${period.start}`}
            className="inline-flex min-h-12 items-center justify-center rounded-full border border-ink px-4 font-medium"
          >
            Download CSV
          </a>
          {periodStatus !== "processed" ? (
            <form action={processPeriod}>
              <input type="hidden" name="periodStart" value={period.start} />
              <button
                type="submit"
                className="min-h-12 w-full rounded-full bg-ink px-4 font-medium text-white"
              >
                Mark this period processed
              </button>
            </form>
          ) : null}
        </section>
      ) : null}
    </div>
  );
}
