-- Size quantities are per style. Employees and directors can read the
-- ones they are allowed to see. Only owners, the production manager, and
-- can_update_order_status can change a quantity.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(10);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b1',
    'authenticated', 'authenticated', 'size-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b3',
    'authenticated', 'authenticated', 'size-emp@example.com',
    '{"role":"employee","full_name":"SAMPLE Maker"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b4',
    'authenticated', 'authenticated', 'size-dir@example.com',
    '{"role":"program_director","full_name":"SAMPLE Director"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000b5',
    'authenticated', 'authenticated', 'size-jialin@example.com',
    '{"role":"employee","can_update_order_status":true,"full_name":"SAMPLE Jialin"}'::jsonb,
    '{}'::jsonb,
    now(), now(), '', '', ''
  );

insert into public.programs (name) values ('SAMPLE Size Program');

insert into public.director_programs (profile_id, program_id)
select '00000000-0000-0000-0000-0000000000b4', id
from public.programs
where name = 'SAMPLE Size Program';

insert into public.costume_orders (order_number, program_id)
select 'SAMPLE-SIZE', id from public.programs where name = 'SAMPLE Size Program';

insert into public.costume_orders (order_number)
values ('SAMPLE-SIZE-OTHER');

insert into public.styles (style_key, garment_description, order_id)
select 'SAMPLE-SIZE-GIRLS', 'SAMPLE girls leo', id
from public.costume_orders where order_number = 'SAMPLE-SIZE';

insert into public.styles (style_key, garment_description, order_id)
select 'SAMPLE-SIZE-OTHER', 'SAMPLE other leo', id
from public.costume_orders where order_number = 'SAMPLE-SIZE-OTHER';

insert into public.order_sizes (style_id, order_id, size_code, qty, qty_raw)
select style.id, style.order_id, 'MC', 2, '2'
from public.styles style
where style.style_key = 'SAMPLE-SIZE-GIRLS';

insert into public.order_sizes (style_id, order_id, size_code, qty, qty_raw)
select style.id, style.order_id, 'SA', 9, '9'
from public.styles style
where style.style_key = 'SAMPLE-SIZE-OTHER';

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

select is(
  (
    select count(*)::int
    from public.size_scale
    where size_code in (
      'XSC', 'SC', 'IC', 'IC-L', 'MC', 'MC-L', 'LC', 'XLC',
      'XSA', 'SA', 'SA-L', 'MA', 'LA', 'XLA', 'XXLA'
    )
  ),
  15,
  'the size list keeps Elaine''s codes, including the long sizes, plus XSC'
);

select is(
  (select sort_order from public.size_scale where size_code = 'XSC'),
  1,
  'XSC is the first column'
);

select tests.claims('00000000-0000-0000-0000-0000000000b4');
set role authenticated;

select is(
  (
    select qty
    from public.order_sizes
    where size_code = 'MC'
      and style_id = (
        select id from public.styles where style_key = 'SAMPLE-SIZE-GIRLS'
      )
  ),
  2,
  'a director sees quantities for their program'
);

select is(
  (select count(*)::int from public.order_sizes where size_code = 'SA' and qty = 9),
  0,
  'a director does not see another program''s sizes'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000b3');
set role authenticated;

select throws_ok(
  $$
    update public.order_sizes
    set qty = 99
    where size_code = 'MC'
      and style_id = (
        select id from public.styles where style_key = 'SAMPLE-SIZE-GIRLS'
      )
  $$,
  '42501',
  'You cannot change size quantities',
  'an employee cannot edit the grid'
);

select throws_ok(
  $$
    insert into public.size_scale (size_code, sort_order)
    values ('SAMPLE-XS', 50)
  $$,
  '42501',
  null,
  'an employee cannot add a size'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000b5');
set role authenticated;

select lives_ok(
  $$
    update public.order_sizes
    set qty = 3
    where size_code = 'MC'
      and style_id = (
        select id from public.styles where style_key = 'SAMPLE-SIZE-GIRLS'
      )
  $$,
  'someone who can update order status can edit a quantity'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000b1');
set role authenticated;

select lives_ok(
  $$
    insert into public.size_scale (size_code, sort_order)
    values ('SAMPLE-XT', 40)
  $$,
  'an owner can add a size to the ordered list'
);

select throws_ok(
  $$
    delete from public.order_sizes
    where size_code = 'MC'
      and style_id = (
        select id from public.styles where style_key = 'SAMPLE-SIZE-GIRLS'
      )
  $$,
  '42501',
  null,
  'a size quantity cannot be deleted'
);

select is(
  (
    select qty
    from public.order_sizes
    where size_code = 'MC'
      and style_id = (
        select id from public.styles where style_key = 'SAMPLE-SIZE-GIRLS'
      )
  ),
  3,
  'the edited quantity is still stored on that style'
);

select * from finish();

rollback;
