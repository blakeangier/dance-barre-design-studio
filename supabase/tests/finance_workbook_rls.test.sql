-- Finance workbook rows are owners only. SAMPLE amounts stay inside this transaction.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon, service_role;
set search_path to public, extensions;

select plan(5);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d1',
    'authenticated', 'authenticated', 'workbook-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000d4',
    'authenticated', 'authenticated', 'workbook-emp@example.com',
    '{"role":"employee","full_name":"SAMPLE Maker"}'::jsonb, '{}'::jsonb,
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

select tests.claims('00000000-0000-0000-0000-0000000000d4');
set role authenticated;

select throws_ok(
  $$
    select public.upsert_finance_rows(
      'finance_spend_lines',
      '[{"load_key":"sample-spend","section":"design_co","label":"SAMPLE tools","amount":10,"source_note":"SAMPLE"}]'::jsonb
    )
  $$,
  '42501',
  'Only an owner can load finance rows',
  'an employee cannot load finance rows'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000d1');
set role authenticated;

select lives_ok(
  $$
    select public.upsert_finance_rows(
      'finance_spend_lines',
      '[{"load_key":"sample-spend","section":"design_co","label":"SAMPLE tools","amount":10,"detail_href":"/finances/startup","source_note":"SAMPLE"}]'::jsonb
    )
  $$,
  'an owner can load a SAMPLE spend line'
);

select is(
  (select count(*)::int from public.finance_spend_lines where archived_at is null),
  1,
  'the SAMPLE spend line is stored'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000d4');
set role authenticated;

select is(
  (select count(*)::int from public.finance_spend_lines),
  0,
  'an employee sees no spend lines after the owner load'
);

select is(
  (select count(*)::int from public.expense_log),
  0,
  'an employee sees no expense log rows'
);

select * from finish();

rollback;
