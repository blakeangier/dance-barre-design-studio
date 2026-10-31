import { redirect } from "next/navigation";
import { areasFor, ROLE_LABELS } from "@/lib/auth/permissions";
import { ROLE_BADGE } from "@/lib/brand";
import { signOut } from "@/app/login/actions";
import { getSessionState } from "@/lib/auth/session";
import { BrandLogo } from "@/components/brand/brand-logo";
import { AccountLink } from "@/components/shell/account-link";
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
      <header className="border-b border-line bg-card">
        <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 px-4 py-3">
          <div className="flex items-center gap-3">
            <BrandLogo className="h-12 w-auto sm:h-14" />
            <p className="hidden text-sm font-medium text-muted sm:block">
              Design Studio
            </p>
          </div>
          <div className="flex items-center gap-2 sm:gap-3">
            <p className="hidden text-right text-sm sm:block">
              <span className="block leading-tight">
                {state.profile.fullName}
              </span>
              <span className="mt-1 flex justify-end gap-1">
                <span
                  className={`rounded-full px-2 py-0.5 text-xs font-medium ${ROLE_BADGE[state.profile.role]}`}
                >
                  {ROLE_LABELS[state.profile.role]}
                </span>
                {state.profile.canPurchase ? (
                  <span className="rounded-full border border-purple bg-card px-2 py-0.5 text-xs font-medium text-ink">
                    Purchasing
                  </span>
                ) : null}
              </span>
            </p>
            <AccountLink />
            <form action={signOut}>
              <button
                type="submit"
                className="min-h-11 rounded-full border border-ink bg-card px-4 text-sm font-medium text-ink"
              >
                Sign out
              </button>
            </form>
          </div>
        </div>
        <div className="brand-stripe" aria-hidden="true" />
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
