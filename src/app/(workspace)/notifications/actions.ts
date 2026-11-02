"use server";

import { redirect } from "next/navigation";
import { getSessionState } from "@/lib/auth/session";
import { canManagePushSettings, canSendAnnouncement } from "@/lib/push/policy";
import { notifyUser } from "@/lib/push/send";
import { createClient } from "@/lib/supabase/server";

function back(notice: string): never {
  redirect(`/notifications?notice=${notice}`);
}

export async function savePushMaster(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canManagePushSettings(state.profile)) back("denied");
  const supabase = await createClient();
  const { error } = await supabase
    .from("push_settings")
    .update({
      enabled: formData.get("enabled") === "on",
      notify_shift_changes: formData.get("shiftChanges") === "on",
      notify_task_assigned: formData.get("taskAssigned") === "on",
      notify_alteration_due: formData.get("alterationDue") === "on",
      notify_announcements: formData.get("announcements") === "on",
      updated_by: state.profile.id,
    })
    .eq("id", 1);
  back(error ? "failed" : "saved");
}

export async function sendAnnouncement(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canSendAnnouncement(state.profile)) back("denied");
  const title = String(formData.get("title") ?? "").trim();
  const message = String(formData.get("message") ?? "").trim();
  const recipient = String(formData.get("recipient") ?? "all");
  if (!title || title.length > 80 || !message || message.length > 180) {
    back("invalid");
  }
  const supabase = await createClient();
  const { data: settings } = await supabase
    .from("push_settings")
    .select("enabled, notify_announcements")
    .eq("id", 1)
    .maybeSingle();
  if (!settings?.enabled || !settings.notify_announcements) back("off");

  let people: { id: string }[] = [];
  if (recipient === "all") {
    const { data } = await supabase
      .from("profiles")
      .select("id")
      .eq("is_active", true);
    people = (data ?? []) as { id: string }[];
  } else if (
    /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
      recipient,
    )
  ) {
    people = [{ id: recipient }];
  } else {
    back("invalid");
  }

  for (const person of people) {
    await notifyUser({
      recipientId: person.id,
      actorId: state.profile.id,
      event: "announcements",
      title,
      body: message,
      url: "/",
    });
  }
  back("sent");
}
