-- A program director sees only orders in programs she is linked to.
-- No director_programs rows means no orders. An order with no program_id
-- is hidden from every director.
-- Owners, the production manager, and can_update_order_status may set the
-- program. That flag still cannot edit the rest of the order.

create or replace function private.director_can_see_order(target_order bigint)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    private.is_program_director()
    and exists (
      select 1
      from public.costume_orders costume_order
      join public.director_programs link
        on link.program_id = costume_order.program_id
      where costume_order.id = target_order
        and link.profile_id = (select auth.uid())
    );
$$;

comment on table public.director_programs is
  'Required scope. A program director with no rows here sees no orders. Orders with no program are hidden from every director.';

comment on column public.costume_orders.program_id is
  'Optional program. Null is visible to shop staff and to no program director.';

drop policy if exists programs_select on public.programs;
create policy programs_select
  on public.programs for select to authenticated
  using (
    not (select private.is_program_director())
    or exists (
      select 1
      from public.director_programs link
      where link.profile_id = (select auth.uid())
        and link.program_id = programs.id
    )
  );

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

  if not private.can_edit_inventory()
    and (
      to_jsonb(new) - 'production_status' - 'program_id' - 'updated_at'
      is distinct from
      to_jsonb(old) - 'production_status' - 'program_id' - 'updated_at'
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
  end if;

  return new;
end;
$$;
