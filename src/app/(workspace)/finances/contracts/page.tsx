import { Suspense } from "react";
import {
  saveContract,
  saveContractPayment,
  saveContractPhase,
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
import { todayInToronto } from "@/lib/inventory/usage";
import { contractStanding } from "@/lib/finances/workbook";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Contracts" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function ContractsPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Contracts searchParams={props.searchParams} />
    </Suspense>
  );
}

function personName(
  value: { full_name: string } | { full_name: string }[] | null,
): string {
  if (!value) return "Person";
  return Array.isArray(value)
    ? (value[0]?.full_name ?? "Person")
    : value.full_name;
}

async function Contracts({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const notice = firstQueryValue((await searchParams).notice);
  const today = todayInToronto();
  const supabase = await createClient();
  const [contractResult, phaseResult, paymentResult, profileResult] =
    await Promise.all([
      supabase
        .from("contractor_contracts")
        .select(
          "id, contractor_id, total_amount_cad, hst_amount_cad, start_date, end_date, source_note, profiles(full_name)",
        )
        .is("archived_at", null)
        .order("end_date"),
      supabase
        .from("contractor_contract_phases")
        .select(
          "id, contract_id, label, amount_before_hst, hst, notes, source_note",
        )
        .is("archived_at", null)
        .order("sort_order"),
      supabase
        .from("contractor_payments")
        .select(
          "id, contract_id, paid_on, amount_cad, hst_cad, payment_method, description, source_note",
        )
        .is("archived_at", null)
        .order("paid_on", { ascending: false, nullsFirst: true }),
      supabase.from("profiles").select("id, full_name").order("full_name"),
    ]);
  const contracts = (contractResult.data ?? []) as {
    id: number;
    total_amount_cad: number | string;
    hst_amount_cad: number | string;
    start_date: string;
    end_date: string;
    source_note: string;
    profiles: { full_name: string } | { full_name: string }[] | null;
  }[];
  const phases = (phaseResult.data ?? []) as {
    id: number;
    contract_id: number;
    label: string;
    amount_before_hst: number | string;
    hst: number | string;
    notes: string | null;
    source_note: string;
  }[];
  const payments = (paymentResult.data ?? []) as {
    id: number;
    contract_id: number;
    paid_on: string | null;
    amount_cad: number | string;
    hst_cad: number | string;
    payment_method: string | null;
    description: string | null;
    source_note: string;
  }[];
  const profiles = (profileResult.data ?? []) as {
    id: string;
    full_name: string;
  }[];

  return (
    <FinanceFrame
      title="Contracts"
      current="contracts"
      notice={notice}
      lede="Phases such as setup and extension, then payments, then where the contract stands."
    >
      {contracts.map((contract) => {
        const contractPhases = phases.filter(
          (phase) => phase.contract_id === contract.id,
        );
        const contractPayments = payments.filter(
          (payment) => payment.contract_id === contract.id,
        );
        const standing = contractStanding({
          phases: contractPhases.map((phase) => ({
            beforeHst: Number(phase.amount_before_hst),
            hst: Number(phase.hst),
          })),
          fallbackBeforeHst: Number(contract.total_amount_cad),
          fallbackHst: Number(contract.hst_amount_cad),
          payments: contractPayments.map((payment) => ({
            amount: Number(payment.amount_cad),
            hst: Number(payment.hst_cad),
            paidOn: payment.paid_on,
          })),
          end: contract.end_date,
          today,
        });
        return (
          <article
            key={contract.id}
            className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
          >
            <h2 className="font-serif text-2xl text-ink">
              {personName(contract.profiles)}
            </h2>
            <p className="text-sm text-muted">
              {contract.start_date} – {contract.end_date}
            </p>
            <SourceLine note={contract.source_note} />
            <div className="overflow-x-auto">
              <table className="w-full min-w-[36rem] text-left text-sm">
                <thead>
                  <tr className="text-muted">
                    <th className="py-2 pr-3 font-medium">Phase</th>
                    <th className="py-2 pr-3 font-medium">Before HST</th>
                    <th className="py-2 pr-3 font-medium">HST</th>
                    <th className="py-2 pr-3 font-medium">Incl. HST</th>
                    <th className="py-2 font-medium">Source</th>
                  </tr>
                </thead>
                <tbody>
                  {contractPhases.map((phase) => (
                    <tr key={phase.id} className="border-t border-line">
                      <td className="py-2 pr-3">
                        {phase.label}
                        {phase.notes ? (
                          <span className="block text-muted">
                            {phase.notes}
                          </span>
                        ) : null}
                      </td>
                      <td className="py-2 pr-3">
                        {money(Number(phase.amount_before_hst))}
                      </td>
                      <td className="py-2 pr-3">{money(Number(phase.hst))}</td>
                      <td className="py-2 pr-3">
                        {money(
                          Number(phase.amount_before_hst) + Number(phase.hst),
                        )}
                      </td>
                      <td className="py-2">
                        <SourceLine note={phase.source_note} />
                        <ArchiveForm
                          table="contractor_contract_phases"
                          id={phase.id}
                          back="/finances/contracts"
                        />
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <form
              action={saveContractPhase}
              className="grid gap-2 sm:grid-cols-2"
            >
              <input type="hidden" name="contractId" value={contract.id} />
              <input
                name="label"
                required
                placeholder="Phase, such as setup"
                className={financeField}
              />
              <input
                name="beforeHst"
                required
                inputMode="decimal"
                placeholder="Before HST"
                className={financeField}
              />
              <input
                name="hst"
                inputMode="decimal"
                placeholder="HST"
                className={financeField}
              />
              <input
                name="notes"
                placeholder="Notes"
                className={financeField}
              />
              <input
                name="sourceNote"
                placeholder="Source"
                className={financeField}
              />
              <button type="submit" className={financeButton}>
                Add phase
              </button>
            </form>
            <h3 className="font-medium text-ink">Payments</h3>
            <div className="overflow-x-auto">
              <table className="w-full min-w-[36rem] text-left text-sm">
                <thead>
                  <tr className="text-muted">
                    <th className="py-2 pr-3 font-medium">Date</th>
                    <th className="py-2 pr-3 font-medium">Amount</th>
                    <th className="py-2 pr-3 font-medium">Method</th>
                    <th className="py-2 pr-3 font-medium">Description</th>
                    <th className="py-2 font-medium">Source</th>
                  </tr>
                </thead>
                <tbody>
                  {contractPayments.map((payment) => (
                    <tr key={payment.id} className="border-t border-line">
                      <td className="py-2 pr-3">
                        {payment.paid_on ?? "Date unknown"}
                      </td>
                      <td className="py-2 pr-3">
                        {money(Number(payment.amount_cad))}
                        {Number(payment.hst_cad)
                          ? ` · HST ${money(Number(payment.hst_cad))}`
                          : ""}
                      </td>
                      <td className="py-2 pr-3">
                        {payment.payment_method ?? "—"}
                      </td>
                      <td className="py-2 pr-3">
                        {payment.description ?? "—"}
                      </td>
                      <td className="py-2">
                        <SourceLine note={payment.source_note} />
                        <ArchiveForm
                          table="contractor_payments"
                          id={payment.id}
                          back="/finances/contracts"
                        />
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <form
              action={saveContractPayment}
              className="grid gap-2 sm:grid-cols-2"
            >
              <input type="hidden" name="contractId" value={contract.id} />
              <input
                name="paidOn"
                type="date"
                aria-label="Payment date"
                className={financeField}
              />
              <input
                name="amount"
                required
                inputMode="decimal"
                placeholder="Amount"
                className={financeField}
              />
              <input
                name="hst"
                inputMode="decimal"
                placeholder="HST"
                className={financeField}
              />
              <input
                name="paymentMethod"
                placeholder="Method"
                className={financeField}
              />
              <input
                name="description"
                placeholder="Description"
                className={financeField}
              />
              <input
                name="sourceNote"
                placeholder="Source"
                className={financeField}
              />
              <button type="submit" className={financeButton}>
                Add payment
              </button>
            </form>
            <h3 className="font-medium text-ink">Where it stands</h3>
            <p className="text-sm">
              Remaining {money(standing.remaining)} · Payments left{" "}
              {standing.paymentsLeft} · Months left {standing.monthsLeft} ·
              Average needed per month {money(standing.averagePerMonth)}
            </p>
            <ArchiveForm
              table="contractor_contracts"
              id={contract.id}
              back="/finances/contracts"
            />
          </article>
        );
      })}
      <form action={saveContract} className="grid gap-2 sm:grid-cols-2">
        <h2 className="font-serif text-2xl text-ink sm:col-span-2">
          Add a contract
        </h2>
        <select name="contractorId" required className={financeField}>
          {profiles.map((profile) => (
            <option key={profile.id} value={profile.id}>
              {profile.full_name || profile.id}
            </option>
          ))}
        </select>
        <input
          name="total"
          required
          inputMode="decimal"
          placeholder="Before HST, if there are no phases yet"
          className={financeField}
        />
        <input
          name="hst"
          inputMode="decimal"
          placeholder="HST"
          className={financeField}
        />
        <input
          name="startDate"
          required
          type="date"
          aria-label="Start date"
          className={financeField}
        />
        <input
          name="endDate"
          required
          type="date"
          aria-label="End date"
          className={financeField}
        />
        <input name="notes" placeholder="Notes" className={financeField} />
        <input
          name="sourceNote"
          placeholder="Source"
          className={financeField}
        />
        <button type="submit" className={financeButton}>
          Save contract
        </button>
      </form>
    </FinanceFrame>
  );
}
