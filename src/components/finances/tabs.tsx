import Link from "next/link";

const TABS = [
  { href: "/finances", label: "Overview", id: "overview" },
  { href: "/finances/startup", label: "Startup", id: "startup" },
  { href: "/finances/running", label: "Running", id: "running" },
  { href: "/finances/payroll", label: "Payroll", id: "payroll" },
  { href: "/finances/cards", label: "Card", id: "cards" },
  {
    href: "/finances/miscellaneous",
    label: "Miscellaneous",
    id: "miscellaneous",
  },
] as const;

export function FinanceTabs({
  current,
}: {
  current: (typeof TABS)[number]["id"];
}) {
  return (
    <nav className="flex flex-wrap gap-2" aria-label="Finances">
      {TABS.map((tab) => (
        <Link
          key={tab.id}
          href={tab.href}
          aria-current={tab.id === current ? "page" : undefined}
          className={`inline-flex min-h-11 items-center rounded-full px-3 text-sm font-medium ${
            tab.id === current
              ? "bg-ink text-white"
              : "border border-ink text-ink"
          }`}
        >
          {tab.label}
        </Link>
      ))}
    </nav>
  );
}
