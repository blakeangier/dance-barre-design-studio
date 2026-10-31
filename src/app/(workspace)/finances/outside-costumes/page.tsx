import { Suspense } from "react";
import {
  archiveOutsideCostumeBudget,
  importOutsideCostumes,
  saveOutsideCostumeBudget,
} from "@/app/(workspace)/finances/actions";
import { ownerGate } from "@/app/(workspace)/finances/guard";
import { FinanceTabs } from "@/components/finances/tabs";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { firstQueryValue } from "@/lib/auth/notices";
import { money } from "@/lib/inventory/format";
import { outsideCostumeSpend } from "@/lib/finances/outside-costumes";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Outside costumes" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type PurchaseRow = {
  id: number;
  program_id: number;
  source_tab: string;
  purchased_on: string | null;
  raw_date: string | null;
  payment_method: string | null;
  vendor: string;
  item_description: string;
  amount: number | string | null;
  currency: "CAD" | "USD";
  arrival_status: string | null;
  reimbursement: boolean;
  reimbursement_note: string | null;
  is_refund: boolean;
  programs: { name: string } | { name: string }[] | null;
};

export default function OutsideCostumesPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <OutsideCostumes searchParams={props.searchParams} />
    </Suspense>
  );
}

async function OutsideCostumes({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const params = await searchParams;
  const notice = firstQueryValue(params.notice);
  const program = firstQueryValue(params.program) ?? "";
  const vendor = firstQueryValue(params.vendor) ?? "";
  const payment = firstQueryValue(params.payment) ?? "";
  const arrival = firstQueryValue(params.arrival) ?? "";
  const month = firstQueryValue(params.month) ?? "";
  const supabase = await createClient();
  const [programsResult, budgetsResult, purchasesResult] = await Promise.all([
    supabase.from("programs").select("id, name").order("name"),
    supabase
      .from("outside_costume_budgets")
      .select(
        "id, program_id, season_label, budget_amount, notes, programs(name)",
      )
      .is("archived_at", null)
      .order("season_label"),
    supabase
      .from("outside_costume_purchases")
      .select(
        "id, program_id, source_tab, purchased_on, raw_date, payment_method, vendor, item_description, amount, currency, arrival_status, reimbursement, reimbursement_note, is_refund, programs(name)",
      )
      .is("archived_at", null)
      .order("purchased_on", { ascending: false, nullsFirst: true }),
  ]);
  const programs = (programsResult.data ?? []) as {
    id: number;
    name: string;
  }[];
  const allPurchases = (purchasesResult.data ?? []) as PurchaseRow[];
  const purchases = allPurchases.filter((row) => {
    if (/^\d+$/.test(program) && row.program_id !== Number(program))
      return false;
    if (vendor && !row.vendor.toLowerCase().includes(vendor.toLowerCase()))
      return false;
    if (
      payment &&
      !(row.payment_method ?? "").toLowerCase().includes(payment.toLowerCase())
    ) {
      return false;
    }
    if (
      arrival &&
      !(row.arrival_status ?? "").toLowerCase().includes(arrival.toLowerCase())
    ) {
      return false;
    }
    if (/^\d{4}-\d{2}$/.test(month) && !row.purchased_on?.startsWith(month)) {
      return false;
    }
    return true;
  });
  const spend = outsideCostumeSpend(
    purchases.map((row) => ({
      vendor: row.vendor,
      amount: row.amount === null ? null : Number(row.amount),
      currency: row.currency === "USD" ? "USD" : "CAD",
      purchasedOn: row.purchased_on,
      rawDate: row.raw_date,
      refund: row.is_refund,
      archived: false,
    })),
  );
  const budgets = (budgetsResult.data ?? []) as {
    id: number;
    program_id: number;
    season_label: string;
    budget_amount: number | string | null;
    notes: string | null;
    programs: { name: string } | { name: string }[] | null;
  }[];
  const cadByProgram = new Map<number, number>();
  for (const row of allPurchases) {
    if (row.amount === null || row.currency === "USD") continue;
    const signed =
      row.is_refund && Number(row.amount) > 0
        ? -Number(row.amount)
        : Number(row.amount);
    cadByProgram.set(
      row.program_id,
      (cadByProgram.get(row.program_id) ?? 0) + signed,
    );
  }

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Outside costumes</h1>
      <FinanceTabs current="outside" />
      <p className="text-sm text-muted">
        Costumes bought from other stores for the competitive programs. This is
        not part of Design Studio startup or running costs. Import the weekly
        sheet as JSON. Do not put a full card number in the payment method.
      </p>
      {notice === "saved" ? <StatusNote>Saved.</StatusNote> : null}
      {notice === "failed" ? (
        <StatusNote tone="error">That did not save.</StatusNote>
      ) : null}
      <section className="flex flex-col gap-2">
        <h2 className="font-serif text-2xl text-ink">Budget and spent</h2>
        {budgets.length === 0 ? (
          <p className="text-sm text-muted">No budgets yet.</p>
        ) : (
          budgets.map((budget) => {
            const spent = cadByProgram.get(budget.program_id) ?? 0;
            const limit =
              budget.budget_amount === null
                ? null
                : Number(budget.budget_amount);
            return (
              <article
                key={budget.id}
                className="rounded-2xl border border-line bg-card p-3 text-sm"
              >
                <p className="font-medium text-ink">
                  {programName(budget.programs)} · {budget.season_label}
                </p>
                <p>
                  Budget {limit === null ? "not set" : money(limit)} · CAD spent{" "}
                  {money(spent)}
                  {limit === null ? "" : ` · Remaining ${money(limit - spent)}`}
                </p>
                <form action={archiveOutsideCostumeBudget}>
                  <input type="hidden" name="id" value={budget.id} />
                  <button type="submit" className="min-h-11 font-medium">
                    Archive
                  </button>
                </form>
              </article>
            );
          })
        )}
        <form action={saveOutsideCostumeBudget} className="flex flex-col gap-2">
          <select
            name="programId"
            required
            className="min-h-12 rounded-xl border border-line bg-card px-3"
          >
            {programs.map((item) => (
              <option key={item.id} value={item.id}>
                {item.name}
              </option>
            ))}
          </select>
          <input
            name="seasonLabel"
            required
            placeholder="Season label"
            className="min-h-12 rounded-xl border border-line bg-card px-3"
          />
          <input
            name="budgetAmount"
            inputMode="decimal"
            placeholder="CAD budget, optional"
            className="min-h-12 rounded-xl border border-line bg-card px-3"
          />
          <textarea
            name="notes"
            placeholder="Notes"
            className="min-h-20 rounded-xl border border-line bg-card px-3 py-2"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium"
          >
            Save budget
          </button>
        </form>
      </section>
      <section className="text-sm">
        <h2 className="font-serif text-2xl text-ink">Totals</h2>
        <p>
          CAD {money(spend.cad)} · USD{" "}
          {spend.usd.toLocaleString("en-CA", {
            style: "currency",
            currency: "USD",
          })}
        </p>
        <p className="text-muted">
          {spend.missingAmount} without an amount · {spend.missingDate} without
          a date
        </p>
        <h3 className="mt-2 font-medium">By vendor</h3>
        <ul>
          {spend.byVendor.map((row) => (
            <li key={row.vendor}>
              {row.vendor} · {money(row.cad)}
              {row.usd ? ` · USD ${row.usd}` : ""}
            </li>
          ))}
        </ul>
        <h3 className="mt-2 font-medium">By month</h3>
        <ul>
          {spend.byMonth.map((row) => (
            <li key={row.month}>
              {row.month} · {money(row.cad)}
              {row.usd ? ` · USD ${row.usd}` : ""}
            </li>
          ))}
        </ul>
      </section>
      <form className="grid gap-2 sm:grid-cols-2" method="get">
        <select
          name="program"
          defaultValue={program}
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <option value="">Every program</option>
          {programs.map((item) => (
            <option key={item.id} value={item.id}>
              {item.name}
            </option>
          ))}
        </select>
        <input
          name="vendor"
          defaultValue={vendor}
          placeholder="Vendor"
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        />
        <input
          name="payment"
          defaultValue={payment}
          placeholder="Payment method"
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        />
        <input
          name="arrival"
          defaultValue={arrival}
          placeholder="Arrival status"
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        />
        <input
          name="month"
          type="month"
          defaultValue={month}
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        />
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white"
        >
          Filter
        </button>
      </form>
      <ul className="flex flex-col gap-2">
        {purchases.map((row) => {
          const missingAmount = row.amount === null;
          const missingDate = !row.purchased_on && !row.raw_date?.trim();
          return (
            <li
              key={row.id}
              className="rounded-2xl border border-line bg-card p-3 text-sm"
            >
              <p className="font-medium text-ink">
                {programName(row.programs)} · {row.vendor}
              </p>
              <p>{row.item_description}</p>
              <p className="text-muted">
                {row.purchased_on ?? row.raw_date ?? "No date"} ·{" "}
                {row.payment_method ?? "No payment method"} ·{" "}
                {row.arrival_status ?? "No arrival status"}
                {row.reimbursement ? " · reimbursed" : ""}
              </p>
              <p>
                {missingAmount
                  ? "No amount"
                  : `${Number(row.amount).toLocaleString("en-CA", { style: "currency", currency: row.currency })}`}
                {row.is_refund ? " · refund" : ""}
              </p>
              {missingAmount || missingDate ? (
                <p className="font-medium text-ink">
                  {missingAmount ? "Missing amount. " : ""}
                  {missingDate ? "Missing date." : ""}
                </p>
              ) : null}
            </li>
          );
        })}
      </ul>
      <form action={importOutsideCostumes} className="flex flex-col gap-2">
        <label className="text-sm font-medium" htmlFor="payload">
          Weekly sheet JSON
        </label>
        <textarea
          id="payload"
          name="payload"
          required
          placeholder='{"rows":[]}'
          className="min-h-32 rounded-xl border border-line bg-card px-3 py-2 font-mono text-sm"
        />
        <button
          type="submit"
          className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium"
        >
          Import
        </button>
      </form>
    </div>
  );
}

function programName(
  value: { name: string } | { name: string }[] | null,
): string {
  if (!value) return "Program";
  return Array.isArray(value) ? (value[0]?.name ?? "Program") : value.name;
}
