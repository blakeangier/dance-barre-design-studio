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

export const OPEN_TASK_STATUSES: readonly TaskStatus[] = [
  "to_do",
  "in_progress",
  "waiting",
];

export type TaskSheetScope = "mine" | "asked" | "both";

export type TaskSortKey =
  | "title"
  | "order"
  | "assigned"
  | "asked"
  | "status"
  | "priority"
  | "due"
  | "shift";

export type TaskSheetRow = {
  id: number;
  title: string;
  orderLabel: string | null;
  assignedTo: string;
  assignedName: string;
  askedBy: string;
  askedName: string;
  status: string;
  priority: string;
  dueOn: string | null;
  shiftDays: string;
  waitingReason: string | null;
};

const STATUS_RANK = new Map<string, number>(
  TASK_STATUSES.map((status, index) => [status.value, index]),
);
const PRIORITY_RANK = new Map<string, number>(
  TASK_PRIORITIES.map((priority, index) => [priority.value, index]),
);

export function canEditTaskStatus(input: {
  viewerId: string;
  assignedTo: string;
  createdBy: string;
  supervisor: boolean;
}): boolean {
  return (
    input.supervisor ||
    input.viewerId === input.assignedTo ||
    input.viewerId === input.createdBy
  );
}

export function canCancelTask(input: {
  viewerId: string;
  createdBy: string;
  supervisor: boolean;
}): boolean {
  return input.supervisor || input.viewerId === input.createdBy;
}

export function taskStatusOptions(canCancel: boolean): readonly TaskStatus[] {
  if (canCancel) return TASK_STATUSES.map((status) => status.value);
  return TASK_STATUSES.map((status) => status.value).filter(
    (status) => status !== "cancelled",
  );
}

export function taskInScope(
  row: Pick<TaskSheetRow, "assignedTo" | "askedBy">,
  viewerId: string,
  scope: TaskSheetScope | "all",
): boolean {
  if (scope === "all") return true;
  const mine = row.assignedTo === viewerId;
  const asked = row.askedBy === viewerId && row.assignedTo !== viewerId;
  if (scope === "mine") return mine;
  if (scope === "asked") return asked;
  return mine || asked;
}

export function filterTaskSheet(
  rows: readonly TaskSheetRow[],
  input: {
    viewerId: string;
    scope: TaskSheetScope | "all";
    statuses: readonly string[];
  },
): TaskSheetRow[] {
  const allowed = new Set(input.statuses);
  return rows.filter(
    (row) =>
      taskInScope(row, input.viewerId, input.scope) && allowed.has(row.status),
  );
}

function compareText(left: string, right: string): number {
  return left.localeCompare(right, "en-CA", { sensitivity: "base" });
}

export function compareTaskRows(
  left: TaskSheetRow,
  right: TaskSheetRow,
  key: TaskSortKey,
): number {
  switch (key) {
    case "title":
      return compareText(left.title, right.title);
    case "order": {
      const leftLabel = left.orderLabel ?? "";
      const rightLabel = right.orderLabel ?? "";
      if (leftLabel === rightLabel) return 0;
      if (!leftLabel) return 1;
      if (!rightLabel) return -1;
      return compareText(leftLabel, rightLabel);
    }
    case "assigned":
      return compareText(left.assignedName, right.assignedName);
    case "asked":
      return compareText(left.askedName, right.askedName);
    case "status":
      return (
        (STATUS_RANK.get(left.status) ?? 99) -
        (STATUS_RANK.get(right.status) ?? 99)
      );
    case "priority":
      return (
        (PRIORITY_RANK.get(left.priority) ?? 99) -
        (PRIORITY_RANK.get(right.priority) ?? 99)
      );
    case "due":
      return compareDueSoon(left.dueOn, right.dueOn);
    case "shift":
      return compareText(left.shiftDays, right.shiftDays);
    default: {
      const neverKey: never = key;
      return neverKey;
    }
  }
}

export function sortTaskRows(
  rows: readonly TaskSheetRow[],
  key: TaskSortKey,
  direction: "asc" | "desc",
): TaskSheetRow[] {
  const sorted = [...rows].sort((left, right) => {
    const compared = compareTaskRows(left, right, key);
    if (compared !== 0) return direction === "asc" ? compared : -compared;
    return compareText(left.title, right.title) || left.id - right.id;
  });
  return sorted;
}

const WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] as const;
const MONTHS = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
] as const;

function utcWeekday(year: number, month: number, day: number): number {
  const offsets = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4];
  const adjustedYear = month < 3 ? year - 1 : year;
  return (
    (adjustedYear +
      Math.floor(adjustedYear / 4) -
      Math.floor(adjustedYear / 100) +
      Math.floor(adjustedYear / 400) +
      (offsets[month - 1] ?? 0) +
      day) %
    7
  );
}

export function formatShiftDays(dates: readonly string[]): string {
  const unique = [
    ...new Set(
      dates
        .map((date) => date.slice(0, 10))
        .filter((date) => /^\d{4}-\d{2}-\d{2}$/.test(date)),
    ),
  ].sort();
  return unique
    .map((date) => {
      const [year, month, day] = date.split("-").map(Number);
      const weekday =
        WEEKDAYS[utcWeekday(year ?? 0, month ?? 1, day ?? 1)] ?? "";
      const monthName = MONTHS[(month ?? 1) - 1] ?? "";
      return `${weekday}, ${monthName} ${day ?? 1}`;
    })
    .join(", ");
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
