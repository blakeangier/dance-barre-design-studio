import Link from "next/link";
import { Suspense } from "react";
import { TimesheetView } from "@/app/(workspace)/scheduling/hours/timesheet-view";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { EDIT_NOTICES } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Timesheet" };

type PageProps = {
  params: Promise<{ id: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function TimesheetPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <TimesheetScreen
        params={props.params}
        searchParams={props.searchParams}
      />
    </Suspense>
  );
}

async function TimesheetScreen({ params, searchParams }: PageProps) {
  const gate = await gateArea("scheduling");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const id = Number((await params).id);
  const notice =
    EDIT_NOTICES[firstQueryValue((await searchParams).notice) ?? ""];
  const supabase = await createClient();
  const { data: sheet } = await supabase
    .from("timesheets")
    .select(
      "id, profile_id, period_start, period_end, status, returned_comment",
    )
    .eq("id", id)
    .maybeSingle();
  if (!sheet) return <NoAccess reason="denied" />;
  const [entries, settings, period] = await Promise.all([
    supabase
      .from("timesheet_entries")
      .select(
        "id, shift_id, work_date, scheduled_starts_at, scheduled_ends_at, scheduled_break_minutes, actual_starts_at, actual_ends_at, actual_break_minutes, not_worked, reason, status",
      )
      .eq("timesheet_id", id)
      .order("work_date"),
    supabase
      .from("payroll_settings")
      .select("rounding_minutes")
      .eq("id", true)
      .maybeSingle(),
    supabase
      .from("pay_periods")
      .select("status")
      .eq("period_start", sheet.period_start)
      .maybeSingle(),
  ]);

  return (
    <div className="flex flex-col gap-4">
      <Link href="/scheduling/hours" className="text-sm text-muted">
        Hours
      </Link>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      <TimesheetView
        sheet={sheet}
        entries={entries.data ?? []}
        profile={gate.profile}
        rounding={settings.data?.rounding_minutes ?? 0}
        periodProcessed={period.data?.status === "processed"}
      />
    </div>
  );
}
