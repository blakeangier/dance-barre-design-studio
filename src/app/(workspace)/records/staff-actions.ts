"use server";

import { redirect } from "next/navigation";
import { canSeeStaffPrivate } from "@/lib/auth/permissions";
import { safeNextPath } from "@/lib/auth/redirect";
import { getSessionState } from "@/lib/auth/session";
import {
  employmentType,
  optionalDate,
  optionalText,
  personalEmail,
  phoneNumber,
  type FieldResult,
} from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

function bail(path: string, notice: string): never {
  redirect(`${path}?notice=${notice}`);
}

function take<T>(path: string, result: FieldResult<T>): T {
  if (!result.ok) bail(path, result.notice);
  return result.value;
}

export async function saveJobDetails(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (state.profile.role !== "owner") bail("/people", "denied");

  const profileId = String(formData.get("profileId") ?? "");
  const back = "/people";
  const title = take(back, optionalText(formData.get("jobTitle"), 80));
  const type = take(back, employmentType(formData.get("employmentType")));
  const start = take(back, optionalDate(formData.get("startDate")));
  const note = take(back, optionalText(formData.get("startNote"), 400));
  const pronouns = take(back, optionalText(formData.get("pronouns"), 40));
  const supabase = await createClient();
  const { error } = await supabase
    .from("profiles")
    .update({
      job_title: title,
      employment_type: type,
      start_date: start,
      start_note: note,
      pronouns,
    })
    .eq("id", profileId);
  if (error) bail(back, "failed");
  redirect(`${back}?notice=saved`);
}

export async function saveEmployeePrivate(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");

  const nextPath = safeNextPath(String(formData.get("next") ?? "/people"));
  const profileId = String(formData.get("profileId") ?? "");
  const own = profileId === state.profile.id;
  if (!own && !canSeeStaffPrivate(state.profile)) bail(nextPath, "denied");

  const street = take(nextPath, optionalText(formData.get("street"), 200));
  const city = take(nextPath, optionalText(formData.get("city"), 80));
  const province = take(nextPath, optionalText(formData.get("province"), 40));
  const postal = take(nextPath, optionalText(formData.get("postalCode"), 16));
  const email = take(nextPath, personalEmail(formData.get("personalEmail")));
  const emergencyName = take(
    nextPath,
    optionalText(formData.get("emergencyName"), 120),
  );
  const relationship = take(
    nextPath,
    optionalText(formData.get("emergencyRelationship"), 80),
  );
  const emergencyPhone = take(
    nextPath,
    phoneNumber(formData.get("emergencyPhone")),
  );
  const supabase = await createClient();
  const { error } = await supabase.from("employee_private").upsert(
    {
      profile_id: profileId,
      street,
      city,
      province,
      postal_code: postal,
      personal_email: email,
      emergency_name: emergencyName,
      emergency_relationship: relationship,
      emergency_phone: emergencyPhone,
    },
    { onConflict: "profile_id" },
  );
  if (error) bail(nextPath, "failed");
  redirect(
    `${nextPath}?notice=${nextPath === "/account" ? "private-saved" : "saved"}`,
  );
}
