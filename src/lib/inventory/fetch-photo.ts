import "server-only";

import { lookup } from "node:dns/promises";
import { isBlockedAddress, isBlockedHost } from "@/lib/inventory/photo-import";

const MAX_BYTES = 15 * 1024 * 1024;

export async function fetchPhoto(
  sourceUrl: string,
): Promise<{ ok: true; bytes: Uint8Array } | { ok: false; reason: string }> {
  let url: URL;
  try {
    url = new URL(sourceUrl);
  } catch {
    return {
      ok: false,
      reason: "The source link must be a public https address.",
    };
  }
  if (isBlockedHost(url.hostname)) {
    return {
      ok: false,
      reason: "The source link must be a public https address.",
    };
  }
  try {
    const addresses = await lookup(url.hostname, { all: true });
    if (
      addresses.length === 0 ||
      addresses.some((item) => isBlockedAddress(item.address))
    ) {
      return {
        ok: false,
        reason: "The source link must be a public https address.",
      };
    }
  } catch {
    return { ok: false, reason: "The photo link did not answer." };
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 15_000);
  try {
    const response = await fetch(url, {
      redirect: "manual",
      signal: controller.signal,
      headers: { accept: "image/jpeg,image/png,image/webp" },
    });
    if (response.status >= 300 && response.status < 400) {
      return {
        ok: false,
        reason: "The photo link redirected, so it was skipped.",
      };
    }
    if (!response.ok) {
      return { ok: false, reason: "The photo link did not answer." };
    }
    const length = Number(response.headers.get("content-length") ?? "0");
    if (length > MAX_BYTES) {
      return { ok: false, reason: "The photo is too large to store." };
    }
    const bytes = new Uint8Array(await response.arrayBuffer());
    if (bytes.length > MAX_BYTES) {
      return { ok: false, reason: "The photo is too large to store." };
    }
    return { ok: true, bytes };
  } catch {
    return { ok: false, reason: "The photo link did not answer." };
  } finally {
    clearTimeout(timer);
  }
}
