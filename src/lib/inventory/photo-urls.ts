import "server-only";

import { thumbnailPath } from "@/lib/inventory/photos";
import { createClient } from "@/lib/supabase/server";

export type MaterialPhotoLink = {
  thumbUrl: string;
  fullUrl: string;
};

type PhotoRow = {
  material_id: number;
  storage_path: string;
  is_primary: boolean;
};

export async function photosForMaterials(
  materialIds: number[],
): Promise<Map<number, MaterialPhotoLink>> {
  const links = new Map<number, MaterialPhotoLink>();
  if (materialIds.length === 0) return links;

  const supabase = await createClient();
  const { data, error } = await supabase
    .from("material_photos")
    .select("material_id, storage_path, is_primary, created_at")
    .in("material_id", materialIds)
    .is("archived_at", null)
    .order("is_primary", { ascending: false })
    .order("created_at", { ascending: false });
  if (error || !data) return links;

  const chosen = new Map<number, string>();
  for (const row of data as PhotoRow[]) {
    if (!chosen.has(row.material_id))
      chosen.set(row.material_id, row.storage_path);
  }
  const fullPaths = [...chosen.values()];
  if (fullPaths.length === 0) return links;
  const thumbPaths = fullPaths.map(thumbnailPath);
  const bucket = supabase.storage.from("material-photos");
  const [fullSigned, thumbSigned] = await Promise.all([
    bucket.createSignedUrls(fullPaths, 60 * 60),
    bucket.createSignedUrls(thumbPaths, 60 * 60),
  ]);
  const fullByPath = new Map(
    (fullSigned.data ?? []).map((item) => [item.path, item.signedUrl]),
  );
  const thumbByPath = new Map(
    (thumbSigned.data ?? []).map((item) => [item.path, item.signedUrl]),
  );

  for (const [materialId, storagePath] of chosen) {
    const fullUrl = fullByPath.get(storagePath);
    if (!fullUrl) continue;
    links.set(materialId, {
      fullUrl,
      thumbUrl: thumbByPath.get(thumbnailPath(storagePath)) || fullUrl,
    });
  }
  return links;
}

export type GalleryPhoto = {
  id: number;
  storagePath: string;
  caption: string | null;
  isPrimary: boolean;
  thumbUrl: string;
  fullUrl: string;
};

export async function signedUsagePhotos(
  paths: string[],
): Promise<Map<string, MaterialPhotoLink>> {
  const links = new Map<string, MaterialPhotoLink>();
  const unique = [...new Set(paths.filter(Boolean))];
  if (unique.length === 0) return links;
  const supabase = await createClient();
  const bucket = supabase.storage.from("material-photos");
  const [fullSigned, thumbSigned] = await Promise.all([
    bucket.createSignedUrls(unique, 60 * 60),
    bucket.createSignedUrls(unique.map(thumbnailPath), 60 * 60),
  ]);
  const fullByPath = new Map(
    (fullSigned.data ?? []).map((item) => [item.path, item.signedUrl]),
  );
  const thumbByPath = new Map(
    (thumbSigned.data ?? []).map((item) => [item.path, item.signedUrl]),
  );
  for (const path of unique) {
    const fullUrl = fullByPath.get(path);
    if (!fullUrl) continue;
    links.set(path, {
      fullUrl,
      thumbUrl: thumbByPath.get(thumbnailPath(path)) || fullUrl,
    });
  }
  return links;
}

export async function galleryForMaterial(
  materialId: number,
): Promise<GalleryPhoto[]> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("material_photos")
    .select("id, storage_path, caption, is_primary")
    .eq("material_id", materialId)
    .is("archived_at", null)
    .order("is_primary", { ascending: false })
    .order("created_at", { ascending: false });
  if (error || !data || data.length === 0) return [];
  const rows = data as {
    id: number;
    storage_path: string;
    caption: string | null;
    is_primary: boolean;
  }[];
  const fullPaths = rows.map((row) => row.storage_path);
  const bucket = supabase.storage.from("material-photos");
  const [fullSigned, thumbSigned] = await Promise.all([
    bucket.createSignedUrls(fullPaths, 60 * 60),
    bucket.createSignedUrls(fullPaths.map(thumbnailPath), 60 * 60),
  ]);
  const fullByPath = new Map(
    (fullSigned.data ?? []).map((item) => [item.path, item.signedUrl]),
  );
  const thumbByPath = new Map(
    (thumbSigned.data ?? []).map((item) => [item.path, item.signedUrl]),
  );
  return rows.flatMap((row) => {
    const fullUrl = fullByPath.get(row.storage_path);
    if (!fullUrl) return [];
    return [
      {
        id: row.id,
        storagePath: row.storage_path,
        caption: row.caption,
        isPrimary: row.is_primary,
        fullUrl,
        thumbUrl: thumbByPath.get(thumbnailPath(row.storage_path)) || fullUrl,
      },
    ];
  });
}
