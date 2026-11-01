-- Schedule and bi-weekly timesheets for Dance Barre Design Studio Inc.
-- Times are America/Toronto. The first pay-period date stays blank until someone sets it.
-- Nothing here is deleted. Shifts are cancelled. Timesheet lines are voided.

create table public.payroll_settings (
  id boolean primary key default true,
  entity_id bigint references public.business_entities (id),
  timezone text not null default 'America/Toronto',
  pay_period_anchor date,
  period_length_days integer not null default 14,
  rounding_minutes integer not null default 0,
  overtime_weekly_hours numeric(6, 2),
  updated_at timestamptz not null default now(),
  constraint payroll_settings_singleton check (id),
  constraint payroll_settings_timezone_check check (timezone = 'America/Toronto'),
  constraint payroll_settings_length_check check (period_length_days = 14),
  constraint payroll_settings_rounding_check check (rounding_minutes in (0, 5, 15)),
  constraint payroll_settings_overtime_check check (
    overtime_weekly_hours is null or overtime_weekly_hours > 0
  )
);

comment on table public.payroll_settings is
  'Bi-weekly payroll for Dance Barre Design Studio Inc. The anchor date is blank until an owner or payroll sets it. Overtime hours are stored only as a blank setting until the rule is confirmed.';

comment on column public.payroll_settings.overtime_weekly_hours is
  'Left blank on purpose. Ontario overtime is not confirmed, so the app does not calculate it.';

insert into public.payroll_settings (id) values (true);

create trigger payroll_settings_set_updated_at
  before update on public.payroll_settings
  for each row
  execute function private.set_updated_at();

create table public.pay_periods (
  period_start date primary key,
  period_end date not null,
  status text not null default 'open',
  processed_at timestamptz,
  processed_by uuid references public.profiles (id),
  updated_at timestamptz not null default now(),
  constraint pay_periods_status_check check (status in ('open', 'processed')),
  constraint pay_periods_range_check check (period_end = period_start + 13)
);

comment on table public.pay_periods is
  'One bi-weekly period. Processed locks the schedule and timesheets in that range.';

create trigger pay_periods_set_updated_at
  before update on public.pay_periods
  for each row
  execute function private.set_updated_at();

create table public.shift_templates (
  id bigint generated always as identity primary key,
  name text not null,
  weekday smallint not null,
  start_local time not null,
  end_local time not null,
  break_minutes integer not null default 0,
  note text,
  profile_id uuid references public.profiles (id),
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint shift_templates_weekday_check check (weekday between 1 and 7),
  constraint shift_templates_break_check check (break_minutes >= 0),
  constraint shift_templates_name_check check (char_length(btrim(name)) > 0)
);

comment on table public.shift_templates is
  'Repeating weekly shift patterns. Weekday 1 is Monday. Archived templates are hidden.';

create trigger shift_templates_set_updated_at
  before update on public.shift_templates
  for each row
  execute function private.set_updated_at();

create table public.shifts (
  id bigint generated always as identity primary key,
  profile_id uuid not null references public.profiles (id),
  work_date date not null,
  start_local time not null,
  end_local time not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  break_minutes integer not null default 0,
  note text,
  order_id bigint references public.costume_orders (id),
  status text not null default 'scheduled',
  created_by uuid references public.profiles (id),
  cancelled_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint shifts_status_check check (status in ('scheduled', 'cancelled')),
  constraint shifts_break_check check (break_minutes >= 0),
  constraint shifts_span_check check (ends_at > starts_at)
);

comment on table public.shifts is
  'Shop schedule. ends_at is after starts_at in real time, including overnight and Toronto daylight-saving changes. Cancel a shift instead of deleting it.';

comment on column public.shifts.break_minutes is
  'Unpaid break in minutes. Paid time is end minus start minus this.';
comment on column public.shift_templates.break_minutes is
  'Unpaid break in minutes. Paid time is end minus start minus this.';

create index shifts_profile_date_idx on public.shifts (profile_id, work_date);
create index shifts_work_date_idx on public.shifts (work_date);

create trigger shifts_set_updated_at
  before update on public.shifts
  for each row
  execute function private.set_updated_at();

create table public.timesheets (
  id bigint generated always as identity primary key,
  profile_id uuid not null references public.profiles (id),
  period_start date not null,
  period_end date not null,
  status text not null default 'draft',
  employee_submitted_at timestamptz,
  manager_approved_at timestamptz,
  manager_approved_by uuid references public.profiles (id),
  returned_comment text,
  sent_to_payroll_at timestamptz,
  processed_at timestamptz,
  reopened_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (profile_id, period_start),
  constraint timesheets_status_check check (
    status in ('draft', 'submitted', 'approved', 'returned', 'sent', 'processed')
  ),
  constraint timesheets_range_check check (period_end = period_start + 13)
);

comment on table public.timesheets is
  'One sheet per person per pay period. draft or returned can be edited by that person. submitted waits for the production manager. approved can be sent to payroll. processed is locked.';

create index timesheets_status_idx on public.timesheets (status);

create trigger timesheets_set_updated_at
  before update on public.timesheets
  for each row
  execute function private.set_updated_at();

create table public.timesheet_entries (
  id bigint generated always as identity primary key,
  timesheet_id bigint not null references public.timesheets (id),
  shift_id bigint references public.shifts (id),
  work_date date not null,
  scheduled_starts_at timestamptz,
  scheduled_ends_at timestamptz,
  scheduled_break_minutes integer,
  actual_starts_at timestamptz,
  actual_ends_at timestamptz,
  actual_break_minutes integer not null default 0,
  not_worked boolean not null default false,
  reason text,
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint timesheet_entries_status_check check (status in ('active', 'void')),
  constraint timesheet_entries_break_check check (actual_break_minutes >= 0),
  constraint timesheet_entries_reason_check check (
    reason is null or char_length(reason) <= 300
  )
);

comment on table public.timesheet_entries is
  'Scheduled hours beside the hours the employee submits. A difference, an extra shift, or a shift not worked needs a short reason. Void a line instead of deleting it.';

comment on column public.timesheet_entries.scheduled_break_minutes is
  'Unpaid break from the schedule, in minutes.';
comment on column public.timesheet_entries.actual_break_minutes is
  'Unpaid break submitted for pay, in minutes. Paid time subtracts this.';

create index timesheet_entries_sheet_idx on public.timesheet_entries (timesheet_id);
create unique index timesheet_entries_shift_active_idx
  on public.timesheet_entries (timesheet_id, shift_id)
  where shift_id is not null and status = 'active';

create trigger timesheet_entries_set_updated_at
  before update on public.timesheet_entries
  for each row
  execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Locks and reasons
-- ---------------------------------------------------------------------------

create or replace function private.period_is_processed(day date)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.pay_periods
    where status = 'processed'
      and day between period_start and period_end
  );
$$;

revoke all on function private.period_is_processed(date) from public, anon;
grant execute on function private.period_is_processed(date) to authenticated, service_role;

create or replace function private.reject_schedule_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Cancel or void this record. It cannot be deleted.'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_schedule_delete() from public, anon;
grant execute on function private.reject_schedule_delete() to authenticated, service_role;

create trigger shifts_reject_delete
  before delete on public.shifts
  for each row execute function private.reject_schedule_delete();
create trigger timesheets_reject_delete
  before delete on public.timesheets
  for each row execute function private.reject_schedule_delete();
create trigger timesheet_entries_reject_delete
  before delete on public.timesheet_entries
  for each row execute function private.reject_schedule_delete();

create or replace function private.guard_timesheet_entry()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  sheet public.timesheets;
  claims text := nullif(current_setting('request.jwt.claims', true), '');
  jwt_role text := '';
begin
  if claims is not null then
    jwt_role := coalesce(claims::jsonb ->> 'role', '');
  end if;
  if claims is null or jwt_role in ('service_role', '') then
    return new;
  end if;

  select * into sheet from public.timesheets where id = new.timesheet_id;
  if sheet.id is null then
    raise exception 'That timesheet does not exist' using errcode = '42501';
  end if;

  if private.period_is_processed(sheet.period_start)
    and current_setting('app.reopen_period', true) is distinct from 'on'
  then
    raise exception 'This pay period is processed and locked'
      using errcode = '42501';
  end if;

  if tg_op = 'UPDATE' and old.timesheet_id is distinct from new.timesheet_id then
    raise exception 'A line cannot move to another timesheet' using errcode = '42501';
  end if;

  if new.not_worked
    or new.shift_id is null
    or new.actual_starts_at is distinct from new.scheduled_starts_at
    or new.actual_ends_at is distinct from new.scheduled_ends_at
    or new.actual_break_minutes is distinct from coalesce(new.scheduled_break_minutes, 0)
    or new.status = 'void'
  then
    if new.reason is null or char_length(btrim(new.reason)) < 3 then
      raise exception 'Add a short reason for this change from the schedule'
        using errcode = '23514';
    end if;
  end if;

  if auth.uid() = sheet.profile_id and not private.is_owner() then
    if sheet.status not in ('draft', 'returned') then
      raise exception 'This timesheet is already submitted' using errcode = '42501';
    end if;
  elsif private.is_owner() then
    null;
  else
    raise exception 'You cannot edit these hours' using errcode = '42501';
  end if;

  return new;
end;
$$;

revoke all on function private.guard_timesheet_entry() from public, anon;
grant execute on function private.guard_timesheet_entry() to authenticated, service_role;

create trigger timesheet_entries_guard
  before insert or update on public.timesheet_entries
  for each row execute function private.guard_timesheet_entry();

create or replace function private.guard_timesheet()
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
  if claims is null or jwt_role in ('service_role', '') then
    return new;
  end if;

  if new.profile_id is distinct from old.profile_id
    or new.period_start is distinct from old.period_start
    or new.period_end is distinct from old.period_end
  then
    raise exception 'A timesheet cannot be moved' using errcode = '42501';
  end if;

  if current_setting('app.pay_period_lock', true) = 'on'
    and new.status = 'processed'
    and (private.is_payroll_admin() or private.is_owner())
  then
    return new;
  end if;

  if private.period_is_processed(new.period_start)
    and current_setting('app.reopen_period', true) is distinct from 'on'
  then
    raise exception 'This pay period is processed and locked'
      using errcode = '42501';
  end if;

  if new.status is not distinct from old.status then
    return new;
  end if;

  if private.is_owner()
    or (auth.uid() = new.profile_id and new.status = 'submitted' and old.status in ('draft', 'returned'))
    or (
      private.is_production_manager()
      and (
        (old.status = 'submitted' and new.status in ('approved', 'returned'))
        or (old.status = 'approved' and new.status in ('sent', 'returned'))
        or (old.status = 'sent' and new.status = 'returned')
      )
    )
  then
    if new.status = 'returned'
      and (new.returned_comment is null or char_length(btrim(new.returned_comment)) < 3)
    then
      raise exception 'Add a comment when you send this back'
        using errcode = '23514';
    end if;
    return new;
  end if;

  raise exception 'You cannot change this timesheet to that status'
    using errcode = '42501';
end;
$$;

revoke all on function private.guard_timesheet() from public, anon;
grant execute on function private.guard_timesheet() to authenticated, service_role;

create trigger timesheets_guard
  before update on public.timesheets
  for each row execute function private.guard_timesheet();

create or replace function private.guard_shift()
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
  if claims is null or jwt_role in ('service_role', '') then
    return new;
  end if;

  if private.period_is_processed(new.work_date)
    and current_setting('app.reopen_period', true) is distinct from 'on'
  then
    raise exception 'This pay period is processed and locked'
      using errcode = '42501';
  end if;
  if not private.is_owner() and not private.is_production_manager() then
    raise exception 'Only the production manager or an owner can change the schedule'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

revoke all on function private.guard_shift() from public, anon;
grant execute on function private.guard_shift() to authenticated, service_role;

create trigger shifts_guard
  before insert or update on public.shifts
  for each row execute function private.guard_shift();

-- ---------------------------------------------------------------------------
-- Build a timesheet from the schedule. Safe to call again.
-- ---------------------------------------------------------------------------

create or replace function public.ensure_timesheet(
  target_profile uuid,
  p_start date,
  p_end date
)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  sheet_id bigint;
begin
  if auth.uid() is null then
    raise exception 'Sign in first' using errcode = '42501';
  end if;
  if auth.uid() is distinct from target_profile
    and not private.is_owner()
    and not private.is_production_manager()
  then
    raise exception 'You cannot open that timesheet' using errcode = '42501';
  end if;
  if p_end is distinct from p_start + 13 then
    raise exception 'A pay period is 14 days' using errcode = '23514';
  end if;

  insert into public.pay_periods (period_start, period_end)
  values (p_start, p_end)
  on conflict (period_start) do nothing;

  insert into public.timesheets (profile_id, period_start, period_end)
  values (target_profile, p_start, p_end)
  on conflict (profile_id, period_start) do nothing;

  select id into sheet_id
  from public.timesheets
  where profile_id = target_profile and period_start = p_start;

  insert into public.timesheet_entries (
    timesheet_id, shift_id, work_date,
    scheduled_starts_at, scheduled_ends_at, scheduled_break_minutes,
    actual_starts_at, actual_ends_at, actual_break_minutes
  )
  select
    sheet_id, s.id, s.work_date,
    s.starts_at, s.ends_at, s.break_minutes,
    s.starts_at, s.ends_at, s.break_minutes
  from public.shifts s
  where s.profile_id = target_profile
    and s.work_date between p_start and p_end
    and s.status = 'scheduled'
    and not exists (
      select 1
      from public.timesheet_entries e
      where e.timesheet_id = sheet_id
        and e.shift_id = s.id
        and e.status = 'active'
    );

  return sheet_id;
end;
$$;

revoke all on function public.ensure_timesheet(uuid, date, date) from public, anon;
grant execute on function public.ensure_timesheet(uuid, date, date) to authenticated;

create or replace function public.mark_pay_period_processed(p_start date)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_owner() and not private.is_payroll_admin() then
    raise exception 'Only payroll or an owner can mark a period processed'
      using errcode = '42501';
  end if;

  perform set_config('app.pay_period_lock', 'on', true);

  update public.pay_periods
  set status = 'processed',
      processed_at = now(),
      processed_by = auth.uid()
  where period_start = p_start
    and status = 'open';

  update public.timesheets
  set status = 'processed',
      processed_at = now()
  where period_start = p_start
    and status in ('approved', 'sent');
end;
$$;

revoke all on function public.mark_pay_period_processed(date) from public, anon;
grant execute on function public.mark_pay_period_processed(date) to authenticated;

create or replace function public.reopen_timesheet(sheet_id bigint, reason text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  sheet public.timesheets;
  period_status text;
begin
  if reason is null or char_length(btrim(reason)) < 3 then
    raise exception 'Add a reason for reopening' using errcode = '23514';
  end if;

  select * into sheet from public.timesheets where id = sheet_id;
  if sheet.id is null then
    raise exception 'That timesheet does not exist' using errcode = '42501';
  end if;

  select status into period_status
  from public.pay_periods
  where period_start = sheet.period_start;

  if period_status = 'processed' then
    if not private.is_owner() then
      raise exception 'A processed timesheet needs an owner to reopen it'
        using errcode = '42501';
    end if;
    perform set_config('app.reopen_period', 'on', true);
    update public.pay_periods
    set status = 'open', processed_at = null, processed_by = null
    where period_start = sheet.period_start;
  elsif not private.is_owner() and not private.is_production_manager() then
    raise exception 'Only the production manager or an owner can reopen this'
      using errcode = '42501';
  elsif sheet.status not in ('approved', 'sent') then
    raise exception 'Only an approved timesheet can be reopened'
      using errcode = '42501';
  end if;

  update public.timesheets
  set status = 'returned',
      returned_comment = btrim(reason),
      reopened_reason = btrim(reason)
  where id = sheet_id;
end;
$$;

revoke all on function public.reopen_timesheet(bigint, text) from public, anon;
grant execute on function public.reopen_timesheet(bigint, text) to authenticated;

-- ---------------------------------------------------------------------------
-- Audit
-- ---------------------------------------------------------------------------

create trigger payroll_settings_audit
  after insert or update or delete on public.payroll_settings
  for each row execute function private.audit_row();
create trigger pay_periods_audit
  after insert or update or delete on public.pay_periods
  for each row execute function private.audit_row();
create trigger shift_templates_audit
  after insert or update or delete on public.shift_templates
  for each row execute function private.audit_row();
create trigger shifts_audit
  after insert or update or delete on public.shifts
  for each row execute function private.audit_row();
create trigger timesheets_audit
  after insert or update or delete on public.timesheets
  for each row execute function private.audit_row();
create trigger timesheet_entries_audit
  after insert or update or delete on public.timesheet_entries
  for each row execute function private.audit_row();

-- ---------------------------------------------------------------------------
-- Grants and row security
-- ---------------------------------------------------------------------------

revoke all on table public.payroll_settings from public, anon, authenticated;
revoke all on table public.pay_periods from public, anon, authenticated;
revoke all on table public.shift_templates from public, anon, authenticated;
revoke all on table public.shifts from public, anon, authenticated;
revoke all on table public.timesheets from public, anon, authenticated;
revoke all on table public.timesheet_entries from public, anon, authenticated;

grant select on table public.payroll_settings to authenticated;
grant update on table public.payroll_settings to authenticated;
grant select, insert, update on table public.pay_periods to authenticated;
grant select, insert, update on table public.shift_templates to authenticated;
grant select, insert, update on table public.shifts to authenticated;
grant select, insert, update on table public.timesheets to authenticated;
grant select, insert, update on table public.timesheet_entries to authenticated;

grant select, insert, update, delete on table public.payroll_settings to service_role;
grant select, insert, update, delete on table public.pay_periods to service_role;
grant select, insert, update, delete on table public.shift_templates to service_role;
grant select, insert, update, delete on table public.shifts to service_role;
grant select, insert, update, delete on table public.timesheets to service_role;
grant select, insert, update, delete on table public.timesheet_entries to service_role;

alter table public.payroll_settings enable row level security;
alter table public.pay_periods enable row level security;
alter table public.shift_templates enable row level security;
alter table public.shifts enable row level security;
alter table public.timesheets enable row level security;
alter table public.timesheet_entries enable row level security;

create policy payroll_settings_select
  on public.payroll_settings for select to authenticated
  using (true);
create policy payroll_settings_update
  on public.payroll_settings for update to authenticated
  using ((select private.is_owner()) or (select private.is_payroll_admin()))
  with check ((select private.is_owner()) or (select private.is_payroll_admin()));

create policy pay_periods_select
  on public.pay_periods for select to authenticated
  using (true);
create policy pay_periods_insert
  on public.pay_periods for insert to authenticated
  with check (
    (select private.is_owner())
    or (select private.is_payroll_admin())
    or (select private.is_production_manager())
  );
create policy pay_periods_update
  on public.pay_periods for update to authenticated
  using ((select private.is_owner()) or (select private.is_payroll_admin()))
  with check ((select private.is_owner()) or (select private.is_payroll_admin()));

create policy shift_templates_select
  on public.shift_templates for select to authenticated
  using (true);
create policy shift_templates_write
  on public.shift_templates for insert to authenticated
  with check ((select private.is_owner()) or (select private.is_production_manager()));
create policy shift_templates_update
  on public.shift_templates for update to authenticated
  using ((select private.is_owner()) or (select private.is_production_manager()))
  with check ((select private.is_owner()) or (select private.is_production_manager()));

create policy shifts_select
  on public.shifts for select to authenticated
  using (true);
create policy shifts_insert
  on public.shifts for insert to authenticated
  with check ((select private.is_owner()) or (select private.is_production_manager()));
create policy shifts_update
  on public.shifts for update to authenticated
  using ((select private.is_owner()) or (select private.is_production_manager()))
  with check ((select private.is_owner()) or (select private.is_production_manager()));

create policy timesheets_select
  on public.timesheets for select to authenticated
  using (
    profile_id = (select auth.uid())
    or (select private.is_owner())
    or (select private.is_production_manager())
    or (
      (select private.is_payroll_admin())
      and status in ('approved', 'sent', 'processed')
    )
  );
create policy timesheets_insert
  on public.timesheets for insert to authenticated
  with check (
    profile_id = (select auth.uid())
    or (select private.is_owner())
    or (select private.is_production_manager())
  );
create policy timesheets_update_own
  on public.timesheets for update to authenticated
  using (
    profile_id = (select auth.uid())
    and status in ('draft', 'returned')
  )
  with check (
    profile_id = (select auth.uid())
    and status in ('draft', 'submitted', 'returned')
  );
create policy timesheets_update_manager
  on public.timesheets for update to authenticated
  using ((select private.is_owner()) or (select private.is_production_manager()))
  with check ((select private.is_owner()) or (select private.is_production_manager()));

create policy timesheet_entries_select
  on public.timesheet_entries for select to authenticated
  using (
    exists (
      select 1
      from public.timesheets t
      where t.id = timesheet_id
        and (
          t.profile_id = (select auth.uid())
          or (select private.is_owner())
          or (select private.is_production_manager())
          or (
            (select private.is_payroll_admin())
            and t.status in ('approved', 'sent', 'processed')
          )
        )
    )
  );
create policy timesheet_entries_insert
  on public.timesheet_entries for insert to authenticated
  with check (
    exists (
      select 1
      from public.timesheets t
      where t.id = timesheet_id
        and t.status in ('draft', 'returned')
        and (
          t.profile_id = (select auth.uid())
          or (select private.is_owner())
        )
    )
  );
create policy timesheet_entries_update
  on public.timesheet_entries for update to authenticated
  using (
    exists (
      select 1
      from public.timesheets t
      where t.id = timesheet_id
        and t.status in ('draft', 'returned')
        and t.profile_id = (select auth.uid())
    )
  )
  with check (
    exists (
      select 1
      from public.timesheets t
      where t.id = timesheet_id
        and t.status in ('draft', 'returned')
        and t.profile_id = (select auth.uid())
    )
  );
create policy timesheet_entries_update_owner
  on public.timesheet_entries for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));
