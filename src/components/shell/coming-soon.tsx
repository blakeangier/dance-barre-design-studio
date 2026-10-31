export function ComingSoon({
  title,
  summary,
}: {
  title: string;
  summary: string;
}) {
  return (
    <section className="rounded-2xl border border-line bg-card p-5 shadow-sm">
      <p className="text-xs font-semibold tracking-[0.16em] text-gold uppercase">
        Coming in a later phase
      </p>
      <h1 className="mt-2 font-serif text-3xl text-wine-deep">{title}</h1>
      <p className="mt-3 max-w-prose text-base leading-relaxed text-ink/80">
        {summary}
      </p>
    </section>
  );
}
