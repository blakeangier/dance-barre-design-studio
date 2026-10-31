import { Suspense } from "react";
import { firstQueryValue, noticeText } from "@/lib/auth/notices";
import { safeNextPath } from "@/lib/auth/redirect";
import { sendMagicLink, signIn } from "@/app/login/actions";
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
      <p className="text-xs font-semibold tracking-[0.16em] text-gold uppercase">
        Dance Barre
      </p>
      <h1 className="mt-2 font-serif text-4xl text-wine-deep">Design Studio</h1>
      <p className="mt-3 text-base leading-relaxed text-ink/80">
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
        <h2 className="font-serif text-2xl text-wine">Sign in</h2>
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
          className="min-h-12 rounded-xl border border-line bg-cream px-3 text-base"
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
          minLength={12}
          className="min-h-12 rounded-xl border border-line bg-cream px-3 text-base"
        />
        <button
          type="submit"
          className="mt-2 min-h-12 rounded-full bg-wine px-4 text-base font-medium text-cream"
        >
          Sign in
        </button>
      </form>
      <form
        action={sendMagicLink}
        className="flex flex-col gap-3 rounded-2xl border border-dashed border-line bg-card/70 p-5"
      >
        <h2 className="font-serif text-2xl text-wine">Email me a link</h2>
        <p className="text-sm leading-relaxed text-ink/75">
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
          className="min-h-12 rounded-xl border border-line bg-cream px-3 text-base"
        />
        <button
          type="submit"
          className="min-h-12 rounded-full border border-wine px-4 text-base font-medium text-wine"
        >
          Send link
        </button>
      </form>
    </div>
  );
}
