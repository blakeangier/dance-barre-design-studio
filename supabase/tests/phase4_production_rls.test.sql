-- Phase 4: sized fabric, material kind, quality checks, tech packs,
-- fittings, and due dates. Hosted dev is not changed by this file.

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
    '00000000-0000-0000-0000-0000000000f1',
    'authenticated', 'authenticated', 'owner-p4@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000f2',
    'authenticated', 'authenticated', 'pm-p4@example.com',
    '{"role":"production_manager","full_name":"SAMPLE PM"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000f3',
    'authenticated', 'authenticated', 'emp-p4@example.com',
    '{"role":"employee","full_name":"SAMPLE Maker"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000f4',
    'authenticated', 'authenticated', 'dir-p4@example.com',
    '{"role":"program_director","full_name":"SAMPLE Director"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

insert into public.programs (name) values ('SAMPLE Phase4 Program');

insert into public.director_programs (profile_id, program_id)
select
  '00000000-0000-0000-0000-0000000000f4',
  id
from public.programs
where name = 'SAMPLE Phase4 Program';

insert into public.costume_orders (
  order_number, order_date, status, production_status, program_id
)
select
  'SAMPLE-P4',
  current_date,
  null,
  'finishing_qc',
  id
from public.programs
where name = 'SAMPLE Phase4 Program';

insert into public.costume_orders (
  order_number, order_date, status, production_status
)
values ('SAMPLE-P4-OTHER', current_date, null, 'sewing');

insert into public.materials (material_code, material_kind, unit_kind)
values ('SAMPLE-TRIM', 'elastic', 'metres');

insert into public.bom_lines (line_code, order_id, component, is_estimate)
select 'SAMPLE-BOM', id, 'Self', false
from public.costume_orders
where order_number = 'SAMPLE-P4';

select is(
  (
    select count(*)::integer
    from public.qc_template_items
    where archived_at is null
  ),
  8,
  'the default quality checklist has eight items'
);

select is(
  (
    select count(*)::integer
    from public.sewing_route_template
  ),
  10,
  'the Order 005 sewing route has ten steps'
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
select tests.claims('00000000-0000-0000-0000-0000000000f3');
set role authenticated;

select throws_ok(
  $$
    insert into public.bom_size_qty (bom_line_id, size_code, metres_per_piece)
    select id, 'SC', 0.4
    from public.bom_lines
    where line_code = 'SAMPLE-BOM'
  $$,
  '42501',
  null,
  'an employee cannot write a sized quantity'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000f2');
set role authenticated;

select lives_ok(
  $$
    insert into public.bom_size_qty (bom_line_id, size_code, metres_per_piece)
    select id, 'SC', 0.4
    from public.bom_lines
    where line_code = 'SAMPLE-BOM'
  $$,
  'the production manager can save metres per size'
);

select throws_ok(
  $$
    update public.costume_orders
    set production_status = 'ready_for_pickup'
    where order_number = 'SAMPLE-P4'
  $$,
  '42501',
  'Quality check must be complete before pickup',
  'pickup stays locked until quality check is clear'
);

select lives_ok(
  $$
    insert into public.qc_checks (order_id, item_name, result, checked_by)
    select order_row.id, item.item_name, 'pass',
      '00000000-0000-0000-0000-0000000000f2'
    from public.costume_orders order_row
    cross join public.qc_template_items item
    where order_row.order_number = 'SAMPLE-P4'
      and item.archived_at is null
  $$,
  'the production manager records a passing checklist'
);

select lives_ok(
  $$
    update public.costume_orders
    set production_status = 'ready_for_pickup'
    where order_number = 'SAMPLE-P4'
  $$,
  'pickup is allowed once every check passes'
);

select throws_ok(
  $$
    insert into public.fittings (
      fitting_code, order_id, dancer_label, outcome
    )
    select 'SAMPLE-FIT-BAD', id, 'Ava Moore', 'approved'
    from public.costume_orders
    where order_number = 'SAMPLE-P4'
  $$,
  '23514',
  null,
  'a dancer name cannot include a full surname'
);

select lives_ok(
  $$
    insert into public.fittings (
      fitting_code, order_id, dancer_label, outcome
    )
    select 'SAMPLE-FIT', id, 'Ava M', 'alter'
    from public.costume_orders
    where order_number = 'SAMPLE-P4'
  $$,
  'a first name and last initial can be saved'
);

select throws_ok(
  $$
    delete from public.fittings where fitting_code = 'SAMPLE-FIT'
  $$,
  '42501',
  null,
  'a fitting is archived, not deleted'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000f4');
set role authenticated;

select is(
  (
    select due_on::text
    from public.costume_orders
    where order_number = 'SAMPLE-P4-OTHER'
  ),
  null,
  'a director does not see another program''s due date'
);

select throws_ok(
  $$
    update public.costume_orders
    set due_on = current_date
    where order_number = 'SAMPLE-P4'
  $$,
  '42501',
  null,
  'a director cannot change a due date'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000f1');
set role authenticated;

select lives_ok(
  $$
    update public.costume_orders
    set production_status = 'finishing_qc', due_on = current_date
    where order_number = 'SAMPLE-P4-OTHER'
  $$,
  'the owner can set a due date'
);

select throws_ok(
  $$
    insert into public.materials (material_code, material_kind, unit_kind)
    values ('SAMPLE-BAD-KIND', 'ribbon', 'metres')
  $$,
  '23514',
  null,
  'a material kind must be one of the trim list'
);

select is(
  (select unit_kind from public.materials where material_code = 'SAMPLE-TRIM'),
  'metres',
  'elastic is counted in metres on the same ledger'
);

select * from finish();

rollback;
