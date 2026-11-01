import { createAdminClient } from "@/lib/supabase/admin";
import { siteUrl } from "@/lib/supabase/env";
import { thumbnailPath } from "@/lib/inventory/photos";
import {
  deliverLowStockDigest,
  type LowStockAlertLine,
} from "@/lib/inventory/low-stock-alert";

type AlertRow = {
  id: number;
  material_id: number;
  available_m: number | string;
  reorder_point_m: number | string;
};

type MaterialRow = {
  id: number;
  material_code: string;
  fabric_name: string | null;
  unit_kind: string | null;
};

function unitLabel(unit: string | null): string {
  if (unit === "units" || unit === "spools" || unit === "pieces") return unit;
  return "m";
}

function asNumber(value: number | string): number {
  const number = typeof value === "number" ? value : Number(value);
  return Number.isFinite(number) ? number : 0;
}

export async function GET(request: Request) {
  const cronSecret = process.env.CRON_SECRET;
  const header = request.headers.get("authorization");
  if (!cronSecret || header !== `Bearer ${cronSecret}`) {
    return Response.json({ ok: false }, { status: 401 });
  }

  const apiKey = process.env.RESEND_API_KEY;
  if (!apiKey?.trim()) {
    console.info("RESEND_API_KEY is not set. Low-stock alerts stay pending.");
    return Response.json({ ok: true, sent: false, reason: "missing-key" });
  }

  const admin = createAdminClient();
  const { data: settings, error: settingsError } = await admin
    .from("inventory_settings")
    .select("low_stock_alert_to, low_stock_alert_from")
    .eq("id", true)
    .maybeSingle();
  if (settingsError || !settings) {
    console.error("Low-stock digest could not read the recipient.");
    return Response.json({ ok: false }, { status: 500 });
  }

  const { data: pending, error: pendingError } = await admin
    .from("low_stock_alerts")
    .select("id, material_id, available_m, reorder_point_m")
    .eq("status", "pending")
    .order("created_at");
  if (pendingError) {
    console.error("Low-stock digest could not read pending alerts.");
    return Response.json({ ok: false }, { status: 500 });
  }
  const alerts = (pending ?? []) as AlertRow[];
  if (alerts.length === 0) {
    return Response.json({ ok: true, sent: false, reason: "empty" });
  }

  const materialIds = [...new Set(alerts.map((alert) => alert.material_id))];
  const [{ data: materials }, { data: photos }] = await Promise.all([
    admin
      .from("materials")
      .select("id, material_code, fabric_name, unit_kind")
      .in("id", materialIds),
    admin
      .from("material_photos")
      .select("material_id, storage_path, is_primary")
      .in("material_id", materialIds)
      .is("archived_at", null)
      .order("is_primary", { ascending: false })
      .order("created_at", { ascending: false }),
  ]);
  const materialById = new Map(
    ((materials ?? []) as MaterialRow[]).map((material) => [
      material.id,
      material,
    ]),
  );
  const photoByMaterial = new Map<number, string>();
  for (const photo of (photos ?? []) as {
    material_id: number;
    storage_path: string;
  }[]) {
    if (!photoByMaterial.has(photo.material_id)) {
      photoByMaterial.set(photo.material_id, photo.storage_path);
    }
  }
  const thumbByPath = new Map<string, string>();
  const paths = [...photoByMaterial.values()];
  if (paths.length > 0) {
    const signed = await admin.storage
      .from("material-photos")
      .createSignedUrls(paths.map(thumbnailPath), 60 * 60 * 24 * 7);
    for (const item of signed.data ?? []) {
      if (item.path && item.signedUrl)
        thumbByPath.set(item.path, item.signedUrl);
    }
  }

  const lines: LowStockAlertLine[] = alerts.flatMap((alert) => {
    const material = materialById.get(alert.material_id);
    if (!material) return [];
    const photoPath = photoByMaterial.get(alert.material_id);
    const thumbPath = photoPath ? thumbnailPath(photoPath) : null;
    return [
      {
        materialCode: material.material_code,
        fabricName: material.fabric_name,
        availableM: asNumber(alert.available_m),
        reorderPointM: asNumber(alert.reorder_point_m),
        pageUrl: `${siteUrl()}/inventory/${encodeURIComponent(material.material_code)}`,
        thumbUrl: thumbPath ? (thumbByPath.get(thumbPath) ?? null) : null,
        unit: unitLabel(material.unit_kind),
      },
    ];
  });

  const result = await deliverLowStockDigest({
    apiKey,
    from: settings.low_stock_alert_from,
    to: settings.low_stock_alert_to,
    lines,
  });
  if (result !== "sent") {
    console.error("Low-stock digest was not sent.");
    return Response.json({ ok: true, sent: false, reason: result });
  }

  const sentAt = new Date().toISOString();
  const { error: updateError } = await admin
    .from("low_stock_alerts")
    .update({ status: "sent", sent_at: sentAt })
    .in(
      "id",
      alerts.map((alert) => alert.id),
    )
    .eq("status", "pending");
  if (updateError) {
    console.error("Low-stock digest was sent, but the rows stayed pending.");
  }
  return Response.json({ ok: true, sent: true, count: lines.length });
}
