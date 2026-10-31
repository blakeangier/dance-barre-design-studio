"use server";

import { redirect } from "next/navigation";
import { canEditInventory } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

function text(value: FormDataEntryValue | null): string {
  return typeof value === "string" ? value.trim() : "";
}

export async function saveLowStockMail(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canEditInventory(state.profile)) redirect("/inventory?notice=denied");

  const to = text(formData.get("alertTo"));
  const from = text(formData.get("alertFrom"));
  if (!/^[^\s@]+@[^\s@]+$/.test(to) || to.length > 200) {
    redirect("/inventory/alerts?notice=email");
  }
  if (!from.includes("@") || from.length < 3 || from.length > 200) {
    redirect("/inventory/alerts?notice=from");
  }

  const supabase = await createClient();
  const { error } = await supabase
    .from("inventory_settings")
    .update({
      low_stock_alert_to: to,
      low_stock_alert_from: from,
    })
    .eq("id", true);
  if (error) redirect("/inventory/alerts?notice=failed");
  redirect("/inventory/alerts?notice=saved");
}
