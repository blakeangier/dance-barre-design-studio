"use server";

import { redirect } from "next/navigation";
import { canEditSchedule } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { notifyShiftChange } from "@/lib/push/send";
import { addDays, localToUtc } from "@/lib/schedule/hours";
import { createClient } from "@/lib/supabase/server";

function back(week: string, span: string, notice: string): never {
  const params = new URLSearchParams({ week, span, notice });
  redirect(`/scheduling?${params.toString()}`);
}

async function editor(week: string, span: string) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canEditSchedule(state.profile)) back(week, span, "denied");
  return state.profile;
}

function instants(date: string, start: string, end: string) {
  const startAt = localToUtc(date, start);
  const endDate = end <= start ? addDays(date, 1) : date;
  const endAt = localToUtc(endDate, end);
  if (endAt <= startAt) return null;
  return { startAt, endAt };
}

export async function saveShift(formData: FormData) {
  const week = String(formData.get("week") ?? "");
  const span = String(formData.get("span") ?? "7");
  const profile = await editor(week, span);
  const person = String(formData.get("profileId") ?? "");
  const date = String(formData.get("workDate") ?? "");
  const start = String(formData.get("start") ?? "");
  const end = String(formData.get("end") ?? "");
  const breakMinutes = Number(String(formData.get("breakMinutes") ?? "0"));
  const note = String(formData.get("note") ?? "").trim();
  const orderId = String(formData.get("orderId") ?? "");
  const shiftId = String(formData.get("shiftId") ?? "");
  if (!person || !/^\d{4}-\d{2}-\d{2}$/.test(date))
    back(week, span, "required");
  if (!/^\d{2}:\d{2}$/.test(start) || !/^\d{2}:\d{2}$/.test(end)) {
    back(week, span, "time");
  }
  if (!Number.isInteger(breakMinutes) || breakMinutes < 0)
    back(week, span, "number");
  const clock = instants(date, start, end);
  if (!clock) back(week, span, "time");
  const row = {
    profile_id: person,
    work_date: date,
    start_local: start,
    end_local: end,
    starts_at: clock.startAt.toISOString(),
    ends_at: clock.endAt.toISOString(),
    break_minutes: breakMinutes,
    note: note || null,
    order_id: orderId ? Number(orderId) : null,
    created_by: profile.id,
  };
  const supabase = await createClient();
  const { error } = shiftId
    ? await supabase.from("shifts").update(row).eq("id", Number(shiftId))
    : await supabase.from("shifts").insert({ ...row, status: "scheduled" });
  if (error) back(week, span, "failed");
  await notifyShiftChange({
    recipientId: person,
    actorId: profile.id,
    change: shiftId ? "changed" : "created",
    when: date,
    start,
    end,
  });
  back(week, span, "saved");
}

export async function cancelShift(formData: FormData) {
  const week = String(formData.get("week") ?? "");
  const span = String(formData.get("span") ?? "7");
  const profile = await editor(week, span);
  const shiftId = Number(String(formData.get("shiftId") ?? ""));
  const supabase = await createClient();
  const { data: shift } = await supabase
    .from("shifts")
    .select("profile_id, work_date")
    .eq("id", shiftId)
    .maybeSingle();
  const { error } = await supabase
    .from("shifts")
    .update({ status: "cancelled", cancelled_at: new Date().toISOString() })
    .eq("id", shiftId);
  if (error) back(week, span, "failed");
  if (shift?.profile_id) {
    await notifyShiftChange({
      recipientId: shift.profile_id,
      actorId: profile.id,
      change: "cancelled",
      when: String(shift.work_date),
    });
  }
  back(week, span, "saved");
}

export async function copyLastWeek(formData: FormData) {
  const week = String(formData.get("week") ?? "");
  const span = String(formData.get("span") ?? "7");
  const profile = await editor(week, span);
  const supabase = await createClient();
  const previousStart = addDays(week, -7);
  const previousEnd = addDays(week, -1);
  const { data: previous } = await supabase
    .from("shifts")
    .select(
      "profile_id, work_date, start_local, end_local, break_minutes, note, order_id",
    )
    .eq("status", "scheduled")
    .gte("work_date", previousStart)
    .lte("work_date", previousEnd);
  const { data: existing } = await supabase
    .from("shifts")
    .select("profile_id, work_date, start_local")
    .eq("status", "scheduled")
    .gte("work_date", week)
    .lte("work_date", addDays(week, 6));
  const taken = new Set(
    (existing ?? []).map(
      (shift) =>
        `${shift.profile_id}|${shift.work_date}|${String(shift.start_local).slice(0, 5)}`,
    ),
  );
  const rows = [];
  for (const shift of previous ?? []) {
    const date = addDays(String(shift.work_date), 7);
    const start = String(shift.start_local).slice(0, 5);
    const end = String(shift.end_local).slice(0, 5);
    const key = `${shift.profile_id}|${date}|${start}`;
    if (taken.has(key)) continue;
    const clock = instants(date, start, end);
    if (!clock) continue;
    taken.add(key);
    rows.push({
      profile_id: shift.profile_id,
      work_date: date,
      start_local: start,
      end_local: end,
      starts_at: clock.startAt.toISOString(),
      ends_at: clock.endAt.toISOString(),
      break_minutes: shift.break_minutes,
      note: shift.note,
      order_id: shift.order_id,
      status: "scheduled",
      created_by: profile.id,
    });
  }
  if (rows.length > 0) {
    const { error } = await supabase.from("shifts").insert(rows);
    if (error) back(week, span, "failed");
    const people = new Set(rows.map((row) => row.profile_id));
    for (const recipientId of people) {
      await notifyShiftChange({
        recipientId,
        actorId: profile.id,
        change: "created",
        when: week,
      });
    }
  }
  back(week, span, "saved");
}

export async function saveTemplate(formData: FormData) {
  const week = String(formData.get("week") ?? "");
  const span = String(formData.get("span") ?? "7");
  await editor(week, span);
  const name = String(formData.get("name") ?? "").trim();
  const weekday = Number(String(formData.get("weekday") ?? ""));
  const start = String(formData.get("start") ?? "");
  const end = String(formData.get("end") ?? "");
  const breakMinutes = Number(String(formData.get("breakMinutes") ?? "0"));
  const person = String(formData.get("profileId") ?? "");
  const note = String(formData.get("note") ?? "").trim();
  if (!name || weekday < 1 || weekday > 7) back(week, span, "required");
  if (!/^\d{2}:\d{2}$/.test(start) || !/^\d{2}:\d{2}$/.test(end)) {
    back(week, span, "time");
  }
  const supabase = await createClient();
  const { error } = await supabase.from("shift_templates").insert({
    name,
    weekday,
    start_local: start,
    end_local: end,
    break_minutes: breakMinutes,
    note: note || null,
    profile_id: person || null,
  });
  if (error) back(week, span, "failed");
  back(week, span, "saved");
}

export async function applyTemplates(formData: FormData) {
  const week = String(formData.get("week") ?? "");
  const span = String(formData.get("span") ?? "7");
  const profile = await editor(week, span);
  const supabase = await createClient();
  const { data: templates } = await supabase
    .from("shift_templates")
    .select(
      "name, weekday, start_local, end_local, break_minutes, note, profile_id",
    )
    .is("archived_at", null)
    .not("profile_id", "is", null);
  const rows = [];
  for (const template of templates ?? []) {
    const date = addDays(week, Number(template.weekday) - 1);
    const start = String(template.start_local).slice(0, 5);
    const end = String(template.end_local).slice(0, 5);
    const clock = instants(date, start, end);
    if (!clock || !template.profile_id) continue;
    rows.push({
      profile_id: template.profile_id,
      work_date: date,
      start_local: start,
      end_local: end,
      starts_at: clock.startAt.toISOString(),
      ends_at: clock.endAt.toISOString(),
      break_minutes: template.break_minutes,
      note: template.note,
      status: "scheduled",
      created_by: profile.id,
    });
  }
  if (rows.length > 0) {
    const { error } = await supabase.from("shifts").insert(rows);
    if (error) back(week, span, "failed");
    const people = new Set(rows.map((row) => row.profile_id));
    for (const recipientId of people) {
      await notifyShiftChange({
        recipientId,
        actorId: profile.id,
        change: "created",
        when: week,
      });
    }
  }
  back(week, span, "saved");
}
