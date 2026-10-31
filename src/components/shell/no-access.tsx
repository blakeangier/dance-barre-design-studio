const REASONS: Record<string, { title: string; body: string }> = {
  denied: {
    title: "You don't have access to this area",
    body: "The menu only lists areas for your role. If you need this one, ask an owner.",
  },
  inactive: {
    title: "This account is turned off",
    body: "Ask an owner if you still need to sign in.",
  },
  "missing-profile": {
    title: "Your login has no profile yet",
    body: "Apply the database migrations, then sign out and back in. The profile row is created from the account's app metadata.",
  },
  "database-error": {
    title: "The database did not answer",
    body: "Check that the dev Supabase project is reachable and that .env.local points at it.",
  },
  unconfigured: {
    title: "Supabase is not connected",
    body: "Copy .env.example to .env.local and fill in the dev project URL and publishable key.",
  },
};

export function NoAccess({ reason }: { reason: string }) {
  const copy = REASONS[reason] ?? REASONS.denied;

  return (
    <section className="rounded-2xl border border-line bg-card p-5">
      <h1 className="font-serif text-3xl text-ink">{copy?.title}</h1>
      <p className="mt-3 max-w-prose leading-relaxed text-muted">
        {copy?.body}
      </p>
    </section>
  );
}
