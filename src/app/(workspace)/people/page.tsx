import { Suspense } from "react";
import { updateAccess } from "@/app/(workspace)/people/actions";
import { firstQueryValue, noticeText } from "@/lib/auth/notices";
import { ROLE_LABELS, ROLES, type AppRole } from "@/lib/auth/permissions";
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
  const notice = noticeText(firstQueryValue(params.notice));
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("profiles")
    .select("id, email, full_name, role, can_purchase, is_active")
    .order("full_name");

  const people = (data ?? []) as PersonRow[];
  const isOwner = gate.profile.role === "owner";

  return (
    <div className="flex flex-col gap-4">
      <div>
        <h1 className="font-serif text-3xl text-wine-deep">People</h1>
        <p className="mt-2 max-w-prose text-sm leading-relaxed text-ink/75">
          New accounts are created with the setup script, not from this screen.
          {isOwner
            ? " You can change someone else's role here. You cannot change your own."
            : " Role changes are limited to owners."}
        </p>
      </div>
      {notice ? <StatusNote>{notice}</StatusNote> : null}
      {error ? (
        <p className="text-sm text-ink/75">The people list did not load.</p>
      ) : (
        <ul className="flex flex-col gap-3">
          {people.map((person) => (
            <li
              key={person.id}
              className="rounded-2xl border border-line bg-card p-4"
            >
              <p className="font-medium">
                {person.full_name || "Unnamed"}
                {!person.is_active ? " (off)" : ""}
              </p>
              <p className="text-sm text-ink/70">{person.email}</p>
              <p className="mt-1 text-sm">
                {ROLE_LABELS[person.role]}
                {person.can_purchase ? " · Purchasing" : ""}
              </p>
              {isOwner && person.id !== gate.profile.id ? (
                <form
                  action={updateAccess}
                  className="mt-3 flex flex-col gap-3"
                >
                  <input type="hidden" name="profileId" value={person.id} />
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
                    className="min-h-12 rounded-xl border border-line bg-cream px-3 text-base"
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
                    className="min-h-12 rounded-full bg-wine px-4 font-medium text-cream"
                  >
                    Save access
                  </button>
                </form>
              ) : null}
              {isOwner && person.id === gate.profile.id ? (
                <p className="mt-3 text-sm text-ink/70">
                  Ask the other owner to change your access.
                </p>
              ) : null}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
