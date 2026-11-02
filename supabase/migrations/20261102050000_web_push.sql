-- Web Push subscriptions and the owner switch that keeps them quiet.
-- Nothing is delivered while push_settings.enabled is false.
-- Subscriptions are revoked, not deleted. The log is append-only.

create table public.push_settings (
  id integer primary key default 1,
  enabled boolean not null default false,
  notify_shift_changes boolean not null default true,
  notify_task_assigned boolean not null default true,
  notify_alteration_due boolean not null default true,
  notify_announcements boolean not null default true,
  updated_at timestamptz not null default now(),
  updated_by uuid references public.profiles (id),
  constraint push_settings_one_row check (id = 1)
);

comment on table public.push_settings is
  'One row. enabled is the master switch and starts off. The other columns are per-event switches.';

insert into public.push_settings (id, enabled) values (1, false);

create table public.push_preferences (
  user_id uuid primary key references public.profiles (id),
  shift_changes boolean not null default true,
  task_assigned boolean not null default true,
  alteration_due boolean not null default true,
  announcements boolean not null default true,
  updated_at timestamptz not null default now()
);

comment on table public.push_preferences is
  'What this person wants on their own phone. Missing row means all four are on.';

create table public.push_subscriptions (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles (id),
  endpoint text not null,
  keys jsonb not null,
  user_agent text,
  created_at timestamptz not null default now(),
  last_used_at timestamptz,
  revoked_at timestamptz,
  constraint push_subscriptions_endpoint_check check (
    endpoint like 'https://%'
    and char_length(endpoint) between 12 and 2000
  ),
  constraint push_subscriptions_keys_check check (
    keys ? 'p256dh'
    and keys ? 'auth'
    and char_length(keys->>'p256dh') between 8 and 300
    and char_length(keys->>'auth') between 8 and 300
  ),
  constraint push_subscriptions_agent_check check (
    user_agent is null or char_length(user_agent) <= 400
  ),
  constraint push_subscriptions_user_endpoint_key unique (user_id, endpoint)
);

comment on table public.push_subscriptions is
  'Browsers this person allowed to notify. Revoke a dead subscription. Do not delete it.';

create index push_subscriptions_user_idx
  on public.push_subscriptions (user_id)
  where revoked_at is null;

create table public.notification_log (
  id bigint generated always as identity primary key,
  event_kind text not null,
  recipient_id uuid references public.profiles (id),
  title text not null,
  body text not null,
  status text not null,
  detail text,
  created_at timestamptz not null default now(),
  created_by uuid references public.profiles (id),
  constraint notification_log_kind_check check (
    event_kind in (
      'shift_changes',
      'task_assigned',
      'alteration_due',
      'announcements'
    )
  ),
  constraint notification_log_status_check check (
    status in ('sent', 'skipped', 'failed', 'revoked')
  ),
  constraint notification_log_title_check check (
    char_length(title) between 1 and 80
  ),
  constraint notification_log_body_check check (
    char_length(body) between 1 and 200
  )
);

comment on table public.notification_log is
  'One row each time a push is sent, skipped, fails, or the browser subscription is revoked.';

create index notification_log_recipient_idx
  on public.notification_log (recipient_id);

create index notification_log_created_by_idx
  on public.notification_log (created_by);

create index notification_log_created_at_idx
  on public.notification_log (created_at desc);

create trigger push_settings_set_updated_at
  before update on public.push_settings
  for each row execute function private.set_updated_at();

create trigger push_preferences_set_updated_at
  before update on public.push_preferences
  for each row execute function private.set_updated_at();

create or replace function private.reject_push_delete()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Revoke a subscription or keep the log. These rows are not deleted.'
    using errcode = '42501';
end;
$$;

revoke all on function private.reject_push_delete() from public, anon;
grant execute on function private.reject_push_delete() to authenticated, service_role;

create trigger push_subscriptions_reject_delete
  before delete on public.push_subscriptions
  for each row execute function private.reject_push_delete();

create trigger notification_log_reject_delete
  before delete on public.notification_log
  for each row execute function private.reject_push_delete();

create trigger notification_log_reject_update
  before update on public.notification_log
  for each row execute function private.reject_push_delete();

revoke all on table public.push_settings from public, anon, authenticated;
grant select, update on table public.push_settings to authenticated;
grant select, insert, update, delete on table public.push_settings to service_role;

revoke all on table public.push_preferences from public, anon, authenticated;
grant select, insert, update on table public.push_preferences to authenticated;
grant select, insert, update, delete on table public.push_preferences to service_role;

revoke all on table public.push_subscriptions from public, anon, authenticated;
grant select, insert, update on table public.push_subscriptions to authenticated;
grant select, insert, update, delete on table public.push_subscriptions to service_role;

revoke all on table public.notification_log from public, anon, authenticated;
grant select, insert on table public.notification_log to authenticated;
grant select, insert, update, delete on table public.notification_log to service_role;

alter table public.push_settings enable row level security;
alter table public.push_preferences enable row level security;
alter table public.push_subscriptions enable row level security;
alter table public.notification_log enable row level security;

create policy push_settings_select
  on public.push_settings for select to authenticated
  using (true);

create policy push_settings_update
  on public.push_settings for update to authenticated
  using ((select private.is_owner()))
  with check ((select private.is_owner()));

create policy push_preferences_select
  on public.push_preferences for select to authenticated
  using (user_id = (select auth.uid()));

create policy push_preferences_insert
  on public.push_preferences for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy push_preferences_update
  on public.push_preferences for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy push_subscriptions_select
  on public.push_subscriptions for select to authenticated
  using (user_id = (select auth.uid()));

create policy push_subscriptions_insert
  on public.push_subscriptions for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy push_subscriptions_update
  on public.push_subscriptions for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy notification_log_select
  on public.notification_log for select to authenticated
  using (
    (select private.is_owner())
    or (select private.is_production_manager())
  );

create policy notification_log_insert
  on public.notification_log for insert to authenticated
  with check (
    created_by = (select auth.uid())
    and (
      (select private.is_owner())
      or (select private.is_production_manager())
      or (select private.can_update_order_status())
    )
  );

-- Endpoints stay hidden unless this person may notify the recipient,
-- and unless the master switch is on.
create or replace function public.push_targets(recipient uuid, event_kind text)
returns table (
  subscription_id bigint,
  endpoint text,
  p256dh text,
  auth_key text
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  master_on boolean := false;
  event_on boolean := false;
  user_on boolean := true;
  allowed boolean := false;
begin
  if (select auth.uid()) is null or recipient is null then
    return;
  end if;

  if event_kind = 'announcements' or event_kind = 'shift_changes' then
    allowed :=
      (select private.is_owner())
      or (select private.is_production_manager());
  elsif event_kind = 'task_assigned' then
    allowed := (select private.can_update_order_status());
  elsif event_kind = 'alteration_due' then
    allowed := (select private.can_edit_inventory());
  else
    return;
  end if;

  if not allowed then
    return;
  end if;

  select
    settings.enabled,
    case event_kind
      when 'shift_changes' then settings.notify_shift_changes
      when 'task_assigned' then settings.notify_task_assigned
      when 'alteration_due' then settings.notify_alteration_due
      when 'announcements' then settings.notify_announcements
      else false
    end
  into master_on, event_on
  from public.push_settings settings
  where settings.id = 1;

  if coalesce(master_on, false) is not true or coalesce(event_on, false) is not true then
    return;
  end if;

  select
    case event_kind
      when 'shift_changes' then prefs.shift_changes
      when 'task_assigned' then prefs.task_assigned
      when 'alteration_due' then prefs.alteration_due
      when 'announcements' then prefs.announcements
      else true
    end
  into user_on
  from public.push_preferences prefs
  where prefs.user_id = recipient;

  if user_on is false then
    return;
  end if;

  return query
  select
    sub.id,
    sub.endpoint,
    sub.keys->>'p256dh',
    sub.keys->>'auth'
  from public.push_subscriptions sub
  where sub.user_id = recipient
    and sub.revoked_at is null;
end;
$$;

revoke all on function public.push_targets(uuid, text) from public, anon;
grant execute on function public.push_targets(uuid, text) to authenticated, service_role;

create or replace function public.revoke_push_subscription(subscription_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    return;
  end if;
  if not (
    (select private.is_owner())
    or (select private.is_production_manager())
    or (select private.can_update_order_status())
  ) then
    return;
  end if;

  update public.push_subscriptions
  set revoked_at = now()
  where id = subscription_id
    and revoked_at is null;
end;
$$;

revoke all on function public.revoke_push_subscription(bigint) from public, anon;
grant execute on function public.revoke_push_subscription(bigint) to authenticated, service_role;

create or replace function public.touch_push_subscription(subscription_id bigint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    return;
  end if;
  if not (
    (select private.is_owner())
    or (select private.is_production_manager())
    or (select private.can_update_order_status())
  ) then
    return;
  end if;

  update public.push_subscriptions
  set last_used_at = now()
  where id = subscription_id
    and revoked_at is null;
end;
$$;

revoke all on function public.touch_push_subscription(bigint) from public, anon;
grant execute on function public.touch_push_subscription(bigint) to authenticated, service_role;
