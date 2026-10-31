"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { registerMaterialPhoto } from "@/app/(workspace)/inventory/photo-actions";
import {
  PHOTO_MAX_BYTES,
  PHOTO_MAX_EDGE,
  PHOTO_THUMB_EDGE,
  fitWithin,
} from "@/lib/inventory/photos";
import { createClient } from "@/lib/supabase/client";

async function canvasBlob(
  canvas: HTMLCanvasElement,
  type: string,
  quality: number,
): Promise<Blob | null> {
  return new Promise((resolve) =>
    canvas.toBlob((blob) => resolve(blob), type, quality),
  );
}

async function encoded(
  canvas: HTMLCanvasElement,
  maxBytes: number,
): Promise<Blob> {
  const types = ["image/webp", "image/jpeg"];
  for (const type of types) {
    let quality = 0.82;
    let blob = await canvasBlob(canvas, type, quality);
    if (!blob || !blob.type.startsWith("image/")) continue;
    while (blob.size > maxBytes && quality > 0.45) {
      quality -= 0.08;
      const smaller = await canvasBlob(canvas, type, quality);
      if (!smaller) break;
      blob = smaller;
    }
    if (blob.size <= maxBytes) return blob;
  }
  throw new Error("too-big");
}

async function draw(file: File, maxEdge: number): Promise<HTMLCanvasElement> {
  const bitmap = await createImageBitmap(file);
  const size = fitWithin(bitmap.width, bitmap.height, maxEdge);
  const canvas = document.createElement("canvas");
  canvas.width = size.width;
  canvas.height = size.height;
  const context = canvas.getContext("2d");
  if (!context) throw new Error("failed");
  context.drawImage(bitmap, 0, 0, size.width, size.height);
  bitmap.close();
  return canvas;
}

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
      const fullCanvas = await draw(file, PHOTO_MAX_EDGE);
      const thumbCanvas = await draw(file, PHOTO_THUMB_EDGE);
      const full = await encoded(fullCanvas, PHOTO_MAX_BYTES);
      const thumb = await encoded(thumbCanvas, 120 * 1024);
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
