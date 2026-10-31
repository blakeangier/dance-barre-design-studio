"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { registerMaterialPhoto } from "@/app/(workspace)/inventory/photo-actions";
import { compressPhotoFile } from "@/lib/inventory/compress-photo";
import {
  PHOTO_MAX_BYTES,
  PHOTO_MAX_EDGE,
  PHOTO_THUMB_EDGE,
} from "@/lib/inventory/photos";
import { createClient } from "@/lib/supabase/client";

export function AddPhoto({
  materialId,
  replacePath,
}: {
  materialId: number;
  replacePath?: string;
}) {
  const router = useRouter();
  const [message, setMessage] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function onFile(file: File | undefined) {
    if (!file) return;
    setBusy(true);
    setMessage(null);
    try {
      const full = await compressPhotoFile(
        file,
        PHOTO_MAX_EDGE,
        PHOTO_MAX_BYTES,
      );
      const thumb = await compressPhotoFile(file, PHOTO_THUMB_EDGE, 120 * 1024);
      const ext = full.type === "image/webp" ? "webp" : "jpg";
      const id = crypto.randomUUID();
      const storagePath = `${materialId}/${id}.${ext}`;
      const thumbPath = `${materialId}/${id}-thumb.${ext}`;
      const supabase = createClient();
      const bucket = supabase.storage.from("material-photos");
      const uploaded = await bucket.upload(storagePath, full, {
        contentType: full.type,
        upsert: false,
      });
      if (uploaded.error) throw new Error("upload");
      const thumbUploaded = await bucket.upload(thumbPath, thumb, {
        contentType: thumb.type,
        upsert: false,
      });
      if (thumbUploaded.error) throw new Error("upload");
      const result = await registerMaterialPhoto(
        materialId,
        storagePath,
        replacePath ?? null,
      );
      if (!result.ok) setMessage(result.message);
      else router.refresh();
    } catch {
      setMessage("That photo did not save. Try another picture.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="flex flex-col gap-2">
      <label className="inline-flex min-h-12 cursor-pointer items-center justify-center rounded-full bg-ink px-4 text-sm font-medium text-white">
        {replacePath ? "Replace photo" : "Add photo"}
        <input
          type="file"
          accept="image/*"
          capture="environment"
          className="sr-only"
          disabled={busy}
          onChange={(event) => {
            const file = event.target.files?.[0];
            event.target.value = "";
            void onFile(file);
          }}
        />
      </label>
      <label className="inline-flex min-h-12 cursor-pointer items-center justify-center rounded-full border border-ink px-4 text-sm font-medium text-ink">
        Choose from gallery
        <input
          type="file"
          accept="image/*"
          className="sr-only"
          disabled={busy}
          onChange={(event) => {
            const file = event.target.files?.[0];
            event.target.value = "";
            void onFile(file);
          }}
        />
      </label>
      {busy ? <p className="text-sm text-muted">Saving the photo…</p> : null}
      {message ? <p className="text-sm text-ink">{message}</p> : null}
    </div>
  );
}
