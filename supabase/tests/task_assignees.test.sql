-- Any active person can be assigned a task. A turned-off account cannot.
-- A program director can see and update only the task assigned to them.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(9);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b1',
    'authenticated', 'authenticated', 'assign-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b2',
    'authenticated', 'authenticated', 'assign-director@example.com',
    '{"role":"program_director","full_name":"SAMPLE Director"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b3',
    'authenticated', 'authenticated', 'assign-payroll@example.com',
    '{"role":"payroll_admin","full_name":"SAMPLE Payroll"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b4',
    'authenticated', 'authenticated', 'assign-contractor@example.com',
    '{"role":"employee","full_name":"SAMPLE Contractor"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b5',
    'authenticated', 'authenticated', 'assign-off@example.com',
    '{"role":"employee","full_name":"SAMPLE Off"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

update public.profiles
set employment_type = 'contractor'
where id = '00000000-0000-0000-0000-0000000000b4';

update public.profiles
set is_active = false
where id = '00000000-0000-0000-0000-0000000000b5';

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

select tests.claims('00000000-0000-0000-0000-0000000000b1');
set role authenticated;

select lives_ok(
  $$
    insert into public.tasks (title, created_by, assigned_to)
    values (
      'SAMPLE director hem',
      '00000000-0000-0000-0000-0000000000b1',
      '00000000-0000-0000-0000-0000000000b2'
    )
  $$,
  'an owner can assign a task to a program director'
);

select lives_ok(
  $$
    insert into public.tasks (title, created_by, assigned_to)
    values (
      'SAMPLE payroll count',
      '00000000-0000-0000-0000-0000000000b1',
      '00000000-0000-0000-0000-0000000000b3'
    )
  $$,
  'an owner can assign a task to payroll'
);

select lives_ok(
  $$
    insert into public.tasks (title, created_by, assigned_to)
    values (
      'SAMPLE contractor stitch',
      '00000000-0000-0000-0000-0000000000b1',
      '00000000-0000-0000-0000-0000000000b4'
    )
  $$,
  'an owner can assign a task to a contractor'
);

select throws_ok(
  $$
    insert into public.tasks (title, created_by, assigned_to)
    values (
      'SAMPLE turned off',
      '00000000-0000-0000-0000-0000000000b1',
      '00000000-0000-0000-0000-0000000000b5'
    )
  $$,
  '42501',
  null,
  'a turned-off account cannot be assigned a task'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000b2');
set role authenticated;

select is(
  (select count(*)::int from public.tasks),
  1,
  'a program director sees only the task assigned to them'
);

select lives_ok(
  $$
    update public.tasks
    set status = 'in_progress'
    where title = 'SAMPLE director hem'
  $$,
  'a program director can update the task assigned to them'
);

select throws_ok(
  $$
    insert into public.tasks (title, created_by, assigned_to)
    values (
      'SAMPLE director creates',
      '00000000-0000-0000-0000-0000000000b2',
      '00000000-0000-0000-0000-0000000000b2'
    )
  $$,
  '42501',
  null,
  'a program director still cannot create a task'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000b3');
set role authenticated;

select is(
  (select title from public.tasks),
  'SAMPLE payroll count',
  'payroll sees the task assigned to them and not the others'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000b4');
set role authenticated;

select is(
  (select count(*)::int from public.tasks where title = 'SAMPLE director hem'),
  0,
  'a contractor cannot see a task assigned to someone else'
);

select * from finish();
rollback;
