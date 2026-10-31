"use server";

import { redirect } from "next/navigation";
import { canEditInventory, canUpdateOrderStatus } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

function text(value: FormDataEntryValue | null): string {
  return typeof value === "string" ? value.trim() : "";
}

export async function saveOrderSizeGrid(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const orderNumber = text(formData.get("orderNumber"));
  const back = `/production-orders/${encodeURIComponent(orderNumber)}`;
  if (!canUpdateOrderStatus(state.profile)) redirect(`${back}?notice=denied`);
  const orderId = Number(text(formData.get("orderId")));
  if (!Number.isInteger(orderId)) redirect(`${back}?notice=number`);
  const supabase = await createClient();
  const { data: styles } = await supabase
    .from("styles")
    .select("id")
    .eq("order_id", orderId);
  const styleIds = new Set(
    ((styles ?? []) as { id: number }[]).map((style) => style.id),
  );
  for (const [key, raw] of formData.entries()) {
    if (typeof raw !== "string") continue;
    const match = /^qty_(\d+)_(.+)$/.exec(key);
    if (!match?.[1] || !match[2]) continue;
    const styleId = Number(match[1]);
    const sizeCode = match[2];
    if (!styleIds.has(styleId)) continue;
    const written = raw.trim();
    if (written !== "" && !/^\d+$/.test(written))
      redirect(`${back}?notice=number`);
    const qty = written === "" ? null : Number(written);
    const { data: existing } = await supabase
      .from("order_sizes")
      .select("id")
      .eq("style_id", styleId)
      .eq("size_code", sizeCode)
      .maybeSingle();
    if (!existing && qty === null) continue;
    const row = {
      style_id: styleId,
      order_id: orderId,
      size_code: sizeCode,
      qty,
      qty_raw: qty === null ? null : String(qty),
    };
    const { error } = existing
      ? await supabase.from("order_sizes").update(row).eq("id", existing.id)
      : await supabase.from("order_sizes").insert(row);
    if (error) redirect(`${back}?notice=number`);
  }
  redirect(`${back}?notice=record-saved`);
}

export async function addSizeCode(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const orderNumber = text(formData.get("orderNumber"));
  const back = `/production-orders/${encodeURIComponent(orderNumber)}`;
  if (!canEditInventory(state.profile)) redirect(`${back}?notice=denied`);
  const sizeCode = text(formData.get("sizeCode")).toUpperCase();
  if (!/^[A-Z0-9-]{1,12}$/.test(sizeCode)) redirect(`${back}?notice=number`);
  const supabase = await createClient();
  const writtenOrder = text(formData.get("sortOrder"));
  let sortOrder = /^\d+$/.test(writtenOrder) ? Number(writtenOrder) : 0;
  if (!sortOrder) {
    const { data } = await supabase
      .from("size_scale")
      .select("sort_order")
      .order("sort_order", { ascending: false })
      .limit(1);
    const highest =
      (data?.[0] as { sort_order: number } | undefined)?.sort_order ?? 0;
    sortOrder = highest + 1;
  }
  const { error } = await supabase
    .from("size_scale")
    .upsert(
      { size_code: sizeCode, sort_order: sortOrder, archived_at: null },
      { onConflict: "size_code" },
    );
  if (error) redirect(`${back}?notice=number`);
  redirect(`${back}?notice=record-saved`);
}
