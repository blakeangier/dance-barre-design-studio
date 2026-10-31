import { Suspense } from "react";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canSeePrivateRecords } from "@/lib/auth/permissions";
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

export default function OrdersPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <OrdersScreen />
    </Suspense>
  );
}

async function OrdersScreen() {
  const gate = await gateArea("production-orders");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;

  const supabase = await createClient();
  const ordersResult = await supabase
    .from("costume_orders")
    .select("id, order_number, production_song, status, status_raw, order_date")
    .order("order_number");
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
      <h1 className="font-serif text-3xl text-ink">Orders</h1>
      <ul className="flex flex-col gap-3">
        {((ordersResult.data ?? []) as OrderRow[]).map((order) => {
          const hidden = privates.get(order.id);
          return (
            <li
              key={order.id}
              className="rounded-2xl border border-line bg-card p-4"
            >
              <p className="font-medium text-ink">
                {order.order_number}
                {order.production_song ? ` · ${order.production_song}` : ""}
              </p>
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
