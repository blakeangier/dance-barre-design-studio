-- Finances are owners only. No real figures: the SAMPLE line exists only
-- inside this transaction.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(9);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c1',
    'authenticated', 'authenticated', 'finance-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c2',
    'authenticated', 'authenticated', 'finance-pm@example.com',
    '{"role":"production_manager","full_name":"SAMPLE Elaine"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c3',
    'authenticated', 'authenticated', 'finance-pay@example.com',
    '{"role":"payroll_admin","full_name":"SAMPLE Rebecca"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c4',
    'authenticated', 'authenticated', 'finance-emp@example.com',
    '{"role":"employee","full_name":"SAMPLE Jialin"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c5',
    'authenticated', 'authenticated', 'finance-dir@example.com',
    '{"role":"program_director","full_name":"SAMPLE Director"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  );

insert into public.startup_costs (
  occurred_on, description, vendor, category_id, amount_cad, hst_cad, source
)
select current_date, 'SAMPLE shelf', 'SAMPLE vendor', id, 1.00, 0.13, 'manual'
from public.finance_categories
where name = 'Fixtures';

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
  (select count(*)::int from public.finance_categories),
  15,
  'fifteen finance categories are named, with no dollar amounts'
);

select is(
  (
    select excludes_from_totals
    from public.finance_categories
    where name = 'Not a Design Studio cost'
  ),
  true,
  'Not a Design Studio cost is left out of totals'
);

select tests.claims('00000000-0000-0000-0000-0000000000c1');
set role authenticated;

select is(
  (select count(*)::int from public.startup_costs where description = 'SAMPLE shelf'),
  1,
  'an owner can read a SAMPLE startup line'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c2');
set role authenticated;

select is(
  (select count(*)::int from public.startup_costs),
  0,
  'the production manager sees no finance rows'
);

select is(
  (select count(*)::int from public.finance_categories),
  0,
  'the production manager does not see finance categories'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c3');
set role authenticated;

select is(
  (select count(*)::int from public.card_transactions)
    + (select count(*)::int from public.recurring_costs)
    + (select count(*)::int from public.payroll_actuals)
    + (select count(*)::int from public.startup_costs),
  0,
  'payroll admin sees no finance rows'
);

reset role;
create temp table sample_fixture as
select id from public.finance_categories where name = 'Fixtures';
select tests.claims('00000000-0000-0000-0000-0000000000c4');
set role authenticated;

select is(
  (select count(*)::int from public.startup_costs),
  0,
  'an employee sees no finance rows'
);

select throws_ok(
  $$
    insert into public.startup_costs (
      occurred_on, description, category_id, amount_cad, source
    )
    select current_date, 'SAMPLE hidden', id, 2, 'manual'
    from sample_fixture
  $$,
  '42501',
  null,
  'an employee cannot add a finance line'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c5');
set role authenticated;

select is(
  (select count(*)::int from public.startup_costs),
  0,
  'a program director sees no finance rows'
);

select * from finish();

rollback;
