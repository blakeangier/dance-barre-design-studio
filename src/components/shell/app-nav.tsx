"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

type Item = {
  href: string;
  label: string;
  badge?: number;
};

export function AppNav({ items }: { items: Item[] }) {
  const pathname = usePathname();

  return (
    <nav
      aria-label="Main"
      className="border-b border-line bg-card md:w-56 md:shrink-0 md:border-r md:border-b-0"
    >
      <ul className="flex gap-2 overflow-x-auto px-3 py-2 md:flex-col md:px-3 md:py-4">
        {items.map((item) => {
          const current =
            item.href === "/"
              ? pathname === "/"
              : pathname === item.href || pathname.startsWith(`${item.href}/`);

          return (
            <li key={item.href} className="shrink-0 md:shrink">
              <Link
                href={item.href}
                aria-current={current ? "page" : undefined}
                className={`inline-flex min-h-11 items-center rounded-full px-4 text-sm font-medium md:w-full md:rounded-xl ${
                  current ? "bg-ink text-white" : "text-ink hover:bg-paper"
                }`}
              >
                {item.label}
                {item.badge ? (
                  <span className="ml-2 inline-flex min-h-6 min-w-6 items-center justify-center rounded-full bg-orange px-1 text-xs font-medium text-ink">
                    {item.badge}
                  </span>
                ) : null}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
