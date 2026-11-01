"use server";

import { redirect } from "next/navigation";
import { canEditInventory, canSeeCosts } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import {
  STAGE_NAMES,
  SIZE_CODES,
  checked,
  optionalId,
  optionalNumber,
  optionalText,
  requiredText,
  stageYes,
  optionalDate,
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

async function editor() {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canEditInventory(state.profile)) redirect("/styles?notice=denied");
  return state;
}

export async function saveStyle(formData: FormData) {
  const state = await editor();
  const idText = String(formData.get("id") ?? "").trim();
  const id = idText ? Number(idText) : null;
  const back = id ? `/styles/${id}` : "/styles/new";
  if (idText && !Number.isInteger(id)) bail(back, "failed");

  const styleKey = take(back, requiredText(formData.get("styleKey"), 160));
  const styleCode = take(back, optionalText(formData.get("styleCode"), 80));
  const orderNumber = take(back, optionalText(formData.get("orderNumber"), 40));
  const garment = take(back, optionalText(formData.get("garment"), 300));
  const category = take(back, optionalText(formData.get("category"), 80));
  const groupName = take(back, optionalText(formData.get("groupName"), 80));
  const version = take(back, optionalText(formData.get("versionLabel"), 80));
  const childOrAdult = take(
    back,
    optionalText(formData.get("childOrAdult"), 40),
  );
  const characterNote = take(
    back,
    optionalText(formData.get("characterNote"), 300),
  );
  const fabricCode = take(back, optionalText(formData.get("fabricCode"), 80));
  const materialId = take(back, optionalId(formData.get("materialId")));
  const keepArchived = String(formData.get("archivedAt") ?? "").trim();
  const archivedAt = checked(formData.get("archive"))
    ? keepArchived || new Date().toISOString()
    : null;

  const supabase = await createClient();
  let orderId: number | null = null;
  if (orderNumber) {
    const { data: order } = await supabase
      .from("costume_orders")
      .select("id")
      .eq("order_number", orderNumber)
      .maybeSingle();
    if (!order) bail(back, "missing");
    orderId = order.id;
  }

  const row = {
    style_key: styleKey,
    style_code: styleCode,
    order_id: orderId,
    order_number_raw: orderNumber,
    garment_description: garment,
    category,
    group_name: groupName,
    version_label: version,
    child_or_adult: childOrAdult,
    character_note: characterNote,
    fabric_code_raw: fabricCode,
    material_id: materialId,
    archived_at: archivedAt,
  };

  let styleId = id;
  if (styleId) {
    const { error } = await supabase
      .from("styles")
      .update(row)
      .eq("id", styleId);
    const notice = problem(error);
    if (notice) bail(back, notice);
  } else {
    const { data, error } = await supabase
      .from("styles")
      .insert(row)
      .select("id")
      .single();
    const notice = problem(error);
    if (notice || !data) bail(back, notice ?? "failed");
    styleId = data.id;
    const stageRows = STAGE_NAMES.map((name, index) => ({
      style_id: styleId,
      stage_name: name,
      stage_order: index + 1,
    }));
    const { error: stageError } = await supabase
      .from("style_stages")
      .insert(stageRows);
    if (stageError) bail(`/styles/${styleId}`, "failed");
    redirect(`/styles/${styleId}?notice=saved`);
  }

  const stageIds = formData.getAll("stageId").map((value) => String(value));
  for (const stageId of stageIds) {
    const note = take(
      back,
      optionalText(formData.get(`stageText_${stageId}`), 300),
    );
    const date = take(back, optionalDate(formData.get(`stageDate_${stageId}`)));
    const yes = take(back, stageYes(formData.get(`stageYes_${stageId}`)));
    const { error } = await supabase
      .from("style_stages")
      .update({
        cell_text: note,
        interpreted_on: date,
        interpreted_yes: yes,
      })
      .eq("id", Number(stageId))
      .eq("style_id", styleId);
    if (error) bail(back, "failed");
  }

  const sizeCodes = [
    ...new Set(
      [...formData.keys()]
        .filter((key) => key.startsWith("size_"))
        .map((key) => key.slice("size_".length)),
    ),
  ];
  for (const sizeCode of sizeCodes.length > 0 ? sizeCodes : SIZE_CODES) {
    const qty = take(back, optionalNumber(formData.get(`size_${sizeCode}`)));
    if (qty !== null && !Number.isInteger(qty)) bail(back, "number");
    const existing = String(formData.get(`sizeId_${sizeCode}`) ?? "").trim();
    if (!existing && qty === null) continue;
    if (existing) {
      const { error } = await supabase
        .from("order_sizes")
        .update({ qty, qty_raw: qty === null ? null : String(qty) })
        .eq("id", Number(existing));
      if (error) bail(back, "failed");
    } else {
      const { error } = await supabase.from("order_sizes").insert({
        style_id: styleId,
        order_id: orderId,
        size_code: sizeCode,
        qty,
        qty_raw: String(qty),
      });
      if (error) bail(back, "failed");
    }
  }

  const bomIds = formData.getAll("bomId").map((value) => String(value));
  for (const bomId of bomIds) {
    const linked = take(back, optionalId(formData.get(`bomMaterial_${bomId}`)));
    const consumption = take(
      back,
      optionalNumber(formData.get(`bomQty_${bomId}`)),
    );
    const written = take(
      back,
      optionalText(formData.get(`bomWritten_${bomId}`), 80),
    );
    const bomArchived = checked(formData.get(`bomArchive_${bomId}`))
      ? String(formData.get(`bomArchivedAt_${bomId}`) ?? "").trim() ||
        new Date().toISOString()
      : null;
    const { error } = await supabase
      .from("bom_lines")
      .update({
        material_id: linked,
        fabric_as_written: written,
        consumption_per_unit_m: consumption,
        consumption_raw: consumption === null ? null : String(consumption),
        needs_review: linked === null && Boolean(written),
        archived_at: bomArchived,
      })
      .eq("id", Number(bomId))
      .eq("style_id", styleId);
    if (error) bail(back, "failed");

    if (canSeeCosts(state.profile)) {
      const price = take(
        back,
        optionalNumber(formData.get(`bomPrice_${bomId}`)),
      );
      const { error: priceError } = await supabase.from("bom_costs").upsert(
        {
          bom_line_id: Number(bomId),
          price_per_m_used: price,
          price_per_m_used_raw: price === null ? null : String(price),
        },
        { onConflict: "bom_line_id" },
      );
      if (priceError) bail(back, "failed");
    }
  }

  const newComponent = take(
    back,
    optionalText(formData.get("newBomComponent"), 120),
  );
  const newMaterial = take(back, optionalId(formData.get("newBomMaterial")));
  const newQty = take(back, optionalNumber(formData.get("newBomQty")));
  if (newComponent || newMaterial || newQty !== null) {
    const lineCode = `B-APP-${crypto.randomUUID().slice(0, 8)}`;
    const { data: created, error } = await supabase
      .from("bom_lines")
      .insert({
        line_code: lineCode,
        style_id: styleId,
        order_id: orderId,
        order_number_raw: orderNumber,
        component: newComponent,
        material_id: newMaterial,
        consumption_per_unit_m: newQty,
        consumption_raw: newQty === null ? null : String(newQty),
        needs_review: newMaterial === null,
      })
      .select("id")
      .single();
    if (error || !created) bail(back, "failed");
  }

  redirect(`/styles/${styleId}?notice=saved`);
}
