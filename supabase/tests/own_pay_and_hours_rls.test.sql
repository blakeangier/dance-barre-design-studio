-- A person can read their own pay rate and timesheet, and not someone else's.
-- Payroll and owners still read every rate. The person cannot change a rate.
-- cost_rates and employee_private stay closed.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(12);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c1',
    'authenticated', 'authenticated', 'pay-contractor@example.com',
    '{"role":"employee","full_name":"SAMPLE Contractor"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c2',
    'authenticated', 'authenticated', 'pay-employee@example.com',
    '{"role":"employee","full_name":"SAMPLE Employee"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c3',
    'authenticated', 'authenticated', 'pay-payroll@example.com',
    '{"role":"payroll_admin","full_name":"SAMPLE Payroll"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c4',
    'authenticated', 'authenticated', 'pay-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

update public.profiles
set employment_type = 'contractor'
where id = '00000000-0000-0000-0000-0000000000c1';

insert into public.employee_compensation (
  profile_id, entity_id, currency, hourly_rate, effective_from, notes
)
select
  '00000000-0000-0000-0000-0000000000c1',
  id,
  'CAD',
  18.0000,
  date '2026-01-01',
  'SAMPLE — not a real pay rate'
from public.business_entities
where legal_name = 'Dance Barre Design Studio Inc.';

insert into public.employee_compensation (
  profile_id, entity_id, currency, hourly_rate, effective_from, notes
)
select
  '00000000-0000-0000-0000-0000000000c2',
  id,
  'CAD',
  22.0000,
  date '2026-01-01',
  'SAMPLE — not a real pay rate'
from public.business_entities
where legal_name = 'Dance Barre Design Studio Inc.';

insert into public.employee_private (profile_id, street)
values ('00000000-0000-0000-0000-0000000000c2', 'SAMPLE street');

insert into public.pay_periods (period_start, period_end)
values (date '2026-03-02', date '2026-03-15');

insert into public.timesheets (profile_id, period_start, period_end, status)
values
  (
    '00000000-0000-0000-0000-0000000000c1',
    date '2026-03-02',
    date '2026-03-15',
    'draft'
  ),
  (
    '00000000-0000-0000-0000-0000000000c2',
    date '2026-03-02',
    date '2026-03-15',
    'approved'
  );

insert into public.timesheet_entries (
  timesheet_id, work_date,
  actual_starts_at, actual_ends_at, actual_break_minutes
)
select id, date '2026-03-02',
  timestamptz '2026-03-02 14:00+00', timestamptz '2026-03-02 18:00+00', 0
from public.timesheets
where profile_id = '00000000-0000-0000-0000-0000000000c1';

insert into public.timesheet_entries (
  timesheet_id, work_date,
  actual_starts_at, actual_ends_at, actual_break_minutes
)
select id, date '2026-03-03',
  timestamptz '2026-03-03 14:00+00', timestamptz '2026-03-03 22:00+00', 30
from public.timesheets
where profile_id = '00000000-0000-0000-0000-0000000000c2';

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
select tests.claims('00000000-0000-0000-0000-0000000000c1');
set role authenticated;

select is(
  (select hourly_rate from public.employee_compensation),
  18.0000,
  'a contractor can read their own pay rate'
);
select is(
  (
    select count(*)::int
    from public.employee_compensation
    where profile_id = '00000000-0000-0000-0000-0000000000c2'
  ),
  0,
  'a contractor cannot read another person''s pay rate'
);
select is(
  (select count(*)::int from public.timesheets),
  1,
  'a contractor can read their own timesheet'
);
select is(
  (
    select count(*)::int
    from public.timesheets
    where profile_id = '00000000-0000-0000-0000-0000000000c2'
  ),
  0,
  'a contractor cannot read another person''s timesheet'
);
select is(
  (select count(*)::int from public.timesheet_entries),
  1,
  'a contractor cannot read another person''s timesheet lines'
);
select is(
  (select count(*)::int from public.cost_rates),
  0,
  'a contractor cannot read internal cost rates'
);
select is(
  (select count(*)::int from public.employee_private),
  0,
  'a contractor cannot read private staff records'
);

select throws_ok(
  $$update public.employee_compensation set hourly_rate = 99$$,
  '42501',
  null,
  'a contractor cannot change a pay rate'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c2');
set role authenticated;

select is(
  (select hourly_rate from public.employee_compensation),
  22.0000,
  'an employee can read their own pay rate'
);
select is(
  (
    select count(*)::int
    from public.timesheets
    where profile_id = '00000000-0000-0000-0000-0000000000c1'
  ),
  0,
  'an employee cannot read another person''s timesheet'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c3');
set role authenticated;

select is(
  (select count(*)::int from public.employee_compensation),
  2,
  'payroll can still read every pay rate'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c4');
set role authenticated;

select is(
  (select count(*)::int from public.employee_compensation),
  2,
  'an owner can still read every pay rate'
);

select * from finish();
rollback;
