import Link from "next/link";
import { Suspense } from "react";
import { toTaskSheetRows } from "@/app/(workspace)/tasks/sheet-query";
import { TaskSheet } from "@/components/tasks/task-sheet";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canOpenTaskBoard, canUpdateOrderStatus } from "@/lib/auth/permissions";
import { gateArea } from "@/lib/auth/session";
import { todayInToronto } from "@/lib/inventory/usage";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "My tasks" };

export default function TasksPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <MyTasks />
    </Suspense>
  );
}

async function MyTasks() {
  const gate = await gateArea("tasks");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const supabase = await createClient();
  const { data } = await supabase
    .from("tasks")
    .select(
      "id, title, status, due_on, priority, assigned_to, created_by, order_id, waiting_reason",
    )
    .or(`assigned_to.eq.${gate.profile.id},created_by.eq.${gate.profile.id}`);
  const rows = await toTaskSheetRows(data ?? []);
  const today = todayInToronto();

  return (
    <div className="flex w-full flex-col gap-4">
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
        One row per task. Mine is work assigned to you. Asked of someone else is
        work you gave to another person. Done and cancelled stay hidden until
        you show them.
      </p>
      {canOpenTaskBoard(gate.profile) ? (
        <Link href="/tasks/board" className="text-sm font-medium text-ink">
          All tasks
        </Link>
      ) : null}
      <TaskSheet
        rows={rows}
        viewerId={gate.profile.id}
        today={today}
        supervisor={canUpdateOrderStatus(gate.profile)}
        showScope
      />
    </div>
  );
}
