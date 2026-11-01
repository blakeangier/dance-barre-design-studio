// Pure decisions for the password-reset links. The route and proxy call these
// so the PKCE code and the token_hash link end on the same page.

export const FORGOT_PASSWORD_PATH = "/forgot-password";
export const RESET_PASSWORD_PATH = "/reset-password";
export const RECOVERY_CALLBACK_PATH = "/auth/recovery";

const AUTH_EXCHANGE_PATHS = new Set(["/auth/callback", RECOVERY_CALLBACK_PATH]);

const EXPIRED_CODES = new Set([
  "otp_expired",
  "flow_state_expired",
  "session_expired",
]);

export type LinkFailure = "expired" | "invalid";

export type RecoveryHashAction =
  | { kind: "ignore" }
  | { kind: "error"; notice: LinkFailure }
  | { kind: "session"; accessToken: string; refreshToken: string };

type LinkInput = {
  type: string | null;
  recoveryPath?: boolean;
};

function matchesPath(pathname: string, path: string): boolean {
  return pathname === path || pathname.startsWith(`${path}/`);
}

export function isPasswordRecoveryPage(pathname: string): boolean {
  return (
    matchesPath(pathname, FORGOT_PASSWORD_PATH) ||
    matchesPath(pathname, RESET_PASSWORD_PATH)
  );
}

// Exact URL passed to resetPasswordForEmail. No query string, so the Auth
// allow-list can match it without a wildcard.
export function passwordResetRedirectUrl(site: string): string {
  return `${site.replace(/\/$/, "")}${RECOVERY_CALLBACK_PATH}`;
}

export function isRecoveryLink(input: LinkInput): boolean {
  return input.recoveryPath === true || input.type === "recovery";
}

export function callbackDestination(input: LinkInput): string {
  if (isRecoveryLink(input)) return RESET_PASSWORD_PATH;
  return "/";
}

export function linkFailureNotice(error: {
  code?: string | null;
  message?: string | null;
}): LinkFailure {
  const code = (error.code ?? "").toLowerCase();
  const message = (error.message ?? "").toLowerCase();
  if (EXPIRED_CODES.has(code) || message.includes("expired")) return "expired";
  return "invalid";
}

export function callbackFailurePath(
  input: LinkInput & { notice: LinkFailure },
): string {
  if (isRecoveryLink(input)) {
    return `${RESET_PASSWORD_PATH}?notice=${input.notice}`;
  }
  return "/login?notice=invalid";
}

// A recovery or magic-link redirect that misses /auth/* still carries ?code=
// or ?token_hash=. Those are not a session. Point them at the exchange route
// before the sign-in gate drops the query string.
export function authParamForwardPath(
  pathname: string,
  params: {
    get: (name: string) => string | null;
    has: (name: string) => boolean;
  },
): string | null {
  if (AUTH_EXCHANGE_PATHS.has(pathname)) return null;
  const hasCode = params.has("code");
  const hasToken = params.has("token_hash");
  if (!hasCode && !hasToken) return null;
  if (params.get("type") === "recovery") return RECOVERY_CALLBACK_PATH;
  return "/auth/callback";
}

// Dashboard recovery emails use the implicit grant: tokens sit in the hash,
// which the server never receives. @supabase/ssr only accepts PKCE codes from
// the URL, so this parses the hash and the caller stores the session itself.
export function recoveryHashAction(hash: string): RecoveryHashAction {
  const raw = hash.startsWith("#") ? hash.slice(1) : hash;
  if (!raw) return { kind: "ignore" };

  const params = new URLSearchParams(raw);
  if ((params.get("type") ?? "").toLowerCase() !== "recovery") {
    return { kind: "ignore" };
  }

  const accessToken = params.get("access_token");
  const refreshToken = params.get("refresh_token");
  if (accessToken && refreshToken) {
    return { kind: "session", accessToken, refreshToken };
  }

  return {
    kind: "error",
    notice: linkFailureNotice({
      code: params.get("error_code"),
      message: params.get("error_description"),
    }),
  };
}
