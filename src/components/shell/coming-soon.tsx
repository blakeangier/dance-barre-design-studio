export function ComingSoon({
  title,
  summary,
}: {
  title: string;
  summary: string;
}) {
  return (
    <section className="rounded-2xl border border-line bg-card p-5 shadow-sm">
      <p className="text-xs font-semibold tracking-[0.16em] text-muted uppercase">
        <span
          className="mr-2 inline-block size-2 rounded-full bg-purple align-middle"
          aria-hidden="true"
        />
        Coming in a later phase
      </p>
      <h1 className="mt-2 font-serif text-3xl text-ink">{title}</h1>
      <p className="mt-3 max-w-prose text-base leading-relaxed text-muted">
        {summary}
      </p>
    </section>
  );
}
