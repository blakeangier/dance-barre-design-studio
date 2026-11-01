-- Production seasons are owners only. No dates are seeded.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(5);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c1',
    'authenticated', 'authenticated', 'season-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c4',
    'authenticated', 'authenticated', 'season-emp@example.com',
    '{"role":"employee","full_name":"SAMPLE Maker"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

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
  (select count(*)::int from public.production_seasons),
  0,
  'no production season dates are seeded'
);

select is(
  (select payroll_runs from public.finance_run_settings),
  'production_only',
  'payroll defaults to production days only'
);

select tests.claims('00000000-0000-0000-0000-0000000000c1');
set role authenticated;

select lives_ok(
  $$
    insert into public.production_seasons (name, start_date, end_date)
    values ('SAMPLE season', date '2026-10-01', date '2026-10-10')
  $$,
  'an owner can save a SAMPLE season'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c4');
set role authenticated;

select is(
  (select count(*)::int from public.production_seasons),
  0,
  'an employee sees no seasons'
);

select throws_ok(
  $$
    insert into public.production_seasons (name, start_date, end_date)
    values ('SAMPLE hidden', date '2026-11-01', date '2026-11-02')
  $$,
  '42501',
  null,
  'an employee cannot add a season'
);

select * from finish();

rollback;
