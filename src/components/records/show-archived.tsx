"use client";

import { usePathname, useRouter, useSearchParams } from "next/navigation";

export function ShowArchived({ checked }: { checked: boolean }) {
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();

  return (
    <label className="flex min-h-12 items-center gap-2 text-sm">
      <input
        type="checkbox"
        className="size-5"
        checked={checked}
        onChange={(event) => {
          const next = new URLSearchParams(params.toString());
          if (event.target.checked) next.set("archived", "1");
          else next.delete("archived");
          const query = next.toString();
          router.replace(query ? `${pathname}?${query}` : pathname, {
            scroll: false,
          });
        }}
      />
      Show archived
    </label>
  );
}
