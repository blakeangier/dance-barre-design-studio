"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { canAccessArea, canUpdateOrderStatus } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import {
  canCancelTask,
  canEditTaskStatus,
  isTaskStatus,
} from "@/lib/tasks/tasks";
import { createClient } from "@/lib/supabase/server";

export async function setTaskStatus(
  taskId: number,
  status: string,
): Promise<{ ok: true } | { ok: false; message: string }> {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canAccessArea(state.profile, "tasks")) redirect("/?notice=denied");
  const profile = state.profile;
  if (!Number.isInteger(taskId) || taskId <= 0 || !isTaskStatus(status)) {
    return { ok: false, message: "That status did not save." };
  }
  const supabase = await createClient();
  const { data, error: readError } = await supabase
    .from("tasks")
    .select("created_by, assigned_to, waiting_reason, status")
    .eq("id", taskId)
    .maybeSingle();
  if (readError || !data) {
    return { ok: false, message: "That task could not be updated." };
  }
  const supervisor = canUpdateOrderStatus(profile);
  const access = {
    viewerId: profile.id,
    assignedTo: data.assigned_to,
    createdBy: data.created_by,
    supervisor,
  };
  if (!canEditTaskStatus(access)) {
    return { ok: false, message: "You cannot change this task." };
  }
  if (status === "cancelled" && !canCancelTask(access)) {
    return { ok: false, message: "You cannot cancel this task." };
  }
  if (status === "waiting" && (data.waiting_reason ?? "").trim().length < 3) {
    return {
      ok: false,
      message: "Open the task and add a waiting reason first.",
    };
  }
  if (data.status === status) return { ok: true };
  const { error } = await supabase
    .from("tasks")
    .update({ status })
    .eq("id", taskId);
  if (error) return { ok: false, message: "That status did not save." };
  revalidatePath("/tasks");
  revalidatePath("/tasks/board");
  revalidatePath(`/tasks/${taskId}`);
  return { ok: true };
}
