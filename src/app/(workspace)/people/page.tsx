import { Suspense } from "react";
import { updateAccess } from "@/app/(workspace)/people/actions";
import {
  saveEmployeePrivate,
  saveJobDetails,
} from "@/app/(workspace)/records/staff-actions";
import { ShowArchived } from "@/components/records/show-archived";
import { firstQueryValue, noticeText } from "@/lib/auth/notices";
import {
  ROLE_LABELS,
  ROLES,
  canSeeStaffPrivate,
  type AppRole,
} from "@/lib/auth/permissions";
import {
  EDIT_NOTICES,
  EMPLOYMENT_TYPES,
  employmentTypeLabel,
} from "@/lib/records/edit";
import { ROLE_BADGE } from "@/lib/brand";
import { gateArea } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";

export const metadata = {
  title: "People",
};

type PeopleProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type PersonRow = {
  id: string;
  email: string;
  full_name: string;
  role: AppRole;
  can_purchase: boolean;
  is_active: boolean;
  job_title: string | null;
  employment_type: string | null;
  start_date: string | null;
  start_note: string | null;
  pronouns: string | null;
};

type PrivateRow = {
  profile_id: string;
  street: string | null;
  city: string | null;
  province: string | null;
  postal_code: string | null;
  personal_email: string | null;
  emergency_name: string | null;
  emergency_relationship: string | null;
  emergency_phone: string | null;
};

type ContactRow = {
  profile_id: string;
  email: string;
};

export default function PeoplePage(props: PeopleProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <PeopleScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function PeopleScreen({
  searchParams,
}: {
  searchParams: PeopleProps["searchParams"];
}) {
  const gate = await gateArea("people");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;

  const params = await searchParams;
  const showArchived = firstQueryValue(params.archived) === "1";
  const noticeCode = firstQueryValue(params.notice);
  const notice =
    noticeText(noticeCode) ?? EDIT_NOTICES[noticeCode ?? ""]?.text ?? null;
  const supabase = await createClient();
  const seesPrivate = canSeeStaffPrivate(gate.profile);
  let peopleQuery = supabase
    .from("profiles")
    .select(
      "id, full_name, role, can_purchase, is_active, job_title, employment_type, start_date, start_note, pronouns",
    )
    .order("full_name");
  if (!showArchived) peopleQuery = peopleQuery.eq("is_active", true);
  const [peopleResult, contactsResult, privateResult] = await Promise.all([
    peopleQuery,
    supabase.from("profile_contacts").select("profile_id, email"),
    seesPrivate
      ? supabase
          .from("employee_private")
          .select(
            "profile_id, street, city, province, postal_code, personal_email, emergency_name, emergency_relationship, emergency_phone",
          )
      : Promise.resolve({ data: [] }),
  ]);

  const contacts = new Map(
    ((contactsResult.data ?? []) as ContactRow[]).map((contact) => [
      contact.profile_id,
      contact,
    ]),
  );
  const people: PersonRow[] = (
    (peopleResult.data ?? []) as Omit<PersonRow, "email">[]
  ).map((person) => ({
    ...person,
    email: contacts.get(person.id)?.email ?? "",
  }));
  const privates = new Map(
    ((privateResult.data ?? []) as PrivateRow[]).map((row) => [
      row.profile_id,
      row,
    ]),
  );
  const error = peopleResult.error;
  const isOwner = gate.profile.role === "owner";

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="font-serif text-3xl text-ink">People</h1>
        <p className="mt-2 max-w-prose text-sm leading-relaxed text-muted">
          New accounts are created with the setup script, not from this screen.
          {isOwner
            ? " You can change someone else's name, role, title, and pronouns here. You cannot change your own access."
            : " Role and job details are limited to owners."}{" "}
          Home address and emergency contacts are for owners and payroll.
          Turned-off accounts stay hidden until you show archived.
        </p>
      </div>
      <ShowArchived checked={showArchived} />
      {notice ? <StatusNote>{notice}</StatusNote> : null}
      {error ? (
        <p className="text-sm text-muted">The people list did not load.</p>
      ) : (
        <ul className="flex flex-col gap-3">
          {people.map((person) => (
            <li
              key={person.id}
              className="rounded-2xl border border-line bg-card p-4"
            >
              <p className="font-medium">
                {person.full_name || "Unnamed"}
                {person.pronouns ? ` (${person.pronouns})` : ""}
                {!person.is_active ? " (off)" : ""}
              </p>
              {person.job_title ? (
                <p className="text-sm text-ink">{person.job_title}</p>
              ) : null}
              <p className="text-sm text-muted">
                {[
                  employmentTypeLabel(person.employment_type),
                  person.start_date,
                  person.start_note,
                ]
                  .filter(Boolean)
                  .join(" · ")}
              </p>
              <p className="text-sm text-muted">{person.email}</p>
              <p className="mt-2 flex flex-wrap gap-1">
                <span
                  className={`rounded-full px-2 py-0.5 text-xs font-medium ${ROLE_BADGE[person.role]}`}
                >
                  {ROLE_LABELS[person.role]}
                </span>
                {person.can_purchase ? (
                  <span className="rounded-full border border-purple bg-card px-2 py-0.5 text-xs font-medium text-ink">
                    Purchasing
                  </span>
                ) : null}
              </p>
              {isOwner && person.id !== gate.profile.id ? (
                <form
                  action={updateAccess}
                  className="mt-3 flex flex-col gap-3"
                >
                  <input type="hidden" name="profileId" value={person.id} />
                  <label
                    className="text-sm font-medium"
                    htmlFor={`name-${person.id}`}
                  >
                    Name
                  </label>
                  <input
                    id={`name-${person.id}`}
                    name="fullName"
                    required
                    maxLength={120}
                    defaultValue={person.full_name}
                    className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
                  />
                  <label
                    className="text-sm font-medium"
                    htmlFor={`role-${person.id}`}
                  >
                    Role
                  </label>
                  <select
                    id={`role-${person.id}`}
                    name="role"
                    defaultValue={person.role}
                    className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
                  >
                    {ROLES.map((role) => (
                      <option key={role} value={role}>
                        {ROLE_LABELS[role]}
                      </option>
                    ))}
                  </select>
                  <label className="flex min-h-11 items-center gap-2 text-sm">
                    <input
                      type="checkbox"
                      name="canPurchase"
                      defaultChecked={person.can_purchase}
                    />
                    Can purchase outside costumes and dancewear
                  </label>
                  <label className="flex min-h-11 items-center gap-2 text-sm">
                    <input
                      type="checkbox"
                      name="isActive"
                      defaultChecked={person.is_active}
                    />
                    Account is on
                  </label>
                  <button
                    type="submit"
                    className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
                  >
                    Save access
                  </button>
                </form>
              ) : null}
              {isOwner && person.id === gate.profile.id ? (
                <p className="mt-3 text-sm text-muted">
                  Ask the other owner to change your access. You can still set
                  your own job details below.
                </p>
              ) : null}
              {isOwner ? (
                <form
                  action={saveJobDetails}
                  className="mt-3 flex flex-col gap-3"
                >
                  <input type="hidden" name="profileId" value={person.id} />
                  <label
                    className="text-sm font-medium"
                    htmlFor={`title-${person.id}`}
                  >
                    Job title
                  </label>
                  <input
                    id={`title-${person.id}`}
                    name="jobTitle"
                    maxLength={80}
                    defaultValue={person.job_title ?? ""}
                    className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
                  />
                  <label
                    className="text-sm font-medium"
                    htmlFor={`type-${person.id}`}
                  >
                    Employment type
                  </label>
                  <select
                    id={`type-${person.id}`}
                    name="employmentType"
                    defaultValue={person.employment_type ?? ""}
                    className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
                  >
                    {EMPLOYMENT_TYPES.map((type) => (
                      <option key={type.label} value={type.value}>
                        {type.label}
                      </option>
                    ))}
                  </select>
                  <label
                    className="text-sm font-medium"
                    htmlFor={`start-${person.id}`}
                  >
                    Start date
                  </label>
                  <input
                    id={`start-${person.id}`}
                    name="startDate"
                    type="date"
                    defaultValue={person.start_date ?? ""}
                    className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
                  />
                  <label
                    className="text-sm font-medium"
                    htmlFor={`start-note-${person.id}`}
                  >
                    Start note
                  </label>
                  <input
                    id={`start-note-${person.id}`}
                    name="startNote"
                    maxLength={400}
                    defaultValue={person.start_note ?? ""}
                    className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
                  />
                  <label
                    className="text-sm font-medium"
                    htmlFor={`pronouns-${person.id}`}
                  >
                    Pronouns
                  </label>
                  <input
                    id={`pronouns-${person.id}`}
                    name="pronouns"
                    maxLength={40}
                    defaultValue={person.pronouns ?? ""}
                    className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
                  />
                  <button
                    type="submit"
                    className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
                  >
                    Save job details
                  </button>
                </form>
              ) : null}
              {seesPrivate ? (
                <PrivateForm
                  personId={person.id}
                  row={privates.get(person.id)}
                />
              ) : null}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

function PrivateForm({
  personId,
  row,
}: {
  personId: string;
  row: PrivateRow | undefined;
}) {
  return (
    <form
      action={saveEmployeePrivate}
      className="mt-3 flex flex-col gap-3 border-t border-line pt-3"
    >
      <h2 className="font-serif text-xl text-ink">Private details</h2>
      <input type="hidden" name="profileId" value={personId} />
      <input type="hidden" name="next" value="/people" />
      <label className="text-sm font-medium" htmlFor={`street-${personId}`}>
        Street
      </label>
      <input
        id={`street-${personId}`}
        name="street"
        autoComplete="street-address"
        defaultValue={row?.street ?? ""}
        className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
      />
      <label className="text-sm font-medium" htmlFor={`city-${personId}`}>
        City
      </label>
      <input
        id={`city-${personId}`}
        name="city"
        autoComplete="address-level2"
        defaultValue={row?.city ?? ""}
        className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
      />
      <label className="text-sm font-medium" htmlFor={`province-${personId}`}>
        Province
      </label>
      <input
        id={`province-${personId}`}
        name="province"
        autoComplete="address-level1"
        defaultValue={row?.province ?? ""}
        className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
      />
      <label className="text-sm font-medium" htmlFor={`postal-${personId}`}>
        Postal code
      </label>
      <input
        id={`postal-${personId}`}
        name="postalCode"
        autoComplete="postal-code"
        defaultValue={row?.postal_code ?? ""}
        className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
      />
      <label className="text-sm font-medium" htmlFor={`personal-${personId}`}>
        Personal email
      </label>
      <input
        id={`personal-${personId}`}
        name="personalEmail"
        type="email"
        autoComplete="email"
        defaultValue={row?.personal_email ?? ""}
        className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
      />
      <label className="text-sm font-medium" htmlFor={`ename-${personId}`}>
        Emergency contact
      </label>
      <input
        id={`ename-${personId}`}
        name="emergencyName"
        defaultValue={row?.emergency_name ?? ""}
        className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
      />
      <label className="text-sm font-medium" htmlFor={`erel-${personId}`}>
        Relationship
      </label>
      <input
        id={`erel-${personId}`}
        name="emergencyRelationship"
        defaultValue={row?.emergency_relationship ?? ""}
        className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
      />
      <label className="text-sm font-medium" htmlFor={`ephone-${personId}`}>
        Emergency phone
      </label>
      <input
        id={`ephone-${personId}`}
        name="emergencyPhone"
        type="tel"
        defaultValue={row?.emergency_phone ?? ""}
        className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
      />
      <button
        type="submit"
        className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
      >
        Save private details
      </button>
    </form>
  );
}
