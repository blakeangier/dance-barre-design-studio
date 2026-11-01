-- Costumes bought from other stores for the competitive programs.
-- This is dance-program money, not a Design Studio startup or running cost.
-- No purchase amounts are seeded.

create table public.outside_costume_budgets (
  id bigint generated always as identity primary key,
  program_id bigint not null references public.programs (id),
  season_label text not null,
  budget_amount numeric(12, 2),
  notes text,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint outside_costume_budgets_season_check check (
    char_length(btrim(season_label)) > 0
  ),
  constraint outside_costume_budgets_amount_check check (
    budget_amount is null or budget_amount >= 0
  )
);

comment on table public.outside_costume_budgets is
  'Optional CAD budget for outside costumes in one program and season. Owners only.';

comment on column public.outside_costume_budgets.budget_amount is
  'CAD. USD purchases are tracked separately and are not subtracted from this.';

create table public.outside_costume_purchases (
  id bigint generated always as identity primary key,
  program_id bigint not null references public.programs (id),
  source_tab text not null,
  purchased_on date,
  raw_date text,
  payment_method text,
  vendor text not null,
  item_description text not null,
  amount numeric(12, 2),
  currency text not null default 'CAD',
  arrival_status text,
  reimbursement boolean not null default false,
  reimbursement_note text,
  notes text,
  is_refund boolean not null default false,
  source_row_hash text not null unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint outside_costume_purchases_currency_check check (
    currency in ('CAD', 'USD')
  ),
  constraint outside_costume_purchases_card_check check (
    payment_method is null or payment_method !~ '[0-9]{8,}'
  ),
  constraint outside_costume_purchases_vendor_check check (
    char_length(btrim(vendor)) > 0
  )
);

comment on table public.outside_costume_purchases is
  'One line from the owners sheet. raw_date keeps text such as Aug. 19. payment_method is a label such as a last 4, never a full card number. Archive instead of deleting. Owners only.';

comment on column public.outside_costume_purchases.source_row_hash is
  'Stable id for a sheet row so a weekly import updates the same line.';

create index outside_costume_purchases_program_idx
  on public.outside_costume_purchases (program_id)
  where archived_at is null;

create table public.outside_costume_import_runs (
  id bigint generated always as identity primary key,
  started_at timestamptz not null default now(),
  rows_seen integer not null,
  inserted integer not null,
  updated integer not null,
  archived_missing integer not null,
  notes text,
  constraint outside_costume_import_runs_counts_check check (
    rows_seen >= 0
    and inserted >= 0
    and updated >= 0
    and archived_missing >= 0
  )
);

comment on table public.outside_costume_import_runs is
  'One weekly import of the outside-costume sheet. Owners only.';

create trigger outside_costume_budgets_set_updated_at
  before update on public.outside_costume_budgets
  for each row execute function private.set_updated_at();

create trigger outside_costume_purchases_set_updated_at
  before update on public.outside_costume_purchases
  for each row execute function private.set_updated_at();

create trigger outside_costume_budgets_reject_delete
  before delete on public.outside_costume_budgets
  for each row execute function private.reject_finance_delete();

create trigger outside_costume_purchases_reject_delete
  before delete on public.outside_costume_purchases
  for each row execute function private.reject_finance_delete();

create trigger outside_costume_import_runs_reject_delete
  before delete on public.outside_costume_import_runs
  for each row execute function private.reject_finance_delete();

create or replace function public.upsert_outside_costume_purchases(payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  claims text := nullif(current_setting('request.jwt.claims', true), '');
  caller_role text := '';
  item jsonb;
  seen integer := 0;
  inserted_count integer := 0;
  updated_count integer := 0;
  archived_count integer := 0;
  program_id bigint;
  row_hash text;
  tabs text[] := '{}';
  hashes text[] := '{}';
begin
  if claims is not null then
    caller_role := coalesce(claims::jsonb ->> 'role', '');
  end if;
  if caller_role is distinct from 'service_role' and not private.is_owner() then
    raise exception 'Only an owner can import outside costumes'
      using errcode = '42501';
  end if;
  if jsonb_typeof(payload -> 'rows') is distinct from 'array' then
    raise exception 'The import needs a rows array'
      using errcode = '23514';
  end if;

  drop table if exists pg_temp.outside_import;
  create temporary table pg_temp.outside_import (
    source_row_hash text primary key,
    program_id bigint not null,
    source_tab text not null,
    purchased_on date,
    raw_date text,
    payment_method text,
    vendor text not null,
    item_description text not null,
    amount numeric(12, 2),
    currency text not null,
    arrival_status text,
    reimbursement boolean not null,
    reimbursement_note text,
    notes text,
    is_refund boolean not null
  ) on commit drop;

  for item in
    select value from jsonb_array_elements(payload -> 'rows')
  loop
    seen := seen + 1;
    row_hash := nullif(btrim(item ->> 'source_row_hash'), '');
    if row_hash is null then
      raise exception 'Each row needs a source_row_hash'
        using errcode = '23514';
    end if;
    if coalesce(item ->> 'payment_method', '') ~ '[0-9]{8,}' then
      raise exception 'Do not store a full card number'
        using errcode = '23514';
    end if;
    if nullif(item ->> 'program_id', '') is not null then
      select program.id into program_id
      from public.programs program
      where program.id = (item ->> 'program_id')::bigint;
    else
      select program.id into program_id
      from public.programs program
      where lower(program.name) = lower(btrim(coalesce(item ->> 'program_name', '')));
    end if;
    if program_id is null then
      raise exception 'Unknown program'
        using errcode = '23503';
    end if;
    insert into pg_temp.outside_import (
      source_row_hash, program_id, source_tab, purchased_on, raw_date,
      payment_method, vendor, item_description, amount, currency,
      arrival_status, reimbursement, reimbursement_note, notes, is_refund
    )
    values (
      row_hash,
      program_id,
      btrim(coalesce(item ->> 'source_tab', '')),
      case
        when coalesce(item ->> 'purchased_on', '') ~ '^\d{4}-\d{2}-\d{2}$'
          then (item ->> 'purchased_on')::date
        else null
      end,
      nullif(btrim(coalesce(item ->> 'raw_date', '')), ''),
      nullif(btrim(coalesce(item ->> 'payment_method', '')), ''),
      btrim(coalesce(item ->> 'vendor', '')),
      btrim(coalesce(item ->> 'item_description', '')),
      nullif(item ->> 'amount', '')::numeric,
      case
        when upper(btrim(coalesce(item ->> 'currency', 'CAD'))) = 'USD' then 'USD'
        else 'CAD'
      end,
      nullif(btrim(coalesce(item ->> 'arrival_status', '')), ''),
      coalesce((item ->> 'reimbursement')::boolean, false),
      nullif(btrim(coalesce(item ->> 'reimbursement_note', '')), ''),
      nullif(btrim(coalesce(item ->> 'notes', '')), ''),
      coalesce((item ->> 'is_refund')::boolean, false)
        or coalesce(nullif(item ->> 'amount', '')::numeric, 0) < 0
    );
    tabs := tabs || btrim(coalesce(item ->> 'source_tab', ''));
    hashes := hashes || row_hash;
  end loop;

  update public.outside_costume_purchases purchase
  set
    program_id = incoming.program_id,
    source_tab = incoming.source_tab,
    purchased_on = incoming.purchased_on,
    raw_date = incoming.raw_date,
    payment_method = incoming.payment_method,
    vendor = incoming.vendor,
    item_description = incoming.item_description,
    amount = incoming.amount,
    currency = incoming.currency,
    arrival_status = incoming.arrival_status,
    reimbursement = incoming.reimbursement,
    reimbursement_note = incoming.reimbursement_note,
    notes = incoming.notes,
    is_refund = incoming.is_refund,
    archived_at = null
  from pg_temp.outside_import incoming
  where purchase.source_row_hash = incoming.source_row_hash;
  get diagnostics updated_count = row_count;

  insert into public.outside_costume_purchases (
    program_id, source_tab, purchased_on, raw_date, payment_method, vendor,
    item_description, amount, currency, arrival_status, reimbursement,
    reimbursement_note, notes, is_refund, source_row_hash
  )
  select
    incoming.program_id, incoming.source_tab, incoming.purchased_on,
    incoming.raw_date, incoming.payment_method, incoming.vendor,
    incoming.item_description, incoming.amount, incoming.currency,
    incoming.arrival_status, incoming.reimbursement, incoming.reimbursement_note,
    incoming.notes, incoming.is_refund, incoming.source_row_hash
  from pg_temp.outside_import incoming
  where not exists (
    select 1
    from public.outside_costume_purchases purchase
    where purchase.source_row_hash = incoming.source_row_hash
  );
  get diagnostics inserted_count = row_count;

  update public.outside_costume_purchases purchase
  set archived_at = now()
  where purchase.archived_at is null
    and purchase.source_tab = any (tabs)
    and not (purchase.source_row_hash = any (hashes));
  get diagnostics archived_count = row_count;

  insert into public.outside_costume_import_runs (
    rows_seen, inserted, updated, archived_missing, notes
  )
  values (
    seen,
    inserted_count,
    updated_count,
    archived_count,
    nullif(btrim(coalesce(payload ->> 'notes', '')), '')
  );

  return jsonb_build_object(
    'rows_seen', seen,
    'inserted', inserted_count,
    'updated', updated_count,
    'archived_missing', archived_count
  );
end;
$$;

comment on function public.upsert_outside_costume_purchases(jsonb) is
  'Upserts outside-costume sheet rows by source_row_hash. Rows on the same tabs that are absent from this payload are archived. Owners and the service role only.';

revoke all on function public.upsert_outside_costume_purchases(jsonb) from public, anon;
grant execute on function public.upsert_outside_costume_purchases(jsonb) to authenticated, service_role;

revoke all on table public.outside_costume_budgets from public, anon, authenticated;
grant select, insert, update on table public.outside_costume_budgets to authenticated;
grant select, insert, update, delete on table public.outside_costume_budgets to service_role;

revoke all on table public.outside_costume_purchases from public, anon, authenticated;
grant select, insert, update on table public.outside_costume_purchases to authenticated;
grant select, insert, update, delete on table public.outside_costume_purchases to service_role;

revoke all on table public.outside_costume_import_runs from public, anon, authenticated;
grant select on table public.outside_costume_import_runs to authenticated;
grant select, insert, update, delete on table public.outside_costume_import_runs to service_role;

alter table public.outside_costume_budgets enable row level security;
alter table public.outside_costume_purchases enable row level security;
alter table public.outside_costume_import_runs enable row level security;

create policy outside_costume_budgets_select
  on public.outside_costume_budgets for select to authenticated
  using ((select private.is_owner()));

create policy outside_costume_budgets_insert
  on public.outside_costume_budgets for insert to authenticated
  with check ((select private.is_owner()));

create policy outside_costume_budgets_update
  on public.outside_costume_budgets for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));

create policy outside_costume_purchases_select
  on public.outside_costume_purchases for select to authenticated
  using ((select private.is_owner()));

create policy outside_costume_purchases_insert
  on public.outside_costume_purchases for insert to authenticated
  with check ((select private.is_owner()));

create policy outside_costume_purchases_update
  on public.outside_costume_purchases for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));

create policy outside_costume_import_runs_select
  on public.outside_costume_import_runs for select to authenticated
  using ((select private.is_owner()));
