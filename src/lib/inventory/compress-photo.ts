import { fitWithin } from "@/lib/inventory/photos";

function canvasBlob(
  canvas: HTMLCanvasElement,
  type: string,
  quality: number,
): Promise<Blob | null> {
  return new Promise((resolve) =>
    canvas.toBlob((blob) => resolve(blob), type, quality),
  );
}

export async function compressPhotoFile(
  file: File,
  maxEdge: number,
  maxBytes: number,
): Promise<Blob> {
  const bitmap = await createImageBitmap(file);
  const size = fitWithin(bitmap.width, bitmap.height, maxEdge);
  const canvas = document.createElement("canvas");
  canvas.width = size.width;
  canvas.height = size.height;
  const context = canvas.getContext("2d");
  if (!context) throw new Error("failed");
  context.drawImage(bitmap, 0, 0, size.width, size.height);
  bitmap.close();

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
