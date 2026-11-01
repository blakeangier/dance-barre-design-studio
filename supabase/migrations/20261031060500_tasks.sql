-- Tasks for the floor. Second migration in this phase, after the sized BOM.
-- No deletes. Status history is append-only. A note can be edited by its
-- author for 15 minutes.

create table public.tasks (
  id bigint generated always as identity primary key,
  title text not null,
  description text,
  created_by uuid not null,
  assigned_to uuid not null,
  order_id bigint references public.costume_orders (id),
  style_id bigint references public.styles (id),
  material_id bigint references public.materials (id),
  due_on date,
  priority text not null default 'normal',
  status text not null default 'to_do',
  waiting_reason text,
  done_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tasks_created_by_fkey foreign key (created_by) references public.profiles (id),
  constraint tasks_assigned_to_fkey foreign key (assigned_to) references public.profiles (id),
  constraint tasks_title_check check (char_length(btrim(title)) > 0),
  constraint tasks_priority_check check (
    priority in ('low', 'normal', 'high', 'urgent')
  ),
  constraint tasks_status_check check (
    status in ('to_do', 'in_progress', 'waiting', 'done', 'cancelled')
  ),
  constraint tasks_waiting_check check (
    status <> 'waiting'
    or char_length(btrim(coalesce(waiting_reason, ''))) >= 3
  )
);

comment on table public.tasks is
  'Work on the floor. One assignee. Archive is not used: cancel a task instead of deleting it.';

create index tasks_assigned_to_idx on public.tasks (assigned_to);
create index tasks_created_by_idx on public.tasks (created_by);
create index tasks_order_id_idx on public.tasks (order_id);
create index tasks_due_on_idx on public.tasks (due_on);

create table public.task_status_events (
  id bigint generated always as identity primary key,
  task_id bigint not null references public.tasks (id),
  from_status text,
  to_status text not null,
  changed_by uuid references public.profiles (id),
  changed_at timestamptz not null default now(),
  constraint task_status_events_to_check check (
    to_status in ('to_do', 'in_progress', 'waiting', 'done', 'cancelled')
  )
);

comment on table public.task_status_events is
  'Append-only record of each status change: who, when, from, and to.';

create index task_status_events_task_idx on public.task_status_events (task_id, changed_at);

create table public.task_notes (
  id bigint generated always as identity primary key,
  task_id bigint not null references public.tasks (id),
  body text not null,
  photo_path text,
  author_id uuid not null references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint task_notes_body_check check (char_length(btrim(body)) > 0),
  constraint task_notes_photo_check check (
    photo_path is null
    or photo_path ~* '^tasks/[0-9a-f-]{36}/[0-9a-f-]{36}\.(webp|jpe?g)$'
  )
);

comment on table public.task_notes is
  'Comments on a task. Append-only, except the author may edit for 15 minutes. Photos live under tasks/ in the material-photos bucket.';

create index task_notes_task_idx on public.task_notes (task_id, created_at);

create trigger tasks_set_updated_at
  before update on public.tasks
  for each row execute function private.set_updated_at();

create trigger task_notes_set_updated_at
  before update on public.task_notes
  for each row execute function private.set_updated_at();

create or replace function private.can_read_task(creator uuid, assignee uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when (select private.is_program_director()) then false
    when (select private.is_owner()) or (select private.is_production_manager()) then true
    else creator = (select auth.uid()) or assignee = (select auth.uid())
  end;
$$;

revoke all on function private.can_read_task(uuid, uuid) from public, anon;
grant execute on function private.can_read_task(uuid, uuid) to authenticated, service_role;

create or replace function private.guard_task()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := (select auth.uid());
  supervisor boolean := (select private.can_update_order_status());
begin
  if uid is null then
    return new;
  end if;

  if not exists (
    select 1
    from public.profiles
    where id = new.assigned_to
      and is_active
      and role <> 'program_director'
  ) then
    raise exception 'Assign this to someone who can sign in'
      using errcode = '42501';
  end if;

  if tg_op = 'INSERT' then
    if new.created_by is distinct from uid then
      raise exception 'A task is created by the signed-in person'
        using errcode = '42501';
    end if;
    if (select private.is_program_director()) then
      raise exception 'You cannot create a task'
        using errcode = '42501';
    end if;
    if not supervisor and new.assigned_to is distinct from uid then
      raise exception 'You can only create a task for yourself'
        using errcode = '42501';
    end if;
  else
    if new.created_by is distinct from old.created_by then
      raise exception 'The creator stays on the task'
        using errcode = '42501';
    end if;

    if supervisor or old.created_by = uid then
      null;
    elsif old.assigned_to = uid then
      if new.status = 'cancelled' then
        raise exception 'You cannot cancel this task'
          using errcode = '42501';
      end if;
      if new.status not in ('to_do', 'in_progress', 'waiting', 'done') then
        raise exception 'You cannot change this task'
          using errcode = '42501';
      end if;
      if new.assigned_to is distinct from old.assigned_to
        or new.title is distinct from old.title
        or new.description is distinct from old.description
        or new.order_id is distinct from old.order_id
        or new.style_id is distinct from old.style_id
        or new.material_id is distinct from old.material_id
        or new.due_on is distinct from old.due_on
        or new.priority is distinct from old.priority
        or (
          new.waiting_reason is distinct from old.waiting_reason
          and new.status is distinct from 'waiting'
        )
      then
        raise exception 'You can change the status only'
          using errcode = '42501';
      end if;
    else
      raise exception 'You cannot change this task'
        using errcode = '42501';
    end if;
  end if;

  if new.status = 'done' and (tg_op = 'INSERT' or old.status is distinct from 'done') then
    new.done_at := now();
  elsif new.status is distinct from 'done' then
    new.done_at := null;
  end if;

  if new.status = 'cancelled' and (tg_op = 'INSERT' or old.status is distinct from 'cancelled') then
    new.cancelled_at := now();
  elsif new.status is distinct from 'cancelled' then
    new.cancelled_at := null;
  end if;

  return new;
end;
$$;

revoke all on function private.guard_task() from public, anon;
grant execute on function private.guard_task() to authenticated, service_role;

create trigger tasks_guard
  before insert or update on public.tasks
  for each row execute function private.guard_task();

create or replace function private.record_task_status()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' or new.status is distinct from old.status then
    insert into public.task_status_events (task_id, from_status, to_status, changed_by)
    values (
      new.id,
      case when tg_op = 'INSERT' then null else old.status end,
      new.status,
      (select auth.uid())
    );
  end if;
  return new;
end;
$$;

revoke all on function private.record_task_status() from public, anon;
grant execute on function private.record_task_status() to authenticated, service_role;

create trigger tasks_record_status
  after insert or update of status on public.tasks
  for each row execute function private.record_task_status();

create or replace function private.reject_task_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'A task is cancelled, not deleted.'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_task_delete() from public, anon;
grant execute on function private.reject_task_delete() to authenticated, service_role;

create trigger tasks_reject_delete
  before delete on public.tasks
  for each row execute function private.reject_task_delete();

create trigger task_notes_reject_delete
  before delete on public.task_notes
  for each row execute function private.reject_task_delete();

create trigger task_status_events_reject_change
  before update or delete on public.task_status_events
  for each row execute function private.reject_task_delete();

create or replace function private.guard_task_note()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    return new;
  end if;

  if tg_op = 'INSERT' then
    if new.author_id is distinct from (select auth.uid()) then
      raise exception 'A note is written by the signed-in person'
        using errcode = '42501';
    end if;
    return new;
  end if;

  if old.author_id is distinct from (select auth.uid()) then
    raise exception 'You can edit only your own note'
      using errcode = '42501';
  end if;
  if now() - old.created_at > interval '15 minutes' then
    raise exception 'A note can be edited for 15 minutes'
      using errcode = '42501';
  end if;
  if new.task_id is distinct from old.task_id
    or new.author_id is distinct from old.author_id
    or new.created_at is distinct from old.created_at
  then
    raise exception 'Only the note text can change'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke all on function private.guard_task_note() from public, anon;
grant execute on function private.guard_task_note() to authenticated, service_role;

create trigger task_notes_guard
  before insert or update on public.task_notes
  for each row execute function private.guard_task_note();

revoke all on table public.tasks from public, anon, authenticated;
grant select, insert, update on table public.tasks to authenticated;
grant select, insert, update, delete on table public.tasks to service_role;

revoke all on table public.task_notes from public, anon, authenticated;
grant select, insert, update on table public.task_notes to authenticated;
grant select, insert, update, delete on table public.task_notes to service_role;

revoke all on table public.task_status_events from public, anon, authenticated;
grant select on table public.task_status_events to authenticated;
grant select, insert, update, delete on table public.task_status_events to service_role;

alter table public.tasks enable row level security;
alter table public.task_notes enable row level security;
alter table public.task_status_events enable row level security;

create policy tasks_select
  on public.tasks for select to authenticated
  using ((select private.can_read_task(created_by, assigned_to)));

create policy tasks_insert
  on public.tasks for insert to authenticated
  with check (
    created_by = (select auth.uid())
    and not (select private.is_program_director())
    and (
      (select private.can_update_order_status())
      or assigned_to = (select auth.uid())
    )
  );

create policy tasks_update
  on public.tasks for update to authenticated
  using ((select private.can_read_task(created_by, assigned_to)))
  with check ((select private.can_read_task(created_by, assigned_to)));

create policy task_notes_select
  on public.task_notes for select to authenticated
  using (
    exists (
      select 1
      from public.tasks task
      where task.id = task_notes.task_id
    )
  );

create policy task_notes_insert
  on public.task_notes for insert to authenticated
  with check (
    author_id = (select auth.uid())
    and (
      (select private.is_owner())
      or (select private.is_production_manager())
      or exists (
        select 1
        from public.tasks task
        where task.id = task_notes.task_id
          and (
            task.assigned_to = (select auth.uid())
            or task.created_by = (select auth.uid())
          )
      )
    )
  );

create policy task_notes_update
  on public.task_notes for update to authenticated
  using (author_id = (select auth.uid()))
  with check (author_id = (select auth.uid()));

create policy task_status_events_select
  on public.task_status_events for select to authenticated
  using (
    exists (
      select 1
      from public.tasks task
      where task.id = task_status_events.task_id
    )
  );

drop policy if exists material_photos_storage_insert on storage.objects;
create policy material_photos_storage_insert
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'material-photos'
    and name !~ '\.\.'
    and (
      (select private.can_edit_inventory())
      or name like 'usage/' || (select auth.uid())::text || '/%'
      or name like 'tasks/' || (select auth.uid())::text || '/%'
    )
  );
