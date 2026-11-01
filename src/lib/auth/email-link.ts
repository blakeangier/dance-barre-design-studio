import "server-only";

import { NextResponse } from "next/server";
import type { EmailOtpType } from "@supabase/supabase-js";
import {
  callbackDestination,
  callbackFailurePath,
  linkFailureNotice,
  type LinkFailure,
} from "@/lib/auth/recovery";
import { hasPublicSupabaseEnv } from "@/lib/supabase/env";
import { createClient } from "@/lib/supabase/server";

const OTP_TYPES = new Set<EmailOtpType>([
  "signup",
  "invite",
  "magiclink",
  "recovery",
  "email_change",
  "email",
]);

function isOtpType(value: string | null): value is EmailOtpType {
  return value !== null && OTP_TYPES.has(value as EmailOtpType);
}

// Turns an email link into a session cookie. recoveryPath is true for
// /auth/recovery, which is the redirect used by resetPasswordForEmail.
// A PKCE code has no type query; that path is what marks it as recovery.
export async function finishEmailLink(
  request: Request,
  recoveryPath: boolean,
): Promise<NextResponse> {
  const url = new URL(request.url);
  const type = url.searchParams.get("type");
  const link = { type, recoveryPath };

  const redirectTo = (path: string) =>
    NextResponse.redirect(new URL(path, url.origin));

  if (!hasPublicSupabaseEnv()) return redirectTo("/login?notice=setup");

  const fail = (notice: LinkFailure) =>
    redirectTo(callbackFailurePath({ ...link, notice }));

  const code = url.searchParams.get("code");
  const tokenHash = url.searchParams.get("token_hash");
  const errorCode = url.searchParams.get("error_code");
  const errorDescription = url.searchParams.get("error_description");

  if (!code && !tokenHash && (url.searchParams.get("error") || errorCode)) {
    return fail(
      linkFailureNotice({ code: errorCode, message: errorDescription }),
    );
  }

  const supabase = await createClient();

  if (code) {
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (error) return fail(linkFailureNotice(error));
    return redirectTo(callbackDestination(link));
  }

  if (tokenHash && isOtpType(type)) {
    // This path is only for password recovery. Other email types stay on
    // /auth/callback so a crafted link cannot turn a magic link into a
    // password form.
    if (recoveryPath && type !== "recovery") return fail("invalid");

    const { error } = await supabase.auth.verifyOtp({
      token_hash: tokenHash,
      type,
    });
    if (error) return fail(linkFailureNotice(error));
    return redirectTo(callbackDestination(link));
  }

  return fail("invalid");
}
