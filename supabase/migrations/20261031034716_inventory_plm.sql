-- Inventory, orders, and the development records from Elaine's tracker.
-- On-hand, reserved, and available are calculated from stock_transactions.
-- Costs, supplier prices, supplier contact details, and client emails or
-- budgets live in separate tables because row security cannot hide columns.

-- ---------------------------------------------------------------------------
-- Settings
-- ---------------------------------------------------------------------------

create table public.inventory_settings (
  id boolean primary key default true,
  low_stock_threshold_m numeric(12, 4) not null default 2,
  updated_at timestamptz not null default now(),
  constraint inventory_settings_singleton check (id),
  constraint inventory_settings_threshold_check check (low_stock_threshold_m >= 0)
);

comment on table public.inventory_settings is
  'Shop-wide inventory settings. The default 2 m threshold comes from the tracker README.';

insert into public.inventory_settings (id, low_stock_threshold_m)
values (true, 2);

create trigger inventory_settings_set_updated_at
  before update on public.inventory_settings
  for each row
  execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Suppliers
-- ---------------------------------------------------------------------------

create table public.suppliers (
  id bigint generated always as identity primary key,
  supplier_code text not null unique,
  name text not null,
  website text,
  lead_time_days integer,
  lead_time_raw text,
  minimum_order text,
  volume_discount text,
  notes text,
  needs_data text,
  source_tab text,
  source_row integer,
  source_label text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint suppliers_code_check check (char_length(btrim(supplier_code)) > 0),
  constraint suppliers_lead_time_check check (lead_time_days is null or lead_time_days >= 0)
);

comment on table public.suppliers is
  'Vendor directory without phone, email, or account numbers.';

create trigger suppliers_set_updated_at
  before update on public.suppliers
  for each row
  execute function private.set_updated_at();

create table public.supplier_contacts (
  supplier_id bigint primary key references public.suppliers (id) on delete cascade,
  contact_name text,
  email text,
  phone text,
  address text,
  account_number text,
  updated_at timestamptz not null default now()
);

comment on table public.supplier_contacts is
  'Supplier phone, email, address, and account number. Owners and production managers only.';

create trigger supplier_contacts_set_updated_at
  before update on public.supplier_contacts
  for each row
  execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Materials
-- ---------------------------------------------------------------------------

create table public.materials (
  id bigint generated always as identity primary key,
  material_code text not null unique,
  fabric_number text,
  colour_number text,
  colour_name text,
  fabric_name text,
  supplier_fabric_code text,
  supplier_id bigint references public.suppliers (id),
  supplier_as_written text,
  content text,
  fabric_type text,
  width_cm numeric(12, 4),
  width_raw text,
  cuttable_width_cm numeric(12, 4),
  cuttable_width_raw text,
  gsm numeric(12, 4),
  gsm_raw text,
  eco_cert text,
  care text,
  roll_status text,
  bin_location text,
  swatch_link text,
  stock_count_recorded text,
  reorder_point_m numeric(12, 4),
  reorder_point_raw text,
  needs_review boolean not null default false,
  needs_review_reason text,
  registry_stock_raw text,
  registry_ordered_raw text,
  registry_supplier_order text,
  registry_order_date_raw text,
  registry_date_received_raw text,
  registry_received_raw text,
  registry_allocated_raw text,
  registry_order_history text,
  registry_notes text,
  source_stock_flag text,
  source_tab text,
  source_row integer,
  source_label text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint materials_code_check check (char_length(btrim(material_code)) > 0),
  constraint materials_width_check check (width_cm is null or width_cm >= 0),
  constraint materials_gsm_check check (gsm is null or gsm >= 0),
  constraint materials_reorder_check check (reorder_point_m is null or reorder_point_m >= 0)
);

comment on table public.materials is
  'Fabric and trim registry. Unit is metres. On-hand is not stored here.';

comment on column public.materials.needs_review is
  'True when the source row still has an open question or a value that was not a clean number.';

create index materials_supplier_id_idx on public.materials (supplier_id);
create index materials_fabric_type_idx on public.materials (fabric_type);
create index materials_needs_review_idx on public.materials (needs_review) where needs_review;

create trigger materials_set_updated_at
  before update on public.materials
  for each row
  execute function private.set_updated_at();

create table public.material_costs (
  material_id bigint primary key references public.materials (id) on delete cascade,
  list_price_per_m numeric(12, 4),
  list_price_raw text,
  discount_entered numeric(12, 6),
  discount_raw text,
  net_price_per_m numeric(12, 4),
  net_price_raw text,
  source_tab text,
  source_row integer,
  updated_at timestamptz not null default now(),
  constraint material_costs_list_check check (list_price_per_m is null or list_price_per_m >= 0),
  constraint material_costs_net_check check (net_price_per_m is null or net_price_per_m >= 0)
);

comment on table public.material_costs is
  'List price, discount as exported, and net price per metre. Not visible to employees.';

comment on column public.material_costs.discount_entered is
  'The number from the sheet, unchanged. A value of 0.1 was not converted into 10 percent.';

create trigger material_costs_set_updated_at
  before update on public.material_costs
  for each row
  execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Orders and styles
-- ---------------------------------------------------------------------------

create table public.costume_orders (
  id bigint generated always as identity primary key,
  order_number text not null unique,
  production_song text,
  status text,
  status_raw text,
  order_date date,
  order_date_raw text,
  fitting_target_raw text,
  accessory text,
  female_total integer,
  female_total_raw text,
  male_total integer,
  male_total_raw text,
  notes text,
  source_tab text,
  source_row integer,
  source_label text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint costume_orders_number_check check (char_length(btrim(order_number)) > 0),
  constraint costume_orders_status_check check (
    status is null or status in ('cancelled')
  )
);

comment on table public.costume_orders is
  'Costume orders. Client emails and budgets are in order_private. Status cancelled keeps the original wording in status_raw.';

create index costume_orders_status_idx on public.costume_orders (status);

create trigger costume_orders_set_updated_at
  before update on public.costume_orders
  for each row
  execute function private.set_updated_at();

create table public.order_private (
  order_id bigint primary key references public.costume_orders (id) on delete cascade,
  contacts text,
  contact_emails text,
  budget_per_costume numeric(12, 2),
  budget_per_costume_raw text,
  accessory_cost_each numeric(12, 2),
  accessory_cost_each_raw text,
  accessory_qty integer,
  accessory_qty_raw text,
  restricted_notes text,
  updated_at timestamptz not null default now()
);

comment on table public.order_private is
  'Client names, emails, budgets, and any order note that itself contains an email address. Owners and production managers only.';

create trigger order_private_set_updated_at
  before update on public.order_private
  for each row
  execute function private.set_updated_at();

create table public.styles (
  id bigint generated always as identity primary key,
  style_key text not null unique,
  style_code text,
  order_id bigint references public.costume_orders (id),
  order_number_raw text,
  production_song text,
  garment_description text,
  category text,
  group_name text,
  version_label text,
  child_or_adult text,
  character_note text,
  fabric_code_raw text,
  material_id bigint references public.materials (id),
  fabric_in_materials text,
  size_qty_raw text,
  flags text,
  source_tab text,
  source_row integer,
  source_label text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint styles_key_check check (char_length(btrim(style_key)) > 0)
);

comment on table public.styles is
  'One row per style key. Style ID is not unique in the source, so style_key is the key.';

create index styles_order_id_idx on public.styles (order_id);
create index styles_material_id_idx on public.styles (material_id);
create index styles_style_code_idx on public.styles (style_code);

create trigger styles_set_updated_at
  before update on public.styles
  for each row
  execute function private.set_updated_at();

create table public.style_stages (
  id bigint generated always as identity primary key,
  style_id bigint not null references public.styles (id) on delete cascade,
  stage_name text not null,
  stage_order integer not null,
  cell_text text,
  interpreted_on date,
  interpreted_yes boolean,
  check_text text,
  check_yes boolean,
  source_tab text,
  source_row integer,
  unique (style_id, stage_name),
  constraint style_stages_order_check check (stage_order between 1 and 11)
);

comment on table public.style_stages is
  'The 11 development stages. cell_text is the original cell. A date or yes/no is filled only when the cell is exactly that.';

create index style_stages_style_id_idx on public.style_stages (style_id);

create table public.order_sizes (
  id bigint generated always as identity primary key,
  style_id bigint not null references public.styles (id) on delete cascade,
  order_id bigint references public.costume_orders (id),
  size_code text not null,
  qty integer,
  qty_raw text,
  source_tab text,
  source_row integer,
  unique (style_id, size_code),
  constraint order_sizes_qty_check check (qty is null or qty >= 0)
);

comment on table public.order_sizes is
  'Size quantities. Blank cells are not stored. Header, total, and spacer rows are not stored.';

create index order_sizes_order_id_idx on public.order_sizes (order_id);

-- ---------------------------------------------------------------------------
-- Stock ledger
-- ---------------------------------------------------------------------------

create table public.stock_transactions (
  id bigint generated always as identity primary key,
  txn_code text not null unique,
  occurred_on date,
  occurred_on_raw text,
  txn_type text not null,
  material_id bigint references public.materials (id),
  material_code_raw text,
  qty_m numeric(12, 4),
  qty_raw text,
  order_id bigint references public.costume_orders (id),
  order_number_raw text,
  po_ref text,
  description text,
  entered_by text,
  created_by uuid references public.profiles (id),
  source_tab text,
  source_row integer,
  source_label text,
  created_at timestamptz not null default now(),
  constraint stock_transactions_type_check check (
    txn_type in ('receive', 'reserve', 'use', 'adjust', 'return')
  ),
  constraint stock_transactions_qty_sign_check check (
    qty_m is null or txn_type = 'adjust' or qty_m >= 0
  )
);

comment on table public.stock_transactions is
  'Append-style stock ledger in metres. Receive and return add to on-hand, use subtracts, adjust is signed, reserve adds to reserved.';

create index stock_transactions_material_id_idx on public.stock_transactions (material_id);
create index stock_transactions_order_id_idx on public.stock_transactions (order_id);
create index stock_transactions_created_by_idx on public.stock_transactions (created_by);

create view public.material_stock
with (security_invoker = true) as
select
  m.id as material_id,
  m.material_code,
  case
    when count(t.id) filter (
      where t.txn_type in ('receive', 'return', 'use', 'adjust')
        and t.qty_m is not null
    ) = 0 then null
    else
      coalesce(sum(t.qty_m) filter (
        where t.txn_type in ('receive', 'return') and t.qty_m is not null
      ), 0)
      - coalesce(sum(t.qty_m) filter (
        where t.txn_type = 'use' and t.qty_m is not null
      ), 0)
      + coalesce(sum(t.qty_m) filter (
        where t.txn_type = 'adjust' and t.qty_m is not null
      ), 0)
  end as on_hand_m,
  case
    when count(t.id) filter (
      where t.txn_type = 'reserve' and t.qty_m is not null
    ) = 0 then null
    else coalesce(sum(t.qty_m) filter (
      where t.txn_type = 'reserve' and t.qty_m is not null
    ), 0)
  end as reserved_m
from public.materials m
left join public.stock_transactions t on t.material_id = m.id
group by m.id, m.material_code;

comment on view public.material_stock is
  'On-hand and reserved metres, calculated from the ledger. Null means there is no numeric ledger row of that kind.';

create view public.material_availability
with (security_invoker = true) as
select
  s.material_id,
  s.material_code,
  s.on_hand_m,
  s.reserved_m,
  case
    when s.on_hand_m is null then null
    else s.on_hand_m - coalesce(s.reserved_m, 0)
  end as available_m,
  case
    when s.on_hand_m is null then false
    else (s.on_hand_m - coalesce(s.reserved_m, 0))
      < coalesce(m.reorder_point_m, settings.low_stock_threshold_m)
  end as is_low_stock
from public.material_stock s
join public.materials m on m.id = s.material_id
cross join public.inventory_settings settings;

comment on view public.material_availability is
  'Available metres and the low-stock flag. A material with no on-hand ledger is not marked low.';

-- ---------------------------------------------------------------------------
-- Purchases and BOM
-- ---------------------------------------------------------------------------

create table public.purchase_orders (
  id bigint generated always as identity primary key,
  po_ref text not null unique,
  supplier_id bigint references public.suppliers (id),
  supplier_as_written text,
  po_date date,
  po_date_raw text,
  ship_eta_raw text,
  source_tab text,
  source_row integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.purchase_orders is
  'One header per supplier order number or written PO reference.';

create index purchase_orders_supplier_id_idx on public.purchase_orders (supplier_id);

create trigger purchase_orders_set_updated_at
  before update on public.purchase_orders
  for each row
  execute function private.set_updated_at();

create table public.purchase_order_lines (
  id bigint generated always as identity primary key,
  line_code text not null unique,
  purchase_order_id bigint not null references public.purchase_orders (id) on delete cascade,
  material_id bigint references public.materials (id),
  material_code_raw text,
  fabric_as_written text,
  supplier_colour text,
  fabric_name_as_written text,
  supplier_fabric_code text,
  qty_ordered_m numeric(12, 4),
  qty_ordered_raw text,
  studio_orders_raw text,
  assigned_order_raw text,
  line_note text,
  status_raw text,
  received_m numeric(12, 4),
  received_raw text,
  received_on date,
  received_on_raw text,
  id_check text,
  needs_review boolean not null default false,
  needs_review_reason text,
  source_tab text,
  source_row integer,
  source_label text,
  created_at timestamptz not null default now(),
  constraint purchase_order_lines_qty_check check (qty_ordered_m is null or qty_ordered_m >= 0),
  constraint purchase_order_lines_received_check check (received_m is null or received_m >= 0)
);

comment on table public.purchase_order_lines is
  'PO lines. A missing or unknown material id is left unlinked and flagged.';

create index purchase_order_lines_po_id_idx on public.purchase_order_lines (purchase_order_id);
create index purchase_order_lines_material_id_idx on public.purchase_order_lines (material_id);

create table public.purchase_line_prices (
  line_id bigint primary key references public.purchase_order_lines (id) on delete cascade,
  price_per_m numeric(12, 4),
  price_raw text,
  discount_entered numeric(12, 6),
  discount_raw text,
  line_total numeric(12, 2),
  line_total_raw text,
  updated_at timestamptz not null default now(),
  constraint purchase_line_prices_price_check check (price_per_m is null or price_per_m >= 0)
);

comment on table public.purchase_line_prices is
  'Supplier price and line total for a purchase line.';

create trigger purchase_line_prices_set_updated_at
  before update on public.purchase_line_prices
  for each row
  execute function private.set_updated_at();

create table public.bom_lines (
  id bigint generated always as identity primary key,
  line_code text not null unique,
  style_id bigint references public.styles (id),
  style_key_raw text,
  order_id bigint references public.costume_orders (id),
  order_number_raw text,
  garment text,
  version_label text,
  component text,
  placement text,
  material_id bigint references public.materials (id),
  fabric_as_written text,
  fabric_name text,
  colour text,
  consumption_per_unit_m numeric(12, 4),
  consumption_raw text,
  consumption_basis text,
  flag text,
  needs_review boolean not null default false,
  needs_review_reason text,
  source_tab text,
  source_row integer,
  source_label text,
  created_at timestamptz not null default now(),
  constraint bom_lines_consumption_check check (
    consumption_per_unit_m is null or consumption_per_unit_m >= 0
  )
);

comment on table public.bom_lines is
  'Fabric use on a style. Contrast lines with the F002-125 / F002-25 conflict stay unlinked.';

create index bom_lines_style_id_idx on public.bom_lines (style_id);
create index bom_lines_order_id_idx on public.bom_lines (order_id);
create index bom_lines_material_id_idx on public.bom_lines (material_id);

create table public.bom_costs (
  bom_line_id bigint primary key references public.bom_lines (id) on delete cascade,
  price_per_m_source text,
  price_per_m_used numeric(12, 4),
  price_per_m_used_raw text,
  cost_per_unit numeric(12, 4),
  cost_per_unit_raw text,
  total_cost numeric(12, 2),
  total_cost_raw text,
  updated_at timestamptz not null default now()
);

comment on table public.bom_costs is
  'BOM price and cost figures. Not visible to employees.';

create trigger bom_costs_set_updated_at
  before update on public.bom_costs
  for each row
  execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Fittings and review
-- ---------------------------------------------------------------------------

create table public.fittings (
  id bigint generated always as identity primary key,
  fitting_code text not null unique,
  order_id bigint references public.costume_orders (id),
  order_number_raw text,
  style_id bigint references public.styles (id),
  style_key_raw text,
  sample_label text,
  garment text,
  version_label text,
  size_label text,
  pattern_status text,
  sample_complete text,
  fit_test_raw text,
  corrections_required text,
  corrections_complete text,
  approval_status text,
  approved_by text,
  approval_raw text,
  comments text,
  source_tab text,
  source_row integer,
  source_label text,
  created_at timestamptz not null default now()
);

comment on table public.fittings is
  'Sample and prototype fittings. Blank template rows are not loaded.';

create index fittings_order_id_idx on public.fittings (order_id);
create index fittings_style_id_idx on public.fittings (style_id);

create table public.fitting_checks (
  id bigint generated always as identity primary key,
  order_id bigint references public.costume_orders (id),
  order_number_raw text,
  check_name text not null,
  required_text text,
  completed_text text,
  check_date_raw text,
  approved_by text,
  notes text,
  source_tab text,
  source_row integer,
  source_label text,
  unique (order_number_raw, check_name)
);

comment on table public.fitting_checks is
  'Prototype approval checklist rows from the Fittings tab. They are not sample fittings.';

create index fitting_checks_order_id_idx on public.fitting_checks (order_id);

create table public.production_gates (
  id bigint generated always as identity primary key,
  order_id bigint references public.costume_orders (id),
  order_number_raw text,
  gate_name text not null,
  target_raw text,
  completed_raw text,
  owner_name text,
  status_raw text,
  approval_raw text,
  notes text,
  source_tab text,
  source_row integer,
  source_label text,
  unique (order_number_raw, gate_name)
);

comment on table public.production_gates is
  'Production gate rows from the Fittings tab. Target dates are kept as written.';

create index production_gates_order_id_idx on public.production_gates (order_id);

create table public.review_items (
  id bigint generated always as identity primary key,
  review_code text not null unique,
  source_sheet text,
  record_label text,
  source_detail text,
  field_name text,
  original_text text,
  issue text,
  question text,
  priority text,
  status text not null default 'open',
  status_raw text,
  resolution text,
  material_id bigint references public.materials (id),
  order_id bigint references public.costume_orders (id),
  style_id bigint references public.styles (id),
  bom_line_id bigint references public.bom_lines (id),
  purchase_line_id bigint references public.purchase_order_lines (id),
  supplier_id bigint references public.suppliers (id),
  source_tab text,
  source_row integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint review_items_priority_check check (
    priority is null or priority in ('high', 'medium', 'low')
  ),
  constraint review_items_status_check check (
    status in ('open', 'resolved')
  )
);

comment on table public.review_items is
  'Questions for Elaine, from the Needs Review tab and from values this import could not structure.';

create index review_items_status_idx on public.review_items (status);
create index review_items_material_id_idx on public.review_items (material_id);
create index review_items_order_id_idx on public.review_items (order_id);
create index review_items_style_id_idx on public.review_items (style_id);

create trigger review_items_set_updated_at
  before update on public.review_items
  for each row
  execute function private.set_updated_at();

-- ---------------------------------------------------------------------------
-- Who can see costs
-- ---------------------------------------------------------------------------

create or replace function private.can_read_costs()
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  return (select private.is_owner())
    or (select private.is_production_manager())
    or (select private.has_purchasing());
end;
$$;

revoke all on function private.can_read_costs() from public, anon;
grant execute on function private.can_read_costs() to authenticated, service_role;

create or replace function private.can_edit_inventory()
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  return (select private.is_owner())
    or (select private.is_production_manager());
end;
$$;

revoke all on function private.can_edit_inventory() from public, anon;
grant execute on function private.can_edit_inventory() to authenticated, service_role;

comment on function private.can_edit_inventory() is
  'Owners and production managers. They may edit inventory, and they are the only roles who can read supplier contacts and client emails or budgets.';

-- ---------------------------------------------------------------------------
-- Audit
-- ---------------------------------------------------------------------------

create trigger inventory_settings_audit
  after insert or update or delete on public.inventory_settings
  for each row execute function private.audit_row();
create trigger suppliers_audit
  after insert or update or delete on public.suppliers
  for each row execute function private.audit_row();
create trigger supplier_contacts_audit
  after insert or update or delete on public.supplier_contacts
  for each row execute function private.audit_row();
create trigger materials_audit
  after insert or update or delete on public.materials
  for each row execute function private.audit_row();
create trigger material_costs_audit
  after insert or update or delete on public.material_costs
  for each row execute function private.audit_row();
create trigger costume_orders_audit
  after insert or update or delete on public.costume_orders
  for each row execute function private.audit_row();
create trigger order_private_audit
  after insert or update or delete on public.order_private
  for each row execute function private.audit_row();
create trigger styles_audit
  after insert or update or delete on public.styles
  for each row execute function private.audit_row();
create trigger style_stages_audit
  after insert or update or delete on public.style_stages
  for each row execute function private.audit_row();
create trigger order_sizes_audit
  after insert or update or delete on public.order_sizes
  for each row execute function private.audit_row();
create trigger stock_transactions_audit
  after insert or update or delete on public.stock_transactions
  for each row execute function private.audit_row();
create trigger purchase_orders_audit
  after insert or update or delete on public.purchase_orders
  for each row execute function private.audit_row();
create trigger purchase_order_lines_audit
  after insert or update or delete on public.purchase_order_lines
  for each row execute function private.audit_row();
create trigger purchase_line_prices_audit
  after insert or update or delete on public.purchase_line_prices
  for each row execute function private.audit_row();
create trigger bom_lines_audit
  after insert or update or delete on public.bom_lines
  for each row execute function private.audit_row();
create trigger bom_costs_audit
  after insert or update or delete on public.bom_costs
  for each row execute function private.audit_row();
create trigger fittings_audit
  after insert or update or delete on public.fittings
  for each row execute function private.audit_row();
create trigger fitting_checks_audit
  after insert or update or delete on public.fitting_checks
  for each row execute function private.audit_row();
create trigger production_gates_audit
  after insert or update or delete on public.production_gates
  for each row execute function private.audit_row();
create trigger review_items_audit
  after insert or update or delete on public.review_items
  for each row execute function private.audit_row();

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

revoke all on table public.inventory_settings from public, anon, authenticated;
revoke all on table public.suppliers from public, anon, authenticated;
revoke all on table public.supplier_contacts from public, anon, authenticated;
revoke all on table public.materials from public, anon, authenticated;
revoke all on table public.material_costs from public, anon, authenticated;
revoke all on table public.costume_orders from public, anon, authenticated;
revoke all on table public.order_private from public, anon, authenticated;
revoke all on table public.styles from public, anon, authenticated;
revoke all on table public.style_stages from public, anon, authenticated;
revoke all on table public.order_sizes from public, anon, authenticated;
revoke all on table public.stock_transactions from public, anon, authenticated;
revoke all on table public.purchase_orders from public, anon, authenticated;
revoke all on table public.purchase_order_lines from public, anon, authenticated;
revoke all on table public.purchase_line_prices from public, anon, authenticated;
revoke all on table public.bom_lines from public, anon, authenticated;
revoke all on table public.bom_costs from public, anon, authenticated;
revoke all on table public.fittings from public, anon, authenticated;
revoke all on table public.fitting_checks from public, anon, authenticated;
revoke all on table public.production_gates from public, anon, authenticated;
revoke all on table public.review_items from public, anon, authenticated;

grant select on table public.inventory_settings to authenticated;
grant select, insert, update on table public.suppliers to authenticated;
grant select, insert, update on table public.supplier_contacts to authenticated;
grant select, insert, update on table public.materials to authenticated;
grant select, insert, update on table public.material_costs to authenticated;
grant select, insert, update on table public.costume_orders to authenticated;
grant select, insert, update on table public.order_private to authenticated;
grant select, insert, update on table public.styles to authenticated;
grant select, insert, update on table public.style_stages to authenticated;
grant select, insert, update on table public.order_sizes to authenticated;
grant select, insert on table public.stock_transactions to authenticated;
grant select, insert, update on table public.purchase_orders to authenticated;
grant select, insert, update on table public.purchase_order_lines to authenticated;
grant select, insert, update on table public.purchase_line_prices to authenticated;
grant select, insert, update on table public.bom_lines to authenticated;
grant select, insert, update on table public.bom_costs to authenticated;
grant select, insert, update on table public.fittings to authenticated;
grant select, insert, update on table public.fitting_checks to authenticated;
grant select, insert, update on table public.production_gates to authenticated;
grant select, insert, update on table public.review_items to authenticated;

grant select on public.material_stock to authenticated;
grant select on public.material_availability to authenticated;
revoke all on public.material_stock from anon;
revoke all on public.material_availability from anon;

grant select, insert, update, delete on all tables in schema public to service_role;
grant usage, select on all sequences in schema public to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table public.inventory_settings enable row level security;
alter table public.suppliers enable row level security;
alter table public.supplier_contacts enable row level security;
alter table public.materials enable row level security;
alter table public.material_costs enable row level security;
alter table public.costume_orders enable row level security;
alter table public.order_private enable row level security;
alter table public.styles enable row level security;
alter table public.style_stages enable row level security;
alter table public.order_sizes enable row level security;
alter table public.stock_transactions enable row level security;
alter table public.purchase_orders enable row level security;
alter table public.purchase_order_lines enable row level security;
alter table public.purchase_line_prices enable row level security;
alter table public.bom_lines enable row level security;
alter table public.bom_costs enable row level security;
alter table public.fittings enable row level security;
alter table public.fitting_checks enable row level security;
alter table public.production_gates enable row level security;
alter table public.review_items enable row level security;

create policy inventory_settings_select
  on public.inventory_settings for select to authenticated
  using (true);
create policy inventory_settings_update
  on public.inventory_settings for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy suppliers_select
  on public.suppliers for select to authenticated using (true);
create policy suppliers_write
  on public.suppliers for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy supplier_contacts_read
  on public.supplier_contacts for select to authenticated
  using ((select private.can_edit_inventory()));
create policy supplier_contacts_write
  on public.supplier_contacts for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy materials_select
  on public.materials for select to authenticated using (true);
create policy materials_write
  on public.materials for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy material_costs_read
  on public.material_costs for select to authenticated
  using ((select private.can_read_costs()));
create policy material_costs_write
  on public.material_costs for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy costume_orders_select
  on public.costume_orders for select to authenticated using (true);
create policy costume_orders_write
  on public.costume_orders for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy order_private_read
  on public.order_private for select to authenticated
  using ((select private.can_edit_inventory()));
create policy order_private_write
  on public.order_private for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy styles_select
  on public.styles for select to authenticated using (true);
create policy styles_write
  on public.styles for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy style_stages_select
  on public.style_stages for select to authenticated using (true);
create policy style_stages_write
  on public.style_stages for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy order_sizes_select
  on public.order_sizes for select to authenticated using (true);
create policy order_sizes_write
  on public.order_sizes for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy stock_transactions_select
  on public.stock_transactions for select to authenticated using (true);
create policy stock_transactions_insert_use
  on public.stock_transactions for insert to authenticated
  with check (
    txn_type = 'use'
    and created_by = (select auth.uid())
    and qty_m is not null
  );
create policy stock_transactions_insert_editor
  on public.stock_transactions for insert to authenticated
  with check ((select private.can_edit_inventory()));

create policy purchase_orders_select
  on public.purchase_orders for select to authenticated using (true);
create policy purchase_orders_write
  on public.purchase_orders for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy purchase_order_lines_select
  on public.purchase_order_lines for select to authenticated using (true);
create policy purchase_order_lines_write
  on public.purchase_order_lines for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy purchase_line_prices_read
  on public.purchase_line_prices for select to authenticated
  using ((select private.can_read_costs()));
create policy purchase_line_prices_write
  on public.purchase_line_prices for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy bom_lines_select
  on public.bom_lines for select to authenticated using (true);
create policy bom_lines_write
  on public.bom_lines for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy bom_costs_read
  on public.bom_costs for select to authenticated
  using ((select private.can_read_costs()));
create policy bom_costs_write
  on public.bom_costs for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy fittings_select
  on public.fittings for select to authenticated using (true);
create policy fittings_write
  on public.fittings for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy fitting_checks_select
  on public.fitting_checks for select to authenticated using (true);
create policy fitting_checks_write
  on public.fitting_checks for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy production_gates_select
  on public.production_gates for select to authenticated using (true);
create policy production_gates_write
  on public.production_gates for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy review_items_select
  on public.review_items for select to authenticated
  using ((select private.can_read_costs()));
create policy review_items_write
  on public.review_items for all to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

-- Cost and contact history stays with the people who can see those tables.
drop policy if exists audit_log_select_limited on public.audit_log;
create policy audit_log_select_limited
  on public.audit_log
  for select
  to authenticated
  using (
    (select private.is_owner())
    or (
      (select private.is_payroll_admin())
      and table_name = 'employee_compensation'
    )
    or (
      (
        (select private.has_purchasing())
        or (select private.is_production_manager())
      )
      and table_name in (
        'supplier_prices',
        'material_costs',
        'purchase_line_prices',
        'bom_costs'
      )
    )
    or (
      (select private.is_production_manager())
      and table_name in ('supplier_contacts', 'order_private')
    )
    or (
      (
        (select private.is_payroll_admin())
        or (select private.is_production_manager())
      )
      and table_name = 'profile_contacts'
    )
  );
