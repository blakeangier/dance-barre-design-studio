export function StatusNote({
  children,
  tone = "ok",
}: {
  children: string;
  tone?: "ok" | "error";
}) {
  const error = tone === "error";

  return (
    <p
      role={error ? "alert" : "status"}
      className={`rounded-xl border px-4 py-3 text-sm text-ink ${
        error ? "border-red bg-card" : "border-teal bg-teal/30"
      }`}
    >
      {children}
    </p>
  );
}
