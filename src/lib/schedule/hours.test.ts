import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  elapsedMinutes,
  hoursFromMinutes,
  payPeriodContaining,
  payableMinutes,
} from "./hours.ts";

describe("shift hours", () => {
  it("subtracts an unpaid break from a same-day shift", () => {
    const minutes = elapsedMinutes({
      date: "2026-06-02",
      start: "09:00",
      end: "17:00",
      breakMinutes: 30,
    });
    assert.equal(minutes, 450);
    assert.equal(hoursFromMinutes(minutes!), 7.5);
  });

  it("counts an overnight shift into the next morning", () => {
    assert.equal(
      elapsedMinutes({
        date: "2026-06-02",
        start: "22:00",
        end: "06:00",
        breakMinutes: 0,
      }),
      480,
    );
  });

  it("uses the real elapsed time when Toronto springs forward", () => {
    assert.equal(
      elapsedMinutes({
        date: "2026-03-08",
        start: "01:00",
        end: "04:00",
        breakMinutes: 0,
      }),
      120,
    );
  });

  it("uses the real elapsed time when Toronto falls back", () => {
    assert.equal(
      elapsedMinutes({
        date: "2026-11-01",
        start: "01:00",
        end: "03:00",
        breakMinutes: 0,
      }),
      180,
    );
  });

  it("rejects a break that uses up the whole shift", () => {
    assert.equal(
      elapsedMinutes({
        date: "2026-06-02",
        start: "09:00",
        end: "09:20",
        breakMinutes: 30,
      }),
      null,
    );
  });

  it("rounds only when a rounding increment is set", () => {
    const shift = {
      date: "2026-06-02",
      start: "09:00",
      end: "16:08",
      breakMinutes: 0,
    };
    assert.equal(payableMinutes(shift, 0), 428);
    assert.equal(payableMinutes(shift, 15), 435);
  });
});

describe("bi-weekly pay periods", () => {
  const anchor = "2026-01-05";

  it("does not invent a period before the anchor or when the anchor is blank", () => {
    assert.equal(payPeriodContaining(null, "2026-01-05"), null);
    assert.equal(payPeriodContaining(anchor, "2026-01-04"), null);
  });

  it("starts a period on the anchor and ends 13 days later", () => {
    assert.deepEqual(payPeriodContaining(anchor, "2026-01-05"), {
      start: "2026-01-05",
      end: "2026-01-18",
    });
    assert.deepEqual(payPeriodContaining(anchor, "2026-01-18"), {
      start: "2026-01-05",
      end: "2026-01-18",
    });
  });

  it("opens the next period on day 15", () => {
    assert.deepEqual(payPeriodContaining(anchor, "2026-01-19"), {
      start: "2026-01-19",
      end: "2026-02-01",
    });
  });
});
