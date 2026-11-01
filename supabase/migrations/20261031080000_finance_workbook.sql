-- Owners' finance workbook. No dollar amounts and no season dates are seeded.
-- Blake loads the real rows in dev, through SQL or upsert_finance_rows.
-- Archive instead of deleting. Every money row keeps a source_note.

-- ---------------------------------------------------------------------------
-- Columns on the ledgers that already exist
-- ---------------------------------------------------------------------------

alter table public.startup_costs
  add column source_note text not null default '',
  add column startup_share_percent numeric(5, 2) not null default 100,
  add column load_key text unique;

alter table public.startup_costs
  add constraint startup_costs_share_check check (
    startup_share_percent >= 0 and startup_share_percent <= 100
  );

comment on column public.startup_costs.startup_share_percent is
  'Percent of this line that counts as startup. 50 means half of one invoice.';

comment on column public.startup_costs.source_note is
  'Where this number came from.';

comment on column public.startup_costs.load_key is
  'Stable key for upsert_finance_rows. Blank on rows typed in the app.';

alter table public.card_transactions
  add column source_note text not null default '',
  add column load_key text unique;

alter table public.recurring_costs
  add column source_note text not null default '',
  add column load_key text unique;

alter table public.payroll_actuals
  add column source_note text not null default '',
  add column load_key text unique;

alter table public.production_seasons
  add column source_note text not null default '';

alter table public.contractor_contracts
  add column source_note text not null default '',
  add column load_key text unique;

alter table public.contractor_payments
  add column source_note text not null default '',
  add column load_key text unique,
  add column payment_method text,
  add column description text;

alter table public.contractor_payments
  add constraint contractor_payments_method_check check (
    payment_method is null or payment_method !~ '[0-9]{8,}'
  );

alter table public.outside_costume_budgets
  add column source_note text not null default '';

alter table public.outside_costume_purchases
  add column source_note text not null default '',
  add column load_key text unique,
  add column vendor_type text,
  add column flag_duplicate boolean not null default false,
  add column flag_canceled boolean not null default false,
  add column flag_owing boolean not null default false;

comment on column public.outside_costume_purchases.vendor_type is
  'Owner label such as retailer or dance supplier. Free text, not a seeded list.';

comment on column public.outside_costume_purchases.flag_duplicate is
  'Left out of the outside-costume summary.';

comment on column public.outside_costume_purchases.flag_canceled is
  'Left out of the outside-costume summary.';

comment on column public.outside_costume_purchases.flag_owing is
  'Still to pay. Shown in the owing total.';

-- ---------------------------------------------------------------------------
-- Workbook tables
-- ---------------------------------------------------------------------------

create table public.finance_spend_lines (
  id bigint generated always as identity primary key,
  section text not null,
  label text not null,
  amount numeric(12, 2) not null,
  detail_href text,
  sort_order integer not null default 0,
  source_note text not null default '',
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint finance_spend_lines_section_check check (
    section in ('design_co', 'outside_costumes')
  ),
  constraint finance_spend_lines_label_check check (char_length(btrim(label)) > 0),
  constraint finance_spend_lines_href_check check (
    detail_href is null or detail_href like '/finances%'
  )
);

comment on table public.finance_spend_lines is
  'Where the money went. design_co or outside_costumes. Owners only. No amounts are seeded.';

create table public.finance_committed_items (
  id bigint generated always as identity primary key,
  label text not null,
  amount numeric(12, 2) not null,
  detail_href text,
  counts_as_startup boolean not null default false,
  sort_order integer not null default 0,
  source_note text not null default '',
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint finance_committed_items_label_check check (char_length(btrim(label)) > 0),
  constraint finance_committed_items_href_check check (
    detail_href is null or detail_href like '/finances%'
  )
);

comment on table public.finance_committed_items is
  'Committed but not yet paid. counts_as_startup feeds the full startup total. Owners only.';

create table public.finance_funding_lines (
  id bigint generated always as identity primary key,
  paid_from text not null,
  label text not null,
  amount numeric(12, 2) not null,
  sort_order integer not null default 0,
  source_note text not null default '',
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint finance_funding_lines_paid_from_check check (
    paid_from in (
      'card',
      'e-transfer',
      'carm_credit',
      'personal_card_reimbursed',
      'payroll_eft',
      'lease',
      'not_recorded'
    )
  ),
  constraint finance_funding_lines_label_check check (char_length(btrim(label)) > 0),
  constraint finance_funding_lines_method_check check (label !~ '[0-9]{8,}')
);

comment on table public.finance_funding_lines is
  'Where the money came from. The label can be a card ending, never a full card number. Owners only.';

create table public.finance_cost_lines (
  id bigint generated always as identity primary key,
  section text not null,
  label text not null,
  amount numeric(12, 2) not null,
  hst numeric(12, 2) not null default 0,
  adjustment text not null default 'none',
  sort_order integer not null default 0,
  source_note text not null default '',
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint finance_cost_lines_section_check check (
    section in ('make_in_house', 'purchased_outside')
  ),
  constraint finance_cost_lines_label_check check (char_length(btrim(label)) > 0),
  constraint finance_cost_lines_adjustment_check check (
    adjustment in ('none', 'canceled', 'duplicate', 'owing')
  )
);

comment on table public.finance_cost_lines is
  'Cost to make in house, and costumes purchased outside, including canceled, duplicate, and owing adjustments. Startup stays on startup_costs. Owners only.';

create table public.finance_unit_settings (
  id boolean primary key default true,
  units numeric(12, 2),
  cost_per_unit numeric(12, 2),
  source_note text not null default '',
  updated_at timestamptz not null default now(),
  constraint finance_unit_settings_singleton check (id),
  constraint finance_unit_settings_units_check check (units is null or units >= 0),
  constraint finance_unit_settings_rate_check check (
    cost_per_unit is null or cost_per_unit >= 0
  )
);

comment on table public.finance_unit_settings is
  'Editable unit count and cost per unit for the season comparison. One row. Owners only.';

create table public.expense_log (
  id bigint generated always as identity primary key,
  occurred_on date,
  amount numeric(12, 2) not null,
  payment_as_entered text,
  paid_from text not null,
  vendor text,
  description text not null,
  category text not null,
  flag_notes text,
  source_note text not null default '',
  card_transaction_id bigint references public.card_transactions (id),
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint expense_log_description_check check (char_length(btrim(description)) > 0),
  constraint expense_log_paid_from_check check (
    paid_from in (
      'card',
      'e-transfer',
      'carm_credit',
      'personal_card_reimbursed',
      'payroll_eft',
      'lease',
      'not_recorded'
    )
  ),
  constraint expense_log_category_check check (
    category in (
      'equipment_tools',
      'studio_build_out',
      'fabric_supplies',
      'website',
      'people',
      'admin_fees',
      'equipment_repair',
      'supplies_reimbursed'
    )
  ),
  constraint expense_log_method_check check (
    payment_as_entered is null or payment_as_entered !~ '[0-9]{8,}'
  )
);

comment on table public.expense_log is
  'Workbook expense log. card_transaction_id marks a Visa line already recorded here so it is not added twice. Owners only.';

comment on column public.expense_log.payment_as_entered is
  'The payment text from the sheet, such as a last 4. Never a full card number.';

create unique index expense_log_card_idx
  on public.expense_log (card_transaction_id)
  where card_transaction_id is not null and archived_at is null;

create index expense_log_category_idx
  on public.expense_log (category)
  where archived_at is null;

create table public.contractor_invoices (
  id bigint generated always as identity primary key,
  profile_id uuid not null references public.profiles (id),
  paid_on date,
  invoice_number text,
  period_start date,
  period_end date,
  hours numeric(8, 2),
  rate numeric(12, 2),
  hst numeric(12, 2) not null default 0,
  expected numeric(12, 2),
  amount_paid numeric(12, 2),
  payment_method text,
  notes text,
  source_note text not null default '',
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint contractor_invoices_period_check check (
    period_end is null or period_start is null or period_end >= period_start
  ),
  constraint contractor_invoices_method_check check (
    payment_method is null or payment_method !~ '[0-9]{8,}'
  )
);

comment on table public.contractor_invoices is
  'Invoices and pay lines for one person. Paid below expected is an underpayment. Owners only.';

create index contractor_invoices_profile_idx
  on public.contractor_invoices (profile_id)
  where archived_at is null;

create table public.contractor_contract_phases (
  id bigint generated always as identity primary key,
  contract_id bigint not null references public.contractor_contracts (id),
  label text not null,
  sort_order integer not null default 0,
  amount_before_hst numeric(12, 2) not null,
  hst numeric(12, 2) not null default 0,
  notes text,
  source_note text not null default '',
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint contractor_contract_phases_label_check check (char_length(btrim(label)) > 0)
);

comment on table public.contractor_contract_phases is
  'Setup, extension, and other phases of one contract. Incl-HST is before-HST plus HST. Owners only.';

create index contractor_contract_phases_contract_idx
  on public.contractor_contract_phases (contract_id)
  where archived_at is null;

create table public.equipment_quote_items (
  id bigint generated always as identity primary key,
  label text not null,
  new_price numeric(12, 2),
  preowned_price numeric(12, 2),
  notes text,
  source_note text not null default '',
  sort_order integer not null default 0,
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint equipment_quote_items_label_check check (char_length(btrim(label)) > 0),
  constraint equipment_quote_items_new_check check (new_price is null or new_price >= 0),
  constraint equipment_quote_items_used_check check (
    preowned_price is null or preowned_price >= 0
  )
);

comment on table public.equipment_quote_items is
  'Equipment quote. Savings are new price minus pre-owned price. Owners only.';

create table public.lease_options (
  id bigint generated always as identity primary key,
  label text not null,
  term_months integer not null,
  monthly_payment numeric(12, 2) not null,
  hst numeric(12, 2) not null default 0,
  buyout numeric(12, 2),
  upfront numeric(12, 2) not null default 0,
  is_chosen boolean not null default false,
  payments_made integer not null default 0,
  started_on date,
  notes text,
  source_note text not null default '',
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint lease_options_label_check check (char_length(btrim(label)) > 0),
  constraint lease_options_term_check check (term_months > 0),
  constraint lease_options_payment_check check (monthly_payment >= 0),
  constraint lease_options_hst_check check (hst >= 0),
  constraint lease_options_buyout_check check (buyout is null or buyout >= 0),
  constraint lease_options_upfront_check check (upfront >= 0),
  constraint lease_options_made_check check (payments_made >= 0)
);

comment on table public.lease_options is
  'Lease choices. One unarchived row can be the chosen lease. upfront is first and last. Owners only.';

create unique index lease_options_one_chosen_idx
  on public.lease_options ((true))
  where is_chosen and archived_at is null;

create table public.finance_projection_months (
  id bigint generated always as identity primary key,
  month_start date not null unique,
  is_production boolean not null,
  source_note text not null default '',
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint finance_projection_months_start_check check (
    month_start = date_trunc('month', month_start)::date
  )
);

comment on table public.finance_projection_months is
  'Owner override for a month. 1 is a production month. Months with no row use production_seasons, or Fall Aug 1–Dec 5 and Spring Feb 1–Apr 15 when no seasons are stored. Owners only.';

create table public.finance_projection_team (
  id bigint generated always as identity primary key,
  person_name text not null,
  profile_id uuid references public.profiles (id),
  role_label text,
  pay_kind text not null,
  hours_per_week numeric(6, 2),
  rate numeric(12, 2) not null,
  adds_hst boolean not null default false,
  runs text not null default 'every_month',
  sort_order integer not null default 0,
  source_note text not null default '',
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint finance_projection_team_name_check check (char_length(btrim(person_name)) > 0),
  constraint finance_projection_team_kind_check check (
    pay_kind in ('hourly_weekly', 'fixed_biweekly')
  ),
  constraint finance_projection_team_runs_check check (
    runs in ('every_month', 'production_only')
  ),
  constraint finance_projection_team_hours_check check (
    hours_per_week is null or hours_per_week >= 0
  ),
  constraint finance_projection_team_rate_check check (rate >= 0)
);

comment on table public.finance_projection_team is
  'Projection people. Monthly pre-tax is the weekly amount times 4.33. Weekly is hours times rate, or fixed pay per 2 weeks divided by 2. Owners only.';

create table public.finance_projection_costs (
  id bigint generated always as identity primary key,
  label text not null,
  amount numeric(12, 2) not null,
  period text not null,
  runs text not null default 'every_month',
  sort_order integer not null default 0,
  source_note text not null default '',
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint finance_projection_costs_label_check check (char_length(btrim(label)) > 0),
  constraint finance_projection_costs_period_check check (period in ('month', 'year')),
  constraint finance_projection_costs_runs_check check (
    runs in ('every_month', 'production_only')
  )
);

comment on table public.finance_projection_costs is
  'Other projection costs. A yearly amount is divided by 12 on each month it applies. Owners only.';

create table public.finance_todos (
  id bigint generated always as identity primary key,
  item text not null,
  amount numeric(12, 2),
  status text not null default 'open',
  action text,
  source_note text not null default '',
  load_key text unique,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint finance_todos_item_check check (char_length(btrim(item)) > 0),
  constraint finance_todos_status_check check (status in ('open', 'done', 'waiting'))
);

comment on table public.finance_todos is
  'Open questions about the finance workbook. Owners only.';

-- ---------------------------------------------------------------------------
-- Owner access, archive-only, audit
-- ---------------------------------------------------------------------------

do $$
declare
  target text;
  fresh text[] := array[
    'finance_spend_lines',
    'finance_committed_items',
    'finance_funding_lines',
    'finance_cost_lines',
    'finance_unit_settings',
    'expense_log',
    'contractor_invoices',
    'contractor_contract_phases',
    'equipment_quote_items',
    'lease_options',
    'finance_projection_months',
    'finance_projection_team',
    'finance_projection_costs',
    'finance_todos'
  ];
  existing text[] := array[
    'startup_costs',
    'card_transactions',
    'recurring_costs',
    'payroll_actuals',
    'production_seasons',
    'contractor_contracts',
    'contractor_payments',
    'outside_costume_budgets',
    'outside_costume_purchases',
    'outside_costume_import_runs'
  ];
begin
  foreach target in array fresh loop
    execute format(
      'create trigger %I before update on public.%I for each row execute function private.set_updated_at()',
      target || '_set_updated_at',
      target
    );
    execute format(
      'create trigger %I before delete on public.%I for each row execute function private.reject_finance_delete()',
      target || '_reject_delete',
      target
    );
    execute format(
      'create trigger %I after insert or update or delete on public.%I for each row execute function private.audit_row()',
      target || '_audit',
      target
    );
    execute format('revoke all on table public.%I from public, anon, authenticated', target);
    execute format('grant select, insert, update on table public.%I to authenticated', target);
    execute format(
      'grant select, insert, update, delete on table public.%I to service_role',
      target
    );
    execute format('alter table public.%I enable row level security', target);
    execute format(
      'create policy %I on public.%I for select to authenticated using ((select private.is_owner()))',
      target || '_select',
      target
    );
    execute format(
      'create policy %I on public.%I for insert to authenticated with check ((select private.is_owner()))',
      target || '_insert',
      target
    );
    execute format(
      'create policy %I on public.%I for update to authenticated using ((select private.is_owner())) with check ((select private.is_owner()))',
      target || '_update',
      target
    );
  end loop;

  foreach target in array existing loop
    execute format(
      'create trigger %I after insert or update or delete on public.%I for each row execute function private.audit_row()',
      target || '_audit',
      target
    );
  end loop;
end;
$$;

comment on column public.finance_spend_lines.source_note is 'Where this number came from.';
comment on column public.finance_committed_items.source_note is 'Where this number came from.';
comment on column public.finance_funding_lines.source_note is 'Where this number came from.';
comment on column public.finance_cost_lines.source_note is 'Where this number came from.';
comment on column public.finance_unit_settings.source_note is 'Where this number came from.';
comment on column public.expense_log.source_note is 'Where this number came from.';
comment on column public.contractor_invoices.source_note is 'Where this number came from.';
comment on column public.contractor_contract_phases.source_note is 'Where this number came from.';
comment on column public.equipment_quote_items.source_note is 'Where this number came from.';
comment on column public.lease_options.source_note is 'Where this number came from.';
comment on column public.finance_projection_months.source_note is 'Where this flag came from.';
comment on column public.finance_projection_team.source_note is 'Where this number came from.';
comment on column public.finance_projection_costs.source_note is 'Where this number came from.';
comment on column public.finance_todos.source_note is 'Where this question came from.';

-- ---------------------------------------------------------------------------
-- Bulk load. Owners and the service role. Upsert by load_key. Nothing is deleted.
--
-- select public.upsert_finance_rows('finance_spend_lines', jsonb_build_array(
--   jsonb_build_object(
--     'load_key', 'sample-spend-1',
--     'section', 'design_co',
--     'label', 'SAMPLE line',
--     'amount', 0,
--     'detail_href', '/finances/startup',
--     'source_note', 'SAMPLE'
--   )
-- ));
--
-- Targets and keys:
--   finance_spend_lines: load_key, section, label, amount, detail_href, sort_order, source_note
--   finance_committed_items: load_key, label, amount, detail_href, counts_as_startup, sort_order, source_note
--   finance_funding_lines: load_key, paid_from, label, amount, sort_order, source_note
--   finance_cost_lines: load_key, section, label, amount, hst, adjustment, sort_order, source_note
--   finance_unit_settings: units, cost_per_unit, source_note (one object in a one-row array)
--   expense_log: load_key, occurred_on, amount, payment_as_entered, paid_from, vendor, description, category, flag_notes, source_note, card_transaction_id
--   contractor_invoices: load_key, profile_id, paid_on, invoice_number, period_start, period_end, hours, rate, hst, expected, amount_paid, payment_method, notes, source_note
--   contractor_contract_phases: load_key, contract_id, label, sort_order, amount_before_hst, hst, notes, source_note
--   contractor_contracts: load_key, contractor_id, total_amount_cad, hst_amount_cad, start_date, end_date, payout, notes, source_note
--   contractor_payments: load_key, contract_id, paid_on, amount_cad, hst_cad, notes, source_note, payment_method, description
--   startup_costs: load_key, occurred_on, description, vendor, category_id, amount_cad, hst_cad, notes, source, source_note, startup_share_percent, created_by
--   equipment_quote_items: load_key, label, new_price, preowned_price, notes, source_note, sort_order
--   lease_options: load_key, label, term_months, monthly_payment, hst, buyout, upfront, is_chosen, payments_made, started_on, notes, source_note
--   finance_projection_months: month (YYYY-MM), is_production, source_note, load_key
--   finance_projection_team: load_key, person_name, profile_id, role_label, pay_kind, hours_per_week, rate, adds_hst, runs, sort_order, source_note
--   finance_projection_costs: load_key, label, amount, period, runs, sort_order, source_note
--   finance_todos: load_key, item, amount, status, action, source_note
--   outside_costume_flags: source_row_hash or load_key, plus vendor_type, flag_duplicate, flag_canceled, flag_owing, source_note
-- ---------------------------------------------------------------------------

create or replace function public.upsert_finance_rows(target text, rows jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  claims text := nullif(current_setting('request.jwt.claims', true), '');
  caller_role text := '';
  upserted integer := 0;
  item jsonb;
begin
  if claims is not null then
    caller_role := coalesce(claims::jsonb ->> 'role', '');
  end if;
  if caller_role is distinct from 'service_role' and not private.is_owner() then
    raise exception 'Only an owner can load finance rows'
      using errcode = '42501';
  end if;
  if jsonb_typeof(rows) is distinct from 'array' then
    raise exception 'The load needs a JSON array of rows'
      using errcode = '23514';
  end if;
  if exists (
    select 1
    from jsonb_array_elements(rows) entry
    where coalesce(entry ->> 'payment_method', '') ~ '[0-9]{8,}'
      or coalesce(entry ->> 'payment_as_entered', '') ~ '[0-9]{8,}'
  ) then
    raise exception 'Do not store a full card number'
      using errcode = '23514';
  end if;
  if target is distinct from 'finance_unit_settings'
    and target is distinct from 'finance_projection_months'
    and target is distinct from 'outside_costume_flags'
    and exists (
      select 1
      from jsonb_array_elements(rows) entry
      where nullif(btrim(entry ->> 'load_key'), '') is null
    )
  then
    raise exception 'Each row needs a load_key'
      using errcode = '23514';
  end if;

  if target = 'finance_unit_settings' then
    select entry into item
    from jsonb_array_elements(rows) entry
    limit 1;
    if item is null then
      raise exception 'The unit settings need one row'
        using errcode = '23514';
    end if;
    insert into public.finance_unit_settings (id, units, cost_per_unit, source_note)
    values (
      true,
      nullif(item ->> 'units', '')::numeric,
      nullif(item ->> 'cost_per_unit', '')::numeric,
      coalesce(item ->> 'source_note', '')
    )
    on conflict (id) do update
    set
      units = excluded.units,
      cost_per_unit = excluded.cost_per_unit,
      source_note = excluded.source_note,
      updated_at = now();
    get diagnostics upserted = row_count;
  elsif target = 'finance_projection_months' then
    insert into public.finance_projection_months (
      month_start, is_production, source_note, load_key
    )
    select
      date_trunc('month', (entry ->> 'month')::date)::date,
      coalesce((entry ->> 'is_production')::boolean, false),
      coalesce(entry ->> 'source_note', ''),
      nullif(btrim(entry ->> 'load_key'), '')
    from jsonb_array_elements(rows) entry
    on conflict (month_start) do update
    set
      is_production = excluded.is_production,
      source_note = excluded.source_note,
      load_key = coalesce(excluded.load_key, public.finance_projection_months.load_key),
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'outside_costume_flags' then
    update public.outside_costume_purchases purchase
    set
      vendor_type = coalesce(nullif(btrim(entry ->> 'vendor_type'), ''), purchase.vendor_type),
      flag_duplicate = coalesce((entry ->> 'flag_duplicate')::boolean, purchase.flag_duplicate),
      flag_canceled = coalesce((entry ->> 'flag_canceled')::boolean, purchase.flag_canceled),
      flag_owing = coalesce((entry ->> 'flag_owing')::boolean, purchase.flag_owing),
      source_note = coalesce(entry ->> 'source_note', purchase.source_note)
    from jsonb_array_elements(rows) entry
    where (
      nullif(btrim(entry ->> 'source_row_hash'), '') is not null
      and purchase.source_row_hash = entry ->> 'source_row_hash'
    ) or (
      nullif(btrim(entry ->> 'load_key'), '') is not null
      and purchase.load_key = entry ->> 'load_key'
    );
    get diagnostics upserted = row_count;
    if upserted is distinct from jsonb_array_length(rows) then
      raise exception 'Unknown outside costume row'
        using errcode = '23503';
    end if;
  elsif target = 'finance_spend_lines' then
    insert into public.finance_spend_lines (
      load_key, section, label, amount, detail_href, sort_order, source_note
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      entry ->> 'section',
      btrim(entry ->> 'label'),
      (entry ->> 'amount')::numeric,
      nullif(btrim(entry ->> 'detail_href'), ''),
      coalesce(nullif(entry ->> 'sort_order', '')::integer, 0),
      coalesce(entry ->> 'source_note', '')
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      section = excluded.section,
      label = excluded.label,
      amount = excluded.amount,
      detail_href = excluded.detail_href,
      sort_order = excluded.sort_order,
      source_note = excluded.source_note,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'finance_committed_items' then
    insert into public.finance_committed_items (
      load_key, label, amount, detail_href, counts_as_startup, sort_order, source_note
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      btrim(entry ->> 'label'),
      (entry ->> 'amount')::numeric,
      nullif(btrim(entry ->> 'detail_href'), ''),
      coalesce((entry ->> 'counts_as_startup')::boolean, false),
      coalesce(nullif(entry ->> 'sort_order', '')::integer, 0),
      coalesce(entry ->> 'source_note', '')
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      label = excluded.label,
      amount = excluded.amount,
      detail_href = excluded.detail_href,
      counts_as_startup = excluded.counts_as_startup,
      sort_order = excluded.sort_order,
      source_note = excluded.source_note,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'finance_funding_lines' then
    insert into public.finance_funding_lines (
      load_key, paid_from, label, amount, sort_order, source_note
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      entry ->> 'paid_from',
      btrim(entry ->> 'label'),
      (entry ->> 'amount')::numeric,
      coalesce(nullif(entry ->> 'sort_order', '')::integer, 0),
      coalesce(entry ->> 'source_note', '')
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      paid_from = excluded.paid_from,
      label = excluded.label,
      amount = excluded.amount,
      sort_order = excluded.sort_order,
      source_note = excluded.source_note,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'finance_cost_lines' then
    insert into public.finance_cost_lines (
      load_key, section, label, amount, hst, adjustment, sort_order, source_note
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      entry ->> 'section',
      btrim(entry ->> 'label'),
      (entry ->> 'amount')::numeric,
      coalesce(nullif(entry ->> 'hst', '')::numeric, 0),
      coalesce(nullif(btrim(entry ->> 'adjustment'), ''), 'none'),
      coalesce(nullif(entry ->> 'sort_order', '')::integer, 0),
      coalesce(entry ->> 'source_note', '')
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      section = excluded.section,
      label = excluded.label,
      amount = excluded.amount,
      hst = excluded.hst,
      adjustment = excluded.adjustment,
      sort_order = excluded.sort_order,
      source_note = excluded.source_note,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'expense_log' then
    insert into public.expense_log (
      load_key, occurred_on, amount, payment_as_entered, paid_from, vendor,
      description, category, flag_notes, source_note, card_transaction_id
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      nullif(entry ->> 'occurred_on', '')::date,
      (entry ->> 'amount')::numeric,
      nullif(btrim(entry ->> 'payment_as_entered'), ''),
      entry ->> 'paid_from',
      nullif(btrim(entry ->> 'vendor'), ''),
      btrim(entry ->> 'description'),
      entry ->> 'category',
      nullif(btrim(entry ->> 'flag_notes'), ''),
      coalesce(entry ->> 'source_note', ''),
      nullif(entry ->> 'card_transaction_id', '')::bigint
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      occurred_on = excluded.occurred_on,
      amount = excluded.amount,
      payment_as_entered = excluded.payment_as_entered,
      paid_from = excluded.paid_from,
      vendor = excluded.vendor,
      description = excluded.description,
      category = excluded.category,
      flag_notes = excluded.flag_notes,
      source_note = excluded.source_note,
      card_transaction_id = excluded.card_transaction_id,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'contractor_invoices' then
    insert into public.contractor_invoices (
      load_key, profile_id, paid_on, invoice_number, period_start, period_end,
      hours, rate, hst, expected, amount_paid, payment_method, notes, source_note
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      (entry ->> 'profile_id')::uuid,
      nullif(entry ->> 'paid_on', '')::date,
      nullif(btrim(entry ->> 'invoice_number'), ''),
      nullif(entry ->> 'period_start', '')::date,
      nullif(entry ->> 'period_end', '')::date,
      nullif(entry ->> 'hours', '')::numeric,
      nullif(entry ->> 'rate', '')::numeric,
      coalesce(nullif(entry ->> 'hst', '')::numeric, 0),
      nullif(entry ->> 'expected', '')::numeric,
      nullif(entry ->> 'amount_paid', '')::numeric,
      nullif(btrim(entry ->> 'payment_method'), ''),
      nullif(btrim(entry ->> 'notes'), ''),
      coalesce(entry ->> 'source_note', '')
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      profile_id = excluded.profile_id,
      paid_on = excluded.paid_on,
      invoice_number = excluded.invoice_number,
      period_start = excluded.period_start,
      period_end = excluded.period_end,
      hours = excluded.hours,
      rate = excluded.rate,
      hst = excluded.hst,
      expected = excluded.expected,
      amount_paid = excluded.amount_paid,
      payment_method = excluded.payment_method,
      notes = excluded.notes,
      source_note = excluded.source_note,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'contractor_contract_phases' then
    insert into public.contractor_contract_phases (
      load_key, contract_id, label, sort_order, amount_before_hst, hst, notes, source_note
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      (entry ->> 'contract_id')::bigint,
      btrim(entry ->> 'label'),
      coalesce(nullif(entry ->> 'sort_order', '')::integer, 0),
      (entry ->> 'amount_before_hst')::numeric,
      coalesce(nullif(entry ->> 'hst', '')::numeric, 0),
      nullif(btrim(entry ->> 'notes'), ''),
      coalesce(entry ->> 'source_note', '')
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      contract_id = excluded.contract_id,
      label = excluded.label,
      sort_order = excluded.sort_order,
      amount_before_hst = excluded.amount_before_hst,
      hst = excluded.hst,
      notes = excluded.notes,
      source_note = excluded.source_note,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'contractor_contracts' then
    insert into public.contractor_contracts (
      load_key, contractor_id, total_amount_cad, hst_amount_cad, start_date,
      end_date, payout, notes, source_note
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      (entry ->> 'contractor_id')::uuid,
      (entry ->> 'total_amount_cad')::numeric,
      coalesce(nullif(entry ->> 'hst_amount_cad', '')::numeric, 0),
      (entry ->> 'start_date')::date,
      (entry ->> 'end_date')::date,
      coalesce(nullif(btrim(entry ->> 'payout'), ''), 'spread'),
      nullif(btrim(entry ->> 'notes'), ''),
      coalesce(entry ->> 'source_note', '')
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      contractor_id = excluded.contractor_id,
      total_amount_cad = excluded.total_amount_cad,
      hst_amount_cad = excluded.hst_amount_cad,
      start_date = excluded.start_date,
      end_date = excluded.end_date,
      payout = excluded.payout,
      notes = excluded.notes,
      source_note = excluded.source_note,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'contractor_payments' then
    insert into public.contractor_payments (
      load_key, contract_id, paid_on, amount_cad, hst_cad, notes, source_note,
      payment_method, description
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      (entry ->> 'contract_id')::bigint,
      nullif(entry ->> 'paid_on', '')::date,
      (entry ->> 'amount_cad')::numeric,
      coalesce(nullif(entry ->> 'hst_cad', '')::numeric, 0),
      nullif(btrim(entry ->> 'notes'), ''),
      coalesce(entry ->> 'source_note', ''),
      nullif(btrim(entry ->> 'payment_method'), ''),
      nullif(btrim(entry ->> 'description'), '')
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      contract_id = excluded.contract_id,
      paid_on = excluded.paid_on,
      amount_cad = excluded.amount_cad,
      hst_cad = excluded.hst_cad,
      notes = excluded.notes,
      source_note = excluded.source_note,
      payment_method = excluded.payment_method,
      description = excluded.description,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'startup_costs' then
    insert into public.startup_costs (
      load_key, occurred_on, description, vendor, category_id, amount_cad, hst_cad,
      notes, source, source_note, startup_share_percent, created_by
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      nullif(entry ->> 'occurred_on', '')::date,
      btrim(entry ->> 'description'),
      nullif(btrim(entry ->> 'vendor'), ''),
      (entry ->> 'category_id')::bigint,
      (entry ->> 'amount_cad')::numeric,
      coalesce(nullif(entry ->> 'hst_cad', '')::numeric, 0),
      nullif(btrim(entry ->> 'notes'), ''),
      coalesce(nullif(btrim(entry ->> 'source'), ''), 'manual'),
      coalesce(entry ->> 'source_note', ''),
      coalesce(nullif(entry ->> 'startup_share_percent', '')::numeric, 100),
      nullif(entry ->> 'created_by', '')::uuid
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      occurred_on = excluded.occurred_on,
      description = excluded.description,
      vendor = excluded.vendor,
      category_id = excluded.category_id,
      amount_cad = excluded.amount_cad,
      hst_cad = excluded.hst_cad,
      notes = excluded.notes,
      source = excluded.source,
      source_note = excluded.source_note,
      startup_share_percent = excluded.startup_share_percent,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'equipment_quote_items' then
    insert into public.equipment_quote_items (
      load_key, label, new_price, preowned_price, notes, source_note, sort_order
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      btrim(entry ->> 'label'),
      nullif(entry ->> 'new_price', '')::numeric,
      nullif(entry ->> 'preowned_price', '')::numeric,
      nullif(btrim(entry ->> 'notes'), ''),
      coalesce(entry ->> 'source_note', ''),
      coalesce(nullif(entry ->> 'sort_order', '')::integer, 0)
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      label = excluded.label,
      new_price = excluded.new_price,
      preowned_price = excluded.preowned_price,
      notes = excluded.notes,
      source_note = excluded.source_note,
      sort_order = excluded.sort_order,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'lease_options' then
    insert into public.lease_options (
      load_key, label, term_months, monthly_payment, hst, buyout, upfront,
      is_chosen, payments_made, started_on, notes, source_note
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      btrim(entry ->> 'label'),
      (entry ->> 'term_months')::integer,
      (entry ->> 'monthly_payment')::numeric,
      coalesce(nullif(entry ->> 'hst', '')::numeric, 0),
      nullif(entry ->> 'buyout', '')::numeric,
      coalesce(nullif(entry ->> 'upfront', '')::numeric, 0),
      coalesce((entry ->> 'is_chosen')::boolean, false),
      coalesce(nullif(entry ->> 'payments_made', '')::integer, 0),
      nullif(entry ->> 'started_on', '')::date,
      nullif(btrim(entry ->> 'notes'), ''),
      coalesce(entry ->> 'source_note', '')
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      label = excluded.label,
      term_months = excluded.term_months,
      monthly_payment = excluded.monthly_payment,
      hst = excluded.hst,
      buyout = excluded.buyout,
      upfront = excluded.upfront,
      is_chosen = excluded.is_chosen,
      payments_made = excluded.payments_made,
      started_on = excluded.started_on,
      notes = excluded.notes,
      source_note = excluded.source_note,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'finance_projection_team' then
    insert into public.finance_projection_team (
      load_key, person_name, profile_id, role_label, pay_kind, hours_per_week,
      rate, adds_hst, runs, sort_order, source_note
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      btrim(entry ->> 'person_name'),
      nullif(entry ->> 'profile_id', '')::uuid,
      nullif(btrim(entry ->> 'role_label'), ''),
      entry ->> 'pay_kind',
      nullif(entry ->> 'hours_per_week', '')::numeric,
      (entry ->> 'rate')::numeric,
      coalesce((entry ->> 'adds_hst')::boolean, false),
      coalesce(nullif(btrim(entry ->> 'runs'), ''), 'every_month'),
      coalesce(nullif(entry ->> 'sort_order', '')::integer, 0),
      coalesce(entry ->> 'source_note', '')
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      person_name = excluded.person_name,
      profile_id = excluded.profile_id,
      role_label = excluded.role_label,
      pay_kind = excluded.pay_kind,
      hours_per_week = excluded.hours_per_week,
      rate = excluded.rate,
      adds_hst = excluded.adds_hst,
      runs = excluded.runs,
      sort_order = excluded.sort_order,
      source_note = excluded.source_note,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'finance_projection_costs' then
    insert into public.finance_projection_costs (
      load_key, label, amount, period, runs, sort_order, source_note
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      btrim(entry ->> 'label'),
      (entry ->> 'amount')::numeric,
      entry ->> 'period',
      coalesce(nullif(btrim(entry ->> 'runs'), ''), 'every_month'),
      coalesce(nullif(entry ->> 'sort_order', '')::integer, 0),
      coalesce(entry ->> 'source_note', '')
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      label = excluded.label,
      amount = excluded.amount,
      period = excluded.period,
      runs = excluded.runs,
      sort_order = excluded.sort_order,
      source_note = excluded.source_note,
      archived_at = null;
    get diagnostics upserted = row_count;
  elsif target = 'finance_todos' then
    insert into public.finance_todos (
      load_key, item, amount, status, action, source_note
    )
    select
      nullif(btrim(entry ->> 'load_key'), ''),
      btrim(entry ->> 'item'),
      nullif(entry ->> 'amount', '')::numeric,
      coalesce(nullif(btrim(entry ->> 'status'), ''), 'open'),
      nullif(btrim(entry ->> 'action'), ''),
      coalesce(entry ->> 'source_note', '')
    from jsonb_array_elements(rows) entry
    on conflict (load_key) do update
    set
      item = excluded.item,
      amount = excluded.amount,
      status = excluded.status,
      action = excluded.action,
      source_note = excluded.source_note,
      archived_at = null;
    get diagnostics upserted = row_count;
  else
    raise exception 'Unknown finance table'
      using errcode = '22023';
  end if;

  return jsonb_build_object('target', target, 'upserted', upserted);
end;
$$;

comment on function public.upsert_finance_rows(text, jsonb) is
  'Upserts workbook rows by load_key for owners and the service role. Does not delete or archive rows that are absent. outside_costume_flags updates flags on existing purchases.';

revoke all on function public.upsert_finance_rows(text, jsonb) from public, anon;
grant execute on function public.upsert_finance_rows(text, jsonb) to authenticated, service_role;
