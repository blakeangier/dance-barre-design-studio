-- Quality checks. Owners and the production manager edit the template and
-- record results. An order cannot move to ready for pickup while a check is
-- missing or an open fail or needs-fix remains. An owner can override with a
-- reason. Imported fitting_checks and production_gates stay as they were.

create table public.qc_template_items (
  id bigint generated always as identity primary key,
  item_name text not null,
  sort_order integer not null,
  archived_at timestamptz,
  unique (item_name),
  constraint qc_template_items_order_check check (sort_order > 0)
);

comment on table public.qc_template_items is
  'Checklist Elaine applies to an order. Archive an item instead of deleting it.';

insert into public.qc_template_items (item_name, sort_order)
values
  ('Seams secure', 1),
  ('Elastic correct tension', 2),
  ('Size label matches', 3),
  ('Measurements in tolerance', 4),
  ('Trims and embellishments secure', 5),
  ('No loose threads', 6),
  ('Pressed', 7),
  ('Correct fabric and colour', 8);

create table public.qc_checks (
  id bigint generated always as identity primary key,
  order_id bigint not null references public.costume_orders (id),
  template_item_id bigint references public.qc_template_items (id),
  item_name text not null,
  size_code text,
  result text not null,
  note text,
  photo_path text,
  checked_by uuid references public.profiles (id),
  checked_at timestamptz not null default now(),
  resolved_at timestamptz,
  resolved_by uuid references public.profiles (id),
  archived_at timestamptz,
  constraint qc_checks_result_check check (
    result in ('pass', 'needs_fix', 'fail')
  ),
  constraint qc_checks_size_check check (
    size_code is null
    or size_code in (
      'SC', 'IC', 'IC-L', 'MC', 'MC-L', 'LC', 'XLC',
      'XSA', 'SA', 'SA-L', 'MA', 'LA', 'XLA', 'XXLA'
    )
  ),
  constraint qc_checks_photo_check check (
    photo_path is null
    or photo_path ~* '^qc/[0-9a-f-]{36}/[0-9a-f-]{36}\.(webp|jpe?g)$'
  )
);

comment on table public.qc_checks is
  'One result on an order, optionally for one size batch. Fail and needs-fix stay open until resolved_at is set. size_code null is the order checklist.';

create index qc_checks_order_idx
  on public.qc_checks (order_id)
  where archived_at is null;

create table public.qc_overrides (
  id bigint generated always as identity primary key,
  order_id bigint not null references public.costume_orders (id),
  reason text not null,
  overridden_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  constraint qc_overrides_reason_check check (char_length(btrim(reason)) >= 3)
);

comment on table public.qc_overrides is
  'Owner override so an order can be marked ready for pickup. Append-only.';

create or replace function private.order_qc_clear(target_order bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    exists (
      select 1
      from public.qc_overrides override
      where override.order_id = target_order
    )
    or (
      not exists (
        select 1
        from public.qc_template_items item
        where item.archived_at is null
          and not exists (
            select 1
            from public.qc_checks check_row
            where check_row.order_id = target_order
              and check_row.archived_at is null
              and check_row.size_code is null
              and check_row.item_name = item.item_name
              and (
                check_row.result = 'pass'
                or check_row.resolved_at is not null
              )
          )
      )
      and not exists (
        select 1
        from public.qc_checks check_row
        where check_row.order_id = target_order
          and check_row.archived_at is null
          and check_row.size_code is null
          and check_row.result in ('fail', 'needs_fix')
          and check_row.resolved_at is null
      )
      and exists (
        select 1
        from public.qc_checks check_row
        where check_row.order_id = target_order
          and check_row.archived_at is null
          and check_row.size_code is null
      )
    );
$$;

revoke all on function private.order_qc_clear(bigint) from public, anon;
grant execute on function private.order_qc_clear(bigint) to authenticated, service_role;

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

  if new.program_id is distinct from old.program_id
    and not private.can_update_order_status()
  then
    raise exception 'You cannot change the program'
      using errcode = '42501';
  end if;

  if not private.can_edit_inventory()
    and (
      to_jsonb(new) - 'production_status' - 'program_id' - 'updated_at'
      is distinct from
      to_jsonb(old) - 'production_status' - 'program_id' - 'updated_at'
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
    if new.production_status = 'ready_for_pickup'
      and not private.order_qc_clear(new.id)
    then
      raise exception 'Quality check must be complete before pickup'
        using errcode = '42501';
    end if;
  end if;

  return new;
end;
$$;

create or replace function private.reject_qc_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Archive this quality record. It cannot be deleted.'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_qc_delete() from public, anon;
grant execute on function private.reject_qc_delete() to authenticated, service_role;

create trigger qc_template_items_reject_delete
  before delete on public.qc_template_items
  for each row execute function private.reject_qc_delete();

create trigger qc_checks_reject_delete
  before delete on public.qc_checks
  for each row execute function private.reject_qc_delete();

create or replace function private.reject_qc_override_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'An override stays on the record.'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_qc_override_change() from public, anon;
grant execute on function private.reject_qc_override_change() to authenticated, service_role;

create trigger qc_overrides_reject_change
  before update or delete on public.qc_overrides
  for each row execute function private.reject_qc_override_change();

revoke all on table public.qc_template_items from public, anon, authenticated;
grant select, insert, update on table public.qc_template_items to authenticated;

revoke all on table public.qc_checks from public, anon, authenticated;
grant select, insert, update on table public.qc_checks to authenticated;

revoke all on table public.qc_overrides from public, anon, authenticated;
grant select, insert on table public.qc_overrides to authenticated;

alter table public.qc_template_items enable row level security;
alter table public.qc_checks enable row level security;
alter table public.qc_overrides enable row level security;

create policy qc_template_select
  on public.qc_template_items for select to authenticated
  using (true);

create policy qc_template_write
  on public.qc_template_items for insert to authenticated
  with check ((select private.can_edit_inventory()));

create policy qc_template_update
  on public.qc_template_items for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy qc_checks_select
  on public.qc_checks for select to authenticated
  using (
    not (select private.is_program_director())
    or (select private.director_can_see_order(order_id))
  );

create policy qc_checks_insert
  on public.qc_checks for insert to authenticated
  with check ((select private.can_edit_inventory()));

create policy qc_checks_update
  on public.qc_checks for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create policy qc_overrides_select
  on public.qc_overrides for select to authenticated
  using (
    not (select private.is_program_director())
    or (select private.director_can_see_order(order_id))
  );

create policy qc_overrides_insert
  on public.qc_overrides for insert to authenticated
  with check (
    (select private.is_owner())
    and overridden_by = (select auth.uid())
  );
