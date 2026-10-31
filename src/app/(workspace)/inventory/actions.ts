"use server";

import { redirect } from "next/navigation";
import { canEditInventory } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

const TYPES = ["receive", "use", "adjust"] as const;

export async function logStock(materialCode: string, formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");

  const txnType = String(formData.get("txnType") ?? "");
  if (!TYPES.includes(txnType as (typeof TYPES)[number])) {
    redirect(`/inventory/${encodeURIComponent(materialCode)}?notice=type`);
  }
  if (!canEditInventory(state.profile) && txnType !== "use") {
    redirect(`/inventory/${encodeURIComponent(materialCode)}?notice=denied`);
  }

  const qty = Number(String(formData.get("qty") ?? "").trim());
  if (!Number.isFinite(qty) || (txnType !== "adjust" && qty < 0)) {
    redirect(`/inventory/${encodeURIComponent(materialCode)}?notice=qty`);
  }

  const note = String(formData.get("note") ?? "").trim();
  const orderNumber = String(formData.get("orderNumber") ?? "").trim();
  const supabase = await createClient();
  const { data: material } = await supabase
    .from("materials")
    .select("id")
    .eq("material_code", materialCode)
    .maybeSingle();

  if (!material) {
    redirect("/inventory?notice=missing");
  }

  let orderId: number | null = null;
  if (orderNumber) {
    const { data: order } = await supabase
      .from("costume_orders")
      .select("id")
      .eq("order_number", orderNumber)
      .maybeSingle();
    orderId = order?.id ?? null;
  }

  const { error } = await supabase.from("stock_transactions").insert({
    txn_code: `APP-${crypto.randomUUID()}`,
    txn_type: txnType,
    material_id: material.id,
    qty_m: qty,
    qty_raw: String(qty),
    order_id: orderId,
    order_number_raw: orderNumber || null,
    description: note || null,
    entered_by: state.profile.fullName,
    created_by: state.profile.id,
    source_tab: "app",
  });

  if (error) {
    redirect(`/inventory/${encodeURIComponent(materialCode)}?notice=failed`);
  }
  redirect(`/inventory/${encodeURIComponent(materialCode)}?notice=saved`);
}
