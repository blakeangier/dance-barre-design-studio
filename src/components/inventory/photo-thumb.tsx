"use client";

import { useState } from "react";

export function PhotoThumb({
  thumbUrl,
  fullUrl,
  label,
}: {
  thumbUrl: string | null;
  fullUrl: string | null;
  label: string;
}) {
  const [open, setOpen] = useState(false);

  if (!thumbUrl || !fullUrl) {
    return (
      <span
        aria-label={`No photo of ${label}`}
        className="inline-flex h-14 w-14 shrink-0 items-center justify-center rounded-lg border border-dashed border-line bg-paper px-1 text-center text-[10px] leading-tight text-muted"
      >
        No photo
      </span>
    );
  }

  return (
    <>
      <button
        type="button"
        className="h-14 w-14 shrink-0 overflow-hidden rounded-lg border border-line"
        onClick={() => setOpen(true)}
        aria-label={`Enlarge photo of ${label}`}
      >
        {/* Signed URLs expire, so the browser loads the file directly. */}
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={thumbUrl} alt="" className="h-full w-full object-cover" />
      </button>
      {open ? (
        <div
          role="dialog"
          aria-modal="true"
          aria-label={label}
          className="fixed inset-0 z-50 flex items-center justify-center bg-ink/80 p-4"
          onClick={() => setOpen(false)}
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={fullUrl}
            alt={label}
            className="max-h-[85vh] max-w-full rounded-lg"
          />
        </div>
      ) : null}
    </>
  );
}
