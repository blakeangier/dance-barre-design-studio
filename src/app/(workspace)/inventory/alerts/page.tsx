import Link from "next/link";
import { Suspense } from "react";
import { saveLowStockMail } from "@/app/(workspace)/inventory/alert-actions";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory } from "@/lib/auth/permissions";
import { gateArea } from "@/lib/auth/session";
import { firstQueryValue } from "@/lib/auth/notices";
import { metres } from "@/lib/inventory/format";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Low-stock alerts" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

const NOTICES: Record<string, { tone: "ok" | "error"; text: string }> = {
  saved: { tone: "ok", text: "Alert mail settings saved." },
  email: { tone: "error", text: "Enter the inbox as a plain email address." },
  from: {
    tone: "error",
    text: "Enter a from address, such as Name <mail@yourdomain.com>.",
  },
  failed: { tone: "error", text: "Those settings did not save." },
};

type AlertRow = {
  id: number;
  available_m: number | string;
  reorder_point_m: number | string;
  created_at: string;
  sent_at: string | null;
  status: string;
  materials:
    | { material_code: string; fabric_name: string | null }
    | { material_code: string; fabric_name: string | null }[]
    | null;
};

function materialOf(row: AlertRow): {
  material_code: string;
  fabric_name: string | null;
} | null {
  if (!row.materials) return null;
  return Array.isArray(row.materials)
    ? (row.materials[0] ?? null)
    : row.materials;
}

function when(value: string): string {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "America/Toronto",
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(value));
}

export default function AlertsPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <AlertsScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function AlertsScreen({ searchParams }: PageProps) {
  const gate = await gateArea("inventory");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  if (!canEditInventory(gate.profile)) return <NoAccess reason="denied" />;

  const notice = NOTICES[firstQueryValue((await searchParams).notice) ?? ""];
  const supabase = await createClient();
  const [alertsResult, settingsResult] = await Promise.all([
    supabase
      .from("low_stock_alerts")
      .select(
        "id, available_m, reorder_point_m, created_at, sent_at, status, materials(material_code, fabric_name)",
      )
      .order("created_at", { ascending: false })
      .limit(40),
    supabase
      .from("inventory_settings")
      .select("low_stock_alert_to, low_stock_alert_from")
      .eq("id", true)
      .maybeSingle(),
  ]);

  if (alertsResult.error) {
    return (
      <section className="mx-auto w-full max-w-lg">
        <h1 className="font-serif text-3xl text-ink">Low-stock alerts</h1>
        <p className="mt-2 text-sm text-muted">
          This list appears after the low-stock migration is applied.
        </p>
      </section>
    );
  }

  const alerts = (alertsResult.data ?? []) as AlertRow[];
  const settings = settingsResult.data as {
    low_stock_alert_to: string;
    low_stock_alert_from: string;
  } | null;

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <div>
        <Link href="/inventory" className="text-sm text-muted">
          Inventory
        </Link>
        <h1 className="mt-1 font-serif text-3xl text-ink">Low-stock alerts</h1>
        <p className="mt-2 text-sm text-muted">
          One alert is queued when available metres cross the reorder point.
          Pending alerts go out together as one email. There are no prices in
          that email.
        </p>
      </div>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      {settings ? (
        <form
          action={saveLowStockMail}
          className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
        >
          <label className="text-sm font-medium" htmlFor="alertTo">
            Send the digest to
          </label>
          <input
            id="alertTo"
            name="alertTo"
            type="email"
            required
            defaultValue={settings.low_stock_alert_to}
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <label className="text-sm font-medium" htmlFor="alertFrom">
            From address
          </label>
          <input
            id="alertFrom"
            name="alertFrom"
            required
            defaultValue={settings.low_stock_alert_from}
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <p className="text-sm text-muted">
            Dev mail can use Resend&apos;s onboarding sender,
            onboarding@resend.dev. A verified domain in Resend is required
            before production mail leaves that sender.
          </p>
          <button
            type="submit"
            className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
          >
            Save mail settings
          </button>
        </form>
      ) : null}
      {alerts.length === 0 ? (
        <p className="text-sm text-muted">No low-stock alerts yet.</p>
      ) : (
        <ul className="flex flex-col gap-3">
          {alerts.map((alert) => {
            const material = materialOf(alert);
            return (
              <li
                key={alert.id}
                className="rounded-2xl border border-line bg-card p-4 text-sm"
              >
                <p className="font-medium text-ink">
                  {material ? (
                    <Link
                      href={`/inventory/${encodeURIComponent(material.material_code)}`}
                    >
                      {material.material_code}
                    </Link>
                  ) : (
                    "Fabric"
                  )}
                  {material?.fabric_name ? ` · ${material.fabric_name}` : ""}
                </p>
                <p className="text-muted">
                  Available {metres(alert.available_m)} · Reorder point{" "}
                  {metres(alert.reorder_point_m)}
                </p>
                <p className="text-muted">
                  {alert.status === "sent" ? "Sent" : "Pending"} ·{" "}
                  {when(alert.sent_at ?? alert.created_at)}
                </p>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
