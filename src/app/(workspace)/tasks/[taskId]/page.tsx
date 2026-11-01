import Link from "next/link";
import { Suspense } from "react";
import { editTaskNote, updateTask } from "@/app/(workspace)/tasks/actions";
import { TaskNoteForm } from "@/components/tasks/note-form";
import { PhotoThumb } from "@/components/inventory/photo-thumb";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canSuperviseTasks } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { signedUsagePhotos } from "@/lib/inventory/photo-urls";
import { todayInToronto } from "@/lib/inventory/usage";
import {
  isOverdue,
  noteStillEditable,
  TASK_PRIORITIES,
  TASK_STATUSES,
  taskPriorityLabel,
  taskStatusLabel,
} from "@/lib/tasks/tasks";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Task" };

type PageProps = {
  params: Promise<{ taskId: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function TaskPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <TaskScreen params={props.params} searchParams={props.searchParams} />
    </Suspense>
  );
}

type TaskRow = {
  id: number;
  title: string;
  description: string | null;
  created_by: string;
  assigned_to: string;
  order_id: number | null;
  style_id: number | null;
  material_id: number | null;
  due_on: string | null;
  priority: string;
  status: string;
  waiting_reason: string | null;
  done_at: string | null;
};

async function TaskScreen({ params, searchParams }: PageProps) {
  const gate = await gateArea("tasks");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const taskId = Number((await params).taskId);
  const notice = firstQueryValue((await searchParams).notice);
  const supabase = await createClient();
  const { data: task } = await supabase
    .from("tasks")
    .select(
      "id, title, description, created_by, assigned_to, order_id, style_id, material_id, due_on, priority, status, waiting_reason, done_at",
    )
    .eq("id", taskId)
    .maybeSingle();
  if (!task) {
    return <h1 className="font-serif text-3xl text-ink">Task not found</h1>;
  }
  const typed = task as TaskRow;
  const notesResult = await supabase
    .from("task_notes")
    .select("id, body, photo_path, author_id, created_at")
    .eq("task_id", typed.id)
    .order("created_at");
  const notes = (notesResult.data ?? []) as {
    id: number;
    body: string;
    photo_path: string | null;
    author_id: string;
    created_at: string;
  }[];
  const nameIds = [
    ...new Set([
      typed.created_by,
      typed.assigned_to,
      ...notes.map((note) => note.author_id),
    ]),
  ];
  const [peopleResult, historyResult, orderResult] = await Promise.all([
    supabase.from("profiles").select("id, full_name").in("id", nameIds),
    supabase
      .from("task_status_events")
      .select("id, from_status, to_status, changed_at, changed_by")
      .eq("task_id", typed.id)
      .order("changed_at"),
    typed.order_id
      ? supabase
          .from("costume_orders")
          .select("order_number")
          .eq("id", typed.order_id)
          .maybeSingle()
      : Promise.resolve({ data: null }),
  ]);
  const names = new Map(
    ((peopleResult.data ?? []) as { id: string; full_name: string }[]).map(
      (person) => [person.id, person.full_name],
    ),
  );
  const supervisor = canSuperviseTasks(gate.profile);
  const creator = typed.created_by === gate.profile.id;
  const canManage = supervisor || creator;
  const assignee = typed.assigned_to === gate.profile.id;
  const today = todayInToronto();
  const photos = await signedUsagePhotos(
    notes.flatMap((note) => (note.photo_path ? [note.photo_path] : [])),
  );
  const statusChoices = canManage
    ? TASK_STATUSES
    : TASK_STATUSES.filter((status) => status.value !== "cancelled");

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/tasks" className="text-sm text-muted">
        My tasks
      </Link>
      <h1 className="font-serif text-3xl text-ink">{typed.title}</h1>
      {notice === "saved" ? <StatusNote>Saved.</StatusNote> : null}
      {notice === "failed" ? (
        <StatusNote tone="error">That did not save.</StatusNote>
      ) : null}
      <p className="text-sm text-ink">
        From {names.get(typed.created_by) ?? "Unknown"} · Assigned to{" "}
        {names.get(typed.assigned_to) ?? "Unknown"}
      </p>
      <p className="text-sm text-muted">
        {taskStatusLabel(typed.status)} · {taskPriorityLabel(typed.priority)} ·
        Due {typed.due_on ?? "not set"}
        {isOverdue(typed.due_on, typed.status, today) ? " · Overdue" : ""}
      </p>
      {typed.description ? (
        <p className="text-sm text-ink">{typed.description}</p>
      ) : null}
      {typed.waiting_reason ? (
        <p className="text-sm text-ink">Waiting: {typed.waiting_reason}</p>
      ) : null}
      {orderResult.data ? (
        <Link
          href={`/production-orders/${encodeURIComponent(
            (orderResult.data as { order_number: string }).order_number,
          )}`}
          className="text-sm text-ink"
        >
          Order {(orderResult.data as { order_number: string }).order_number}
        </Link>
      ) : null}
      {assignee || canManage ? (
        <form
          action={updateTask}
          className="flex flex-col gap-2 rounded-2xl border border-line bg-card p-4"
        >
          <input type="hidden" name="taskId" value={typed.id} />
          <input type="hidden" name="isCreator" value={canManage ? "1" : "0"} />
          {canManage ? (
            <>
              <label className="text-sm font-medium" htmlFor="title">
                Title
              </label>
              <input
                id="title"
                name="title"
                required
                defaultValue={typed.title}
                className="min-h-12 rounded-xl border border-line px-3"
              />
              <textarea
                name="description"
                defaultValue={typed.description ?? ""}
                className="min-h-20 rounded-xl border border-line px-3 py-2"
              />
              <label className="text-sm font-medium" htmlFor="assignedTo">
                Assigned to
              </label>
              <AssigneeSelect
                current={typed.assigned_to}
                fallbackName={names.get(typed.assigned_to) ?? "Assignee"}
              />
              <input
                name="dueOn"
                type="date"
                defaultValue={typed.due_on ?? ""}
                className="min-h-12 rounded-xl border border-line px-3"
              />
              <select
                name="priority"
                defaultValue={typed.priority}
                className="min-h-12 rounded-xl border border-line px-3"
              >
                {TASK_PRIORITIES.map((priority) => (
                  <option key={priority.value} value={priority.value}>
                    {priority.label}
                  </option>
                ))}
              </select>
              <input
                type="hidden"
                name="orderId"
                value={typed.order_id ?? ""}
              />
              <input
                type="hidden"
                name="styleId"
                value={typed.style_id ?? ""}
              />
            </>
          ) : null}
          <label className="text-sm font-medium" htmlFor="status">
            Status
          </label>
          <select
            id="status"
            name="status"
            defaultValue={typed.status}
            className="min-h-12 rounded-xl border border-line px-3"
          >
            {statusChoices.map((status) => (
              <option key={status.value} value={status.value}>
                {status.label}
              </option>
            ))}
          </select>
          <label className="text-sm font-medium" htmlFor="waitingReason">
            Waiting reason
          </label>
          <input
            id="waitingReason"
            name="waitingReason"
            defaultValue={typed.waiting_reason ?? ""}
            placeholder="Required when waiting"
            className="min-h-12 rounded-xl border border-line px-3"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white"
          >
            Save
          </button>
        </form>
      ) : null}
      <section className="flex flex-col gap-3">
        <h2 className="font-serif text-2xl text-ink">Notes</h2>
        {notes.map((note) => (
          <article
            key={note.id}
            className="rounded-2xl border border-line bg-card p-3 text-sm"
          >
            <p className="font-medium text-ink">
              {names.get(note.author_id) ?? "Note"}
            </p>
            <p className="text-ink">{note.body}</p>
            {note.photo_path && photos.get(note.photo_path) ? (
              <PhotoThumb
                thumbUrl={photos.get(note.photo_path)?.thumbUrl ?? null}
                fullUrl={photos.get(note.photo_path)?.fullUrl ?? null}
                label="Task photo"
              />
            ) : null}
            {note.author_id === gate.profile.id &&
            noteStillEditable(note.created_at) ? (
              <form action={editTaskNote} className="mt-2 flex flex-col gap-2">
                <input type="hidden" name="taskId" value={typed.id} />
                <input type="hidden" name="noteId" value={note.id} />
                <textarea
                  name="body"
                  required
                  defaultValue={note.body}
                  className="min-h-16 rounded-xl border border-line px-3 py-2"
                />
                <button type="submit" className="min-h-11 text-sm font-medium">
                  Save note
                </button>
              </form>
            ) : null}
          </article>
        ))}
        <TaskNoteForm taskId={typed.id} />
      </section>
      <section className="flex flex-col gap-2">
        <h2 className="font-serif text-2xl text-ink">Status history</h2>
        {(
          (historyResult.data ?? []) as {
            id: number;
            from_status: string | null;
            to_status: string;
            changed_at: string;
          }[]
        ).map((event) => (
          <p key={event.id} className="text-sm text-muted">
            {event.from_status ? taskStatusLabel(event.from_status) : "New"} →{" "}
            {taskStatusLabel(event.to_status)} ·{" "}
            {event.changed_at.slice(0, 16).replace("T", " ")}
          </p>
        ))}
      </section>
    </div>
  );
}

async function AssigneeSelect({
  current,
  fallbackName,
}: {
  current: string;
  fallbackName: string;
}) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("profiles")
    .select("id, full_name")
    .eq("is_active", true)
    .neq("role", "program_director")
    .order("full_name");
  const people = (data ?? []) as { id: string; full_name: string }[];
  const listed = people.some((person) => person.id === current);
  return (
    <select
      id="assignedTo"
      name="assignedTo"
      defaultValue={current}
      className="min-h-12 rounded-xl border border-line px-3"
    >
      {listed ? null : <option value={current}>{fallbackName}</option>}
      {people.map((person) => (
        <option key={person.id} value={person.id}>
          {person.full_name}
        </option>
      ))}
    </select>
  );
}
