"use server";

import { redirect } from "next/navigation";
import { getSessionState } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

export async function updateMyDetails(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");

  const fullName = String(formData.get("fullName") ?? "").trim();
  const phone = String(formData.get("phone") ?? "").trim();

  if (fullName.length < 1 || fullName.length > 120) redirect("/?notice=name");
  if (phone.length > 40) redirect("/?notice=phone");

  const supabase = await createClient();
  const { error } = await supabase
    .from("profiles")
    .update({
      full_name: fullName,
      phone: phone.length > 0 ? phone : null,
    })
    .eq("id", state.profile.id);

  if (error) redirect("/?notice=save-failed");

  redirect("/?notice=saved");
}
