-- Inventory access. Costs stay hidden from employees. Employees may log use only.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(15);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b1',
    'authenticated', 'authenticated', 'inv-employee@example.com',
    '{"role":"employee","full_name":"SAMPLE Employee"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b2',
    'authenticated', 'authenticated', 'inv-production@example.com',
    '{"role":"production_manager","full_name":"SAMPLE Production"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b3',
    'authenticated', 'authenticated', 'inv-buyer@example.com',
    '{"role":"employee","can_purchase":true,"full_name":"SAMPLE Buyer"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

insert into public.materials (material_code, fabric_name, colour_name)
values ('SAMPLE-FABRIC', 'SAMPLE knit', 'SAMPLE blue');

insert into public.material_costs (material_id, list_price_per_m, list_price_raw)
select id, 1.5000, '1.5'
from public.materials where material_code = 'SAMPLE-FABRIC';

insert into public.suppliers (supplier_code, name)
values ('SAMPLE-SUP', 'SAMPLE Supplier');

insert into public.supplier_contacts (supplier_id, email, phone)
select id, 'sample@example.com', '555-0100'
from public.suppliers where supplier_code = 'SAMPLE-SUP';

insert into public.costume_orders (order_number, production_song)
values ('SAMPLE-ORDER', 'SAMPLE song');

insert into public.styles (style_key, garment_description)
values ('SAMPLE-STYLE', 'SAMPLE skirt');

insert into public.order_private (order_id, contact_emails, budget_per_costume)
select id, 'client@example.com', 12.00
from public.costume_orders where order_number = 'SAMPLE-ORDER';

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
select tests.claims('00000000-0000-0000-0000-0000000000b1');
set role authenticated;

select is(
  (
    select count(*)::int
    from public.material_costs c
    join public.materials m on m.id = c.material_id
    where m.material_code = 'SAMPLE-FABRIC'
  ),
  0,
  'employee cannot read material costs'
);
select is(
  (select fabric_name from public.materials where material_code = 'SAMPLE-FABRIC'),
  'SAMPLE knit',
  'employee can read materials'
);

update public.materials set fabric_name = 'Hacked' where material_code = 'SAMPLE-FABRIC';
select is(
  (select fabric_name from public.materials where material_code = 'SAMPLE-FABRIC'),
  'SAMPLE knit',
  'employee cannot edit a material'
);

select throws_ok(
  $$insert into public.stock_transactions (
    txn_code, txn_type, material_id, qty_m, created_by
  )
  select 'SAMPLE-RECEIVE', 'receive', id, 5, '00000000-0000-0000-0000-0000000000b1'
  from public.materials where material_code = 'SAMPLE-FABRIC'$$,
  '42501',
  null,
  'employee cannot log a receipt'
);

insert into public.stock_transactions (
  txn_code, txn_type, material_id, qty_m, created_by, usage_kind, style_id
)
select 'SAMPLE-USE', 'use', m.id, 1, '00000000-0000-0000-0000-0000000000b1',
  'sample', s.id
from public.materials m
cross join public.styles s
where m.material_code = 'SAMPLE-FABRIC'
  and s.style_key = 'SAMPLE-STYLE';
select is(
  (select count(*)::int from public.stock_transactions where txn_code = 'SAMPLE-USE'),
  1,
  'employee can log usage'
);
select is(
  (
    select count(*)::int
    from public.supplier_contacts c
    join public.suppliers s on s.id = c.supplier_id
    where s.supplier_code = 'SAMPLE-SUP'
  ),
  0,
  'employee cannot read supplier contacts'
);
select is(
  (
    select count(*)::int
    from public.order_private p
    join public.costume_orders o on o.id = p.order_id
    where o.order_number = 'SAMPLE-ORDER'
  ),
  0,
  'employee cannot read client emails or budgets'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000b2');
set role authenticated;

select is(
  (
    select count(*)::int
    from public.material_costs c
    join public.materials m on m.id = c.material_id
    where m.material_code = 'SAMPLE-FABRIC'
  ),
  1,
  'production manager can read material costs'
);
update public.materials set bin_location = 'SAMPLE bin' where material_code = 'SAMPLE-FABRIC';
select is(
  (select bin_location from public.materials where material_code = 'SAMPLE-FABRIC'),
  'SAMPLE bin',
  'production manager can edit a material'
);
select is(
  (
    select c.list_price_per_m
    from public.material_costs c
    join public.materials m on m.id = c.material_id
    where m.material_code = 'SAMPLE-FABRIC'
  ),
  1.5000,
  'production manager can read the sample price'
);
select is(
  (
    select c.email
    from public.supplier_contacts c
    join public.suppliers s on s.id = c.supplier_id
    where s.supplier_code = 'SAMPLE-SUP'
  ),
  'sample@example.com',
  'production manager can read supplier contacts'
);
select is(
  (
    select p.contact_emails
    from public.order_private p
    join public.costume_orders o on o.id = p.order_id
    where o.order_number = 'SAMPLE-ORDER'
  ),
  'client@example.com',
  'production manager can read client emails'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000b3');
set role authenticated;

select is(
  (
    select count(*)::int
    from public.material_costs c
    join public.materials m on m.id = c.material_id
    where m.material_code = 'SAMPLE-FABRIC'
  ),
  1,
  'purchasing switch can read material costs'
);
select is(
  (
    select count(*)::int
    from public.supplier_contacts c
    join public.suppliers s on s.id = c.supplier_id
    where s.supplier_code = 'SAMPLE-SUP'
  ),
  0,
  'purchasing switch cannot read supplier contacts'
);
select is(
  (
    select count(*)::int
    from public.order_private p
    join public.costume_orders o on o.id = p.order_id
    where o.order_number = 'SAMPLE-ORDER'
  ),
  0,
  'purchasing switch cannot read client emails or budgets'
);

select * from finish();
rollback;
