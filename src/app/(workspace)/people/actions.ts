"use server";

import { redirect } from "next/navigation";
import { isAppRole } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { createAdminClient } from "@/lib/supabase/admin";
import { createClient } from "@/lib/supabase/server";

const UUID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function done(notice: string): never {
  redirect(`/people?notice=${notice}`);
}

// Owners only. The signed-in session is checked first. The secret key is used
// only after that, because row-level security does not let a normal session
// rewrite someone else's role.
export async function updateAccess(formData: FormData) {
  const state = await getSessionState();

  if (state.status !== "ready" || state.profile.role !== "owner") {
    done("denied");
  }

  const profileId = String(formData.get("profileId") ?? "");
  const roleValue = String(formData.get("role") ?? "");
  const fullName = String(formData.get("fullName") ?? "").trim();
  const canPurchase = formData.get("canPurchase") === "on";
  const isActive = formData.get("isActive") === "on";

  if (!UUID_PATTERN.test(profileId) || !isAppRole(roleValue)) {
    done("missing-person");
  }
  if (fullName.length < 1 || fullName.length > 120) done("name");

  if (profileId === state.profile.id) done("self");

  const supabase = await createClient();
  const { data: visible } = await supabase
    .from("profiles")
    .select("id")
    .eq("id", profileId)
    .maybeSingle();

  if (!visible) done("missing-person");

  let admin;

  try {
    admin = createAdminClient();
  } catch {
    done("secret");
  }

  const { data: userResult, error: readError } =
    await admin.auth.admin.getUserById(profileId);

  if (readError || !userResult.user) done("missing-person");

  const { error: authError } = await admin.auth.admin.updateUserById(
    profileId,
    {
      app_metadata: {
        ...userResult.user.app_metadata,
        role: roleValue,
        can_purchase: canPurchase,
        full_name: fullName,
      },
    },
  );

  if (authError) done("failed");

  const { error: profileError } = await supabase
    .from("profiles")
    .update({
      full_name: fullName,
      role: roleValue,
      can_purchase: canPurchase,
      is_active: isActive,
    })
    .eq("id", profileId);

  if (profileError) done("failed");

  done("saved");
}
