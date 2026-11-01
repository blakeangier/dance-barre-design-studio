-- Fabric photos. The bucket is private. The app shows them with signed URLs.
-- Employees can see photos. They cannot add, replace, or archive them.
-- Photos are part of the fabric record Elaine keeps, not a usage log.
-- Archive a photo instead of deleting it.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'material-photos',
  'material-photos',
  false,
  1048576,
  array['image/jpeg', 'image/webp']
)
on conflict (id) do update
set
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists material_photos_storage_read on storage.objects;
create policy material_photos_storage_read
  on storage.objects
  for select
  to authenticated
  using (bucket_id = 'material-photos');

drop policy if exists material_photos_storage_insert on storage.objects;
create policy material_photos_storage_insert
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'material-photos'
    and (select private.can_edit_inventory())
  );

drop policy if exists material_photos_storage_update on storage.objects;
create policy material_photos_storage_update
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'material-photos'
    and (select private.can_edit_inventory())
  )
  with check (
    bucket_id = 'material-photos'
    and (select private.can_edit_inventory())
  );

create table public.material_photos (
  id bigint generated always as identity primary key,
  material_id bigint not null references public.materials (id),
  storage_path text not null unique,
  is_primary boolean not null default false,
  caption text,
  taken_by uuid references public.profiles (id),
  created_at timestamptz not null default now(),
  archived_at timestamptz,
  constraint material_photos_path_check check (
    storage_path !~ '\.\.'
    and char_length(storage_path) between 3 and 300
  ),
  constraint material_photos_caption_check check (
    caption is null or char_length(caption) <= 200
  )
);

comment on table public.material_photos is
  'Photos of a fabric. storage_path is the full image in the private material-photos bucket. A thumbnail is the same path with -thumb before the extension. Signed-in people can view. Owners and the production manager can add, replace, choose the primary, and archive.';

create unique index material_photos_one_primary_idx
  on public.material_photos (material_id)
  where is_primary and archived_at is null;

create index material_photos_material_id_idx
  on public.material_photos (material_id)
  where archived_at is null;

create or replace function private.material_photos_one_primary()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' and new.taken_by is distinct from old.taken_by then
    raise exception 'The person who took the photo stays on the record'
      using errcode = '42501';
  end if;

  if new.is_primary and new.archived_at is null then
    update public.material_photos
    set is_primary = false
    where material_id = new.material_id
      and id is distinct from new.id
      and is_primary
      and archived_at is null;
  end if;

  if new.archived_at is not null then
    new.is_primary := false;
  end if;

  return new;
end;
$$;

revoke all on function private.material_photos_one_primary() from public, anon;
grant execute on function private.material_photos_one_primary() to authenticated, service_role;

create trigger material_photos_one_primary
  before insert or update on public.material_photos
  for each row execute function private.material_photos_one_primary();

create trigger material_photos_audit
  after insert or update or delete on public.material_photos
  for each row execute function private.audit_row();

create or replace function private.reject_material_photo_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Archive a photo. It cannot be deleted.'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_material_photo_delete() from public, anon;
grant execute on function private.reject_material_photo_delete() to authenticated, service_role;

create trigger material_photos_reject_delete
  before delete on public.material_photos
  for each row execute function private.reject_material_photo_delete();

revoke all on table public.material_photos from public, anon, authenticated;
grant select, insert, update on table public.material_photos to authenticated;
grant select, insert, update, delete on table public.material_photos to service_role;

alter table public.material_photos enable row level security;

create policy material_photos_select
  on public.material_photos
  for select
  to authenticated
  using (true);

create policy material_photos_insert
  on public.material_photos
  for insert
  to authenticated
  with check (
    (select private.can_edit_inventory())
    and taken_by = (select auth.uid())
  );

create policy material_photos_update
  on public.material_photos
  for update
  to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));
