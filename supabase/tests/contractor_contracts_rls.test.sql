-- Contractor contracts are owners only. SAMPLE amounts stay in this transaction.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(4);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c1',
    'authenticated', 'authenticated', 'contract-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c4',
    'authenticated', 'authenticated', 'contract-emp@example.com',
    '{"role":"employee","full_name":"SAMPLE Maker"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c6',
    'authenticated', 'authenticated', 'contract-person@example.com',
    '{"role":"employee","employment_type":"contractor","full_name":"SAMPLE Contractor"}'::jsonb,
    '{}'::jsonb,
    now(), now(), '', '', ''
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

select tests.claims('00000000-0000-0000-0000-0000000000c1');
set role authenticated;

select lives_ok(
  $$
    insert into public.contractor_contracts (
      contractor_id, total_amount_cad, hst_amount_cad, start_date, end_date, notes
    )
    values (
      '00000000-0000-0000-0000-0000000000c6',
      100.00, 13.00, date '2026-10-01', date '2026-10-31', 'SAMPLE contract'
    )
  $$,
  'an owner can save a SAMPLE contract'
);

select lives_ok(
  $$
    insert into public.contractor_payments (contract_id, paid_on, amount_cad, hst_cad, notes)
    select id, null, 25.00, 3.25, 'SAMPLE payment'
    from public.contractor_contracts
    where notes = 'SAMPLE contract'
  $$,
  'an owner can record a SAMPLE payment with no date'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c4');
set role authenticated;

select is(
  (select count(*)::int from public.contractor_contracts)
    + (select count(*)::int from public.contractor_payments),
  0,
  'an employee sees no contractor contracts or payments'
);

select throws_ok(
  $$
    delete from public.contractor_contracts
    where notes = 'SAMPLE contract'
  $$,
  '42501',
  null,
  'a contract is archived, not deleted'
);

select * from finish();

rollback;
