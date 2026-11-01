import Link from "next/link";
import { Suspense } from "react";
import { assignOrdersToProgram } from "@/app/(workspace)/records/order-actions";
import { OrderTabs } from "@/components/orders/order-tabs";
import { StatusPill } from "@/components/orders/production-status";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canUpdateOrderStatus } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Programs" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

const NOTICES: Record<string, { tone: "ok" | "error"; text: string }> = {
  saved: { tone: "ok", text: "Those orders were assigned." },
  choose: { tone: "error", text: "Choose at least one order." },
  denied: { tone: "error", text: "You cannot assign programs." },
  failed: { tone: "error", text: "That assignment did not save." },
};

type OrderRow = {
  id: number;
  order_number: string;
  production_song: string | null;
  status: string | null;
  production_status: string | null;
  program_id: number | null;
};

type ProgramRow = { id: number; name: string };

export default function ProgramsPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ProgramsScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function ProgramsScreen({ searchParams }: PageProps) {
  const gate = await gateArea("production-orders");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const notice = NOTICES[firstQueryValue((await searchParams).notice) ?? ""];
  const canAssign = canUpdateOrderStatus(gate.profile);
  const supabase = await createClient();
  const [ordersResult, programsResult] = await Promise.all([
    supabase
      .from("costume_orders")
      .select(
        "id, order_number, production_song, status, production_status, program_id",
      )
      .is("archived_at", null)
      .order("order_number"),
    supabase.from("programs").select("id, name").order("name"),
  ]);

  if (ordersResult.error || programsResult.error) {
    return (
      <section className="flex flex-col gap-4">
        <h1 className="font-serif text-3xl text-ink">Programs</h1>
        <p className="text-sm text-muted">
          Programs appear after the production status migrations are applied.
        </p>
      </section>
    );
  }

  const programs = (programsResult.data ?? []) as ProgramRow[];
  const orders = (ordersResult.data ?? []) as OrderRow[];
  const groups = [
    ...programs.map((program) => ({
      key: String(program.id),
      name: program.name,
      orders: orders.filter((order) => order.program_id === program.id),
    })),
    {
      key: "unassigned",
      name: "Unassigned",
      orders: orders.filter((order) => order.program_id === null),
    },
  ];

  return (
    <div className="flex flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Orders</h1>
      <OrderTabs current="programs" />
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      <p className="text-sm text-muted">
        Tag each order with its program. Unassigned orders are not visible to
        program directors.
      </p>
      <form action={assignOrdersToProgram} className="flex flex-col gap-4">
        {groups.map((group) => (
          <section key={group.key} className="flex flex-col gap-2">
            <h2 className="font-serif text-2xl text-ink">
              {group.name}
              <span className="ml-2 text-base text-muted">
                {group.orders.length}
              </span>
            </h2>
            {group.orders.length === 0 ? (
              <p className="text-sm text-muted">No orders.</p>
            ) : (
              <ul className="flex flex-col gap-2">
                {group.orders.map((order) => (
                  <li
                    key={order.id}
                    className="flex items-center gap-3 rounded-2xl border border-line bg-card p-3"
                  >
                    {canAssign ? (
                      <input
                        type="checkbox"
                        name="orderId"
                        value={order.id}
                        aria-label={`Select ${order.order_number}`}
                        className="size-5"
                      />
                    ) : null}
                    <div className="min-w-0">
                      <Link
                        href={`/production-orders/${encodeURIComponent(order.order_number)}`}
                        className="inline-flex min-h-11 items-center font-medium text-ink"
                      >
                        {order.order_number}
                        {order.production_song
                          ? ` · ${order.production_song}`
                          : ""}
                      </Link>
                      <div className="mt-1">
                        <StatusPill
                          status={order.production_status}
                          cancelled={order.status === "cancelled"}
                        />
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </section>
        ))}
        {canAssign ? (
          <div className="flex flex-col gap-2 rounded-2xl border border-line bg-card p-4">
            <label className="text-sm font-medium" htmlFor="assignProgram">
              Assign selected orders to
            </label>
            <select
              id="assignProgram"
              name="programId"
              className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
              defaultValue=""
            >
              <option value="">Unassigned</option>
              {programs.map((program) => (
                <option key={program.id} value={program.id}>
                  {program.name}
                </option>
              ))}
            </select>
            <button
              type="submit"
              className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
            >
              Assign selected
            </button>
          </div>
        ) : null}
      </form>
    </div>
  );
}
