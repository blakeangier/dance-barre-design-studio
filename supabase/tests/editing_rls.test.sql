-- Owners and production managers can edit. Employees cannot.
-- Deletes do not remove rows. Edits land in the audit log.

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
    '00000000-0000-0000-0000-0000000000c1',
    'authenticated', 'authenticated', 'edit-employee@example.com',
    '{"role":"employee","full_name":"SAMPLE Employee"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c2',
    'authenticated', 'authenticated', 'edit-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c3',
    'authenticated', 'authenticated', 'edit-production@example.com',
    '{"role":"production_manager","full_name":"SAMPLE Production"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

insert into public.materials (material_code, fabric_name)
values ('SAMPLE-EDIT', 'SAMPLE knit');

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

update public.materials
set fabric_name = 'Hacked'
where material_code = 'SAMPLE-EDIT';

select is(
  (select fabric_name from public.materials where material_code = 'SAMPLE-EDIT'),
  'SAMPLE knit',
  'employee cannot edit a material'
);

select throws_ok(
  $$delete from public.materials where material_code = 'SAMPLE-EDIT'$$,
  '42501',
  null,
  'employee cannot delete a material'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c2');
set role authenticated;

update public.materials
set fabric_name = 'SAMPLE owner edit'
where material_code = 'SAMPLE-EDIT';

select is(
  (select fabric_name from public.materials where material_code = 'SAMPLE-EDIT'),
  'SAMPLE owner edit',
  'owner can edit a material'
);

select is(
  (
    select old_data->>'fabric_name'
    from public.audit_log
    where table_name = 'materials'
      and action = 'UPDATE'
      and actor_id = '00000000-0000-0000-0000-0000000000c2'
      and new_data->>'fabric_name' = 'SAMPLE owner edit'
    order by id desc
    limit 1
  ),
  'SAMPLE knit',
  'audit log keeps who changed the material and the previous name'
);

select is(
  (
    select new_data->>'fabric_name'
    from public.audit_log
    where table_name = 'materials'
      and action = 'UPDATE'
      and actor_id = '00000000-0000-0000-0000-0000000000c2'
      and record_id = (
        select id::text from public.materials where material_code = 'SAMPLE-EDIT'
      )
    order by id desc
    limit 1
  ),
  'SAMPLE owner edit',
  'audit log keeps the new name'
);

select throws_ok(
  $$delete from public.materials where material_code = 'SAMPLE-EDIT'$$,
  '42501',
  null,
  'owner cannot delete a material'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c3');
set role authenticated;

update public.materials
set bin_location = 'SAMPLE bin'
where material_code = 'SAMPLE-EDIT';

select is(
  (select bin_location from public.materials where material_code = 'SAMPLE-EDIT'),
  'SAMPLE bin',
  'production manager can edit a material'
);

select * from finish();
rollback;
