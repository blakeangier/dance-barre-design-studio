import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  canCancelTask,
  canEditTaskStatus,
  compareDueSoon,
  filterTaskSheet,
  formatShiftDays,
  groupByStatus,
  isOverdue,
  noteStillEditable,
  OPEN_TASK_STATUSES,
  progressCounts,
  sortTaskRows,
  taskStatusOptions,
  type TaskSheetRow,
} from "./tasks.ts";

describe("task overdue and order", () => {
  it("flags a past due date until the task is done or cancelled", () => {
    assert.equal(isOverdue("2026-10-01", "to_do", "2026-10-31"), true);
    assert.equal(isOverdue("2026-11-02", "in_progress", "2026-10-31"), false);
    assert.equal(isOverdue("2026-10-01", "done", "2026-10-31"), false);
    assert.equal(isOverdue("2026-10-01", "cancelled", "2026-10-31"), false);
    assert.equal(isOverdue(null, "to_do", "2026-10-31"), false);
  });

  it("puts the soonest due date first and leaves undated tasks last", () => {
    const groups = groupByStatus([
      { status: "to_do", dueOn: null, title: "later" },
      { status: "to_do", dueOn: "2026-12-01", title: "dec" },
      { status: "to_do", dueOn: "2026-11-01", title: "nov" },
      { status: "done", dueOn: "2026-10-01", title: "finished" },
    ]);
    assert.deepEqual(
      groups.to_do.map((task) => task.title),
      ["nov", "dec", "later"],
    );
    assert.equal(groups.done[0]?.title, "finished");
    assert.equal(compareDueSoon(null, "2026-11-01"), 1);
  });
});

describe("task progress and notes", () => {
  it("counts done and still-open work, and skips cancelled", () => {
    const counts = progressCounts([
      { key: "Ava", status: "done" },
      { key: "Ava", status: "to_do" },
      { key: "Ava", status: "cancelled" },
      { key: "005", status: "waiting" },
    ]);
    assert.deepEqual(counts.get("Ava"), { done: 1, open: 1 });
    assert.deepEqual(counts.get("005"), { done: 0, open: 1 });
  });

  it("keeps SAMPLE rows in a sheet: open statuses, scope, and column order", () => {
    const rows: TaskSheetRow[] = [
      {
        id: 2,
        title: "SAMPLE hem",
        orderLabel: "002 · SAMPLE song · CREW",
        assignedTo: "me",
        assignedName: "SAMPLE Me",
        askedBy: "owner",
        askedName: "SAMPLE Owner",
        status: "done",
        priority: "low",
        dueOn: "2026-11-01",
        shiftDays: "Mon, Nov 2",
        waitingReason: null,
      },
      {
        id: 1,
        title: "SAMPLE leos",
        orderLabel: "001 · SAMPLE song · Elite Company",
        assignedTo: "me",
        assignedName: "SAMPLE Me",
        askedBy: "me",
        askedName: "SAMPLE Me",
        status: "to_do",
        priority: "normal",
        dueOn: "2026-11-11",
        shiftDays: "",
        waitingReason: null,
      },
      {
        id: 3,
        title: "SAMPLE ask",
        orderLabel: null,
        assignedTo: "other",
        assignedName: "SAMPLE Other",
        askedBy: "me",
        askedName: "SAMPLE Me",
        status: "waiting",
        priority: "high",
        dueOn: null,
        shiftDays: "Tue, Nov 3",
        waitingReason: "SAMPLE reason",
      },
    ];
    const open = filterTaskSheet(rows, {
      viewerId: "me",
      scope: "both",
      statuses: OPEN_TASK_STATUSES,
    });
    assert.deepEqual(
      open.map((row) => row.id),
      [1, 3],
    );
    assert.deepEqual(
      filterTaskSheet(rows, {
        viewerId: "me",
        scope: "asked",
        statuses: OPEN_TASK_STATUSES,
      }).map((row) => row.title),
      ["SAMPLE ask"],
    );
    assert.deepEqual(
      sortTaskRows(rows, "order", "asc").map((row) => row.id),
      [1, 2, 3],
    );
    assert.equal(
      formatShiftDays(["2026-11-03", "2026-11-02", "2026-11-02"]),
      "Mon, Nov 2, Tue, Nov 3",
    );
  });

  it("lets an assignee change status and keeps cancel with the asker or a supervisor", () => {
    assert.equal(
      canEditTaskStatus({
        viewerId: "maker",
        assignedTo: "maker",
        createdBy: "owner",
        supervisor: false,
      }),
      true,
    );
    assert.equal(
      canCancelTask({
        viewerId: "maker",
        createdBy: "owner",
        supervisor: false,
      }),
      false,
    );
    assert.deepEqual(taskStatusOptions(false).includes("cancelled"), false);
    assert.equal(
      canCancelTask({
        viewerId: "owner",
        createdBy: "owner",
        supervisor: false,
      }),
      true,
    );
    assert.equal(
      canEditTaskStatus({
        viewerId: "payroll",
        assignedTo: "maker",
        createdBy: "owner",
        supervisor: false,
      }),
      false,
    );
  });

  it("lets the author edit a note for 15 minutes", () => {
    const created = "2026-10-31T12:00:00.000Z";
    const start = Date.parse(created);
    assert.equal(noteStillEditable(created, start + 14 * 60 * 1000), true);
    assert.equal(noteStillEditable(created, start + 16 * 60 * 1000), false);
  });
});
