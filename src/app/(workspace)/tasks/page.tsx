import Link from "next/link";
import { Suspense } from "react";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { gateArea } from "@/lib/auth/session";
import { canOpenTaskBoard } from "@/lib/auth/permissions";
import { todayInToronto } from "@/lib/inventory/usage";
import {
  groupByStatus,
  isOverdue,
  TASK_STATUSES,
  taskPriorityLabel,
  taskStatusLabel,
} from "@/lib/tasks/tasks";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "My tasks" };

export default function TasksPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <MyTasks />
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
};

async function MyTasks() {
  const gate = await gateArea("tasks");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const supabase = await createClient();
  const { data } = await supabase
    .from("tasks")
    .select("id, title, status, due_on, priority, assigned_to, created_by")
    .or(`assigned_to.eq.${gate.profile.id},created_by.eq.${gate.profile.id}`);
  const rows = (data ?? []) as TaskRow[];
  const mine = rows.filter((task) => task.assigned_to === gate.profile.id);
  const asked = rows.filter(
    (task) =>
      task.created_by === gate.profile.id &&
      task.assigned_to !== gate.profile.id,
  );
  const groups = groupByStatus(
    mine.map((task) => ({ ...task, dueOn: task.due_on })),
  );
  const today = todayInToronto();

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <div className="flex items-center justify-between gap-3">
        <h1 className="font-serif text-3xl text-ink">My tasks</h1>
        {gate.profile.role === "program_director" ? null : (
          <Link
            href="/tasks/new"
            className="inline-flex min-h-12 items-center rounded-full bg-ink px-4 text-sm font-medium text-white"
          >
            New task
          </Link>
        )}
      </div>
      <p className="text-sm text-muted">
        My tasks is your list: work assigned to you, and tasks you asked of
        someone else.
      </p>
      {canOpenTaskBoard(gate.profile) ? (
        <Link href="/tasks/board" className="text-sm font-medium text-ink">
          All tasks
        </Link>
      ) : null}
      {TASK_STATUSES.map((status) => (
        <section key={status.value} className="flex flex-col gap-2">
          <h2 className="font-serif text-2xl text-ink">{status.label}</h2>
          {groups[status.value].length === 0 ? (
            <p className="text-sm text-muted">None</p>
          ) : (
            groups[status.value].map((task) => (
              <TaskLink key={task.id} task={task} today={today} />
            ))
          )}
        </section>
      ))}
      {asked.length > 0 ? (
        <section className="flex flex-col gap-2">
          <h2 className="font-serif text-2xl text-ink">
            Asked of someone else
          </h2>
          {asked.map((task) => (
            <TaskLink key={task.id} task={task} today={today} />
          ))}
        </section>
      ) : null}
    </div>
  );
}

function TaskLink({ task, today }: { task: TaskRow; today: string }) {
  const late = isOverdue(task.due_on, task.status, today);
  return (
    <Link
      href={`/tasks/${task.id}`}
      className="rounded-2xl border border-line bg-card p-4"
    >
      <p className="font-medium text-ink">{task.title}</p>
      <p className="text-sm text-muted">
        {taskStatusLabel(task.status)} · {taskPriorityLabel(task.priority)} ·
        Due {task.due_on ?? "not set"}
        {late ? " · Overdue" : ""}
      </p>
    </Link>
  );
}
