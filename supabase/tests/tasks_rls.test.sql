-- Tasks: employees see their own, owners and the production manager see all,
-- program directors see none. No deletes.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(18);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000a1',
    'authenticated', 'authenticated', 'task-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000a2',
    'authenticated', 'authenticated', 'task-pm@example.com',
    '{"role":"production_manager","full_name":"SAMPLE PM"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000a3',
    'authenticated', 'authenticated', 'task-emp@example.com',
    '{"role":"employee","full_name":"SAMPLE Maker"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000a4',
    'authenticated', 'authenticated', 'task-dir@example.com',
    '{"role":"program_director","full_name":"SAMPLE Director"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000a5',
    'authenticated', 'authenticated', 'task-jialin@example.com',
    '{"role":"employee","can_update_order_status":true,"full_name":"SAMPLE Jialin"}'::jsonb,
    '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000a6',
    'authenticated', 'authenticated', 'task-sew@example.com',
    '{"role":"employee","full_name":"SAMPLE Sew"}'::jsonb, '{}'::jsonb,
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

select tests.claims('00000000-0000-0000-0000-0000000000a3');
set role authenticated;

select lives_ok(
  $$
    insert into public.tasks (title, created_by, assigned_to)
    values (
      'SAMPLE hem my leo',
      '00000000-0000-0000-0000-0000000000a3',
      '00000000-0000-0000-0000-0000000000a3'
    )
  $$,
  'an employee can create a task for themselves'
);

select throws_ok(
  $$
    insert into public.tasks (title, created_by, assigned_to)
    values (
      'SAMPLE not mine',
      '00000000-0000-0000-0000-0000000000a3',
      '00000000-0000-0000-0000-0000000000a6'
    )
  $$,
  '42501',
  null,
  'an employee cannot assign a task to someone else'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a5');
set role authenticated;

select lives_ok(
  $$
    insert into public.tasks (title, created_by, assigned_to, priority)
    values (
      'SAMPLE press order',
      '00000000-0000-0000-0000-0000000000a5',
      '00000000-0000-0000-0000-0000000000a6',
      'high'
    )
  $$,
  'someone who can update order status can assign a task'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a4');
set role authenticated;

select throws_ok(
  $$
    insert into public.tasks (title, created_by, assigned_to)
    values (
      'SAMPLE director',
      '00000000-0000-0000-0000-0000000000a4',
      '00000000-0000-0000-0000-0000000000a4'
    )
  $$,
  '42501',
  null,
  'a program director cannot create a task'
);

select is(
  (select count(*)::int from public.tasks),
  0,
  'a program director sees no tasks'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a3');
set role authenticated;

select is(
  (select count(*)::int from public.tasks where title = 'SAMPLE press order'),
  0,
  'an employee does not see a task they did not create or receive'
);

select is(
  (select count(*)::int from public.tasks where title = 'SAMPLE hem my leo'),
  1,
  'an employee sees the task they created for themselves'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a1');
set role authenticated;

select is(
  (select count(*)::int from public.tasks where title like 'SAMPLE %'),
  2,
  'an owner sees every task'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a2');
set role authenticated;

select is(
  (select count(*)::int from public.tasks where title like 'SAMPLE %'),
  2,
  'the production manager sees every task'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a6');
set role authenticated;

select lives_ok(
  $$
    update public.tasks
    set status = 'in_progress'
    where title = 'SAMPLE press order'
  $$,
  'the assignee can move their task to in progress'
);

select throws_ok(
  $$
    update public.tasks
    set status = 'cancelled'
    where title = 'SAMPLE press order'
  $$,
  '42501',
  'You cannot cancel this task',
  'the assignee cannot cancel a task they did not create'
);

select throws_ok(
  $$
    update public.tasks
    set status = 'waiting'
    where assigned_to = '00000000-0000-0000-0000-0000000000a6'
  $$,
  '23514',
  null,
  'waiting requires a short reason'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a3');
set role authenticated;

select throws_ok(
  $$
    delete from public.tasks where title = 'SAMPLE hem my leo'
  $$,
  '42501',
  null,
  'a task cannot be deleted'
);

reset role;
create temp table sample_press as
select id from public.tasks where title = 'SAMPLE press order';
select tests.claims('00000000-0000-0000-0000-0000000000a3');
set role authenticated;

select throws_ok(
  $$
    insert into public.task_notes (task_id, body, author_id)
    select id, 'SAMPLE not my task', '00000000-0000-0000-0000-0000000000a3'
    from sample_press
  $$,
  '42501',
  null,
  'an employee cannot comment on someone else''s task'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a6');
set role authenticated;

select lives_ok(
  $$
    insert into public.task_notes (task_id, body, author_id)
    select id, 'SAMPLE pinned the side', '00000000-0000-0000-0000-0000000000a6'
    from public.tasks
    where title = 'SAMPLE press order'
  $$,
  'the assignee can post a note'
);

select lives_ok(
  $$
    update public.task_notes
    set body = 'SAMPLE pinned the side seam'
    where body = 'SAMPLE pinned the side'
  $$,
  'the author can edit a note inside 15 minutes'
);

select is(
  (
    select count(*)::int
    from public.task_status_events event
    join public.tasks task on task.id = event.task_id
    where task.title = 'SAMPLE press order'
      and event.to_status = 'in_progress'
      and event.from_status = 'to_do'
  ),
  1,
  'a status change is kept, with who it was before'
);

reset role;
select set_config('request.jwt.claim.sub', '', true);
select set_config('request.jwt.claims', '', true);
update public.task_notes
set created_at = now() - interval '16 minutes'
where body = 'SAMPLE pinned the side seam';

select tests.claims('00000000-0000-0000-0000-0000000000a6');
set role authenticated;

select throws_ok(
  $$
    update public.task_notes
    set body = 'SAMPLE too late'
    where body = 'SAMPLE pinned the side seam'
  $$,
  '42501',
  'A note can be edited for 15 minutes',
  'a note locks after 15 minutes'
);

select * from finish();

rollback;
