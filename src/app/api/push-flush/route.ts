import { createAdminClient } from "@/lib/supabase/admin";
import { shouldDeliverQueued, summarizeQueued } from "@/lib/push/quiet-hours";
import webpush from "web-push";

type PendingRow = {
  id: number;
  user_id: string;
  title: string;
  body: string;
  url: string | null;
  event_kind: string;
};

type SubscriptionRow = {
  id: number;
  endpoint: string;
  keys: { p256dh?: string; auth?: string };
};

export async function GET(request: Request) {
  const cronSecret = process.env.CRON_SECRET;
  const header = request.headers.get("authorization");
  if (!cronSecret || header !== `Bearer ${cronSecret}`) {
    return Response.json({ ok: false }, { status: 401 });
  }

  let admin;
  try {
    admin = createAdminClient();
  } catch {
    return Response.json(
      { ok: false, reason: "missing-secret" },
      { status: 500 },
    );
  }

  const { data: settings, error: settingsError } = await admin
    .from("push_settings")
    .select("enabled")
    .eq("id", 1)
    .maybeSingle();
  if (settingsError) {
    return Response.json({ ok: false }, { status: 500 });
  }
  const now = new Date();
  if (!shouldDeliverQueued(Boolean(settings?.enabled), new Date(0), now)) {
    return Response.json({ ok: true, flushed: 0, reason: "master-off" });
  }

  const { data: pending, error: pendingError } = await admin
    .from("pending_notifications")
    .select("id, user_id, title, body, url, event_kind")
    .is("sent_at", null)
    .lte("deliver_at", now.toISOString())
    .order("created_at");
  if (pendingError) {
    return Response.json({ ok: false }, { status: 500 });
  }
  const due = (pending ?? []) as PendingRow[];
  if (due.length === 0) {
    return Response.json({ ok: true, flushed: 0, reason: "empty" });
  }

  const publicKey = process.env.VAPID_PUBLIC_KEY?.trim();
  const privateKey = process.env.VAPID_PRIVATE_KEY?.trim();
  const subject = process.env.VAPID_SUBJECT?.trim();
  if (!publicKey || !privateKey || !subject) {
    return Response.json({ ok: true, flushed: 0, reason: "missing-vapid" });
  }
  webpush.setVapidDetails(subject, publicKey, privateKey);

  const byUser = new Map<string, PendingRow[]>();
  for (const row of due) {
    const list = byUser.get(row.user_id) ?? [];
    list.push(row);
    byUser.set(row.user_id, list);
  }

  let flushed = 0;
  for (const [userId, items] of byUser) {
    const summary = summarizeQueued(items);
    const { data: subscriptions } = await admin
      .from("push_subscriptions")
      .select("id, endpoint, keys")
      .eq("user_id", userId)
      .is("revoked_at", null);
    const targets = (subscriptions ?? []) as SubscriptionRow[];
    if (targets.length === 0) continue;

    let delivered = false;
    for (const target of targets) {
      const p256dh = target.keys?.p256dh;
      const auth = target.keys?.auth;
      if (!p256dh || !auth) continue;
      try {
        await webpush.sendNotification(
          { endpoint: target.endpoint, keys: { p256dh, auth } },
          JSON.stringify({
            title: summary.title,
            body: summary.body,
            url: items[0]?.url || "/",
          }),
        );
        await admin
          .from("push_subscriptions")
          .update({ last_used_at: now.toISOString() })
          .eq("id", target.id);
        delivered = true;
      } catch (error) {
        const status =
          error && typeof error === "object" && "statusCode" in error
            ? (error as { statusCode?: number }).statusCode
            : null;
        if (status === 404 || status === 410) {
          await admin
            .from("push_subscriptions")
            .update({ revoked_at: now.toISOString() })
            .eq("id", target.id);
        }
      }
    }
    if (!delivered) continue;
    await admin
      .from("pending_notifications")
      .update({ sent_at: now.toISOString() })
      .in(
        "id",
        items.map((item) => item.id),
      );
    await admin.from("notification_log").insert({
      event_kind: items[0]!.event_kind,
      recipient_id: userId,
      title: summary.title,
      body: summary.body,
      status: "sent",
      detail:
        items.length === 1
          ? "Delivered from the quiet-hours queue."
          : `Delivered ${items.length} queued notices as one summary.`,
      created_by: null,
    });
    flushed += 1;
  }

  return Response.json({ ok: true, flushed });
}
