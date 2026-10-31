-- Production status, who may change it, and a view-only program director.
-- Cancelled stays on costume_orders.status. production_status is the shop step.
-- Program scope is tightened in 20261031054000_director_scope_required.sql:
-- a director with no links sees no orders. This file does not create Jialin Liao. An owner sets
-- can_update_order_status on her account after she can sign in.

create or replace function private.parse_role(value text)
returns public.app_role
language plpgsql
immutable
set search_path = ''
as $$
begin
  if value in (
    'owner',
    'production_manager',
    'payroll_admin',
    'employee',
    'program_director'
  ) then
    return value::public.app_role;
  end if;

  return 'employee'::public.app_role;
end;
$$;

comment on type public.app_role is
  'Job role. program_director is view-only. Purchasing and order-status updates are flags, not roles.';

alter table public.profiles
  add column can_update_order_status boolean not null default false;

comment on column public.profiles.can_update_order_status is
  'Copied from app_metadata. Owners and the production manager can always change production status. This flag lets a regular employee, such as Jialin Liao, do that too.';

create or replace function private.sync_profile_from_auth()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  meta jsonb := coalesce(new.raw_app_meta_data, '{}'::jsonb);
begin
  insert into public.profiles (
    id, full_name, role, can_purchase, can_update_order_status
  )
  values (
    new.id,
    coalesce(meta->>'full_name', ''),
    private.parse_role(meta->>'role'),
    private.parse_bool(meta->>'can_purchase', false),
    private.parse_bool(meta->>'can_update_order_status', false)
  )
  on conflict (id) do update
    set role = excluded.role,
        can_purchase = excluded.can_purchase,
        can_update_order_status = excluded.can_update_order_status,
        updated_at = now();

  insert into public.profile_contacts (profile_id, email)
  values (new.id, coalesce(new.email, ''))
  on conflict (profile_id) do update
    set email = excluded.email,
        updated_at = now();

  return new;
end;
$$;

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
  if claims is not null then
    jwt_role := coalesce(claims::jsonb ->> 'role', '');
  end if;
  if jwt_role = 'service_role' or jwt_role = '' then
    return new;
  end if;

  if new.id is distinct from old.id then
    raise exception 'You cannot change account identity'
      using errcode = '42501';
  end if;

  if new.role is distinct from old.role
    or new.can_purchase is distinct from old.can_purchase
    or new.can_update_order_status is distinct from old.can_update_order_status
  then
    if auth.uid() = old.id then
      raise exception 'You cannot change your own role or access flags'
        using errcode = '42501';
    end if;

    if not private.is_owner() then
      raise exception 'Only an owner can change role or access flags'
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

  if new.job_title is distinct from old.job_title
    or new.employment_type is distinct from old.employment_type
    or new.start_date is distinct from old.start_date
    or new.start_note is distinct from old.start_note
  then
    if not private.is_owner() then
      raise exception 'Only an owner can change job details'
        using errcode = '42501';
    end if;
  end if;

  if new.pronouns is distinct from old.pronouns
    and auth.uid() is distinct from old.id
    and not private.is_owner()
  then
    raise exception 'You can change only your own pronouns'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

create or replace function private.is_program_director()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = (select auth.uid())
      and role = 'program_director'
      and is_active
  );
$$;

revoke all on function private.is_program_director() from public, anon;
grant execute on function private.is_program_director() to authenticated, service_role;

create or replace function private.can_update_order_status()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = (select auth.uid())
      and is_active
      and role <> 'program_director'
      and (
        role in ('owner', 'production_manager')
        or can_update_order_status
      )
  );
$$;

revoke all on function private.can_update_order_status() from public, anon;
grant execute on function private.can_update_order_status() to authenticated, service_role;

create table public.programs (
  id bigint generated always as identity primary key,
  name text not null unique,
  created_at timestamptz not null default now(),
  constraint programs_name_check check (char_length(btrim(name)) > 0)
);

comment on table public.programs is
  'Optional grouping for costume orders, such as Elite Company, CREW, and Petite Elite.';

insert into public.programs (name)
values ('Elite Company'), ('CREW'), ('Petite Elite');

create table public.director_programs (
  profile_id uuid not null references public.profiles (id) on delete cascade,
  program_id bigint not null references public.programs (id) on delete cascade,
  primary key (profile_id, program_id)
);

comment on table public.director_programs is
  'When a program director has rows here, they see only those programs. No rows means every order.';

alter table public.costume_orders
  add column program_id bigint references public.programs (id),
  add column production_status text not null default 'not_started';

alter table public.costume_orders
  add constraint costume_orders_production_status_check check (
    production_status in (
      'not_started',
      'design_samples',
      'fabric_ordered',
      'ready_to_cut',
      'cutting',
      'sewing',
      'finishing_qc',
      'ready_for_pickup',
      'delivered'
    )
  );

comment on column public.costume_orders.production_status is
  'Shop step. Cancelled orders keep costume_orders.status = cancelled and do not move this step.';

comment on column public.costume_orders.program_id is
  'Optional program. Null orders are visible to a director who is not limited to programs.';

create index costume_orders_program_id_idx
  on public.costume_orders (program_id);

create index costume_orders_production_status_idx
  on public.costume_orders (production_status);

create table public.order_status_events (
  id bigint generated always as identity primary key,
  order_id bigint not null references public.costume_orders (id),
  from_status text,
  to_status text not null,
  changed_by uuid references public.profiles (id),
  created_at timestamptz not null default now()
);

comment on table public.order_status_events is
  'Append-only history of production_status. The original step is not edited.';

create index order_status_events_order_id_idx
  on public.order_status_events (order_id, created_at);

create or replace function private.director_can_see_order(target_order bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    private.is_program_director()
    and (
      not exists (
        select 1
        from public.director_programs link
        where link.profile_id = (select auth.uid())
      )
      or exists (
        select 1
        from public.costume_orders costume_order
        join public.director_programs link
          on link.program_id = costume_order.program_id
        where costume_order.id = target_order
          and link.profile_id = (select auth.uid())
      )
    );
$$;

revoke all on function private.director_can_see_order(bigint) from public, anon;
grant execute on function private.director_can_see_order(bigint) to authenticated, service_role;

create or replace function private.guard_production_status()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    return new;
  end if;

  if not private.can_edit_inventory()
    and (
      to_jsonb(new) - 'production_status' - 'updated_at'
      is distinct from
      to_jsonb(old) - 'production_status' - 'updated_at'
    )
  then
    raise exception 'You can change the production status only'
      using errcode = '42501';
  end if;

  if new.production_status is distinct from old.production_status then
    if not private.can_update_order_status() then
      raise exception 'You cannot change the production status'
        using errcode = '42501';
    end if;
    if old.status = 'cancelled' then
      raise exception 'A cancelled order keeps its cancelled state'
        using errcode = '42501';
    end if;
  end if;

  return new;
end;
$$;

revoke all on function private.guard_production_status() from public, anon;
grant execute on function private.guard_production_status() to authenticated, service_role;

create trigger costume_orders_guard_production_status
  before update on public.costume_orders
  for each row execute function private.guard_production_status();

create or replace function private.record_production_status()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.production_status is distinct from old.production_status then
    insert into public.order_status_events (
      order_id, from_status, to_status, changed_by
    ) values (
      new.id, old.production_status, new.production_status, (select auth.uid())
    );
  end if;
  return new;
end;
$$;

revoke all on function private.record_production_status() from public, anon;
grant execute on function private.record_production_status() to authenticated, service_role;

create trigger costume_orders_record_production_status
  after update on public.costume_orders
  for each row execute function private.record_production_status();

create or replace function private.reject_status_event_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Production status history is kept'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_status_event_change() from public, anon;
grant execute on function private.reject_status_event_change() to authenticated, service_role;

create trigger order_status_events_reject_change
  before update or delete on public.order_status_events
  for each row execute function private.reject_status_event_change();

-- A program director sees orders, their styles, stages, fabrics, and photos.
-- They do not see costs, stock quantities, purchases, supplier details,
-- staff records, the audit log, or low-stock alerts.

drop policy if exists costume_orders_select on public.costume_orders;
create policy costume_orders_select
  on public.costume_orders for select to authenticated
  using (
    not (select private.is_program_director())
    or (select private.director_can_see_order(id))
  );

-- Anyone who can see an order may attempt an update. The guard trigger
-- rejects every change they are not allowed to make, so a denied write
-- is an error rather than a silent no-op.
create policy costume_orders_update_attempt
  on public.costume_orders for update to authenticated
  using (
    not (select private.is_program_director())
    or (select private.director_can_see_order(id))
  )
  with check (
    not (select private.is_program_director())
    or (select private.director_can_see_order(id))
  );

drop policy if exists styles_select on public.styles;
create policy styles_select
  on public.styles for select to authenticated
  using (
    not (select private.is_program_director())
    or (
      order_id is not null
      and (select private.director_can_see_order(order_id))
    )
  );

drop policy if exists style_stages_select on public.style_stages;
create policy style_stages_select
  on public.style_stages for select to authenticated
  using (
    not (select private.is_program_director())
    or exists (
      select 1
      from public.styles style
      where style.id = style_stages.style_id
        and style.order_id is not null
        and (select private.director_can_see_order(style.order_id))
    )
  );

drop policy if exists bom_lines_select on public.bom_lines;
create policy bom_lines_select
  on public.bom_lines for select to authenticated
  using (
    not (select private.is_program_director())
    or (
      order_id is not null
      and (select private.director_can_see_order(order_id))
    )
  );

drop policy if exists materials_select on public.materials;
create policy materials_select
  on public.materials for select to authenticated
  using (
    not (select private.is_program_director())
    or exists (
      select 1
      from public.bom_lines line
      where line.material_id = materials.id
        and line.order_id is not null
        and (select private.director_can_see_order(line.order_id))
    )
  );

drop policy if exists material_photos_select on public.material_photos;
create policy material_photos_select
  on public.material_photos for select to authenticated
  using (
    not (select private.is_program_director())
    or exists (
      select 1
      from public.bom_lines line
      where line.material_id = material_photos.material_id
        and line.order_id is not null
        and (select private.director_can_see_order(line.order_id))
    )
  );

drop policy if exists stock_transactions_select on public.stock_transactions;
create policy stock_transactions_select
  on public.stock_transactions for select to authenticated
  using (not (select private.is_program_director()));

drop policy if exists stock_transactions_insert_use on public.stock_transactions;
create policy stock_transactions_insert_use
  on public.stock_transactions for insert to authenticated
  with check (
    txn_type = 'use'
    and created_by = (select auth.uid())
    and qty_m is not null
    and not (select private.is_program_director())
  );

drop policy if exists suppliers_select on public.suppliers;
create policy suppliers_select
  on public.suppliers for select to authenticated
  using (not (select private.is_program_director()));

drop policy if exists purchase_orders_select on public.purchase_orders;
create policy purchase_orders_select
  on public.purchase_orders for select to authenticated
  using (not (select private.is_program_director()));

drop policy if exists purchase_order_lines_select on public.purchase_order_lines;
create policy purchase_order_lines_select
  on public.purchase_order_lines for select to authenticated
  using (not (select private.is_program_director()));

drop policy if exists fittings_select on public.fittings;
create policy fittings_select
  on public.fittings for select to authenticated
  using (not (select private.is_program_director()));

drop policy if exists fitting_checks_select on public.fitting_checks;
create policy fitting_checks_select
  on public.fitting_checks for select to authenticated
  using (not (select private.is_program_director()));

drop policy if exists production_gates_select on public.production_gates;
create policy production_gates_select
  on public.production_gates for select to authenticated
  using (not (select private.is_program_director()));

drop policy if exists order_sizes_select on public.order_sizes;
create policy order_sizes_select
  on public.order_sizes for select to authenticated
  using (not (select private.is_program_director()));

drop policy if exists review_items_select on public.review_items;
create policy review_items_select
  on public.review_items for select to authenticated
  using (not (select private.is_program_director()));

drop policy if exists inventory_settings_select on public.inventory_settings;
create policy inventory_settings_select
  on public.inventory_settings for select to authenticated
  using (not (select private.is_program_director()));

drop policy if exists profiles_select_coworkers on public.profiles;
create policy profiles_select_coworkers
  on public.profiles for select to authenticated
  using (
    not (select private.is_program_director())
    or id = (select auth.uid())
  );

revoke all on table public.programs from public, anon, authenticated;
grant select on table public.programs to authenticated;
grant select, insert, update, delete on table public.programs to service_role;

revoke all on table public.director_programs from public, anon, authenticated;
grant select, insert, delete on table public.director_programs to authenticated;
grant select, insert, update, delete on table public.director_programs to service_role;

revoke all on table public.order_status_events from public, anon, authenticated;
grant select on table public.order_status_events to authenticated;
grant select, insert, update, delete on table public.order_status_events to service_role;

alter table public.programs enable row level security;
alter table public.director_programs enable row level security;
alter table public.order_status_events enable row level security;

create policy programs_select
  on public.programs for select to authenticated
  using (
    not (select private.is_program_director())
    or not exists (
      select 1
      from public.director_programs link
      where link.profile_id = (select auth.uid())
    )
    or exists (
      select 1
      from public.director_programs link
      where link.profile_id = (select auth.uid())
        and link.program_id = programs.id
    )
  );

create policy director_programs_select
  on public.director_programs for select to authenticated
  using (
    profile_id = (select auth.uid())
    or (select private.is_owner())
  );

create policy director_programs_insert
  on public.director_programs for insert to authenticated
  with check ((select private.is_owner()));

create policy director_programs_delete
  on public.director_programs for delete to authenticated
  using ((select private.is_owner()));

create policy order_status_events_select
  on public.order_status_events for select to authenticated
  using (
    not (select private.is_program_director())
    or (select private.director_can_see_order(order_id))
  );
