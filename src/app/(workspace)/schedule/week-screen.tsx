import Link from "next/link";
import {
  archiveStaffShift,
  createShiftTask,
  linkShiftTask,
  saveStaffShift,
  unlinkShiftTask,
  updateMyTaskStatus,
} from "@/app/(workspace)/schedule/actions";
import { CopyLastWeek } from "@/app/(workspace)/schedule/copy-week";
import { OrderSelectOptions } from "@/components/orders/order-options";
import { StatusNote } from "@/components/shell/status-note";
import {
  canEditStaffSchedule,
  canReadAllStaffShifts,
} from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { getSessionState } from "@/lib/auth/session";
import {
  orderChoiceLabel,
  toOrderChoice,
  type OrderChoice,
} from "@/lib/orders/label";
import { formatHours } from "@/lib/schedule/hours";
import {
  WEEKDAY_LABELS,
  staffShiftMinutes,
  weekDays,
  weekStarting,
} from "@/lib/schedule/staff-week";
import { TASK_STATUSES, taskStatusLabel } from "@/lib/tasks/tasks";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";

type WeekProps = {
  mine: boolean;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type ShiftRow = {
  id: number;
  profile_id: string;
  shift_date: string;
  start_time: string;
  end_time: string;
  break_minutes: number;
  notes: string | null;
};

const NOTICES: Record<string, { tone: "ok" | "error"; text: string }> = {
  saved: { tone: "ok", text: "Saved." },
  archived: { tone: "ok", text: "That shift is archived." },
  copied: {
    tone: "ok",
    text: "Last week's shifts were copied. Tasks were not.",
  },
  none: {
    tone: "ok",
    text: "Nothing new to copy. Those shifts are already on this week.",
  },
  overlap: {
    tone: "error",
    text: "Saved. This shift overlaps another shift for the same person.",
  },
  times: {
    tone: "error",
    text: "The end has to be later than the start, and the break has to leave some working time.",
  },
  failed: { tone: "error", text: "That did not save." },
  denied: { tone: "error", text: "You cannot edit the schedule." },
};

export async function WeekScreen({ mine, searchParams }: WeekProps) {
  const state = await getSessionState();
  if (state.status === "anonymous") redirect("/login");
  if (state.status !== "ready") redirect("/login");
  const params = await searchParams;
  const today = new Date().toLocaleDateString("en-CA", {
    timeZone: "America/Toronto",
  });
  const week = weekStarting(firstQueryValue(params.week), today);
  const editor = canEditStaffSchedule(state.profile);
  const readAll = canReadAllStaffShifts(state.profile);
  if (!mine && !readAll) redirect(`/schedule/me?week=${week}`);

  const days = weekDays(week);
  const supabase = await createClient();
  const peopleQuery = supabase
    .from("profiles")
    .select("id, full_name")
    .eq("is_active", true)
    .order("full_name");
  const shiftsQuery = supabase
    .from("staff_shifts")
    .select(
      "id, profile_id, shift_date, start_time, end_time, break_minutes, notes",
    )
    .gte("shift_date", days[0])
    .lte("shift_date", days[6])
    .is("archived_at", null)
    .order("start_time");
  const [peopleResult, shiftsResult, linksResult, actualResult] =
    await Promise.all([
      mine
        ? Promise.resolve({
            data: [{ id: state.profile.id, full_name: state.profile.fullName }],
          })
        : peopleQuery,
      mine ? shiftsQuery.eq("profile_id", state.profile.id) : shiftsQuery,
      supabase.from("shift_tasks").select("shift_id, task_id"),
      editor
        ? supabase.rpc("staff_week_actual_minutes", { week_start: week })
        : Promise.resolve({ data: [] }),
    ]);

  const people = (peopleResult.data ?? []) as {
    id: string;
    full_name: string;
  }[];
  const shifts = (shiftsResult.data ?? []) as ShiftRow[];
  const taskCounts = new Map<number, number>();
  for (const link of (linksResult.data ?? []) as {
    shift_id: number;
    task_id: number;
  }[]) {
    taskCounts.set(link.shift_id, (taskCounts.get(link.shift_id) ?? 0) + 1);
  }
  const actual = new Map(
    (
      (actualResult.data ?? []) as {
        profile_id: string;
        actual_minutes: number;
      }[]
    ).map((row) => [row.profile_id, row.actual_minutes]),
  );
  const notice = NOTICES[firstQueryValue(params.notice) ?? ""];
  const prevWeek = days[0] ? addDaysSafe(days[0], -7) : week;
  const nextWeek = days[0] ? addDaysSafe(days[0], 7) : week;
  const base = mine ? "/schedule/me" : "/schedule";

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="font-serif text-3xl text-ink">
            {mine ? "My week" : "Schedule"}
          </h1>
          <p className="mt-1 text-sm text-muted">
            {days[0]} to {days[6]}. Times are the same day. Breaks are unpaid.
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Link
            href={`${base}?week=${prevWeek}`}
            className="inline-flex min-h-12 items-center rounded-full border border-ink px-4 text-sm font-medium"
          >
            Previous week
          </Link>
          <Link
            href={base}
            className="inline-flex min-h-12 items-center rounded-full border border-ink px-4 text-sm font-medium"
          >
            This week
          </Link>
          <Link
            href={`${base}?week=${nextWeek}`}
            className="inline-flex min-h-12 items-center rounded-full border border-ink px-4 text-sm font-medium"
          >
            Next week
          </Link>
          {editor && !mine ? <CopyLastWeek week={week} /> : null}
          {mine ? null : (
            <Link
              href="/schedule/me"
              className="inline-flex min-h-12 items-center text-sm"
            >
              My week
            </Link>
          )}
        </div>
      </div>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      {peopleResult && "error" in peopleResult && peopleResult.error ? (
        <p className="text-sm text-muted">
          The schedule is not available until the staff schedule migration is
          applied.
        </p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full min-w-[880px] border-collapse text-sm">
            <thead>
              <tr>
                <th className="border border-line bg-card px-2 py-2 text-left">
                  Person
                </th>
                {days.map((day, index) => (
                  <th
                    key={day}
                    className="border border-line bg-card px-2 py-2 text-left"
                  >
                    {WEEKDAY_LABELS[index]} {day.slice(5)}
                  </th>
                ))}
                <th className="border border-line bg-card px-2 py-2 text-left">
                  Total
                </th>
              </tr>
            </thead>
            <tbody>
              {people.map((person) => {
                const personShifts = shifts.filter(
                  (shift) => shift.profile_id === person.id,
                );
                const planned = personShifts.reduce(
                  (sum, shift) =>
                    sum +
                    (staffShiftMinutes(
                      String(shift.start_time),
                      String(shift.end_time),
                      shift.break_minutes,
                    ) ?? 0),
                  0,
                );
                return (
                  <tr key={person.id}>
                    <th className="border border-line bg-card px-2 py-2 text-left font-medium">
                      {person.full_name}
                      {editor || state.profile.role === "payroll_admin" ? (
                        <p className="font-normal text-muted">
                          Planned {formatHours(planned)}
                          {editor
                            ? ` · Actual ${formatHours(actual.get(person.id) ?? 0)}`
                            : ""}
                        </p>
                      ) : null}
                    </th>
                    {days.map((day) => {
                      const cell = personShifts.filter(
                        (shift) => shift.shift_date === day,
                      );
                      return (
                        <td
                          key={day}
                          className="border border-line px-1 py-1 align-top"
                        >
                          <ul className="flex flex-col gap-1">
                            {cell.map((shift) => {
                              const minutes = staffShiftMinutes(
                                String(shift.start_time),
                                String(shift.end_time),
                                shift.break_minutes,
                              );
                              const label = `${String(shift.start_time).slice(0, 5)}–${String(shift.end_time).slice(0, 5)} · ${formatHours(minutes ?? 0)}`;
                              const count = taskCounts.get(shift.id) ?? 0;
                              return (
                                <li key={shift.id}>
                                  {editor || mine ? (
                                    <Link
                                      href={`${base}?week=${week}&shift=${shift.id}`}
                                      className="block rounded-lg bg-paper px-2 py-1 text-ink"
                                    >
                                      {label}
                                      {count > 0
                                        ? ` · ${count} task${count === 1 ? "" : "s"}`
                                        : ""}
                                    </Link>
                                  ) : (
                                    <p className="px-2 py-1">{label}</p>
                                  )}
                                </li>
                              );
                            })}
                          </ul>
                          {editor ? (
                            <Link
                              href={`${base}?week=${week}&shift=new&profile=${person.id}&date=${day}`}
                              className="mt-1 inline-flex min-h-8 items-center text-xs text-muted"
                            >
                              Add
                            </Link>
                          ) : null}
                        </td>
                      );
                    })}
                    <td className="border border-line px-2 py-2">
                      {formatHours(planned)}
                    </td>
                  </tr>
                );
              })}
              <tr>
                <th className="border border-line bg-card px-2 py-2 text-left">
                  Headcount
                </th>
                {days.map((day) => {
                  const count = new Set(
                    shifts
                      .filter((shift) => shift.shift_date === day)
                      .map((shift) => shift.profile_id),
                  ).size;
                  return (
                    <td key={day} className="border border-line px-2 py-2">
                      {count}
                    </td>
                  );
                })}
                <td className="border border-line" />
              </tr>
            </tbody>
          </table>
        </div>
      )}
      <ShiftDialog
        week={week}
        base={base}
        editor={editor}
        viewerId={state.profile.id}
        shift={firstQueryValue(params.shift)}
        profileId={firstQueryValue(params.profile)}
        date={firstQueryValue(params.date)}
      />
    </div>
  );
}

function addDaysSafe(day: string, count: number): string {
  const [year, month, date] = day.split("-").map(Number);
  const utc = new Date(Date.UTC(year!, month! - 1, date! + count));
  return utc.toISOString().slice(0, 10);
}

async function ShiftDialog({
  week,
  base,
  editor,
  viewerId,
  shift,
  profileId,
  date,
}: {
  week: string;
  base: string;
  editor: boolean;
  viewerId: string;
  shift?: string;
  profileId?: string;
  date?: string;
}) {
  if (!shift) return null;
  const supabase = await createClient();
  const existing =
    shift === "new"
      ? null
      : (
          await supabase
            .from("staff_shifts")
            .select(
              "id, profile_id, shift_date, start_time, end_time, break_minutes, notes",
            )
            .eq("id", Number(shift))
            .is("archived_at", null)
            .maybeSingle()
        ).data;
  if (shift !== "new" && !existing) return null;
  const personId = existing?.profile_id ?? profileId ?? viewerId;
  if (!editor && personId !== viewerId) return null;
  const shiftDate = existing?.shift_date ?? date ?? week;
  const [linked, available, ordersResult] = await Promise.all([
    existing
      ? supabase
          .from("shift_tasks")
          .select(
            "task_id, tasks(id, title, status, order_id, costume_orders(id, order_number, production_song, programs(name)))",
          )
          .eq("shift_id", existing.id)
      : Promise.resolve({ data: [] }),
    supabase
      .from("tasks")
      .select(
        "id, title, status, order_id, costume_orders(id, order_number, production_song, programs(name))",
      )
      .eq("assigned_to", personId)
      .neq("status", "cancelled")
      .order("title"),
    editor
      ? supabase
          .from("costume_orders")
          .select("id, order_number, production_song, programs(name)")
      : Promise.resolve({ data: [] }),
  ]);
  const orders = (
    (ordersResult.data ?? []) as {
      id: number;
      order_number: string;
      production_song: string | null;
      programs: { name: string } | { name: string }[] | null;
    }[]
  ).map((order) => toOrderChoice(order));
  const linkedTasks = ((linked.data ?? []) as LinkedRow[]).flatMap((row) =>
    taskFromEmbed(row.tasks),
  );
  const linkedIds = new Set(linkedTasks.map((task) => task.id));
  const choices = ((available.data ?? []) as TaskEmbed[])
    .map(normalizeTask)
    .filter(
      (task): task is TaskView => task !== null && !linkedIds.has(task.id),
    );

  return (
    <section className="rounded-2xl border border-line bg-card p-4">
      <div className="flex items-center justify-between gap-3">
        <h2 className="font-serif text-2xl text-ink">
          {existing ? "Shift" : "New shift"}
        </h2>
        <Link href={`${base}?week=${week}`} className="text-sm text-ink">
          Close
        </Link>
      </div>
      {editor ? (
        <form
          action={saveStaffShift}
          className="mt-3 grid gap-3 sm:grid-cols-2"
        >
          <input type="hidden" name="week" value={week} />
          <input type="hidden" name="shiftId" value={existing?.id ?? ""} />
          <input type="hidden" name="profileId" value={personId} />
          <label className="text-sm font-medium" htmlFor="shiftDate">
            Date
          </label>
          <input
            id="shiftDate"
            name="shiftDate"
            type="date"
            required
            defaultValue={shiftDate}
            className="min-h-12 rounded-xl border border-line px-3"
          />
          <label className="text-sm font-medium" htmlFor="startTime">
            Start
          </label>
          <input
            id="startTime"
            name="startTime"
            type="time"
            required
            defaultValue={String(existing?.start_time ?? "09:00").slice(0, 5)}
            className="min-h-12 rounded-xl border border-line px-3"
          />
          <label className="text-sm font-medium" htmlFor="endTime">
            End
          </label>
          <input
            id="endTime"
            name="endTime"
            type="time"
            required
            defaultValue={String(existing?.end_time ?? "15:00").slice(0, 5)}
            className="min-h-12 rounded-xl border border-line px-3"
          />
          <label className="text-sm font-medium" htmlFor="breakMinutes">
            Unpaid break (minutes)
          </label>
          <input
            id="breakMinutes"
            name="breakMinutes"
            type="number"
            min={0}
            defaultValue={existing?.break_minutes ?? 0}
            className="min-h-12 rounded-xl border border-line px-3"
          />
          <label className="text-sm font-medium sm:col-span-2" htmlFor="notes">
            Notes
          </label>
          <input
            id="notes"
            name="notes"
            maxLength={400}
            defaultValue={existing?.notes ?? ""}
            className="min-h-12 rounded-xl border border-line px-3 sm:col-span-2"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
          >
            Save shift
          </button>
        </form>
      ) : (
        <p className="mt-2 text-sm text-ink">
          {String(existing?.start_time ?? "").slice(0, 5)}–
          {String(existing?.end_time ?? "").slice(0, 5)}
          {existing?.notes ? ` · ${existing.notes}` : ""}
        </p>
      )}
      {existing ? (
        <div className="mt-4 flex flex-col gap-3">
          <h3 className="font-medium text-ink">Tasks on this shift</h3>
          {linkedTasks.length === 0 ? (
            <p className="text-sm text-muted">No tasks linked yet.</p>
          ) : (
            <ul className="flex flex-col gap-2">
              {linkedTasks.map((task) => (
                <li key={task.id} className="rounded-xl border border-line p-3">
                  <p className="font-medium text-ink">{task.title}</p>
                  <p className="text-sm text-muted">
                    {task.order ? orderChoiceLabel(task.order) : "No order"} ·{" "}
                    {taskStatusLabel(task.status)}
                  </p>
                  {personId === viewerId ? (
                    <form
                      action={updateMyTaskStatus}
                      className="mt-2 flex flex-wrap gap-2"
                    >
                      <input type="hidden" name="taskId" value={task.id} />
                      <input
                        type="hidden"
                        name="returnTo"
                        value={`${base}?week=${week}&shift=${existing.id}`}
                      />
                      <select
                        name="status"
                        defaultValue={task.status}
                        aria-label={`Status for ${task.title}`}
                        className="min-h-11 rounded-xl border border-line px-2"
                      >
                        {TASK_STATUSES.filter(
                          (item) => editor || item.value !== "cancelled",
                        ).map((item) => (
                          <option key={item.value} value={item.value}>
                            {item.label}
                          </option>
                        ))}
                      </select>
                      <input
                        name="waitingReason"
                        placeholder="Why it is waiting"
                        className="min-h-11 rounded-xl border border-line px-2"
                      />
                      <button
                        type="submit"
                        className="min-h-11 text-sm font-medium"
                      >
                        Update status
                      </button>
                    </form>
                  ) : null}
                  {editor ? (
                    <form action={unlinkShiftTask}>
                      <input type="hidden" name="week" value={week} />
                      <input type="hidden" name="shiftId" value={existing.id} />
                      <input type="hidden" name="taskId" value={task.id} />
                      <button type="submit" className="text-sm text-muted">
                        Remove from shift
                      </button>
                    </form>
                  ) : null}
                </li>
              ))}
            </ul>
          )}
          {editor ? (
            <>
              {choices.length > 0 ? (
                <form
                  action={linkShiftTask}
                  className="flex flex-wrap items-center gap-2"
                >
                  <input type="hidden" name="week" value={week} />
                  <input type="hidden" name="shiftId" value={existing.id} />
                  <label className="text-sm font-medium" htmlFor="taskId">
                    Add an existing task
                  </label>
                  <select
                    id="taskId"
                    name="taskId"
                    className="min-h-12 rounded-xl border border-line px-3"
                  >
                    {choices.map((task) => (
                      <option key={task.id} value={task.id}>
                        {task.title}
                        {task.order ? ` · ${orderChoiceLabel(task.order)}` : ""}
                      </option>
                    ))}
                  </select>
                  <button
                    type="submit"
                    className="min-h-12 text-sm font-medium"
                  >
                    Link task
                  </button>
                </form>
              ) : null}
              <form action={createShiftTask} className="grid gap-2">
                <input type="hidden" name="week" value={week} />
                <input type="hidden" name="shiftId" value={existing.id} />
                <label className="text-sm font-medium" htmlFor="newTitle">
                  New task for this person
                </label>
                <input
                  id="newTitle"
                  name="title"
                  required
                  className="min-h-12 rounded-xl border border-line px-3"
                />
                <label className="text-sm font-medium" htmlFor="orderId">
                  Order
                </label>
                <select
                  id="orderId"
                  name="orderId"
                  className="min-h-12 rounded-xl border border-line px-3"
                >
                  <OrderSelectOptions blank="None" orders={orders} />
                </select>
                <button
                  type="submit"
                  className="min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white"
                >
                  Create task
                </button>
              </form>
              <form action={archiveStaffShift}>
                <input type="hidden" name="week" value={week} />
                <input type="hidden" name="shiftId" value={existing.id} />
                <button type="submit" className="text-sm text-muted">
                  Archive shift
                </button>
              </form>
            </>
          ) : null}
        </div>
      ) : null}
    </section>
  );
}

type TaskView = {
  id: number;
  title: string;
  status: string;
  order: OrderChoice | null;
};

type TaskEmbed = {
  id: number;
  title: string;
  status: string;
  costume_orders:
    | {
        id: number;
        order_number: string;
        production_song: string | null;
        programs: { name: string } | { name: string }[] | null;
      }
    | {
        id: number;
        order_number: string;
        production_song: string | null;
        programs: { name: string } | { name: string }[] | null;
      }[]
    | null;
};

type LinkedRow = { tasks: TaskEmbed | TaskEmbed[] | null };

function taskFromEmbed(value: TaskEmbed | TaskEmbed[] | null): TaskView[] {
  if (!value) return [];
  const rows = Array.isArray(value) ? value : [value];
  return rows.flatMap((row) => {
    const task = normalizeTask(row);
    return task ? [task] : [];
  });
}

function normalizeTask(row: TaskEmbed): TaskView | null {
  const order = Array.isArray(row.costume_orders)
    ? row.costume_orders[0]
    : row.costume_orders;
  return {
    id: row.id,
    title: row.title,
    status: row.status,
    order: order ? toOrderChoice(order) : null,
  };
}
