import Link from "next/link";

export function OrderTabs({ current }: { current: "orders" | "programs" }) {
  const item = (href: string, label: string, active: boolean) => (
    <Link
      href={href}
      aria-current={active ? "page" : undefined}
      className={`inline-flex min-h-12 flex-1 items-center justify-center rounded-full px-4 text-sm font-medium ${
        active ? "bg-ink text-white" : "border border-ink text-ink"
      }`}
    >
      {label}
    </Link>
  );

  return (
    <nav className="flex gap-2" aria-label="Order views">
      {item("/production-orders", "Orders", current === "orders")}
      {item("/production-orders/programs", "Programs", current === "programs")}
    </nav>
  );
}
