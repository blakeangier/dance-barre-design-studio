"use client";

import { copyLastWeek } from "@/app/(workspace)/schedule/actions";

export function CopyLastWeek({ week }: { week: string }) {
  return (
    <form action={copyLastWeek}>
      <input type="hidden" name="week" value={week} />
      <button
        type="submit"
        className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium text-ink"
        onClick={(event) => {
          const ok = window.confirm(
            "Copy last week's shifts into this week? Tasks are not copied. Shifts that are already here are skipped.",
          );
          if (!ok) event.preventDefault();
        }}
      >
        Copy last week
      </button>
    </form>
  );
}
