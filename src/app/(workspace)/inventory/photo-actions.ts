"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { canEditInventory } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { isMaterialPhotoPath } from "@/lib/inventory/photos";
import { createClient } from "@/lib/supabase/server";

export async function registerMaterialPhoto(
  materialId: number,
  storagePath: string,
  replacePath: string | null,
): Promise<{ ok: true } | { ok: false; message: string }> {
  const state = await getSessionState();
  if (state.status !== "ready") {
    return { ok: false, message: "Sign in again, then take the photo." };
  }
  if (!canEditInventory(state.profile)) {
    return { ok: false, message: "You can view photos. Elaine adds them." };
  }
  if (
    !Number.isInteger(materialId) ||
    !isMaterialPhotoPath(materialId, storagePath)
  ) {
    return {
      ok: false,
      message: "That photo did not save. Try another picture.",
    };
  }

  const supabase = await createClient();
  const { count } = await supabase
    .from("material_photos")
    .select("id", { count: "exact", head: true })
    .eq("material_id", materialId)
    .is("archived_at", null);
  const { error } = await supabase.from("material_photos").insert({
    material_id: materialId,
    storage_path: storagePath,
    is_primary: (count ?? 0) === 0,
    taken_by: state.profile.id,
  });
  if (error) {
    return {
      ok: false,
      message: "That photo did not save. Try another picture.",
    };
  }

  if (replacePath) {
    await supabase
      .from("material_photos")
      .update({ archived_at: new Date().toISOString(), is_primary: false })
      .eq("material_id", materialId)
      .eq("storage_path", replacePath)
      .is("archived_at", null);
    await supabase
      .from("material_photos")
      .update({ is_primary: true })
      .eq("material_id", materialId)
      .eq("storage_path", storagePath);
  }

  revalidatePath("/inventory");
  return { ok: true };
}

export async function setPrimaryPhoto(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready" || !canEditInventory(state.profile)) return;
  const photoId = Number(String(formData.get("photoId") ?? ""));
  const materialCode = String(formData.get("materialCode") ?? "");
  const supabase = await createClient();
  await supabase
    .from("material_photos")
    .update({ is_primary: true })
    .eq("id", photoId);
  redirect(`/inventory/${encodeURIComponent(materialCode)}`);
}

export async function archivePhoto(formData: FormData) {
  const state = await getSessionState();
  if (state.status !== "ready" || !canEditInventory(state.profile)) return;
  const photoId = Number(String(formData.get("photoId") ?? ""));
  const materialCode = String(formData.get("materialCode") ?? "");
  const supabase = await createClient();
  await supabase
    .from("material_photos")
    .update({ archived_at: new Date().toISOString(), is_primary: false })
    .eq("id", photoId);
  redirect(`/inventory/${encodeURIComponent(materialCode)}`);
}
