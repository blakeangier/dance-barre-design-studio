-- Home address and emergency contacts stay with the person, owners, and payroll.

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
    '00000000-0000-0000-0000-0000000000d1',
    'authenticated', 'authenticated', 'hr-employee@example.com',
    '{"role":"employee","full_name":"SAMPLE Staff"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d2',
    'authenticated', 'authenticated', 'hr-other@example.com',
    '{"role":"employee","full_name":"SAMPLE Other"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d3',
    'authenticated', 'authenticated', 'hr-production@example.com',
    '{"role":"production_manager","full_name":"SAMPLE Production"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d4',
    'authenticated', 'authenticated', 'hr-payroll@example.com',
    '{"role":"payroll_admin","full_name":"SAMPLE Payroll"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

insert into public.employee_private (profile_id, street, city)
values (
  '00000000-0000-0000-0000-0000000000d1',
  'SAMPLE street',
  'Windsor'
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

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000d2');
set role authenticated;

select is(
  (select count(*)::int from public.employee_private),
  0,
  'an employee cannot read another person''s private details'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000d3');
set role authenticated;

select is(
  (select count(*)::int from public.employee_private),
  0,
  'the production manager cannot read private staff details'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000d4');
set role authenticated;

select is(
  (select street from public.employee_private where profile_id = '00000000-0000-0000-0000-0000000000d1'),
  'SAMPLE street',
  'payroll can read private staff details'
);

update public.employee_private
set city = 'SAMPLE city'
where profile_id = '00000000-0000-0000-0000-0000000000d1';

select is(
  (
    select new_data->>'city'
    from public.audit_log
    where table_name = 'employee_private'
      and action = 'UPDATE'
      and actor_id = '00000000-0000-0000-0000-0000000000d4'
    order by id desc
    limit 1
  ),
  'SAMPLE city',
  'payroll edits of private details are audited'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000d1');
set role authenticated;

select is(
  (select street from public.employee_private),
  'SAMPLE street',
  'a person can read their own private details'
);

select * from finish();
rollback;
