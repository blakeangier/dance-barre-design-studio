export function StatusNote({ children }: { children: string }) {
  return (
    <p
      role="status"
      className="rounded-xl border border-gold/40 bg-gold/10 px-4 py-3 text-sm text-ink"
    >
      {children}
    </p>
  );
}
