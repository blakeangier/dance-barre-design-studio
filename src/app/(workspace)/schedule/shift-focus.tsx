"use client";

import { useEffect } from "react";

export function ScrollShiftFocus({ token }: { token: string | null }) {
  useEffect(() => {
    if (!token) return;
    const cell = document.querySelector("[data-shift-focus='cell']");
    if (!(cell instanceof HTMLElement)) return;
    cell.scrollIntoView({ block: "nearest", inline: "nearest" });
    const scroller = cell.closest(".overflow-x-auto");
    if (!(scroller instanceof HTMLElement)) return;
    const sticky = scroller.querySelector("tbody th");
    const stickyWidth = sticky?.getBoundingClientRect().width ?? 0;
    const covered =
      stickyWidth +
      12 -
      (cell.getBoundingClientRect().left -
        scroller.getBoundingClientRect().left);
    if (covered > 0) scroller.scrollLeft -= covered;
  }, [token]);
  return null;
}
