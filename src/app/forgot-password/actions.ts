"use server";

import { redirect } from "next/navigation";
import { passwordResetRedirectUrl } from "@/lib/auth/recovery";
import { hasPublicSupabaseEnv, siteUrl } from "@/lib/supabase/env";
import { createClient } from "@/lib/supabase/server";

// The same sentence is shown whether or not the address has an account.
// resetPasswordForEmail already hides that, and so do we.
export async function requestPasswordReset(formData: FormData) {
  if (!hasPublicSupabaseEnv()) redirect("/forgot-password?notice=setup");

  const email = String(formData.get("email") ?? "")
    .trim()
    .toLowerCase();

  if (!email) redirect("/forgot-password?notice=missing");

  try {
    const supabase = await createClient();
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: passwordResetRedirectUrl(siteUrl()),
    });
    if (error) {
      console.error(
        "Password reset email was not sent",
        error.code ?? "unknown",
      );
    }
  } catch {
    console.error("Password reset email was not sent");
  }

  redirect("/forgot-password?notice=sent");
}
