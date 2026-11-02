-- Quiet hours. Notices outside a person's window wait in pending_notifications
-- until the next open minute. The master switch still blocks the flush.

alter table public.push_preferences
  add column quiet_start time not null default time '08:00',
  add column quiet_end time not null default time '21:00',
  add column time_zone text not null default 'America/Toronto',
  add column urgent_bypass boolean not null default false;

alter table public.push_preferences
  add constraint push_preferences_zone_check check (
    char_length(time_zone) between 3 and 64
  );

comment on column public.push_preferences.quiet_start is
  'Local time when notices may start. Default 8:00 AM.';
comment on column public.push_preferences.quiet_end is
  'Local time when notices stop. Default 9:00 PM. An earlier end means the window crosses midnight.';
comment on column public.push_preferences.urgent_bypass is
  'When on, an urgent announcement can arrive outside the window. Off by default.';

alter table public.notification_log
  drop constraint notification_log_status_check;

alter table public.notification_log
  add constraint notification_log_status_check check (
    status in ('sent', 'skipped', 'failed', 'revoked', 'queued')
  );

create table public.pending_notifications (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles (id),
  event_kind text not null,
  title text not null,
  body text not null,
  url text,
  urgent boolean not null default false,
  deliver_at timestamptz not null,
  created_at timestamptz not null default now(),
  created_by uuid references public.profiles (id),
  sent_at timestamptz,
  constraint pending_notifications_kind_check check (
    event_kind in (
      'shift_changes',
      'task_assigned',
      'alteration_due',
      'announcements'
    )
  ),
  constraint pending_notifications_title_check check (
    char_length(title) between 1 and 80
  ),
  constraint pending_notifications_body_check check (
    char_length(body) between 1 and 200
  ),
  constraint pending_notifications_url_check check (
    url is null or (url like '/%' and char_length(url) <= 300)
  )
);

comment on table public.pending_notifications is
  'Pushes waiting for a person''s next open window. Delivered as one summary when several are due. Not deleted.';

create index pending_notifications_user_idx
  on public.pending_notifications (user_id);

create index pending_notifications_due_idx
  on public.pending_notifications (deliver_at)
  where sent_at is null;

create index pending_notifications_created_by_idx
  on public.pending_notifications (created_by);

create trigger pending_notifications_reject_delete
  before delete on public.pending_notifications
  for each row execute function private.reject_push_delete();

revoke all on table public.pending_notifications from public, anon, authenticated;
grant select, insert on table public.pending_notifications to authenticated;
grant select, insert, update, delete on table public.pending_notifications to service_role;

alter table public.pending_notifications enable row level security;

create policy pending_notifications_select
  on public.pending_notifications for select to authenticated
  using (
    user_id = (select auth.uid())
    or (select private.is_owner())
  );

create policy pending_notifications_insert
  on public.pending_notifications for insert to authenticated
  with check (
    created_by = (select auth.uid())
    and (
      (select private.is_owner())
      or (select private.is_production_manager())
      or (select private.can_update_order_status())
    )
  );

-- The sender may read the recipient's window. Other staff cannot.
create or replace function public.push_quiet_window(recipient uuid)
returns table (
  quiet_start time,
  quiet_end time,
  time_zone text,
  urgent_bypass boolean
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null or recipient is null then
    return;
  end if;
  if recipient is distinct from (select auth.uid())
    and not (select private.is_owner())
    and not (select private.is_production_manager())
    and not (select private.can_update_order_status())
  then
    return;
  end if;

  return query
  select
    coalesce(prefs.quiet_start, time '08:00'),
    coalesce(prefs.quiet_end, time '21:00'),
    coalesce(prefs.time_zone, 'America/Toronto'),
    coalesce(prefs.urgent_bypass, false)
  from public.push_preferences prefs
  where prefs.user_id = recipient;

  if not found then
    return query
    select time '08:00', time '21:00', 'America/Toronto'::text, false;
  end if;
end;
$$;

revoke all on function public.push_quiet_window(uuid) from public, anon;
grant execute on function public.push_quiet_window(uuid) to authenticated, service_role;
