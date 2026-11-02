"use server";

import { redirect } from "next/navigation";
import { getSessionState } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

function back(notice: string): never {
  redirect(`/account/notifications?notice=${notice}`);
}

export async function pushPublicKey(): Promise<string | null> {
  const state = await getSessionState();
  if (state.status !== "ready") return null;
  const key = process.env.VAPID_PUBLIC_KEY?.trim();
  return key || null;
}

export async function savePushSubscription(input: {
  endpoint: string;
  p256dh: string;
  auth: string;
  userAgent: string;
}): Promise<{ ok: true } | { ok: false; message: string }> {
  const state = await getSessionState();
  if (state.status !== "ready") {
    return { ok: false, message: "Sign in again, then try the button." };
  }
  const endpoint = input.endpoint.trim();
  const p256dh = input.p256dh.trim();
  const auth = input.auth.trim();
  if (
    !endpoint.startsWith("https://") ||
    endpoint.length > 2000 ||
    p256dh.length < 8 ||
    auth.length < 8
  ) {
    return { ok: false, message: "This browser did not share a subscription." };
  }
  const supabase = await createClient();
  const { error } = await supabase.from("push_subscriptions").upsert(
    {
      user_id: state.profile.id,
      endpoint,
      keys: { p256dh, auth },
      user_agent: input.userAgent.slice(0, 400) || null,
      revoked_at: null,
    },
    { onConflict: "user_id,endpoint" },
  );
  if (error) return { ok: false, message: "That subscription did not save." };
  return { ok: true };
}

export async function savePushPreferences(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const supabase = await createClient();
  const { error } = await supabase.from("push_preferences").upsert({
    user_id: state.profile.id,
    shift_changes: formData.get("shiftChanges") === "on",
    task_assigned: formData.get("taskAssigned") === "on",
    alteration_due: formData.get("alterationDue") === "on",
    announcements: formData.get("announcements") === "on",
  });
  back(error ? "failed" : "saved");
}
