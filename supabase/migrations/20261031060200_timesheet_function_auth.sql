-- The timesheet helpers are security definer, so each one checks the caller
-- before it writes. Owners, the production manager, and payroll can process
-- or reopen a period. An employee can open only their own timesheet.
-- schedule_timesheets.sql is already applied on dev, so this replaces the
-- functions instead of editing that file.

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
  if (select auth.uid()) is null then
    raise exception 'Sign in first' using errcode = '42501';
  end if;
  if (select auth.uid()) is distinct from target_profile
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

create or replace function public.mark_pay_period_processed(p_start date)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_owner()
    and not private.is_production_manager()
    and not private.is_payroll_admin()
  then
    raise exception 'Only an owner, the production manager, or payroll can mark a period processed'
      using errcode = '42501';
  end if;

  perform set_config('app.pay_period_lock', 'on', true);

  update public.pay_periods
  set status = 'processed',
      processed_at = now(),
      processed_by = (select auth.uid())
  where period_start = p_start
    and status = 'open';

  update public.timesheets
  set status = 'processed',
      processed_at = now()
  where period_start = p_start
    and status in ('approved', 'sent');
end;
$$;

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
  if not private.is_owner()
    and not private.is_production_manager()
    and not private.is_payroll_admin()
  then
    raise exception 'Only an owner, the production manager, or payroll can reopen a timesheet'
      using errcode = '42501';
  end if;

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

revoke all on function public.ensure_timesheet(uuid, date, date) from public, anon;
revoke all on function public.mark_pay_period_processed(date) from public, anon;
revoke all on function public.reopen_timesheet(bigint, text) from public, anon;

grant execute on function public.ensure_timesheet(uuid, date, date) to authenticated;
grant execute on function public.mark_pay_period_processed(date) to authenticated;
grant execute on function public.reopen_timesheet(bigint, text) to authenticated;
