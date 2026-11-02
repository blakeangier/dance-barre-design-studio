"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useMemo, useState, useTransition } from "react";
import { setTaskStatus } from "@/app/(workspace)/tasks/status-action";
import {
  OPEN_TASK_STATUSES,
  TASK_STATUSES,
  canCancelTask,
  canEditTaskStatus,
  filterTaskSheet,
  isOverdue,
  sortTaskRows,
  taskPriorityLabel,
  taskStatusLabel,
  taskStatusOptions,
  type TaskSheetRow,
  type TaskSheetScope,
  type TaskSortKey,
  type TaskStatus,
} from "@/lib/tasks/tasks";

const COLUMNS: { key: TaskSortKey; label: string }[] = [
  { key: "title", label: "Task" },
  { key: "order", label: "Order" },
  { key: "assigned", label: "Assigned to" },
  { key: "asked", label: "Asked by" },
  { key: "status", label: "Status" },
  { key: "priority", label: "Priority" },
  { key: "due", label: "Due" },
  { key: "shift", label: "Shift" },
];

export function TaskSheet({
  rows,
  viewerId,
  today,
  supervisor,
  showScope = false,
}: {
  rows: TaskSheetRow[];
  viewerId: string;
  today: string;
  supervisor: boolean;
  showScope?: boolean;
}) {
  const [scope, setScope] = useState<TaskSheetScope>("both");
  const [statuses, setStatuses] = useState<string[]>([...OPEN_TASK_STATUSES]);
  const [sortKey, setSortKey] = useState<TaskSortKey>("due");
  const [direction, setDirection] = useState<"asc" | "desc">("asc");
  const [notice, setNotice] = useState<string | null>(null);
  const closedOn = statuses.includes("done") && statuses.includes("cancelled");

  const visible = useMemo(
    () =>
      sortTaskRows(
        filterTaskSheet(rows, {
          viewerId,
          scope: showScope ? scope : "all",
          statuses,
        }),
        sortKey,
        direction,
      ),
    [rows, viewerId, showScope, scope, statuses, sortKey, direction],
  );

  function toggleStatus(status: string) {
    setStatuses((current) =>
      current.includes(status)
        ? current.filter((item) => item !== status)
        : [...current, status],
    );
  }

  function toggleClosed() {
    setStatuses((current) => {
      const open = current.filter(
        (status) => status !== "done" && status !== "cancelled",
      );
      if (closedOn) return open;
      return [...open, "done", "cancelled"];
    });
  }

  function sortBy(key: TaskSortKey) {
    if (key === sortKey) {
      setDirection((current) => (current === "asc" ? "desc" : "asc"));
      return;
    }
    setSortKey(key);
    setDirection("asc");
  }

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-col gap-2">
        {showScope ? (
          <div
            className="flex flex-wrap gap-2"
            role="radiogroup"
            aria-label="Which tasks"
          >
            {(
              [
                ["mine", "Mine"],
                ["asked", "Asked of someone else"],
                ["both", "Both"],
              ] as const
            ).map(([value, label]) => (
              <button
                key={value}
                type="button"
                role="radio"
                aria-checked={scope === value}
                onClick={() => setScope(value)}
                className={`inline-flex min-h-11 items-center rounded-full px-3 text-sm font-medium ${
                  scope === value
                    ? "bg-ink text-white"
                    : "border border-ink text-ink"
                }`}
              >
                {label}
              </button>
            ))}
          </div>
        ) : null}
        <div className="flex flex-wrap items-center gap-2">
          <div className="flex flex-wrap gap-2" aria-label="Status">
            {TASK_STATUSES.map((status) => {
              const on = statuses.includes(status.value);
              return (
                <button
                  key={status.value}
                  type="button"
                  aria-pressed={on}
                  onClick={() => toggleStatus(status.value)}
                  className={`inline-flex min-h-11 items-center rounded-full px-3 text-sm font-medium ${
                    on
                      ? "bg-ink text-white"
                      : "border border-line bg-card text-ink"
                  }`}
                >
                  {status.label}
                </button>
              );
            })}
          </div>
          <button
            type="button"
            aria-pressed={closedOn}
            onClick={toggleClosed}
            className="inline-flex min-h-11 items-center rounded-full border border-ink px-3 text-sm font-medium"
          >
            {closedOn ? "Hide done and cancelled" : "Show done and cancelled"}
          </button>
        </div>
      </div>
      {notice ? <p className="text-sm text-ink">{notice}</p> : null}
      <p className="text-sm text-muted">
        {visible.length} {visible.length === 1 ? "task" : "tasks"}
      </p>
      <div className="max-h-[calc(100dvh-16rem)] overflow-auto rounded-xl border border-line bg-card">
        <table className="w-full min-w-[64rem] border-collapse text-left text-sm">
          <caption className="sr-only">Tasks</caption>
          <thead>
            <tr>
              {COLUMNS.map((column, index) => (
                <th
                  key={column.key}
                  aria-sort={
                    sortKey === column.key
                      ? direction === "asc"
                        ? "ascending"
                        : "descending"
                      : "none"
                  }
                  className={`sticky top-0 border-b border-line bg-card px-2 py-1.5 font-medium text-muted ${
                    index === 0
                      ? "left-0 z-30 min-w-48 shadow-[1px_0_0_0_var(--color-line)]"
                      : "z-20"
                  }`}
                >
                  <button
                    type="button"
                    onClick={() => sortBy(column.key)}
                    className="inline-flex min-h-11 items-center gap-1"
                  >
                    {column.label}
                    {sortKey === column.key
                      ? direction === "asc"
                        ? " ↑"
                        : " ↓"
                      : ""}
                  </button>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {visible.length === 0 ? (
              <tr>
                <td colSpan={COLUMNS.length} className="px-2 py-3 text-muted">
                  No tasks in this view.
                </td>
              </tr>
            ) : (
              visible.map((row) => (
                <tr key={row.id} className="group">
                  <td className="sticky left-0 z-10 min-w-48 border-b border-line bg-card px-2 py-1 shadow-[1px_0_0_0_var(--color-line)] group-hover:bg-paper">
                    <Link
                      href={`/tasks/${row.id}`}
                      className="font-medium text-ink underline decoration-line underline-offset-2"
                    >
                      {row.title}
                    </Link>
                  </td>
                  <SheetCell>{row.orderLabel ?? "—"}</SheetCell>
                  <SheetCell>{row.assignedName}</SheetCell>
                  <SheetCell>{row.askedName}</SheetCell>
                  <td className="border-b border-line px-2 py-1 group-hover:bg-paper">
                    <StatusSelect
                      key={`${row.id}:${row.status}`}
                      row={row}
                      viewerId={viewerId}
                      supervisor={supervisor}
                      onNotice={setNotice}
                    />
                  </td>
                  <SheetCell>{taskPriorityLabel(row.priority)}</SheetCell>
                  <td
                    className={`border-b border-line px-2 py-1 whitespace-nowrap group-hover:bg-paper ${
                      isOverdue(row.dueOn, row.status, today)
                        ? "font-medium text-red"
                        : ""
                    }`}
                  >
                    {row.dueOn ?? "—"}
                    {isOverdue(row.dueOn, row.status, today) ? " Overdue" : ""}
                  </td>
                  <SheetCell>{row.shiftDays || "—"}</SheetCell>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function SheetCell({ children }: { children: string }) {
  return (
    <td className="border-b border-line px-2 py-1 whitespace-nowrap text-ink group-hover:bg-paper">
      {children}
    </td>
  );
}

function StatusSelect({
  row,
  viewerId,
  supervisor,
  onNotice,
}: {
  row: TaskSheetRow;
  viewerId: string;
  supervisor: boolean;
  onNotice: (message: string | null) => void;
}) {
  const router = useRouter();
  const editable = canEditTaskStatus({
    viewerId,
    assignedTo: row.assignedTo,
    createdBy: row.askedBy,
    supervisor,
  });
  const [value, setValue] = useState(row.status);
  const [pending, startTransition] = useTransition();
  const canCancel = canCancelTask({
    viewerId,
    createdBy: row.askedBy,
    supervisor,
  });
  const choices = taskStatusOptions(canCancel);
  const options: string[] = choices.includes(value as TaskStatus)
    ? [...choices]
    : [value, ...choices];

  if (!editable) {
    return <span>{taskStatusLabel(row.status)}</span>;
  }

  return (
    <select
      aria-label={`Status for ${row.title}`}
      value={value}
      disabled={pending}
      onChange={(event) => {
        const next = event.target.value;
        const previous = value;
        setValue(next);
        onNotice(null);
        startTransition(async () => {
          const result = await setTaskStatus(row.id, next);
          if (!result.ok) {
            setValue(previous);
            onNotice(result.message);
            return;
          }
          onNotice(null);
          router.refresh();
        });
      }}
      className="max-w-40 rounded border border-line bg-card px-1 py-1 text-sm"
    >
      {options.map((status) => (
        <option key={status} value={status}>
          {taskStatusLabel(status)}
        </option>
      ))}
    </select>
  );
}
