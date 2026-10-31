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

const USAGE_PHOTO = /^usage\/([0-9a-f-]{36})\/([0-9a-f-]{36})\.(webp|jpe?g)$/i;
const TASK_PHOTO = /^tasks\/([0-9a-f-]{36})\/([0-9a-f-]{36})\.(webp|jpe?g)$/i;

export function isTaskPhotoPath(userId: string, storagePath: string): boolean {
  const match = TASK_PHOTO.exec(storagePath);
  if (!match?.[1] || !match[2]) return false;
  return match[1].toLowerCase() === userId.toLowerCase();
}

export function isUsagePhotoPath(userId: string, storagePath: string): boolean {
  const match = USAGE_PHOTO.exec(storagePath);
  if (!match?.[1] || !match[2]) return false;
  return match[1].toLowerCase() === userId.toLowerCase();
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
