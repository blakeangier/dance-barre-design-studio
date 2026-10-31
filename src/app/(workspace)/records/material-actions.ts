"use server";

import { redirect } from "next/navigation";
import { canEditInventory } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import {
  checked,
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

export async function saveMaterial(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canEditInventory(state.profile)) redirect("/inventory?notice=denied");

  const returnCode = String(formData.get("returnCode") ?? "").trim();
  const back = returnCode
    ? `/inventory/${encodeURIComponent(returnCode)}`
    : "/inventory/new";
  const idText = String(formData.get("id") ?? "").trim();
  const id = idText ? Number(idText) : null;
  if (idText && !Number.isInteger(id)) bail(back, "failed");

  const code = take(back, requiredText(formData.get("materialCode"), 80));
  const fabricName = take(back, optionalText(formData.get("fabricName"), 200));
  const colourName = take(back, optionalText(formData.get("colourName"), 120));
  const colourNumber = take(
    back,
    optionalText(formData.get("colourNumber"), 40),
  );
  const fabricNumber = take(
    back,
    optionalText(formData.get("fabricNumber"), 40),
  );
  const content = take(back, optionalText(formData.get("content"), 200));
  const fabricType = take(back, optionalText(formData.get("fabricType"), 120));
  const width = take(back, optionalNumber(formData.get("widthCm")));
  const gsm = take(back, optionalNumber(formData.get("gsm")));
  const bin = take(back, optionalText(formData.get("binLocation"), 120));
  const reorder = take(back, optionalNumber(formData.get("reorderPoint")));
  if (reorder !== null && reorder < 0) bail(back, "number");
  const notes = take(back, optionalText(formData.get("notes"), 2000));
  const reviewNote = take(back, optionalText(formData.get("reviewNote"), 500));
  const supplierId = take(back, optionalId(formData.get("supplierId")));
  const supplierWritten = take(
    back,
    optionalText(formData.get("supplierWritten"), 200),
  );
  const listPrice = take(back, optionalNumber(formData.get("listPrice")));
  const netPrice = take(back, optionalNumber(formData.get("netPrice")));
  const discount = take(back, optionalNumber(formData.get("discount")));
  const keepArchived = String(formData.get("archivedAt") ?? "").trim();
  const archivedAt = checked(formData.get("archive"))
    ? keepArchived || new Date().toISOString()
    : null;

  const row = {
    material_code: code,
    fabric_name: fabricName,
    colour_name: colourName,
    colour_number: colourNumber,
    fabric_number: fabricNumber,
    content,
    fabric_type: fabricType,
    width_cm: width,
    gsm,
    bin_location: bin,
    reorder_point_m: reorder,
    reorder_point_raw: reorder === null ? null : String(reorder),
    registry_notes: notes,
    needs_review: checked(formData.get("needsReview")),
    needs_review_reason: reviewNote,
    supplier_id: supplierId,
    supplier_as_written: supplierWritten,
    archived_at: archivedAt,
  };

  const supabase = await createClient();
  let materialId = id;
  if (materialId) {
    const { error } = await supabase
      .from("materials")
      .update(row)
      .eq("id", materialId);
    const notice = problem(error);
    if (notice) bail(back, notice);
  } else {
    const { data, error } = await supabase
      .from("materials")
      .insert(row)
      .select("id")
      .single();
    const notice = problem(error);
    if (notice || !data) bail(back, notice ?? "failed");
    materialId = data.id;
  }

  const { error: costError } = await supabase.from("material_costs").upsert(
    {
      material_id: materialId,
      list_price_per_m: listPrice,
      list_price_raw: listPrice === null ? null : String(listPrice),
      net_price_per_m: netPrice,
      net_price_raw: netPrice === null ? null : String(netPrice),
      discount_entered: discount,
      discount_raw: discount === null ? null : String(discount),
    },
    { onConflict: "material_id" },
  );
  const costNotice = problem(costError);
  if (costNotice) bail(`/inventory/${encodeURIComponent(code)}`, costNotice);

  redirect(`/inventory/${encodeURIComponent(code)}?notice=record-saved`);
}
