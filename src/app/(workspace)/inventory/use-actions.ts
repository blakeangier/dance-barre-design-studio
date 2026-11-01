"use server";

import { redirect } from "next/navigation";
import { canEditInventory } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { isUsagePhotoPath } from "@/lib/inventory/photos";
import {
  canReverseUsage,
  isIsoDate,
  parseUsageAmount,
  todayInToronto,
  toMetres,
  type UsagePurpose,
  type UsageUnit,
} from "@/lib/inventory/usage";
import { createClient } from "@/lib/supabase/server";

export type LogUseResult =
  { ok: true; groupId: string } | { ok: false; message: string };

const NOTE_LIMIT = 500;

function text(value: FormDataEntryValue | null): string {
  return typeof value === "string" ? value.trim() : "";
}

export async function logFabricUse(formData: FormData): Promise<LogUseResult> {
  const state = await getSessionState();
  if (state.status !== "ready") {
    return { ok: false, message: "Sign in again, then log the use." };
  }

  const materialId = Number(text(formData.get("materialId")));
  if (!Number.isInteger(materialId) || materialId <= 0) {
    return { ok: false, message: "Choose the fabric." };
  }

  const unit = text(formData.get("unit")) === "cm" ? "cm" : "m";
  const useM = parseUsageAmount(
    text(formData.get("amount")),
    unit as UsageUnit,
  );
  if (useM === null) {
    return {
      ok: false,
      message: "Enter the metres used. Use a number greater than zero.",
    };
  }
  const wasteRaw = text(formData.get("waste"));
  const wasteM = wasteRaw ? parseUsageAmount(wasteRaw, unit as UsageUnit) : 0;
  if (wasteRaw && wasteM === null) {
    return {
      ok: false,
      message: "Enter the waste in metres, or leave it blank.",
    };
  }

  const purposeText = text(formData.get("purpose"));
  if (purposeText !== "sample" && purposeText !== "production") {
    return { ok: false, message: "Choose sample or a production order." };
  }
  const purpose: UsagePurpose = purposeText;

  const styleId = numberOrNull(text(formData.get("styleId")));
  const orderId = numberOrNull(text(formData.get("orderId")));
  const bomLineId = numberOrNull(text(formData.get("bomLineId")));
  const occurredOn = text(formData.get("occurredOn")) || todayInToronto();
  if (!isIsoDate(occurredOn)) {
    return { ok: false, message: "Enter the date." };
  }
  const note = text(formData.get("note"));
  if (note.length > NOTE_LIMIT) {
    return { ok: false, message: "The note is too long." };
  }
  const photoPath = text(formData.get("photoPath"));
  if (photoPath && !isUsagePhotoPath(state.profile.id, photoPath)) {
    return { ok: false, message: "That photo could not be stored." };
  }

  const supabase = await createClient();
  const { data: material } = await supabase
    .from("materials")
    .select("id, material_code")
    .eq("id", materialId)
    .maybeSingle();
  if (!material) return { ok: false, message: "That fabric was not found." };

  let orderNumber: string | null = null;
  let linkedStyleId: number | null = styleId;
  let linkedBomId: number | null = null;

  if (purpose === "sample") {
    if (!styleId) return { ok: false, message: "Choose the style." };
    const { data: style } = await supabase
      .from("styles")
      .select("id")
      .eq("id", styleId)
      .maybeSingle();
    if (!style) return { ok: false, message: "Choose the style." };
  } else {
    if (!orderId) return { ok: false, message: "Choose the production order." };
    const { data: order } = await supabase
      .from("costume_orders")
      .select("id, order_number")
      .eq("id", orderId)
      .maybeSingle();
    if (!order) return { ok: false, message: "Choose the production order." };
    orderNumber = order.order_number;

    if (styleId) {
      const { data: style } = await supabase
        .from("styles")
        .select("id, order_id")
        .eq("id", styleId)
        .maybeSingle();
      if (!style || style.order_id !== orderId) {
        return { ok: false, message: "That style is not on this order." };
      }
    }

    if (bomLineId) {
      const { data: line } = await supabase
        .from("bom_lines")
        .select("id, order_id, style_id, material_id")
        .eq("id", bomLineId)
        .maybeSingle();
      if (!line || line.order_id !== orderId) {
        return { ok: false, message: "That fabric line is not on this order." };
      }
      if (line.material_id !== null && line.material_id !== materialId) {
        return {
          ok: false,
          message: "That fabric line is a different material.",
        };
      }
      if (line.style_id && linkedStyleId && line.style_id !== linkedStyleId) {
        return { ok: false, message: "That fabric line is a different style." };
      }
      if (line.style_id && !linkedStyleId) {
        const { data: style } = await supabase
          .from("styles")
          .select("id, order_id")
          .eq("id", line.style_id)
          .maybeSingle();
        if (style?.order_id === orderId) linkedStyleId = style.id;
      }
      linkedBomId = line.id;
    }
  }

  const groupId = crypto.randomUUID();
  const shared = {
    purpose,
    materialId,
    materialCode: material.material_code,
    orderId: purpose === "production" ? orderId : null,
    orderNumber,
    styleId: linkedStyleId,
    bomLineId: linkedBomId,
    occurredOn,
    note,
    groupId,
    userId: state.profile.id,
    userName: state.profile.fullName,
  };
  const { error } = await supabase.from("stock_transactions").insert(
    usageRow({
      ...shared,
      qtyM: useM,
      waste: false,
      photoPath: photoPath || null,
    }),
  );
  if (error) return { ok: false, message: "That use did not save." };

  if (wasteM && wasteM > 0) {
    const { error: wasteError } = await supabase
      .from("stock_transactions")
      .insert(
        usageRow({
          ...shared,
          qtyM: wasteM,
          waste: true,
          photoPath: null,
        }),
      );
    if (wasteError) {
      return {
        ok: false,
        message:
          "The metres used were saved. The waste was not. Check the usage log before logging it again.",
      };
    }
  }
  return { ok: true, groupId };
}

function usageRow(input: {
  purpose: UsagePurpose;
  materialId: number;
  materialCode: string;
  qtyM: number;
  waste: boolean;
  orderId: number | null;
  orderNumber: string | null;
  styleId: number | null;
  bomLineId: number | null;
  occurredOn: string;
  note: string;
  photoPath: string | null;
  groupId: string;
  userId: string;
  userName: string;
}) {
  return {
    txn_code: `${input.waste ? "WASTE" : "USE"}-${crypto.randomUUID()}`,
    txn_type: "use",
    material_id: input.materialId,
    material_code_raw: input.materialCode,
    qty_m: input.qtyM,
    qty_raw: String(input.qtyM),
    order_id: input.orderId,
    order_number_raw: input.orderNumber,
    style_id: input.styleId,
    bom_line_id: input.bomLineId,
    usage_kind: input.purpose,
    is_waste: input.waste,
    occurred_on: input.occurredOn,
    occurred_on_raw: input.occurredOn,
    description: input.note || null,
    photo_path: input.photoPath,
    usage_group: input.groupId,
    entered_by: input.userName,
    created_by: input.userId,
    source_tab: "app",
    source_label: input.waste ? "fabric-waste" : "fabric-use",
  };
}

function numberOrNull(value: string): number | null {
  if (!value) return null;
  const number = Number(value);
  return Number.isInteger(number) && number > 0 ? number : null;
}

export async function reverseFabricUse(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const back = "/inventory/usage";
  const entryId = Number(text(formData.get("entryId")));
  if (!Number.isInteger(entryId) || entryId <= 0) {
    redirect(`${back}?notice=missing`);
  }

  const supabase = await createClient();
  const { data: original } = await supabase
    .from("stock_transactions")
    .select(
      "id, txn_code, txn_type, material_id, qty_m, created_by, created_at, usage_kind, reservation_drawdown_m",
    )
    .eq("id", entryId)
    .maybeSingle();
  if (!original || original.txn_type !== "use" || !original.usage_kind) {
    redirect(`${back}?notice=missing`);
  }

  const { data: prior } = await supabase
    .from("stock_transactions")
    .select("id")
    .eq("reverses_id", original.id)
    .maybeSingle();

  const allowed = canReverseUsage({
    createdBy: original.created_by,
    createdAt: new Date(original.created_at),
    alreadyReversed: Boolean(prior),
    actorId: state.profile.id,
    actorCanCorrectAny: canEditInventory(state.profile),
    now: new Date(),
  });
  if (!allowed) redirect(`${back}?notice=denied`);

  const qty = toMetres(original.qty_m);
  if (qty === null || qty <= 0) redirect(`${back}?notice=failed`);

  const { error } = await supabase.from("stock_transactions").insert({
    txn_code: `REV-${crypto.randomUUID()}`,
    txn_type: "adjust",
    reverses_id: original.id,
    material_id: original.material_id,
    qty_m: qty,
    qty_raw: String(qty),
    reservation_drawdown_m: toMetres(original.reservation_drawdown_m) ?? 0,
    created_by: state.profile.id,
    entered_by: state.profile.fullName,
    occurred_on: todayInToronto(),
    occurred_on_raw: todayInToronto(),
    description: `Reverses ${original.txn_code}`,
    source_tab: "app",
    source_label: "fabric-reversal",
  });

  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=reversed`);
}
