import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  employmentType,
  optionalDate,
  optionalNumber,
  optionalText,
  orderStatus,
  personalEmail,
  personName,
  phoneNumber,
  reviewStatus,
  stageYes,
} from "./edit.ts";

describe("record edit validation", () => {
  it("requires a name and keeps a normal one", () => {
    assert.deepEqual(personName("  Blake Angier  "), {
      ok: true,
      value: "Blake Angier",
    });
    assert.deepEqual(personName("   "), { ok: false, notice: "name" });
    assert.equal(personName("a".repeat(121)).ok, false);
  });

  it("allows a blank phone and rejects a very long one", () => {
    assert.deepEqual(phoneNumber(""), { ok: true, value: null });
    assert.deepEqual(phoneNumber("  519-555-0100 "), {
      ok: true,
      value: "519-555-0100",
    });
    assert.deepEqual(phoneNumber("1".repeat(41)), {
      ok: false,
      notice: "phone",
    });
  });

  it("accepts a plain number and rejects free-text stock", () => {
    assert.deepEqual(optionalNumber(""), { ok: true, value: null });
    assert.deepEqual(optionalNumber(" 12.5 "), { ok: true, value: 12.5 });
    assert.deepEqual(optionalNumber("27.5m + 40m"), {
      ok: false,
      notice: "number",
    });
    assert.deepEqual(optionalNumber("100m"), { ok: false, notice: "number" });
  });

  it("accepts a real calendar date only", () => {
    assert.deepEqual(optionalDate("2026-10-31"), {
      ok: true,
      value: "2026-10-31",
    });
    assert.deepEqual(optionalDate(""), { ok: true, value: null });
    assert.deepEqual(optionalDate("2026-02-31"), { ok: false, notice: "date" });
    assert.deepEqual(optionalDate("31 Oct 2026"), {
      ok: false,
      notice: "date",
    });
  });

  it("only allows the order and review statuses in the lists", () => {
    assert.deepEqual(orderStatus(""), { ok: true, value: null });
    assert.deepEqual(orderStatus("cancelled"), {
      ok: true,
      value: "cancelled",
    });
    assert.deepEqual(orderStatus("Cancelled-purchasing"), {
      ok: false,
      notice: "status",
    });
    assert.deepEqual(reviewStatus("answered"), { ok: true, value: "answered" });
    assert.deepEqual(reviewStatus("resolved"), { ok: false, notice: "status" });
    assert.deepEqual(stageYes("yes"), { ok: true, value: true });
    assert.deepEqual(stageYes(""), { ok: true, value: null });
    assert.deepEqual(stageYes("already completed"), {
      ok: false,
      notice: "status",
    });
  });

  it("keeps employment type and personal email empty unless they are usable", () => {
    assert.deepEqual(employmentType(""), { ok: true, value: null });
    assert.deepEqual(employmentType("full-time"), {
      ok: true,
      value: "full-time",
    });
    assert.deepEqual(employmentType("contractor"), {
      ok: true,
      value: "contractor",
    });
    assert.deepEqual(employmentType("casual"), {
      ok: false,
      notice: "employment",
    });
    assert.deepEqual(personalEmail(""), { ok: true, value: null });
    assert.deepEqual(personalEmail("  me@example.com "), {
      ok: true,
      value: "me@example.com",
    });
    assert.deepEqual(personalEmail("not-an-email"), {
      ok: false,
      notice: "email",
    });
  });

  it("rejects text over the limit", () => {
    assert.deepEqual(optionalText("x".repeat(20), 8), {
      ok: false,
      notice: "long",
    });
    assert.deepEqual(optionalText("  ", 8), { ok: true, value: null });
  });
});
