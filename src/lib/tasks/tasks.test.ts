import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  compareDueSoon,
  groupByStatus,
  isOverdue,
  noteStillEditable,
  progressCounts,
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

  it("lets the author edit a note for 15 minutes", () => {
    const created = "2026-10-31T12:00:00.000Z";
    const start = Date.parse(created);
    assert.equal(noteStillEditable(created, start + 14 * 60 * 1000), true);
    assert.equal(noteStillEditable(created, start + 16 * 60 * 1000), false);
  });
});
