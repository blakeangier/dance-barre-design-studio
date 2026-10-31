-- Tech pack versions. A new save is a new version. Older versions stay.
-- The default sewing route is the Order 005 routing. Costs are not stored here.

create table public.sewing_route_template (
  sort_order integer primary key,
  operation_name text not null,
  constraint sewing_route_template_order_check check (sort_order > 0)
);

comment on table public.sewing_route_template is
  'Default sewing route taken from Order 005: prep through QC.';

insert into public.sewing_route_template (sort_order, operation_name)
values
  (1, 'Prep'),
  (2, 'Join body'),
  (3, 'Sleeves'),
  (4, 'Panty/pant'),
  (5, 'Waistband'),
  (6, 'Elastic/binding'),
  (7, 'Coverstitch'),
  (8, 'Labels'),
  (9, 'Press'),
  (10, 'QC');

create table public.tech_pack_versions (
  id bigint generated always as identity primary key,
  style_id bigint not null references public.styles (id),
  version_no integer not null,
  description text,
  construction_notes text,
  sketch_path text,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  unique (style_id, version_no),
  constraint tech_pack_versions_no_check check (version_no > 0),
  constraint tech_pack_versions_sketch_check check (
    sketch_path is null
    or sketch_path ~* '^sketches/[0-9]+/[0-9a-f-]{36}\.(webp|jpe?g)$'
  )
);

comment on table public.tech_pack_versions is
  'One saved spec sheet. Fabrics and trims are read from the live BOM, not copied here, so prices never land on the pack.';

create table public.tech_pack_measures (
  id bigint generated always as identity primary key,
  version_id bigint not null references public.tech_pack_versions (id),
  point_name text not null,
  size_code text not null,
  value_cm numeric(8, 2),
  tolerance_cm numeric(8, 2),
  sort_order integer not null default 1,
  unique (version_id, point_name, size_code),
  constraint tech_pack_measures_size_check check (
    size_code in (
      'SC', 'IC', 'IC-L', 'MC', 'MC-L', 'LC', 'XLC',
      'XSA', 'SA', 'SA-L', 'MA', 'LA', 'XLA', 'XXLA'
    )
  )
);

comment on table public.tech_pack_measures is
  'One point of measure for one size on one tech pack version.';

create table public.tech_pack_operations (
  id bigint generated always as identity primary key,
  version_id bigint not null references public.tech_pack_versions (id),
  sort_order integer not null,
  operation_name text not null,
  unique (version_id, sort_order)
);

comment on table public.tech_pack_operations is
  'Sewing operations for one tech pack version.';

create or replace function private.reject_tech_pack_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'A tech pack version stays as saved. Add a new version.'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_tech_pack_change() from public, anon;
grant execute on function private.reject_tech_pack_change() to authenticated, service_role;

create trigger tech_pack_versions_reject_change
  before update or delete on public.tech_pack_versions
  for each row execute function private.reject_tech_pack_change();

create trigger tech_pack_measures_reject_change
  before update or delete on public.tech_pack_measures
  for each row execute function private.reject_tech_pack_change();

create trigger tech_pack_operations_reject_change
  before update or delete on public.tech_pack_operations
  for each row execute function private.reject_tech_pack_change();

revoke all on table public.sewing_route_template from public, anon, authenticated;
grant select on table public.sewing_route_template to authenticated;

revoke all on table public.tech_pack_versions from public, anon, authenticated;
grant select, insert on table public.tech_pack_versions to authenticated;

revoke all on table public.tech_pack_measures from public, anon, authenticated;
grant select, insert on table public.tech_pack_measures to authenticated;

revoke all on table public.tech_pack_operations from public, anon, authenticated;
grant select, insert on table public.tech_pack_operations to authenticated;

alter table public.sewing_route_template enable row level security;
alter table public.tech_pack_versions enable row level security;
alter table public.tech_pack_measures enable row level security;
alter table public.tech_pack_operations enable row level security;

create policy sewing_route_select
  on public.sewing_route_template for select to authenticated
  using (true);

create policy tech_pack_versions_select
  on public.tech_pack_versions for select to authenticated
  using (
    not (select private.is_program_director())
    or exists (
      select 1
      from public.styles style
      where style.id = tech_pack_versions.style_id
        and style.order_id is not null
        and (select private.director_can_see_order(style.order_id))
    )
  );

create policy tech_pack_versions_insert
  on public.tech_pack_versions for insert to authenticated
  with check ((select private.can_edit_inventory()));

create policy tech_pack_measures_select
  on public.tech_pack_measures for select to authenticated
  using (
    exists (
      select 1
      from public.tech_pack_versions version
      where version.id = tech_pack_measures.version_id
    )
  );

create policy tech_pack_measures_insert
  on public.tech_pack_measures for insert to authenticated
  with check ((select private.can_edit_inventory()));

create policy tech_pack_operations_select
  on public.tech_pack_operations for select to authenticated
  using (
    exists (
      select 1
      from public.tech_pack_versions version
      where version.id = tech_pack_operations.version_id
    )
  );

create policy tech_pack_operations_insert
  on public.tech_pack_operations for insert to authenticated
  with check ((select private.can_edit_inventory()));
