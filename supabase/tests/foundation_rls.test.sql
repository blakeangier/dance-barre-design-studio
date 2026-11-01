-- Proves role separation in the database.
-- Sample rows created here are rolled back with the test transaction.
-- They are not real pay rates, prices, or employees.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon, service_role;
-- Supabase puts `extensions` on the search path. A plain Postgres does not.
set search_path to public, extensions;

select plan(62);

create schema if not exists tests;

-- JWT claims only. Role changes stay at the top level (`set role` / `reset role`)
-- because a normal function cannot promote itself back to the admin role.
create or replace function tests.claims(user_id uuid)
returns void
language plpgsql
as $$
begin
  perform set_config(
    'request.jwt.claims',
    json_build_object(
      'sub', user_id::text,
      'role', 'authenticated',
      'aud', 'authenticated'
    )::text,
    true
  );
  perform set_config('request.jwt.claim.sub', user_id::text, true);
end;
$$;

create or replace function tests.clear_claims()
returns void
language plpgsql
as $$
begin
  perform set_config('request.jwt.claims', '', true);
  perform set_config('request.jwt.claim.sub', '', true);
end;
$$;

-- Fixed ids keep the assertions easy to read.
insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  recovery_token
)
values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000a1',
    'authenticated',
    'authenticated',
    'sample-owner@example.com',
    extensions.crypt('SamplePassword1', extensions.gen_salt('bf')),
    '{"provider":"email","providers":["email"],"role":"owner","full_name":"SAMPLE Owner","can_purchase":false}'::jsonb,
    '{}'::jsonb,
    now(),
    now(),
    '',
    '',
    ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000a2',
    'authenticated',
    'authenticated',
    'sample-production@example.com',
    extensions.crypt('SamplePassword1', extensions.gen_salt('bf')),
    '{"provider":"email","providers":["email"],"role":"production_manager","full_name":"SAMPLE Production"}'::jsonb,
    '{}'::jsonb,
    now(),
    now(),
    '',
    '',
    ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000a3',
    'authenticated',
    'authenticated',
    'sample-payroll@example.com',
    extensions.crypt('SamplePassword1', extensions.gen_salt('bf')),
    '{"provider":"email","providers":["email"],"role":"payroll_admin","full_name":"SAMPLE Payroll"}'::jsonb,
    '{}'::jsonb,
    now(),
    now(),
    '',
    '',
    ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000a4',
    'authenticated',
    'authenticated',
    'sample-employee@example.com',
    extensions.crypt('SamplePassword1', extensions.gen_salt('bf')),
    '{"provider":"email","providers":["email"],"role":"employee","full_name":"SAMPLE Employee"}'::jsonb,
    '{}'::jsonb,
    now(),
    now(),
    '',
    '',
    ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000a5',
    'authenticated',
    'authenticated',
    'sample-purchasing@example.com',
    extensions.crypt('SamplePassword1', extensions.gen_salt('bf')),
    '{"provider":"email","providers":["email"],"role":"employee","can_purchase":true,"full_name":"SAMPLE Purchasing"}'::jsonb,
    '{}'::jsonb,
    now(),
    now(),
    '',
    '',
    ''
  );

-- SAMPLE money rows. Not real rates. Visible only through RLS.
insert into public.employee_compensation (
  profile_id,
  entity_id,
  currency,
  hourly_rate,
  effective_from,
  notes
)
select
  '00000000-0000-0000-0000-0000000000a4',
  id,
  'CAD',
  1.0000,
  date '2026-01-01',
  'SAMPLE — not a real pay rate'
from public.business_entities
where legal_name = 'Dance Barre Design Studio Inc.';

insert into public.supplier_prices (
  entity_id,
  supplier_name,
  description,
  currency,
  unit_price
)
select
  id,
  'SAMPLE Supplier',
  'SAMPLE — not a real supplier price',
  'USD',
  1.0000
from public.business_entities
where legal_name = 'Dance Barre Design Studio Inc.';

insert into public.cost_rates (entity_id, description, currency, amount)
select id, 'SAMPLE — not a real cost', 'CAD', 1.0000
from public.business_entities
where legal_name = 'Dance Barre Design Studio Inc.';

select ok(
  (select relrowsecurity from pg_class where oid = 'public.profiles'::regclass),
  'profiles has row level security'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.business_entities'::regclass),
  'business_entities has row level security'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.employee_compensation'::regclass),
  'employee_compensation has row level security'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.supplier_prices'::regclass),
  'supplier_prices has row level security'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.cost_rates'::regclass),
  'cost_rates has row level security'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.audit_log'::regclass),
  'audit_log has row level security'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.profile_contacts'::regclass),
  'profile_contacts has row level security'
);
select hasnt_column('public', 'profiles', 'email', 'profiles do not store email');
select hasnt_column('public', 'profiles', 'phone', 'profiles do not store phone');
select has_column('public', 'profile_contacts', 'email', 'email lives on profile_contacts');
select has_column('public', 'profile_contacts', 'phone', 'phone lives on profile_contacts');

select is(
  (
    select count(*)::int
    from public.business_entities
    where legal_name in (
      'Dance Barre Design Studio Inc.',
      'Dance Barre Studio'
    )
  ),
  2,
  'both operating entities from the brief are present'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a4');
set role authenticated;
select is(
  (select count(*)::int from public.profiles),
  5,
  'employee can see coworker names and roles'
);
select is(
  (
    select full_name
    from public.profiles
    where id = '00000000-0000-0000-0000-0000000000a1'
  ),
  'SAMPLE Owner',
  'employee can read a coworker name'
);
select is(
  (
    select role::text
    from public.profiles
    where id = '00000000-0000-0000-0000-0000000000a1'
  ),
  'owner',
  'employee can read a coworker role'
);
select is(
  (select count(*)::int from public.profile_contacts),
  1,
  'employee sees only their own contact details'
);
select is(
  (
    select count(*)::int
    from public.profile_contacts
    where email = 'sample-owner@example.com'
  ),
  0,
  'employee cannot see a coworker email or phone'
);
select is(
  (select count(*)::int from public.employee_compensation),
  0,
  'employee cannot read compensation rows'
);
select is(
  (select count(*)::int from public.supplier_prices),
  0,
  'employee cannot read supplier prices'
);
select is(
  (select count(*)::int from public.cost_rates),
  0,
  'employee cannot read cost rates'
);
select is(
  (select count(*)::int from public.audit_log),
  0,
  'employee cannot read the audit log'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a2');
set role authenticated;
select is(
  (select count(*)::int from public.profiles),
  5,
  'production manager can see the people directory'
);
select is(
  (select count(*)::int from public.employee_compensation),
  0,
  'production manager cannot read compensation'
);
select is(
  (select count(*)::int from public.profile_contacts),
  5,
  'production manager can see contact details'
);
select is(
  (select count(*)::int from public.supplier_prices),
  1,
  'production manager can read supplier prices without the purchasing switch'
);
select is(
  (select count(*)::int from public.cost_rates),
  0,
  'production manager cannot read cost rates'
);
select throws_ok(
  $$insert into public.supplier_prices (
      entity_id, supplier_name, description, currency, unit_price
    )
    select id, 'SAMPLE Supplier', 'SAMPLE blocked buy', 'CAD', 2
    from public.business_entities
    where legal_name = 'Dance Barre Design Studio Inc.'$$,
  '42501',
  NULL,
  'production manager cannot record a supplier price without the purchasing switch'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a5');
set role authenticated;
select is(
  (select count(*)::int from public.profiles),
  5,
  'purchasing employee can see coworker names'
);
select is(
  (select count(*)::int from public.profile_contacts),
  1,
  'purchasing employee cannot read other people''s contact details'
);
select is(
  (select count(*)::int from public.employee_compensation),
  0,
  'purchasing cannot read compensation'
);
select is(
  (select count(*)::int from public.supplier_prices),
  1,
  'purchasing can read supplier prices'
);
select is(
  (select count(*)::int from public.cost_rates),
  0,
  'purchasing cannot read internal cost rates'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a3');
set role authenticated;
select is(
  (select count(*)::int from public.profiles),
  5,
  'payroll admin can see the people directory'
);
select is(
  (select count(*)::int from public.employee_compensation),
  1,
  'payroll admin can read compensation rows'
);
select is(
  (select count(*)::int from public.supplier_prices),
  0,
  'payroll admin cannot read supplier prices'
);
select is(
  (select count(*)::int from public.cost_rates),
  0,
  'payroll admin cannot read cost rates'
);
select is(
  (
    select count(*)::int
    from public.audit_log
    where table_name = 'profiles'
  ),
  0,
  'payroll admin does not see profile audit rows'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a1');
set role authenticated;
select is(
  (select count(*)::int from public.employee_compensation),
  1,
  'owner can read compensation rows'
);
select is(
  (select count(*)::int from public.supplier_prices),
  1,
  'owner can read supplier prices'
);
select is(
  (select count(*)::int from public.cost_rates),
  1,
  'owner can read cost rates'
);
select ok(
  (select count(*)::int from public.audit_log) > 0,
  'owner can read the audit log'
);

-- Signed-out requests use the anon role and must not see people.
reset role;
select tests.clear_claims();
set local role anon;
select throws_ok(
  'select * from public.profiles',
  '42501',
  NULL,
  'anonymous visitors cannot read profiles'
);
reset role;
select tests.clear_claims();

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a4');
set role authenticated;
select throws_ok(
  $$update public.profiles
    set role = 'owner'
    where id = '00000000-0000-0000-0000-0000000000a4'$$,
  '42501',
  NULL,
  'a user cannot change their own role'
);
update public.profiles
  set full_name = 'SAMPLE Employee Renamed'
  where id = '00000000-0000-0000-0000-0000000000a4';
select is(
  (
    select role::text
    from public.profiles
    where id = '00000000-0000-0000-0000-0000000000a4'
  ),
  'employee',
  'updating a name leaves the role unchanged'
);
select is(
  (
    select full_name
    from public.profiles
    where id = '00000000-0000-0000-0000-0000000000a4'
  ),
  'SAMPLE Employee Renamed',
  'employee can update their own name'
);
-- A hidden row updates as zero rows, with no error. Check the name did not change.
update public.profiles
  set full_name = 'Nope'
  where id = '00000000-0000-0000-0000-0000000000a1';
reset role;
select tests.clear_claims();
select is(
  (
    select full_name
    from public.profiles
    where id = '00000000-0000-0000-0000-0000000000a1'
  ),
  'SAMPLE Owner',
  'employee cannot rename someone else'
);
reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a4');
set role authenticated;
select is(
  (select count(*)::int from public.audit_log),
  0,
  'employee still cannot read the audit row their name change wrote'
);

select throws_ok(
  $$insert into public.employee_compensation (
    profile_id, entity_id, currency, hourly_rate, effective_from, notes
  )
  select
    '00000000-0000-0000-0000-0000000000a4',
    id,
    'CAD',
    2,
    date '2026-02-01',
    'SAMPLE blocked'
  from public.business_entities
  where legal_name = 'Dance Barre Design Studio Inc.'$$,
  '42501',
  NULL,
  'employee cannot insert compensation'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a3');
set role authenticated;
insert into public.employee_compensation (
  profile_id,
  entity_id,
  currency,
  hourly_rate,
  effective_from,
  notes
)
select
  '00000000-0000-0000-0000-0000000000a4',
  id,
  'CAD',
  2.0000,
  date '2026-02-01',
  'SAMPLE payroll insert'
from public.business_entities
where legal_name = 'Dance Barre Design Studio Inc.';
select is(
  (select count(*)::int from public.employee_compensation),
  2,
  'payroll admin can insert a compensation row'
);
select throws_ok(
  'delete from public.employee_compensation',
  '42501',
  NULL,
  'payroll admin cannot delete compensation rows'
);
select ok(
  (
    select count(*)::int
    from public.audit_log
    where table_name = 'employee_compensation'
  ) >= 1,
  'payroll admin can read compensation audit rows'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a1');
set role authenticated;
select throws_ok(
  $$update public.audit_log set action = 'DELETE'$$,
  '42501',
  NULL,
  'audit_log cannot be updated by an owner session'
);
reset role;
select tests.clear_claims();
select throws_ok(
  $$update public.audit_log set action = 'INSERT'$$,
  '42501',
  NULL,
  'audit_log cannot be updated even by the table owner'
);
reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a1');
set role authenticated;
select throws_ok(
  'delete from public.audit_log',
  '42501',
  NULL,
  'audit_log cannot be deleted'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a4');
set role authenticated;
select throws_ok(
  'delete from public.audit_log',
  '42501',
  NULL,
  'employee cannot delete audit_log'
);

-- Turn payroll off and confirm the helper stops matching.
reset role;
select tests.clear_claims();
update public.profiles
  set is_active = false
  where id = '00000000-0000-0000-0000-0000000000a3';
reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a3');
set role authenticated;
select is(
  (select count(*)::int from public.employee_compensation),
  0,
  'an inactive payroll admin cannot read compensation'
);
reset role;
select tests.clear_claims();
update public.profiles
  set is_active = true
  where id = '00000000-0000-0000-0000-0000000000a3';

-- Role changes made in Auth app_metadata flow through to profiles.
update auth.users
  set raw_app_meta_data = raw_app_meta_data || '{"role":"payroll_admin"}'::jsonb
  where id = '00000000-0000-0000-0000-0000000000a4';
select is(
  (
    select role::text
    from public.profiles
    where id = '00000000-0000-0000-0000-0000000000a4'
  ),
  'payroll_admin',
  'app_metadata role is copied onto the profile'
);
update auth.users
  set raw_app_meta_data = raw_app_meta_data || '{"role":"employee"}'::jsonb
  where id = '00000000-0000-0000-0000-0000000000a4';
select is(
  (
    select role::text
    from public.profiles
    where id = '00000000-0000-0000-0000-0000000000a4'
  ),
  'employee',
  'reverting app_metadata restores the employee role'
);

-- Even if the role column is accidentally writable, the trigger still blocks
-- a person from promoting themselves. An owner may change someone else.
grant update (role) on table public.profiles to authenticated;
reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a4');
set role authenticated;
select throws_ok(
  $$update public.profiles
    set role = 'owner'
    where id = '00000000-0000-0000-0000-0000000000a4'$$,
  '42501',
  NULL,
  'trigger blocks a user from changing their own role'
);
reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a1');
set role authenticated;
-- An owner may change someone else's role from their own session.
-- Changing your own role is still blocked by the trigger above.
update public.profiles
  set role = 'production_manager'
  where id = '00000000-0000-0000-0000-0000000000a4';
select is(
  (
    select role::text
    from public.profiles
    where id = '00000000-0000-0000-0000-0000000000a4'
  ),
  'production_manager',
  'an owner can change someone else''s role'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a4');
set role authenticated;
select throws_ok(
  $$update public.business_entities set home_currency = 'USD'$$,
  '42501',
  NULL,
  'signed-in users cannot change entity currency through the Data API'
);

-- Elaine's case: a production manager who also has the purchasing switch can buy.
reset role;
select tests.clear_claims();
update public.profiles
  set can_purchase = true
  where id = '00000000-0000-0000-0000-0000000000a2';
reset role;
select tests.claims('00000000-0000-0000-0000-0000000000a2');
set role authenticated;
insert into public.supplier_prices (
  entity_id,
  supplier_name,
  description,
  currency,
  unit_price
)
select
  id,
  'SAMPLE Supplier',
  'SAMPLE purchase by production manager',
  'CAD',
  3
from public.business_entities
where legal_name = 'Dance Barre Design Studio Inc.';
select is(
  (select count(*)::int from public.supplier_prices),
  2,
  'production manager with the purchasing switch can record a supplier price'
);

select * from finish();

rollback;
