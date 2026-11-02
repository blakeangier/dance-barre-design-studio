import "server-only";

import { cache } from "react";
import { redirect } from "next/navigation";
import {
  canAccessArea,
  isAppRole,
  type AccessProfile,
  type AppRole,
  type AreaId,
} from "@/lib/auth/permissions";
import { hasPublicSupabaseEnv } from "@/lib/supabase/env";
import { createClient } from "@/lib/supabase/server";

export type CurrentProfile = AccessProfile & {
  id: string;
  email: string;
  fullName: string;
  phone: string | null;
  pronouns: string | null;
  jobTitle: string | null;
  role: AppRole;
};

export type SessionState =
  | { status: "unconfigured" }
  | { status: "anonymous" }
  | { status: "inactive" }
  | { status: "missing-profile" }
  | { status: "database-error" }
  | { status: "ready"; profile: CurrentProfile };

// Read once per request. Not cached across requests: a role change should
// apply the next time someone opens a page.
export const getSessionState = cache(async (): Promise<SessionState> => {
  if (!hasPublicSupabaseEnv()) return { status: "unconfigured" };

  const supabase = await createClient();
  const { data, error } = await supabase.auth.getClaims();

  if (error || !data?.claims.sub) return { status: "anonymous" };

  const userId = data.claims.sub;
  const [profileResult, contactResult] = await Promise.all([
    supabase
      .from("profiles")
      .select(
        "id, full_name, role, can_purchase, can_update_order_status, can_edit_schedule, is_active, pronouns, job_title",
      )
      .eq("id", userId)
      .maybeSingle(),
    supabase
      .from("profile_contacts")
      .select("email, phone")
      .eq("profile_id", userId)
      .maybeSingle(),
  ]);

  if (profileResult.error || contactResult.error) {
    console.error("Profile lookup failed");
    return { status: "database-error" };
  }

  const row = profileResult.data;
  if (!row || !isAppRole(row.role) || !contactResult.data?.email) {
    return { status: "missing-profile" };
  }
  if (!row.is_active) return { status: "inactive" };

  return {
    status: "ready",
    profile: {
      id: row.id,
      email: contactResult.data.email,
      fullName: row.full_name,
      phone: contactResult.data.phone,
      pronouns: row.pronouns,
      jobTitle: row.job_title,
      role: row.role,
      canPurchase: row.can_purchase,
      canUpdateOrderStatus: row.can_update_order_status,
      canEditSchedule: row.can_edit_schedule,
    },
  };
});

export async function gateArea(area: AreaId): Promise<
  | { ok: true; profile: CurrentProfile }
  | {
      ok: false;
      reason: Exclude<SessionState["status"], "anonymous" | "ready"> | "denied";
    }
> {
  const state = await getSessionState();

  if (state.status === "anonymous") redirect("/login");
  if (state.status !== "ready") return { ok: false, reason: state.status };
  if (!canAccessArea(state.profile, area))
    return { ok: false, reason: "denied" };

  return { ok: true, profile: state.profile };
}
