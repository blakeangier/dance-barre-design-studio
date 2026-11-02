import Link from "next/link";
import { redirect } from "next/navigation";
import { Suspense } from "react";
import { savePushPreferences } from "@/app/(workspace)/account/notifications/actions";
import { EnableNotifications } from "@/app/(workspace)/account/notifications/enable-button";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canSendAnnouncement } from "@/lib/push/policy";
import { firstQueryValue } from "@/lib/auth/notices";
import { getSessionState } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Notifications" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

const NOTICES: Record<string, { tone: "ok" | "error"; text: string }> = {
  saved: { tone: "ok", text: "Your notification choices are saved." },
  failed: { tone: "error", text: "Those choices did not save." },
};

export default function NotificationsPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <NotificationsScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function NotificationsScreen({
  searchParams,
}: {
  searchParams: PageProps["searchParams"];
}) {
  const state = await getSessionState();
  if (state.status === "anonymous") redirect("/login");
  if (state.status !== "ready") return <NoAccess reason={state.status} />;
  const params = await searchParams;
  const notice = NOTICES[firstQueryValue(params.notice) ?? ""];
  const supabase = await createClient();
  const { data: prefs } = await supabase
    .from("push_preferences")
    .select("shift_changes, task_assigned, alteration_due, announcements")
    .eq("user_id", state.profile.id)
    .maybeSingle();
  const choices = {
    shiftChanges: prefs?.shift_changes ?? true,
    taskAssigned: prefs?.task_assigned ?? true,
    alterationDue: prefs?.alteration_due ?? true,
    announcements: prefs?.announcements ?? true,
  };

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/account" className="text-sm text-muted">
        My account
      </Link>
      <div>
        <h1 className="font-serif text-3xl text-ink">Notifications</h1>
        <p className="mt-2 text-sm leading-relaxed text-muted">
          Tap Enable notifications yourself. On iPhone that only works after the
          app is on the Home Screen. Nothing is sent until an owner turns
          notifications on.
        </p>
      </div>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      <section className="rounded-2xl border border-line bg-card p-4">
        <h2 className="font-serif text-2xl text-ink">This device</h2>
        <div className="mt-3">
          <EnableNotifications />
        </div>
        <Link
          href="/install"
          className="mt-3 inline-flex min-h-11 items-center text-sm"
        >
          Add to Home Screen
        </Link>
      </section>
      <form
        action={savePushPreferences}
        className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
      >
        <h2 className="font-serif text-2xl text-ink">What to send me</h2>
        <Preference
          name="shiftChanges"
          label="Shift changes"
          checked={choices.shiftChanges}
        />
        <Preference
          name="taskAssigned"
          label="Task assigned"
          checked={choices.taskAssigned}
        />
        <Preference
          name="alterationDue"
          label="Alteration due"
          checked={choices.alterationDue}
        />
        <Preference
          name="announcements"
          label="Announcements"
          checked={choices.announcements}
        />
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
        >
          Save choices
        </button>
      </form>
      {canSendAnnouncement(state.profile) ? (
        <Link href="/notifications" className="text-sm font-medium text-ink">
          Send an announcement
        </Link>
      ) : null}
    </div>
  );
}

function Preference({
  name,
  label,
  checked,
}: {
  name: string;
  label: string;
  checked: boolean;
}) {
  return (
    <label className="flex min-h-11 items-center gap-2 text-sm">
      <input type="checkbox" name={name} defaultChecked={checked} />
      {label}
    </label>
  );
}
