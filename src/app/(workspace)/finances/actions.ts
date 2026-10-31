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
    runs:
      text(formData.get("runs")) === "production_only"
        ? "production_only"
        : "year_round",
    contractor_profile_id: text(formData.get("contractorId")) || null,
  };
  const id = text(formData.get("id"));
  const supabase = await createClient();
  const { error } = id
    ? await supabase.from("recurring_costs").update(row).eq("id", Number(id))
    : await supabase.from("recurring_costs").insert(row);
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function saveProductionSeason(formData: FormData) {
  await ownerOrRedirect("/finances/running");
  const back = "/finances/running";
  const name = text(formData.get("name"));
  const startDate = text(formData.get("startDate"));
  const endDate = text(formData.get("endDate"));
  if (!name || !startDate || !endDate) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("production_seasons")
    .insert({
      name,
      start_date: startDate,
      end_date: endDate,
    });
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function archiveProductionSeason(formData: FormData) {
  await ownerOrRedirect("/finances/running");
  const { error } = await (
    await createClient()
  )
    .from("production_seasons")
    .update({ archived_at: new Date().toISOString() })
    .eq("id", Number(text(formData.get("id"))));
  if (error) redirect("/finances/running?notice=failed");
  redirect("/finances/running?notice=saved");
}

export async function saveRunSettings(formData: FormData) {
  await ownerOrRedirect("/finances/running");
  const payroll =
    text(formData.get("payrollRuns")) === "year_round"
      ? "year_round"
      : "production_only";
  const variable =
    text(formData.get("variableRuns")) === "year_round"
      ? "year_round"
      : "production_only";
  const { error } = await (
    await createClient()
  )
    .from("finance_run_settings")
    .update({ payroll_runs: payroll, variable_spend_runs: variable })
    .eq("id", true);
  if (error) redirect("/finances/running?notice=failed");
  redirect("/finances/running?notice=saved");
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

export async function saveContractorContract(formData: FormData) {
  await ownerOrRedirect("/finances/payroll");
  const back = "/finances/payroll";
  const total = money(text(formData.get("totalAmount")));
  const contractorId = text(formData.get("contractorId"));
  const startDate = text(formData.get("startDate"));
  const endDate = text(formData.get("endDate"));
  if (total === null || !contractorId || !startDate || !endDate) {
    redirect(`${back}?notice=failed`);
  }
  const payout =
    text(formData.get("payout")) === "lump_sums" ? "lump_sums" : "spread";
  const { error } = await (
    await createClient()
  )
    .from("contractor_contracts")
    .insert({
      contractor_id: contractorId,
      total_amount_cad: total,
      hst_amount_cad: money(text(formData.get("hstAmount"))) ?? 0,
      start_date: startDate,
      end_date: endDate,
      payout,
      notes: text(formData.get("notes")) || null,
    });
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function archiveContractorContract(formData: FormData) {
  await ownerOrRedirect("/finances/payroll");
  const { error } = await (
    await createClient()
  )
    .from("contractor_contracts")
    .update({ archived_at: new Date().toISOString() })
    .eq("id", Number(text(formData.get("id"))));
  if (error) redirect("/finances/payroll?notice=failed");
  redirect("/finances/payroll?notice=saved");
}

export async function saveContractorPayment(formData: FormData) {
  await ownerOrRedirect("/finances/payroll");
  const back = "/finances/payroll";
  const amount = money(text(formData.get("amount")));
  const contractId = Number(text(formData.get("contractId")));
  if (amount === null || !contractId) redirect(`${back}?notice=failed`);
  const dateUnknown = formData.get("dateUnknown") === "on";
  const { error } = await (
    await createClient()
  )
    .from("contractor_payments")
    .insert({
      contract_id: contractId,
      paid_on: dateUnknown ? null : text(formData.get("paidOn")) || null,
      amount_cad: amount,
      hst_cad: money(text(formData.get("hst"))) ?? 0,
      notes: text(formData.get("notes")) || null,
    });
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function archiveContractorPayment(formData: FormData) {
  await ownerOrRedirect("/finances/payroll");
  const { error } = await (
    await createClient()
  )
    .from("contractor_payments")
    .update({ archived_at: new Date().toISOString() })
    .eq("id", Number(text(formData.get("id"))));
  if (error) redirect("/finances/payroll?notice=failed");
  redirect("/finances/payroll?notice=saved");
}

export async function saveOutsideCostumeBudget(formData: FormData) {
  await ownerOrRedirect("/finances/outside-costumes");
  const back = "/finances/outside-costumes";
  const programId = Number(text(formData.get("programId")));
  const season = text(formData.get("seasonLabel"));
  const budget = text(formData.get("budgetAmount"));
  if (!programId || !season) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("outside_costume_budgets")
    .insert({
      program_id: programId,
      season_label: season,
      budget_amount: budget ? money(budget) : null,
      notes: text(formData.get("notes")) || null,
    });
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function archiveOutsideCostumeBudget(formData: FormData) {
  await ownerOrRedirect("/finances/outside-costumes");
  const { error } = await (
    await createClient()
  )
    .from("outside_costume_budgets")
    .update({ archived_at: new Date().toISOString() })
    .eq("id", Number(text(formData.get("id"))));
  if (error) redirect("/finances/outside-costumes?notice=failed");
  redirect("/finances/outside-costumes?notice=saved");
}

export async function importOutsideCostumes(formData: FormData) {
  await ownerOrRedirect("/finances/outside-costumes");
  const back = "/finances/outside-costumes";
  const raw = text(formData.get("payload"));
  let payload: unknown;
  try {
    payload = JSON.parse(raw);
  } catch {
    redirect(`${back}?notice=failed`);
  }
  const { error } = await (
    await createClient()
  ).rpc("upsert_outside_costume_purchases", { payload });
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
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
