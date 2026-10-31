export function StatusNote({ children }: { children: string }) {
  return (
    <p
      role="status"
      className="rounded-xl border border-teal bg-teal/30 px-4 py-3 text-sm text-ink"
    >
      {children}
    </p>
  );
}
