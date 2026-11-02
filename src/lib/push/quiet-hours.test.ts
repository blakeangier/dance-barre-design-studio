import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  isQuietHoursOpen,
  minuteInWindow,
  nextWindowStart,
  quietPlan,
  shouldDeliverQueued,
  summarizeQueued,
} from "./quiet-hours.ts";

const dayWindow = {
  start: "08:00",
  end: "21:00",
  timeZone: "America/Toronto",
};

describe("quiet hours window", () => {
  it("treats 8:00 AM as open and 9:00 PM as closed", () => {
    assert.equal(minuteInWindow(8 * 60, 8 * 60, 21 * 60), true);
    assert.equal(minuteInWindow(21 * 60, 8 * 60, 21 * 60), false);
    assert.equal(minuteInWindow(7 * 60 + 59, 8 * 60, 21 * 60), false);
    assert.equal(minuteInWindow(12 * 60, 8 * 60, 21 * 60), true);
  });

  it("keeps a window that crosses midnight open on both sides", () => {
    assert.equal(minuteInWindow(23 * 60, 22 * 60, 6 * 60), true);
    assert.equal(minuteInWindow(5 * 60, 22 * 60, 6 * 60), true);
    assert.equal(minuteInWindow(12 * 60, 22 * 60, 6 * 60), false);
    assert.equal(minuteInWindow(22 * 60, 22 * 60, 6 * 60), true);
    assert.equal(minuteInWindow(6 * 60, 22 * 60, 6 * 60), false);
  });

  it("queues a 10 PM Toronto notice until 8:00 the next morning", () => {
    const now = new Date("2026-07-15T02:30:00.000Z");
    assert.equal(isQuietHoursOpen(now, dayWindow), false);
    const plan = quietPlan({
      now,
      ...dayWindow,
      urgent: false,
      urgentBypass: false,
    });
    assert.equal(plan.action, "queue");
    if (plan.action !== "queue") return;
    assert.equal(plan.deliverAt.toISOString(), "2026-07-15T12:00:00.000Z");
    assert.equal(isQuietHoursOpen(plan.deliverAt, dayWindow), true);
  });

  it("delivers immediately inside the default window", () => {
    const now = new Date("2026-07-15T16:00:00.000Z");
    assert.equal(isQuietHoursOpen(now, dayWindow), true);
    assert.deepEqual(
      quietPlan({
        now,
        ...dayWindow,
        urgent: false,
        urgentBypass: false,
      }),
      { action: "send" },
    );
  });

  it("opens the next window the same morning when the notice is before 8:00", () => {
    const now = new Date("2026-07-15T11:15:00.000Z");
    const at = nextWindowStart(now, dayWindow);
    assert.equal(at.toISOString(), "2026-07-15T12:00:00.000Z");
  });

  it("queues a noon notice until 10 PM when the open hours cross midnight", () => {
    const now = new Date("2026-07-15T16:00:00.000Z");
    const window = {
      start: "22:00",
      end: "06:00",
      timeZone: "America/Toronto",
    };
    assert.equal(isQuietHoursOpen(now, window), false);
    assert.equal(
      nextWindowStart(now, window).toISOString(),
      "2026-07-16T02:00:00.000Z",
    );
  });

  it("lets an urgent announcement through only when that person allowed it", () => {
    const now = new Date("2026-07-15T03:00:00.000Z");
    assert.equal(
      quietPlan({
        now,
        ...dayWindow,
        urgent: true,
        urgentBypass: false,
      }).action,
      "queue",
    );
    assert.equal(
      quietPlan({
        now,
        ...dayWindow,
        urgent: true,
        urgentBypass: true,
      }).action,
      "send",
    );
  });
});

describe("quiet hours and daylight saving", () => {
  it("uses 8:00 AM Eastern Daylight Time after Toronto springs forward", () => {
    const before = new Date("2026-03-08T11:30:00.000Z");
    assert.equal(isQuietHoursOpen(before, dayWindow), false);
    const at = nextWindowStart(before, dayWindow);
    assert.equal(at.toISOString(), "2026-03-08T12:00:00.000Z");
    assert.equal(isQuietHoursOpen(at, dayWindow), true);
  });

  it("uses 8:00 AM Eastern Standard Time after Toronto falls back", () => {
    const first = new Date("2026-11-01T05:30:00.000Z");
    const second = new Date("2026-11-01T06:30:00.000Z");
    assert.equal(isQuietHoursOpen(first, dayWindow), false);
    assert.equal(isQuietHoursOpen(second, dayWindow), false);
    assert.equal(
      nextWindowStart(first, dayWindow).toISOString(),
      "2026-11-01T13:00:00.000Z",
    );
    assert.equal(
      nextWindowStart(second, dayWindow).toISOString(),
      "2026-11-01T13:00:00.000Z",
    );
  });

  it("still finds an open minute when the window starts in the missing hour", () => {
    const now = new Date("2026-03-08T06:00:00.000Z");
    const at = nextWindowStart(now, {
      start: "02:30",
      end: "21:00",
      timeZone: "America/Toronto",
    });
    assert.ok(at.getTime() >= now.getTime());
    assert.equal(
      isQuietHoursOpen(at, {
        start: "02:30",
        end: "21:00",
        timeZone: "America/Toronto",
      }),
      true,
    );
  });
});

describe("queued delivery", () => {
  it("does not flush while the master switch is off", () => {
    assert.equal(
      shouldDeliverQueued(
        false,
        new Date("2026-07-15T12:00:00.000Z"),
        new Date("2026-07-15T12:05:00.000Z"),
      ),
      false,
    );
  });

  it("waits until the queued time even when the master switch is on", () => {
    const deliverAt = new Date("2026-07-15T12:00:00.000Z");
    assert.equal(
      shouldDeliverQueued(
        true,
        deliverAt,
        new Date("2026-07-15T11:59:00.000Z"),
      ),
      false,
    );
    assert.equal(shouldDeliverQueued(true, deliverAt, deliverAt), true);
  });

  it("folds several overnight notices into one summary", () => {
    const summary = summarizeQueued([
      { title: "Shift added", body: "Monday" },
      { title: "Task assigned", body: "Hem" },
      { title: "Shift changed", body: "Tuesday" },
    ]);
    assert.equal(summary.title, "3 updates");
    assert.equal(
      summary.body,
      "3 updates: Shift added, Task assigned, Shift changed",
    );
    assert.equal(
      summarizeQueued([{ title: "Shift added", body: "Monday 09:00" }]).body,
      "Monday 09:00",
    );
  });
});
