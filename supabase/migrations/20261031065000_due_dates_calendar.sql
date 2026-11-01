-- Due date, event date, and a target date for each production step.
-- Directors only see dates on orders their program link already allows.

alter table public.costume_orders
  add column due_on date,
  add column event_on date;

comment on column public.costume_orders.due_on is
  'Date the costumes are due.';

comment on column public.costume_orders.event_on is
  'Competition or event date.';

create table public.order_milestones (
  id bigint generated always as identity primary key,
  order_id bigint not null references public.costume_orders (id),
  production_status text not null,
  target_on date not null,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  unique (order_id, production_status),
  constraint order_milestones_status_check check (
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
  )
);

comment on table public.order_milestones is
  'Target date for a production step. Archive instead of deleting.';

create index order_milestones_order_idx
  on public.order_milestones (order_id)
  where archived_at is null;

create or replace function private.reject_milestone_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Archive a milestone. It cannot be deleted.'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_milestone_delete() from public, anon;
grant execute on function private.reject_milestone_delete() to authenticated, service_role;

create trigger order_milestones_reject_delete
  before delete on public.order_milestones
  for each row execute function private.reject_milestone_delete();

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

  if (
      new.due_on is distinct from old.due_on
      or new.event_on is distinct from old.event_on
    )
    and not private.can_update_order_status()
  then
    raise exception 'You cannot change the dates'
      using errcode = '42501';
  end if;

  if not private.can_edit_inventory()
    and (
      to_jsonb(new)
        - 'production_status' - 'program_id' - 'due_on' - 'event_on' - 'updated_at'
      is distinct from
      to_jsonb(old)
        - 'production_status' - 'program_id' - 'due_on' - 'event_on' - 'updated_at'
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

revoke all on table public.order_milestones from public, anon, authenticated;
grant select, insert, update on table public.order_milestones to authenticated;

alter table public.order_milestones enable row level security;

create policy order_milestones_select
  on public.order_milestones for select to authenticated
  using (
    not (select private.is_program_director())
    or (select private.director_can_see_order(order_id))
  );

create policy order_milestones_insert
  on public.order_milestones for insert to authenticated
  with check ((select private.can_update_order_status()));

create policy order_milestones_update
  on public.order_milestones for update to authenticated
  using ((select private.can_update_order_status()))
  with check ((select private.can_update_order_status()));
