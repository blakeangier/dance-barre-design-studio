-- Fabric use draws a production reservation down.
-- A person can reverse their own entry within 24 hours.
-- Owners and the production manager can reverse any logged use.
-- The original row is not edited.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(16);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c1',
    'authenticated', 'authenticated', 'use-employee@example.com',
    '{"role":"employee","full_name":"SAMPLE Cutter"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c2',
    'authenticated', 'authenticated', 'use-production@example.com',
    '{"role":"production_manager","full_name":"SAMPLE Elaine"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

insert into public.materials (material_code, fabric_name)
values ('SAMPLE-USE-FAB', 'SAMPLE mesh');

insert into public.costume_orders (order_number, production_song)
values ('SAMPLE-USE-ORDER', 'SAMPLE song');

insert into public.styles (style_key, garment_description, order_id)
select 'SAMPLE-USE-STYLE', 'SAMPLE skirt', id
from public.costume_orders
where order_number = 'SAMPLE-USE-ORDER';

insert into public.stock_transactions (
  txn_code, txn_type, material_id, qty_m
)
select 'SAMPLE-USE-RECEIVE', 'receive', id, 10
from public.materials
where material_code = 'SAMPLE-USE-FAB';

insert into public.stock_transactions (
  txn_code, txn_type, material_id, qty_m, order_id, order_number_raw
)
select 'SAMPLE-USE-RESERVE', 'reserve', m.id, 4, o.id, o.order_number
from public.materials m
cross join public.costume_orders o
where m.material_code = 'SAMPLE-USE-FAB'
  and o.order_number = 'SAMPLE-USE-ORDER';

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

insert into public.stock_transactions (
  txn_code, txn_type, material_id, qty_m, created_by, usage_kind, order_id
)
select
  'SAMPLE-USE-CUT', 'use', m.id, 3,
  '00000000-0000-0000-0000-0000000000c1', 'production', o.id
from public.materials m
cross join public.costume_orders o
where m.material_code = 'SAMPLE-USE-FAB'
  and o.order_number = 'SAMPLE-USE-ORDER';

select is(
  (
    select reservation_drawdown_m
    from public.stock_transactions
    where txn_code = 'SAMPLE-USE-CUT'
  ),
  3.0000,
  'a production use draws the reservation down by the metres used'
);

select is(
  (
    select on_hand_m
    from public.material_stock s
    join public.materials m on m.id = s.material_id
    where m.material_code = 'SAMPLE-USE-FAB'
  ),
  7.0000,
  'the use lowers on-hand'
);

select is(
  (
    select reserved_m
    from public.material_stock s
    join public.materials m on m.id = s.material_id
    where m.material_code = 'SAMPLE-USE-FAB'
  ),
  1.0000,
  'the reservation falls by the same metres'
);

select is(
  (
    select available_m
    from public.material_availability a
    join public.materials m on m.id = a.material_id
    where m.material_code = 'SAMPLE-USE-FAB'
  ),
  6.0000,
  'available stays the same because the use came from the reservation'
);

insert into public.stock_transactions (
  txn_code, txn_type, material_id, qty_m, created_by, usage_kind, order_id, is_waste
)
select
  'SAMPLE-USE-WASTE', 'use', m.id, 1,
  '00000000-0000-0000-0000-0000000000c1', 'production', o.id, true
from public.materials m
cross join public.costume_orders o
where m.material_code = 'SAMPLE-USE-FAB'
  and o.order_number = 'SAMPLE-USE-ORDER';

select is(
  (
    select reservation_drawdown_m
    from public.stock_transactions
    where txn_code = 'SAMPLE-USE-WASTE'
  ),
  1.0000,
  'waste draws the remaining reservation'
);

select is(
  (
    select reserved_m
    from public.material_stock s
    join public.materials m on m.id = s.material_id
    where m.material_code = 'SAMPLE-USE-FAB'
  ),
  0.0000,
  'the reservation is fully drawn'
);

insert into public.stock_transactions (
  txn_code, txn_type, material_id, qty_m, created_by, usage_kind, order_id
)
select
  'SAMPLE-USE-EXTRA', 'use', m.id, 2,
  '00000000-0000-0000-0000-0000000000c1', 'production', o.id
from public.materials m
cross join public.costume_orders o
where m.material_code = 'SAMPLE-USE-FAB'
  and o.order_number = 'SAMPLE-USE-ORDER';

select is(
  (
    select reservation_drawdown_m
    from public.stock_transactions
    where txn_code = 'SAMPLE-USE-EXTRA'
  ),
  0.0000,
  'metres past the reservation do not draw it below zero'
);

insert into public.stock_transactions (
  txn_code, txn_type, material_id, qty_m, created_by, usage_kind, style_id
)
select
  'SAMPLE-USE-SAMPLE', 'use', m.id, 1,
  '00000000-0000-0000-0000-0000000000c1', 'sample', s.id
from public.materials m
cross join public.styles s
where m.material_code = 'SAMPLE-USE-FAB'
  and s.style_key = 'SAMPLE-USE-STYLE';

select is(
  (
    select reservation_drawdown_m
    from public.stock_transactions
    where txn_code = 'SAMPLE-USE-SAMPLE'
  ),
  0.0000,
  'a sample does not draw a production reservation'
);

insert into public.stock_transactions (
  txn_code, txn_type, reverses_id, material_id, qty_m, created_by,
  reservation_drawdown_m
)
select
  'SAMPLE-USE-UNDO', 'adjust', id, material_id, qty_m,
  '00000000-0000-0000-0000-0000000000c1', 0
from public.stock_transactions
where txn_code = 'SAMPLE-USE-SAMPLE';

select is(
  (
    select count(*)::int
    from public.stock_transactions
    where txn_code = 'SAMPLE-USE-UNDO' and txn_type = 'adjust'
  ),
  1,
  'an employee can reverse their own recent entry'
);

select is(
  (
    select on_hand_m
    from public.material_stock s
    join public.materials m on m.id = s.material_id
    where m.material_code = 'SAMPLE-USE-FAB'
  ),
  4.0000,
  'the reversing entry puts those metres back on hand'
);

reset role;

insert into public.stock_transactions (
  txn_code, txn_type, material_id, qty_m, created_by, usage_kind, style_id, created_at
)
select
  'SAMPLE-USE-OLD', 'use', m.id, 1,
  '00000000-0000-0000-0000-0000000000c1', 'sample', s.id,
  now() - interval '2 days'
from public.materials m
cross join public.styles s
where m.material_code = 'SAMPLE-USE-FAB'
  and s.style_key = 'SAMPLE-USE-STYLE';

select tests.claims('00000000-0000-0000-0000-0000000000c1');
set role authenticated;

select throws_ok(
  $$insert into public.stock_transactions (
    txn_code, txn_type, reverses_id, material_id, qty_m, created_by, reservation_drawdown_m
  )
  select 'SAMPLE-USE-OLD-UNDO', 'adjust', id, material_id, qty_m,
    '00000000-0000-0000-0000-0000000000c1', 0
  from public.stock_transactions where txn_code = 'SAMPLE-USE-OLD'$$,
  '42501',
  null,
  'an employee cannot reverse an entry after 24 hours'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c2');
set role authenticated;

insert into public.stock_transactions (
  txn_code, txn_type, reverses_id, material_id, qty_m, created_by,
  reservation_drawdown_m
)
select
  'SAMPLE-USE-OLD-PM', 'adjust', id, material_id, qty_m,
  '00000000-0000-0000-0000-0000000000c2', 0
from public.stock_transactions
where txn_code = 'SAMPLE-USE-OLD';

select is(
  (
    select count(*)::int
    from public.stock_transactions
    where txn_code = 'SAMPLE-USE-OLD-PM'
  ),
  1,
  'the production manager can reverse an older entry'
);

select throws_ok(
  $$insert into public.stock_transactions (
    txn_code, txn_type, reverses_id, material_id, qty_m, created_by, reservation_drawdown_m
  )
  select 'SAMPLE-USE-OLD-AGAIN', 'adjust', id, material_id, qty_m,
    '00000000-0000-0000-0000-0000000000c2', 0
  from public.stock_transactions where txn_code = 'SAMPLE-USE-OLD'$$,
  '42501',
  null,
  'an entry can be reversed once'
);

insert into public.stock_transactions (
  txn_code, txn_type, material_id, qty_m, created_by, usage_kind, order_id
)
select
  'SAMPLE-USE-PM', 'use', m.id, 0.2,
  '00000000-0000-0000-0000-0000000000c2', 'production', o.id
from public.materials m
cross join public.costume_orders o
where m.material_code = 'SAMPLE-USE-FAB'
  and o.order_number = 'SAMPLE-USE-ORDER';

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c1');
set role authenticated;

select throws_ok(
  $$insert into public.stock_transactions (
    txn_code, txn_type, reverses_id, material_id, qty_m, created_by, reservation_drawdown_m
  )
  select 'SAMPLE-USE-PM-UNDO', 'adjust', id, material_id, qty_m,
    '00000000-0000-0000-0000-0000000000c1', 0
  from public.stock_transactions where txn_code = 'SAMPLE-USE-PM'$$,
  '42501',
  null,
  'an employee cannot reverse someone else''s entry'
);

select throws_ok(
  $$update public.stock_transactions set qty_m = 9 where txn_code = 'SAMPLE-USE-CUT'$$,
  '42501',
  null,
  'a logged use is not edited'
);

select throws_ok(
  $$delete from public.stock_transactions where txn_code = 'SAMPLE-USE-CUT'$$,
  '42501',
  null,
  'a logged use is not deleted'
);

select * from finish();
rollback;
