// Matches the sign-in field and the local Auth minimum in supabase/config.toml.
// A shorter password cannot be typed on the sign-in page.
export const MIN_PASSWORD_LENGTH = 12;

export type PasswordIssue = "current" | "short" | "mismatch" | "same";

const ISSUE_TEXT: Record<PasswordIssue, string> = {
  current: "Enter your current password.",
  short: "New passwords need at least 12 characters.",
  mismatch: "The new password and the confirmation do not match.",
  same: "Choose a new password that is different from your current one.",
};

export function passwordIssueText(issue: PasswordIssue): string {
  return ISSUE_TEXT[issue];
}

export const WEAK_PASSWORD_TEXT =
  "That password was rejected. Use at least 12 characters, with an uppercase letter, a lowercase letter, and a digit.";

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

export type NewPasswordIssue = "short" | "mismatch";

// Recovery has no current password to compare. Spaces still count.
export function validateNewPassword(input: {
  newPassword: string;
  confirmPassword: string;
}): { ok: true } | { ok: false; issue: NewPasswordIssue } {
  if (input.newPassword.length < MIN_PASSWORD_LENGTH) {
    return { ok: false, issue: "short" };
  }
  if (input.newPassword !== input.confirmPassword) {
    return { ok: false, issue: "mismatch" };
  }
  return { ok: true };
}

export type PasswordUpdateIssue = "weak" | "same" | "invalid" | "failed";

// Maps an Auth updateUser error to a notice. Does not echo the raw message.
export function passwordUpdateIssue(error: {
  code?: string | null;
  message?: string | null;
}): PasswordUpdateIssue {
  const code = error.code ?? "";
  if (code === "weak_password") return "weak";
  if (code === "same_password") return "same";
  if (code === "session_not_found" || code === "session_expired") {
    return "invalid";
  }
  const message = (error.message ?? "").toLowerCase();
  if (message.includes("weak") || message.includes("should be at least")) {
    return "weak";
  }
  if (message.includes("different from the old")) return "same";
  return "failed";
}
