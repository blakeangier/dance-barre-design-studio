import Link from "next/link";
import { Suspense } from "react";
import { createTask } from "@/app/(workspace)/tasks/actions";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canSuperviseTasks } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { TASK_PRIORITIES } from "@/lib/tasks/tasks";
import { ORDER_CHOICE_COLUMNS, toOrderChoice } from "@/lib/orders/label";
import { OrderSelectOptions } from "@/components/orders/order-options";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "New task" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function NewTaskPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <NewTask searchParams={props.searchParams} />
    </Suspense>
  );
}

async function NewTask({ searchParams }: PageProps) {
  const gate = await gateArea("tasks");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const params = await searchParams;
  const notice = firstQueryValue(params.notice);
  const orderId = firstQueryValue(params.order) ?? "";
  const supervisor = canSuperviseTasks(gate.profile);
  const supabase = await createClient();
  const [peopleResult, ordersResult, stylesResult] = await Promise.all([
    supervisor
      ? supabase
          .from("profiles")
          .select("id, full_name, role")
          .eq("is_active", true)
          .order("full_name")
      : Promise.resolve({ data: [] }),
    supabase.from("costume_orders").select(ORDER_CHOICE_COLUMNS),
    supabase.from("styles").select("id, style_key").order("style_key"),
  ]);

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/tasks" className="text-sm text-muted">
        My tasks
      </Link>
      <h1 className="font-serif text-3xl text-ink">New task</h1>
      {notice === "failed" ? (
        <StatusNote tone="error">That task did not save.</StatusNote>
      ) : null}
      <form action={createTask} className="flex flex-col gap-3">
        <label className="text-sm font-medium" htmlFor="title">
          Title
        </label>
        <input
          id="title"
          name="title"
          required
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        />
        <label className="text-sm font-medium" htmlFor="description">
          Description
        </label>
        <textarea
          id="description"
          name="description"
          className="min-h-24 rounded-xl border border-line bg-card px-3 py-2"
        />
        {supervisor ? (
          <>
            <label className="text-sm font-medium" htmlFor="assignedTo">
              Assigned to
            </label>
            <select
              id="assignedTo"
              name="assignedTo"
              required
              defaultValue={gate.profile.id}
              className="min-h-12 rounded-xl border border-line bg-card px-3"
            >
              {(
                (peopleResult.data ?? []) as {
                  id: string;
                  full_name: string;
                }[]
              ).map((person) => (
                <option key={person.id} value={person.id}>
                  {person.full_name}
                </option>
              ))}
            </select>
          </>
        ) : (
          <p className="text-sm text-muted">
            This task will be assigned to you.
          </p>
        )}
        <label className="text-sm font-medium" htmlFor="orderId">
          Order
        </label>
        <select
          id="orderId"
          name="orderId"
          defaultValue={orderId}
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <OrderSelectOptions
            blank="None"
            orders={(ordersResult.data ?? []).map((order) =>
              toOrderChoice(order),
            )}
          />
        </select>
        <label className="text-sm font-medium" htmlFor="styleId">
          Style
        </label>
        <select
          id="styleId"
          name="styleId"
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <option value="">None</option>
          {(
            (stylesResult.data ?? []) as { id: number; style_key: string }[]
          ).map((style) => (
            <option key={style.id} value={style.id}>
              {style.style_key}
            </option>
          ))}
        </select>
        <label className="text-sm font-medium" htmlFor="materialCode">
          Material id
        </label>
        <input
          id="materialCode"
          name="materialCode"
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        />
        <label className="text-sm font-medium" htmlFor="dueOn">
          Due date
        </label>
        <input
          id="dueOn"
          name="dueOn"
          type="date"
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        />
        <label className="text-sm font-medium" htmlFor="priority">
          Priority
        </label>
        <select
          id="priority"
          name="priority"
          defaultValue="normal"
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          {TASK_PRIORITIES.map((priority) => (
            <option key={priority.value} value={priority.value}>
              {priority.label}
            </option>
          ))}
        </select>
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
        >
          Save task
        </button>
      </form>
    </div>
  );
}
