import { redirect } from "next/navigation";
import { Suspense } from "react";
import { changePassword } from "@/app/(workspace)/account/actions";
import { updateMyDetails } from "@/app/(workspace)/actions";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { isPasswordIssue, passwordIssueText } from "@/lib/auth/password";
import { firstQueryValue } from "@/lib/auth/notices";
import { getSessionState } from "@/lib/auth/session";

export const metadata = { title: "My account" };

type AccountProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

const ACTION_NOTICES: Record<string, { tone: "ok" | "error"; text: string }> = {
  saved: {
    tone: "ok",
    text: "Your password is changed. Use it the next time you sign in.",
  },
  wrong: {
    tone: "error",
    text: "The current password did not match.",
  },
  failed: {
    tone: "error",
    text: "The password did not change. Try again.",
  },
  name: {
    tone: "error",
    text: "Enter a name, up to 120 characters.",
  },
  phone: {
    tone: "error",
    text: "Phone numbers can be up to 40 characters.",
  },
  "details-saved": {
    tone: "ok",
    text: "Your name and phone are saved.",
  },
  "save-failed": {
    tone: "error",
    text: "That could not be saved. Try again.",
  },
};

export default function AccountPage(props: AccountProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <AccountScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function AccountScreen({
  searchParams,
}: {
  searchParams: AccountProps["searchParams"];
}) {
  const state = await getSessionState();
  if (state.status === "anonymous") redirect("/login");
  if (state.status !== "ready") return <NoAccess reason={state.status} />;

  const params = await searchParams;
  const code = firstQueryValue(params.notice);
  const notice = code
    ? isPasswordIssue(code)
      ? { tone: "error" as const, text: passwordIssueText(code) }
      : ACTION_NOTICES[code]
    : undefined;

  return (
    <div className="mx-auto flex w-full max-w-md flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">My account</h1>
      <p className="text-sm leading-relaxed text-muted">
        Change the password for your own sign-in. There is no reset email yet.
      </p>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      <section className="rounded-2xl border border-line bg-card p-4">
        <h2 className="font-serif text-2xl text-ink">Signed in as</h2>
        <form action={updateMyDetails} className="mt-3 flex flex-col gap-3">
          <input type="hidden" name="next" value="/account" />
          <p className="text-sm text-muted">
            Email stays with the login: {state.profile.email}
          </p>
          <label className="text-sm font-medium" htmlFor="fullName">
            Name
          </label>
          <input
            id="fullName"
            name="fullName"
            required
            maxLength={120}
            defaultValue={state.profile.fullName}
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
          />
          <label className="text-sm font-medium" htmlFor="phone">
            Phone
          </label>
          <input
            id="phone"
            name="phone"
            type="tel"
            autoComplete="tel"
            maxLength={40}
            defaultValue={state.profile.phone ?? ""}
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
          >
            Save name and phone
          </button>
        </form>
      </section>
      <form
        action={changePassword}
        className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
      >
        <h2 className="font-serif text-2xl text-ink">Change password</h2>
        <label className="text-sm font-medium" htmlFor="currentPassword">
          Current password
        </label>
        <input
          id="currentPassword"
          name="currentPassword"
          type="password"
          autoComplete="current-password"
          required
          className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
        />
        <label className="text-sm font-medium" htmlFor="newPassword">
          New password
        </label>
        <input
          id="newPassword"
          name="newPassword"
          type="password"
          autoComplete="new-password"
          required
          minLength={10}
          className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
        />
        <p className="text-sm text-muted">At least 10 characters.</p>
        <label className="text-sm font-medium" htmlFor="confirmPassword">
          Confirm new password
        </label>
        <input
          id="confirmPassword"
          name="confirmPassword"
          type="password"
          autoComplete="new-password"
          required
          minLength={10}
          className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
        />
        <button
          type="submit"
          className="mt-1 min-h-12 rounded-full bg-ink px-4 text-base font-medium text-white"
        >
          Change password
        </button>
      </form>
    </div>
  );
}
