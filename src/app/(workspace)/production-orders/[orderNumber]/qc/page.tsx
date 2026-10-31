import Link from "next/link";
import { Suspense } from "react";
import {
  overrideQc,
  resolveQcCheck,
  saveQcCheck,
} from "@/app/(workspace)/records/production-actions";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { qcBlocksPickup } from "@/lib/production/qc";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Quality check" };

type PageProps = {
  params: Promise<{ orderNumber: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function QcPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <QcScreen params={props.params} searchParams={props.searchParams} />
    </Suspense>
  );
}

async function QcScreen({ params, searchParams }: PageProps) {
  const gate = await gateArea("production-orders");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const orderNumber = decodeURIComponent((await params).orderNumber);
  const notice = firstQueryValue((await searchParams).notice);
  const editor = canEditInventory(gate.profile);
  const owner = gate.profile.role === "owner";
  const supabase = await createClient();
  const { data: order } = await supabase
    .from("costume_orders")
    .select("id")
    .eq("order_number", orderNumber)
    .maybeSingle();
  if (!order) return <h1 className="font-serif text-3xl">Order not found</h1>;
  const [
    templateResult,
    checksResult,
    gatesResult,
    importedResult,
    overrideResult,
  ] = await Promise.all([
    supabase
      .from("qc_template_items")
      .select("id, item_name, sort_order")
      .is("archived_at", null)
      .order("sort_order"),
    supabase
      .from("qc_checks")
      .select("id, item_name, result, note, size_code, resolved_at, checked_at")
      .eq("order_id", order.id)
      .is("archived_at", null)
      .order("checked_at", { ascending: false }),
    supabase
      .from("production_gates")
      .select("gate_name, target_raw, status_raw")
      .eq("order_id", order.id),
    supabase
      .from("fitting_checks")
      .select("check_name, completed_text, notes")
      .eq("order_id", order.id),
    supabase.from("qc_overrides").select("id, reason").eq("order_id", order.id),
  ]);
  const template = (templateResult.data ?? []) as {
    id: number;
    item_name: string;
  }[];
  const checks = (checksResult.data ?? []) as {
    id: number;
    item_name: string;
    result: "pass" | "needs_fix" | "fail";
    note: string | null;
    size_code: string | null;
    resolved_at: string | null;
  }[];
  const blocked = qcBlocksPickup({
    templateNames: template.map((item) => item.item_name),
    checks: checks
      .filter((check) => !check.size_code)
      .map((check) => ({
        itemName: check.item_name,
        result: check.result,
        resolved: Boolean(check.resolved_at),
      })),
    hasOverride: (overrideResult.data ?? []).length > 0,
  });

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link
        href={`/production-orders/${encodeURIComponent(orderNumber)}`}
        className="text-sm text-muted"
      >
        {orderNumber}
      </Link>
      <h1 className="font-serif text-3xl text-ink">Quality check</h1>
      <p className="text-sm text-ink">
        {blocked
          ? "Pickup stays locked until every order-level check passes or open rework is resolved."
          : "Quality check is clear for pickup."}
      </p>
      {notice === "saved" ? <StatusNote>Saved.</StatusNote> : null}
      {notice === "failed" ? (
        <StatusNote tone="error">That did not save.</StatusNote>
      ) : null}
      {editor
        ? template.map((item) => (
            <form
              key={item.id}
              action={saveQcCheck}
              className="flex flex-col gap-2 rounded-2xl border border-line bg-card p-4"
            >
              <h2 className="font-medium">{item.item_name}</h2>
              <input type="hidden" name="orderNumber" value={orderNumber} />
              <input type="hidden" name="templateId" value={item.id} />
              <input type="hidden" name="itemName" value={item.item_name} />
              <select
                name="result"
                className="min-h-12 rounded-xl border border-line px-3"
                defaultValue="pass"
              >
                <option value="pass">Pass</option>
                <option value="needs_fix">Needs fix</option>
                <option value="fail">Fail</option>
              </select>
              <input
                name="sizeCode"
                placeholder="Size batch (optional)"
                className="min-h-12 rounded-xl border border-line px-3"
              />
              <textarea
                name="note"
                placeholder="Note"
                className="min-h-20 rounded-xl border border-line px-3 py-2"
              />
              <button
                type="submit"
                className="min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white"
              >
                Save check
              </button>
            </form>
          ))
        : null}
      <section className="flex flex-col gap-2">
        <h2 className="font-serif text-2xl text-ink">Recorded checks</h2>
        {checks.map((check) => (
          <div
            key={check.id}
            className="rounded-2xl border border-line bg-card p-3 text-sm"
          >
            <p className="font-medium text-ink">
              {check.item_name} · {check.result}
              {check.size_code ? ` · ${check.size_code}` : ""}
            </p>
            {check.note ? <p>{check.note}</p> : null}
            {check.resolved_at ? (
              <p className="text-muted">Resolved</p>
            ) : editor && check.result !== "pass" ? (
              <form action={resolveQcCheck}>
                <input type="hidden" name="orderNumber" value={orderNumber} />
                <input type="hidden" name="checkId" value={check.id} />
                <button type="submit" className="min-h-11 text-sm font-medium">
                  Mark resolved
                </button>
              </form>
            ) : null}
          </div>
        ))}
      </section>
      <section className="flex flex-col gap-2">
        <h2 className="font-serif text-2xl text-ink">Imported checks</h2>
        <p className="text-sm text-muted">
          Prototype checklist and production gates already on the order.
        </p>
        {(
          (importedResult.data ?? []) as {
            check_name: string;
            completed_text: string | null;
          }[]
        ).map((row) => (
          <p key={row.check_name} className="text-sm text-ink">
            {row.check_name}
            {row.completed_text ? ` · ${row.completed_text}` : ""}
          </p>
        ))}
        {(
          (gatesResult.data ?? []) as {
            gate_name: string;
            status_raw: string | null;
          }[]
        ).map((row) => (
          <p key={row.gate_name} className="text-sm text-ink">
            {row.gate_name}
            {row.status_raw ? ` · ${row.status_raw}` : ""}
          </p>
        ))}
      </section>
      {owner ? (
        <form action={overrideQc} className="flex flex-col gap-2">
          <label className="text-sm font-medium" htmlFor="reason">
            Owner override
          </label>
          <textarea
            id="reason"
            name="reason"
            required
            minLength={3}
            className="min-h-20 rounded-xl border border-line px-3 py-2"
          />
          <input type="hidden" name="orderNumber" value={orderNumber} />
          <button
            type="submit"
            className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium"
          >
            Allow pickup anyway
          </button>
        </form>
      ) : null}
    </div>
  );
}
