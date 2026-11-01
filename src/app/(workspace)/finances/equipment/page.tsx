import { Suspense } from "react";
import {
  saveEquipmentQuote,
  saveLeaseOption,
} from "@/app/(workspace)/finances/workbook-actions";
import { ownerGate } from "@/app/(workspace)/finances/guard";
import {
  ArchiveForm,
  FinanceFrame,
  SourceLine,
  financeButton,
  financeField,
} from "@/components/finances/frame";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { firstQueryValue } from "@/lib/auth/notices";
import { money } from "@/lib/inventory/format";
import { equipmentSavings, leaseStanding } from "@/lib/finances/workbook";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Equipment and lease" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function EquipmentPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Equipment searchParams={props.searchParams} />
    </Suspense>
  );
}

async function Equipment({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const notice = firstQueryValue((await searchParams).notice);
  const supabase = await createClient();
  const [quoteResult, leaseResult] = await Promise.all([
    supabase
      .from("equipment_quote_items")
      .select("id, label, new_price, preowned_price, notes, source_note")
      .is("archived_at", null)
      .order("sort_order"),
    supabase
      .from("lease_options")
      .select(
        "id, label, term_months, monthly_payment, hst, buyout, upfront, is_chosen, payments_made, started_on, notes, source_note",
      )
      .is("archived_at", null)
      .order("label"),
  ]);
  const quotes = (quoteResult.data ?? []) as {
    id: number;
    label: string;
    new_price: number | string | null;
    preowned_price: number | string | null;
    notes: string | null;
    source_note: string;
  }[];
  const leases = (leaseResult.data ?? []) as {
    id: number;
    label: string;
    term_months: number;
    monthly_payment: number | string;
    hst: number | string;
    buyout: number | string | null;
    upfront: number | string;
    is_chosen: boolean;
    payments_made: number;
    started_on: string | null;
    notes: string | null;
    source_note: string;
  }[];
  const chosen = leases.find((lease) => lease.is_chosen) ?? null;
  const chosenStanding = chosen
    ? leaseStanding({
        termMonths: chosen.term_months,
        monthly: Number(chosen.monthly_payment),
        hst: Number(chosen.hst),
        upfront: Number(chosen.upfront),
        paymentsMade: chosen.payments_made,
        startedOn: chosen.started_on,
      })
    : null;

  return (
    <FinanceFrame
      title="Equipment and lease"
      current="equipment"
      notice={notice}
      lede="Quote prices stay beside the lease options. Savings are the new price minus the pre-owned price."
    >
      <div className="overflow-x-auto">
        <table className="w-full min-w-[40rem] text-left text-sm">
          <thead>
            <tr className="text-muted">
              <th className="py-2 pr-3 font-medium">Item</th>
              <th className="py-2 pr-3 font-medium">New</th>
              <th className="py-2 pr-3 font-medium">Pre-owned</th>
              <th className="py-2 pr-3 font-medium">Savings</th>
              <th className="py-2 font-medium">Source</th>
            </tr>
          </thead>
          <tbody>
            {quotes.map((row) => {
              const savings = equipmentSavings(
                row.new_price === null ? null : Number(row.new_price),
                row.preowned_price === null ? null : Number(row.preowned_price),
              );
              return (
                <tr key={row.id} className="border-t border-line">
                  <td className="py-2 pr-3">
                    {row.label}
                    {row.notes ? (
                      <span className="block text-muted">{row.notes}</span>
                    ) : null}
                  </td>
                  <td className="py-2 pr-3">
                    {row.new_price === null
                      ? "—"
                      : money(Number(row.new_price))}
                  </td>
                  <td className="py-2 pr-3">
                    {row.preowned_price === null
                      ? "—"
                      : money(Number(row.preowned_price))}
                  </td>
                  <td className="py-2 pr-3">
                    {savings === null ? "—" : money(savings)}
                  </td>
                  <td className="py-2">
                    <SourceLine note={row.source_note} />
                    <ArchiveForm
                      table="equipment_quote_items"
                      id={row.id}
                      back="/finances/equipment"
                    />
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      <form action={saveEquipmentQuote} className="grid gap-2 sm:grid-cols-2">
        <input
          name="label"
          required
          placeholder="Equipment"
          className={financeField}
        />
        <input
          name="newPrice"
          inputMode="decimal"
          placeholder="New price"
          className={financeField}
        />
        <input
          name="preownedPrice"
          inputMode="decimal"
          placeholder="Pre-owned price"
          className={financeField}
        />
        <input name="notes" placeholder="Notes" className={financeField} />
        <input
          name="sourceNote"
          placeholder="Source"
          className={financeField}
        />
        <button type="submit" className={financeButton}>
          Add quote item
        </button>
      </form>
      <h2 className="font-serif text-2xl text-ink">Lease options</h2>
      <div className="overflow-x-auto">
        <table className="w-full min-w-[48rem] text-left text-sm">
          <thead>
            <tr className="text-muted">
              <th className="py-2 pr-3 font-medium">Option</th>
              <th className="py-2 pr-3 font-medium">Term</th>
              <th className="py-2 pr-3 font-medium">Monthly</th>
              <th className="py-2 pr-3 font-medium">HST</th>
              <th className="py-2 pr-3 font-medium">Buyout</th>
              <th className="py-2 pr-3 font-medium">First and last</th>
              <th className="py-2 font-medium">Source</th>
            </tr>
          </thead>
          <tbody>
            {leases.map((lease) => (
              <tr key={lease.id} className="border-t border-line">
                <td className="py-2 pr-3">
                  {lease.label}
                  {lease.is_chosen ? " · chosen" : ""}
                </td>
                <td className="py-2 pr-3">{lease.term_months} months</td>
                <td className="py-2 pr-3">
                  {money(Number(lease.monthly_payment))}
                </td>
                <td className="py-2 pr-3">{money(Number(lease.hst))}</td>
                <td className="py-2 pr-3">
                  {lease.buyout === null ? "—" : money(Number(lease.buyout))}
                </td>
                <td className="py-2 pr-3">{money(Number(lease.upfront))}</td>
                <td className="py-2">
                  <SourceLine note={lease.source_note} />
                  <ArchiveForm
                    table="lease_options"
                    id={lease.id}
                    back="/finances/equipment"
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {chosen && chosenStanding ? (
        <section className="rounded-2xl border border-line bg-card p-4 text-sm">
          <h2 className="font-serif text-2xl text-ink">
            Chosen lease · {chosen.label}
          </h2>
          <p>Payments made {chosen.payments_made}</p>
          <p>Paid to date {money(chosenStanding.paidToDate)}</p>
          <p>Remaining payments {chosenStanding.remainingPayments}</p>
          <p>
            Final payment month{" "}
            {chosenStanding.finalMonth ?? "Start date not recorded"}
          </p>
          <SourceLine note={chosen.source_note} />
        </section>
      ) : (
        <p className="text-sm text-muted">No chosen lease yet.</p>
      )}
      <form action={saveLeaseOption} className="grid gap-2 sm:grid-cols-2">
        <input
          name="label"
          required
          placeholder="Lease"
          className={financeField}
        />
        <input
          name="termMonths"
          required
          inputMode="numeric"
          placeholder="Term in months"
          className={financeField}
        />
        <input
          name="monthly"
          required
          inputMode="decimal"
          placeholder="Monthly payment"
          className={financeField}
        />
        <input
          name="hst"
          inputMode="decimal"
          placeholder="HST"
          className={financeField}
        />
        <input
          name="buyout"
          inputMode="decimal"
          placeholder="Buyout"
          className={financeField}
        />
        <input
          name="upfront"
          inputMode="decimal"
          placeholder="Up-front first and last"
          className={financeField}
        />
        <input
          name="paymentsMade"
          inputMode="numeric"
          placeholder="Payments made"
          className={financeField}
        />
        <input
          name="startedOn"
          type="date"
          aria-label="Lease start"
          className={financeField}
        />
        <input name="notes" placeholder="Notes" className={financeField} />
        <input
          name="sourceNote"
          placeholder="Source"
          className={financeField}
        />
        <label className="flex min-h-11 items-center gap-2 text-sm">
          <input type="checkbox" name="isChosen" />
          This is the chosen lease
        </label>
        <button type="submit" className={financeButton}>
          Add lease option
        </button>
      </form>
    </FinanceFrame>
  );
}
