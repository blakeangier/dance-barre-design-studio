export const TASK_STATUSES = [
  { value: "to_do", label: "To do" },
  { value: "in_progress", label: "In progress" },
  { value: "waiting", label: "Waiting" },
  { value: "done", label: "Done" },
  { value: "cancelled", label: "Cancelled" },
] as const;

export const TASK_PRIORITIES = [
  { value: "low", label: "Low" },
  { value: "normal", label: "Normal" },
  { value: "high", label: "High" },
  { value: "urgent", label: "Urgent" },
] as const;

export type TaskStatus = (typeof TASK_STATUSES)[number]["value"];
export type TaskPriority = (typeof TASK_PRIORITIES)[number]["value"];

const STATUS_VALUES = new Set<string>(
  TASK_STATUSES.map((status) => status.value),
);
const PRIORITY_VALUES = new Set<string>(
  TASK_PRIORITIES.map((priority) => priority.value),
);

export function isTaskStatus(value: string): value is TaskStatus {
  return STATUS_VALUES.has(value);
}

export function isTaskPriority(value: string): value is TaskPriority {
  return PRIORITY_VALUES.has(value);
}

export function taskStatusLabel(value: string): string {
  return TASK_STATUSES.find((status) => status.value === value)?.label ?? value;
}

export function taskPriorityLabel(value: string): string {
  return (
    TASK_PRIORITIES.find((priority) => priority.value === value)?.label ?? value
  );
}

export function isOverdue(
  dueOn: string | null,
  status: string,
  today: string,
): boolean {
  if (!dueOn) return false;
  if (status === "done" || status === "cancelled") return false;
  return dueOn < today;
}

export function compareDueSoon(a: string | null, b: string | null): number {
  if (a === b) return 0;
  if (!a) return 1;
  if (!b) return -1;
  return a < b ? -1 : 1;
}

export function groupByStatus<
  T extends { status: string; dueOn: string | null },
>(tasks: readonly T[]): Record<TaskStatus, T[]> {
  const groups = {
    to_do: [] as T[],
    in_progress: [] as T[],
    waiting: [] as T[],
    done: [] as T[],
    cancelled: [] as T[],
  };
  for (const task of tasks) {
    if (!isTaskStatus(task.status)) continue;
    groups[task.status].push(task);
  }
  for (const status of TASK_STATUSES) {
    groups[status.value].sort((left, right) =>
      compareDueSoon(left.dueOn, right.dueOn),
    );
  }
  return groups;
}

export function progressCounts(
  tasks: readonly { key: string; status: string }[],
): Map<string, { done: number; open: number }> {
  const counts = new Map<string, { done: number; open: number }>();
  for (const task of tasks) {
    const current = counts.get(task.key) ?? { done: 0, open: 0 };
    if (task.status === "done") current.done += 1;
    else if (task.status !== "cancelled") current.open += 1;
    counts.set(task.key, current);
  }
  return counts;
}

const NOTE_EDIT_MS = 15 * 60 * 1000;

export function noteStillEditable(createdAt: string, nowMs?: number): boolean {
  const now = nowMs ?? Date.now();
  const created = Date.parse(createdAt);
  if (Number.isNaN(created)) return false;
  return now - created <= NOTE_EDIT_MS && now >= created;
}
