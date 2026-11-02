import Link from "next/link";
import { Suspense } from "react";
import { toTaskSheetRows } from "@/app/(workspace)/tasks/sheet-query";
import { TaskSheet } from "@/components/tasks/task-sheet";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canOpenTaskBoard, canUpdateOrderStatus } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { todayInToronto } from "@/lib/inventory/usage";
import { progressCounts, TASK_PRIORITIES } from "@/lib/tasks/tasks";
import { OrderSelectOptions } from "@/components/orders/order-options";
import { orderChoiceLabel, toOrderChoice } from "@/lib/orders/label";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "All tasks" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function BoardPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Board searchParams={props.searchParams} />
    </Suspense>
  );
}

type TaskRow = {
  id: number;
  title: string;
  status: string;
  due_on: string | null;
  priority: string;
  assigned_to: string;
  created_by: string;
  order_id: number | null;
  waiting_reason: string | null;
};

async function Board({ searchParams }: PageProps) {
  const gate = await gateArea("tasks");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  if (!canOpenTaskBoard(gate.profile)) return <NoAccess reason="denied" />;
  const params = await searchParams;
  const person = firstQueryValue(params.person) ?? "";
  const order = firstQueryValue(params.order) ?? "";
  const program = firstQueryValue(params.program) ?? "";
  const priority = firstQueryValue(params.priority) ?? "";
  const overdueOnly = firstQueryValue(params.overdue) === "1";
  const today = todayInToronto();
  const supabase = await createClient();
  let query = supabase
    .from("tasks")
    .select(
      "id, title, status, due_on, priority, assigned_to, created_by, order_id, waiting_reason",
    );
  if (person) query = query.eq("assigned_to", person);
  if (/^\d+$/.test(order)) query = query.eq("order_id", Number(order));
  if (priority) query = query.eq("priority", priority);
  if (overdueOnly) {
    query = query.lt("due_on", today).not("status", "in", "(done,cancelled)");
  }
  const [tasksResult, peopleResult, ordersResult, programsResult] =
    await Promise.all([
      query,
      supabase
        .from("profiles")
        .select("id, full_name")
        .eq("is_active", true)
        .order("full_name"),
      supabase
        .from("costume_orders")
        .select(
          "id, order_number, production_song, program_id, programs(name)",
        ),
      supabase.from("programs").select("id, name").order("name"),
    ]);
  const people = (peopleResult.data ?? []) as {
    id: string;
    full_name: string;
  }[];
  const orders = (ordersResult.data ?? []) as {
    id: number;
    order_number: string;
    production_song: string | null;
    program_id: number | null;
    programs: { name: string } | { name: string }[] | null;
  }[];
  const choices = orders.map((row) => toOrderChoice(row));
  const programOrderIds = new Set(
    orders
      .filter((row) => program !== "" && String(row.program_id) === program)
      .map((row) => row.id),
  );
  const tasks = ((tasksResult.data ?? []) as TaskRow[]).filter((task) =>
    program === ""
      ? true
      : task.order_id !== null && programOrderIds.has(task.order_id),
  );
  const names = new Map(
    people.map((personRow) => [personRow.id, personRow.full_name]),
  );
  const orderNames = new Map(
    choices.map((row) => [Number(row.id), orderChoiceLabel(row)]),
  );
  const sheet = await toTaskSheetRows(tasks);
  const byPerson = progressCounts(
    tasks.map((task) => ({
      key: names.get(task.assigned_to) ?? "Unassigned",
      status: task.status,
    })),
  );
  const byOrder = progressCounts(
    tasks
      .filter((task) => task.order_id !== null)
      .map((task) => ({
        key: orderNames.get(task.order_id ?? 0) ?? "Order",
        status: task.status,
      })),
  );

  return (
    <div className="flex flex-col gap-4">
      <Link href="/tasks" className="text-sm text-muted">
        My tasks
      </Link>
      <h1 className="font-serif text-3xl text-ink">All tasks</h1>
      <p className="text-sm text-muted">
        Every task you can see, in one sheet. Done and cancelled stay hidden
        until you show them. My tasks stays the shorter list.
      </p>
      <form className="grid gap-2 sm:grid-cols-2" method="get">
        <select
          name="person"
          defaultValue={person}
          aria-label="Assignee"
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <option value="">Every assignee</option>
          {people.map((personRow) => (
            <option key={personRow.id} value={personRow.id}>
              {personRow.full_name}
            </option>
          ))}
        </select>
        <select
          name="program"
          defaultValue={program}
          aria-label="Program"
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <option value="">Every program</option>
          {((programsResult.data ?? []) as { id: number; name: string }[]).map(
            (item) => (
              <option key={item.id} value={item.id}>
                {item.name}
              </option>
            ),
          )}
        </select>
        <select
          name="order"
          defaultValue={order}
          aria-label="Order"
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <OrderSelectOptions blank="Every order" orders={choices} />
        </select>
        <select
          name="priority"
          defaultValue={priority}
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <option value="">Every priority</option>
          {TASK_PRIORITIES.map((item) => (
            <option key={item.value} value={item.value}>
              {item.label}
            </option>
          ))}
        </select>
        <label className="flex min-h-12 items-center gap-2 text-sm">
          <input
            type="checkbox"
            name="overdue"
            value="1"
            defaultChecked={overdueOnly}
          />
          Overdue only
        </label>
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white"
        >
          Filter
        </button>
      </form>
      <section className="flex flex-col gap-1 text-sm">
        <h2 className="font-medium text-ink">By person</h2>
        {[...byPerson.entries()].map(([name, count]) => (
          <p key={name}>
            {name}: {count.done} done · {count.open} open
          </p>
        ))}
        <h2 className="mt-2 font-medium text-ink">By order</h2>
        {[...byOrder.entries()].map(([name, count]) => (
          <p key={name}>
            {name}: {count.done} done · {count.open} open
          </p>
        ))}
      </section>
      <TaskSheet
        rows={sheet}
        viewerId={gate.profile.id}
        today={today}
        supervisor={canUpdateOrderStatus(gate.profile)}
      />
    </div>
  );
}
