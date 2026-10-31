"use server";

import { redirect } from "next/navigation";
import { safeNextPath } from "@/lib/auth/redirect";
import { getSessionState } from "@/lib/auth/session";
import { personName, phoneNumber } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

export async function updateMyDetails(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");

  const nextPath = safeNextPath(String(formData.get("next") ?? "/"));
  const name = personName(formData.get("fullName"));
  const phone = phoneNumber(formData.get("phone"));
  if (!name.ok) redirect(`${nextPath}?notice=${name.notice}`);
  if (!phone.ok) redirect(`${nextPath}?notice=${phone.notice}`);
  const fullName = name.value;

  const supabase = await createClient();
  const [nameResult, phoneResult] = await Promise.all([
    supabase
      .from("profiles")
      .update({ full_name: fullName })
      .eq("id", state.profile.id),
    supabase
      .from("profile_contacts")
      .update({ phone: phone.value })
      .eq("profile_id", state.profile.id),
  ]);

  if (nameResult.error || phoneResult.error) {
    redirect(`${nextPath}?notice=save-failed`);
  }

  redirect(
    `${nextPath}?notice=${nextPath === "/account" ? "details-saved" : "saved"}`,
  );
}
