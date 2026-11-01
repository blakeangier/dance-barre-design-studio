import { Suspense } from "react";
import Link from "next/link";
import { setNewPassword } from "@/app/reset-password/actions";
import { BrandLogo } from "@/components/brand/brand-logo";
import { StatusNote } from "@/components/shell/status-note";
import { firstQueryValue } from "@/lib/auth/notices";
import {
  MIN_PASSWORD_LENGTH,
  passwordIssueText,
  WEAK_PASSWORD_TEXT,
  type NewPasswordIssue,
} from "@/lib/auth/password";
import { hasPublicSupabaseEnv } from "@/lib/supabase/env";
import { createClient } from "@/lib/supabase/server";

type ResetProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export const metadata = {
  title: "Set a new password",
};

const LINK_NOTICES = new Set(["expired", "invalid"]);

function isNewPasswordIssue(value: string): value is NewPasswordIssue {
  return value === "short" || value === "mismatch";
}

function formNotice(code: string | undefined): {
  tone: "ok" | "error";
  text: string;
} | null {
  if (!code || LINK_NOTICES.has(code)) return null;
  if (isNewPasswordIssue(code)) {
    return { tone: "error", text: passwordIssueText(code) };
  }
  if (code === "same") {
    return { tone: "error", text: passwordIssueText(code) };
  }
  if (code === "weak") return { tone: "error", text: WEAK_PASSWORD_TEXT };
  if (code === "failed") {
    return {
      tone: "error",
      text: "The password did not change. Try again.",
    };
  }
  return null;
}

export default function ResetPasswordPage(props: ResetProps) {
  return (
    <main className="mx-auto flex min-h-full w-full max-w-md flex-col justify-center px-4 py-10">
      <BrandLogo priority className="h-auto w-full max-w-[280px]" />
      <h1 className="mt-4 font-serif text-4xl text-ink">Set a new password</h1>
      <Suspense fallback={null}>
        <ResetScreen searchParams={props.searchParams} />
      </Suspense>
    </main>
  );
}

async function ResetScreen({
  searchParams,
}: {
  searchParams: ResetProps["searchParams"];
}) {
  const params = await searchParams;
  const code = firstQueryValue(params.notice);
  let signedIn = false;

  if (hasPublicSupabaseEnv() && code !== "expired" && code !== "invalid") {
    const supabase = await createClient();
    const { data } = await supabase.auth.getClaims();
    signedIn = Boolean(data?.claims.sub);
  }

  const showForm = signedIn && !LINK_NOTICES.has(code ?? "");
  const notice = formNotice(code);

  return (
    <div className="mt-6 flex flex-col gap-4">
      {showForm ? (
        <>
          <p className="text-base leading-relaxed text-muted">
            Choose a new password for this account. It needs at least{" "}
            {MIN_PASSWORD_LENGTH} characters.
          </p>
          {notice ? (
            <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
          ) : null}
          <form
            action={setNewPassword}
            className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-5"
          >
            <label className="text-sm font-medium" htmlFor="password">
              New password
            </label>
            <input
              id="password"
              name="password"
              type="password"
              autoComplete="new-password"
              required
              minLength={MIN_PASSWORD_LENGTH}
              className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
            />
            <p className="text-sm text-muted">At least 12 characters.</p>
            <label className="text-sm font-medium" htmlFor="confirm">
              Confirm new password
            </label>
            <input
              id="confirm"
              name="confirm"
              type="password"
              autoComplete="new-password"
              required
              minLength={MIN_PASSWORD_LENGTH}
              className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
            />
            <button
              type="submit"
              className="mt-2 min-h-12 rounded-full bg-ink px-4 text-base font-medium text-white"
            >
              Save new password
            </button>
          </form>
        </>
      ) : (
        <>
          <StatusNote tone="error">
            {code === "expired"
              ? "This reset link has expired. Request a new one."
              : code === "invalid"
                ? "This reset link is invalid. Request a new one."
                : "This reset link is invalid or has expired. Request a new one."}
          </StatusNote>
          <Link
            href="/forgot-password"
            className="inline-flex min-h-12 items-center justify-center rounded-full bg-ink px-4 text-base font-medium text-white"
          >
            Request a new link
          </Link>
        </>
      )}
      <Link
        href="/login"
        className="inline-flex min-h-11 items-center self-start text-sm font-medium text-ink underline decoration-line underline-offset-4"
      >
        Back to sign in
      </Link>
    </div>
  );
}
