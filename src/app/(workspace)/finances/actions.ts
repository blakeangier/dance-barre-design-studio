"use server";

import { redirect } from "next/navigation";
import { financesStatus } from "@/lib/finances/access";
import { getSessionState } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

function text(value: FormDataEntryValue | null): string {
  return typeof value === "string" ? value.trim() : "";
}

async function ownerOrRedirect(back: string) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (financesStatus(state.profile.role) === 403) redirect("/");
  return { state, back };
}

function money(value: string): number | null {
  if (!value) return null;
  const number = Number(value);
  return Number.isFinite(number) ? number : null;
}

export async function saveStartupCost(formData: FormData) {
  const { state } = await ownerOrRedirect("/finances/startup");
  const back = "/finances/startup";
  const amount = money(text(formData.get("amountCad")));
  const hst = money(text(formData.get("hstCad"))) ?? 0;
  const description = text(formData.get("description"));
  const dateUnknown = formData.get("dateUnknown") === "on";
  const occurredOn = dateUnknown ? "" : text(formData.get("occurredOn"));
  const categoryId = Number(text(formData.get("categoryId")));
  if (amount === null || !description || !categoryId) {
    redirect(`${back}?notice=failed`);
  }
  const source =
    text(formData.get("source")) === "card_statement"
      ? "card_statement"
      : "manual";
  const row = {
    occurred_on: occurredOn || null,
    description,
    vendor: text(formData.get("vendor")) || null,
    category_id: categoryId,
    amount_cad: amount,
    hst_cad: hst,
    notes: text(formData.get("notes")) || null,
    source,
    created_by: state.profile.id,
  };
  const id = text(formData.get("id"));
  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("startup_costs").update(row).eq("id", Number(id))
    : await supabase.from("startup_costs").insert(row);
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function archiveStartupCost(formData: FormData) {
  await ownerOrRedirect("/finances/startup");
  const { error } = await (
    await createClient()
  )
    .from("startup_costs")
    .update({ archived_at: new Date().toISOString() })
    .eq("id", Number(text(formData.get("id"))));
  if (error) redirect("/finances/startup?notice=failed");
  redirect("/finances/startup?notice=saved");
}

export async function saveRecurringCost(formData: FormData) {
  await ownerOrRedirect("/finances/running");
  const back = "/finances/running";
  const amount = money(text(formData.get("amountCad")));
  const name = text(formData.get("name"));
  const frequency = text(formData.get("frequency"));
  const startDate = text(formData.get("startDate"));
  const categoryId = Number(text(formData.get("categoryId")));
  if (amount === null || !name || !frequency || !startDate || !categoryId) {
    redirect(`${back}?notice=failed`);
  }
  const row = {
    name,
    category_id: categoryId,
    amount_cad: amount,
    hst_cad: money(text(formData.get("hstCad"))) ?? 0,
    frequency,
    start_date: startDate,
    end_date: text(formData.get("endDate")) || null,
    notes: text(formData.get("notes")) || null,
  };
  const id = text(formData.get("id"));
  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("recurring_costs").update(row).eq("id", Number(id))
    : await supabase.from("recurring_costs").insert(row);
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function archiveRecurringCost(formData: FormData) {
  await ownerOrRedirect("/finances/running");
  const { error } = await (
    await createClient()
  )
    .from("recurring_costs")
    .update({ archived_at: new Date().toISOString() })
    .eq("id", Number(text(formData.get("id"))));
  if (error) redirect("/finances/running?notice=failed");
  redirect("/finances/running?notice=saved");
}

export async function savePayrollActual(formData: FormData) {
  await ownerOrRedirect("/finances/payroll");
  const back = "/finances/payroll";
  const gross = money(text(formData.get("grossCad")));
  const start = text(formData.get("periodStart"));
  const end = text(formData.get("periodEnd"));
  if (gross === null || !start || !end) redirect(`${back}?notice=failed`);
  const row = {
    period_start: start,
    period_end: end,
    gross_cad: gross,
    employer_cpp_cad: money(text(formData.get("employerCpp"))) ?? 0,
    employer_ei_cad: money(text(formData.get("employerEi"))) ?? 0,
    notes: text(formData.get("notes")) || null,
  };
  const id = text(formData.get("id"));
  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("payroll_actuals").update(row).eq("id", Number(id))
    : await supabase.from("payroll_actuals").insert(row);
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function archivePayrollActual(formData: FormData) {
  await ownerOrRedirect("/finances/payroll");
  const { error } = await (
    await createClient()
  )
    .from("payroll_actuals")
    .update({ archived_at: new Date().toISOString() })
    .eq("id", Number(text(formData.get("id"))));
  if (error) redirect("/finances/payroll?notice=failed");
  redirect("/finances/payroll?notice=saved");
}

export async function updateCardTransaction(formData: FormData) {
  await ownerOrRedirect("/finances/cards");
  const category = text(formData.get("categoryId"));
  const purchase = text(formData.get("purchaseLineId"));
  const { error } = await (
    await createClient()
  )
    .from("card_transactions")
    .update({
      category_id: category ? Number(category) : null,
      notes: text(formData.get("notes")) || null,
      hst_cad: money(text(formData.get("hstCad"))) ?? 0,
      is_startup: formData.get("isStartup") === "on",
      excluded: formData.get("excluded") === "on",
      purchase_line_id: purchase ? Number(purchase) : null,
    })
    .eq("id", Number(text(formData.get("id"))));
  if (error) redirect("/finances/cards?notice=failed");
  redirect("/finances/cards?notice=saved");
}
