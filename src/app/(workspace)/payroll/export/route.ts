import { canProcessPayroll } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { payrollCsv, type PayrollExportRow } from "@/lib/payroll/export-csv";
import { hoursFromMinutes, minutesBetween } from "@/lib/schedule/hours";
import { createClient } from "@/lib/supabase/server";

export async function GET(request: Request) {
  const state = await getSessionState();
  if (state.status !== "ready" || !canProcessPayroll(state.profile)) {
    return new Response("You cannot download this file.", { status: 403 });
  }
  const period = new URL(request.url).searchParams.get("period") ?? "";
  if (!/^\d{4}-\d{2}-\d{2}$/.test(period)) {
    return new Response("Choose a pay period.", { status: 400 });
  }
  const supabase = await createClient();
  const { data: sheets } = await supabase
    .from("timesheets")
    .select("id, period_start, period_end, profiles(full_name)")
    .eq("period_start", period)
    .in("status", ["approved", "sent", "processed"]);
  const ids = (sheets ?? []).map((sheet) => sheet.id);
  const { data: entries } = ids.length
    ? await supabase
        .from("timesheet_entries")
        .select(
          "timesheet_id, actual_starts_at, actual_ends_at, actual_break_minutes, not_worked, status, reason",
        )
        .in("timesheet_id", ids)
    : { data: [] };
  const { data: settings } = await supabase
    .from("payroll_settings")
    .select("rounding_minutes")
    .eq("id", true)
    .maybeSingle();
  const rows: PayrollExportRow[] = (sheets ?? []).map((sheet) => {
    const person = sheet.profiles as
      { full_name: string } | { full_name: string }[] | null;
    const name = Array.isArray(person)
      ? person[0]?.full_name
      : person?.full_name;
    const minutes = (entries ?? [])
      .filter(
        (entry) =>
          entry.timesheet_id === sheet.id &&
          entry.status === "active" &&
          !entry.not_worked &&
          entry.actual_starts_at &&
          entry.actual_ends_at,
      )
      .reduce(
        (sum, entry) =>
          sum +
          (minutesBetween(
            entry.actual_starts_at!,
            entry.actual_ends_at!,
            entry.actual_break_minutes,
            settings?.rounding_minutes ?? 0,
          ) ?? 0),
        0,
      );
    const hours = hoursFromMinutes(minutes);
    const notes = (entries ?? [])
      .filter((entry) => entry.timesheet_id === sheet.id && entry.reason)
      .map((entry) => entry.reason)
      .join("; ");
    return {
      employeeName: name ?? "Someone",
      periodStart: sheet.period_start,
      periodEnd: sheet.period_end,
      regularHours: hours,
      totalHours: hours,
      notes: notes || "Overtime is not calculated.",
    };
  });
  return new Response(payrollCsv(rows), {
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="hours-${period}.csv"`,
    },
  });
}
