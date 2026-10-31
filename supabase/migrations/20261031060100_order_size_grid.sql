-- Size grid for an order. Runs with the sized BOM: quantities stay on
-- order_sizes, one row per style and size. Order 005's imported rows are
-- kept. The column order is a setting, so a new size can be added later.

create table public.size_scale (
  size_code text primary key,
  sort_order integer not null unique,
  archived_at timestamptz,
  constraint size_scale_code_check check (char_length(btrim(size_code)) > 0),
  constraint size_scale_order_check check (sort_order > 0)
);

comment on table public.size_scale is
  'Ordered costume sizes for the order grid. Archive a size instead of deleting it. Seeded from the Order 005 breakdown, with XSC first so a smaller child size can be used.';

insert into public.size_scale (size_code, sort_order)
values
  ('XSC', 1),
  ('SC', 2),
  ('IC', 3),
  ('IC-L', 4),
  ('MC', 5),
  ('MC-L', 6),
  ('LC', 7),
  ('XLC', 8),
  ('XSA', 9),
  ('SA', 10),
  ('SA-L', 11),
  ('MA', 12),
  ('LA', 13),
  ('XLA', 14),
  ('XXLA', 15);

-- Any size already stored, including Order 005, stays even if it was not in the seed.
insert into public.size_scale (size_code, sort_order)
select
  existing.size_code,
  1000 + row_number() over (order by existing.size_code)
from (
  select distinct size_code
  from public.order_sizes
  where size_code not in (select size_code from public.size_scale)
) existing;

-- Point each size row at the style's order when that link was missing.
update public.order_sizes size_row
set order_id = style.order_id
from public.styles style
where size_row.style_id = style.id
  and style.order_id is not null
  and size_row.order_id is distinct from style.order_id;

comment on table public.order_sizes is
  'Quantity needed of one size for one style. Order 005 stays as imported: one row per style and size, not one row for the whole order.';

alter table public.order_sizes
  add constraint order_sizes_size_fkey
  foreign key (size_code) references public.size_scale (size_code);

alter table public.bom_size_qty drop constraint bom_size_qty_size_check;
alter table public.bom_size_qty
  add constraint bom_size_qty_size_fkey
  foreign key (size_code) references public.size_scale (size_code);

alter table public.qc_checks drop constraint qc_checks_size_check;
alter table public.qc_checks
  add constraint qc_checks_size_fkey
  foreign key (size_code) references public.size_scale (size_code);

alter table public.tech_pack_measures drop constraint tech_pack_measures_size_check;
alter table public.tech_pack_measures
  add constraint tech_pack_measures_size_fkey
  foreign key (size_code) references public.size_scale (size_code);

create or replace function private.guard_order_size()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    return new;
  end if;
  if not (select private.can_update_order_status()) then
    raise exception 'You cannot change size quantities'
      using errcode = '42501';
  end if;
  if new.order_id is null then
    select style.order_id into new.order_id
    from public.styles style
    where style.id = new.style_id;
  end if;
  return new;
end;
$$;

revoke all on function private.guard_order_size() from public, anon;
grant execute on function private.guard_order_size() to authenticated, service_role;

create trigger order_sizes_guard
  before insert or update on public.order_sizes
  for each row execute function private.guard_order_size();

create or replace function private.reject_order_size_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Clear a quantity. A size row cannot be deleted.'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_order_size_delete() from public, anon;
grant execute on function private.reject_order_size_delete() to authenticated, service_role;

create trigger order_sizes_reject_delete
  before delete on public.order_sizes
  for each row execute function private.reject_order_size_delete();

create trigger size_scale_reject_delete
  before delete on public.size_scale
  for each row execute function private.reject_order_size_delete();

revoke all on table public.size_scale from public, anon, authenticated;
grant select, insert, update on table public.size_scale to authenticated;
grant select, insert, update, delete on table public.size_scale to service_role;

alter table public.size_scale enable row level security;

create policy size_scale_select
  on public.size_scale for select to authenticated
  using (true);

create policy size_scale_insert
  on public.size_scale for insert to authenticated
  with check ((select private.can_edit_inventory()));

create policy size_scale_update
  on public.size_scale for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));

drop policy if exists order_sizes_select on public.order_sizes;
create policy order_sizes_select
  on public.order_sizes for select to authenticated
  using (
    not (select private.is_program_director())
    or exists (
      select 1
      from public.styles style
      where style.id = order_sizes.style_id
        and style.order_id is not null
        and (select private.director_can_see_order(style.order_id))
    )
  );

drop policy if exists order_sizes_insert on public.order_sizes;
create policy order_sizes_insert
  on public.order_sizes for insert to authenticated
  with check ((select private.can_update_order_status()));

drop policy if exists order_sizes_update on public.order_sizes;
create policy order_sizes_update
  on public.order_sizes for update to authenticated
  using (
    not (select private.is_program_director())
    or exists (
      select 1
      from public.styles style
      where style.id = order_sizes.style_id
        and style.order_id is not null
        and (select private.director_can_see_order(style.order_id))
    )
  )
  with check ((select private.can_update_order_status()));
