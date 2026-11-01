import Link from "next/link";
import { Suspense } from "react";
import {
  applyTemplates,
  cancelShift,
  copyLastWeek,
  saveShift,
  saveTemplate,
} from "@/app/(workspace)/scheduling/actions";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditSchedule } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { EDIT_NOTICES } from "@/lib/records/edit";
import { addDays, datesInRange, mondayOf } from "@/lib/schedule/hours";
import { OrderSelectOptions } from "@/components/orders/order-options";
import { orderChoiceLabel, toOrderChoice } from "@/lib/orders/label";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Schedule" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type Person = { id: string; full_name: string; pronouns: string | null };
type ShiftRow = {
  id: number;
  profile_id: string;
  work_date: string;
  start_local: string;
  end_local: string;
  break_minutes: number;
  note: string | null;
  order_id: number | null;
  status: string;
};
type OrderOption = {
  id: number;
  order_number: string;
  production_song: string | null;
  programs: { name: string } | { name: string }[] | null;
};

const WEEKDAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

function nameOf(person: Person | undefined): string {
  if (!person) return "Someone";
  return person.pronouns
    ? `${person.full_name} (${person.pronouns})`
    : person.full_name;
}

export default function SchedulingPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ScheduleScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function ScheduleScreen({
  searchParams,
}: {
  searchParams: PageProps["searchParams"];
}) {
  const gate = await gateArea("scheduling");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const params = await searchParams;
  const requested = firstQueryValue(params.week);
  const today = new Date().toLocaleDateString("en-CA", {
    timeZone: "America/Toronto",
  });
  const week = mondayOf(
    requested && /^\d{4}-\d{2}-\d{2}$/.test(requested) ? requested : today,
  );
  const span = firstQueryValue(params.span) === "14" ? 14 : 7;
  const days = datesInRange(week, addDays(week, span - 1));
  const editor = canEditSchedule(gate.profile);
  const notice = EDIT_NOTICES[firstQueryValue(params.notice) ?? ""];
  const supabase = await createClient();
  const [peopleResult, shiftsResult, ordersResult] = await Promise.all([
    supabase
      .from("profiles")
      .select("id, full_name, pronouns")
      .eq("is_active", true)
      .order("full_name"),
    supabase
      .from("shifts")
      .select(
        "id, profile_id, work_date, start_local, end_local, break_minutes, note, order_id, status",
      )
      .gte("work_date", week)
      .lte("work_date", addDays(week, span - 1))
      .order("work_date")
      .order("start_local"),
    supabase
      .from("costume_orders")
      .select("id, order_number, production_song, programs(name)")
      .is("archived_at", null),
  ]);
  const people = (peopleResult.data ?? []) as Person[];
  const peopleById = new Map(people.map((person) => [person.id, person]));
  const shifts = (shiftsResult.data ?? []) as ShiftRow[];
  const orders = (ordersResult.data ?? []) as OrderOption[];
  const visible = editor
    ? shifts
    : shifts.filter((shift) => shift.status === "scheduled");
  const previous = addDays(week, -7);
  const next = addDays(week, 7);

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="font-serif text-3xl text-ink">Schedule</h1>
          <p className="mt-1 text-sm text-muted">
            {week} to {addDays(week, span - 1)}. Times are Toronto. Paid hours
            are the end time minus the start time, minus the unpaid break.
          </p>
        </div>
        <Link
          href="/scheduling/hours"
          className="inline-flex min-h-12 items-center rounded-full bg-ink px-4 font-medium text-white"
        >
          Hours
        </Link>
      </div>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      {shiftsResult.error ? (
        <p className="text-sm text-muted">
          The schedule is not available until the schedule migration is applied.
        </p>
      ) : null}
      <div className="flex flex-wrap gap-2">
        <Link
          href={`/scheduling?week=${previous}&span=${span}`}
          className="inline-flex min-h-12 items-center rounded-full border border-ink px-4 text-sm"
        >
          Previous
        </Link>
        <Link
          href={`/scheduling?week=${next}&span=${span}`}
          className="inline-flex min-h-12 items-center rounded-full border border-ink px-4 text-sm"
        >
          Next
        </Link>
        <Link
          href={`/scheduling?week=${week}&span=${span === 7 ? 14 : 7}`}
          className="inline-flex min-h-12 items-center rounded-full border border-ink px-4 text-sm"
        >
          {span === 7 ? "Two weeks" : "One week"}
        </Link>
      </div>
      {editor ? (
        <div className="flex flex-wrap gap-2">
          <form action={copyLastWeek}>
            <input type="hidden" name="week" value={week} />
            <input type="hidden" name="span" value={span} />
            <button
              type="submit"
              className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium"
            >
              Copy last week
            </button>
          </form>
          <form action={applyTemplates}>
            <input type="hidden" name="week" value={week} />
            <input type="hidden" name="span" value={span} />
            <button
              type="submit"
              className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium"
            >
              Apply weekly templates
            </button>
          </form>
        </div>
      ) : (
        <p className="text-sm text-muted">
          Your shifts, and the shifts of the people you work with. Pay is not
          shown here.
        </p>
      )}
      {days.map((day) => {
        const dayShifts = visible.filter((shift) => shift.work_date === day);
        return (
          <section
            key={day}
            className="rounded-2xl border border-line bg-card p-4"
          >
            <h2 className="font-medium text-ink">
              {WEEKDAYS[(new Date(`${day}T00:00:00Z`).getUTCDay() + 6) % 7]}{" "}
              {day}
            </h2>
            <ul className="mt-2 flex flex-col gap-3">
              {dayShifts.length === 0 ? (
                <li className="text-sm text-muted">No one scheduled.</li>
              ) : (
                dayShifts.map((shift) => (
                  <li key={shift.id} className="border-t border-line pt-3">
                    <p className="font-medium text-ink">
                      {nameOf(peopleById.get(shift.profile_id))}
                    </p>
                    <p className="text-sm text-muted">
                      {String(shift.start_local).slice(0, 5)}–
                      {String(shift.end_local).slice(0, 5)}
                      {shift.break_minutes
                        ? ` · ${shift.break_minutes} min unpaid break`
                        : ""}
                      {shift.status === "cancelled" ? " · Cancelled" : ""}
                    </p>
                    {shift.note ? (
                      <p className="text-sm text-ink">{shift.note}</p>
                    ) : null}
                    {shift.order_id ? (
                      <p className="text-sm text-muted">
                        {orderChoiceLabel(
                          toOrderChoice(
                            orders.find(
                              (order) => order.id === shift.order_id,
                            ) ?? {
                              id: shift.order_id,
                              order_number: "Order",
                              production_song: null,
                              programs: null,
                            },
                          ),
                        )}
                      </p>
                    ) : null}
                    {editor && shift.status === "scheduled" ? (
                      <form
                        action={saveShift}
                        className="mt-3 flex flex-col gap-2"
                      >
                        <input type="hidden" name="week" value={week} />
                        <input type="hidden" name="span" value={span} />
                        <input type="hidden" name="shiftId" value={shift.id} />
                        <input
                          type="hidden"
                          name="profileId"
                          value={shift.profile_id}
                        />
                        <input
                          type="hidden"
                          name="workDate"
                          value={shift.work_date}
                        />
                        <input
                          type="hidden"
                          name="orderId"
                          value={shift.order_id ?? ""}
                        />
                        <label
                          className="text-sm font-medium"
                          htmlFor={`start-${shift.id}`}
                        >
                          Start
                        </label>
                        <input
                          id={`start-${shift.id}`}
                          name="start"
                          type="time"
                          required
                          defaultValue={String(shift.start_local).slice(0, 5)}
                          className="min-h-12 rounded-xl border border-line px-3 text-base"
                        />
                        <label
                          className="text-sm font-medium"
                          htmlFor={`end-${shift.id}`}
                        >
                          End
                        </label>
                        <input
                          id={`end-${shift.id}`}
                          name="end"
                          type="time"
                          required
                          defaultValue={String(shift.end_local).slice(0, 5)}
                          className="min-h-12 rounded-xl border border-line px-3 text-base"
                        />
                        <label
                          className="text-sm font-medium"
                          htmlFor={`break-${shift.id}`}
                        >
                          Unpaid break
                        </label>
                        <input
                          id={`break-${shift.id}`}
                          name="breakMinutes"
                          type="number"
                          min={0}
                          defaultValue={shift.break_minutes}
                          className="min-h-12 rounded-xl border border-line px-3 text-base"
                        />
                        <label
                          className="text-sm font-medium"
                          htmlFor={`note-${shift.id}`}
                        >
                          Note or task
                        </label>
                        <input
                          id={`note-${shift.id}`}
                          name="note"
                          defaultValue={shift.note ?? ""}
                          className="min-h-12 rounded-xl border border-line px-3 text-base"
                        />
                        <button
                          type="submit"
                          className="min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white"
                        >
                          Save changes
                        </button>
                        <button
                          type="submit"
                          formAction={cancelShift}
                          className="min-h-11 text-sm text-ink"
                        >
                          Cancel shift
                        </button>
                      </form>
                    ) : null}
                  </li>
                ))
              )}
            </ul>
          </section>
        );
      })}
      {editor ? (
        <form
          action={saveShift}
          className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
        >
          <h2 className="font-serif text-2xl text-ink">Add a shift</h2>
          <input type="hidden" name="week" value={week} />
          <input type="hidden" name="span" value={span} />
          <label className="text-sm font-medium" htmlFor="profileId">
            Person
          </label>
          <select
            id="profileId"
            name="profileId"
            required
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          >
            {people.map((person) => (
              <option key={person.id} value={person.id}>
                {nameOf(person)}
              </option>
            ))}
          </select>
          <label className="text-sm font-medium" htmlFor="workDate">
            Date
          </label>
          <input
            id="workDate"
            name="workDate"
            type="date"
            required
            defaultValue={week}
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <label className="text-sm font-medium" htmlFor="start">
            Start
          </label>
          <input
            id="start"
            name="start"
            type="time"
            required
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <label className="text-sm font-medium" htmlFor="end">
            End
          </label>
          <input
            id="end"
            name="end"
            type="time"
            required
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <label className="text-sm font-medium" htmlFor="breakMinutes">
            Unpaid break
          </label>
          <input
            id="breakMinutes"
            name="breakMinutes"
            type="number"
            min={0}
            defaultValue={0}
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <label className="text-sm font-medium" htmlFor="note">
            Note or task
          </label>
          <input
            id="note"
            name="note"
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <label className="text-sm font-medium" htmlFor="orderId">
            Order
          </label>
          <select
            id="orderId"
            name="orderId"
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          >
            <OrderSelectOptions
              blank="No order"
              orders={orders.map((order) => toOrderChoice(order))}
            />
          </select>
          <button
            type="submit"
            className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
          >
            Save shift
          </button>
        </form>
      ) : null}
      {editor ? (
        <form
          action={saveTemplate}
          className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
        >
          <h2 className="font-serif text-2xl text-ink">Weekly template</h2>
          <p className="text-sm text-muted">
            A template repeats every week for one person. Apply it from the
            button above.
          </p>
          <input type="hidden" name="week" value={week} />
          <input type="hidden" name="span" value={span} />
          <label className="text-sm font-medium" htmlFor="templateName">
            Name
          </label>
          <input
            id="templateName"
            name="name"
            required
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <label className="text-sm font-medium" htmlFor="weekday">
            Weekday
          </label>
          <select
            id="weekday"
            name="weekday"
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          >
            {WEEKDAYS.map((label, index) => (
              <option key={label} value={index + 1}>
                {label}
              </option>
            ))}
          </select>
          <label className="text-sm font-medium" htmlFor="templatePerson">
            Person
          </label>
          <select
            id="templatePerson"
            name="profileId"
            required
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          >
            {people.map((person) => (
              <option key={person.id} value={person.id}>
                {nameOf(person)}
              </option>
            ))}
          </select>
          <label className="text-sm font-medium" htmlFor="templateStart">
            Start
          </label>
          <input
            id="templateStart"
            name="start"
            type="time"
            required
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <label className="text-sm font-medium" htmlFor="templateEnd">
            End
          </label>
          <input
            id="templateEnd"
            name="end"
            type="time"
            required
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <label className="text-sm font-medium" htmlFor="templateBreak">
            Unpaid break
          </label>
          <input
            id="templateBreak"
            name="breakMinutes"
            type="number"
            min={0}
            defaultValue={0}
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <label className="text-sm font-medium" htmlFor="templateNote">
            Note or task
          </label>
          <input
            id="templateNote"
            name="note"
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
          >
            Save template
          </button>
        </form>
      ) : null}
    </div>
  );
}
