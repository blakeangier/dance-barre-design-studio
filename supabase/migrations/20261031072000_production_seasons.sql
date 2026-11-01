-- The studio does not run all year. Production-only costs accrue on days
-- inside a season. No season dates are stored here.

create table public.production_seasons (
  id bigint generated always as identity primary key,
  name text not null,
  start_date date not null,
  end_date date not null,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint production_seasons_name_check check (char_length(btrim(name)) > 0),
  constraint production_seasons_dates_check check (end_date >= start_date)
);

comment on table public.production_seasons is
  'Named production stretches. Owners enter the dates. Nothing is seeded.';

create table public.finance_run_settings (
  id boolean primary key default true,
  payroll_runs text not null default 'production_only',
  variable_spend_runs text not null default 'production_only',
  constraint finance_run_settings_singleton check (id),
  constraint finance_run_settings_payroll_check check (
    payroll_runs in ('year_round', 'production_only')
  ),
  constraint finance_run_settings_variable_check check (
    variable_spend_runs in ('year_round', 'production_only')
  )
);

comment on table public.finance_run_settings is
  'Whether payroll and the card-spend average run all year or only during production. WSIB follows payroll.';

insert into public.finance_run_settings (id) values (true);

alter table public.recurring_costs
  add column runs text not null default 'year_round';

alter table public.recurring_costs
  add constraint recurring_costs_runs_check check (
    runs in ('year_round', 'production_only')
  );

comment on column public.recurring_costs.runs is
  'year_round is charged every day. production_only is charged only on days inside a production season. WSIB uses the payroll setting instead.';

create trigger production_seasons_set_updated_at
  before update on public.production_seasons
  for each row execute function private.set_updated_at();

create trigger production_seasons_reject_delete
  before delete on public.production_seasons
  for each row execute function private.reject_finance_delete();

create trigger finance_run_settings_reject_delete
  before delete on public.finance_run_settings
  for each row execute function private.reject_finance_delete();

revoke all on table public.production_seasons from public, anon, authenticated;
grant select, insert, update on table public.production_seasons to authenticated;
grant select, insert, update, delete on table public.production_seasons to service_role;

revoke all on table public.finance_run_settings from public, anon, authenticated;
grant select, update on table public.finance_run_settings to authenticated;
grant select, insert, update, delete on table public.finance_run_settings to service_role;

alter table public.production_seasons enable row level security;
alter table public.finance_run_settings enable row level security;

create policy production_seasons_select
  on public.production_seasons for select to authenticated
  using ((select private.is_owner()));

create policy production_seasons_insert
  on public.production_seasons for insert to authenticated
  with check ((select private.is_owner()));

create policy production_seasons_update
  on public.production_seasons for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));

create policy finance_run_settings_select
  on public.finance_run_settings for select to authenticated
  using ((select private.is_owner()));

create policy finance_run_settings_update
  on public.finance_run_settings for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));
