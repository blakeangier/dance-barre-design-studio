import { Suspense } from "react";
import { saveInvoice } from "@/app/(workspace)/finances/workbook-actions";
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
import { invoiceSummary } from "@/lib/finances/workbook";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Person" };

type PageProps = {
  params: Promise<{ profileId: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function PersonPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Person params={props.params} searchParams={props.searchParams} />
    </Suspense>
  );
}

async function Person({ params, searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const { profileId } = await params;
  const notice = firstQueryValue((await searchParams).notice);
  if (!/^[0-9a-f-]{36}$/i.test(profileId)) {
    return (
      <FinanceFrame title="Person" current="people" notice={null}>
        <p className="text-sm text-muted">That person is not in the list.</p>
      </FinanceFrame>
    );
  }
  const supabase = await createClient();
  const [profileResult, invoiceResult] = await Promise.all([
    supabase
      .from("profiles")
      .select("full_name")
      .eq("id", profileId)
      .maybeSingle(),
    supabase
      .from("contractor_invoices")
      .select(
        "id, paid_on, invoice_number, period_start, period_end, hours, rate, hst, expected, amount_paid, payment_method, notes, source_note",
      )
      .eq("profile_id", profileId)
      .is("archived_at", null)
      .order("paid_on", { ascending: false, nullsFirst: true }),
  ]);
  const profile = profileResult.data as { full_name: string } | null;
  const rows = (invoiceResult.data ?? []) as {
    id: number;
    paid_on: string | null;
    invoice_number: string | null;
    period_start: string | null;
    period_end: string | null;
    hours: number | string | null;
    rate: number | string | null;
    hst: number | string;
    expected: number | string | null;
    amount_paid: number | string | null;
    payment_method: string | null;
    notes: string | null;
    source_note: string;
  }[];
  const summary = invoiceSummary(
    rows.map((row) => ({
      hours: row.hours === null ? null : Number(row.hours),
      expected: row.expected === null ? null : Number(row.expected),
      paid: row.amount_paid === null ? null : Number(row.amount_paid),
      hst: Number(row.hst),
    })),
  );
  const back = `/finances/people/${profileId}`;

  return (
    <FinanceFrame
      title={profile?.full_name || "Person"}
      current="people"
      notice={notice}
      lede="Date paid, invoice, period, hours, rate, HST, expected, paid, and the difference."
    >
      <p className="text-sm">
        Total expected {money(summary.expected)} · Paid {money(summary.paid)} ·
        Difference {money(summary.difference)} · Hours {summary.hours} · HST{" "}
        {money(summary.hst)}
      </p>
      <p className="text-sm text-muted">
        Average expected {money(summary.averageExpected)} · Average paid{" "}
        {money(summary.averagePaid)} · Average hours {summary.averageHours}
        {summary.underpaid > 0 ? ` · ${summary.underpaid} underpaid` : ""}
      </p>
      <div className="overflow-x-auto">
        <table className="w-full min-w-[64rem] text-left text-sm">
          <thead>
            <tr className="text-muted">
              <th className="py-2 pr-3 font-medium">Paid</th>
              <th className="py-2 pr-3 font-medium">Invoice</th>
              <th className="py-2 pr-3 font-medium">Period</th>
              <th className="py-2 pr-3 font-medium">Hours</th>
              <th className="py-2 pr-3 font-medium">Rate</th>
              <th className="py-2 pr-3 font-medium">HST</th>
              <th className="py-2 pr-3 font-medium">Expected</th>
              <th className="py-2 pr-3 font-medium">Paid amount</th>
              <th className="py-2 pr-3 font-medium">Difference</th>
              <th className="py-2 pr-3 font-medium">Method</th>
              <th className="py-2 font-medium">Source</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => {
              const expected =
                row.expected === null ? null : Number(row.expected);
              const paid =
                row.amount_paid === null ? null : Number(row.amount_paid);
              const under =
                expected !== null && paid !== null && paid < expected;
              return (
                <tr key={row.id} className="border-t border-line">
                  <td className="py-2 pr-3">{row.paid_on ?? "—"}</td>
                  <td className="py-2 pr-3">{row.invoice_number ?? "—"}</td>
                  <td className="py-2 pr-3">
                    {row.period_start ?? "—"} – {row.period_end ?? "—"}
                  </td>
                  <td className="py-2 pr-3">{row.hours ?? "—"}</td>
                  <td className="py-2 pr-3">
                    {row.rate === null ? "—" : money(Number(row.rate))}
                  </td>
                  <td className="py-2 pr-3">{money(Number(row.hst))}</td>
                  <td className="py-2 pr-3">
                    {expected === null ? "—" : money(expected)}
                  </td>
                  <td className="py-2 pr-3">
                    {paid === null ? "—" : money(paid)}
                  </td>
                  <td className="py-2 pr-3">
                    {expected === null || paid === null
                      ? "—"
                      : money(paid - expected)}
                    {under ? " · underpaid" : ""}
                  </td>
                  <td className="py-2 pr-3">{row.payment_method ?? "—"}</td>
                  <td className="py-2">
                    <SourceLine note={row.source_note} />
                    {row.notes ? <p>{row.notes}</p> : null}
                    <ArchiveForm
                      table="contractor_invoices"
                      id={row.id}
                      back={back}
                    />
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      <form action={saveInvoice} className="grid gap-2 sm:grid-cols-2">
        <input type="hidden" name="profileId" value={profileId} />
        <input
          name="paidOn"
          type="date"
          aria-label="Date paid"
          className={financeField}
        />
        <input
          name="invoiceNumber"
          placeholder="Invoice number"
          className={financeField}
        />
        <input
          name="periodStart"
          type="date"
          aria-label="Period start"
          className={financeField}
        />
        <input
          name="periodEnd"
          type="date"
          aria-label="Period end"
          className={financeField}
        />
        <input
          name="hours"
          inputMode="decimal"
          placeholder="Hours"
          className={financeField}
        />
        <input
          name="rate"
          inputMode="decimal"
          placeholder="Rate"
          className={financeField}
        />
        <input
          name="hst"
          inputMode="decimal"
          placeholder="HST"
          className={financeField}
        />
        <input
          name="expected"
          inputMode="decimal"
          placeholder="Expected"
          className={financeField}
        />
        <input
          name="amountPaid"
          inputMode="decimal"
          placeholder="Amount paid"
          className={financeField}
        />
        <input
          name="paymentMethod"
          placeholder="Method"
          className={financeField}
        />
        <input name="notes" placeholder="Notes" className={financeField} />
        <input
          name="sourceNote"
          placeholder="Source"
          className={financeField}
        />
        <button type="submit" className={financeButton}>
          Add line
        </button>
      </form>
    </FinanceFrame>
  );
}
