import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  authParamForwardPath,
  callbackDestination,
  callbackFailurePath,
  isPasswordRecoveryPage,
  isRecoveryLink,
  linkFailureNotice,
  passwordResetRedirectUrl,
  recoveryHashAction,
  RECOVERY_CALLBACK_PATH,
} from "./recovery.ts";

describe("passwordResetRedirectUrl", () => {
  it("points at the recovery exchange path and drops a trailing slash", () => {
    assert.equal(
      passwordResetRedirectUrl("https://dance-barre-design-studio.vercel.app/"),
      "https://dance-barre-design-studio.vercel.app/auth/recovery",
    );
    assert.equal(
      passwordResetRedirectUrl("http://localhost:3000").includes("?"),
      false,
    );
  });
});

describe("recovery link routing", () => {
  it("sends a recovery session to the set-password page", () => {
    assert.equal(isRecoveryLink({ type: "recovery" }), true);
    assert.equal(isRecoveryLink({ type: null, recoveryPath: true }), true);
    assert.equal(isRecoveryLink({ type: "magiclink" }), false);
    assert.equal(callbackDestination({ type: "recovery" }), "/reset-password");
    assert.equal(
      callbackDestination({ type: null, recoveryPath: true }),
      "/reset-password",
    );
    assert.equal(callbackDestination({ type: "magiclink" }), "/");
    assert.equal(callbackDestination({ type: null }), "/");
  });

  it("keeps an expired recovery link off the sign-in page", () => {
    assert.equal(
      callbackFailurePath({ type: "recovery", notice: "expired" }),
      "/reset-password?notice=expired",
    );
    assert.equal(
      callbackFailurePath({
        type: null,
        recoveryPath: true,
        notice: "invalid",
      }),
      "/reset-password?notice=invalid",
    );
    assert.equal(
      callbackFailurePath({ type: "magiclink", notice: "invalid" }),
      "/login?notice=invalid",
    );
  });

  it("treats expired auth errors as expired and everything else as invalid", () => {
    assert.equal(linkFailureNotice({ code: "otp_expired" }), "expired");
    assert.equal(linkFailureNotice({ code: "flow_state_expired" }), "expired");
    assert.equal(
      linkFailureNotice({
        message: "Email link is invalid or has expired",
      }),
      "expired",
    );
    assert.equal(
      linkFailureNotice({ code: "flow_state_not_found" }),
      "invalid",
    );
    assert.equal(linkFailureNotice({ code: null, message: null }), "invalid");
  });
});

describe("authParamForwardPath", () => {
  const params = (search: string) => new URLSearchParams(search);

  it("leaves the exchange routes alone", () => {
    assert.equal(
      authParamForwardPath("/auth/callback", params("code=abc")),
      null,
    );
    assert.equal(
      authParamForwardPath(
        RECOVERY_CALLBACK_PATH,
        params("token_hash=abc&type=recovery"),
      ),
      null,
    );
    assert.equal(authParamForwardPath("/", params("")), null);
    assert.equal(
      authParamForwardPath("/login", params("notice=invalid")),
      null,
    );
  });

  it("sends a stray recovery token to /auth/recovery and other codes to the callback", () => {
    assert.equal(
      authParamForwardPath("/", params("token_hash=abc&type=recovery")),
      "/auth/recovery",
    );
    assert.equal(
      authParamForwardPath("/login", params("code=abc&type=recovery")),
      "/auth/recovery",
    );
    assert.equal(
      authParamForwardPath("/", params("code=abc")),
      "/auth/callback",
    );
    assert.equal(
      authParamForwardPath("/", params("token_hash=abc&type=magiclink")),
      "/auth/callback",
    );
  });
});

describe("recoveryHashAction", () => {
  it("ignores hashes that are not a recovery grant", () => {
    assert.deepEqual(recoveryHashAction(""), { kind: "ignore" });
    assert.deepEqual(recoveryHashAction("#access_token=a&type=magiclink"), {
      kind: "ignore",
    });
  });

  it("keeps a recovery session from the hash", () => {
    assert.deepEqual(
      recoveryHashAction(
        "#access_token=access&refresh_token=refresh&type=recovery",
      ),
      { kind: "session", accessToken: "access", refreshToken: "refresh" },
    );
  });

  it("turns an expired or broken recovery hash into a notice", () => {
    assert.deepEqual(
      recoveryHashAction(
        "#error=access_denied&error_code=otp_expired&type=recovery",
      ),
      { kind: "error", notice: "expired" },
    );
    assert.deepEqual(
      recoveryHashAction("#error=access_denied&error_code=bad&type=Recovery"),
      { kind: "error", notice: "invalid" },
    );
  });
});

describe("isPasswordRecoveryPage", () => {
  it("allows the forgot and reset pages without opening other routes", () => {
    assert.equal(isPasswordRecoveryPage("/forgot-password"), true);
    assert.equal(isPasswordRecoveryPage("/reset-password"), true);
    assert.equal(isPasswordRecoveryPage("/forgot-password/extra"), true);
    assert.equal(isPasswordRecoveryPage("/forgot-password-other"), false);
    assert.equal(isPasswordRecoveryPage("/login"), false);
    assert.equal(isPasswordRecoveryPage("/"), false);
  });
});
