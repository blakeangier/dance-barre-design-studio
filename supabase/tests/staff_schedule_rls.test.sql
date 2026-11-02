-- Staff schedule access. An employee reads only their own shifts.
-- Payroll can read every shift and cannot edit. A flagged person can edit.
-- A program director still cannot create a task.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(13);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c1',
    'authenticated', 'authenticated', 'sched2-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c2',
    'authenticated', 'authenticated', 'sched2-emp@example.com',
    '{"role":"employee","full_name":"SAMPLE Maker"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c3',
    'authenticated', 'authenticated', 'sched2-other@example.com',
    '{"role":"employee","full_name":"SAMPLE Other"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c4',
    'authenticated', 'authenticated', 'sched2-pay@example.com',
    '{"role":"payroll_admin","full_name":"SAMPLE Payroll"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c5',
    'authenticated', 'authenticated', 'sched2-flag@example.com',
    '{"role":"employee","can_edit_schedule":true,"full_name":"SAMPLE Jialin"}'::jsonb,
    '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c6',
    'authenticated', 'authenticated', 'sched2-dir@example.com',
    '{"role":"program_director","full_name":"SAMPLE Director"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

select is(
  (
    select can_edit_schedule
    from public.profiles
    where id = '00000000-0000-0000-0000-0000000000c2'
  ),
  false,
  'the schedule flag defaults to off'
);

select is(
  (
    select can_edit_schedule
    from public.profiles
    where id = '00000000-0000-0000-0000-0000000000c5'
  ),
  true,
  'app metadata can turn the schedule flag on'
);

insert into public.staff_shifts (
  profile_id, shift_date, start_time, end_time, break_minutes, notes, created_by
) values
  (
    '00000000-0000-0000-0000-0000000000c2',
    date '2026-11-02', time '09:00', time '15:00', 30,
    'SAMPLE — maker shift',
    '00000000-0000-0000-0000-0000000000c1'
  ),
  (
    '00000000-0000-0000-0000-0000000000c3',
    date '2026-11-02', time '10:00', time '14:00', 0,
    'SAMPLE — other shift',
    '00000000-0000-0000-0000-0000000000c1'
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

select tests.claims('00000000-0000-0000-0000-0000000000c2');
set role authenticated;

select is(
  (select count(*)::int from public.staff_shifts),
  1,
  'an employee sees only their own shift'
);

select throws_ok(
  $$
    insert into public.staff_shifts (
      profile_id, shift_date, start_time, end_time, created_by
    ) values (
      '00000000-0000-0000-0000-0000000000c2',
      date '2026-11-03', time '09:00', time '12:00',
      '00000000-0000-0000-0000-0000000000c2'
    )
  $$,
  '42501',
  null,
  'an employee cannot add a shift'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c4');
set role authenticated;

select is(
  (select count(*)::int from public.staff_shifts),
  2,
  'payroll can read every shift'
);

update public.staff_shifts set notes = 'nope';

reset role;
select is(
  (select count(*)::int from public.staff_shifts where notes = 'nope'),
  0,
  'payroll cannot edit a shift without the flag'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c5');
set role authenticated;

select lives_ok(
  $$
    insert into public.staff_shifts (
      profile_id, shift_date, start_time, end_time, notes, created_by
    ) values (
      '00000000-0000-0000-0000-0000000000c3',
      date '2026-11-04', time '09:00', time '13:00',
      'SAMPLE — flagged edit',
      '00000000-0000-0000-0000-0000000000c5'
    )
  $$,
  'a person with the schedule flag can add a shift'
);

select throws_ok(
  $$
    delete from public.staff_shifts
  $$,
  '42501',
  null,
  'a shift cannot be deleted'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c6');
set role authenticated;

select is(
  (select count(*)::int from public.staff_shifts),
  0,
  'a program director does not see other people''s shifts'
);

select throws_ok(
  $$
    insert into public.tasks (title, created_by, assigned_to)
    values (
      'SAMPLE director task',
      '00000000-0000-0000-0000-0000000000c6',
      '00000000-0000-0000-0000-0000000000c6'
    )
  $$,
  '42501',
  null,
  'a program director still cannot create a task'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c1');
set role authenticated;

select lives_ok(
  $$
    update public.staff_shifts
    set archived_at = now()
    where notes = 'SAMPLE — other shift'
  $$,
  'an owner can archive a shift'
);

select is(
  (
    select count(*)::int
    from public.staff_shifts
    where notes = 'SAMPLE — other shift'
      and archived_at is null
  ),
  0,
  'an archived shift leaves the week view'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c2');
set role authenticated;

select is(
  (select count(*)::int from public.staff_shifts where notes = 'SAMPLE — other shift'),
  0,
  'an employee does not see an archived shift'
);

select * from finish();
rollback;
