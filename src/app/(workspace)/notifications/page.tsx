import Link from "next/link";
import { redirect } from "next/navigation";
import { Suspense } from "react";
import {
  savePushMaster,
  sendAnnouncement,
} from "@/app/(workspace)/notifications/actions";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { firstQueryValue } from "@/lib/auth/notices";
import { getSessionState } from "@/lib/auth/session";
import { canManagePushSettings, canSendAnnouncement } from "@/lib/push/policy";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Announcements" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

const NOTICES: Record<string, { tone: "ok" | "error"; text: string }> = {
  saved: { tone: "ok", text: "Notification settings are saved." },
  sent: {
    tone: "ok",
    text: "The announcement was handed to notification delivery.",
  },
  off: {
    tone: "error",
    text: "Push notifications are off. Nothing was sent.",
  },
  denied: { tone: "error", text: "You cannot change that." },
  failed: { tone: "error", text: "That did not save." },
  invalid: { tone: "error", text: "Write a title and a short message." },
};

export default function AnnouncementsPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Announcements searchParams={props.searchParams} />
    </Suspense>
  );
}

async function Announcements({
  searchParams,
}: {
  searchParams: PageProps["searchParams"];
}) {
  const state = await getSessionState();
  if (state.status === "anonymous") redirect("/login");
  if (state.status !== "ready") return <NoAccess reason={state.status} />;
  if (!canSendAnnouncement(state.profile)) return <NoAccess reason="denied" />;
  const params = await searchParams;
  const notice = NOTICES[firstQueryValue(params.notice) ?? ""];
  const supabase = await createClient();
  const [settingsResult, peopleResult] = await Promise.all([
    supabase
      .from("push_settings")
      .select(
        "enabled, notify_shift_changes, notify_task_assigned, notify_alteration_due, notify_announcements",
      )
      .eq("id", 1)
      .maybeSingle(),
    supabase
      .from("profiles")
      .select("id, full_name")
      .eq("is_active", true)
      .order("full_name"),
  ]);
  const settings = settingsResult.data;
  const owner = canManagePushSettings(state.profile);

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/account/notifications" className="text-sm text-muted">
        Notifications
      </Link>
      <div>
        <h1 className="font-serif text-3xl text-ink">Announcements</h1>
        <p className="mt-2 text-sm leading-relaxed text-muted">
          {settings?.enabled
            ? "Push notifications are on."
            : "Push notifications are off. Nothing is sent until an owner turns them on."}
        </p>
      </div>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      {owner ? (
        <form
          action={savePushMaster}
          className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
        >
          <h2 className="font-serif text-2xl text-ink">
            Push notifications on
          </h2>
          <label className="flex min-h-11 items-center gap-2 text-sm">
            <input
              type="checkbox"
              name="enabled"
              defaultChecked={Boolean(settings?.enabled)}
            />
            Push notifications on
          </label>
          <label className="flex min-h-11 items-center gap-2 text-sm">
            <input
              type="checkbox"
              name="shiftChanges"
              defaultChecked={settings?.notify_shift_changes ?? true}
            />
            Shift changes
          </label>
          <label className="flex min-h-11 items-center gap-2 text-sm">
            <input
              type="checkbox"
              name="taskAssigned"
              defaultChecked={settings?.notify_task_assigned ?? true}
            />
            Task assigned
          </label>
          <label className="flex min-h-11 items-center gap-2 text-sm">
            <input
              type="checkbox"
              name="alterationDue"
              defaultChecked={settings?.notify_alteration_due ?? true}
            />
            Alteration due
          </label>
          <label className="flex min-h-11 items-center gap-2 text-sm">
            <input
              type="checkbox"
              name="announcements"
              defaultChecked={settings?.notify_announcements ?? true}
            />
            Announcements
          </label>
          <button
            type="submit"
            className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
          >
            Save notification settings
          </button>
        </form>
      ) : null}
      <form
        action={sendAnnouncement}
        className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
      >
        <h2 className="font-serif text-2xl text-ink">Send an announcement</h2>
        <label className="text-sm font-medium" htmlFor="title">
          Title
        </label>
        <input
          id="title"
          name="title"
          required
          maxLength={80}
          className="min-h-12 rounded-xl border border-line px-3"
        />
        <label className="text-sm font-medium" htmlFor="message">
          Message
        </label>
        <textarea
          id="message"
          name="message"
          required
          maxLength={180}
          rows={3}
          className="rounded-xl border border-line px-3 py-2"
        />
        <label className="text-sm font-medium" htmlFor="recipient">
          Who
        </label>
        <select
          id="recipient"
          name="recipient"
          className="min-h-12 rounded-xl border border-line px-3"
          defaultValue="all"
        >
          <option value="all">Everyone</option>
          {(
            (peopleResult.data ?? []) as { id: string; full_name: string }[]
          ).map((person) => (
            <option key={person.id} value={person.id}>
              {person.full_name}
            </option>
          ))}
        </select>
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
        >
          Send announcement
        </button>
      </form>
    </div>
  );
}
