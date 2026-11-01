"use server";

import { redirect } from "next/navigation";
import { financesStatus } from "@/lib/finances/access";
import { looksLikeFullCardNumber } from "@/lib/finances/outside-costumes";
import { getSessionState } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

const TABLES = new Set([
  "finance_spend_lines",
  "finance_committed_items",
  "finance_funding_lines",
  "finance_cost_lines",
  "expense_log",
  "contractor_invoices",
  "contractor_contract_phases",
  "contractor_contracts",
  "contractor_payments",
  "equipment_quote_items",
  "lease_options",
  "finance_projection_months",
  "finance_projection_team",
  "finance_projection_costs",
  "finance_todos",
  "startup_costs",
  "outside_costume_purchases",
]);

function text(value: FormDataEntryValue | null): string {
  return typeof value === "string" ? value.trim() : "";
}

function money(value: string): number | null {
  if (!value) return null;
  const number = Number(value);
  return Number.isFinite(number) ? number : null;
}

function backTo(value: string): string {
  if (!value.startsWith("/finances") || value.startsWith("//")) {
    return "/finances";
  }
  return value;
}

function rejectCard(value: string, back: string) {
  if (looksLikeFullCardNumber(value)) redirect(`${back}?notice=failed`);
}

async function ownerOrRedirect() {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (financesStatus(state.profile.role) === 403) redirect("/");
  return state;
}

async function finish(back: string, error: { message: string } | null) {
  if (error) redirect(`${back}?notice=failed`);
  redirect(`${back}?notice=saved`);
}

export async function archiveFinanceRow(formData: FormData) {
  const back = backTo(text(formData.get("back")));
  await ownerOrRedirect();
  const table = text(formData.get("table"));
  const id = Number(text(formData.get("id")));
  if (!TABLES.has(table) || !id) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from(table)
    .update({ archived_at: new Date().toISOString() })
    .eq("id", id);
  await finish(back, error);
}

export async function saveSpendLine(formData: FormData) {
  const back = "/finances";
  await ownerOrRedirect();
  const label = text(formData.get("label"));
  const amount = money(text(formData.get("amount")));
  const section = text(formData.get("section"));
  const href = text(formData.get("detailHref"));
  if (!label || amount === null) redirect(`${back}?notice=failed`);
  if (href && !href.startsWith("/finances")) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("finance_spend_lines")
    .insert({
      section:
        section === "outside_costumes" ? "outside_costumes" : "design_co",
      label,
      amount,
      detail_href: href || null,
      source_note: text(formData.get("sourceNote")),
    });
  await finish(back, error);
}

export async function saveCommittedItem(formData: FormData) {
  const back = "/finances";
  await ownerOrRedirect();
  const label = text(formData.get("label"));
  const amount = money(text(formData.get("amount")));
  const href = text(formData.get("detailHref"));
  if (!label || amount === null) redirect(`${back}?notice=failed`);
  if (href && !href.startsWith("/finances")) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("finance_committed_items")
    .insert({
      label,
      amount,
      detail_href: href || null,
      counts_as_startup: formData.get("countsAsStartup") === "on",
      source_note: text(formData.get("sourceNote")),
    });
  await finish(back, error);
}

export async function saveFundingLine(formData: FormData) {
  const back = "/finances";
  await ownerOrRedirect();
  const label = text(formData.get("label"));
  const amount = money(text(formData.get("amount")));
  rejectCard(label, back);
  if (!label || amount === null) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("finance_funding_lines")
    .insert({
      paid_from: text(formData.get("paidFrom")) || "not_recorded",
      label,
      amount,
      source_note: text(formData.get("sourceNote")),
    });
  await finish(back, error);
}

export async function saveCostLine(formData: FormData) {
  const back = "/finances/cost";
  await ownerOrRedirect();
  const label = text(formData.get("label"));
  const amount = money(text(formData.get("amount")));
  if (!label || amount === null) redirect(`${back}?notice=failed`);
  const section = text(formData.get("section"));
  const adjustment = text(formData.get("adjustment"));
  const { error } = await (
    await createClient()
  )
    .from("finance_cost_lines")
    .insert({
      section:
        section === "purchased_outside" ? "purchased_outside" : "make_in_house",
      label,
      amount,
      hst: money(text(formData.get("hst"))) ?? 0,
      adjustment: ["canceled", "duplicate", "owing"].includes(adjustment)
        ? adjustment
        : "none",
      source_note: text(formData.get("sourceNote")),
    });
  await finish(back, error);
}

export async function saveStartupShare(formData: FormData) {
  const back = "/finances/cost";
  await ownerOrRedirect();
  const share = money(text(formData.get("startupShare")));
  if (share === null || share < 0 || share > 100)
    redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("startup_costs")
    .update({
      startup_share_percent: share,
      source_note: text(formData.get("sourceNote")),
    })
    .eq("id", Number(text(formData.get("id"))));
  await finish(back, error);
}

export async function saveUnitSettings(formData: FormData) {
  const back = "/finances/cost";
  await ownerOrRedirect();
  const { error } = await (
    await createClient()
  )
    .from("finance_unit_settings")
    .upsert(
      {
        id: true,
        units: money(text(formData.get("units"))),
        cost_per_unit: money(text(formData.get("costPerUnit"))),
        source_note: text(formData.get("sourceNote")),
      },
      { onConflict: "id" },
    );
  await finish(back, error);
}

export async function saveProjectionMonth(formData: FormData) {
  const back = "/finances/projection";
  await ownerOrRedirect();
  const month = text(formData.get("month"));
  if (!/^\d{4}-\d{2}-01$/.test(month)) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("finance_projection_months")
    .upsert(
      {
        month_start: month,
        is_production: text(formData.get("isProduction")) === "1",
        source_note: text(formData.get("sourceNote")),
        archived_at: null,
      },
      { onConflict: "month_start" },
    );
  await finish(back, error);
}

export async function saveProjectionPerson(formData: FormData) {
  const back = "/finances/projection";
  await ownerOrRedirect();
  const name = text(formData.get("personName"));
  const rate = money(text(formData.get("rate")));
  const payKind = text(formData.get("payKind"));
  if (!name || rate === null || rate < 0) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("finance_projection_team")
    .insert({
      person_name: name,
      role_label: text(formData.get("roleLabel")) || null,
      pay_kind:
        payKind === "fixed_biweekly" ? "fixed_biweekly" : "hourly_weekly",
      hours_per_week: money(text(formData.get("hoursPerWeek"))),
      rate,
      adds_hst: formData.get("addsHst") === "on",
      runs:
        text(formData.get("runs")) === "production_only"
          ? "production_only"
          : "every_month",
      source_note: text(formData.get("sourceNote")),
    });
  await finish(back, error);
}

export async function saveProjectionCost(formData: FormData) {
  const back = "/finances/projection";
  await ownerOrRedirect();
  const label = text(formData.get("label"));
  const amount = money(text(formData.get("amount")));
  if (!label || amount === null) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("finance_projection_costs")
    .insert({
      label,
      amount,
      period: text(formData.get("period")) === "year" ? "year" : "month",
      runs:
        text(formData.get("runs")) === "production_only"
          ? "production_only"
          : "every_month",
      source_note: text(formData.get("sourceNote")),
    });
  await finish(back, error);
}

export async function openPerson(formData: FormData) {
  await ownerOrRedirect();
  const profileId = text(formData.get("profileId"));
  redirect(backTo(`/finances/people/${profileId}`));
}

export async function saveInvoice(formData: FormData) {
  const profileId = text(formData.get("profileId"));
  const back = backTo(`/finances/people/${profileId}`);
  await ownerOrRedirect();
  const method = text(formData.get("paymentMethod"));
  rejectCard(method, back);
  const { error } = await (
    await createClient()
  )
    .from("contractor_invoices")
    .insert({
      profile_id: profileId,
      paid_on: text(formData.get("paidOn")) || null,
      invoice_number: text(formData.get("invoiceNumber")) || null,
      period_start: text(formData.get("periodStart")) || null,
      period_end: text(formData.get("periodEnd")) || null,
      hours: money(text(formData.get("hours"))),
      rate: money(text(formData.get("rate"))),
      hst: money(text(formData.get("hst"))) ?? 0,
      expected: money(text(formData.get("expected"))),
      amount_paid: money(text(formData.get("amountPaid"))),
      payment_method: method || null,
      notes: text(formData.get("notes")) || null,
      source_note: text(formData.get("sourceNote")),
    });
  await finish(back, error);
}

export async function saveContractPhase(formData: FormData) {
  const back = "/finances/contracts";
  await ownerOrRedirect();
  const label = text(formData.get("label"));
  const before = money(text(formData.get("beforeHst")));
  if (!label || before === null) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("contractor_contract_phases")
    .insert({
      contract_id: Number(text(formData.get("contractId"))),
      label,
      amount_before_hst: before,
      hst: money(text(formData.get("hst"))) ?? 0,
      notes: text(formData.get("notes")) || null,
      source_note: text(formData.get("sourceNote")),
    });
  await finish(back, error);
}

export async function saveContract(formData: FormData) {
  const back = "/finances/contracts";
  await ownerOrRedirect();
  const total = money(text(formData.get("total")));
  const start = text(formData.get("startDate"));
  const end = text(formData.get("endDate"));
  const contractorId = text(formData.get("contractorId"));
  if (total === null || !start || !end || !contractorId) {
    redirect(`${back}?notice=failed`);
  }
  const { error } = await (
    await createClient()
  )
    .from("contractor_contracts")
    .insert({
      contractor_id: contractorId,
      total_amount_cad: total,
      hst_amount_cad: money(text(formData.get("hst"))) ?? 0,
      start_date: start,
      end_date: end,
      payout: "spread",
      notes: text(formData.get("notes")) || null,
      source_note: text(formData.get("sourceNote")),
    });
  await finish(back, error);
}

export async function saveContractPayment(formData: FormData) {
  const back = "/finances/contracts";
  await ownerOrRedirect();
  const amount = money(text(formData.get("amount")));
  const method = text(formData.get("paymentMethod"));
  rejectCard(method, back);
  if (amount === null) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("contractor_payments")
    .insert({
      contract_id: Number(text(formData.get("contractId"))),
      paid_on: text(formData.get("paidOn")) || null,
      amount_cad: amount,
      hst_cad: money(text(formData.get("hst"))) ?? 0,
      payment_method: method || null,
      description: text(formData.get("description")) || null,
      notes: text(formData.get("notes")) || null,
      source_note: text(formData.get("sourceNote")),
    });
  await finish(back, error);
}

export async function saveExpense(formData: FormData) {
  const back = "/finances/expenses";
  await ownerOrRedirect();
  const description = text(formData.get("description"));
  const amount = money(text(formData.get("amount")));
  const payment = text(formData.get("paymentAsEntered"));
  rejectCard(payment, back);
  if (!description || amount === null) redirect(`${back}?notice=failed`);
  const cardId = text(formData.get("cardTransactionId"));
  const { error } = await (await createClient()).from("expense_log").insert({
    occurred_on: text(formData.get("occurredOn")) || null,
    amount,
    payment_as_entered: payment || null,
    paid_from: text(formData.get("paidFrom")) || "not_recorded",
    vendor: text(formData.get("vendor")) || null,
    description,
    category: text(formData.get("category")) || "admin_fees",
    flag_notes: text(formData.get("flagNotes")) || null,
    source_note: text(formData.get("sourceNote")),
    card_transaction_id: cardId ? Number(cardId) : null,
  });
  await finish(back, error);
}

export async function saveEquipmentQuote(formData: FormData) {
  const back = "/finances/equipment";
  await ownerOrRedirect();
  const label = text(formData.get("label"));
  if (!label) redirect(`${back}?notice=failed`);
  const { error } = await (
    await createClient()
  )
    .from("equipment_quote_items")
    .insert({
      label,
      new_price: money(text(formData.get("newPrice"))),
      preowned_price: money(text(formData.get("preownedPrice"))),
      notes: text(formData.get("notes")) || null,
      source_note: text(formData.get("sourceNote")),
    });
  await finish(back, error);
}

export async function saveLeaseOption(formData: FormData) {
  const back = "/finances/equipment";
  await ownerOrRedirect();
  const label = text(formData.get("label"));
  const term = Number(text(formData.get("termMonths")));
  const monthly = money(text(formData.get("monthly")));
  if (!label || !term || monthly === null) redirect(`${back}?notice=failed`);
  const chosen = formData.get("isChosen") === "on";
  const supabase = await createClient();
  if (chosen) {
    const cleared = await supabase
      .from("lease_options")
      .update({ is_chosen: false })
      .eq("is_chosen", true)
      .is("archived_at", null);
    if (cleared.error) redirect(`${back}?notice=failed`);
  }
  const { error } = await supabase.from("lease_options").insert({
    label,
    term_months: term,
    monthly_payment: monthly,
    hst: money(text(formData.get("hst"))) ?? 0,
    buyout: money(text(formData.get("buyout"))),
    upfront: money(text(formData.get("upfront"))) ?? 0,
    is_chosen: chosen,
    payments_made: Number(text(formData.get("paymentsMade"))) || 0,
    started_on: text(formData.get("startedOn")) || null,
    notes: text(formData.get("notes")) || null,
    source_note: text(formData.get("sourceNote")),
  });
  await finish(back, error);
}

export async function saveFinanceTodo(formData: FormData) {
  const back = "/finances/todos";
  await ownerOrRedirect();
  const item = text(formData.get("item"));
  if (!item) redirect(`${back}?notice=failed`);
  const status = text(formData.get("status"));
  const { error } = await (await createClient()).from("finance_todos").insert({
    item,
    amount: money(text(formData.get("amount"))),
    status: status === "done" || status === "waiting" ? status : "open",
    action: text(formData.get("action")) || null,
    source_note: text(formData.get("sourceNote")),
  });
  await finish(back, error);
}

export async function setFinanceTodoStatus(formData: FormData) {
  const back = "/finances/todos";
  await ownerOrRedirect();
  const status = text(formData.get("status"));
  const { error } = await (
    await createClient()
  )
    .from("finance_todos")
    .update({
      status: status === "done" || status === "waiting" ? status : "open",
    })
    .eq("id", Number(text(formData.get("id"))));
  await finish(back, error);
}

export async function saveOutsideCostumeFlags(formData: FormData) {
  const back = "/finances/outside-costumes";
  await ownerOrRedirect();
  const { error } = await (
    await createClient()
  )
    .from("outside_costume_purchases")
    .update({
      vendor_type: text(formData.get("vendorType")) || null,
      flag_duplicate: formData.get("flagDuplicate") === "on",
      flag_canceled: formData.get("flagCanceled") === "on",
      flag_owing: formData.get("flagOwing") === "on",
      source_note: text(formData.get("sourceNote")),
    })
    .eq("id", Number(text(formData.get("id"))));
  await finish(back, error);
}
