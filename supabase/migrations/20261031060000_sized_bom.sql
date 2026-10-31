-- Metres of each component per costume size. Existing Order 005 lines stay
-- estimates: they keep consumption_per_unit_m and is_estimate.

alter table public.bom_lines
  add column waste_percent numeric(6, 2),
  add column is_estimate boolean not null default false;

alter table public.bom_lines
  add constraint bom_lines_waste_check check (
    waste_percent is null or (waste_percent >= 0 and waste_percent <= 100)
  );

update public.bom_lines
set is_estimate = true
where order_number_raw = '005';

comment on column public.bom_lines.is_estimate is
  'True for the Order 005 consumption figures. They are not a sized breakdown.';

comment on column public.bom_lines.waste_percent is
  'Optional extra percent added after size quantities times costume counts.';

create table public.bom_size_qty (
  id bigint generated always as identity primary key,
  bom_line_id bigint not null references public.bom_lines (id),
  size_code text not null,
  metres_per_piece numeric(12, 4) not null,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  unique (bom_line_id, size_code),
  constraint bom_size_qty_size_check check (
    size_code in (
      'SC', 'IC', 'IC-L', 'MC', 'MC-L', 'LC', 'XLC',
      'XSA', 'SA', 'SA-L', 'MA', 'LA', 'XLA', 'XXLA'
    )
  ),
  constraint bom_size_qty_metres_check check (metres_per_piece >= 0)
);

comment on table public.bom_size_qty is
  'Metres of one BOM component for one costume of that size. Archive instead of deleting.';

create index bom_size_qty_line_idx
  on public.bom_size_qty (bom_line_id)
  where archived_at is null;

create or replace function private.reject_bom_size_qty_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Archive a size quantity. It cannot be deleted.'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_bom_size_qty_delete() from public, anon;
grant execute on function private.reject_bom_size_qty_delete() to authenticated, service_role;

create trigger bom_size_qty_reject_delete
  before delete on public.bom_size_qty
  for each row execute function private.reject_bom_size_qty_delete();

revoke all on table public.bom_size_qty from public, anon, authenticated;
grant select, insert, update on table public.bom_size_qty to authenticated;
grant select, insert, update, delete on table public.bom_size_qty to service_role;

alter table public.bom_size_qty enable row level security;

create policy bom_size_qty_select
  on public.bom_size_qty for select to authenticated
  using (
    not (select private.is_program_director())
    or exists (
      select 1
      from public.bom_lines line
      where line.id = bom_size_qty.bom_line_id
        and line.order_id is not null
        and (select private.director_can_see_order(line.order_id))
    )
  );

create policy bom_size_qty_insert
  on public.bom_size_qty for insert to authenticated
  with check ((select private.can_edit_inventory()));

create policy bom_size_qty_update
  on public.bom_size_qty for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));
