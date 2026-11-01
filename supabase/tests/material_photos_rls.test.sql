-- Fabric photos. Everyone signed in can see them.
-- Only an owner or the production manager can add one.
-- A photo is archived, not deleted.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions, storage;

select plan(6);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000f1',
    'authenticated', 'authenticated', 'photo-employee@example.com',
    '{"role":"employee","full_name":"SAMPLE Employee"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000f2',
    'authenticated', 'authenticated', 'photo-production@example.com',
    '{"role":"production_manager","full_name":"SAMPLE Elaine"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

insert into public.materials (material_code, fabric_name)
values ('SAMPLE-PHOTO', 'SAMPLE knit');

insert into public.material_photos (material_id, storage_path, is_primary, taken_by)
select id, 'sample/photo.webp', true, '00000000-0000-0000-0000-0000000000f2'
from public.materials
where material_code = 'SAMPLE-PHOTO';

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
select tests.claims('00000000-0000-0000-0000-0000000000f1');
set role authenticated;

select is(
  (select count(*)::int from public.material_photos),
  1,
  'an employee can see a fabric photo'
);

select throws_ok(
  $$insert into public.material_photos (material_id, storage_path, taken_by)
    select id, 'sample/employee.webp', '00000000-0000-0000-0000-0000000000f1'
    from public.materials where material_code = 'SAMPLE-PHOTO'$$,
  '42501',
  null,
  'an employee cannot add a fabric photo'
);

select throws_ok(
  $$insert into storage.objects (bucket_id, name)
    values ('material-photos', 'sample/employee.webp')$$,
  '42501',
  null,
  'an employee cannot upload into the photo bucket'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000f2');
set role authenticated;

insert into public.material_photos (material_id, storage_path, taken_by)
select id, 'sample/elaine.webp', '00000000-0000-0000-0000-0000000000f2'
from public.materials
where material_code = 'SAMPLE-PHOTO';

select is(
  (
    select count(*)::int
    from public.material_photos
    where storage_path = 'sample/elaine.webp'
  ),
  1,
  'the production manager can add a fabric photo'
);

insert into storage.objects (bucket_id, name)
values ('material-photos', 'sample/elaine.webp');

select is(
  (
    select count(*)::int
    from storage.objects
    where bucket_id = 'material-photos' and name = 'sample/elaine.webp'
  ),
  1,
  'the production manager can upload into the photo bucket'
);

select throws_ok(
  $$delete from public.material_photos where storage_path = 'sample/elaine.webp'$$,
  '42501',
  null,
  'a photo cannot be deleted'
);

select * from finish();
rollback;
