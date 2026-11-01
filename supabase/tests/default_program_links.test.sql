-- New non-owner accounts start linked to every program and turned on.
-- An owner does not. A later login update does not restore a box an owner
-- unchecked. Linking again does not duplicate rows.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(7);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d1',
    'authenticated', 'authenticated', 'default-employee@example.com',
    '{"role":"employee","full_name":"SAMPLE Employee"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d2',
    'authenticated', 'authenticated', 'default-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d3',
    'authenticated', 'authenticated', 'default-director@example.com',
    '{"role":"program_director","full_name":"SAMPLE Director"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

select is(
  (select is_active from public.profiles where id = '00000000-0000-0000-0000-0000000000d1'),
  true,
  'a new account is on'
);

select is(
  (
    select count(*)::int
    from public.director_programs
    where profile_id = '00000000-0000-0000-0000-0000000000d1'
  ),
  (select count(*)::int from public.programs),
  'a new employee is linked to every program'
);

select is(
  (
    select count(*)::int
    from public.director_programs
    where profile_id = '00000000-0000-0000-0000-0000000000d2'
  ),
  0,
  'a new owner is not linked to programs'
);

select is(
  (
    select count(*)::int
    from public.director_programs
    where profile_id = '00000000-0000-0000-0000-0000000000d3'
  ),
  (select count(*)::int from public.programs),
  'a new program director starts with every program'
);

delete from public.director_programs
where profile_id = '00000000-0000-0000-0000-0000000000d1'
  and program_id = (select id from public.programs where name = 'CREW');

update auth.users
set raw_app_meta_data = raw_app_meta_data || '{"full_name":"SAMPLE Renamed"}'::jsonb
where id = '00000000-0000-0000-0000-0000000000d1';

select is(
  (
    select count(*)::int
    from public.director_programs
    where profile_id = '00000000-0000-0000-0000-0000000000d1'
  ),
  (select count(*)::int from public.programs) - 1,
  'updating the login does not put a removed program back'
);

select private.link_all_programs('00000000-0000-0000-0000-0000000000d1');

select is(
  (
    select count(*)::int
    from public.director_programs
    where profile_id = '00000000-0000-0000-0000-0000000000d1'
  ),
  (select count(*)::int from public.programs) - 1,
  'a partial set of programs is left alone'
);

delete from public.director_programs
where profile_id = '00000000-0000-0000-0000-0000000000d1';

select private.link_all_programs('00000000-0000-0000-0000-0000000000d1');
select private.link_all_programs('00000000-0000-0000-0000-0000000000d1');

select is(
  (
    select count(*)::int
    from public.director_programs
    where profile_id = '00000000-0000-0000-0000-0000000000d1'
  ),
  (select count(*)::int from public.programs),
  'linking someone with no programs is safe to run twice'
);

select * from finish();
rollback;
