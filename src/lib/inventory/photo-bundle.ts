import "server-only";

import { unzipSync } from "fflate";
import {
  PHOTO_IMPORT_LIMIT,
  type ManifestRow,
  parsePhotoManifest,
  type ManifestParse,
} from "@/lib/inventory/photo-import";

export type BundleFile = { name: string; bytes: Uint8Array };

const INPUT_BYTE_LIMIT = 15 * 1024 * 1024;

export async function readPhotoBundle(formData: FormData): Promise<
  | {
      ok: true;
      files: BundleFile[];
      manifest: ManifestParse | null;
      links: ManifestRow[];
    }
  | { ok: false; message: string }
> {
  const uploaded = formData
    .getAll("images")
    .filter((value): value is File => value instanceof File && value.size > 0);
  const archive = formData.get("archive");
  const manifestFile = formData.get("manifest");
  const files: BundleFile[] = [];

  for (const file of uploaded) {
    if (file.size > INPUT_BYTE_LIMIT) {
      return { ok: false, message: `${file.name} is larger than 15 MB.` };
    }
    files.push({
      name: file.name,
      bytes: new Uint8Array(await file.arrayBuffer()),
    });
  }

  if (archive instanceof File && archive.size > 0) {
    if (archive.size > INPUT_BYTE_LIMIT) {
      return { ok: false, message: "The zip is larger than 15 MB." };
    }
    if (!archive.name.toLowerCase().endsWith(".zip")) {
      return { ok: false, message: "The archive must be a .zip file." };
    }
    let unzipped: Record<string, Uint8Array>;
    try {
      unzipped = unzipSync(new Uint8Array(await archive.arrayBuffer()));
    } catch {
      return { ok: false, message: "That zip could not be opened." };
    }
    for (const [path, bytes] of Object.entries(unzipped)) {
      if (
        !path ||
        path.endsWith("/") ||
        path.includes("__MACOSX") ||
        path.endsWith(".DS_Store")
      ) {
        continue;
      }
      if (bytes.length > INPUT_BYTE_LIMIT) {
        return { ok: false, message: `${path} is larger than 15 MB.` };
      }
      files.push({ name: path, bytes });
    }
  }

  let manifest: ManifestParse | null = null;
  if (manifestFile instanceof File && manifestFile.size > 0) {
    manifest = parsePhotoManifest(await manifestFile.text(), manifestFile.name);
  } else {
    const packed = files.find((file) =>
      /(?:^|\/)manifest\.(json|csv)$/i.test(file.name),
    );
    if (packed) {
      manifest = parsePhotoManifest(
        new TextDecoder().decode(packed.bytes),
        packed.name,
      );
    }
  }
  if (manifest && !manifest.ok) return manifest;

  const links = linkRows(formData, manifest?.ok ? manifest.rows.length : 0);
  const rows = [...(manifest?.ok ? manifest.rows : []), ...links];
  if (rows.length === 0) {
    return {
      ok: false,
      message: "Add a manifest, or a photo link, before previewing.",
    };
  }
  if (rows.length > PHOTO_IMPORT_LIMIT) {
    return {
      ok: false,
      message: `Import up to ${PHOTO_IMPORT_LIMIT} photos at a time.`,
    };
  }
  return { ok: true, files, manifest, links };
}

function linkRows(formData: FormData, start: number): ManifestRow[] {
  const materials = formData.getAll("linkMaterial").map(String);
  const captions = formData.getAll("linkCaption").map(String);
  const sources = formData.getAll("linkSourceUrl").map(String);
  const rows: ManifestRow[] = [];
  for (let index = 0; index < materials.length; index += 1) {
    const material = materials[index]?.trim() ?? "";
    const sourceUrl = sources[index]?.trim() ?? "";
    const caption = captions[index]?.trim() ?? "";
    if (!material && !sourceUrl && !caption) continue;
    rows.push({
      row: start + rows.length + 1,
      file: null,
      material: material || null,
      caption: caption || null,
      sourceUrl: sourceUrl || null,
    });
  }
  return rows;
}
