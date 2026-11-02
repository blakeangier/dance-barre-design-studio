-- Local seed, applied by `supabase db reset` only.
-- `supabase db push` does not run this file against the hosted project.
--
-- The two operating entities are inserted by the foundation migration.
-- Do not put pay rates, supplier prices, passwords, or other business facts here.
-- Anything added later for a demo must be labelled SAMPLE in the row itself.

-- SAMPLE staff shifts. Local reset only. No-op until a SAMPLE profile exists.
insert into public.staff_shifts (
  profile_id, shift_date, start_time, end_time, break_minutes, notes
)
select
  profile.id,
  current_date,
  time '09:00',
  time '15:00',
  30,
  'SAMPLE — not a real shift'
from public.profiles profile
where profile.full_name ilike 'SAMPLE%'
  and not exists (
    select 1
    from public.staff_shifts existing
    where existing.profile_id = profile.id
      and existing.notes = 'SAMPLE — not a real shift'
  );
