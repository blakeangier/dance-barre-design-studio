-- Independent contractors are paid by e-transfer, not through payroll.
-- full-time and part-time stay as they are.
-- The hours export lives on the schedule branch. It must skip
-- employment_type = 'contractor' (see includeInPayrollExport).

alter table public.profiles
  drop constraint profiles_employment_type_check;

alter table public.profiles
  add constraint profiles_employment_type_check check (
    employment_type is null
    or employment_type in ('full-time', 'part-time', 'contractor')
  );

comment on column public.profiles.employment_type is
  'full-time, part-time, or contractor. A contractor is paid by e-transfer and is left out of the payroll hours export.';
