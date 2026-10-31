-- Dance Barre Design Studio — foundation schema.
--
-- Access is enforced here, not only in the app. Row Level Security hides
-- rows. It cannot hide columns, so pay rates, supplier prices, and internal
-- costs live in their own tables.
--
-- Helper functions live in the `private` schema. That schema is not on the
-- Data API allow-list, so the browser cannot call them directly. They are
-- security definer (they run with the owner's rights) and set search_path
-- to empty so a caller cannot shadow objects they depend on.
--
-- Do not FORCE row level security on these tables. The helper functions are
-- owned by the migration role, which also owns the tables. Forcing RLS would
-- make those helpers subject to the same policies and can recurse.

create schema if not exists private;

revoke all on schema private from public;
revoke all on schema private from anon;
grant usage on schema private to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Types
-- ---------------------------------------------------------------------------

create type public.app_role as enum (
  'owner',
  'production_manager',
  'payroll_admin',
  'employee'
);

comment on type public.app_role is
  'Job role for the manufacturing app. Purchasing is a separate flag on profiles, not a role, because an owner may also purchase.';

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

create or replace function private.parse_role(value text)
returns public.app_role
language plpgsql
immutable
set search_path = ''
as $$
begin
  if value in ('owner', 'production_manager', 'payroll_admin', 'employee') then
    return value::public.app_role;
  end if;

  -- Unknown or missing metadata becomes the least-privileged role.
  return 'employee'::public.app_role;
end;
$$;

create or replace function private.parse_bool(value text, fallback boolean)
returns boolean
language plpgsql
immutable
set search_path = ''
as $$
begin
  if value is null or btrim(value) = '' then
    return fallback;
  end if;

  if lower(value) in ('true', 't', '1', 'yes') then
    return true;
  end if;

  if lower(value) in ('false', 'f', '0', 'no') then
    return false;
  end if;

  return fallback;
end;
$$;

create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Current user id, read once per statement when policies wrap this in (select ...).
create or replace function private.current_user_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select auth.uid();
$$;

-- plpgsql, not sql: the profile table is created just below, and a sql
-- function would be checked against that table at creation time.
create or replace function private.is_owner()
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  return exists (
    select 1
    from public.profiles
    where id = (select auth.uid())
      and role = 'owner'::public.app_role
      and is_active
  );
end;
$$;

create or replace function private.is_production_manager()
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  return exists (
    select 1
    from public.profiles
    where id = (select auth.uid())
      and role = 'production_manager'::public.app_role
      and is_active
  );
end;
$$;

create or replace function private.is_payroll_admin()
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  return exists (
    select 1
    from public.profiles
    where id = (select auth.uid())
      and role = 'payroll_admin'::public.app_role
      and is_active
  );
end;
$$;

-- Purchasing is a capability. Owners are not implied; call is_owner() as well
-- when owners should see the same rows.
create or replace function private.has_purchasing()
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  return exists (
    select 1
    from public.profiles
    where id = (select auth.uid())
      and is_active
      and can_purchase
  );
end;
$$;

revoke all on function private.parse_role(text) from public, anon;
revoke all on function private.parse_bool(text, boolean) from public, anon;
revoke all on function private.set_updated_at() from public, anon;
revoke all on function private.current_user_id() from public, anon;
revoke all on function private.is_owner() from public, anon;
revoke all on function private.is_production_manager() from public, anon;
revoke all on function private.is_payroll_admin() from public, anon;
revoke all on function private.has_purchasing() from public, anon;

grant execute on function private.set_updated_at() to authenticated, service_role;
grant execute on function private.parse_role(text) to authenticated, service_role;
grant execute on function private.parse_bool(text, boolean) to authenticated, service_role;
grant execute on function private.current_user_id() to authenticated, service_role;
grant execute on function private.is_owner() to authenticated, service_role;
grant execute on function private.is_production_manager() to authenticated, service_role;
grant execute on function private.is_payroll_admin() to authenticated, service_role;
grant execute on function private.has_purchasing() to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Business entities
-- ---------------------------------------------------------------------------

create table public.business_entities (
  id bigint generated always as identity primary key,
  legal_name text not null unique,
  short_name text not null,
  -- Books for this entity. The app can record CAD or USD; it does not convert.
  home_currency text not null,
  is_active boolean not null default true,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint business_entities_currency_check
    check (home_currency in ('CAD', 'USD')),
  constraint business_entities_legal_name_check
    check (char_length(btrim(legal_name)) > 0),
  constraint business_entities_short_name_check
    check (char_length(btrim(short_name)) > 0)
);

comment on table public.business_entities is
  'The two operating companies. Money tables point here so reports can stay separate.';

create trigger business_entities_set_updated_at
  before update on public.business_entities
  for each row
  execute function private.set_updated_at();

-- Names below are from the project brief. Home currency CAD is a starting
-- assumption for Canadian operations, not a confirmed accounting fact.
-- Change home_currency in the dashboard if either entity keeps books in USD.
insert into public.business_entities (legal_name, short_name, home_currency, notes)
values
  (
    'Dance Barre Design Studio Inc.',
    'Design Studio',
    'CAD',
    'Costume manufacturer. Home currency CAD is a starting assumption; confirm before financial reporting.'
  ),
  (
    'Dance Barre Studio',
    'Dance Studio',
    'CAD',
    'Separate operating entity. Home currency CAD is a starting assumption; the column also allows USD.'
  );

-- ---------------------------------------------------------------------------
-- Profiles
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  full_name text not null default '',
  role public.app_role not null default 'employee',
  -- Extra capability. Lindsay Angier is an owner who also purchases
  -- externally sourced costumes and dancewear. A later non-owner buyer
  -- can have this flag without receiving every owner screen.
  can_purchase boolean not null default false,
  is_active boolean not null default true,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_email_check check (position('@' in email) > 1),
  constraint profiles_full_name_length_check check (char_length(full_name) <= 120),
  constraint profiles_phone_length_check check (phone is null or char_length(phone) <= 40)
);

comment on table public.profiles is
  'One row per login. Role lives here, not in user-editable metadata. Pay rates do not live here.';

comment on column public.profiles.role is
  'Copied from auth.users raw_app_meta_data by trigger. End users cannot change it.';

create index profiles_role_active_idx
  on public.profiles (role)
  where is_active;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row
  execute function private.set_updated_at();

-- Keeps profiles aligned with Auth. Role is read only from app_metadata
-- (raw_app_meta_data). user_metadata is editable by the signed-in person
-- and must never drive access.
create or replace function private.sync_profile_from_auth()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  meta jsonb := coalesce(new.raw_app_meta_data, '{}'::jsonb);
begin
  insert into public.profiles (id, email, full_name, role, can_purchase)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(meta->>'full_name', ''),
    private.parse_role(meta->>'role'),
    private.parse_bool(meta->>'can_purchase', false)
  )
  on conflict (id) do update
    set email = excluded.email,
        role = excluded.role,
        can_purchase = excluded.can_purchase,
        updated_at = now();

  return new;
end;
$$;

revoke all on function private.sync_profile_from_auth() from public, anon, authenticated;
-- GoTrue updates auth.users as supabase_auth_admin, which must be allowed
-- to fire this trigger. The function itself still runs as its owner.
grant execute on function private.sync_profile_from_auth() to service_role;
grant usage on schema private to supabase_auth_admin;
grant execute on function private.sync_profile_from_auth() to supabase_auth_admin;

create trigger profiles_sync_on_auth_insert
  after insert on auth.users
  for each row
  execute function private.sync_profile_from_auth();

create trigger profiles_sync_on_auth_update
  after update of email, raw_app_meta_data on auth.users
  for each row
  execute function private.sync_profile_from_auth();

-- Blocks privilege changes from a signed-in session. The service role and
-- database admin sessions (no end-user JWT) may still change access, which
-- is how the owner-only server action and the create-users script work.
create or replace function private.protect_profile_privileges()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  claims text := nullif(current_setting('request.jwt.claims', true), '');
  jwt_role text := '';
begin
  -- Read the JWT claims directly. PostgREST sets request.jwt.claims.
  -- An empty setting means a database admin session, not a signed-in person.
  if claims is not null then
    jwt_role := coalesce(claims::jsonb ->> 'role', '');
  end if;
  if jwt_role = 'service_role' or jwt_role = '' then
    return new;
  end if;

  if new.id is distinct from old.id or new.email is distinct from old.email then
    raise exception 'You cannot change account identity'
      using errcode = '42501';
  end if;

  if new.role is distinct from old.role or new.can_purchase is distinct from old.can_purchase then
    if auth.uid() = old.id then
      raise exception 'You cannot change your own role or purchasing access'
        using errcode = '42501';
    end if;

    if not private.is_owner() then
      raise exception 'Only an owner can change role or purchasing access'
        using errcode = '42501';
    end if;
  end if;

  if new.is_active is distinct from old.is_active then
    if auth.uid() = old.id then
      raise exception 'You cannot turn off your own account'
        using errcode = '42501';
    end if;

    if not private.is_owner() then
      raise exception 'Only an owner can turn an account on or off'
        using errcode = '42501';
    end if;
  end if;

  return new;
end;
$$;

revoke all on function private.protect_profile_privileges() from public, anon;
-- The signed-in role must be allowed to fire the trigger. The function body
-- still refuses privilege changes. private is not on the Data API allow-list.
grant execute on function private.protect_profile_privileges() to authenticated, service_role;

create trigger profiles_protect_privileges
  before update on public.profiles
  for each row
  execute function private.protect_profile_privileges();

-- ---------------------------------------------------------------------------
-- Sensitive money tables (empty until a later phase)
-- Separate tables because RLS cannot hide a column inside profiles.
-- ---------------------------------------------------------------------------

create table public.employee_compensation (
  id bigint generated always as identity primary key,
  profile_id uuid not null references public.profiles (id) on delete restrict,
  entity_id bigint not null references public.business_entities (id),
  currency text not null,
  hourly_rate numeric(12, 4) not null,
  effective_from date not null,
  effective_to date,
  notes text,
  created_at timestamptz not null default now(),
  created_by uuid references public.profiles (id) on delete set null,
  constraint employee_compensation_currency_check
    check (currency in ('CAD', 'USD')),
  constraint employee_compensation_rate_check
    check (hourly_rate >= 0),
  constraint employee_compensation_period_check
    check (effective_to is null or effective_to >= effective_from)
);

comment on table public.employee_compensation is
  'Pay rates. Readable by owner and payroll_admin only. Append-only: corrections are new rows.';

create index employee_compensation_profile_id_idx
  on public.employee_compensation (profile_id);

create index employee_compensation_entity_id_idx
  on public.employee_compensation (entity_id);

create table public.supplier_prices (
  id bigint generated always as identity primary key,
  entity_id bigint not null references public.business_entities (id),
  supplier_name text not null,
  description text not null,
  currency text not null,
  unit_price numeric(12, 4) not null,
  recorded_at timestamptz not null default now(),
  constraint supplier_prices_currency_check
    check (currency in ('CAD', 'USD')),
  constraint supplier_prices_amount_check
    check (unit_price >= 0),
  constraint supplier_prices_name_check
    check (char_length(btrim(supplier_name)) > 0)
);

comment on table public.supplier_prices is
  'What outside suppliers charge. Readable by owner and profiles with can_purchase. No rows are seeded.';

create index supplier_prices_entity_id_idx
  on public.supplier_prices (entity_id);

create table public.cost_rates (
  id bigint generated always as identity primary key,
  entity_id bigint not null references public.business_entities (id),
  description text not null,
  currency text not null,
  amount numeric(12, 4) not null,
  recorded_at timestamptz not null default now(),
  constraint cost_rates_currency_check
    check (currency in ('CAD', 'USD')),
  constraint cost_rates_amount_check
    check (amount >= 0),
  constraint cost_rates_description_check
    check (char_length(btrim(description)) > 0)
);

comment on table public.cost_rates is
  'Internal costs. Owner only. No rows are seeded.';

create index cost_rates_entity_id_idx
  on public.cost_rates (entity_id);

-- ---------------------------------------------------------------------------
-- Audit log (append-only)
-- ---------------------------------------------------------------------------

create table public.audit_log (
  id bigint generated always as identity primary key,
  occurred_at timestamptz not null default now(),
  actor_id uuid,
  action text not null,
  schema_name text not null,
  table_name text not null,
  record_id text,
  old_data jsonb,
  new_data jsonb,
  constraint audit_log_action_check
    check (action in ('INSERT', 'UPDATE', 'DELETE'))
);

comment on table public.audit_log is
  'Append-only history. App users cannot update or delete rows. Pay figures inside old_data/new_data are visible only to roles who may see that table.';

create index audit_log_table_record_idx
  on public.audit_log (table_name, record_id);

create index audit_log_occurred_at_idx
  on public.audit_log (occurred_at desc);

create or replace function private.audit_row()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  payload_old jsonb;
  payload_new jsonb;
  row_id text;
begin
  if tg_op = 'DELETE' then
    payload_old := to_jsonb(old);
    payload_new := null;
    row_id := payload_old->>'id';
  elsif tg_op = 'UPDATE' then
    payload_old := to_jsonb(old);
    payload_new := to_jsonb(new);
    row_id := payload_new->>'id';
  else
    payload_old := null;
    payload_new := to_jsonb(new);
    row_id := payload_new->>'id';
  end if;

  insert into public.audit_log (
    actor_id,
    action,
    schema_name,
    table_name,
    record_id,
    old_data,
    new_data
  )
  values (
    auth.uid(),
    tg_op,
    tg_table_schema,
    tg_table_name,
    row_id,
    payload_old,
    payload_new
  );

  return coalesce(new, old);
end;
$$;

revoke all on function private.audit_row() from public, anon;
grant execute on function private.audit_row() to authenticated, service_role;

create or replace function private.reject_audit_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'audit_log is append-only and cannot be changed'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_audit_change() from public, anon;
grant execute on function private.reject_audit_change() to authenticated, service_role;

create trigger audit_log_reject_update
  before update on public.audit_log
  for each row
  execute function private.reject_audit_change();

create trigger audit_log_reject_delete
  before delete on public.audit_log
  for each row
  execute function private.reject_audit_change();

create trigger business_entities_audit
  after insert or update or delete on public.business_entities
  for each row
  execute function private.audit_row();

create trigger profiles_audit
  after insert or update or delete on public.profiles
  for each row
  execute function private.audit_row();

create trigger employee_compensation_audit
  after insert or update or delete on public.employee_compensation
  for each row
  execute function private.audit_row();

create trigger supplier_prices_audit
  after insert or update or delete on public.supplier_prices
  for each row
  execute function private.audit_row();

create trigger cost_rates_audit
  after insert or update or delete on public.cost_rates
  for each row
  execute function private.audit_row();

-- ---------------------------------------------------------------------------
-- Grants
-- Cloud projects grant Data API roles automatically. Revoke first, then
-- grant only the operations each role needs. service_role bypasses RLS but
-- still needs table grants; the app uses it only on the server.
-- ---------------------------------------------------------------------------

revoke all on table public.business_entities from public, anon, authenticated;
revoke all on table public.profiles from public, anon, authenticated;
revoke all on table public.employee_compensation from public, anon, authenticated;
revoke all on table public.supplier_prices from public, anon, authenticated;
revoke all on table public.cost_rates from public, anon, authenticated;
revoke all on table public.audit_log from public, anon, authenticated;

grant select on table public.business_entities to authenticated;
grant select on table public.profiles to authenticated;
-- Name and phone only. Role, purchasing, and active flag are not writable
-- through the Data API. Owners change those with the server-side secret key.
grant update (full_name, phone) on table public.profiles to authenticated;

grant select, insert on table public.employee_compensation to authenticated;
grant select, insert on table public.supplier_prices to authenticated;
grant select, insert on table public.cost_rates to authenticated;
grant select on table public.audit_log to authenticated;

grant select, insert, update, delete on table public.business_entities to service_role;
grant select, insert, update, delete on table public.profiles to service_role;
grant select, insert, update, delete on table public.employee_compensation to service_role;
grant select, insert, update, delete on table public.supplier_prices to service_role;
grant select, insert, update, delete on table public.cost_rates to service_role;
grant select, insert, update, delete on table public.audit_log to service_role;

grant usage, select on all sequences in schema public to authenticated, service_role;
revoke all on all sequences in schema public from anon;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- No policy for anon. With the grants above, anon is denied.
-- Wrap helper calls in (select ...) so Postgres can cache them per statement.
-- ---------------------------------------------------------------------------

alter table public.business_entities enable row level security;
alter table public.profiles enable row level security;
alter table public.employee_compensation enable row level security;
alter table public.supplier_prices enable row level security;
alter table public.cost_rates enable row level security;
alter table public.audit_log enable row level security;

create policy business_entities_select_authenticated
  on public.business_entities
  for select
  to authenticated
  using (true);

create policy profiles_select_visible
  on public.profiles
  for select
  to authenticated
  using (
    id = (select auth.uid())
    or (select private.is_owner())
    or (select private.is_production_manager())
    or (select private.is_payroll_admin())
  );

create policy profiles_update_self
  on public.profiles
  for update
  to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

create policy employee_compensation_select_payroll
  on public.employee_compensation
  for select
  to authenticated
  using (
    (select private.is_owner())
    or (select private.is_payroll_admin())
  );

create policy employee_compensation_insert_payroll
  on public.employee_compensation
  for insert
  to authenticated
  with check (
    (select private.is_owner())
    or (select private.is_payroll_admin())
  );

create policy supplier_prices_select_purchasing
  on public.supplier_prices
  for select
  to authenticated
  using (
    (select private.is_owner())
    or (select private.has_purchasing())
  );

create policy supplier_prices_insert_purchasing
  on public.supplier_prices
  for insert
  to authenticated
  with check (
    (select private.is_owner())
    or (select private.has_purchasing())
  );

create policy cost_rates_select_owner
  on public.cost_rates
  for select
  to authenticated
  using ((select private.is_owner()));

create policy cost_rates_insert_owner
  on public.cost_rates
  for insert
  to authenticated
  with check ((select private.is_owner()));

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
      (select private.has_purchasing())
      and table_name = 'supplier_prices'
    )
  );
