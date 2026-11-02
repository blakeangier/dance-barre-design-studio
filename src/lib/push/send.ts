import "server-only";

import webpush from "web-push";
import { pushDelivery, type PushEvent } from "@/lib/push/policy";
import { createClient } from "@/lib/supabase/server";

type SettingsRow = {
  enabled: boolean;
  notify_shift_changes: boolean;
  notify_task_assigned: boolean;
  notify_alteration_due: boolean;
  notify_announcements: boolean;
};

type PreferenceRow = {
  shift_changes: boolean;
  task_assigned: boolean;
  alteration_due: boolean;
  announcements: boolean;
};

type TargetRow = {
  subscription_id: number;
  endpoint: string;
  p256dh: string;
  auth_key: string;
};

const EVENT_COLUMN: Record<PushEvent, keyof SettingsRow> = {
  shift_changes: "notify_shift_changes",
  task_assigned: "notify_task_assigned",
  alteration_due: "notify_alteration_due",
  announcements: "notify_announcements",
};

const PREF_COLUMN: Record<PushEvent, keyof PreferenceRow> = {
  shift_changes: "shift_changes",
  task_assigned: "task_assigned",
  alteration_due: "alteration_due",
  announcements: "announcements",
};

export async function notifyUser(input: {
  recipientId: string;
  event: PushEvent;
  title: string;
  body: string;
  url?: string;
  actorId: string;
}): Promise<void> {
  if (!input.recipientId || input.recipientId === input.actorId) return;
  const title = clip(input.title, 80);
  const body = clip(input.body, 200);
  if (!title || !body) return;

  try {
    const supabase = await createClient();
    const [settingsResult, preferenceResult] = await Promise.all([
      supabase
        .from("push_settings")
        .select(
          "enabled, notify_shift_changes, notify_task_assigned, notify_alteration_due, notify_announcements",
        )
        .eq("id", 1)
        .maybeSingle(),
      supabase
        .from("push_preferences")
        .select("shift_changes, task_assigned, alteration_due, announcements")
        .eq("user_id", input.recipientId)
        .maybeSingle(),
    ]);
    if (settingsResult.error) return;
    const settings = settingsResult.data as SettingsRow | null;
    const preference = preferenceResult.data as PreferenceRow | null;
    const decision = pushDelivery({
      masterOn: Boolean(settings?.enabled),
      eventOn: settings ? Boolean(settings[EVENT_COLUMN[input.event]]) : false,
      userOn: preference ? Boolean(preference[PREF_COLUMN[input.event]]) : true,
    });
    if (decision !== "send") {
      if (input.event === "announcements" && decision === "master-off") {
        await record(
          supabase,
          input,
          title,
          body,
          "skipped",
          "Push notifications are off.",
        );
      }
      return;
    }

    const publicKey = process.env.VAPID_PUBLIC_KEY?.trim();
    const privateKey = process.env.VAPID_PRIVATE_KEY?.trim();
    const subject = process.env.VAPID_SUBJECT?.trim();
    if (!publicKey || !privateKey || !subject) {
      await record(
        supabase,
        input,
        title,
        body,
        "skipped",
        "VAPID keys are not set on the server.",
      );
      return;
    }

    const targets = await supabase.rpc("push_targets", {
      recipient: input.recipientId,
      event_kind: input.event,
    });
    const rows = (targets.data ?? []) as TargetRow[];
    if (targets.error || rows.length === 0) {
      await record(
        supabase,
        input,
        title,
        body,
        "skipped",
        "No active subscription, or this person turned this notice off.",
      );
      return;
    }

    webpush.setVapidDetails(subject, publicKey, privateKey);
    const payload = JSON.stringify({
      title,
      body,
      url: input.url || "/",
    });
    for (const row of rows) {
      try {
        await webpush.sendNotification(
          {
            endpoint: row.endpoint,
            keys: { p256dh: row.p256dh, auth: row.auth_key },
          },
          payload,
        );
        await supabase.rpc("touch_push_subscription", {
          subscription_id: row.subscription_id,
        });
        await record(supabase, input, title, body, "sent", null);
      } catch (error) {
        const status = statusCode(error);
        if (status === 404 || status === 410) {
          await supabase.rpc("revoke_push_subscription", {
            subscription_id: row.subscription_id,
          });
          await record(
            supabase,
            input,
            title,
            body,
            "revoked",
            "The browser subscription expired.",
          );
        } else {
          await record(
            supabase,
            input,
            title,
            body,
            "failed",
            "The push was not accepted.",
          );
        }
      }
    }
  } catch {
    // A missed notification must not undo the shift, task, or announcement save.
  }
}

export async function notifyShiftChange(input: {
  recipientId: string;
  actorId: string;
  change: "created" | "changed" | "cancelled";
  when: string;
  start?: string;
  end?: string;
}): Promise<void> {
  const when = input.when;
  const clock = input.start && input.end ? ` ${input.start}–${input.end}` : "";
  const title =
    input.change === "cancelled"
      ? "Shift cancelled"
      : input.change === "changed"
        ? "Shift changed"
        : "Shift added";
  await notifyUser({
    recipientId: input.recipientId,
    actorId: input.actorId,
    event: "shift_changes",
    title,
    body: clip(`${when}${clock}`, 200),
    url: "/scheduling",
  });
}

// Called when an alteration is handed to someone. The alterations table has
// no due date yet. This is the hook for that notice.
export async function notifyAlterationDue(input: {
  recipientId: string;
  actorId: string;
  summary: string;
}): Promise<void> {
  await notifyUser({
    recipientId: input.recipientId,
    actorId: input.actorId,
    event: "alteration_due",
    title: "Alteration",
    body: clip(input.summary, 200),
    url: "/",
  });
}

async function record(
  supabase: Awaited<ReturnType<typeof createClient>>,
  input: {
    recipientId: string;
    event: PushEvent;
    actorId: string;
  },
  title: string,
  body: string,
  status: "sent" | "skipped" | "failed" | "revoked",
  detail: string | null,
) {
  await supabase.from("notification_log").insert({
    event_kind: input.event,
    recipient_id: input.recipientId,
    title,
    body,
    status,
    detail,
    created_by: input.actorId,
  });
}

function clip(value: string, max: number): string {
  const trimmed = value.trim();
  return trimmed.length <= max ? trimmed : trimmed.slice(0, max);
}

function statusCode(error: unknown): number | null {
  if (!error || typeof error !== "object" || !("statusCode" in error))
    return null;
  const code = (error as { statusCode?: unknown }).statusCode;
  return typeof code === "number" ? code : null;
}
