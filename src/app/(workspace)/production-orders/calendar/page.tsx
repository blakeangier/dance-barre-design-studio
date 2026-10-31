import Link from "next/link";
import { Suspense } from "react";
import { OrderTabs } from "@/components/orders/order-tabs";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { gateArea } from "@/lib/auth/session";
import { todayInToronto } from "@/lib/inventory/usage";
import { monthDays, orderTimingFlag } from "@/lib/production/schedule";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Calendar" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function CalendarPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <CalendarScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function CalendarScreen({ searchParams }: PageProps) {
  const gate = await gateArea("production-orders");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const view = (await searchParams).view === "week" ? "week" : "month";
  const today = todayInToronto();
  const year = Number(today.slice(0, 4));
  const month = Number(today.slice(5, 7));
  const days = view === "week" ? weekDays(today) : monthDays(year, month);
  const start = days[0] ?? today;
  const end = days.at(-1) ?? today;
  const supabase = await createClient();
  const [ordersResult, fittingsResult, milestonesResult] = await Promise.all([
    supabase
      .from("costume_orders")
      .select(
        "id, order_number, production_status, due_on, event_on, program_id",
      )
      .is("archived_at", null),
    supabase
      .from("fittings")
      .select("id, order_number_raw, fitting_on, dancer_label")
      .gte("fitting_on", start)
      .lte("fitting_on", end)
      .is("archived_at", null),
    supabase
      .from("order_milestones")
      .select("order_id, production_status, target_on")
      .is("archived_at", null),
  ]);
  const orders = (ordersResult.data ?? []) as {
    id: number;
    order_number: string;
    production_status: string | null;
    due_on: string | null;
    event_on: string | null;
  }[];
  const milestones = (milestonesResult.data ?? []) as {
    order_id: number;
    production_status: string;
    target_on: string;
  }[];

  return (
    <div className="flex flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Calendar</h1>
      <OrderTabs current="calendar" />
      <p className="text-sm text-muted">
        {view === "week" ? "This week" : "This month"}. Directors only see their
        own program.
      </p>
      <nav className="flex gap-2">
        <Link
          href="/production-orders/calendar"
          className="inline-flex min-h-12 items-center rounded-full border border-ink px-4 text-sm"
        >
          Month
        </Link>
        <Link
          href="/production-orders/calendar?view=week"
          className="inline-flex min-h-12 items-center rounded-full border border-ink px-4 text-sm"
        >
          Week
        </Link>
      </nav>
      <ul className="flex flex-col gap-3">
        {days.map((day) => {
          const dues = orders.filter((order) => order.due_on === day);
          const events = orders.filter((order) => order.event_on === day);
          const fits = (
            (fittingsResult.data ?? []) as {
              id: number;
              order_number_raw: string | null;
              fitting_on: string | null;
              dancer_label: string | null;
            }[]
          ).filter((row) => row.fitting_on === day);
          const steps = milestones.filter((row) => row.target_on === day);
          if (dues.length + events.length + fits.length + steps.length === 0) {
            return null;
          }
          return (
            <li
              key={day}
              className="rounded-2xl border border-line bg-card p-4"
            >
              <h2 className="font-medium text-ink">{day}</h2>
              {dues.map((order) => (
                <p key={`due-${order.id}`} className="text-sm">
                  Due {order.order_number}{" "}
                  {timing(order.id, order.production_status, milestones, today)}
                </p>
              ))}
              {events.map((order) => (
                <p key={`event-${order.id}`} className="text-sm">
                  Event {order.order_number}
                </p>
              ))}
              {fits.map((fit) => (
                <p key={fit.id} className="text-sm">
                  Fitting {fit.order_number_raw} {fit.dancer_label ?? ""}
                </p>
              ))}
              {steps.map((step) => (
                <p
                  key={`${step.order_id}-${step.production_status}`}
                  className="text-sm"
                >
                  Milestone {step.production_status}
                </p>
              ))}
            </li>
          );
        })}
      </ul>
    </div>
  );
}

function timing(
  orderId: number,
  status: string | null,
  milestones: {
    order_id: number;
    production_status: string;
    target_on: string;
  }[],
  today: string,
): string {
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
  if (flag === "late") return "· Late";
  if (flag === "at_risk") return "· At risk";
  return "";
}

function weekDays(today: string): string[] {
  const [year, month, day] = today.split("-").map(Number);
  const start = new Date(Date.UTC(year ?? 0, (month ?? 1) - 1, day ?? 1));
  const weekday = start.getUTCDay();
  const mondayOffset = weekday === 0 ? -6 : 1 - weekday;
  start.setUTCDate(start.getUTCDate() + mondayOffset);
  return Array.from({ length: 7 }, (_, index) => {
    const date = new Date(start);
    date.setUTCDate(start.getUTCDate() + index);
    return date.toISOString().slice(0, 10);
  });
}
