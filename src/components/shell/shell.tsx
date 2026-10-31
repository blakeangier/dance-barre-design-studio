import { redirect } from "next/navigation";
import { areasFor, ROLE_LABELS } from "@/lib/auth/permissions";
import { signOut } from "@/app/login/actions";
import { getSessionState } from "@/lib/auth/session";
import { AppNav } from "@/components/shell/app-nav";
import { NoAccess } from "@/components/shell/no-access";

export async function Shell({ children }: { children: React.ReactNode }) {
  const state = await getSessionState();

  if (state.status === "anonymous") redirect("/login");

  if (state.status !== "ready") {
    return (
      <main id="content" className="mx-auto w-full max-w-3xl px-4 py-8">
        <NoAccess reason={state.status} />
      </main>
    );
  }

  const items = areasFor(state.profile).map((area) => ({
    href: area.href,
    label: area.label,
  }));

  return (
    <div className="min-h-full">
      <a
        href="#content"
        className="sr-only focus:not-sr-only focus:absolute focus:top-2 focus:left-2 focus:z-20 focus:rounded-md focus:bg-card focus:px-3 focus:py-2"
      >
        Skip to content
      </a>
      <header className="bg-wine text-cream">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-3 px-4 py-3">
          <div>
            <p className="font-serif text-xl leading-none">Dance Barre</p>
            <p className="mt-1 text-xs tracking-[0.14em] text-gold uppercase">
              Design Studio
            </p>
          </div>
          <div className="flex items-center gap-3">
            <p className="hidden text-right text-sm sm:block">
              <span className="block leading-tight">
                {state.profile.fullName}
              </span>
              <span className="block text-xs text-cream/75">
                {ROLE_LABELS[state.profile.role]}
                {state.profile.canPurchase ? " · Purchasing" : ""}
              </span>
            </p>
            <form action={signOut}>
              <button
                type="submit"
                className="min-h-11 rounded-full border border-cream/40 px-4 text-sm"
              >
                Sign out
              </button>
            </form>
          </div>
        </div>
        <div className="h-0.5 bg-gold" aria-hidden="true" />
      </header>
      <div className="mx-auto flex w-full max-w-6xl flex-col md:min-h-[calc(100vh-4.5rem)] md:flex-row">
        <AppNav items={items} />
        <main id="content" className="w-full px-4 py-5">
          {children}
        </main>
      </div>
    </div>
  );
}
