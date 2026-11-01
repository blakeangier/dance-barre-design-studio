"use server";

import { redirect } from "next/navigation";
import { canRecordPurchase } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import {
  checked,
  optionalDate,
  optionalId,
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

async function buyer() {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canRecordPurchase(state.profile)) redirect("/purchases?notice=denied");
  return state.profile;
}

export async function savePurchase(formData: FormData) {
  await buyer();
  const lineCodeExisting = String(formData.get("lineCode") ?? "").trim();
  const back = lineCodeExisting
    ? `/purchases/${encodeURIComponent(lineCodeExisting)}`
    : "/purchases/new";
  const poRef = take(back, requiredText(formData.get("poRef"), 160));
  const supplierId = take(back, optionalId(formData.get("supplierId")));
  const supplierWritten = take(
    back,
    optionalText(formData.get("supplierWritten"), 200),
  );
  const poDate = take(back, optionalDate(formData.get("poDate")));
  const materialId = take(back, optionalId(formData.get("materialId")));
  const materialRaw = take(back, optionalText(formData.get("materialRaw"), 80));
  const fabricName = take(back, optionalText(formData.get("fabricName"), 200));
  const qty = take(back, optionalNumber(formData.get("qty")));
  const price = take(back, optionalNumber(formData.get("price")));
  const note = take(back, optionalText(formData.get("lineNote"), 500));
  const keepLineArchived = String(formData.get("archivedAt") ?? "").trim();
  const lineArchived = checked(formData.get("archive"))
    ? keepLineArchived || new Date().toISOString()
    : null;
  const keepPoArchived = String(formData.get("poArchivedAt") ?? "").trim();
  const poArchived = checked(formData.get("archivePo"))
    ? keepPoArchived || new Date().toISOString()
    : null;

  const supabase = await createClient();
  const { data: existingPo } = await supabase
    .from("purchase_orders")
    .select("id")
    .eq("po_ref", poRef)
    .maybeSingle();
  let poId = existingPo?.id ?? null;
  if (poId) {
    const { error } = await supabase
      .from("purchase_orders")
      .update({
        supplier_id: supplierId,
        supplier_as_written: supplierWritten,
        po_date: poDate,
        po_date_raw: poDate,
        archived_at: poArchived,
      })
      .eq("id", poId);
    if (error) bail(back, "failed");
  } else {
    const { data, error } = await supabase
      .from("purchase_orders")
      .insert({
        po_ref: poRef,
        supplier_id: supplierId,
        supplier_as_written: supplierWritten,
        po_date: poDate,
        po_date_raw: poDate,
        archived_at: poArchived,
      })
      .select("id")
      .single();
    const notice = problem(error);
    if (notice || !data) bail(back, notice ?? "failed");
    poId = data.id;
  }

  const lineIdText = String(formData.get("lineId") ?? "").trim();
  const lineCode =
    lineCodeExisting || `PL-APP-${crypto.randomUUID().slice(0, 8)}`;
  const lineRow = {
    line_code: lineCode,
    purchase_order_id: poId,
    material_id: materialId,
    material_code_raw: materialRaw,
    fabric_name_as_written: fabricName,
    qty_ordered_m: qty,
    qty_ordered_raw: qty === null ? null : String(qty),
    line_note: note,
    needs_review: materialId === null && Boolean(materialRaw),
    archived_at: lineArchived,
  };
  let lineId = lineIdText ? Number(lineIdText) : null;
  if (lineId) {
    const { error } = await supabase
      .from("purchase_order_lines")
      .update(lineRow)
      .eq("id", lineId);
    const notice = problem(error);
    if (notice) bail(back, notice);
  } else {
    const { data, error } = await supabase
      .from("purchase_order_lines")
      .insert(lineRow)
      .select("id")
      .single();
    const notice = problem(error);
    if (notice || !data) bail(back, notice ?? "failed");
    lineId = data.id;
  }

  const { error: priceError } = await supabase
    .from("purchase_line_prices")
    .upsert(
      {
        line_id: lineId,
        price_per_m: price,
        price_raw: price === null ? null : String(price),
      },
      { onConflict: "line_id" },
    );
  if (priceError) bail(`/purchases/${encodeURIComponent(lineCode)}`, "failed");

  redirect(`/purchases/${encodeURIComponent(lineCode)}?notice=saved`);
}
