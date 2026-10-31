-- Fabric use. Employees log metres against a sample style or a production order.
-- A production use draws down that order's reservation so on-hand and reserved
-- both fall, and the same metres are not counted twice.
-- Waste is its own use row. A correction is a new adjusting entry that reverses
-- the original. The original row stays.
-- A photo on a use is stored in the private material-photos bucket under
-- usage/{person}/. It is not the fabric's registry photo, so the person logging
-- the use can upload it. Registry photos stay with owners and the production manager.
-- Re-running the tracker import still upserts: those statements have no user jwt.

alter table public.stock_transactions
  add column style_id bigint references public.styles (id),
  add column bom_line_id bigint references public.bom_lines (id),
  add column usage_kind text,
  add column is_waste boolean not null default false,
  add column reservation_drawdown_m numeric(12, 4),
  add column reverses_id bigint references public.stock_transactions (id),
  add column photo_path text,
  add column usage_group uuid;

alter table public.stock_transactions
  add constraint stock_transactions_usage_kind_check check (
    usage_kind is null or usage_kind in ('sample', 'production')
  ),
  add constraint stock_transactions_usage_shape_check check (
    usage_kind is null
    or (
      txn_type = 'use'
      and qty_m > 0
      and (
        (
          usage_kind = 'sample'
          and style_id is not null
          and order_id is null
          and bom_line_id is null
        )
        or (usage_kind = 'production' and order_id is not null)
      )
    )
  ),
  add constraint stock_transactions_drawdown_check check (
    reservation_drawdown_m is null or reservation_drawdown_m >= 0
  ),
  add constraint stock_transactions_photo_path_check check (
    photo_path is null
    or (
      photo_path !~ '\.\.'
      and char_length(photo_path) <= 300
      and photo_path ~* '^usage/[0-9a-f-]{36}/[0-9a-f-]{36}\.(webp|jpe?g)$'
    )
  );

comment on column public.stock_transactions.usage_kind is
  'sample is development fabric. production is a costume order. Null on older ledger rows.';

comment on column public.stock_transactions.is_waste is
  'True when the metres are waste or an offcut. The row is still a use, so it leaves on-hand.';

comment on column public.stock_transactions.reservation_drawdown_m is
  'Metres of this use taken from the order reservation. Capped at the metres still reserved. Sample use is 0. A reversing adjust copies the value so the reservation comes back.';

comment on column public.stock_transactions.reverses_id is
  'The use entry this adjust undoes. The original row is not edited.';

comment on column public.stock_transactions.photo_path is
  'Optional photo of this use in the private material-photos bucket.';

create index stock_transactions_style_id_idx
  on public.stock_transactions (style_id);

create index stock_transactions_usage_group_idx
  on public.stock_transactions (usage_group);

create unique index stock_transactions_one_reversal_idx
  on public.stock_transactions (reverses_id)
  where reverses_id is not null;

create or replace function private.guard_fabric_use()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  original public.stock_transactions%rowtype;
  gross numeric(12, 4);
  drawn numeric(12, 4);
begin
  if new.reverses_id is not null then
    if (select auth.uid()) is null then
      raise exception 'Sign in to correct an entry'
        using errcode = '42501';
    end if;

    select * into original
    from public.stock_transactions
    where id = new.reverses_id
    for update;

    if not found
      or original.txn_type <> 'use'
      or original.usage_kind is null
    then
      raise exception 'Only a logged fabric use can be reversed'
        using errcode = '42501';
    end if;

    if exists (
      select 1
      from public.stock_transactions earlier
      where earlier.reverses_id = original.id
    ) then
      raise exception 'This entry was already corrected'
        using errcode = '42501';
    end if;

    if not private.can_edit_inventory() then
      if original.created_by is distinct from (select auth.uid())
        or original.created_at < now() - interval '24 hours'
      then
        raise exception 'You can correct your own entry within 24 hours'
          using errcode = '42501';
      end if;
    end if;

    new.txn_type := 'adjust';
    new.material_id := original.material_id;
    new.qty_m := original.qty_m;
    new.reservation_drawdown_m := coalesce(original.reservation_drawdown_m, 0);
    new.order_id := original.order_id;
    new.style_id := original.style_id;
    new.bom_line_id := original.bom_line_id;
    new.usage_kind := null;
    new.is_waste := false;
    new.created_by := (select auth.uid());
    return new;
  end if;

  if new.usage_kind is null then
    if new.txn_type = 'use'
      and (select auth.uid()) is not null
      and not private.can_edit_inventory()
    then
      raise exception 'Say whether this is a sample or a production order'
        using errcode = '42501';
    end if;
    return new;
  end if;

  if new.txn_type <> 'use' then
    raise exception 'A sample or production entry is a use'
      using errcode = '42501';
  end if;

  if new.qty_m is null or new.qty_m <= 0 then
    raise exception 'Enter the metres used'
      using errcode = '42501';
  end if;

  if (select auth.uid()) is not null
    and not private.can_edit_inventory()
    and new.created_by is distinct from (select auth.uid())
  then
    raise exception 'Log use as yourself'
      using errcode = '42501';
  end if;

  if new.usage_kind = 'sample' then
    if new.style_id is null then
      raise exception 'Pick the style'
        using errcode = '42501';
    end if;
    new.order_id := null;
    new.bom_line_id := null;
    new.reservation_drawdown_m := 0;
  else
    if new.order_id is null then
      raise exception 'Pick the order'
        using errcode = '42501';
    end if;

    if new.style_id is not null and not exists (
      select 1
      from public.styles style
      where style.id = new.style_id
        and style.order_id = new.order_id
    ) then
      raise exception 'That style is not on this order'
        using errcode = '42501';
    end if;

    if new.bom_line_id is not null and not exists (
      select 1
      from public.bom_lines line
      where line.id = new.bom_line_id
        and line.order_id = new.order_id
    ) then
      raise exception 'That fabric line is not on this order'
        using errcode = '42501';
    end if;

    select
      coalesce(sum(entry.qty_m) filter (where entry.txn_type = 'reserve'), 0),
      coalesce(sum(entry.reservation_drawdown_m) filter (where entry.txn_type = 'use'), 0)
        - coalesce(sum(entry.reservation_drawdown_m) filter (
          where entry.txn_type = 'adjust' and entry.reverses_id is not null
        ), 0)
    into gross, drawn
    from public.stock_transactions entry
    where entry.material_id = new.material_id
      and entry.order_id = new.order_id;

    if gross > 0 then
      new.reservation_drawdown_m := least(
        new.qty_m,
        greatest(0, gross - drawn)
      );
    else
      new.reservation_drawdown_m := 0;
    end if;
  end if;

  if new.photo_path is not null
    and (
      new.photo_path !~* '^usage/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.(webp|jpe?g)$'
      or (
        (select auth.uid()) is not null
        and not private.can_edit_inventory()
        and lower(new.photo_path) not like 'usage/' || lower((select auth.uid())::text) || '/%'
      )
    )
  then
    raise exception 'That photo could not be stored'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

revoke all on function private.guard_fabric_use() from public, anon;
grant execute on function private.guard_fabric_use() to authenticated, service_role;

create trigger stock_transactions_guard_fabric_use
  before insert on public.stock_transactions
  for each row execute function private.guard_fabric_use();

create or replace function private.reject_stock_history_edit()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if (select auth.uid()) is not null then
    raise exception 'Stock history is kept. Correct a use with a reversing entry.'
      using errcode = '42501';
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

revoke all on function private.reject_stock_history_edit() from public, anon;
grant execute on function private.reject_stock_history_edit() to authenticated, service_role;

create trigger stock_transactions_reject_history_edit
  before update or delete on public.stock_transactions
  for each row execute function private.reject_stock_history_edit();

-- Reserved falls by the drawdown on a use, and rises again when that use is reversed.
-- Older rows have no drawdown, so their on-hand and reserved stay as they were.
create or replace view public.material_stock
with (security_invoker = true) as
select
  m.id as material_id,
  m.material_code,
  case
    when count(t.id) filter (
      where t.txn_type in ('receive', 'return', 'use', 'adjust')
        and t.qty_m is not null
    ) = 0 then null
    else
      coalesce(sum(t.qty_m) filter (
        where t.txn_type in ('receive', 'return') and t.qty_m is not null
      ), 0)
      - coalesce(sum(t.qty_m) filter (
        where t.txn_type = 'use' and t.qty_m is not null
      ), 0)
      + coalesce(sum(t.qty_m) filter (
        where t.txn_type = 'adjust' and t.qty_m is not null
      ), 0)
  end as on_hand_m,
  case
    when count(t.id) filter (
      where t.txn_type = 'reserve' and t.qty_m is not null
    ) = 0 then null
    else greatest(
      0,
      coalesce(sum(t.qty_m) filter (
        where t.txn_type = 'reserve' and t.qty_m is not null
      ), 0)
      - coalesce(sum(t.reservation_drawdown_m) filter (
        where t.txn_type = 'use'
      ), 0)
      + coalesce(sum(t.reservation_drawdown_m) filter (
        where t.txn_type = 'adjust' and t.reverses_id is not null
      ), 0)
    )
  end as reserved_m
from public.materials m
left join public.stock_transactions t on t.material_id = m.id
group by m.id, m.material_code;

comment on view public.material_stock is
  'On-hand and reserved metres from the ledger. A production use reduces reserved by its drawdown so those metres are not also held back from available.';

create policy stock_transactions_insert_reversal
  on public.stock_transactions for insert to authenticated
  with check (
    txn_type = 'adjust'
    and reverses_id is not null
    and created_by = (select auth.uid())
    and qty_m is not null
    and qty_m > 0
  );

drop policy if exists material_photos_storage_insert on storage.objects;
create policy material_photos_storage_insert
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'material-photos'
    and name !~ '\.\.'
    and (
      (select private.can_edit_inventory())
      or name like 'usage/' || (select auth.uid())::text || '/%'
    )
  );
