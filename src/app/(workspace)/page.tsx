import { Suspense } from "react";
import { updateMyDetails } from "@/app/(workspace)/actions";
import { firstQueryValue, noticeText } from "@/lib/auth/notices";
import {
  areasFor,
  ROLE_LABELS,
  canProcessPayroll,
} from "@/lib/auth/permissions";
import { AREA_ACCENT } from "@/lib/brand";
import { gateArea } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";
import {
  formatHours,
  minutesBetween,
  payPeriodContaining,
} from "@/lib/schedule/hours";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import Link from "next/link";

export const metadata = {
  title: "Home",
};

type HomeProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function HomePage(props: HomeProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <HomeScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function HomeScreen({
  searchParams,
}: {
  searchParams: HomeProps["searchParams"];
}) {
  const gate = await gateArea("home");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;

  const params = await searchParams;
  const notice = noticeText(firstQueryValue(params.notice));
  const areas = areasFor(gate.profile).filter((area) => area.id !== "home");
  const supabase = await createClient();
  const { data: entities, error } = await supabase
    .from("business_entities")
    .select("id, legal_name, short_name, home_currency")
    .order("legal_name");

  return (
    <div className="flex flex-col gap-5">
      {notice ? <StatusNote>{notice}</StatusNote> : null}
      <section>
        <h1 className="font-serif text-3xl text-ink">
          Hello{gate.profile.fullName ? `, ${gate.profile.fullName}` : ""}
        </h1>
        <p className="mt-2 max-w-prose leading-relaxed text-muted">
          You are signed in as {ROLE_LABELS[gate.profile.role]}
          {gate.profile.canPurchase ? " with purchasing access" : ""}. Inventory
          and costume orders are open. The other areas stay closed until their
          phase.
        </p>
      </section>
      <section className="rounded-2xl border border-line bg-card p-5">
        <h2 className="font-serif text-2xl text-ink">Companies</h2>
        {error ? (
          <p className="mt-2 text-sm text-muted">
            The company list did not load. Apply the database migrations if you
            have not yet.
          </p>
        ) : (
          <ul className="mt-3 flex flex-col gap-2">
            {(entities ?? []).map((entity) => (
              <li key={entity.id} className="text-sm">
                <span className="font-medium">{entity.legal_name}</span>
                <span className="text-muted">
                  {" "}
                  · {entity.short_name} · {entity.home_currency}
                </span>
              </li>
            ))}
          </ul>
        )}
        <p className="mt-3 text-sm text-muted">
          Both companies are CAD for now. Blake confirmed that in October 2026.
          USD can be chosen later if either company starts keeping its books
          that way. This app does not convert currencies.
        </p>
      </section>
      <HoursCard
        profileId={gate.profile.id}
        canSetPeriod={canProcessPayroll(gate.profile)}
      />
      <section>
        <h2 className="font-serif text-2xl text-ink">Your areas</h2>
        <ul className="mt-3 grid gap-3 sm:grid-cols-2">
          {areas.map((area) => (
            <li key={area.id}>
              <Link
                href={area.href}
                className={`block min-h-20 rounded-2xl border border-line border-l-4 bg-card p-4 hover:bg-paper ${AREA_ACCENT[area.id]}`}
              >
                <span className="block font-medium">{area.label}</span>
                <span className="mt-1 block text-sm text-muted">
                  {area.description}
                </span>
              </Link>
            </li>
          ))}
        </ul>
      </section>
      <section className="rounded-2xl border border-line bg-card p-5">
        <h2 className="font-serif text-2xl text-ink">Your details</h2>
        <form action={updateMyDetails} className="mt-3 flex flex-col gap-3">
          <label className="text-sm font-medium" htmlFor="fullName">
            Name
          </label>
          <input type="hidden" name="next" value="/" />
          <input
            id="fullName"
            name="fullName"
            defaultValue={gate.profile.fullName}
            required
            maxLength={120}
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
          />
          <label className="text-sm font-medium" htmlFor="phone">
            Phone
          </label>
          <input
            id="phone"
            name="phone"
            type="tel"
            autoComplete="tel"
            defaultValue={gate.profile.phone ?? ""}
            maxLength={40}
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base text-ink"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
          >
            Save details
          </button>
        </form>
      </section>
    </div>
  );
}

async function HoursCard({
  profileId,
  canSetPeriod,
}: {
  profileId: string;
  canSetPeriod: boolean;
}) {
  const supabase = await createClient();
  const { data: settings, error } = await supabase
    .from("payroll_settings")
    .select("pay_period_anchor, rounding_minutes")
    .eq("id", true)
    .maybeSingle();
  if (error) return null;
  const today = new Date().toLocaleDateString("en-CA", {
    timeZone: "America/Toronto",
  });
  const period = payPeriodContaining(
    settings?.pay_period_anchor ?? null,
    today,
  );
  if (!period) {
    if (!canSetPeriod) return null;
    return (
      <section className="rounded-2xl border border-orange bg-card p-4">
        <h2 className="font-serif text-2xl text-ink">Pay period</h2>
        <p className="mt-2 text-sm text-muted">
          Set the first pay period start date before hours can be calculated.
        </p>
        <Link
          href="/payroll"
          className="mt-3 inline-flex min-h-12 items-center font-medium text-ink"
        >
          Open payroll
        </Link>
      </section>
    );
  }
  const { data: sheet } = await supabase
    .from("timesheets")
    .select("id, status")
    .eq("profile_id", profileId)
    .eq("period_start", period.start)
    .maybeSingle();
  const { data: entries } = sheet
    ? await supabase
        .from("timesheet_entries")
        .select(
          "actual_starts_at, actual_ends_at, actual_break_minutes, not_worked, status",
        )
        .eq("timesheet_id", sheet.id)
    : { data: [] };
  const minutes = (entries ?? []).reduce((sum, entry) => {
    if (entry.status !== "active" || entry.not_worked) return sum;
    if (!entry.actual_starts_at || !entry.actual_ends_at) return sum;
    return (
      sum +
      (minutesBetween(
        entry.actual_starts_at,
        entry.actual_ends_at,
        entry.actual_break_minutes,
        settings?.rounding_minutes ?? 0,
      ) ?? 0)
    );
  }, 0);

  return (
    <section className="rounded-2xl border border-line bg-card p-4">
      <h2 className="font-serif text-2xl text-ink">Your hours this period</h2>
      <p className="mt-2 font-serif text-3xl text-ink">
        {formatHours(minutes)}
      </p>
      <p className="text-sm text-muted">{sheet?.status ?? "Not started"}</p>
      <Link
        href="/scheduling/hours"
        className="mt-3 inline-flex min-h-12 items-center rounded-full bg-ink px-4 font-medium text-white"
      >
        Review hours
      </Link>
    </section>
  );
}
