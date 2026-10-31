-- Job details coworkers may see, and home/emergency details they may not.
-- Do not load staff rows in this migration. Blake will enter those.

alter table public.profiles
  add column job_title text,
  add column employment_type text,
  add column start_date date,
  add column start_note text,
  add column pronouns text;

alter table public.profiles
  add constraint profiles_job_title_length_check
    check (job_title is null or char_length(job_title) <= 80),
  add constraint profiles_employment_type_check
    check (
      employment_type is null
      or employment_type in ('full-time', 'part-time')
    ),
  add constraint profiles_start_note_length_check
    check (start_note is null or char_length(start_note) <= 400),
  add constraint profiles_pronouns_length_check
    check (pronouns is null or char_length(pronouns) <= 40);

comment on column public.profiles.job_title is
  'Visible to every signed-in person, with the name.';
comment on column public.profiles.employment_type is
  'full-time or part-time, or blank.';
comment on column public.profiles.start_date is
  'First day. Visible with the name and title.';
comment on column public.profiles.start_note is
  'A note about the start date, such as a season, when the date is not a single day.';
comment on column public.profiles.pronouns is
  'Shown next to the name. The person or an owner may set this.';

comment on table public.profiles is
  'Name, role, title, and pronouns for coworkers. Home address and emergency contacts are in employee_private. Pay is in employee_compensation. Login email is in profile_contacts.';

-- Owners edit job details. Anyone may edit their own pronouns.
-- The trigger below stops everyone else from changing job details.
grant update (
  job_title,
  employment_type,
  start_date,
  start_note,
  pronouns
) on table public.profiles to authenticated;

create or replace function private.protect_profile_privileges()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  claims text := nullif(current_setting('request.jwt.claims', true), '');
  jwt_role text := '';
begin
  if claims is not null then
    jwt_role := coalesce(claims::jsonb ->> 'role', '');
  end if;
  if jwt_role = 'service_role' or jwt_role = '' then
    return new;
  end if;

  if new.id is distinct from old.id then
    raise exception 'You cannot change account identity'
      using errcode = '42501';
  end if;

  if new.role is distinct from old.role or new.can_purchase is distinct from old.can_purchase then
    if auth.uid() = old.id then
      raise exception 'You cannot change your own role or purchasing access'
        using errcode = '42501';
    end if;

    if not private.is_owner() then
      raise exception 'Only an owner can change role or purchasing access'
        using errcode = '42501';
    end if;
  end if;

  if new.is_active is distinct from old.is_active then
    if auth.uid() = old.id then
      raise exception 'You cannot turn off your own account'
        using errcode = '42501';
    end if;

    if not private.is_owner() then
      raise exception 'Only an owner can turn an account on or off'
        using errcode = '42501';
    end if;
  end if;

  if new.job_title is distinct from old.job_title
    or new.employment_type is distinct from old.employment_type
    or new.start_date is distinct from old.start_date
    or new.start_note is distinct from old.start_note
  then
    if not private.is_owner() then
      raise exception 'Only an owner can change job details'
        using errcode = '42501';
    end if;
  end if;

  if new.pronouns is distinct from old.pronouns
    and auth.uid() is distinct from old.id
    and not private.is_owner()
  then
    raise exception 'You can change only your own pronouns'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

-- Login email stays on the auth account. A signed-in person may update phone only.
revoke update on table public.profile_contacts from authenticated;
grant update (phone) on table public.profile_contacts to authenticated;

create or replace function private.protect_contact_details()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  claims text := nullif(current_setting('request.jwt.claims', true), '');
  jwt_role text := '';
begin
  if claims is not null then
    jwt_role := coalesce(claims::jsonb ->> 'role', '');
  end if;

  if jwt_role = 'service_role' or jwt_role = '' then
    return new;
  end if;

  if new.profile_id is distinct from old.profile_id or new.email is distinct from old.email then
    raise exception 'You cannot change the login email'
      using errcode = '42501';
  end if;

  return new;
end;
$$;

comment on function private.protect_contact_details() is
  'Signed-in users may change phone only. Login email is copied from Auth.';

create table public.employee_private (
  profile_id uuid primary key references public.profiles (id) on delete cascade,
  street text,
  city text,
  province text,
  postal_code text,
  personal_email text,
  emergency_name text,
  emergency_relationship text,
  emergency_phone text,
  updated_at timestamptz not null default now(),
  constraint employee_private_street_length_check
    check (street is null or char_length(street) <= 200),
  constraint employee_private_city_length_check
    check (city is null or char_length(city) <= 80),
  constraint employee_private_province_length_check
    check (province is null or char_length(province) <= 40),
  constraint employee_private_postal_length_check
    check (postal_code is null or char_length(postal_code) <= 16),
  constraint employee_private_personal_email_check
    check (
      personal_email is null
      or (
        position('@' in personal_email) > 1
        and char_length(personal_email) <= 200
      )
    ),
  constraint employee_private_emergency_name_length_check
    check (emergency_name is null or char_length(emergency_name) <= 120),
  constraint employee_private_emergency_relationship_length_check
    check (
      emergency_relationship is null
      or char_length(emergency_relationship) <= 80
    ),
  constraint employee_private_emergency_phone_length_check
    check (emergency_phone is null or char_length(emergency_phone) <= 40)
);

comment on table public.employee_private is
  'Home address, personal email, and emergency contact. Owners, payroll, and the person. Not the production manager.';

create trigger employee_private_set_updated_at
  before update on public.employee_private
  for each row
  execute function private.set_updated_at();

create trigger employee_private_audit
  after insert or update or delete on public.employee_private
  for each row
  execute function private.audit_row();

revoke all on table public.employee_private from public, anon, authenticated;
grant select, insert, update on table public.employee_private to authenticated;
grant select, insert, update, delete on table public.employee_private to service_role;

alter table public.employee_private enable row level security;

create policy employee_private_select
  on public.employee_private
  for select
  to authenticated
  using (
    profile_id = (select auth.uid())
    or (select private.is_owner())
    or (select private.is_payroll_admin())
  );

create policy employee_private_insert
  on public.employee_private
  for insert
  to authenticated
  with check (
    profile_id = (select auth.uid())
    or (select private.is_owner())
    or (select private.is_payroll_admin())
  );

create policy employee_private_update
  on public.employee_private
  for update
  to authenticated
  using (
    profile_id = (select auth.uid())
    or (select private.is_owner())
    or (select private.is_payroll_admin())
  )
  with check (
    profile_id = (select auth.uid())
    or (select private.is_owner())
    or (select private.is_payroll_admin())
  );

-- Payroll can read the history of this table. Owners already see every audit row.
drop policy if exists audit_log_select_limited on public.audit_log;
create policy audit_log_select_limited
  on public.audit_log
  for select
  to authenticated
  using (
    (select private.is_owner())
    or (
      (select private.is_payroll_admin())
      and table_name in ('employee_compensation', 'employee_private')
    )
    or (
      (
        (select private.has_purchasing())
        or (select private.is_production_manager())
      )
      and table_name in (
        'supplier_prices',
        'material_costs',
        'purchase_line_prices',
        'bom_costs'
      )
    )
    or (
      (select private.is_production_manager())
      and table_name in ('supplier_contacts', 'order_private')
    )
    or (
      (
        (select private.is_payroll_admin())
        or (select private.is_production_manager())
      )
      and table_name = 'profile_contacts'
    )
  );
