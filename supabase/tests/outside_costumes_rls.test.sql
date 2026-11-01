-- Outside costumes are owners only. SAMPLE rows stay inside this transaction.

begin;

create extension if not exists pgtap with schema extensions;
grant usage on schema extensions to authenticated, anon;
set search_path to public, extensions;

select plan(8);

insert into auth.users (
  instance_id, id, aud, role, email, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, email_change, recovery_token
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c1',
    'authenticated', 'authenticated', 'outside-owner@example.com',
    '{"role":"owner","full_name":"SAMPLE Owner"}'::jsonb, '{}'::jsonb,
    now(), now(), '', '', ''
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-0000000000c4',
    'authenticated', 'authenticated', 'outside-emp@example.com',
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

select tests.claims('00000000-0000-0000-0000-0000000000c4');
set role authenticated;

select throws_ok(
  $$
    select public.upsert_outside_costume_purchases(
      '{"rows":[{"source_row_hash":"sample-1","program_name":"CREW","source_tab":"SAMPLE","vendor":"SAMPLE Shop","item_description":"SAMPLE skirt","amount":10}]}'::jsonb
    )
  $$,
  '42501',
  'Only an owner can import outside costumes',
  'an employee cannot import outside costumes'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c1');
set role authenticated;

select lives_ok(
  $$
    select public.upsert_outside_costume_purchases(
      '{"notes":"SAMPLE import","rows":[
        {"source_row_hash":"sample-1","program_name":"CREW","source_tab":"SAMPLE","raw_date":"Aug. 19","payment_method":"6261","vendor":"SAMPLE Shop","item_description":"SAMPLE skirt","amount":10,"currency":"CAD"},
        {"source_row_hash":"sample-2","program_name":"CREW","source_tab":"SAMPLE","vendor":"SAMPLE Shop","item_description":"SAMPLE refund","amount":-4,"is_refund":true}
      ]}'::jsonb
    )
  $$,
  'an owner can import SAMPLE outside costumes'
);

select is(
  (select count(*)::int from public.outside_costume_purchases where archived_at is null),
  2,
  'both SAMPLE lines are stored'
);

select lives_ok(
  $$
    select public.upsert_outside_costume_purchases(
      '{"rows":[
        {"source_row_hash":"sample-1","program_name":"CREW","source_tab":"SAMPLE","raw_date":"Aug. 19","payment_method":"6261","vendor":"SAMPLE Shop","item_description":"SAMPLE skirt","amount":12,"currency":"CAD"}
      ]}'::jsonb
    )
  $$,
  'importing again updates the same hash and archives the line that left the sheet'
);

select is(
  (
    select archived_missing
    from public.outside_costume_import_runs
    order by id desc
    limit 1
  ),
  1,
  'the missing SAMPLE line was archived, not deleted'
);

select throws_ok(
  $$
    select public.upsert_outside_costume_purchases(
      '{"rows":[{"source_row_hash":"sample-card","program_name":"CREW","source_tab":"SAMPLE","vendor":"SAMPLE Shop","item_description":"SAMPLE skirt","payment_method":"4111111111111111","amount":1}]}'::jsonb
    )
  $$,
  '23514',
  'Do not store a full card number',
  'a full card number is rejected'
);

reset role;
select tests.claims('00000000-0000-0000-0000-0000000000c4');
set role authenticated;

select is(
  (select count(*)::int from public.outside_costume_purchases),
  0,
  'an employee sees no outside costume rows after the owner import'
);

reset role;
grant usage on schema extensions to service_role;
select set_config('request.jwt.claims', '{"role":"service_role"}', true);
set role service_role;

select extensions.lives_ok(
  $$
    select public.upsert_outside_costume_purchases(
      '{"rows":[
        {"source_row_hash":"sample-1","program_name":"CREW","source_tab":"SAMPLE","vendor":"SAMPLE Shop","item_description":"SAMPLE skirt","amount":12}
      ]}'::jsonb
    )
  $$,
  'the service role can import outside costumes'
);

select * from finish();

rollback;
