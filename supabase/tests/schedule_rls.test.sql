-- Timesheet access. Employees edit only their own open sheet.
-- Payroll can read approved hours and cannot change them.
-- A processed period is locked.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(6);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000e1',
    'authenticated', 'authenticated', 'sched-employee@example.com',
    '{"role":"employee","full_name":"SAMPLE Employee"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000e2',
    'authenticated', 'authenticated', 'sched-other@example.com',
    '{"role":"employee","full_name":"SAMPLE Other"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000e3',
    'authenticated', 'authenticated', 'sched-production@example.com',
    '{"role":"production_manager","full_name":"SAMPLE Elaine"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000e4',
    'authenticated', 'authenticated', 'sched-payroll@example.com',
    '{"role":"payroll_admin","full_name":"SAMPLE Rebecca"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000e5',
    'authenticated', 'authenticated', 'sched-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

insert into public.pay_periods (period_start, period_end)
values (date '2026-01-05', date '2026-01-18');

insert into public.timesheets (profile_id, period_start, period_end, status)
values (
  '00000000-0000-0000-0000-0000000000e1',
  date '2026-01-05',
  date '2026-01-18',
  'draft'
);

insert into public.timesheet_entries (
  timesheet_id, work_date,
  scheduled_starts_at, scheduled_ends_at, scheduled_break_minutes,
  actual_starts_at, actual_ends_at, actual_break_minutes
)
select id, date '2026-01-05',
  timestamptz '2026-01-05 14:00+00', timestamptz '2026-01-05 22:00+00', 30,
  timestamptz '2026-01-05 14:00+00', timestamptz '2026-01-05 22:00+00', 30
from public.timesheets
where profile_id = '00000000-0000-0000-0000-0000000000e1';

create schema if not exists tests;

create or replace function tests.claims(user_id uuid)
returns void language plpgsql as $$
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', user_id::text, 'role', 'authenticated', 'aud', 'authenticated')::text,
    true
  );
  perform set_config('request.jwt.claim.sub', user_id::text, true);
end;
$$;

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000e2');
set role authenticated;

update public.timesheet_entries
set actual_break_minutes = 5
where timesheet_id in (
  select id from public.timesheets
  where profile_id = '00000000-0000-0000-0000-0000000000e1'
);

reset role;
select is(
  (select actual_break_minutes from public.timesheet_entries limit 1),
  30,
  'an employee cannot edit another person''s timesheet'
);

select tests.claims('00000000-0000-0000-0000-0000000000e1');
set role authenticated;

update public.timesheets
set status = 'submitted', employee_submitted_at = now()
where profile_id = '00000000-0000-0000-0000-0000000000e1';

update public.timesheet_entries
set actual_break_minutes = 5
where timesheet_id in (
  select id from public.timesheets
  where profile_id = '00000000-0000-0000-0000-0000000000e1'
);

reset role;
select is(
  (select actual_break_minutes from public.timesheet_entries limit 1),
  30,
  'an employee cannot edit hours after submit'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000e3');
set role authenticated;

update public.timesheets
set status = 'approved',
    manager_approved_at = now(),
    manager_approved_by = '00000000-0000-0000-0000-0000000000e3'
where profile_id = '00000000-0000-0000-0000-0000000000e1';

select is(
  (select status from public.timesheets where profile_id = '00000000-0000-0000-0000-0000000000e1'),
  'approved',
  'the production manager can approve a submitted timesheet'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000e4');
set role authenticated;

update public.timesheet_entries
set actual_break_minutes = 99
where timesheet_id in (
  select id from public.timesheets
  where profile_id = '00000000-0000-0000-0000-0000000000e1'
);

reset role;
select is(
  (select actual_break_minutes from public.timesheet_entries limit 1),
  30,
  'payroll cannot edit hours'
);

select tests.claims('00000000-0000-0000-0000-0000000000e4');
set role authenticated;

select public.mark_pay_period_processed(date '2026-01-05');

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000e5');
set role authenticated;

select throws_ok(
  $$update public.timesheet_entries set actual_break_minutes = 15$$,
  '42501',
  null,
  'a processed period is locked'
);

select is(
  (select status from public.timesheets where profile_id = '00000000-0000-0000-0000-0000000000e1'),
  'processed',
  'payroll processing locks the timesheet'
);

select * from finish();
rollback;
