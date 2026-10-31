-- Low fabric. Available metres at or below the reorder point are low.
-- Unknown on-hand is never low. A blank reorder point uses the 2 m studio default.
-- One alert is queued when a signed-in person's stock change crosses from
-- above the point to at or below it. It stays quiet until the fabric is
-- above the point again. The tracker import has no user jwt, so replaying
-- history does not queue alerts.
-- The digest sender reads this table. It does not live in the database.

alter table public.inventory_settings
  add column low_stock_alert_to text not null default 'designstudio.dancebarre@gmail.com',
  add column low_stock_alert_from text not null default 'Dance Barre Design Studio <onboarding@resend.dev>';

alter table public.inventory_settings
  add constraint inventory_settings_alert_to_check check (
    char_length(low_stock_alert_to) between 3 and 200
    and low_stock_alert_to like '%@%'
    and low_stock_alert_to !~ '\s'
  ),
  add constraint inventory_settings_alert_from_check check (
    char_length(low_stock_alert_from) between 3 and 200
  );

comment on column public.inventory_settings.low_stock_alert_to is
  'Inbox for the low-fabric digest. The dev default is the studio Gmail.';

comment on column public.inventory_settings.low_stock_alert_from is
  'From address for Resend. onboarding@resend.dev is the shared dev sender. Production mail needs a domain verified in Resend.';

create or replace view public.material_availability
with (security_invoker = true) as
select
  s.material_id,
  s.material_code,
  s.on_hand_m,
  s.reserved_m,
  case
    when s.on_hand_m is null then null
    else s.on_hand_m - coalesce(s.reserved_m, 0)
  end as available_m,
  case
    when s.on_hand_m is null then false
    else (s.on_hand_m - coalesce(s.reserved_m, 0))
      <= coalesce(m.reorder_point_m, settings.low_stock_threshold_m)
  end as is_low_stock
from public.material_stock s
join public.materials m on m.id = s.material_id
cross join public.inventory_settings settings;

comment on view public.material_availability is
  'Available metres and the low-stock flag. Low means on-hand is known and available metres are at or below the reorder point. A blank reorder point uses the studio default. Unknown on-hand is never low.';

create table public.low_stock_alerts (
  id bigint generated always as identity primary key,
  material_id bigint not null references public.materials (id),
  available_m numeric(12, 4) not null,
  reorder_point_m numeric(12, 4) not null,
  created_at timestamptz not null default now(),
  sent_at timestamptz,
  status text not null default 'pending',
  constraint low_stock_alerts_status_check check (status in ('pending', 'sent')),
  constraint low_stock_alerts_sent_check check (
    (status = 'pending' and sent_at is null)
    or (status = 'sent' and sent_at is not null)
  )
);

comment on table public.low_stock_alerts is
  'One row each time available metres cross from above the reorder point to at or below it. Pending rows are sent together as one email.';

create index low_stock_alerts_pending_idx
  on public.low_stock_alerts (created_at)
  where status = 'pending';

create or replace function private.low_stock_note_before()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  available numeric;
begin
  if new.material_id is null or (select auth.uid()) is null then
    return new;
  end if;

  select availability.available_m
  into available
  from public.material_availability availability
  where availability.material_id = new.material_id;

  perform set_config(
    'app.low_stock_material',
    new.material_id::text,
    true
  );
  perform set_config(
    'app.low_stock_before',
    coalesce(available::text, ''),
    true
  );
  return new;
end;
$$;

create or replace function private.low_stock_queue_after()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  before_text text;
  before_m numeric;
  after_m numeric;
  point_m numeric;
begin
  if new.material_id is null or (select auth.uid()) is null then
    return new;
  end if;
  if new.material_id::text
    is distinct from current_setting('app.low_stock_material', true)
  then
    return new;
  end if;

  before_text := current_setting('app.low_stock_before', true);
  if before_text is null or before_text = '' then
    return new;
  end if;
  before_m := before_text::numeric;

  select
    availability.available_m,
    coalesce(material.reorder_point_m, settings.low_stock_threshold_m)
  into after_m, point_m
  from public.material_availability availability
  join public.materials material on material.id = availability.material_id
  cross join public.inventory_settings settings
  where availability.material_id = new.material_id;

  if after_m is null or point_m is null then
    return new;
  end if;

  if before_m > point_m and after_m <= point_m then
    insert into public.low_stock_alerts (
      material_id, available_m, reorder_point_m, status
    ) values (
      new.material_id, after_m, point_m, 'pending'
    );
  end if;

  return new;
end;
$$;

revoke all on function private.low_stock_note_before() from public, anon;
revoke all on function private.low_stock_queue_after() from public, anon;
grant execute on function private.low_stock_note_before() to authenticated, service_role;
grant execute on function private.low_stock_queue_after() to authenticated, service_role;

create trigger stock_transactions_low_stock_before
  before insert on public.stock_transactions
  for each row execute function private.low_stock_note_before();

create trigger stock_transactions_low_stock_after
  after insert on public.stock_transactions
  for each row execute function private.low_stock_queue_after();

revoke all on table public.low_stock_alerts from public, anon, authenticated;
grant select on table public.low_stock_alerts to authenticated;
grant select, insert, update on table public.low_stock_alerts to service_role;

alter table public.low_stock_alerts enable row level security;

create policy low_stock_alerts_select
  on public.low_stock_alerts
  for select
  to authenticated
  using ((select private.can_edit_inventory()));
