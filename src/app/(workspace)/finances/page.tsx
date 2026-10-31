import Link from "next/link";
import { Suspense } from "react";
import {
  saveCommittedItem,
  saveFundingLine,
  saveSpendLine,
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
import {
  PAID_FROM,
  SPEND_SECTIONS,
  fundingCheck,
  labelOf,
  localFinanceHref,
  spendToDate,
  type SpendSection,
} from "@/lib/finances/workbook";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Spend to date" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function FinancesPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Spend searchParams={props.searchParams} />
    </Suspense>
  );
}

async function Spend({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const notice = firstQueryValue((await searchParams).notice);
  const supabase = await createClient();
  const [spentResult, committedResult, fundingResult] = await Promise.all([
    supabase
      .from("finance_spend_lines")
      .select(
        "id, section, label, amount, detail_href, sort_order, source_note",
      )
      .is("archived_at", null)
      .order("sort_order"),
    supabase
      .from("finance_committed_items")
      .select(
        "id, label, amount, detail_href, counts_as_startup, sort_order, source_note",
      )
      .is("archived_at", null)
      .order("sort_order"),
    supabase
      .from("finance_funding_lines")
      .select("id, paid_from, label, amount, sort_order, source_note")
      .is("archived_at", null)
      .order("sort_order"),
  ]);
  const spentRows = (
    (spentResult.data ?? []) as {
      id: number;
      section: SpendSection;
      label: string;
      amount: number | string;
      detail_href: string | null;
      source_note: string;
    }[]
  ).map((row) => ({
    id: row.id,
    section: row.section,
    label: row.label,
    amount: Number(row.amount),
    href: row.detail_href,
    sourceNote: row.source_note,
  }));
  const spent = spendToDate(spentRows);
  const committed = (committedResult.data ?? []) as {
    id: number;
    label: string;
    amount: number | string;
    detail_href: string | null;
    counts_as_startup: boolean;
    source_note: string;
  }[];
  const committedTotal = committed.reduce(
    (sum, row) => sum + Number(row.amount),
    0,
  );
  const fundingRows = (
    (fundingResult.data ?? []) as {
      id: number;
      paid_from: string;
      label: string;
      amount: number | string;
      source_note: string;
    }[]
  ).map((row) => ({
    id: row.id,
    paidFrom: row.paid_from,
    label: row.label,
    amount: Number(row.amount),
    sourceNote: row.source_note,
  }));
  const funding = fundingCheck(spent.total, fundingRows);

  return (
    <FinanceFrame
      title="Spend to date"
      current="spend"
      notice={notice}
      lede="Amounts are the workbook lines. Each line keeps a source so you can see where the number came from."
    >
      <section className="flex flex-col gap-3">
        <h2 className="font-serif text-2xl text-ink">Where the money went</h2>
        {spent.sections.map((section) => (
          <div key={section.section} className="overflow-x-auto">
            <h3 className="font-medium text-ink">{section.title}</h3>
            <table className="w-full min-w-[40rem] text-left text-sm">
              <thead>
                <tr className="text-muted">
                  <th className="py-2 pr-3 font-medium">Label</th>
                  <th className="py-2 pr-3 font-medium">Amount</th>
                  <th className="py-2 pr-3 font-medium">% of total</th>
                  <th className="py-2 pr-3 font-medium">Detail</th>
                  <th className="py-2 font-medium">Source</th>
                </tr>
              </thead>
              <tbody>
                {section.rows.map((row, index) => {
                  const href = localFinanceHref(row.href);
                  const stored = spentRows.filter(
                    (item) => item.section === section.section,
                  )[index];
                  return (
                    <tr
                      key={stored?.id ?? index}
                      className="border-t border-line"
                    >
                      <td className="py-2 pr-3">{row.label}</td>
                      <td className="py-2 pr-3">{money(row.amount)}</td>
                      <td className="py-2 pr-3">{row.percent}%</td>
                      <td className="py-2 pr-3">
                        {href ? (
                          <Link href={href} className="font-medium text-ink">
                            Open
                          </Link>
                        ) : (
                          "—"
                        )}
                      </td>
                      <td className="py-2">
                        <SourceLine note={row.sourceNote} />
                        {stored ? (
                          <ArchiveForm
                            table="finance_spend_lines"
                            id={stored.id}
                            back="/finances"
                          />
                        ) : null}
                      </td>
                    </tr>
                  );
                })}
                <tr className="border-t border-line font-medium">
                  <td className="py-2 pr-3">Subtotal</td>
                  <td className="py-2 pr-3">{money(section.subtotal)}</td>
                  <td colSpan={3} />
                </tr>
              </tbody>
            </table>
          </div>
        ))}
        <p className="font-serif text-3xl text-ink">
          Grand total {money(spent.total)}
        </p>
        <form action={saveSpendLine} className="grid gap-2 sm:grid-cols-2">
          <select name="section" className={financeField}>
            {SPEND_SECTIONS.map(([value, label]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </select>
          <input
            name="label"
            required
            placeholder="Label"
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
            name="detailHref"
            placeholder="/finances/startup"
            className={financeField}
          />
          <input
            name="sourceNote"
            placeholder="Source"
            className={financeField}
          />
          <button type="submit" className={financeButton}>
            Add spent line
          </button>
        </form>
      </section>
      <section className="flex flex-col gap-3">
        <h2 className="font-serif text-2xl text-ink">
          Committed but not yet paid
        </h2>
        <div className="overflow-x-auto">
          <table className="w-full min-w-[40rem] text-left text-sm">
            <thead>
              <tr className="text-muted">
                <th className="py-2 pr-3 font-medium">Label</th>
                <th className="py-2 pr-3 font-medium">Amount</th>
                <th className="py-2 pr-3 font-medium">Detail</th>
                <th className="py-2 font-medium">Source</th>
              </tr>
            </thead>
            <tbody>
              {committed.map((row) => {
                const href = localFinanceHref(row.detail_href);
                return (
                  <tr key={row.id} className="border-t border-line">
                    <td className="py-2 pr-3">
                      {row.label}
                      {row.counts_as_startup ? " · startup" : ""}
                    </td>
                    <td className="py-2 pr-3">{money(Number(row.amount))}</td>
                    <td className="py-2 pr-3">
                      {href ? (
                        <Link href={href} className="font-medium text-ink">
                          Open
                        </Link>
                      ) : (
                        "—"
                      )}
                    </td>
                    <td className="py-2">
                      <SourceLine note={row.source_note} />
                      <ArchiveForm
                        table="finance_committed_items"
                        id={row.id}
                        back="/finances"
                      />
                    </td>
                  </tr>
                );
              })}
              <tr className="border-t border-line font-medium">
                <td className="py-2 pr-3">Total committed</td>
                <td className="py-2">{money(committedTotal)}</td>
                <td colSpan={2} />
              </tr>
            </tbody>
          </table>
        </div>
        <form action={saveCommittedItem} className="grid gap-2 sm:grid-cols-2">
          <input
            name="label"
            required
            placeholder="Label"
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
            name="detailHref"
            placeholder="/finances/contracts"
            className={financeField}
          />
          <input
            name="sourceNote"
            placeholder="Source"
            className={financeField}
          />
          <label className="flex min-h-11 items-center gap-2 text-sm">
            <input type="checkbox" name="countsAsStartup" />
            Counts toward startup still owed
          </label>
          <button type="submit" className={financeButton}>
            Add committed line
          </button>
        </form>
      </section>
      <section className="flex flex-col gap-3">
        <h2 className="font-serif text-2xl text-ink">
          Where the money came from
        </h2>
        <div className="overflow-x-auto">
          <table className="w-full min-w-[40rem] text-left text-sm">
            <thead>
              <tr className="text-muted">
                <th className="py-2 pr-3 font-medium">Paid from</th>
                <th className="py-2 pr-3 font-medium">Amount</th>
                <th className="py-2 pr-3 font-medium">%</th>
                <th className="py-2 font-medium">Source</th>
              </tr>
            </thead>
            <tbody>
              {funding.rows.map((row, index) => {
                const stored = fundingRows[index];
                return (
                  <tr
                    key={stored?.id ?? index}
                    className="border-t border-line"
                  >
                    <td className="py-2 pr-3">
                      {labelOf(PAID_FROM, row.paidFrom)} · {row.label}
                    </td>
                    <td className="py-2 pr-3">{money(row.amount)}</td>
                    <td className="py-2 pr-3">{row.percent}%</td>
                    <td className="py-2">
                      <SourceLine note={row.sourceNote} />
                      {stored ? (
                        <ArchiveForm
                          table="finance_funding_lines"
                          id={stored.id}
                          back="/finances"
                        />
                      ) : null}
                    </td>
                  </tr>
                );
              })}
              <tr className="border-t border-line font-medium">
                <td className="py-2 pr-3">
                  Check · must equal {money(spent.total)} spent
                </td>
                <td className="py-2 pr-3">{money(funding.total)}</td>
                <td colSpan={2} className="py-2">
                  {funding.balances
                    ? "Balances"
                    : `Off by ${money(funding.difference)}`}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <form action={saveFundingLine} className="grid gap-2 sm:grid-cols-2">
          <select name="paidFrom" className={financeField}>
            {PAID_FROM.map(([value, label]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </select>
          <input
            name="label"
            required
            placeholder="Card ending or description"
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
            name="sourceNote"
            placeholder="Source"
            className={financeField}
          />
          <button type="submit" className={financeButton}>
            Add funding line
          </button>
        </form>
      </section>
    </FinanceFrame>
  );
}
