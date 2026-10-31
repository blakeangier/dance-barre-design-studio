import Link from "next/link";
import { Suspense } from "react";
import { TimesheetView } from "@/app/(workspace)/scheduling/hours/timesheet-view";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditSchedule } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { EDIT_NOTICES } from "@/lib/records/edit";
import { payPeriodContaining } from "@/lib/schedule/hours";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Hours" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function HoursPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <HoursScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function HoursScreen({
  searchParams,
}: {
  searchParams: PageProps["searchParams"];
}) {
  const gate = await gateArea("scheduling");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const params = await searchParams;
  const noticeCode = firstQueryValue(params.notice) ?? "";
  const notice =
    noticeCode === "submitted"
      ? { tone: "ok" as const, text: "Submitted. Elaine can approve it now." }
      : EDIT_NOTICES[noticeCode];
  const supabase = await createClient();
  const today = new Date().toLocaleDateString("en-CA", {
    timeZone: "America/Toronto",
  });
  const { data: settings, error: settingsError } = await supabase
    .from("payroll_settings")
    .select("pay_period_anchor, rounding_minutes")
    .eq("id", true)
    .maybeSingle();
  if (settingsError) {
    return (
      <p className="text-sm text-muted">
        Hours are not available until the schedule migration is applied.
      </p>
    );
  }
  const period = payPeriodContaining(
    settings?.pay_period_anchor ?? null,
    today,
  );
  const manager = canEditSchedule(gate.profile);
  let sheetId: number | null = null;
  if (period) {
    const { data } = await supabase.rpc("ensure_timesheet", {
      target_profile: gate.profile.id,
      p_start: period.start,
      p_end: period.end,
    });
    sheetId = typeof data === "number" ? data : null;
  }
  const sheetResult = sheetId
    ? await supabase
        .from("timesheets")
        .select(
          "id, profile_id, period_start, period_end, status, returned_comment",
        )
        .eq("id", sheetId)
        .maybeSingle()
    : { data: null };
  const entriesResult = sheetId
    ? await supabase
        .from("timesheet_entries")
        .select(
          "id, shift_id, work_date, scheduled_starts_at, scheduled_ends_at, scheduled_break_minutes, actual_starts_at, actual_ends_at, actual_break_minutes, not_worked, reason, status",
        )
        .eq("timesheet_id", sheetId)
        .order("work_date")
    : { data: [] };
  const { data: waiting } = manager
    ? await supabase
        .from("timesheets")
        .select("id, status, period_start, period_end, profiles(full_name)")
        .eq("status", "submitted")
        .order("period_start")
    : { data: [] };
  const periodRow = period
    ? await supabase
        .from("pay_periods")
        .select("status")
        .eq("period_start", period.start)
        .maybeSingle()
    : { data: null };

  return (
    <div className="flex flex-col gap-4">
      <Link href="/scheduling" className="text-sm text-muted">
        Schedule
      </Link>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      {!period ? (
        <section className="rounded-2xl border border-line bg-card p-4">
          <h1 className="font-serif text-3xl text-ink">Hours</h1>
          <p className="mt-2 text-sm text-muted">
            Set the first pay period start date before hours can be calculated.
            An owner or payroll does that on the Payroll page.
          </p>
        </section>
      ) : null}
      {sheetResult.data ? (
        <TimesheetView
          sheet={sheetResult.data}
          entries={entriesResult.data ?? []}
          profile={gate.profile}
          rounding={settings?.rounding_minutes ?? 0}
          periodProcessed={periodRow.data?.status === "processed"}
        />
      ) : null}
      {manager ? (
        <section className="flex flex-col gap-2">
          <h2 className="font-serif text-2xl text-ink">Waiting for approval</h2>
          {(waiting ?? []).length === 0 ? (
            <p className="text-sm text-muted">Nothing is waiting.</p>
          ) : (
            (waiting ?? []).map((row) => {
              const person = row.profiles as
                { full_name: string } | { full_name: string }[] | null;
              const name = Array.isArray(person)
                ? person[0]?.full_name
                : person?.full_name;
              return (
                <Link
                  key={row.id}
                  href={`/scheduling/hours/${row.id}`}
                  className="inline-flex min-h-12 items-center rounded-2xl border border-line bg-card px-4"
                >
                  {name ?? "Someone"} · {row.period_start}
                </Link>
              );
            })
          )}
        </section>
      ) : null}
    </div>
  );
}
