export const MIN_PASSWORD_LENGTH = 10;

export type PasswordIssue = "current" | "short" | "mismatch" | "same";

const ISSUE_TEXT: Record<PasswordIssue, string> = {
  current: "Enter your current password.",
  short: "New passwords need at least 10 characters.",
  mismatch: "The new password and the confirmation do not match.",
  same: "Choose a new password that is different from your current one.",
};

export function passwordIssueText(issue: PasswordIssue): string {
  return ISSUE_TEXT[issue];
}

export function isPasswordIssue(value: string): value is PasswordIssue {
  return value in ISSUE_TEXT;
}

// Passwords are compared exactly. Spaces count, and nothing is trimmed.
export function validatePasswordChange(input: {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}): { ok: true } | { ok: false; issue: PasswordIssue } {
  if (input.currentPassword.length === 0) {
    return { ok: false, issue: "current" };
  }
  if (input.newPassword.length < MIN_PASSWORD_LENGTH) {
    return { ok: false, issue: "short" };
  }
  if (input.newPassword !== input.confirmPassword) {
    return { ok: false, issue: "mismatch" };
  }
  if (input.newPassword === input.currentPassword) {
    return { ok: false, issue: "same" };
  }
  return { ok: true };
}
