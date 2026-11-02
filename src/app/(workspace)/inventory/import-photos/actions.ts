"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { randomUUID } from "node:crypto";
import { canBulkImportPhotos } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { fetchPhoto } from "@/lib/inventory/fetch-photo";
import { readPhotoBundle } from "@/lib/inventory/photo-bundle";
import {
  planPhotoImport,
  sniffImageType,
  type KnownMaterial,
  type ManifestRow,
  type PlannedImport,
} from "@/lib/inventory/photo-import";
import {
  prepareMaterialPhoto,
  previewThumb,
} from "@/lib/inventory/prepare-photo";
import { thumbnailPath } from "@/lib/inventory/photos";
import { createAdminClient } from "@/lib/supabase/admin";
import { createClient } from "@/lib/supabase/server";

export type ImportPreviewRow = {
  label: string;
  materialCode: string | null;
  materialName: string | null;
  colour: string | null;
  status: "import" | "skip";
  reason: string | null;
  willBePrimary: boolean;
  thumb: string | null;
};

export type ImportPreview =
  { ok: true; rows: ImportPreviewRow[] } | { ok: false; message: string };

export type ImportReport =
  | {
      ok: true;
      imported: number;
      skipped: { label: string; reason: string }[];
    }
  | { ok: false; message: string };

type MaterialRow = {
  id: number;
  material_code: string;
  fabric_name: string | null;
  colour_name: string | null;
  archived_at: string | null;
};

type PhotoRow = {
  material_id: number;
  is_primary: boolean;
  caption: string | null;
};

export async function previewPhotoImport(
  formData: FormData,
): Promise<ImportPreview> {
  const profile = await owner();
  if (!profile)
    return { ok: false, message: "Only an owner can import photos." };
  const prepared = await prepareRows(formData);
  if (!prepared.ok) return prepared;
  const rows: ImportPreviewRow[] = [];
  for (const row of prepared.rows) {
    let thumb: string | null = null;
    if (row.status === "import") {
      const loaded = await loadBytes(row, prepared.files);
      if (!loaded.ok) {
        rows.push(view(row, null, loaded.reason));
        continue;
      }
      thumb = await previewThumb(loaded.bytes);
    }
    rows.push(view(row, thumb, null));
  }
  return { ok: true, rows: replan(rows, prepared.materials) };
}

export async function importMaterialPhotos(
  formData: FormData,
): Promise<ImportReport> {
  const profile = await owner();
  if (!profile)
    return { ok: false, message: "Only an owner can import photos." };
  const prepared = await prepareRows(formData);
  if (!prepared.ok) return prepared;

  const supabase = await createClient();
  const bucket = await storageBucket();
  let imported = 0;
  const skipped: { label: string; reason: string }[] = [];
  const claimedPrimary = new Set<number>();

  for (const row of prepared.rows) {
    if (row.status !== "import" || row.materialId == null) {
      skipped.push({
        label: row.label,
        reason: row.reason ?? "Skipped.",
      });
      continue;
    }
    const loaded = await loadBytes(row, prepared.files);
    if (!loaded.ok) {
      skipped.push({ label: row.label, reason: loaded.reason });
      continue;
    }
    let stored: { full: Buffer; thumb: Buffer };
    try {
      stored = await prepareMaterialPhoto(loaded.bytes);
    } catch {
      skipped.push({
        label: row.label,
        reason: "The photo is too large to store.",
      });
      continue;
    }
    const storagePath = `${row.materialId}/${randomUUID()}.webp`;
    const thumbPath = thumbnailPath(storagePath);
    const fullUpload = await bucket.upload(storagePath, stored.full, {
      contentType: "image/webp",
      upsert: false,
    });
    if (fullUpload.error) {
      skipped.push({
        label: row.label,
        reason: "That photo did not save. Try it again.",
      });
      continue;
    }
    const thumbUpload = await bucket.upload(thumbPath, stored.thumb, {
      contentType: "image/webp",
      upsert: false,
    });
    if (thumbUpload.error) {
      await bucket.remove([storagePath]);
      skipped.push({
        label: row.label,
        reason: "That photo did not save. Try it again.",
      });
      continue;
    }

    const { count } = await supabase
      .from("material_photos")
      .select("id", { count: "exact", head: true })
      .eq("material_id", row.materialId)
      .eq("is_primary", true)
      .is("archived_at", null);
    const isPrimary =
      row.willBePrimary &&
      (count ?? 0) === 0 &&
      !claimedPrimary.has(row.materialId);
    const { error } = await supabase.from("material_photos").insert({
      material_id: row.materialId,
      storage_path: storagePath,
      is_primary: isPrimary,
      caption: row.caption,
      taken_by: profile.id,
    });
    if (error) {
      await bucket.remove([storagePath, thumbPath]);
      skipped.push({
        label: row.label,
        reason: "That photo did not save. Try it again.",
      });
      continue;
    }
    if (isPrimary) claimedPrimary.add(row.materialId);
    imported += 1;
  }

  revalidatePath("/inventory");
  return { ok: true, imported, skipped };
}

// The secret key stays on the server. When it is unset, the upload still
// happens here, with the signed-in owner's session. The browser never
// receives a key and never talks to the bucket.
async function storageBucket() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key =
    process.env.SUPABASE_SECRET_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (url && key) return createAdminClient().storage.from("material-photos");
  const supabase = await createClient();
  return supabase.storage.from("material-photos");
}

async function owner() {
  const state = await getSessionState();
  if (state.status !== "ready") redirect("/login");
  if (!canBulkImportPhotos(state.profile)) return null;
  return state.profile;
}

async function prepareRows(formData: FormData): Promise<
  | {
      ok: true;
      rows: PlannedImport[];
      files: { name: string; bytes: Uint8Array }[];
      materials: KnownMaterial[];
    }
  | { ok: false; message: string }
> {
  const bundle = await readPhotoBundle(formData);
  if (!bundle.ok) return bundle;
  const manifestRows: ManifestRow[] = [
    ...(bundle.manifest?.ok ? bundle.manifest.rows : []),
    ...bundle.links,
  ];
  const supabase = await createClient();
  const [materialsResult, photosResult] = await Promise.all([
    supabase
      .from("materials")
      .select("id, material_code, fabric_name, colour_name, archived_at"),
    supabase
      .from("material_photos")
      .select("material_id, is_primary, caption")
      .is("archived_at", null),
  ]);
  if (materialsResult.error || photosResult.error) {
    return { ok: false, message: "The material list did not load." };
  }
  const materials = knownMaterials(
    (materialsResult.data ?? []) as MaterialRow[],
    (photosResult.data ?? []) as PhotoRow[],
  );
  const byteErrors = new Map<number, string>();
  const firstPass = planPhotoImport({
    rows: manifestRows,
    availableFiles: bundle.files.map((file) => file.name),
    materials,
  });
  for (const row of firstPass) {
    if (row.status !== "import") continue;
    const loaded = await loadBytes(row, bundle.files);
    if (!loaded.ok) byteErrors.set(row.row, loaded.reason);
  }
  const rows = planPhotoImport({
    rows: manifestRows,
    availableFiles: bundle.files.map((file) => file.name),
    materials,
    byteErrors,
  });
  return { ok: true, rows, files: bundle.files, materials };
}

function knownMaterials(
  materials: MaterialRow[],
  photos: PhotoRow[],
): KnownMaterial[] {
  const captions = new Map<number, string[]>();
  const primary = new Set<number>();
  for (const photo of photos) {
    if (photo.caption) {
      const list = captions.get(photo.material_id) ?? [];
      list.push(photo.caption);
      captions.set(photo.material_id, list);
    }
    if (photo.is_primary) primary.add(photo.material_id);
  }
  return materials.map((material) => ({
    id: material.id,
    code: material.material_code,
    name: material.fabric_name,
    colour: material.colour_name,
    archived: material.archived_at != null,
    hasPrimary: primary.has(material.id),
    captions: captions.get(material.id) ?? [],
  }));
}

async function loadBytes(
  row: PlannedImport,
  files: { name: string; bytes: Uint8Array }[],
): Promise<{ ok: true; bytes: Uint8Array } | { ok: false; reason: string }> {
  if (row.fileName) {
    const wanted = basename(row.fileName).toLowerCase();
    const file = files.find(
      (item) => basename(item.name).toLowerCase() === wanted,
    );
    if (!file) {
      return {
        ok: false,
        reason: `Image file ${basename(row.fileName)} was not in the upload.`,
      };
    }
    if (!sniffImageType(file.bytes)) {
      return {
        ok: false,
        reason: "That file is not a JPEG, PNG, or WebP.",
      };
    }
    return { ok: true, bytes: file.bytes };
  }
  if (!row.sourceUrl) {
    return { ok: false, reason: "No image file or link." };
  }
  return fetchPhoto(row.sourceUrl);
}

function view(
  row: PlannedImport,
  thumb: string | null,
  reason: string | null,
): ImportPreviewRow {
  return {
    label: row.label,
    materialCode: row.materialCode,
    materialName: row.materialName,
    colour: row.colour,
    status: reason ? "skip" : row.status,
    reason: reason ?? row.reason,
    willBePrimary: reason ? false : row.willBePrimary,
    thumb,
  };
}

function replan(
  rows: ImportPreviewRow[],
  materials: KnownMaterial[],
): ImportPreviewRow[] {
  const byCode = new Map(
    materials.map((material) => [material.code, material]),
  );
  const gaining = new Set<number>();
  return rows.map((row) => {
    if (row.status !== "import" || !row.materialCode) {
      return { ...row, willBePrimary: false };
    }
    const material = byCode.get(row.materialCode);
    if (!material) return { ...row, willBePrimary: false };
    const taken = material.hasPrimary || gaining.has(material.id);
    if (!taken) gaining.add(material.id);
    return { ...row, willBePrimary: !taken };
  });
}

function basename(fileName: string): string {
  const parts = fileName.split(/[/\\]/);
  return parts[parts.length - 1] ?? fileName;
}
