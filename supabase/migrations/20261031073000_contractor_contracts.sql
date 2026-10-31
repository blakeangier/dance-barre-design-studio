-- Fixed contractor agreements. Owners enter the figures. A linked recurring
-- cost is left out of the projection while a contract is open.

create table public.contractor_contracts (
  id bigint generated always as identity primary key,
  contractor_id uuid not null references public.profiles (id),
  total_amount_cad numeric(12, 2) not null,
  hst_amount_cad numeric(12, 2) not null default 0,
  start_date date not null,
  end_date date not null,
  payout text not null default 'spread',
  notes text,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint contractor_contracts_total_check check (total_amount_cad >= 0),
  constraint contractor_contracts_hst_check check (hst_amount_cad >= 0),
  constraint contractor_contracts_dates_check check (end_date >= start_date),
  constraint contractor_contracts_payout_check check (
    payout in ('spread', 'lump_sums')
  )
);

comment on table public.contractor_contracts is
  'A fixed contract for one contractor. payout spread puts the unpaid balance on remaining production days. lump_sums uses future payment dates. Owners only.';

create index contractor_contracts_profile_idx
  on public.contractor_contracts (contractor_id)
  where archived_at is null;

create table public.contractor_payments (
  id bigint generated always as identity primary key,
  contract_id bigint not null references public.contractor_contracts (id),
  paid_on date,
  amount_cad numeric(12, 2) not null,
  hst_cad numeric(12, 2) not null default 0,
  notes text,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint contractor_payments_amount_check check (amount_cad >= 0),
  constraint contractor_payments_hst_check check (hst_cad >= 0)
);

comment on table public.contractor_payments is
  'Money paid against a contract. paid_on is blank when the date is unknown. A future date is a scheduled lump sum. Owners only.';

create index contractor_payments_contract_idx
  on public.contractor_payments (contract_id)
  where archived_at is null;

alter table public.recurring_costs
  add column contractor_profile_id uuid references public.profiles (id);

comment on column public.recurring_costs.contractor_profile_id is
  'When this person has an open contract, the projection skips this recurring row.';

create trigger contractor_contracts_set_updated_at
  before update on public.contractor_contracts
  for each row execute function private.set_updated_at();

create trigger contractor_payments_set_updated_at
  before update on public.contractor_payments
  for each row execute function private.set_updated_at();

create trigger contractor_contracts_reject_delete
  before delete on public.contractor_contracts
  for each row execute function private.reject_finance_delete();

create trigger contractor_payments_reject_delete
  before delete on public.contractor_payments
  for each row execute function private.reject_finance_delete();

revoke all on table public.contractor_contracts from public, anon, authenticated;
grant select, insert, update on table public.contractor_contracts to authenticated;
grant select, insert, update, delete on table public.contractor_contracts to service_role;

revoke all on table public.contractor_payments from public, anon, authenticated;
grant select, insert, update on table public.contractor_payments to authenticated;
grant select, insert, update, delete on table public.contractor_payments to service_role;

alter table public.contractor_contracts enable row level security;
alter table public.contractor_payments enable row level security;

create policy contractor_contracts_select
  on public.contractor_contracts for select to authenticated
  using ((select private.is_owner()));

create policy contractor_contracts_insert
  on public.contractor_contracts for insert to authenticated
  with check ((select private.is_owner()));

create policy contractor_contracts_update
  on public.contractor_contracts for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));

create policy contractor_payments_select
  on public.contractor_payments for select to authenticated
  using ((select private.is_owner()));

create policy contractor_payments_insert
  on public.contractor_payments for insert to authenticated
  with check ((select private.is_owner()));

create policy contractor_payments_update
  on public.contractor_payments for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));
