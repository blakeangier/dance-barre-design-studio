import { Suspense } from "react";
import {
  saveFinanceTodo,
  setFinanceTodoStatus,
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
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Finance to-dos" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function TodosPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Todos searchParams={props.searchParams} />
    </Suspense>
  );
}

async function Todos({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const params = await searchParams;
  const notice = firstQueryValue(params.notice);
  const status = firstQueryValue(params.status) ?? "open";
  const supabase = await createClient();
  let query = supabase
    .from("finance_todos")
    .select("id, item, amount, status, action, source_note")
    .is("archived_at", null)
    .order("id");
  if (status !== "all") query = query.eq("status", status);
  const result = await query;
  const rows = (result.data ?? []) as {
    id: number;
    item: string;
    amount: number | string | null;
    status: string;
    action: string | null;
    source_note: string;
  }[];

  return (
    <FinanceFrame
      title="To-dos and flags"
      current="todos"
      notice={notice}
      lede="Open questions about the numbers. Done items stay in the list until you archive them."
    >
      <form className="flex gap-2" method="get">
        <select name="status" defaultValue={status} className={financeField}>
          <option value="open">Open</option>
          <option value="waiting">Waiting</option>
          <option value="done">Done</option>
          <option value="all">All</option>
        </select>
        <button type="submit" className={financeButton}>
          Filter
        </button>
      </form>
      <div className="overflow-x-auto">
        <table className="w-full min-w-[40rem] text-left text-sm">
          <thead>
            <tr className="text-muted">
              <th className="py-2 pr-3 font-medium">Item</th>
              <th className="py-2 pr-3 font-medium">Amount</th>
              <th className="py-2 pr-3 font-medium">Status</th>
              <th className="py-2 pr-3 font-medium">Action</th>
              <th className="py-2 font-medium">Source</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.id} className="border-t border-line">
                <td className="py-2 pr-3">{row.item}</td>
                <td className="py-2 pr-3">
                  {row.amount === null ? "—" : money(Number(row.amount))}
                </td>
                <td className="py-2 pr-3">{row.status}</td>
                <td className="py-2 pr-3">{row.action ?? "—"}</td>
                <td className="py-2">
                  <SourceLine note={row.source_note} />
                  <form action={setFinanceTodoStatus} className="flex gap-2">
                    <input type="hidden" name="id" value={row.id} />
                    <input
                      type="hidden"
                      name="status"
                      value={row.status === "open" ? "done" : "open"}
                    />
                    <button
                      type="submit"
                      className="min-h-11 text-sm font-medium"
                    >
                      {row.status === "open" ? "Mark done" : "Reopen"}
                    </button>
                  </form>
                  <ArchiveForm
                    table="finance_todos"
                    id={row.id}
                    back="/finances/todos"
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <form action={saveFinanceTodo} className="grid gap-2 sm:grid-cols-2">
        <input
          name="item"
          required
          placeholder="Question"
          className={financeField}
        />
        <input
          name="amount"
          inputMode="decimal"
          placeholder="Amount, optional"
          className={financeField}
        />
        <select name="status" className={financeField}>
          <option value="open">Open</option>
          <option value="waiting">Waiting</option>
          <option value="done">Done</option>
        </select>
        <input name="action" placeholder="Action" className={financeField} />
        <input
          name="sourceNote"
          placeholder="Source"
          className={financeField}
        />
        <button type="submit" className={financeButton}>
          Add question
        </button>
      </form>
    </FinanceFrame>
  );
}
