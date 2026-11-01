import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  MIN_PASSWORD_LENGTH,
  passwordIssueText,
  passwordUpdateIssue,
  validateNewPassword,
  validatePasswordChange,
} from "./password.ts";

const current = "current-pass";
const next = "new-password";

describe("validatePasswordChange", () => {
  it("accepts a new password of 12 characters that matches and differs", () => {
    const created = "a".repeat(MIN_PASSWORD_LENGTH);
    assert.equal(created.length, 12);
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

  it("rejects a new password shorter than 12 characters", () => {
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
      "New passwords need at least 12 characters.",
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
    const created = " ".repeat(MIN_PASSWORD_LENGTH);
    assert.equal(created.length, 12);
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

describe("validateNewPassword", () => {
  it("accepts 12 characters that match, including spaces", () => {
    const created = `Ab1${" ".repeat(MIN_PASSWORD_LENGTH - 3)}`;
    assert.deepEqual(
      validateNewPassword({ newPassword: created, confirmPassword: created }),
      { ok: true },
    );
  });

  it("rejects a short password before a mismatch", () => {
    assert.deepEqual(
      validateNewPassword({ newPassword: "short", confirmPassword: "other" }),
      { ok: false, issue: "short" },
    );
  });

  it("rejects a confirmation that does not match", () => {
    const created = "a".repeat(MIN_PASSWORD_LENGTH);
    assert.deepEqual(
      validateNewPassword({
        newPassword: created,
        confirmPassword: `${created}!`,
      }),
      { ok: false, issue: "mismatch" },
    );
  });

  it("does not trim the password", () => {
    const created = `${"a".repeat(MIN_PASSWORD_LENGTH)} `;
    assert.deepEqual(
      validateNewPassword({
        newPassword: created,
        confirmPassword: created.trim(),
      }),
      { ok: false, issue: "mismatch" },
    );
  });
});

describe("passwordUpdateIssue", () => {
  it("maps weak, reused, and expired sessions", () => {
    assert.equal(passwordUpdateIssue({ code: "weak_password" }), "weak");
    assert.equal(passwordUpdateIssue({ code: "same_password" }), "same");
    assert.equal(passwordUpdateIssue({ code: "session_expired" }), "invalid");
    assert.equal(
      passwordUpdateIssue({ code: "over_request_rate_limit" }),
      "failed",
    );
    assert.equal(
      passwordUpdateIssue({
        message: "Password should be at least 12 characters.",
      }),
      "weak",
    );
  });
});
