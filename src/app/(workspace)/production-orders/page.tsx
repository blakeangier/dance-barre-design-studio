import Link from "next/link";
import { Suspense } from "react";
import { ListHeader } from "@/components/records/list-header";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canEditInventory, canSeePrivateRecords } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { money } from "@/lib/inventory/format";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Orders" };

type OrderRow = {
  id: number;
  order_number: string;
  production_song: string | null;
  status: string | null;
  status_raw: string | null;
  order_date: string | null;
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
  const showArchived = firstQueryValue((await searchParams).archived) === "1";
  const supabase = await createClient();
  let ordersQuery = supabase
    .from("costume_orders")
    .select("id, order_number, production_song, status, status_raw, order_date")
    .order("order_number");
  if (!showArchived) ordersQuery = ordersQuery.is("archived_at", null);
  const ordersResult = await ordersQuery;
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
      <ul className="flex flex-col gap-3">
        {((ordersResult.data ?? []) as OrderRow[]).map((order) => {
          const hidden = privates.get(order.id);
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
              <p className="text-sm text-muted">
                {order.status === "cancelled"
                  ? `Cancelled (${order.status_raw})`
                  : (order.order_date ?? "No date")}
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
