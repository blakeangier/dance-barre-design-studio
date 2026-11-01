import { Suspense } from "react";
import Link from "next/link";
import { firstQueryValue, noticeText } from "@/lib/auth/notices";
import { MIN_PASSWORD_LENGTH } from "@/lib/auth/password";
import { safeNextPath } from "@/lib/auth/redirect";
import { sendMagicLink, signIn } from "@/app/login/actions";
import { BrandLogo } from "@/components/brand/brand-logo";
import { StatusNote } from "@/components/shell/status-note";

type LoginProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export const metadata = {
  title: "Sign in",
};

export default function LoginPage(props: LoginProps) {
  return (
    <main className="mx-auto flex min-h-full w-full max-w-md flex-col justify-center px-4 py-10">
      <BrandLogo priority className="h-auto w-full max-w-[280px]" />
      <h1 className="mt-4 font-serif text-4xl text-ink">Design Studio</h1>
      <p className="mt-3 text-base leading-relaxed text-muted">
        Manufacturing workspace for the costume shop. An owner creates your
        account. There is no public sign-up.
      </p>
      <Suspense fallback={null}>
        <LoginForms searchParams={props.searchParams} />
      </Suspense>
    </main>
  );
}

async function LoginForms({
  searchParams,
}: {
  searchParams: LoginProps["searchParams"];
}) {
  const params = await searchParams;
  const notice = noticeText(firstQueryValue(params.notice));
  const nextPath = safeNextPath(firstQueryValue(params.next));

  return (
    <div className="mt-6 flex flex-col gap-4">
      {notice ? <StatusNote>{notice}</StatusNote> : null}
      <form
        action={signIn}
        className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-5"
      >
        <h2 className="font-serif text-2xl text-ink">Sign in</h2>
        <input type="hidden" name="next" value={nextPath} />
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
        <label className="text-sm font-medium" htmlFor="password">
          Password
        </label>
        <input
          id="password"
          name="password"
          type="password"
          autoComplete="current-password"
          required
          minLength={MIN_PASSWORD_LENGTH}
          className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
        />
        <Link
          href="/forgot-password"
          className="inline-flex min-h-11 items-center self-start text-sm font-medium text-ink underline decoration-line underline-offset-4"
        >
          Forgot password?
        </Link>
        <button
          type="submit"
          className="mt-2 min-h-12 rounded-full bg-ink px-4 text-base font-medium text-white"
        >
          Sign in
        </button>
      </form>
      <form
        action={sendMagicLink}
        className="flex flex-col gap-3 rounded-2xl border border-dashed border-line bg-card/70 p-5"
      >
        <h2 className="font-serif text-2xl text-ink">Email me a link</h2>
        <p className="text-sm leading-relaxed text-muted">
          This works once email sending is connected (Resend, later). Until
          then, use the password from the account setup script.
        </p>
        <label className="text-sm font-medium" htmlFor="magic-email">
          Email
        </label>
        <input
          id="magic-email"
          name="email"
          type="email"
          autoComplete="username"
          required
          className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
        />
        <button
          type="submit"
          className="min-h-12 rounded-full border border-ink px-4 text-base font-medium text-ink"
        >
          Send link
        </button>
      </form>
    </div>
  );
}
