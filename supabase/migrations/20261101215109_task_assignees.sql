-- Any active profile can be assigned a task: owners, production managers,
-- payroll, employees, contractors, and program directors. Turned-off accounts
-- stay ineligible. A director still cannot create tasks, and still cannot
-- read a task unless they created it or it is assigned to them.

create or replace function private.can_read_task(creator uuid, assignee uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when (select private.is_owner())
      or (select private.is_production_manager()) then true
    else creator = (select auth.uid()) or assignee = (select auth.uid())
  end;
$$;

create or replace function private.guard_task()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := (select auth.uid());
  supervisor boolean := (select private.can_update_order_status());
begin
  if uid is null then
    return new;
  end if;

  if not exists (
    select 1
    from public.profiles
    where id = new.assigned_to
      and is_active
  ) then
    raise exception 'Assign this to someone who can sign in'
      using errcode = '42501';
  end if;

  if tg_op = 'INSERT' then
    if new.created_by is distinct from uid then
      raise exception 'A task is created by the signed-in person'
        using errcode = '42501';
    end if;
    if (select private.is_program_director()) then
      raise exception 'You cannot create a task'
        using errcode = '42501';
    end if;
    if not supervisor and new.assigned_to is distinct from uid then
      raise exception 'You can only create a task for yourself'
        using errcode = '42501';
    end if;
  else
    if new.created_by is distinct from old.created_by then
      raise exception 'The creator stays on the task'
        using errcode = '42501';
    end if;

    if supervisor or old.created_by = uid then
      null;
    elsif old.assigned_to = uid then
      if new.status = 'cancelled' then
        raise exception 'You cannot cancel this task'
          using errcode = '42501';
      end if;
      if new.status not in ('to_do', 'in_progress', 'waiting', 'done') then
        raise exception 'You cannot change this task'
          using errcode = '42501';
      end if;
      if new.assigned_to is distinct from old.assigned_to
        or new.title is distinct from old.title
        or new.description is distinct from old.description
        or new.order_id is distinct from old.order_id
        or new.style_id is distinct from old.style_id
        or new.material_id is distinct from old.material_id
        or new.due_on is distinct from old.due_on
        or new.priority is distinct from old.priority
        or (
          new.waiting_reason is distinct from old.waiting_reason
          and new.status is distinct from 'waiting'
        )
      then
        raise exception 'You can change the status only'
          using errcode = '42501';
      end if;
    else
      raise exception 'You cannot change this task'
        using errcode = '42501';
    end if;
  end if;

  if new.status = 'done' and (tg_op = 'INSERT' or old.status is distinct from 'done') then
    new.done_at := now();
  elsif new.status is distinct from 'done' then
    new.done_at := null;
  end if;

  if new.status = 'cancelled' and (tg_op = 'INSERT' or old.status is distinct from 'cancelled') then
    new.cancelled_at := now();
  elsif new.status is distinct from 'cancelled' then
    new.cancelled_at := null;
  end if;

  return new;
end;
$$;
