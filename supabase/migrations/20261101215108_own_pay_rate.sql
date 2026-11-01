-- The signed-in person may read their own pay rate. They still cannot insert
-- or update a rate: authenticated has no update grant, and insert stays with
-- owners and payroll. Owners and payroll_admin keep the policies they already
-- have. Timesheet reads are unchanged: a person already sees their own sheets,
-- and payroll still sees approved, sent, and processed sheets.
-- employee_private, cost_rates, and the finance tables are not touched.

create policy employee_compensation_select_self
  on public.employee_compensation
  for select
  to authenticated
  using (profile_id = (select auth.uid()));

comment on table public.employee_compensation is
  'Pay rates. Owners and payroll can read every row. The person can read their own rows and cannot change them. Append-only: corrections are new rows.';
