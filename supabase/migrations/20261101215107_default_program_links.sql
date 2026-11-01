-- New non-owner accounts start with every program checked and the account on.
-- Owners can uncheck programs afterward. This does not change who may read
-- orders: only a program director is limited by these rows, and a director
-- with no rows still sees no orders.
--
-- Safe to apply more than once. It only inserts missing links for profiles
-- that currently have none. It does not delete links, and it does not turn
-- an existing account back on.

create or replace function private.link_all_programs(target uuid)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.director_programs (profile_id, program_id)
  select target, program.id
  from public.programs program
  where not exists (
    select 1
    from public.director_programs existing
    where existing.profile_id = target
  )
  on conflict (profile_id, program_id) do nothing;
$$;

revoke all on function private.link_all_programs(uuid) from public, anon, authenticated;
grant execute on function private.link_all_programs(uuid) to service_role;

comment on function private.link_all_programs(uuid) is
  'Gives a profile every program when they have none. A partial set is left alone.';

create or replace function private.sync_profile_from_auth()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  meta jsonb := coalesce(new.raw_app_meta_data, '{}'::jsonb);
  new_role public.app_role := private.parse_role(meta->>'role');
  is_new boolean;
begin
  select not exists (
    select 1 from public.profiles where id = new.id
  ) into is_new;

  insert into public.profiles (
    id,
    full_name,
    role,
    can_purchase,
    can_update_order_status,
    is_active
  )
  values (
    new.id,
    coalesce(meta->>'full_name', ''),
    new_role,
    private.parse_bool(meta->>'can_purchase', false),
    private.parse_bool(meta->>'can_update_order_status', false),
    true
  )
  on conflict (id) do update
    set role = excluded.role,
        can_purchase = excluded.can_purchase,
        can_update_order_status = excluded.can_update_order_status,
        updated_at = now();

  insert into public.profile_contacts (profile_id, email)
  values (new.id, coalesce(new.email, ''))
  on conflict (profile_id) do update
    set email = excluded.email,
        updated_at = now();

  if is_new and new_role is distinct from 'owner'::public.app_role then
    perform private.link_all_programs(new.id);
  end if;

  return new;
end;
$$;

-- Existing non-owners with no program rows get every program.
-- Someone who already has one or more rows is not changed.
select private.link_all_programs(profile.id)
from public.profiles profile
where profile.role is distinct from 'owner'::public.app_role
  and not exists (
    select 1
    from public.director_programs existing
    where existing.profile_id = profile.id
  );
