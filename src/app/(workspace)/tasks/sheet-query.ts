import "server-only";

import { orderChoiceLabel, toOrderChoice } from "@/lib/orders/label";
import { formatShiftDays, type TaskSheetRow } from "@/lib/tasks/tasks";
import { createClient } from "@/lib/supabase/server";

type TaskSource = {
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

type ShiftEmbed = {
  shift_date: string;
  archived_at: string | null;
} | null;

export async function toTaskSheetRows(
  tasks: readonly TaskSource[],
): Promise<TaskSheetRow[]> {
  const supabase = await createClient();
  const [peopleResult, ordersResult, linksResult] = await Promise.all([
    supabase.from("profiles").select("id, full_name"),
    supabase
      .from("costume_orders")
      .select("id, order_number, production_song, programs(name)"),
    supabase
      .from("shift_tasks")
      .select("task_id, staff_shifts(shift_date, archived_at)"),
  ]);
  const names = new Map(
    ((peopleResult.data ?? []) as { id: string; full_name: string }[]).map(
      (person) => [person.id, person.full_name || "Unknown"],
    ),
  );
  const orders = new Map(
    (
      (ordersResult.data ?? []) as {
        id: number;
        order_number: string;
        production_song: string | null;
        programs: { name: string } | { name: string }[] | null;
      }[]
    ).map((row) => [row.id, orderChoiceLabel(toOrderChoice(row))]),
  );
  const shifts = new Map<number, string[]>();
  for (const link of (linksResult.data ?? []) as {
    task_id: number;
    staff_shifts: ShiftEmbed | ShiftEmbed[];
  }[]) {
    const embedded = Array.isArray(link.staff_shifts)
      ? link.staff_shifts
      : link.staff_shifts
        ? [link.staff_shifts]
        : [];
    for (const shift of embedded) {
      if (!shift || shift.archived_at) continue;
      const dates = shifts.get(link.task_id) ?? [];
      dates.push(shift.shift_date);
      shifts.set(link.task_id, dates);
    }
  }
  return tasks.map((task) => ({
    id: task.id,
    title: task.title,
    orderLabel: task.order_id ? (orders.get(task.order_id) ?? null) : null,
    assignedTo: task.assigned_to,
    assignedName: names.get(task.assigned_to) ?? "Unknown",
    askedBy: task.created_by,
    askedName: names.get(task.created_by) ?? "Unknown",
    status: task.status,
    priority: task.priority,
    dueOn: task.due_on,
    shiftDays: formatShiftDays(shifts.get(task.id) ?? []),
    waitingReason: task.waiting_reason,
  }));
}
