"use server";

import { redirect } from "next/navigation";
import { safeNextPath } from "@/lib/auth/redirect";
import { hasPublicSupabaseEnv, siteUrl } from "@/lib/supabase/env";
import { createClient } from "@/lib/supabase/server";

function loginRedirect(notice: string, nextPath: string): never {
  const params = new URLSearchParams({ notice });
  if (nextPath !== "/") params.set("next", nextPath);
  redirect(`/login?${params.toString()}`);
}

export async function signIn(formData: FormData) {
  const nextPath = safeNextPath(String(formData.get("next") ?? ""));

  if (!hasPublicSupabaseEnv()) loginRedirect("setup", nextPath);

  const email = String(formData.get("email") ?? "")
    .trim()
    .toLowerCase();
  const password = String(formData.get("password") ?? "");

  if (!email || !password) loginRedirect("missing", nextPath);

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) loginRedirect("invalid", nextPath);

  redirect(nextPath);
}

export async function sendMagicLink(formData: FormData) {
  if (!hasPublicSupabaseEnv()) redirect("/login?notice=setup");

  const email = String(formData.get("email") ?? "")
    .trim()
    .toLowerCase();

  if (!email) redirect("/login?notice=missing");

  const supabase = await createClient();

  // shouldCreateUser is false so a magic link cannot open a new account,
  // even if public sign-up is turned on by mistake in the dashboard.
  await supabase.auth.signInWithOtp({
    email,
    options: {
      emailRedirectTo: `${siteUrl()}/auth/callback`,
      shouldCreateUser: false,
    },
  });

  redirect("/login?notice=link");
}

export async function signOut() {
  if (hasPublicSupabaseEnv()) {
    const supabase = await createClient();
    await supabase.auth.signOut();
  }

  redirect("/login");
}
