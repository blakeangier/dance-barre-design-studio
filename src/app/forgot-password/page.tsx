import { Suspense } from "react";
import Link from "next/link";
import { requestPasswordReset } from "@/app/forgot-password/actions";
import { BrandLogo } from "@/components/brand/brand-logo";
import { StatusNote } from "@/components/shell/status-note";
import { firstQueryValue, noticeText } from "@/lib/auth/notices";

type ForgotProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export const metadata = {
  title: "Forgot password",
};

const SENT =
  "If that email has an account, we sent a link to set a new password. The link expires in one hour.";

export default function ForgotPasswordPage(props: ForgotProps) {
  return (
    <main className="mx-auto flex min-h-full w-full max-w-md flex-col justify-center px-4 py-10">
      <BrandLogo priority className="h-auto w-full max-w-[280px]" />
      <h1 className="mt-4 font-serif text-4xl text-ink">Forgot password</h1>
      <p className="mt-3 text-base leading-relaxed text-muted">
        Enter the email on the account. If it matches, a reset link is on its
        way. There is no public sign-up.
      </p>
      <Suspense fallback={null}>
        <ForgotForm searchParams={props.searchParams} />
      </Suspense>
    </main>
  );
}

async function ForgotForm({
  searchParams,
}: {
  searchParams: ForgotProps["searchParams"];
}) {
  const params = await searchParams;
  const code = firstQueryValue(params.notice);
  const setup = code === "setup" ? noticeText("setup") : null;
  const notice =
    code === "sent"
      ? { tone: "ok" as const, text: SENT }
      : code === "missing"
        ? { tone: "error" as const, text: "Enter your email address." }
        : setup
          ? { tone: "error" as const, text: setup }
          : null;

  return (
    <div className="mt-6 flex flex-col gap-4">
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      <form
        action={requestPasswordReset}
        className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-5"
      >
        <label className="text-sm font-medium" htmlFor="email">
          Email
        </label>
        <input
          id="email"
          name="email"
          type="email"
          autoComplete="username"
          required
          className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
        />
        <button
          type="submit"
          className="mt-2 min-h-12 rounded-full bg-ink px-4 text-base font-medium text-white"
        >
          Send reset link
        </button>
      </form>
      <Link
        href="/login"
        className="inline-flex min-h-11 items-center self-start text-sm font-medium text-ink underline decoration-line underline-offset-4"
      >
        Back to sign in
      </Link>
    </div>
  );
}
