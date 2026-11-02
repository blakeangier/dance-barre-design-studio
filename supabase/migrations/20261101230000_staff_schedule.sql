-- Staff week schedule. Separate from public.shifts, which feeds timesheets.
-- Owners and the production manager can edit. can_edit_schedule grants the
-- same edit right to one person. Payroll can read every shift and cannot
-- edit unless that flag is on. Everyone else reads only their own rows.
-- Shifts are archived, not deleted.

alter table public.profiles
  add column can_edit_schedule boolean not null default false;

comment on column public.profiles.can_edit_schedule is
  'When on, this person can edit the staff week schedule. Owners and the production manager can edit it without the flag.';

grant update (can_edit_schedule, can_update_order_status)
  on table public.profiles to authenticated;

create or replace function private.can_edit_staff_schedule()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = (select auth.uid())
      and is_active
      and (
        role in ('owner'::public.app_role, 'production_manager'::public.app_role)
        or can_edit_schedule
      )
  );
$$;

revoke all on function private.can_edit_staff_schedule() from public, anon;
grant execute on function private.can_edit_staff_schedule() to authenticated, service_role;

create or replace function private.can_read_all_staff_shifts()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    (select private.is_owner())
    or (select private.is_production_manager())
    or (select private.is_payroll_admin())
    or (select private.can_edit_staff_schedule());
$$;

revoke all on function private.can_read_all_staff_shifts() from public, anon;
grant execute on function private.can_read_all_staff_shifts() to authenticated, service_role;

-- Keep the flag aligned with app_metadata, same as the other access switches.
create or replace function private.sync_profile_from_auth()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  meta jsonb := coalesce(new.raw_app_meta_data, '{}'::jsonb);
  new_role public.app_role := private.parse_role(meta->>'role');
  is_new boolean;
begin
  select not exists (
    select 1 from public.profiles where id = new.id
  ) into is_new;

  insert into public.profiles (
    id,
    full_name,
    role,
    can_purchase,
    can_update_order_status,
    can_edit_schedule,
    is_active
  )
  values (
    new.id,
    coalesce(meta->>'full_name', ''),
    new_role,
    private.parse_bool(meta->>'can_purchase', false),
    private.parse_bool(meta->>'can_update_order_status', false),
    private.parse_bool(meta->>'can_edit_schedule', false),
    true
  )
  on conflict (id) do update
    set role = excluded.role,
        can_purchase = excluded.can_purchase,
        can_update_order_status = excluded.can_update_order_status,
        can_edit_schedule = excluded.can_edit_schedule,
        updated_at = now();

  insert into public.profile_contacts (profile_id, email)
  values (new.id, coalesce(new.email, ''))
  on conflict (profile_id) do update
    set email = excluded.email,
        updated_at = now();

  if is_new and new_role is distinct from 'owner'::public.app_role then
    perform private.link_all_programs(new.id);
  end if;

  return new;
end;
$$;

create or replace function private.protect_profile_privileges()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  claims text := nullif(current_setting('request.jwt.claims', true), '');
  jwt_role text := '';
begin
  if claims is not null then
    jwt_role := coalesce(claims::jsonb ->> 'role', '');
  end if;
  if jwt_role = 'service_role' or jwt_role = '' then
    return new;
  end if;

  if new.id is distinct from old.id then
    raise exception 'You cannot change account identity'
      using errcode = '42501';
  end if;

  if new.role is distinct from old.role
    or new.can_purchase is distinct from old.can_purchase
    or new.can_update_order_status is distinct from old.can_update_order_status
    or new.can_edit_schedule is distinct from old.can_edit_schedule
  then
    if auth.uid() = old.id then
      raise exception 'You cannot change your own role or access flags'
        using errcode = '42501';
    end if;

    if not private.is_owner() then
      raise exception 'Only an owner can change role or access flags'
        using errcode = '42501';
    end if;
  end if;

  if new.is_active is distinct from old.is_active then
    if auth.uid() = old.id then
      raise exception 'You cannot turn off your own account'
        using errcode = '42501';
    end if;

    if not private.is_owner() then
      raise exception 'Only an owner can turn an account on or off'
        using errcode = '42501';
    end if;
  end if;

  if new.job_title is distinct from old.job_title
    or new.employment_type is distinct from old.employment_type
    or new.start_date is distinct from old.start_date
    or new.start_note is distinct from old.start_note
  then
    if not private.is_owner() then
      raise exception 'Only an owner can change job details'
        using errcode = '42501';
    end if;
  end if;

  if new.pronouns is distinct from old.pronouns
    and auth.uid() is distinct from old.id
    and not private.is_owner()
  then
    raise exception 'You can change only your own pronouns'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

create table public.staff_shifts (
  id bigint generated always as identity primary key,
  profile_id uuid not null references public.profiles (id),
  shift_date date not null,
  start_time time not null,
  end_time time not null,
  break_minutes integer not null default 0,
  notes text,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  constraint staff_shifts_break_check check (break_minutes >= 0),
  constraint staff_shifts_span_check check (end_time > start_time),
  constraint staff_shifts_notes_check check (
    notes is null or char_length(notes) <= 400
  )
);

comment on table public.staff_shifts is
  'Who is in the shop, by day. Archived shifts stay in the table and drop off the week view. Not the timesheet source.';

create index staff_shifts_profile_date_idx
  on public.staff_shifts (profile_id, shift_date)
  where archived_at is null;

create index staff_shifts_date_idx on public.staff_shifts (shift_date);

create index staff_shifts_created_by_idx on public.staff_shifts (created_by);

create trigger staff_shifts_set_updated_at
  before update on public.staff_shifts
  for each row execute function private.set_updated_at();

create or replace function private.reject_staff_shift_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'A shift is archived, not deleted'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_staff_shift_delete() from public, anon;
grant execute on function private.reject_staff_shift_delete() to authenticated, service_role;

create trigger staff_shifts_reject_delete
  before delete on public.staff_shifts
  for each row execute function private.reject_staff_shift_delete();

-- A task stays a task. This only says which shift it belongs to.
create table public.shift_tasks (
  shift_id bigint not null references public.staff_shifts (id),
  task_id bigint not null references public.tasks (id),
  created_at timestamptz not null default now(),
  primary key (shift_id, task_id)
);

comment on table public.shift_tasks is
  'Tasks linked to a staff shift. Removing a link does not delete the task.';

create index shift_tasks_task_id_idx on public.shift_tasks (task_id);

revoke all on table public.staff_shifts from public, anon, authenticated;
grant select, insert, update on table public.staff_shifts to authenticated;
grant select, insert, update, delete on table public.staff_shifts to service_role;

revoke all on table public.shift_tasks from public, anon, authenticated;
grant select, insert, delete on table public.shift_tasks to authenticated;
grant select, insert, update, delete on table public.shift_tasks to service_role;

alter table public.staff_shifts enable row level security;
alter table public.shift_tasks enable row level security;

create policy staff_shifts_select
  on public.staff_shifts for select to authenticated
  using (
    archived_at is null
    and (
      profile_id = (select auth.uid())
      or (select private.can_read_all_staff_shifts())
    )
  );

create policy staff_shifts_insert
  on public.staff_shifts for insert to authenticated
  with check ((select private.can_edit_staff_schedule()));

create policy staff_shifts_update
  on public.staff_shifts for update to authenticated
  using ((select private.can_edit_staff_schedule()))
  with check ((select private.can_edit_staff_schedule()));

create policy shift_tasks_select
  on public.shift_tasks for select to authenticated
  using (
    exists (
      select 1
      from public.staff_shifts shift
      where shift.id = shift_tasks.shift_id
        and shift.archived_at is null
        and (
          shift.profile_id = (select auth.uid())
          or (select private.can_read_all_staff_shifts())
        )
    )
  );

create policy shift_tasks_insert
  on public.shift_tasks for insert to authenticated
  with check ((select private.can_edit_staff_schedule()));

create policy shift_tasks_delete
  on public.shift_tasks for delete to authenticated
  using ((select private.can_edit_staff_schedule()));

-- Schedule editors who are not directors may create a task for the person
-- on the shift. Directors keep the existing ban on creating tasks.
create or replace function private.guard_task()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := (select auth.uid());
  supervisor boolean := (select private.can_update_order_status());
  schedule_editor boolean :=
    (select private.can_edit_staff_schedule())
    and not (select private.is_program_director());
begin
  if uid is null then
    return new;
  end if;

  if not exists (
    select 1
    from public.profiles
    where id = new.assigned_to
      and is_active
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
    if not supervisor
      and not schedule_editor
      and new.assigned_to is distinct from uid
    then
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

drop policy if exists tasks_insert on public.tasks;
create policy tasks_insert
  on public.tasks for insert to authenticated
  with check (
    created_by = (select auth.uid())
    and not (select private.is_program_director())
    and (
      (select private.can_update_order_status())
      or (
        (select private.can_edit_staff_schedule())
        and not (select private.is_program_director())
      )
      or assigned_to = (select auth.uid())
    )
  );

-- Hours already worked, for the schedule editors only. Not a pay figure.
create or replace function public.staff_week_actual_minutes(week_start date)
returns table (profile_id uuid, actual_minutes integer)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not (select private.is_owner())
    and not (select private.is_production_manager())
    and not (select private.can_edit_staff_schedule())
  then
    return;
  end if;

  return query
  select
    sheet.profile_id,
    coalesce(sum(
      case
        when entry.status = 'active'
          and not entry.not_worked
          and entry.actual_starts_at is not null
          and entry.actual_ends_at is not null
          and entry.actual_ends_at > entry.actual_starts_at
        then greatest(
          0,
          (extract(epoch from (entry.actual_ends_at - entry.actual_starts_at)) / 60)::integer
            - entry.actual_break_minutes
        )
        else 0
      end
    ), 0)::integer
  from public.timesheets sheet
  join public.timesheet_entries entry on entry.timesheet_id = sheet.id
  where entry.work_date >= week_start
    and entry.work_date < week_start + 7
  group by sheet.profile_id;
end;
$$;

revoke all on function public.staff_week_actual_minutes(date) from public, anon;
grant execute on function public.staff_week_actual_minutes(date) to authenticated, service_role;
