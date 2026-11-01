-- A stock change queues one low-fabric alert when available metres cross
-- the reorder point. Staying below does not queue another. Going back
-- above re-arms the next crossing. Unknown on-hand does not alert.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(12);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d1',
    'authenticated', 'authenticated', 'low-employee@example.com',
    '{"role":"employee","full_name":"SAMPLE Cutter"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d2',
    'authenticated', 'authenticated', 'low-production@example.com',
    '{"role":"production_manager","full_name":"SAMPLE Elaine"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

insert into public.materials (material_code, fabric_name, reorder_point_m)
values
  ('SAMPLE-LOW', 'SAMPLE low knit', 2),
  ('SAMPLE-UNCOUNTED', 'SAMPLE uncounted', 2),
  ('SAMPLE-DEFAULT', 'SAMPLE default point', null);

insert into public.stock_transactions (txn_code, txn_type, material_id, qty_m)
select 'SAMPLE-LOW-IN', 'receive', id, 10
from public.materials where material_code = 'SAMPLE-LOW';

insert into public.stock_transactions (txn_code, txn_type, material_id, qty_m)
select 'SAMPLE-DEFAULT-IN', 'receive', id, 5
from public.materials where material_code = 'SAMPLE-DEFAULT';

insert into public.stock_transactions (txn_code, txn_type, material_id, qty_m)
select 'SAMPLE-UNCOUNTED-HOLD', 'reserve', id, 3
from public.materials where material_code = 'SAMPLE-UNCOUNTED';

select is(
  (select count(*)::int from public.low_stock_alerts),
  0,
  'replaying stock with no signed-in person does not queue an alert'
);

select is(
  (
    select is_low_stock
    from public.material_availability a
    join public.materials m on m.id = a.material_id
    where m.material_code = 'SAMPLE-UNCOUNTED'
  ),
  false,
  'uncounted stock is not low'
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

insert into public.stock_transactions (txn_code, txn_type, material_id, qty_m, created_by)
select 'SAMPLE-LOW-USE', 'use', id, 8, '00000000-0000-0000-0000-0000000000d2'
from public.materials where material_code = 'SAMPLE-LOW';

select is(
  (
    select available_m
    from public.low_stock_alerts alert
    join public.materials m on m.id = alert.material_id
    where m.material_code = 'SAMPLE-LOW'
  ),
  2.0000,
  'landing exactly on the reorder point queues the available metres'
);

select is(
  (
    select alert.reorder_point_m
    from public.low_stock_alerts alert
    join public.materials m on m.id = alert.material_id
    where m.material_code = 'SAMPLE-LOW'
  ),
  2.0000,
  'the alert records the reorder point'
);

insert into public.stock_transactions (txn_code, txn_type, material_id, qty_m, created_by)
select 'SAMPLE-LOW-MORE', 'use', id, 1, '00000000-0000-0000-0000-0000000000d2'
from public.materials where material_code = 'SAMPLE-LOW';

select is(
  (
    select count(*)::int
    from public.low_stock_alerts alert
    join public.materials m on m.id = alert.material_id
    where m.material_code = 'SAMPLE-LOW'
  ),
  1,
  'staying below the reorder point does not queue another alert'
);

insert into public.stock_transactions (txn_code, txn_type, material_id, qty_m, created_by)
select 'SAMPLE-LOW-BACK', 'receive', id, 5, '00000000-0000-0000-0000-0000000000d2'
from public.materials where material_code = 'SAMPLE-LOW';

select is(
  (
    select count(*)::int
    from public.low_stock_alerts alert
    join public.materials m on m.id = alert.material_id
    where m.material_code = 'SAMPLE-LOW'
  ),
  1,
  'going back above the reorder point does not queue an alert'
);

insert into public.stock_transactions (txn_code, txn_type, material_id, qty_m, created_by)
select 'SAMPLE-LOW-AGAIN', 'use', id, 5, '00000000-0000-0000-0000-0000000000d2'
from public.materials where material_code = 'SAMPLE-LOW';

select is(
  (
    select count(*)::int
    from public.low_stock_alerts alert
    join public.materials m on m.id = alert.material_id
    where m.material_code = 'SAMPLE-LOW'
  ),
  2,
  'the next crossing queues a new alert'
);

insert into public.stock_transactions (txn_code, txn_type, material_id, qty_m, created_by)
select 'SAMPLE-UNCOUNTED-USE', 'use', id, 1, '00000000-0000-0000-0000-0000000000d2'
from public.materials where material_code = 'SAMPLE-UNCOUNTED';

select is(
  (
    select count(*)::int
    from public.low_stock_alerts alert
    join public.materials m on m.id = alert.material_id
    where m.material_code = 'SAMPLE-UNCOUNTED'
  ),
  0,
  'a first count that starts below the point does not alert'
);

select is(
  (
    select is_low_stock
    from public.material_availability a
    join public.materials m on m.id = a.material_id
    where m.material_code = 'SAMPLE-UNCOUNTED'
  ),
  true,
  'once on-hand is known and available is at or below the point, the fabric is low'
);

insert into public.stock_transactions (txn_code, txn_type, material_id, qty_m, created_by)
select 'SAMPLE-DEFAULT-USE', 'use', id, 4, '00000000-0000-0000-0000-0000000000d2'
from public.materials where material_code = 'SAMPLE-DEFAULT';

select is(
  (
    select alert.reorder_point_m
    from public.low_stock_alerts alert
    join public.materials m on m.id = alert.material_id
    where m.material_code = 'SAMPLE-DEFAULT'
  ),
  2.0000,
  'a blank reorder point uses the 2 m studio default'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000d1');
set role authenticated;

select is(
  (select count(*)::int from public.low_stock_alerts),
  0,
  'an employee cannot read low-stock alerts'
);

select throws_ok(
  $$insert into public.low_stock_alerts (material_id, available_m, reorder_point_m)
    select id, 1, 2 from public.materials where material_code = 'SAMPLE-LOW'$$,
  '42501',
  null,
  'an employee cannot queue an alert by hand'
);

select * from finish();
rollback;
