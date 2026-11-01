"use server";

import { redirect } from "next/navigation";
import {
  canAccessArea,
  canSuperviseTasks,
  canUpdateOrderStatus,
} from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { isTaskPhotoPath } from "@/lib/inventory/photos";
import { isTaskPriority, isTaskStatus } from "@/lib/tasks/tasks";
import { createClient } from "@/lib/supabase/server";

function text(value: FormDataEntryValue | null): string {
  return typeof value === "string" ? value.trim() : "";
}

function optionalId(value: string): number | null {
  if (!/^\d+$/.test(value)) return null;
  return Number(value);
}

async function readyProfile() {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canAccessArea(state.profile, "tasks")) redirect("/?notice=denied");
  return state.profile;
}

async function assigneeIsActive(profileId: string): Promise<boolean> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("profiles")
    .select("id")
    .eq("id", profileId)
    .eq("is_active", true)
    .maybeSingle();
  return Boolean(data);
}

export async function createTask(formData: FormData) {
  const profile = await readyProfile();
  const title = text(formData.get("title"));
  const back = "/tasks/new";
  if (!title) redirect(`${back}?notice=failed`);
  const supervisor = canSuperviseTasks(profile);
  const assignedTo = supervisor
    ? text(formData.get("assignedTo")) || profile.id
    : profile.id;
  if (!(await assigneeIsActive(assignedTo))) redirect(`${back}?notice=failed`);
  const priority = text(formData.get("priority")) || "normal";
  if (!isTaskPriority(priority)) redirect(`${back}?notice=failed`);
  const materialCode = text(formData.get("materialCode"));
  const supabase = await createClient();
  let materialId: number | null = null;
  if (materialCode) {
    const { data: material } = await supabase
      .from("materials")
      .select("id")
      .eq("material_code", materialCode)
      .maybeSingle();
    if (!material) redirect(`${back}?notice=failed`);
    materialId = material.id;
  }
  const { data, error } = await supabase
    .from("tasks")
    .insert({
      title,
      description: text(formData.get("description")) || null,
      created_by: profile.id,
      assigned_to: assignedTo,
      order_id: optionalId(text(formData.get("orderId"))),
      style_id: optionalId(text(formData.get("styleId"))),
      material_id: materialId,
      due_on: text(formData.get("dueOn")) || null,
      priority,
      status: "to_do",
    })
    .select("id")
    .single();
  if (error || !data) redirect(`${back}?notice=failed`);
  redirect(`/tasks/${data.id}?notice=saved`);
}

export async function updateTask(formData: FormData) {
  const profile = await readyProfile();
  const taskId = text(formData.get("taskId"));
  const back = `/tasks/${taskId}`;
  const status = text(formData.get("status"));
  if (!isTaskStatus(status)) redirect(`${back}?notice=failed`);
  const priority = text(formData.get("priority"));
  const patch: Record<string, string | number | null> = {
    status,
    waiting_reason: text(formData.get("waitingReason")) || null,
  };
  const supervisor = canUpdateOrderStatus(profile);
  if (supervisor || text(formData.get("isCreator")) === "1") {
    if (priority) {
      if (!isTaskPriority(priority)) redirect(`${back}?notice=failed`);
      patch.priority = priority;
    }
    patch.title = text(formData.get("title")) || "";
    patch.description = text(formData.get("description")) || null;
    patch.due_on = text(formData.get("dueOn")) || null;
    const assigned = text(formData.get("assignedTo"));
    if (assigned) {
      if (!(await assigneeIsActive(assigned)))
        redirect(`${back}?notice=failed`);
      patch.assigned_to = assigned;
    }
    patch.order_id = optionalId(text(formData.get("orderId")));
    patch.style_id = optionalId(text(formData.get("styleId")));
  }
  const { error } = await supabaseUpdate(taskId, patch);
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

async function supabaseUpdate(
  taskId: string,
  patch: Record<string, string | number | null>,
) {
  const supabase = await createClient();
  return supabase.from("tasks").update(patch).eq("id", Number(taskId));
}

export async function addTaskNote(formData: FormData) {
  const profile = await readyProfile();
  const taskId = text(formData.get("taskId"));
  const back = `/tasks/${taskId}`;
  const body = text(formData.get("body"));
  const photoPath = text(formData.get("photoPath"));
  if (!body) redirect(`${back}?notice=failed`);
  if (photoPath && !isTaskPhotoPath(profile.id, photoPath)) {
    redirect(`${back}?notice=failed`);
  }
  const { error } = await (await createClient()).from("task_notes").insert({
    task_id: Number(taskId),
    body,
    photo_path: photoPath || null,
    author_id: profile.id,
  });
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function editTaskNote(formData: FormData) {
  const profile = await readyProfile();
  const taskId = text(formData.get("taskId"));
  const back = `/tasks/${taskId}`;
  const body = text(formData.get("body"));
  if (!body) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("task_notes")
    .update({ body })
    .eq("id", Number(text(formData.get("noteId"))))
    .eq("author_id", profile.id);
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}
