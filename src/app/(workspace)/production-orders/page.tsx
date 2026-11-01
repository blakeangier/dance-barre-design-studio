import Link from "next/link";
import { Suspense } from "react";
import { OrderTabs } from "@/components/orders/order-tabs";
import {
  ProductionSteps,
  StatusPill,
} from "@/components/orders/production-status";
import { ListHeader } from "@/components/records/list-header";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canEditInventory, canSeePrivateRecords } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { money } from "@/lib/inventory/format";
import { todayInToronto } from "@/lib/inventory/usage";
import {
  PRODUCTION_STATUSES,
  isProductionStatus,
} from "@/lib/orders/production-status";
import { orderTimingFlag } from "@/lib/production/schedule";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Orders" };

type OrderRow = {
  id: number;
  order_number: string;
  production_song: string | null;
  status: string | null;
  status_raw: string | null;
  order_date: string | null;
  production_status: string | null;
  fitting_target_raw: string | null;
  program_id: number | null;
  programs: { name: string } | { name: string }[] | null;
};

type PrivateRow = {
  order_id: number;
  budget_per_costume: number | null;
  contact_emails: string | null;
};

type OrdersProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function OrdersPage(props: OrdersProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <OrdersScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function OrdersScreen({
  searchParams,
}: {
  searchParams: OrdersProps["searchParams"];
}) {
  const gate = await gateArea("production-orders");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const params = await searchParams;
  const showArchived = firstQueryValue(params.archived) === "1";
  const statusFilter = firstQueryValue(params.status) ?? "";
  const programFilter = firstQueryValue(params.program) ?? "";
  const supabase = await createClient();
  const programsResult = await supabase
    .from("programs")
    .select("id, name")
    .order("name");
  const programs = (programsResult.data ?? []) as {
    id: number;
    name: string;
  }[];
  let ordersQuery = supabase
    .from("costume_orders")
    .select(
      "id, order_number, production_song, status, status_raw, order_date, production_status, fitting_target_raw, program_id, programs(name)",
    )
    .order("order_number");
  if (!showArchived) ordersQuery = ordersQuery.is("archived_at", null);
  if (statusFilter === "cancelled") {
    ordersQuery = ordersQuery.eq("status", "cancelled");
  } else if (isProductionStatus(statusFilter)) {
    ordersQuery = ordersQuery
      .eq("production_status", statusFilter)
      .is("status", null);
  }
  if (programFilter === "none") {
    ordersQuery = ordersQuery.is("program_id", null);
  } else if (/^\d+$/.test(programFilter)) {
    ordersQuery = ordersQuery.eq("program_id", Number(programFilter));
  }
  const ordersResult = await ordersQuery;
  const milestoneResult = await supabase
    .from("order_milestones")
    .select("order_id, production_status, target_on")
    .is("archived_at", null);
  const today = todayInToronto();
  const milestones = (milestoneResult.data ?? []) as {
    order_id: number;
    production_status: string;
    target_on: string;
  }[];
  const privateResult = canSeePrivateRecords(gate.profile)
    ? await supabase
        .from("order_private")
        .select("order_id, budget_per_costume, contact_emails")
    : { data: [] };
  const privates = new Map(
    ((privateResult.data ?? []) as PrivateRow[]).map((row) => [
      row.order_id,
      row,
    ]),
  );

  return (
    <div className="flex flex-col gap-4">
      <ListHeader
        title="Orders"
        newHref="/production-orders/new"
        newLabel="New order"
        showArchived={showArchived}
        canCreate={canEditInventory(gate.profile)}
      />
      <OrderTabs current="orders" />
      {ordersResult.error ? (
        <p className="text-sm text-muted">
          Production status appears after its migration is applied.
        </p>
      ) : (
        <form method="get" className="flex flex-col gap-2">
          {showArchived ? (
            <input type="hidden" name="archived" value="1" />
          ) : null}
          <label className="text-sm font-medium" htmlFor="program">
            Program
          </label>
          <select
            id="program"
            name="program"
            defaultValue={programFilter}
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          >
            <option value="">All programs</option>
            <option value="none">Unassigned</option>
            {programs.map((program) => (
              <option key={program.id} value={program.id}>
                {program.name}
              </option>
            ))}
          </select>
          <label className="text-sm font-medium" htmlFor="status">
            Production status
          </label>
          <select
            id="status"
            name="status"
            defaultValue={statusFilter}
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          >
            <option value="">All</option>
            {PRODUCTION_STATUSES.map((status) => (
              <option key={status.value} value={status.value}>
                {status.label}
              </option>
            ))}
            <option value="cancelled">Cancelled</option>
          </select>
          <button
            type="submit"
            className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium text-ink"
          >
            Show
          </button>
        </form>
      )}
      <ul className="flex flex-col gap-3">
        {((ordersResult.data ?? []) as OrderRow[]).map((order) => {
          const hidden = privates.get(order.id);
          const cancelled = order.status === "cancelled";
          return (
            <li
              key={order.id}
              className="rounded-2xl border border-line bg-card p-4"
            >
              <Link
                href={`/production-orders/${encodeURIComponent(order.order_number)}`}
                className="inline-flex min-h-11 items-center font-medium text-ink"
              >
                {order.order_number}
                {order.production_song ? ` · ${order.production_song}` : ""}
              </Link>
              <div className="mt-2">
                <StatusPill
                  status={order.production_status}
                  cancelled={cancelled}
                />
                {cancelled
                  ? null
                  : flagLabel(
                      order.id,
                      order.production_status,
                      milestones,
                      today,
                    )}
                {cancelled ? null : (
                  <ProductionSteps status={order.production_status} />
                )}
              </div>
              <p className="mt-2 text-sm text-ink">
                Program {programLabel(order)}
              </p>
              <p className="text-sm text-muted">
                {cancelled
                  ? `Cancelled (${order.status_raw ?? "cancelled"})`
                  : `Due ${order.fitting_target_raw ?? "not set"}`}
              </p>
              {hidden ? (
                <p className="mt-1 text-sm text-muted">
                  Budget {money(hidden.budget_per_costume)} / costume
                  {hidden.contact_emails ? ` · ${hidden.contact_emails}` : ""}
                </p>
              ) : null}
            </li>
          );
        })}
      </ul>
    </div>
  );
}

function flagLabel(
  orderId: number,
  status: string | null,
  milestones: {
    order_id: number;
    production_status: string;
    target_on: string;
  }[],
  today: string,
) {
  const flag = orderTimingFlag(
    today,
    status ?? "not_started",
    milestones
      .filter((row) => row.order_id === orderId)
      .map((row) => ({
        status: row.production_status,
        targetOn: row.target_on,
      })),
  );
  if (!flag) return null;
  return (
    <span className="ml-2 text-sm font-medium text-ink">
      {flag === "late" ? "Late" : "At risk"}
    </span>
  );
}

function programLabel(order: OrderRow): string {
  const linked = Array.isArray(order.programs)
    ? order.programs[0]
    : order.programs;
  return linked?.name ?? "Unassigned";
}
