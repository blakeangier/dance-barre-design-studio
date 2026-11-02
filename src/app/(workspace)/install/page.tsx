import Link from "next/link";
import { redirect } from "next/navigation";
import { Suspense } from "react";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { getSessionState } from "@/lib/auth/session";

export const metadata = { title: "Add to Home Screen" };

export default function InstallPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Install />
    </Suspense>
  );
}

async function Install() {
  const state = await getSessionState();
  if (state.status === "anonymous") redirect("/login");
  if (state.status !== "ready") return <NoAccess reason={state.status} />;

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/account/notifications" className="text-sm text-muted">
        Notifications
      </Link>
      <h1 className="font-serif text-3xl text-ink">Add to Home Screen</h1>
      <p className="text-sm leading-relaxed text-muted">
        The home-screen name is Dance Barre Design Studio. Sign in with Safari
        or Chrome first, then add the icon. On iPhone, notifications only work
        from that icon, and only after you tap Enable notifications yourself.
      </p>
      <section className="rounded-2xl border border-line bg-card p-4">
        <h2 className="font-serif text-2xl text-ink">iPhone</h2>
        <ol className="mt-3 list-decimal space-y-2 pl-5 text-sm leading-relaxed">
          <li>Open this site in Safari.</li>
          <li>Tap Share.</li>
          <li>Tap Add to Home Screen.</li>
          <li>Open the new icon, then tap Enable notifications.</li>
        </ol>
      </section>
      <section className="rounded-2xl border border-line bg-card p-4">
        <h2 className="font-serif text-2xl text-ink">Android</h2>
        <ol className="mt-3 list-decimal space-y-2 pl-5 text-sm leading-relaxed">
          <li>Open this site in Chrome.</li>
          <li>Tap the menu, then Install app or Add to Home screen.</li>
          <li>Open the icon and tap Enable notifications.</li>
        </ol>
      </section>
    </div>
  );
}
