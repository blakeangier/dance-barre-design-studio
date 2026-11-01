-- Security-definer timesheet helpers check the caller. SAMPLE people only.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(8);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d1',
    'authenticated', 'authenticated', 'fn-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d2',
    'authenticated', 'authenticated', 'fn-pm@example.com',
    '{"role":"production_manager","full_name":"SAMPLE Elaine"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d3',
    'authenticated', 'authenticated', 'fn-pay@example.com',
    '{"role":"payroll_admin","full_name":"SAMPLE Rebecca"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d4',
    'authenticated', 'authenticated', 'fn-emp@example.com',
    '{"role":"employee","full_name":"SAMPLE Maker"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d5',
    'authenticated', 'authenticated', 'fn-other@example.com',
    '{"role":"employee","full_name":"SAMPLE Other"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

insert into public.timesheets (profile_id, period_start, period_end, status)
values (
  '00000000-0000-0000-0000-0000000000d4',
  date '2026-02-02',
  date '2026-02-15',
  'approved'
);

insert into public.pay_periods (period_start, period_end)
values (date '2026-02-02', date '2026-02-15');

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

select is(
  has_function_privilege('anon', 'public.ensure_timesheet(uuid,date,date)', 'execute'),
  false,
  'anon cannot execute ensure_timesheet'
);

select is(
  has_function_privilege('anon', 'public.mark_pay_period_processed(date)', 'execute'),
  false,
  'anon cannot execute mark_pay_period_processed'
);

select is(
  has_function_privilege('anon', 'public.reopen_timesheet(bigint,text)', 'execute'),
  false,
  'anon cannot execute reopen_timesheet'
);

select tests.claims('00000000-0000-0000-0000-0000000000d4');
set role authenticated;

select lives_ok(
  $$
    select public.ensure_timesheet(
      '00000000-0000-0000-0000-0000000000d4',
      date '2026-02-16',
      date '2026-03-01'
    )
  $$,
  'an employee can open their own timesheet'
);

select throws_ok(
  $$
    select public.ensure_timesheet(
      '00000000-0000-0000-0000-0000000000d5',
      date '2026-02-16',
      date '2026-03-01'
    )
  $$,
  '42501',
  'You cannot open that timesheet',
  'an employee cannot open someone else''s timesheet'
);

select throws_ok(
  $$ select public.mark_pay_period_processed(date '2026-02-02') $$,
  '42501',
  'Only an owner, the production manager, or payroll can mark a period processed',
  'an employee cannot mark a pay period processed'
);

select throws_ok(
  $$
    select public.reopen_timesheet(
      (select id from public.timesheets where profile_id = '00000000-0000-0000-0000-0000000000d4' and period_start = date '2026-02-02'),
      'SAMPLE reason'
    )
  $$,
  '42501',
  'Only an owner, the production manager, or payroll can reopen a timesheet',
  'an employee cannot reopen a timesheet'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000d2');
set role authenticated;

select lives_ok(
  $$ select public.mark_pay_period_processed(date '2026-03-02') $$,
  'the production manager can mark a pay period processed'
);

select * from finish();

rollback;
