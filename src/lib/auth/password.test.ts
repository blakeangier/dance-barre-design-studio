import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  MIN_PASSWORD_LENGTH,
  passwordIssueText,
  validatePasswordChange,
} from "./password.ts";

const current = "current-pass";
const next = "new-password";

describe("validatePasswordChange", () => {
  it("accepts a new password of 10 characters that matches and differs", () => {
    const created = "a".repeat(MIN_PASSWORD_LENGTH);
    assert.equal(created.length, 10);
    assert.deepEqual(
      validatePasswordChange({
        currentPassword: current,
        newPassword: created,
        confirmPassword: created,
      }),
      { ok: true },
    );
  });

  it("rejects a missing current password before other problems", () => {
    assert.deepEqual(
      validatePasswordChange({
        currentPassword: "",
        newPassword: "short",
        confirmPassword: "other",
      }),
      { ok: false, issue: "current" },
    );
    assert.equal(passwordIssueText("current"), "Enter your current password.");
  });

  it("rejects a new password shorter than 10 characters", () => {
    const created = "a".repeat(MIN_PASSWORD_LENGTH - 1);
    assert.deepEqual(
      validatePasswordChange({
        currentPassword: current,
        newPassword: created,
        confirmPassword: created,
      }),
      { ok: false, issue: "short" },
    );
    assert.equal(
      passwordIssueText("short"),
      "New passwords need at least 10 characters.",
    );
  });

  it("rejects a confirmation that does not match", () => {
    assert.deepEqual(
      validatePasswordChange({
        currentPassword: current,
        newPassword: next,
        confirmPassword: `${next}!`,
      }),
      { ok: false, issue: "mismatch" },
    );
    assert.equal(
      passwordIssueText("mismatch"),
      "The new password and the confirmation do not match.",
    );
  });

  it("rejects a new password that is the same as the current one", () => {
    const created = "same-password";
    assert.deepEqual(
      validatePasswordChange({
        currentPassword: created,
        newPassword: created,
        confirmPassword: created,
      }),
      { ok: false, issue: "same" },
    );
    assert.equal(
      passwordIssueText("same"),
      "Choose a new password that is different from your current one.",
    );
  });

  it("counts spaces and does not treat them as empty", () => {
    const created = "          ";
    assert.equal(created.length, 10);
    assert.deepEqual(
      validatePasswordChange({
        currentPassword: current,
        newPassword: created,
        confirmPassword: created,
      }),
      { ok: true },
    );
  });
});
