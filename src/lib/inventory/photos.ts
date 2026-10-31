export const PHOTO_MAX_EDGE = 1600;
export const PHOTO_THUMB_EDGE = 320;
export const PHOTO_MAX_BYTES = 500 * 1024;

export function fitWithin(
  width: number,
  height: number,
  maxEdge: number,
): { width: number; height: number } {
  const longest = Math.max(width, height);
  const scale = longest > maxEdge ? maxEdge / longest : 1;
  return {
    width: Math.max(1, Math.round(width * scale)),
    height: Math.max(1, Math.round(height * scale)),
  };
}

export function thumbnailPath(storagePath: string): string {
  return storagePath.replace(/(\.[a-z0-9]+)$/i, "-thumb$1");
}

export function isMaterialPhotoPath(
  materialId: number,
  storagePath: string,
): boolean {
  return new RegExp(
    `^${materialId}/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\\.(webp|jpe?g)$`,
    "i",
  ).test(storagePath);
}
