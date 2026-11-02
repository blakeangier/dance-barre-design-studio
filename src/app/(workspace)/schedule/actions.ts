"use server";

import { redirect } from "next/navigation";
import { canEditStaffSchedule } from "@/lib/auth/permissions";
import { isTaskStatus } from "@/lib/tasks/tasks";
import { getSessionState } from "@/lib/auth/session";
import { addDays } from "@/lib/schedule/hours";
import {
  shiftsOverlap,
  staffShiftMinutes,
  weekStarting,
} from "@/lib/schedule/staff-week";
import { createClient } from "@/lib/supabase/server";

function text(value: FormDataEntryValue | null): string {
  return typeof value === "string" ? value.trim() : "";
}

function backTo(week: string, notice?: string): never {
  const params = new URLSearchParams({ week });
  if (notice) params.set("notice", notice);
  redirect(`/schedule?${params.toString()}`);
}

async function editor() {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canEditStaffSchedule(state.profile))
    redirect("/schedule/me?notice=denied");
  return state.profile;
}

export async function saveStaffShift(formData: FormData) {
  const profile = await editor();
  const week = weekStarting(
    text(formData.get("week")),
    text(formData.get("week")),
  );
  const shiftId = text(formData.get("shiftId"));
  const profileId = text(formData.get("profileId"));
  const shiftDate = text(formData.get("shiftDate"));
  const start = text(formData.get("startTime"));
  const end = text(formData.get("endTime"));
  const breakMinutes = Number(text(formData.get("breakMinutes")) || "0");
  const notes = text(formData.get("notes"));
  if (
    !/^\d{4}-\d{2}-\d{2}$/.test(shiftDate) ||
    staffShiftMinutes(start, end, breakMinutes) === null ||
    notes.length > 400
  ) {
    backTo(week, "times");
  }

  const supabase = await createClient();
  const { data: person } = await supabase
    .from("profiles")
    .select("id")
    .eq("id", profileId)
    .eq("is_active", true)
    .maybeSingle();
  if (!person) backTo(week, "failed");

  const row = {
    profile_id: profileId,
    shift_date: shiftDate,
    start_time: start.length === 5 ? `${start}:00` : start,
    end_time: end.length === 5 ? `${end}:00` : end,
    break_minutes: breakMinutes,
    notes: notes || null,
  };

  const saved = shiftId
    ? await supabase
        .from("staff_shifts")
        .update(row)
        .eq("id", Number(shiftId))
        .is("archived_at", null)
        .select("id")
        .maybeSingle()
    : await supabase
        .from("staff_shifts")
        .insert({ ...row, created_by: profile.id })
        .select("id")
        .maybeSingle();
  const savedId = saved.data?.id;
  if (saved.error || savedId == null) backTo(week, "failed");

  const { data: sameDay } = await supabase
    .from("staff_shifts")
    .select("id, start_time, end_time")
    .eq("profile_id", profileId)
    .eq("shift_date", shiftDate)
    .is("archived_at", null);
  const others = (sameDay ?? []).filter((shift) => shift.id !== savedId);
  const overlap = others.some((shift) =>
    shiftsOverlap(
      { start: row.start_time.slice(0, 5), end: row.end_time.slice(0, 5) },
      {
        start: String(shift.start_time).slice(0, 5),
        end: String(shift.end_time).slice(0, 5),
      },
    ),
  );
  backTo(week, overlap ? "overlap" : "saved");
}

export async function archiveStaffShift(formData: FormData) {
  await editor();
  const week = text(formData.get("week"));
  const shiftId = Number(text(formData.get("shiftId")));
  const supabase = await createClient();
  const { error } = await supabase
    .from("staff_shifts")
    .update({ archived_at: new Date().toISOString() })
    .eq("id", shiftId)
    .is("archived_at", null);
  backTo(week, error ? "failed" : "archived");
}

export async function linkShiftTask(formData: FormData) {
  await editor();
  const week = text(formData.get("week"));
  const shiftId = Number(text(formData.get("shiftId")));
  const taskId = Number(text(formData.get("taskId")));
  const supabase = await createClient();
  const { data: shift } = await supabase
    .from("staff_shifts")
    .select("profile_id")
    .eq("id", shiftId)
    .is("archived_at", null)
    .maybeSingle();
  const { data: task } = await supabase
    .from("tasks")
    .select("id, assigned_to")
    .eq("id", taskId)
    .maybeSingle();
  if (!shift || !task || task.assigned_to !== shift.profile_id) {
    backTo(week, "failed");
  }
  const { error } = await supabase
    .from("shift_tasks")
    .insert({ shift_id: shiftId, task_id: taskId });
  backTo(week, error ? "failed" : "saved");
}

export async function unlinkShiftTask(formData: FormData) {
  await editor();
  const week = text(formData.get("week"));
  const supabase = await createClient();
  const { error } = await supabase
    .from("shift_tasks")
    .delete()
    .eq("shift_id", Number(text(formData.get("shiftId"))))
    .eq("task_id", Number(text(formData.get("taskId"))));
  backTo(week, error ? "failed" : "saved");
}

export async function createShiftTask(formData: FormData) {
  const profile = await editor();
  const week = text(formData.get("week"));
  const title = text(formData.get("title"));
  const shiftId = Number(text(formData.get("shiftId")));
  const orderId = text(formData.get("orderId"));
  if (!title) backTo(week, "failed");
  const supabase = await createClient();
  const { data: shift } = await supabase
    .from("staff_shifts")
    .select("profile_id")
    .eq("id", shiftId)
    .is("archived_at", null)
    .maybeSingle();
  if (!shift) backTo(week, "failed");
  const { data: task, error } = await supabase
    .from("tasks")
    .insert({
      title,
      created_by: profile.id,
      assigned_to: shift.profile_id,
      order_id: /^\d+$/.test(orderId) ? Number(orderId) : null,
      status: "to_do",
    })
    .select("id")
    .single();
  if (error || !task) backTo(week, "failed");
  const { error: linkError } = await supabase
    .from("shift_tasks")
    .insert({ shift_id: shiftId, task_id: task.id });
  backTo(week, linkError ? "failed" : "saved");
}

export async function updateMyTaskStatus(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const status = text(formData.get("status"));
  const taskId = Number(text(formData.get("taskId")));
  const back = scheduleReturn(text(formData.get("returnTo")));
  if (!isTaskStatus(status)) redirect(`${back}&notice=failed`);
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("tasks")
    .update({
      status,
      waiting_reason:
        status === "waiting"
          ? text(formData.get("waitingReason")) || null
          : null,
    })
    .eq("id", taskId)
    .eq("assigned_to", state.profile.id)
    .select("id")
    .maybeSingle();
  redirect(`${back}&notice=${error || !data ? "failed" : "saved"}`);
}

function scheduleReturn(value: string): string {
  if (value === "/schedule/me" || value.startsWith("/schedule/me?")) {
    return value.includes("?") ? value : `${value}?`;
  }
  if (value === "/schedule" || value.startsWith("/schedule?")) {
    return value.includes("?") ? value : `${value}?`;
  }
  return "/schedule/me?";
}

export async function copyLastWeek(formData: FormData) {
  const profile = await editor();
  const week = weekStarting(
    text(formData.get("week")),
    text(formData.get("week")),
  );
  const previous = addDays(week, -7);
  const supabase = await createClient();
  const { data: source } = await supabase
    .from("staff_shifts")
    .select(
      "profile_id, shift_date, start_time, end_time, break_minutes, notes",
    )
    .gte("shift_date", previous)
    .lt("shift_date", week)
    .is("archived_at", null);
  const { data: current } = await supabase
    .from("staff_shifts")
    .select("profile_id, shift_date, start_time, end_time")
    .gte("shift_date", week)
    .lt("shift_date", addDays(week, 7))
    .is("archived_at", null);
  const taken = new Set(
    (current ?? []).map((shift) =>
      [
        shift.profile_id,
        shift.shift_date,
        String(shift.start_time).slice(0, 5),
        String(shift.end_time).slice(0, 5),
      ].join("|"),
    ),
  );
  const rows = [];
  for (const shift of source ?? []) {
    const date = addDays(String(shift.shift_date), 7);
    const key = [
      shift.profile_id,
      date,
      String(shift.start_time).slice(0, 5),
      String(shift.end_time).slice(0, 5),
    ].join("|");
    if (taken.has(key)) continue;
    taken.add(key);
    rows.push({
      profile_id: shift.profile_id,
      shift_date: date,
      start_time: shift.start_time,
      end_time: shift.end_time,
      break_minutes: shift.break_minutes,
      notes: shift.notes,
      created_by: profile.id,
    });
  }
  if (rows.length > 0) {
    const { error } = await supabase.from("staff_shifts").insert(rows);
    if (error) backTo(week, "failed");
  }
  backTo(week, rows.length === 0 ? "none" : "copied");
}
