-- Historical costume purchase ledgers (studio GL accounts 5703/5716/5718/5722/5726),
-- one row per GL transaction line. Schema only: data is loaded separately and never
-- committed to the repo. Owners only (Blake and Lindsay).

create table public.historical_costume_spend (
  id bigint generated always as identity primary key,
  season text not null,
  fiscal_year_start date not null,
  gl_account text not null,
  gl_account_name text not null,
  program text not null,
  txn_date date not null,
  payee text not null,
  source_ref text,
  je_number text not null,
  debit numeric(12, 2) not null default 0,
  credit numeric(12, 2) not null default 0,
  net numeric(12, 2) generated always as (debit - credit) stored,
  source_file text not null,
  imported_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint historical_costume_spend_season_check check (season ~ '^[0-9]{4}-[0-9]{2}$'),
  constraint historical_costume_spend_amounts_check check (debit >= 0 and credit >= 0),
  constraint historical_costume_spend_program_check
    check (program in ('Elite Company', 'Recreational', 'CREW', 'ABC', 'Kickstart')),
  constraint historical_costume_spend_payee_check check (char_length(btrim(payee)) > 0),
  constraint historical_costume_spend_line_key
    unique (season, gl_account, je_number, txn_date, payee, debit, credit)
);

comment on table public.historical_costume_spend is
  'Past seasons'' costume purchases from the studio general ledger (Jun 1 – May 31). net = debit - credit; credits/refunds kept as rows. Owners only.';

create index historical_costume_spend_season_program_idx
  on public.historical_costume_spend (season, program);

create trigger historical_costume_spend_set_updated_at
  before update on public.historical_costume_spend
  for each row execute function private.set_updated_at();

revoke all on table public.historical_costume_spend from public, anon, authenticated;
grant select, insert, update, delete on table public.historical_costume_spend to authenticated;
grant select, insert, update, delete on table public.historical_costume_spend to service_role;

alter table public.historical_costume_spend enable row level security;

create policy historical_costume_spend_select
  on public.historical_costume_spend for select to authenticated
  using ((select private.is_owner()));

create policy historical_costume_spend_insert
  on public.historical_costume_spend for insert to authenticated
  with check ((select private.is_owner()));

create policy historical_costume_spend_update
  on public.historical_costume_spend for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));

create policy historical_costume_spend_delete
  on public.historical_costume_spend for delete to authenticated
  using ((select private.is_owner()));
