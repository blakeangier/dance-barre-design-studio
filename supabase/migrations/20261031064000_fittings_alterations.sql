-- Fittings stay on the existing table. Dancer names are a first name and
-- one last initial. Alterations after delivery are a separate log.
-- Directors can read fittings on orders they can see.

alter table public.fittings
  add column dancer_label text,
  add column outcome text,
  add column fit_notes text,
  add column photo_path text,
  add column fitting_on date;

alter table public.fittings
  add constraint fittings_outcome_check check (
    outcome is null or outcome in ('approved', 'alter', 'remake')
  ),
  add constraint fittings_dancer_check check (
    dancer_label is null
    or dancer_label ~ '^[A-Za-z][A-Za-z'' -]{0,40} [A-Z]$'
  ),
  add constraint fittings_photo_check check (
    photo_path is null
    or photo_path ~* '^fittings/[0-9a-f-]{36}/[0-9a-f-]{36}\.(webp|jpe?g)$'
  );

comment on column public.fittings.dancer_label is
  'First name and last initial only, such as Ava M.';

create table public.alterations (
  id bigint generated always as identity primary key,
  order_id bigint not null references public.costume_orders (id),
  style_id bigint references public.styles (id),
  fitting_id bigint references public.fittings (id),
  request text not null,
  asked_by text,
  assigned_to uuid references public.profiles (id),
  status text not null default 'open',
  done_on date,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  constraint alterations_status_check check (
    status in ('open', 'in_progress', 'done')
  ),
  constraint alterations_request_check check (char_length(btrim(request)) > 0)
);

comment on table public.alterations is
  'Work asked for after a costume is delivered. Archive instead of deleting.';

create index alterations_order_idx on public.alterations (order_id);

create or replace function private.reject_alteration_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Archive a fitting or alteration. It cannot be deleted.'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_alteration_delete() from public, anon;
grant execute on function private.reject_alteration_delete() to authenticated, service_role;

create trigger alterations_reject_delete
  before delete on public.alterations
  for each row execute function private.reject_alteration_delete();

revoke all on table public.alterations from public, anon, authenticated;
grant select, insert, update on table public.alterations to authenticated;

alter table public.alterations enable row level security;

drop policy if exists fittings_select on public.fittings;
create policy fittings_select
  on public.fittings for select to authenticated
  using (
    not (select private.is_program_director())
    or (
      order_id is not null
      and (select private.director_can_see_order(order_id))
    )
  );

drop policy if exists fitting_checks_select on public.fitting_checks;
create policy fitting_checks_select
  on public.fitting_checks for select to authenticated
  using (
    not (select private.is_program_director())
    or (
      order_id is not null
      and (select private.director_can_see_order(order_id))
    )
  );

create policy alterations_select
  on public.alterations for select to authenticated
  using (
    not (select private.is_program_director())
    or (select private.director_can_see_order(order_id))
  );

create policy alterations_insert
  on public.alterations for insert to authenticated
  with check ((select private.can_edit_inventory()));

create policy alterations_update
  on public.alterations for update to authenticated
  using ((select private.can_edit_inventory()))
  with check ((select private.can_edit_inventory()));
