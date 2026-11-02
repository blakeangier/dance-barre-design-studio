import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  copyShiftDates,
  shiftsOverlap,
  staffShiftMinutes,
  weekDays,
  weekStarting,
} from "./staff-week.ts";

describe("staff week", () => {
  it("starts the week on Monday", () => {
    assert.equal(weekStarting("2026-11-04", "2026-11-01"), "2026-11-02");
    assert.deepEqual(weekDays("2026-11-02"), [
      "2026-11-02",
      "2026-11-03",
      "2026-11-04",
      "2026-11-05",
      "2026-11-06",
      "2026-11-07",
      "2026-11-08",
    ]);
  });

  it("counts unpaid break and rejects an end that is not later", () => {
    assert.equal(staffShiftMinutes("09:00", "15:00", 30), 330);
    assert.equal(staffShiftMinutes("15:00", "09:00", 0), null);
    assert.equal(staffShiftMinutes("09:00", "09:30", 30), null);
  });

  it("warns when two shifts on the same day overlap", () => {
    assert.equal(
      shiftsOverlap(
        { start: "09:00", end: "13:00" },
        { start: "12:00", end: "16:00" },
      ),
      true,
    );
    assert.equal(
      shiftsOverlap(
        { start: "09:00", end: "12:00" },
        { start: "12:00", end: "16:00" },
      ),
      false,
    );
  });

  it("copies last week and skips a shift that is already there", () => {
    const copies = copyShiftDates(
      [
        { profileId: "a", date: "2026-10-26", start: "09:00", end: "15:00" },
        { profileId: "a", date: "2026-10-27", start: "10:00", end: "14:00" },
      ],
      [
        {
          profileId: "a",
          date: "2026-11-02",
          start: "09:00:00",
          end: "15:00:00",
        },
      ],
    );
    assert.deepEqual(copies, [
      { profileId: "a", date: "2026-11-03", start: "10:00", end: "14:00" },
    ]);
  });
});
