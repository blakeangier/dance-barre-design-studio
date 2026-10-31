-- Program directors can read their orders and cannot read costs, stock,
-- staff records, or write. A status flag can change production status only.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(20);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000e1',
    'authenticated', 'authenticated', 'director-scoped@example.com',
    '{"role":"program_director","full_name":"SAMPLE Director"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000e2',
    'authenticated', 'authenticated', 'director-open@example.com',
    '{"role":"program_director","full_name":"SAMPLE Open Director"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000e3',
    'authenticated', 'authenticated', 'status-none@example.com',
    '{"role":"employee","full_name":"SAMPLE Staff"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000e4',
    'authenticated', 'authenticated', 'status-yes@example.com',
    '{"role":"employee","can_update_order_status":true,"full_name":"SAMPLE Jialin"}'::jsonb,
    '{}'::jsonb,
    now(), now(), '', '', ''
  );

insert into public.director_programs (profile_id, program_id)
select '00000000-0000-0000-0000-0000000000e1', id
from public.programs
where name = 'Elite Company';

insert into public.costume_orders (order_number, production_song, program_id)
select 'DIR-A', 'SAMPLE elite', id
from public.programs where name = 'Elite Company';

insert into public.costume_orders (order_number, production_song, program_id)
select 'DIR-B', 'SAMPLE crew', id
from public.programs where name = 'CREW';

insert into public.costume_orders (order_number, production_song)
values ('DIR-NONE', 'SAMPLE no program');

insert into public.styles (style_key, garment_description, order_id)
select 'DIR-STYLE-A', 'SAMPLE elite skirt', id
from public.costume_orders where order_number = 'DIR-A';

insert into public.styles (style_key, garment_description, order_id)
select 'DIR-STYLE-B', 'SAMPLE crew skirt', id
from public.costume_orders where order_number = 'DIR-B';

insert into public.materials (material_code, fabric_name)
values ('SAMPLE-DIR', 'SAMPLE elite mesh'), ('SAMPLE-OTHER', 'SAMPLE other mesh');

insert into public.material_costs (material_id, list_price_per_m, list_price_raw)
select id, 4, '4' from public.materials where material_code = 'SAMPLE-DIR';

insert into public.bom_lines (line_code, order_id, material_id, fabric_name)
select 'DIR-BOM-A', o.id, m.id, 'SAMPLE elite mesh'
from public.costume_orders o
cross join public.materials m
where o.order_number = 'DIR-A' and m.material_code = 'SAMPLE-DIR';

insert into public.stock_transactions (txn_code, txn_type, material_id, qty_m)
select 'DIR-RECEIVE', 'receive', id, 8
from public.materials where material_code = 'SAMPLE-DIR';

insert into public.employee_private (profile_id, street)
values ('00000000-0000-0000-0000-0000000000e4', 'SAMPLE street');

insert into public.low_stock_alerts (material_id, available_m, reorder_point_m)
select id, 1, 2 from public.materials where material_code = 'SAMPLE-DIR';

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
select tests.claims('00000000-0000-0000-0000-0000000000e1');
set role authenticated;

select is(
  (select count(*)::int from public.costume_orders where order_number = 'DIR-A'),
  1,
  'a scoped director sees their program order'
);
select is(
  (select count(*)::int from public.costume_orders where order_number = 'DIR-B'),
  0,
  'a scoped director cannot see another program'
);
select is(
  (select count(*)::int from public.costume_orders where order_number = 'DIR-NONE'),
  0,
  'an order with no program is hidden from directors'
);
select is(
  (select count(*)::int from public.styles where style_key = 'DIR-STYLE-B'),
  0,
  'a scoped director cannot see another program style'
);
select is(
  (select count(*)::int from public.materials where material_code = 'SAMPLE-OTHER'),
  0,
  'a director cannot browse fabrics that are not on their orders'
);
select is(
  (select count(*)::int from public.material_costs),
  0,
  'a director cannot read material costs'
);
select is(
  (select count(*)::int from public.employee_private),
  0,
  'a director cannot read staff private records'
);
select is(
  (select count(*)::int from public.audit_log),
  0,
  'a director cannot read the audit log'
);
select is(
  (select count(*)::int from public.low_stock_alerts),
  0,
  'a director cannot read low-stock alerts'
);
select is(
  (select count(*)::int from public.stock_transactions),
  0,
  'a director cannot read inventory quantities'
);

select throws_ok(
  $$update public.costume_orders set production_status = 'sewing' where order_number = 'DIR-A'$$,
  '42501',
  null,
  'a director cannot change production status'
);

select throws_ok(
  $$update public.costume_orders
    set program_id = (select id from public.programs where name = 'CREW')
    where order_number = 'DIR-A'$$,
  '42501',
  null,
  'a director cannot change an order program'
);

select throws_ok(
  $$insert into public.stock_transactions (txn_code, txn_type, material_id, qty_m, created_by, usage_kind, style_id)
    select 'DIR-USE', 'use', m.id, 1, '00000000-0000-0000-0000-0000000000e1', 'sample', s.id
    from public.materials m
    cross join public.styles s
    where m.material_code = 'SAMPLE-DIR' and s.style_key = 'DIR-STYLE-A'$$,
  '42501',
  null,
  'a director cannot log fabric use'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000e2');
set role authenticated;

select is(
  (
    select count(*)::int
    from public.costume_orders
    where order_number in ('DIR-A', 'DIR-B', 'DIR-NONE')
  ),
  0,
  'a director with no program links sees no orders'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000e3');
set role authenticated;

select throws_ok(
  $$update public.costume_orders set production_status = 'cutting' where order_number = 'DIR-A'$$,
  '42501',
  null,
  'an employee cannot change production status without the flag'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000e4');
set role authenticated;

update public.costume_orders
set production_status = 'cutting',
    program_id = (select id from public.programs where name = 'CREW')
where order_number = 'DIR-A';

select is(
  (
    select g.name
    from public.costume_orders costume_order
    join public.programs g on g.id = costume_order.program_id
    where costume_order.order_number = 'DIR-A'
  ),
  'CREW',
  'a flagged employee can set the order program'
);

select is(
  (
    select to_status
    from public.order_status_events event
    join public.costume_orders costume_order on costume_order.id = event.order_id
    where costume_order.order_number = 'DIR-A'
  ),
  'cutting',
  'a flagged employee change is kept in the history'
);

select throws_ok(
  $$update public.costume_orders set notes = 'nope' where order_number = 'DIR-A'$$,
  '42501',
  null,
  'the status flag cannot edit the rest of the order'
);

reset role;
select set_config('request.jwt.claims', '', true);
select set_config('request.jwt.claim.sub', '', true);

update public.costume_orders
set status = 'cancelled'
where order_number = 'DIR-B';

select tests.claims('00000000-0000-0000-0000-0000000000e4');
set role authenticated;

select throws_ok(
  $$update public.costume_orders set production_status = 'sewing' where order_number = 'DIR-B'$$,
  '42501',
  null,
  'a cancelled order keeps its cancelled state'
);

select throws_ok(
  $$delete from public.order_status_events$$,
  '42501',
  null,
  'production status history cannot be deleted'
);

select * from finish();
rollback;
