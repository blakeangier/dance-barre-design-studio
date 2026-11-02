import Link from "next/link";

const TABS = [
  { href: "/finances", label: "Spend to date", id: "spend" },
  { href: "/finances/cost", label: "Startup vs cost", id: "cost" },
  {
    href: "/finances/projection",
    label: "12-month projection",
    id: "projection",
  },
  { href: "/finances/people", label: "People and invoices", id: "people" },
  { href: "/finances/contracts", label: "Contracts", id: "contracts" },
  { href: "/finances/expenses", label: "Expense log", id: "expenses" },
  {
    href: "/finances/equipment",
    label: "Equipment and lease",
    id: "equipment",
  },
  {
    href: "/finances/outside-costumes",
    label: "Outside costumes",
    id: "outside",
  },
  {
    href: "/finances/past-spend",
    label: "Past costume spend",
    id: "past",
  },
  { href: "/finances/todos", label: "To-dos", id: "todos" },
] as const;

export type FinanceTab = (typeof TABS)[number]["id"];

export function FinanceTabs({ current }: { current?: FinanceTab }) {
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
