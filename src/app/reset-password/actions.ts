"use server";

import { redirect } from "next/navigation";
import { passwordUpdateIssue, validateNewPassword } from "@/lib/auth/password";
import { hasPublicSupabaseEnv } from "@/lib/supabase/env";
import { createClient } from "@/lib/supabase/server";

function back(notice: string): never {
  redirect(`/reset-password?notice=${notice}`);
}

export async function setNewPassword(formData: FormData) {
  if (!hasPublicSupabaseEnv()) redirect("/login?notice=setup");

  const newPassword = String(formData.get("password") ?? "");
  const confirmPassword = String(formData.get("confirm") ?? "");
  const check = validateNewPassword({ newPassword, confirmPassword });
  if (!check.ok) back(check.issue);

  const supabase = await createClient();
  const { data } = await supabase.auth.getClaims();
  if (!data?.claims.sub) back("invalid");

  const { error } = await supabase.auth.updateUser({ password: newPassword });
  if (error) back(passwordUpdateIssue(error));

  redirect("/");
}
