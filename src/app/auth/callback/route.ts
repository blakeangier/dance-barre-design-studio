import { NextResponse } from "next/server";
import type { EmailOtpType } from "@supabase/supabase-js";
import { createClient } from "@/lib/supabase/server";
import { hasPublicSupabaseEnv } from "@/lib/supabase/env";

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

// Email sign-in links land here. The code is exchanged for a session cookie.
export async function GET(request: Request) {
  const url = new URL(request.url);
  const failure = NextResponse.redirect(
    new URL("/login?notice=invalid", url.origin),
  );

  if (!hasPublicSupabaseEnv()) {
    return NextResponse.redirect(new URL("/login?notice=setup", url.origin));
  }

  const supabase = await createClient();
  const code = url.searchParams.get("code");
  const tokenHash = url.searchParams.get("token_hash");
  const type = url.searchParams.get("type");

  if (code) {
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (error) return failure;
    return NextResponse.redirect(new URL("/", url.origin));
  }

  if (tokenHash && isOtpType(type)) {
    const { error } = await supabase.auth.verifyOtp({
      token_hash: tokenHash,
      type,
    });
    if (error) return failure;
    return NextResponse.redirect(new URL("/", url.origin));
  }

  return failure;
}
