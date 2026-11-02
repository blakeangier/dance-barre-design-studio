"use server";

import { redirect } from "next/navigation";
import { canEditInventory, canUpdateOrderStatus } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { dancerLabel } from "@/lib/production/dancer";
import { reserveQuantity } from "@/lib/production/fabric-need";
import { SIZE_CODES } from "@/lib/records/edit";
import { todayInToronto } from "@/lib/inventory/usage";
import { createClient } from "@/lib/supabase/server";

function text(value: FormDataEntryValue | null): string {
  return typeof value === "string" ? value.trim() : "";
}

async function editorOrStatus(back: string) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (
    !canUpdateOrderStatus(state.profile) &&
    !canEditInventory(state.profile)
  ) {
    redirect(`${back}?notice=denied`);
  }
  return state;
}

export async function saveBomSizeQty(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const orderNumber = text(formData.get("orderNumber"));
  const back = `/production-orders/${encodeURIComponent(orderNumber)}/fabric`;
  if (!canEditInventory(state.profile)) redirect(`${back}?notice=denied`);
  const lineId = Number(text(formData.get("lineId")));
  const sizeCode = text(formData.get("sizeCode"));
  const metres = Number(text(formData.get("metres")));
  const waste = text(formData.get("wastePercent"));
  if (!Number.isInteger(lineId) || !sizeCode || !(metres >= 0)) {
    redirect(`${back}?notice=failed`);
  }
  const supabase = await createClient();
  const { error } = await supabase.from("bom_size_qty").upsert(
    {
      bom_line_id: lineId,
      size_code: sizeCode,
      metres_per_piece: metres,
      archived_at: null,
    },
    { onConflict: "bom_line_id,size_code" },
  );
  if (waste) {
    const percent = Number(waste);
    if (percent >= 0 && percent <= 100) {
      await supabase
        .from("bom_lines")
        .update({ waste_percent: percent })
        .eq("id", lineId);
    }
  }
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function reserveOrderFabric(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const orderNumber = text(formData.get("orderNumber"));
  const back = `/production-orders/${encodeURIComponent(orderNumber)}/fabric`;
  if (!canEditInventory(state.profile)) redirect(`${back}?notice=denied`);
  const materialId = Number(text(formData.get("materialId")));
  const needed = Number(text(formData.get("needed")));
  const reserved = Number(text(formData.get("reserved")));
  const qty = reserveQuantity(needed, Number.isFinite(reserved) ? reserved : 0);
  if (!Number.isInteger(materialId) || qty <= 0)
    redirect(`${back}?notice=saved`);
  const supabase = await createClient();
  const { data: order } = await supabase
    .from("costume_orders")
    .select("id, order_number")
    .eq("order_number", orderNumber)
    .maybeSingle();
  if (!order) redirect(`${back}?notice=failed`);
  const { error } = await supabase.from("stock_transactions").insert({
    txn_code: `RES-${crypto.randomUUID()}`,
    txn_type: "reserve",
    material_id: materialId,
    qty_m: qty,
    qty_raw: String(qty),
    order_id: order.id,
    order_number_raw: order.order_number,
    description: "Reserved from the sized fabric requirement",
    entered_by: state.profile.fullName,
    created_by: state.profile.id,
    occurred_on: todayInToronto(),
    source_tab: "app",
    source_label: "fabric-reserve",
  });
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function saveQcCheck(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const orderNumber = text(formData.get("orderNumber"));
  const back = `/production-orders/${encodeURIComponent(orderNumber)}/qc`;
  if (!canEditInventory(state.profile)) redirect(`${back}?notice=denied`);
  const result = text(formData.get("result"));
  if (result !== "pass" && result !== "needs_fix" && result !== "fail") {
    redirect(`${back}?notice=failed`);
  }
  const supabase = await createClient();
  const { data: order } = await supabase
    .from("costume_orders")
    .select("id")
    .eq("order_number", orderNumber)
    .maybeSingle();
  if (!order) redirect(`${back}?notice=failed`);
  const sizeCode = text(formData.get("sizeCode"));
  if (
    sizeCode &&
    !SIZE_CODES.includes(sizeCode as (typeof SIZE_CODES)[number])
  ) {
    redirect(`${back}?notice=failed`);
  }
  const { error } = await supabase.from("qc_checks").insert({
    order_id: order.id,
    template_item_id: Number(text(formData.get("templateId"))) || null,
    item_name: text(formData.get("itemName")),
    size_code: sizeCode || null,
    result,
    note: text(formData.get("note")) || null,
    photo_path: text(formData.get("photoPath")) || null,
    checked_by: state.profile.id,
  });
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function resolveQcCheck(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const orderNumber = text(formData.get("orderNumber"));
  const back = `/production-orders/${encodeURIComponent(orderNumber)}/qc`;
  if (!canEditInventory(state.profile)) redirect(`${back}?notice=denied`);
  const { error } = await (
    await createClient()
  )
    .from("qc_checks")
    .update({
      resolved_at: new Date().toISOString(),
      resolved_by: state.profile.id,
    })
    .eq("id", Number(text(formData.get("checkId"))));
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function overrideQc(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const orderNumber = text(formData.get("orderNumber"));
  const back = `/production-orders/${encodeURIComponent(orderNumber)}/qc`;
  if (state.profile.role !== "owner") redirect(`${back}?notice=denied`);
  const reason = text(formData.get("reason"));
  if (reason.length < 3) redirect(`${back}?notice=failed`);
  const supabase = await createClient();
  const { data: order } = await supabase
    .from("costume_orders")
    .select("id")
    .eq("order_number", orderNumber)
    .maybeSingle();
  if (!order) redirect(`${back}?notice=failed`);
  const { error } = await supabase.from("qc_overrides").insert({
    order_id: order.id,
    reason,
    overridden_by: state.profile.id,
  });
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function saveTechPack(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const styleId = Number(text(formData.get("styleId")));
  const back = `/styles/${styleId}/tech-pack`;
  if (!canEditInventory(state.profile)) redirect(`${back}?notice=denied`);
  const supabase = await createClient();
  const { data: existing } = await supabase
    .from("tech_pack_versions")
    .select("id, version_no")
    .eq("style_id", styleId)
    .order("version_no", { ascending: false })
    .limit(1);
  const prior = existing?.[0] as { id: number; version_no: number } | undefined;
  const versionNo = (prior?.version_no ?? 0) + 1;
  const { data: version, error } = await supabase
    .from("tech_pack_versions")
    .insert({
      style_id: styleId,
      version_no: versionNo,
      description: text(formData.get("description")) || null,
      construction_notes: text(formData.get("constructionNotes")) || null,
      sketch_path: text(formData.get("sketchPath")) || null,
      created_by: state.profile.id,
    })
    .select("id")
    .single();
  if (error || !version) redirect(`${back}?notice=failed`);
  const point = text(formData.get("pointName"));
  const sizeCode = text(formData.get("sizeCode"));
  const value = text(formData.get("valueCm"));
  if (prior) {
    const [oldMeasures, oldOperations] = await Promise.all([
      supabase
        .from("tech_pack_measures")
        .select("point_name, size_code, value_cm, tolerance_cm, sort_order")
        .eq("version_id", prior.id),
      supabase
        .from("tech_pack_operations")
        .select("sort_order, operation_name")
        .eq("version_id", prior.id),
    ]);
    const measures = (
      (oldMeasures.data ?? []) as {
        point_name: string;
        size_code: string;
        value_cm: number | null;
        tolerance_cm: number | null;
        sort_order: number;
      }[]
    )
      .filter(
        (row) => !(row.point_name === point && row.size_code === sizeCode),
      )
      .map((row) => ({ ...row, version_id: version.id }));
    if (point && sizeCode && value) {
      measures.push({
        version_id: version.id,
        point_name: point,
        size_code: sizeCode,
        value_cm: Number(value),
        tolerance_cm: text(formData.get("toleranceCm"))
          ? Number(text(formData.get("toleranceCm")))
          : null,
        sort_order: measures.length + 1,
      });
    }
    if (measures.length > 0) {
      await supabase.from("tech_pack_measures").insert(measures);
    }
    const operations = (oldOperations.data ?? []) as {
      sort_order: number;
      operation_name: string;
    }[];
    if (operations.length > 0) {
      await supabase
        .from("tech_pack_operations")
        .insert(
          operations.map((step) => ({ ...step, version_id: version.id })),
        );
    }
  } else {
    const { data: route } = await supabase
      .from("sewing_route_template")
      .select("sort_order, operation_name")
      .order("sort_order");
    if (route && route.length > 0) {
      await supabase.from("tech_pack_operations").insert(
        route.map((step) => ({
          version_id: version.id,
          sort_order: step.sort_order,
          operation_name: step.operation_name,
        })),
      );
    }
    if (point && sizeCode && value) {
      await supabase.from("tech_pack_measures").insert({
        version_id: version.id,
        point_name: point,
        size_code: sizeCode,
        value_cm: Number(value),
        tolerance_cm: text(formData.get("toleranceCm"))
          ? Number(text(formData.get("toleranceCm")))
          : null,
        sort_order: 1,
      });
    }
  }
  redirect(`${back}?notice=saved`);
}

export async function saveFitting(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const orderNumber = text(formData.get("orderNumber"));
  const back = `/production-orders/${encodeURIComponent(orderNumber)}/fittings`;
  if (!canEditInventory(state.profile)) redirect(`${back}?notice=denied`);
  const label = dancerLabel(
    text(formData.get("firstName")),
    text(formData.get("lastInitial")),
  );
  if (!label) redirect(`${back}?notice=failed`);
  const outcome = text(formData.get("outcome"));
  if (outcome !== "approved" && outcome !== "alter" && outcome !== "remake") {
    redirect(`${back}?notice=failed`);
  }
  const supabase = await createClient();
  const { data: order } = await supabase
    .from("costume_orders")
    .select("id")
    .eq("order_number", orderNumber)
    .maybeSingle();
  if (!order) redirect(`${back}?notice=failed`);
  const { error } = await supabase.from("fittings").insert({
    fitting_code: `FIT-${crypto.randomUUID()}`,
    order_id: order.id,
    order_number_raw: orderNumber,
    style_id: Number(text(formData.get("styleId"))) || null,
    dancer_label: label,
    size_label: text(formData.get("sizeCode")) || null,
    outcome,
    fit_notes: text(formData.get("fitNotes")) || null,
    photo_path: text(formData.get("photoPath")) || null,
    fitting_on: text(formData.get("fittingOn")) || null,
    comments: text(formData.get("fitNotes")) || null,
  });
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function saveAlteration(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const orderNumber = text(formData.get("orderNumber"));
  const back = `/production-orders/${encodeURIComponent(orderNumber)}/fittings`;
  if (!canEditInventory(state.profile)) redirect(`${back}?notice=denied`);
  const supabase = await createClient();
  const { data: order } = await supabase
    .from("costume_orders")
    .select("id")
    .eq("order_number", orderNumber)
    .maybeSingle();
  if (!order) redirect(`${back}?notice=failed`);
  const request = text(formData.get("request"));
  const assignedTo = text(formData.get("assignedTo"));
  const { error } = await supabase.from("alterations").insert({
    order_id: order.id,
    request,
    asked_by: text(formData.get("askedBy")) || null,
    assigned_to: assignedTo || null,
    status: "open",
  });
  if (error) redirect(`${back}?notice=failed`);
  if (assignedTo) {
    const { notifyAlterationDue } = await import("@/lib/push/send");
    await notifyAlterationDue({
      recipientId: assignedTo,
      actorId: state.profile.id,
      summary: request || "An alteration was assigned to you.",
    });
  }
  redirect(`${back}?notice=saved`);
}

export async function saveOrderDates(formData: FormData) {
  const orderNumber = text(formData.get("orderNumber"));
  const back = `/production-orders/${encodeURIComponent(orderNumber)}`;
  await editorOrStatus(back);
  const supabase = await createClient();
  const { error } = await supabase
    .from("costume_orders")
    .update({
      due_on: text(formData.get("dueOn")) || null,
      event_on: text(formData.get("eventOn")) || null,
    })
    .eq("order_number", orderNumber);
  if (error) redirect(`${back}?notice=failed`);
  const status = text(formData.get("milestoneStatus"));
  const target = text(formData.get("milestoneOn"));
  if (status && target) {
    const { data: order } = await supabase
      .from("costume_orders")
      .select("id")
      .eq("order_number", orderNumber)
      .maybeSingle();
    if (order) {
      await supabase.from("order_milestones").upsert(
        {
          order_id: order.id,
          production_status: status,
          target_on: target,
          archived_at: null,
        },
        { onConflict: "order_id,production_status" },
      );
    }
  }
  redirect(`${back}?notice=record-saved`);
}
