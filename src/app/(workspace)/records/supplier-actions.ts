"use server";

import { redirect } from "next/navigation";
import { canEditInventory, canSeePrivateRecords } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import {
  checked,
  optionalNumber,
  optionalText,
  requiredText,
  type FieldResult,
} from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

function bail(path: string, notice: string): never {
  redirect(`${path}?notice=${notice}`);
}

function take<T>(path: string, result: FieldResult<T>): T {
  if (!result.ok) bail(path, result.notice);
  return result.value;
}

function problem(
  error: { code?: string } | null,
): "duplicate" | "failed" | null {
  if (!error) return null;
  return error.code === "23505" ? "duplicate" : "failed";
}

export async function saveSupplier(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canEditInventory(state.profile)) redirect("/suppliers?notice=denied");

  const returnCode = String(formData.get("returnCode") ?? "").trim();
  const back = returnCode
    ? `/suppliers/${encodeURIComponent(returnCode)}`
    : "/suppliers/new";
  const idText = String(formData.get("id") ?? "").trim();
  const id = idText ? Number(idText) : null;
  if (idText && !Number.isInteger(id)) bail(back, "failed");

  const code = take(back, requiredText(formData.get("supplierCode"), 40));
  const name = take(back, requiredText(formData.get("name"), 200));
  const website = take(back, optionalText(formData.get("website"), 300));
  const lead = take(back, optionalNumber(formData.get("leadTimeDays")));
  const minimum = take(back, optionalText(formData.get("minimumOrder"), 120));
  const notes = take(back, optionalText(formData.get("notes"), 2000));
  if (lead !== null && !Number.isInteger(lead)) bail(back, "number");
  const keepArchived = String(formData.get("archivedAt") ?? "").trim();
  const archivedAt = checked(formData.get("archive"))
    ? keepArchived || new Date().toISOString()
    : null;

  const supabase = await createClient();
  const row = {
    supplier_code: code,
    name,
    website,
    lead_time_days: lead,
    minimum_order: minimum,
    notes,
    archived_at: archivedAt,
  };
  let supplierId = id;
  if (supplierId) {
    const { error } = await supabase
      .from("suppliers")
      .update(row)
      .eq("id", supplierId);
    const notice = problem(error);
    if (notice) bail(back, notice);
  } else {
    const { data, error } = await supabase
      .from("suppliers")
      .insert(row)
      .select("id")
      .single();
    const notice = problem(error);
    if (notice || !data) bail(back, notice ?? "failed");
    supplierId = data.id;
  }

  if (canSeePrivateRecords(state.profile)) {
    const contactName = take(
      back,
      optionalText(formData.get("contactName"), 120),
    );
    const email = take(back, optionalText(formData.get("email"), 200));
    const phone = take(back, optionalText(formData.get("phone"), 40));
    const address = take(back, optionalText(formData.get("address"), 300));
    const account = take(back, optionalText(formData.get("accountNumber"), 80));
    const { error } = await supabase.from("supplier_contacts").upsert(
      {
        supplier_id: supplierId,
        contact_name: contactName,
        email,
        phone,
        address,
        account_number: account,
      },
      { onConflict: "supplier_id" },
    );
    const notice = problem(error);
    if (notice) bail(`/suppliers/${encodeURIComponent(code)}`, notice);
  }

  redirect(`/suppliers/${encodeURIComponent(code)}?notice=saved`);
}
