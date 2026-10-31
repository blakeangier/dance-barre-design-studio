"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

type Item = {
  href: string;
  label: string;
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
                  current ? "bg-wine text-cream" : "text-ink hover:bg-cream"
                }`}
              >
                {item.label}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
