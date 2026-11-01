-- Archive instead of delete, and stop signed-in users from deleting records.
-- Stock quantities are still not columns on materials. They stay in the ledger.

alter table public.materials
  add column archived_at timestamptz;
alter table public.costume_orders
  add column archived_at timestamptz;
alter table public.styles
  add column archived_at timestamptz;
alter table public.suppliers
  add column archived_at timestamptz;
alter table public.purchase_orders
  add column archived_at timestamptz;
alter table public.purchase_order_lines
  add column archived_at timestamptz;
alter table public.fittings
  add column archived_at timestamptz;
alter table public.bom_lines
  add column archived_at timestamptz;

comment on column public.materials.archived_at is
  'When set, the material is hidden from the default list. It is not deleted.';
comment on column public.costume_orders.archived_at is
  'When set, the order is hidden from the default list. Cancelled is a separate status.';
comment on column public.styles.archived_at is
  'When set, the style is hidden from the default list. It is not deleted.';
comment on column public.suppliers.archived_at is
  'When set, the supplier is hidden from the default list. It is not deleted.';
comment on column public.purchase_orders.archived_at is
  'When set, the purchase order is hidden from the default list. It is not deleted.';
comment on column public.purchase_order_lines.archived_at is
  'When set, the purchase line is hidden from the default list. It is not deleted.';
comment on column public.fittings.archived_at is
  'When set, the fitting is hidden from the default list. It is not deleted.';
comment on column public.bom_lines.archived_at is
  'When set, the BOM line is hidden from the default list. It is not deleted.';

-- Closed replaces the unused "resolved" value. Existing imports are all open.
update public.review_items
set status = 'closed'
where status = 'resolved';

alter table public.review_items drop constraint review_items_status_check;
alter table public.review_items
  add constraint review_items_status_check
  check (status in ('open', 'answered', 'closed'));

comment on column public.review_items.status is
  'open, answered, or closed. Closed questions are hidden until Show archived is on.';

-- Owners may edit another person's name, role, purchasing switch, and active flag.
-- The protect trigger still blocks editing your own access.
grant update (role, can_purchase, is_active) on table public.profiles to authenticated;

create policy profiles_update_by_owner
  on public.profiles
  for update
  to authenticated
  using (
    (select private.is_owner())
    and id <> (select auth.uid())
  )
  with check ((select private.is_owner()));

create or replace function private.can_record_purchase()
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  return (select private.is_owner())
    or (select private.has_purchasing());
end;
$$;

revoke all on function private.can_record_purchase() from public, anon;
grant execute on function private.can_record_purchase() to authenticated, service_role;

comment on function private.can_record_purchase() is
  'Owners, and anyone with the purchasing switch, may create and edit purchase orders, lines, and prices.';

-- Replace FOR ALL policies so DELETE is not granted to signed-in users.
drop policy suppliers_write on public.suppliers;
create policy suppliers_insert
  on public.suppliers for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy suppliers_update
  on public.suppliers for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy supplier_contacts_write on public.supplier_contacts;
create policy supplier_contacts_insert
  on public.supplier_contacts for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy supplier_contacts_update
  on public.supplier_contacts for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy materials_write on public.materials;
create policy materials_insert
  on public.materials for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy materials_update
  on public.materials for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy material_costs_write on public.material_costs;
create policy material_costs_insert
  on public.material_costs for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy material_costs_update
  on public.material_costs for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy costume_orders_write on public.costume_orders;
create policy costume_orders_insert
  on public.costume_orders for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy costume_orders_update
  on public.costume_orders for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy order_private_write on public.order_private;
create policy order_private_insert
  on public.order_private for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy order_private_update
  on public.order_private for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy styles_write on public.styles;
create policy styles_insert
  on public.styles for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy styles_update
  on public.styles for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy style_stages_write on public.style_stages;
create policy style_stages_insert
  on public.style_stages for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy style_stages_update
  on public.style_stages for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy order_sizes_write on public.order_sizes;
create policy order_sizes_insert
  on public.order_sizes for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy order_sizes_update
  on public.order_sizes for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy purchase_orders_write on public.purchase_orders;
create policy purchase_orders_insert
  on public.purchase_orders for insert to authenticated
  with check ((select private.can_record_purchase()));
create policy purchase_orders_update
  on public.purchase_orders for update to authenticated
  using ((select private.can_record_purchase()))
  with check ((select private.can_record_purchase()));

drop policy purchase_order_lines_write on public.purchase_order_lines;
create policy purchase_order_lines_insert
  on public.purchase_order_lines for insert to authenticated
  with check ((select private.can_record_purchase()));
create policy purchase_order_lines_update
  on public.purchase_order_lines for update to authenticated
  using ((select private.can_record_purchase()))
  with check ((select private.can_record_purchase()));

drop policy purchase_line_prices_write on public.purchase_line_prices;
create policy purchase_line_prices_insert
  on public.purchase_line_prices for insert to authenticated
  with check ((select private.can_record_purchase()));
create policy purchase_line_prices_update
  on public.purchase_line_prices for update to authenticated
  using ((select private.can_record_purchase()))
  with check ((select private.can_record_purchase()));

drop policy bom_lines_write on public.bom_lines;
create policy bom_lines_insert
  on public.bom_lines for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy bom_lines_update
  on public.bom_lines for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy bom_costs_write on public.bom_costs;
create policy bom_costs_insert
  on public.bom_costs for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy bom_costs_update
  on public.bom_costs for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy fittings_write on public.fittings;
create policy fittings_insert
  on public.fittings for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy fittings_update
  on public.fittings for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy fitting_checks_write on public.fitting_checks;
create policy fitting_checks_insert
  on public.fitting_checks for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy fitting_checks_update
  on public.fitting_checks for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy production_gates_write on public.production_gates;
create policy production_gates_insert
  on public.production_gates for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy production_gates_update
  on public.production_gates for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy review_items_write on public.review_items;
create policy review_items_insert
  on public.review_items for insert to authenticated
  with check ((select private.can_edit_inventory()));
create policy review_items_update
  on public.review_items for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

create or replace function private.reject_record_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Records are archived, not deleted'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_record_delete() from public, anon;
grant execute on function private.reject_record_delete() to authenticated, service_role;

create trigger materials_reject_delete
  before delete on public.materials
  for each row execute function private.reject_record_delete();
create trigger costume_orders_reject_delete
  before delete on public.costume_orders
  for each row execute function private.reject_record_delete();
create trigger styles_reject_delete
  before delete on public.styles
  for each row execute function private.reject_record_delete();
create trigger suppliers_reject_delete
  before delete on public.suppliers
  for each row execute function private.reject_record_delete();
create trigger purchase_orders_reject_delete
  before delete on public.purchase_orders
  for each row execute function private.reject_record_delete();
create trigger purchase_order_lines_reject_delete
  before delete on public.purchase_order_lines
  for each row execute function private.reject_record_delete();
create trigger fittings_reject_delete
  before delete on public.fittings
  for each row execute function private.reject_record_delete();
create trigger bom_lines_reject_delete
  before delete on public.bom_lines
  for each row execute function private.reject_record_delete();
create trigger review_items_reject_delete
  before delete on public.review_items
  for each row execute function private.reject_record_delete();
