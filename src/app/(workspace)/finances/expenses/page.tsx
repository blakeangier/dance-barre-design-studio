import { Suspense } from "react";
import { saveExpense } from "@/app/(workspace)/finances/workbook-actions";
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
import { cents } from "@/lib/finances/money";
import {
  EXPENSE_CATEGORIES,
  PAID_FROM,
  labelOf,
} from "@/lib/finances/workbook";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Expense log" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type Expense = {
  id: number;
  occurred_on: string | null;
  amount: number | string;
  payment_as_entered: string | null;
  paid_from: string;
  vendor: string | null;
  description: string;
  category: string;
  flag_notes: string | null;
  source_note: string;
  card_transaction_id: number | null;
};

export default function ExpensesPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Expenses searchParams={props.searchParams} />
    </Suspense>
  );
}

async function Expenses({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const params = await searchParams;
  const notice = firstQueryValue(params.notice);
  const category = firstQueryValue(params.category) ?? "";
  const vendor = firstQueryValue(params.vendor) ?? "";
  const supabase = await createClient();
  const result = await supabase
    .from("expense_log")
    .select(
      "id, occurred_on, amount, payment_as_entered, paid_from, vendor, description, category, flag_notes, source_note, card_transaction_id",
    )
    .is("archived_at", null)
    .order("occurred_on", { ascending: false, nullsFirst: true });
  const rows = ((result.data ?? []) as Expense[]).filter((row) => {
    if (category && row.category !== category) return false;
    if (
      vendor &&
      !(row.vendor ?? "").toLowerCase().includes(vendor.toLowerCase())
    ) {
      return false;
    }
    return true;
  });
  const byCategory = new Map<string, number>();
  for (const row of rows) {
    byCategory.set(
      row.category,
      (byCategory.get(row.category) ?? 0) + Number(row.amount),
    );
  }

  return (
    <FinanceFrame
      title="Expense log"
      current="expenses"
      notice={notice}
      lede="A linked card charge is already in this log. Do not add that Visa line a second time."
    >
      <ul className="text-sm">
        {[...byCategory.entries()].map(([key, amount]) => (
          <li key={key}>
            {labelOf(EXPENSE_CATEGORIES, key)} · {money(cents(amount))}
          </li>
        ))}
      </ul>
      <form className="grid gap-2 sm:grid-cols-2" method="get">
        <select
          name="category"
          defaultValue={category}
          className={financeField}
        >
          <option value="">Every category</option>
          {EXPENSE_CATEGORIES.map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </select>
        <input
          name="vendor"
          defaultValue={vendor}
          placeholder="Vendor"
          className={financeField}
        />
        <button type="submit" className={financeButton}>
          Filter
        </button>
      </form>
      <div className="overflow-x-auto">
        <table className="w-full min-w-[64rem] text-left text-sm">
          <thead>
            <tr className="text-muted">
              <th className="py-2 pr-3 font-medium">Date</th>
              <th className="py-2 pr-3 font-medium">Amount</th>
              <th className="py-2 pr-3 font-medium">Payment as entered</th>
              <th className="py-2 pr-3 font-medium">Paid from</th>
              <th className="py-2 pr-3 font-medium">Vendor</th>
              <th className="py-2 pr-3 font-medium">Description</th>
              <th className="py-2 pr-3 font-medium">Category</th>
              <th className="py-2 pr-3 font-medium">Flag</th>
              <th className="py-2 font-medium">Source</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.id} className="border-t border-line">
                <td className="py-2 pr-3">{row.occurred_on ?? "—"}</td>
                <td className="py-2 pr-3">{money(Number(row.amount))}</td>
                <td className="py-2 pr-3">{row.payment_as_entered ?? "—"}</td>
                <td className="py-2 pr-3">
                  {labelOf(PAID_FROM, row.paid_from)}
                </td>
                <td className="py-2 pr-3">{row.vendor ?? "—"}</td>
                <td className="py-2 pr-3">{row.description}</td>
                <td className="py-2 pr-3">
                  {labelOf(EXPENSE_CATEGORIES, row.category)}
                </td>
                <td className="py-2 pr-3">{row.flag_notes ?? "—"}</td>
                <td className="py-2">
                  <SourceLine note={row.source_note} />
                  {row.card_transaction_id ? (
                    <p>
                      Linked card charge {row.card_transaction_id}. Already in
                      this log.
                    </p>
                  ) : null}
                  <ArchiveForm
                    table="expense_log"
                    id={row.id}
                    back="/finances/expenses"
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <form action={saveExpense} className="grid gap-2 sm:grid-cols-2">
        <input
          name="occurredOn"
          type="date"
          aria-label="Date"
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
          name="paymentAsEntered"
          placeholder="Payment as entered"
          className={financeField}
        />
        <select name="paidFrom" className={financeField}>
          {PAID_FROM.map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </select>
        <input name="vendor" placeholder="Vendor" className={financeField} />
        <input
          name="description"
          required
          placeholder="Description"
          className={financeField}
        />
        <select name="category" className={financeField}>
          {EXPENSE_CATEGORIES.map(([value, label]) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </select>
        <input
          name="flagNotes"
          placeholder="Flag or notes"
          className={financeField}
        />
        <input
          name="cardTransactionId"
          inputMode="numeric"
          placeholder="Card transaction id, optional"
          className={financeField}
        />
        <input
          name="sourceNote"
          placeholder="Source"
          className={financeField}
        />
        <button type="submit" className={financeButton}>
          Add expense
        </button>
      </form>
    </FinanceFrame>
  );
}
