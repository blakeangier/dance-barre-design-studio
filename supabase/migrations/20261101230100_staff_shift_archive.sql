-- Postgres checks the SELECT policy against the row an UPDATE stores when the
-- statement has a WHERE clause. Hiding every archived shift from editors made
-- archive fail. Editors may still read an archived shift; the week view asks
-- for archived_at is null. Everyone else still cannot see an archived shift.

drop policy if exists staff_shifts_select on public.staff_shifts;

create policy staff_shifts_select
  on public.staff_shifts for select to authenticated
  using (
    (
      profile_id = (select auth.uid())
      or (select private.can_read_all_staff_shifts())
    )
    and (
      archived_at is null
      or (select private.can_edit_staff_schedule())
    )
  );
