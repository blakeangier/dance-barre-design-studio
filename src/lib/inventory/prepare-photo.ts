import "server-only";

import sharp from "sharp";
import {
  PHOTO_MAX_BYTES,
  PHOTO_MAX_EDGE,
  PHOTO_THUMB_EDGE,
} from "@/lib/inventory/photos";

const THUMB_MAX_BYTES = 120 * 1024;

export async function prepareMaterialPhoto(input: Uint8Array): Promise<{
  full: Buffer;
  thumb: Buffer;
}> {
  const full = await encode(input, PHOTO_MAX_EDGE, PHOTO_MAX_BYTES);
  const thumb = await encode(input, PHOTO_THUMB_EDGE, THUMB_MAX_BYTES);
  return { full, thumb };
}

export async function previewThumb(input: Uint8Array): Promise<string | null> {
  try {
    const thumb = await sharp(input, { failOn: "error" })
      .rotate()
      .resize({
        width: 160,
        height: 160,
        fit: "cover",
      })
      .jpeg({ quality: 60 })
      .toBuffer();
    return `data:image/jpeg;base64,${thumb.toString("base64")}`;
  } catch {
    return null;
  }
}

async function encode(
  input: Uint8Array,
  edge: number,
  maxBytes: number,
): Promise<Buffer> {
  let quality = 82;
  let encoded = await render(input, edge, quality);
  while (encoded.length > maxBytes && quality > 45) {
    quality -= 8;
    encoded = await render(input, edge, quality);
  }
  if (encoded.length > maxBytes || encoded.length > 1024 * 1024) {
    throw new Error("too-big");
  }
  return encoded;
}

function render(input: Uint8Array, edge: number, quality: number) {
  return sharp(input, { failOn: "error" })
    .rotate()
    .resize({
      width: edge,
      height: edge,
      fit: "inside",
      withoutEnlargement: true,
    })
    .webp({ quality })
    .toBuffer();
}
