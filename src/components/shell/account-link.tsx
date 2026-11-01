"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export function AccountLink() {
  const pathname = usePathname();
  const current = pathname === "/account";

  return (
    <Link
      href="/account"
      aria-current={current ? "page" : undefined}
      className={`inline-flex min-h-11 items-center rounded-full px-3 text-sm font-medium ${
        current ? "bg-ink text-white" : "text-ink hover:bg-paper"
      }`}
    >
      My account
    </Link>
  );
}
