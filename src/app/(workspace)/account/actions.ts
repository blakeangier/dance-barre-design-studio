"use server";

import { redirect } from "next/navigation";
import {
  passwordUpdateIssue,
  validatePasswordChange,
} from "@/lib/auth/password";
import { getSessionState } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

function accountRedirect(notice: string): never {
  redirect(`/account?notice=${notice}`);
}

export async function changePassword(formData: FormData) {
  const currentPassword = String(formData.get("currentPassword") ?? "");
  const newPassword = String(formData.get("newPassword") ?? "");
  const confirmPassword = String(formData.get("confirmPassword") ?? "");
  const check = validatePasswordChange({
    currentPassword,
    newPassword,
    confirmPassword,
  });

  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!check.ok) accountRedirect(check.issue);

  const supabase = await createClient();
  const { error: signInError } = await supabase.auth.signInWithPassword({
    email: state.profile.email.trim().toLowerCase(),
    password: currentPassword,
  });
  if (signInError) accountRedirect("wrong");

  const { error: updateError } = await supabase.auth.updateUser({
    password: newPassword,
  });
  if (updateError) {
    const issue = passwordUpdateIssue(updateError);
    accountRedirect(issue === "invalid" ? "failed" : issue);
  }

  accountRedirect("saved");
}
