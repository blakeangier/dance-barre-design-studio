"use server";

import { redirect } from "next/navigation";
import { canEditSchedule, canProcessPayroll } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { localToUtc, addDays, payPeriodContaining } from "@/lib/schedule/hours";
import { createClient } from "@/lib/supabase/server";

function sheetBack(id: string, notice: string): never {
  redirect(`/scheduling/hours/${id}?notice=${notice}`);
}

export async function saveEntry(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const timesheetId = String(formData.get("timesheetId") ?? "");
  const entryId = String(formData.get("entryId") ?? "");
  const date = String(formData.get("workDate") ?? "");
  const start = String(formData.get("start") ?? "");
  const end = String(formData.get("end") ?? "");
  const breakMinutes = Number(String(formData.get("breakMinutes") ?? "0"));
  const notWorked = formData.get("notWorked") === "on";
  const reason = String(formData.get("reason") ?? "").trim();
  if (!/^\d{2}:\d{2}$/.test(start) || !/^\d{2}:\d{2}$/.test(end)) {
    sheetBack(timesheetId, "time");
  }
  const endDate = end <= start ? addDays(date, 1) : date;
  const startAt = localToUtc(date, start);
  const endAt = localToUtc(endDate, end);
  const supabase = await createClient();
  const { error } = await supabase
    .from("timesheet_entries")
    .update({
      actual_starts_at: startAt.toISOString(),
      actual_ends_at: endAt.toISOString(),
      actual_break_minutes: breakMinutes,
      not_worked: notWorked,
      reason: reason || null,
    })
    .eq("id", Number(entryId));
  if (error) sheetBack(timesheetId, "failed");
  sheetBack(timesheetId, "saved");
}

export async function addUnscheduled(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const timesheetId = String(formData.get("timesheetId") ?? "");
  const date = String(formData.get("workDate") ?? "");
  const start = String(formData.get("start") ?? "");
  const end = String(formData.get("end") ?? "");
  const breakMinutes = Number(String(formData.get("breakMinutes") ?? "0"));
  const reason = String(formData.get("reason") ?? "").trim();
  if (reason.length < 3) sheetBack(timesheetId, "required");
  const endDate = end <= start ? addDays(date, 1) : date;
  const supabase = await createClient();
  const { error } = await supabase.from("timesheet_entries").insert({
    timesheet_id: Number(timesheetId),
    work_date: date,
    actual_starts_at: localToUtc(date, start).toISOString(),
    actual_ends_at: localToUtc(endDate, end).toISOString(),
    actual_break_minutes: breakMinutes,
    reason,
  });
  if (error) sheetBack(timesheetId, "failed");
  sheetBack(timesheetId, "saved");
}

export async function submitTimesheet(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const timesheetId = String(formData.get("timesheetId") ?? "");
  const supabase = await createClient();
  const { error } = await supabase
    .from("timesheets")
    .update({
      status: "submitted",
      employee_submitted_at: new Date().toISOString(),
    })
    .eq("id", Number(timesheetId))
    .eq("profile_id", state.profile.id);
  if (error) sheetBack(timesheetId, "failed");
  sheetBack(timesheetId, "submitted");
}

export async function reviewTimesheet(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canEditSchedule(state.profile))
    redirect("/scheduling/hours?notice=denied");
  const timesheetId = String(formData.get("timesheetId") ?? "");
  const decision = String(formData.get("decision") ?? "");
  const comment = String(formData.get("comment") ?? "").trim();
  const supabase = await createClient();
  if (decision === "approve") {
    const { error } = await supabase
      .from("timesheets")
      .update({
        status: "approved",
        manager_approved_at: new Date().toISOString(),
        manager_approved_by: state.profile.id,
      })
      .eq("id", Number(timesheetId));
    if (error) sheetBack(timesheetId, "failed");
  } else if (decision === "send") {
    const { error } = await supabase
      .from("timesheets")
      .update({
        status: "sent",
        sent_to_payroll_at: new Date().toISOString(),
      })
      .eq("id", Number(timesheetId));
    if (error) sheetBack(timesheetId, "failed");
  } else {
    const { error } = await supabase
      .from("timesheets")
      .update({ status: "returned", returned_comment: comment })
      .eq("id", Number(timesheetId));
    if (error) sheetBack(timesheetId, "failed");
  }
  sheetBack(timesheetId, "saved");
}

export async function reopenTimesheet(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const timesheetId = Number(String(formData.get("timesheetId") ?? ""));
  const reason = String(formData.get("reason") ?? "").trim();
  const supabase = await createClient();
  const { error } = await supabase.rpc("reopen_timesheet", {
    sheet_id: timesheetId,
    reason,
  });
  if (error) sheetBack(String(timesheetId), "failed");
  sheetBack(String(timesheetId), "saved");
}

export async function savePayrollSettings(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canProcessPayroll(state.profile)) redirect("/payroll?notice=denied");
  const anchor = String(formData.get("anchor") ?? "").trim();
  const rounding = Number(String(formData.get("rounding") ?? "0"));
  const overtime = String(formData.get("overtime") ?? "").trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(anchor)) redirect("/payroll?notice=date");
  if (![0, 5, 15].includes(rounding)) redirect("/payroll?notice=number");
  const supabase = await createClient();
  const { data: entity } = await supabase
    .from("business_entities")
    .select("id")
    .eq("legal_name", "Dance Barre Design Studio Inc.")
    .maybeSingle();
  const { error } = await supabase
    .from("payroll_settings")
    .update({
      pay_period_anchor: anchor,
      rounding_minutes: rounding,
      overtime_weekly_hours: overtime ? Number(overtime) : null,
      entity_id: entity?.id ?? null,
    })
    .eq("id", true);
  if (error) redirect("/payroll?notice=failed");
  redirect("/payroll?notice=saved");
}

export async function processPeriod(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canProcessPayroll(state.profile)) redirect("/payroll?notice=denied");
  const start = String(formData.get("periodStart") ?? "");
  const supabase = await createClient();
  const { error } = await supabase.rpc("mark_pay_period_processed", {
    p_start: start,
  });
  if (error) redirect("/payroll?notice=failed");
  redirect("/payroll?notice=saved");
}

export async function currentPeriodStart(): Promise<string | null> {
  const state = await getSessionState();
  if (state.status !== "ready") return null;
  const supabase = await createClient();
  const { data } = await supabase
    .from("payroll_settings")
    .select("pay_period_anchor")
    .eq("id", true)
    .maybeSingle();
  const today = new Date().toLocaleDateString("en-CA", {
    timeZone: "America/Toronto",
  });
  return (
    payPeriodContaining(data?.pay_period_anchor ?? null, today)?.start ?? null
  );
}
