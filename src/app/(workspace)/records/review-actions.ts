"use server";

import { redirect } from "next/navigation";
import { canEditInventory } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import {
  optionalText,
  reviewStatus,
  type FieldResult,
} from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

function bail(notice: string): never {
  redirect(`/review?notice=${notice}`);
}

function take<T>(result: FieldResult<T>): T {
  if (!result.ok) bail(result.notice);
  return result.value;
}

export async function saveReview(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canEditInventory(state.profile)) bail("denied");

  const id = Number(String(formData.get("id") ?? ""));
  if (!Number.isInteger(id)) bail("missing");
  const status = take(reviewStatus(formData.get("status")));
  const answer = take(optionalText(formData.get("answer"), 2000));
  const supabase = await createClient();
  const { error } = await supabase
    .from("review_items")
    .update({ status, resolution: answer })
    .eq("id", id);
  if (error) bail("failed");
  redirect("/review?notice=saved");
}
