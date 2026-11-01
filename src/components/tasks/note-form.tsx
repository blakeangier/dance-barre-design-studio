"use client";

import { useState, type FormEvent } from "react";
import { addTaskNote } from "@/app/(workspace)/tasks/actions";
import { compressPhotoFile } from "@/lib/inventory/compress-photo";
import {
  PHOTO_MAX_BYTES,
  PHOTO_MAX_EDGE,
  PHOTO_THUMB_EDGE,
} from "@/lib/inventory/photos";
import { createClient } from "@/lib/supabase/client";

function isNextRedirect(error: unknown): boolean {
  return (
    typeof error === "object" &&
    error !== null &&
    "digest" in error &&
    String((error as { digest?: string }).digest).startsWith("NEXT_REDIRECT")
  );
}

export function TaskNoteForm({ taskId }: { taskId: number }) {
  const [message, setMessage] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const data = new FormData(form);
    setBusy(true);
    setMessage(null);
    try {
      const file = data.get("photo");
      if (file instanceof File && file.size > 0) {
        const full = await compressPhotoFile(
          file,
          PHOTO_MAX_EDGE,
          PHOTO_MAX_BYTES,
        );
        const thumb = await compressPhotoFile(
          file,
          PHOTO_THUMB_EDGE,
          120 * 1024,
        );
        const ext = full.type === "image/webp" ? "webp" : "jpg";
        const id = crypto.randomUUID();
        const supabase = createClient();
        const {
          data: { user },
        } = await supabase.auth.getUser();
        if (!user) throw new Error("signed-out");
        const storagePath = `tasks/${user.id}/${id}.${ext}`;
        const thumbPath = `tasks/${user.id}/${id}-thumb.${ext}`;
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
        data.set("photoPath", storagePath);
      }
      data.delete("photo");
      await addTaskNote(data);
      form.reset();
    } catch (error) {
      if (isNextRedirect(error)) throw error;
      setMessage("That note did not save. Try again.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <form
      onSubmit={(event) => void onSubmit(event)}
      className="flex flex-col gap-2"
    >
      <input type="hidden" name="taskId" value={taskId} />
      <label className="text-sm font-medium" htmlFor="note-body">
        Note
      </label>
      <textarea
        id="note-body"
        name="body"
        required
        className="min-h-20 rounded-xl border border-line bg-card px-3 py-2"
      />
      <label className="inline-flex min-h-12 cursor-pointer items-center rounded-full border border-ink px-4 text-sm font-medium">
        Add a photo
        <input name="photo" type="file" accept="image/*" className="sr-only" />
      </label>
      <button
        type="submit"
        disabled={busy}
        className="min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white"
      >
        {busy ? "Saving…" : "Post note"}
      </button>
      {message ? <p className="text-sm text-ink">{message}</p> : null}
    </form>
  );
}
