import Link from "next/link";
import { Suspense } from "react";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canOpenTaskBoard } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { todayInToronto } from "@/lib/inventory/usage";
import {
  groupByStatus,
  isOverdue,
  progressCounts,
  TASK_PRIORITIES,
  TASK_STATUSES,
  taskPriorityLabel,
} from "@/lib/tasks/tasks";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Task board" };

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
  order_id: number | null;
};

async function Board({ searchParams }: PageProps) {
  const gate = await gateArea("tasks");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  if (!canOpenTaskBoard(gate.profile)) return <NoAccess reason="denied" />;
  const params = await searchParams;
  const person = firstQueryValue(params.person) ?? "";
  const order = firstQueryValue(params.order) ?? "";
  const priority = firstQueryValue(params.priority) ?? "";
  const overdueOnly = firstQueryValue(params.overdue) === "1";
  const today = todayInToronto();
  const supabase = await createClient();
  let query = supabase
    .from("tasks")
    .select("id, title, status, due_on, priority, assigned_to, order_id");
  if (person) query = query.eq("assigned_to", person);
  if (/^\d+$/.test(order)) query = query.eq("order_id", Number(order));
  if (priority) query = query.eq("priority", priority);
  if (overdueOnly) {
    query = query.lt("due_on", today).not("status", "in", "(done,cancelled)");
  }
  const [tasksResult, peopleResult, ordersResult] = await Promise.all([
    query,
    supabase
      .from("profiles")
      .select("id, full_name")
      .eq("is_active", true)
      .neq("role", "program_director")
      .order("full_name"),
    supabase
      .from("costume_orders")
      .select("id, order_number")
      .order("order_number"),
  ]);
  const tasks = (tasksResult.data ?? []) as TaskRow[];
  const people = (peopleResult.data ?? []) as {
    id: string;
    full_name: string;
  }[];
  const orders = (ordersResult.data ?? []) as {
    id: number;
    order_number: string;
  }[];
  const names = new Map(
    people.map((personRow) => [personRow.id, personRow.full_name]),
  );
  const orderNames = new Map(orders.map((row) => [row.id, row.order_number]));
  const groups = groupByStatus(
    tasks.map((task) => ({ ...task, dueOn: task.due_on })),
  );
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
      <h1 className="font-serif text-3xl text-ink">Team board</h1>
      <form className="grid gap-2 sm:grid-cols-2" method="get">
        <select
          name="person"
          defaultValue={person}
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <option value="">Everyone</option>
          {people.map((personRow) => (
            <option key={personRow.id} value={personRow.id}>
              {personRow.full_name}
            </option>
          ))}
        </select>
        <select
          name="order"
          defaultValue={order}
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <option value="">Every order</option>
          {orders.map((row) => (
            <option key={row.id} value={row.id}>
              {row.order_number}
            </option>
          ))}
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
      <div className="grid gap-3 md:grid-cols-5">
        {TASK_STATUSES.map((status) => (
          <section key={status.value} className="flex flex-col gap-2">
            <h2 className="font-serif text-xl text-ink">{status.label}</h2>
            {groups[status.value].map((task) => (
              <Link
                key={task.id}
                href={`/tasks/${task.id}`}
                className="rounded-2xl border border-line bg-card p-3 text-sm"
              >
                <p className="font-medium text-ink">{task.title}</p>
                <p className="text-muted">
                  {names.get(task.assigned_to) ?? "Unassigned"} ·{" "}
                  {taskPriorityLabel(task.priority)}
                  {task.due_on ? ` · ${task.due_on}` : ""}
                  {isOverdue(task.due_on, task.status, today)
                    ? " · Overdue"
                    : ""}
                </p>
              </Link>
            ))}
          </section>
        ))}
      </div>
    </div>
  );
}
