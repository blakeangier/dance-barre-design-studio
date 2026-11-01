-- Owners-only finances. No dollar amounts are seeded. Blake loads the real
-- figures in dev. Categories are names only.

create table public.finance_categories (
  id bigint generated always as identity primary key,
  name text not null unique,
  sort_order integer not null unique,
  excludes_from_totals boolean not null default false,
  archived_at timestamptz,
  constraint finance_categories_name_check check (char_length(btrim(name)) > 0)
);

comment on table public.finance_categories is
  'Spend categories for the design studio. Not a Design Studio cost is left out of totals.';

insert into public.finance_categories (name, sort_order, excludes_from_totals)
values
  ('Fabric', 1, false),
  ('Trims and notions', 2, false),
  ('Equipment and supplies', 3, false),
  ('Fixtures', 4, false),
  ('Packaging', 5, false),
  ('Renovation', 6, false),
  ('Equipment lease', 7, false),
  ('Insurance', 8, false),
  ('WSIB', 9, false),
  ('Payroll', 10, false),
  ('Contractors', 11, false),
  ('Bank fees', 12, false),
  ('Software and subscriptions', 13, false),
  ('Miscellaneous', 14, false),
  ('Not a Design Studio cost', 15, true);

create table public.startup_costs (
  id bigint generated always as identity primary key,
  occurred_on date not null,
  description text not null,
  vendor text,
  category_id bigint not null references public.finance_categories (id),
  amount_cad numeric(12, 2) not null,
  hst_cad numeric(12, 2) not null default 0,
  notes text,
  source text not null default 'manual',
  archived_at timestamptz,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint startup_costs_description_check check (char_length(btrim(description)) > 0),
  constraint startup_costs_source_check check (source in ('manual', 'card_statement'))
);

comment on table public.startup_costs is
  'One-time startup lines. Pre-tax and HST are separate. Archive instead of deleting. Owners only.';

create index startup_costs_category_idx on public.startup_costs (category_id);

create table public.card_transactions (
  id bigint generated always as identity primary key,
  statement_period text,
  transaction_date date not null,
  merchant text not null,
  amount_cad numeric(12, 2) not null,
  hst_cad numeric(12, 2) not null default 0,
  original_currency text not null default 'CAD',
  original_amount numeric(12, 2),
  category_id bigint references public.finance_categories (id),
  notes text,
  is_startup boolean not null default false,
  excluded boolean not null default false,
  purchase_line_id bigint references public.purchase_order_lines (id),
  archived_at timestamptz,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint card_transactions_merchant_check check (char_length(btrim(merchant)) > 0),
  constraint card_transactions_currency_check check (char_length(original_currency) = 3)
);

comment on table public.card_transactions is
  'Imported card statement lines. amount_cad is pre-tax. Excluded lines and Not a Design Studio cost stay out of totals. Owners only.';

create index card_transactions_date_idx on public.card_transactions (transaction_date);
create index card_transactions_category_idx on public.card_transactions (category_id);

create table public.recurring_costs (
  id bigint generated always as identity primary key,
  name text not null,
  category_id bigint not null references public.finance_categories (id),
  amount_cad numeric(12, 2) not null,
  hst_cad numeric(12, 2) not null default 0,
  frequency text not null,
  start_date date not null,
  end_date date,
  notes text,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint recurring_costs_name_check check (char_length(btrim(name)) > 0),
  constraint recurring_costs_frequency_check check (
    frequency in ('monthly', 'quarterly', 'yearly', 'bi-weekly', 'per_pay_period')
  ),
  constraint recurring_costs_dates_check check (end_date is null or end_date >= start_date)
);

comment on table public.recurring_costs is
  'Lease, insurance, WSIB, contractor retainers, and software. Normalized to a month on the overview. Owners only.';

create table public.payroll_actuals (
  id bigint generated always as identity primary key,
  period_start date not null,
  period_end date not null,
  gross_cad numeric(12, 2) not null,
  employer_cpp_cad numeric(12, 2) not null default 0,
  employer_ei_cad numeric(12, 2) not null default 0,
  notes text,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint payroll_actuals_period_check check (period_end >= period_start)
);

comment on table public.payroll_actuals is
  'Owner-entered payroll remittances. Employer CPP and EI are separate from gross. Contractors are not payroll. Owners only.';

create trigger startup_costs_set_updated_at
  before update on public.startup_costs
  for each row execute function private.set_updated_at();

create trigger card_transactions_set_updated_at
  before update on public.card_transactions
  for each row execute function private.set_updated_at();

create trigger recurring_costs_set_updated_at
  before update on public.recurring_costs
  for each row execute function private.set_updated_at();

create trigger payroll_actuals_set_updated_at
  before update on public.payroll_actuals
  for each row execute function private.set_updated_at();

create or replace function private.reject_finance_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Archive this finance record. It cannot be deleted.'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_finance_delete() from public, anon;
grant execute on function private.reject_finance_delete() to authenticated, service_role;

create trigger finance_categories_reject_delete
  before delete on public.finance_categories
  for each row execute function private.reject_finance_delete();

create trigger startup_costs_reject_delete
  before delete on public.startup_costs
  for each row execute function private.reject_finance_delete();

create trigger card_transactions_reject_delete
  before delete on public.card_transactions
  for each row execute function private.reject_finance_delete();

create trigger recurring_costs_reject_delete
  before delete on public.recurring_costs
  for each row execute function private.reject_finance_delete();

create trigger payroll_actuals_reject_delete
  before delete on public.payroll_actuals
  for each row execute function private.reject_finance_delete();

revoke all on table public.finance_categories from public, anon, authenticated;
grant select on table public.finance_categories to authenticated;
grant select, insert, update, delete on table public.finance_categories to service_role;

revoke all on table public.startup_costs from public, anon, authenticated;
grant select, insert, update on table public.startup_costs to authenticated;
grant select, insert, update, delete on table public.startup_costs to service_role;

revoke all on table public.card_transactions from public, anon, authenticated;
grant select, insert, update on table public.card_transactions to authenticated;
grant select, insert, update, delete on table public.card_transactions to service_role;

revoke all on table public.recurring_costs from public, anon, authenticated;
grant select, insert, update on table public.recurring_costs to authenticated;
grant select, insert, update, delete on table public.recurring_costs to service_role;

revoke all on table public.payroll_actuals from public, anon, authenticated;
grant select, insert, update on table public.payroll_actuals to authenticated;
grant select, insert, update, delete on table public.payroll_actuals to service_role;

alter table public.finance_categories enable row level security;
alter table public.startup_costs enable row level security;
alter table public.card_transactions enable row level security;
alter table public.recurring_costs enable row level security;
alter table public.payroll_actuals enable row level security;

create policy finance_categories_select
  on public.finance_categories for select to authenticated
  using ((select private.is_owner()));

create policy startup_costs_select
  on public.startup_costs for select to authenticated
  using ((select private.is_owner()));

create policy startup_costs_insert
  on public.startup_costs for insert to authenticated
  with check ((select private.is_owner()));

create policy startup_costs_update
  on public.startup_costs for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));

create policy card_transactions_select
  on public.card_transactions for select to authenticated
  using ((select private.is_owner()));

create policy card_transactions_insert
  on public.card_transactions for insert to authenticated
  with check ((select private.is_owner()));

create policy card_transactions_update
  on public.card_transactions for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));

create policy recurring_costs_select
  on public.recurring_costs for select to authenticated
  using ((select private.is_owner()));

create policy recurring_costs_insert
  on public.recurring_costs for insert to authenticated
  with check ((select private.is_owner()));

create policy recurring_costs_update
  on public.recurring_costs for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));

create policy payroll_actuals_select
  on public.payroll_actuals for select to authenticated
  using ((select private.is_owner()));

create policy payroll_actuals_insert
  on public.payroll_actuals for insert to authenticated
  with check ((select private.is_owner()));

create policy payroll_actuals_update
  on public.payroll_actuals for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));
