"use server";

import { redirect } from "next/navigation";
import {
  canEditInventory,
  canSeePrivateRecords,
  canUpdateOrderStatus,
} from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import {
  checked,
  optionalDate,
  optionalId,
  optionalNumber,
  optionalText,
  orderStatus,
  requiredText,
  type FieldResult,
} from "@/lib/records/edit";
import { isProductionStatus } from "@/lib/orders/production-status";
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

export async function assignOrdersToProgram(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canUpdateOrderStatus(state.profile)) {
    redirect("/production-orders/programs?notice=denied");
  }
  const ids = formData
    .getAll("orderId")
    .map((value) => Number(value))
    .filter((value) => Number.isInteger(value) && value > 0);
  if (ids.length === 0) redirect("/production-orders/programs?notice=choose");
  const programText = String(formData.get("programId") ?? "").trim();
  if (programText && !/^\d+$/.test(programText)) {
    redirect("/production-orders/programs?notice=failed");
  }
  const supabase = await createClient();
  const { error } = await supabase
    .from("costume_orders")
    .update({ program_id: programText ? Number(programText) : null })
    .in("id", ids);
  if (error) redirect("/production-orders/programs?notice=failed");
  redirect("/production-orders/programs?notice=saved");
}

export async function updateProductionStatus(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  const orderNumber = String(formData.get("orderNumber") ?? "").trim();
  const back = `/production-orders/${encodeURIComponent(orderNumber)}`;
  if (!canUpdateOrderStatus(state.profile)) redirect(`${back}?notice=denied`);
  const next = String(formData.get("productionStatus") ?? "");
  const patch: { production_status?: string; program_id?: number | null } = {};
  if (formData.has("productionStatus")) {
    if (!isProductionStatus(next)) redirect(`${back}?notice=status`);
    patch.production_status = next;
  }
  if (formData.has("programId")) {
    const programText = String(formData.get("programId") ?? "").trim();
    if (programText && !/^\d+$/.test(programText)) {
      redirect(`${back}?notice=failed`);
    }
    patch.program_id = programText ? Number(programText) : null;
  }
  if (!patch.production_status && !formData.has("programId")) {
    redirect(`${back}?notice=status`);
  }
  const supabase = await createClient();
  const { error } = await supabase
    .from("costume_orders")
    .update(patch)
    .eq("order_number", orderNumber);
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=record-saved`);
}

async function editor() {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canEditInventory(state.profile))
    redirect("/production-orders?notice=denied");
  return state.profile;
}

export async function saveOrder(formData: FormData) {
  const profile = await editor();
  const returnNumber = String(formData.get("returnNumber") ?? "").trim();
  const back = returnNumber
    ? `/production-orders/${encodeURIComponent(returnNumber)}`
    : "/production-orders/new";
  const idText = String(formData.get("id") ?? "").trim();
  const id = idText ? Number(idText) : null;
  if (idText && !Number.isInteger(id)) bail(back, "failed");

  const orderNumber = take(back, requiredText(formData.get("orderNumber"), 40));
  const song = take(back, optionalText(formData.get("productionSong"), 200));
  const status = take(back, orderStatus(formData.get("status")));
  const orderDate = take(back, optionalDate(formData.get("orderDate")));
  const fitting = take(back, optionalText(formData.get("fittingTarget"), 120));
  const accessory = take(back, optionalText(formData.get("accessory"), 200));
  const female = take(back, optionalNumber(formData.get("femaleTotal")));
  const male = take(back, optionalNumber(formData.get("maleTotal")));
  const notes = take(back, optionalText(formData.get("notes"), 2000));
  const includeProgram = formData.has("programId");
  const programId = includeProgram
    ? take(back, optionalId(formData.get("programId")))
    : null;
  const keepArchived = String(formData.get("archivedAt") ?? "").trim();
  const archivedAt = checked(formData.get("archive"))
    ? keepArchived || new Date().toISOString()
    : null;
  if (female !== null && !Number.isInteger(female)) bail(back, "number");
  if (male !== null && !Number.isInteger(male)) bail(back, "number");

  const supabase = await createClient();
  const row = {
    order_number: orderNumber,
    production_song: song,
    status,
    order_date: orderDate,
    order_date_raw: orderDate,
    fitting_target_raw: fitting,
    accessory,
    female_total: female,
    male_total: male,
    notes,
    archived_at: archivedAt,
    ...(includeProgram ? { program_id: programId } : {}),
  };
  let orderId = id;
  if (orderId) {
    const { error } = await supabase
      .from("costume_orders")
      .update(row)
      .eq("id", orderId);
    const notice = problem(error);
    if (notice) bail(back, notice);
  } else {
    const { data, error } = await supabase
      .from("costume_orders")
      .insert(row)
      .select("id")
      .single();
    const notice = problem(error);
    if (notice || !data) bail(back, notice ?? "failed");
    orderId = data.id;
  }

  if (canSeePrivateRecords(profile)) {
    const contacts = take(back, optionalText(formData.get("contacts"), 500));
    const emails = take(back, optionalText(formData.get("contactEmails"), 500));
    const budget = take(back, optionalNumber(formData.get("budget")));
    const privateNotes = take(
      back,
      optionalText(formData.get("privateNotes"), 2000),
    );
    const { error } = await supabase.from("order_private").upsert(
      {
        order_id: orderId,
        contacts,
        contact_emails: emails,
        budget_per_costume: budget,
        budget_per_costume_raw: budget === null ? null : String(budget),
        restricted_notes: privateNotes,
      },
      { onConflict: "order_id" },
    );
    const notice = problem(error);
    if (notice)
      bail(`/production-orders/${encodeURIComponent(orderNumber)}`, notice);
  }

  redirect(
    `/production-orders/${encodeURIComponent(orderNumber)}?notice=saved`,
  );
}

export async function saveFitting(formData: FormData) {
  await editor();
  const orderNumber = String(formData.get("orderNumber") ?? "").trim();
  const back = `/production-orders/${encodeURIComponent(orderNumber)}`;
  const orderId = take(back, optionalId(formData.get("orderId")));
  if (!orderId) bail(back, "missing");
  const idText = String(formData.get("id") ?? "").trim();
  const id = idText ? Number(idText) : null;
  const code = take(back, requiredText(formData.get("fittingCode"), 40));
  const garment = take(back, optionalText(formData.get("garment"), 200));
  const sizeLabel = take(back, optionalText(formData.get("sizeLabel"), 40));
  const approval = take(back, optionalText(formData.get("approvalStatus"), 80));
  const comments = take(back, optionalText(formData.get("comments"), 2000));
  const keepArchived = String(formData.get("archivedAt") ?? "").trim();
  const archivedAt = checked(formData.get("archive"))
    ? keepArchived || new Date().toISOString()
    : null;
  const row = {
    fitting_code: code,
    order_id: orderId,
    order_number_raw: orderNumber,
    garment,
    size_label: sizeLabel,
    approval_status: approval,
    comments,
    archived_at: archivedAt,
  };
  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("fittings").update(row).eq("id", id)
    : await supabase.from("fittings").insert(row);
  const notice = problem(error);
  if (notice) bail(back, notice);
  redirect(`${back}?notice=saved`);
}
