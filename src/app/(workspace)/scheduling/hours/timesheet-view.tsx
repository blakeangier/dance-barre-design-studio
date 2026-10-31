import {
  addUnscheduled,
  reopenTimesheet,
  reviewTimesheet,
  saveEntry,
  submitTimesheet,
} from "@/app/(workspace)/scheduling/hours/actions";
import { canEditSchedule } from "@/lib/auth/permissions";
import type { CurrentProfile } from "@/lib/auth/session";
import {
  formatHours,
  minutesBetween,
  torontoParts,
} from "@/lib/schedule/hours";

type Entry = {
  id: number;
  shift_id: number | null;
  work_date: string;
  scheduled_starts_at: string | null;
  scheduled_ends_at: string | null;
  scheduled_break_minutes: number | null;
  actual_starts_at: string | null;
  actual_ends_at: string | null;
  actual_break_minutes: number;
  not_worked: boolean;
  reason: string | null;
  status: string;
};

type Sheet = {
  id: number;
  profile_id: string;
  period_start: string;
  period_end: string;
  status: string;
  returned_comment: string | null;
};

function clock(iso: string | null): string {
  if (!iso) return "—";
  return torontoParts(iso).time;
}

function changed(entry: Entry): boolean {
  if (entry.status === "void") return false;
  if (entry.not_worked || entry.shift_id === null) return true;
  return (
    entry.actual_starts_at !== entry.scheduled_starts_at ||
    entry.actual_ends_at !== entry.scheduled_ends_at ||
    entry.actual_break_minutes !== (entry.scheduled_break_minutes ?? 0)
  );
}

export function TimesheetView({
  sheet,
  entries,
  profile,
  rounding,
  periodProcessed,
}: {
  sheet: Sheet;
  entries: Entry[];
  profile: CurrentProfile;
  rounding: number;
  periodProcessed: boolean;
}) {
  const mine = sheet.profile_id === profile.id;
  const editable =
    mine &&
    !periodProcessed &&
    (sheet.status === "draft" || sheet.status === "returned");
  const manager = canEditSchedule(profile);
  const active = entries.filter((entry) => entry.status === "active");
  const changes = active.filter(changed);
  const submittedMinutes = active.reduce((sum, entry) => {
    if (entry.not_worked || !entry.actual_starts_at || !entry.actual_ends_at) {
      return sum;
    }
    return (
      sum +
      (minutesBetween(
        entry.actual_starts_at,
        entry.actual_ends_at,
        entry.actual_break_minutes,
        rounding,
      ) ?? 0)
    );
  }, 0);

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="font-serif text-3xl text-ink">
          {mine ? "Your hours" : "Hours"}
        </h1>
        <p className="mt-1 text-sm text-muted">
          {sheet.period_start} to {sheet.period_end} · {sheet.status}
        </p>
        <p className="mt-2 font-serif text-2xl text-ink">
          {formatHours(submittedMinutes)}
        </p>
        <p className="mt-1 text-sm text-muted">
          Paid hours are the end time minus the start time, minus the unpaid
          break.
        </p>
      </div>
      {sheet.returned_comment ? (
        <p className="rounded-xl border border-red bg-card px-4 py-3 text-sm text-ink">
          Sent back: {sheet.returned_comment}
        </p>
      ) : null}
      {changes.length > 0 ? (
        <section className="rounded-2xl border border-orange bg-card p-4">
          <h2 className="font-medium text-ink">
            What changed from the schedule
          </h2>
          <ul className="mt-2 flex flex-col gap-2 text-sm">
            {changes.map((entry) => (
              <li key={entry.id}>
                {entry.work_date}:{" "}
                {entry.not_worked
                  ? "Not worked"
                  : entry.shift_id
                    ? "Hours changed"
                    : "Added"}
                {entry.reason ? ` · ${entry.reason}` : ""}
              </li>
            ))}
          </ul>
        </section>
      ) : (
        <p className="text-sm text-muted">Nothing differs from the schedule.</p>
      )}
      <ul className="flex flex-col gap-3">
        {active.map((entry) => {
          const scheduled = entry.scheduled_starts_at
            ? minutesBetween(
                entry.scheduled_starts_at,
                entry.scheduled_ends_at ?? entry.scheduled_starts_at,
                entry.scheduled_break_minutes ?? 0,
                rounding,
              )
            : null;
          const actual =
            entry.not_worked || !entry.actual_starts_at || !entry.actual_ends_at
              ? 0
              : minutesBetween(
                  entry.actual_starts_at,
                  entry.actual_ends_at,
                  entry.actual_break_minutes,
                  rounding,
                );
          const start = entry.actual_starts_at
            ? torontoParts(entry.actual_starts_at).time
            : "";
          const end = entry.actual_ends_at
            ? torontoParts(entry.actual_ends_at).time
            : "";
          return (
            <li
              key={entry.id}
              className={`rounded-2xl border bg-card p-4 ${changed(entry) ? "border-orange" : "border-line"}`}
            >
              <p className="font-medium text-ink">{entry.work_date}</p>
              <p className="text-sm text-muted">
                Scheduled{" "}
                {entry.scheduled_starts_at
                  ? `${clock(entry.scheduled_starts_at)}–${clock(entry.scheduled_ends_at)} · ${formatHours(scheduled ?? 0)}${entry.scheduled_break_minutes ? ` · ${entry.scheduled_break_minutes} min unpaid break` : ""}`
                  : "Not on the schedule"}
              </p>
              <p className="text-sm text-ink">
                Submitted{" "}
                {entry.not_worked ? "not worked" : formatHours(actual ?? 0)}
              </p>
              {editable ? (
                <form action={saveEntry} className="mt-3 flex flex-col gap-3">
                  <input type="hidden" name="timesheetId" value={sheet.id} />
                  <input type="hidden" name="entryId" value={entry.id} />
                  <input
                    type="hidden"
                    name="workDate"
                    value={entry.work_date}
                  />
                  <label
                    className="text-sm font-medium"
                    htmlFor={`start-${entry.id}`}
                  >
                    Actual start
                  </label>
                  <input
                    id={`start-${entry.id}`}
                    name="start"
                    type="time"
                    required
                    defaultValue={start}
                    className="min-h-12 rounded-xl border border-line px-3 text-base"
                  />
                  <label
                    className="text-sm font-medium"
                    htmlFor={`end-${entry.id}`}
                  >
                    Actual end
                  </label>
                  <input
                    id={`end-${entry.id}`}
                    name="end"
                    type="time"
                    required
                    defaultValue={end}
                    className="min-h-12 rounded-xl border border-line px-3 text-base"
                  />
                  <label
                    className="text-sm font-medium"
                    htmlFor={`break-${entry.id}`}
                  >
                    Unpaid break
                  </label>
                  <input
                    id={`break-${entry.id}`}
                    name="breakMinutes"
                    type="number"
                    min={0}
                    defaultValue={entry.actual_break_minutes}
                    className="min-h-12 rounded-xl border border-line px-3 text-base"
                  />
                  <label className="flex min-h-12 items-center gap-2 text-sm">
                    <input
                      type="checkbox"
                      name="notWorked"
                      defaultChecked={entry.not_worked}
                      className="size-5"
                    />
                    Not worked
                  </label>
                  <label
                    className="text-sm font-medium"
                    htmlFor={`reason-${entry.id}`}
                  >
                    Reason if this differs from the schedule
                  </label>
                  <input
                    id={`reason-${entry.id}`}
                    name="reason"
                    defaultValue={entry.reason ?? ""}
                    className="min-h-12 rounded-xl border border-line px-3 text-base"
                  />
                  <button
                    type="submit"
                    className="min-h-12 rounded-full border border-ink px-4 font-medium"
                  >
                    Save day
                  </button>
                </form>
              ) : null}
            </li>
          );
        })}
      </ul>
      {editable ? (
        <>
          <form
            action={addUnscheduled}
            className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
          >
            <h2 className="font-serif text-2xl text-ink">Add hours</h2>
            <input type="hidden" name="timesheetId" value={sheet.id} />
            <label className="text-sm font-medium" htmlFor="extraDate">
              Date
            </label>
            <input
              id="extraDate"
              name="workDate"
              type="date"
              required
              min={sheet.period_start}
              max={sheet.period_end}
              className="min-h-12 rounded-xl border border-line px-3 text-base"
            />
            <label className="text-sm font-medium" htmlFor="extraStart">
              Start
            </label>
            <input
              id="extraStart"
              name="start"
              type="time"
              required
              className="min-h-12 rounded-xl border border-line px-3 text-base"
            />
            <label className="text-sm font-medium" htmlFor="extraEnd">
              End
            </label>
            <input
              id="extraEnd"
              name="end"
              type="time"
              required
              className="min-h-12 rounded-xl border border-line px-3 text-base"
            />
            <label className="text-sm font-medium" htmlFor="extraBreak">
              Unpaid break
            </label>
            <input
              id="extraBreak"
              name="breakMinutes"
              type="number"
              min={0}
              defaultValue={0}
              className="min-h-12 rounded-xl border border-line px-3 text-base"
            />
            <label className="text-sm font-medium" htmlFor="extraReason">
              Reason
            </label>
            <input
              id="extraReason"
              name="reason"
              required
              minLength={3}
              className="min-h-12 rounded-xl border border-line px-3 text-base"
            />
            <button
              type="submit"
              className="min-h-12 rounded-full border border-ink px-4 font-medium"
            >
              Add shift
            </button>
          </form>
          <form action={submitTimesheet}>
            <input type="hidden" name="timesheetId" value={sheet.id} />
            <button
              type="submit"
              className="min-h-14 w-full rounded-full bg-ink px-4 text-lg font-medium text-white"
            >
              Submit hours
            </button>
          </form>
        </>
      ) : null}
      {manager && sheet.status === "submitted" ? (
        <div className="flex flex-col gap-3">
          <form action={reviewTimesheet}>
            <input type="hidden" name="timesheetId" value={sheet.id} />
            <input type="hidden" name="decision" value="approve" />
            <button
              type="submit"
              className="min-h-12 w-full rounded-full bg-ink px-4 font-medium text-white"
            >
              Approve
            </button>
          </form>
          <form action={reviewTimesheet} className="flex flex-col gap-3">
            <input type="hidden" name="timesheetId" value={sheet.id} />
            <input type="hidden" name="decision" value="return" />
            <label className="text-sm font-medium" htmlFor="returnComment">
              Send back with a comment
            </label>
            <input
              id="returnComment"
              name="comment"
              required
              minLength={3}
              className="min-h-12 rounded-xl border border-line px-3 text-base"
            />
            <button
              type="submit"
              className="min-h-12 rounded-full border border-ink px-4 font-medium"
            >
              Send back
            </button>
          </form>
        </div>
      ) : null}
      {manager &&
      (sheet.status === "approved" || sheet.status === "sent") &&
      !periodProcessed ? (
        <div className="flex flex-col gap-3">
          {sheet.status === "approved" ? (
            <form action={reviewTimesheet}>
              <input type="hidden" name="timesheetId" value={sheet.id} />
              <input type="hidden" name="decision" value="send" />
              <button
                type="submit"
                className="min-h-12 w-full rounded-full bg-ink px-4 font-medium text-white"
              >
                Send to payroll
              </button>
            </form>
          ) : null}
          <form action={reopenTimesheet} className="flex flex-col gap-3">
            <input type="hidden" name="timesheetId" value={sheet.id} />
            <label className="text-sm font-medium" htmlFor="reopenReason">
              Reopen with a reason
            </label>
            <input
              id="reopenReason"
              name="reason"
              required
              minLength={3}
              className="min-h-12 rounded-xl border border-line px-3 text-base"
            />
            <button
              type="submit"
              className="min-h-12 rounded-full border border-ink px-4 font-medium"
            >
              Reopen
            </button>
          </form>
        </div>
      ) : null}
      {profile.role === "owner" && periodProcessed ? (
        <form action={reopenTimesheet} className="flex flex-col gap-3">
          <input type="hidden" name="timesheetId" value={sheet.id} />
          <label className="text-sm font-medium" htmlFor="ownerReopen">
            Reopen this processed timesheet
          </label>
          <input
            id="ownerReopen"
            name="reason"
            required
            minLength={3}
            className="min-h-12 rounded-xl border border-line px-3 text-base"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full border border-ink px-4 font-medium"
          >
            Reopen
          </button>
        </form>
      ) : null}
    </div>
  );
}
