import Link from "next/link";
import { Suspense } from "react";
import { openPerson } from "@/app/(workspace)/finances/workbook-actions";
import { ownerGate } from "@/app/(workspace)/finances/guard";
import { FinanceFrame, SourceLine } from "@/components/finances/frame";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { firstQueryValue } from "@/lib/auth/notices";
import { money } from "@/lib/inventory/format";
import { invoiceSummary } from "@/lib/finances/workbook";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "People and invoices" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function PeoplePage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <People searchParams={props.searchParams} />
    </Suspense>
  );
}

async function People({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const notice = firstQueryValue((await searchParams).notice);
  const supabase = await createClient();
  const [profilesResult, invoicesResult] = await Promise.all([
    supabase.from("profiles").select("id, full_name").order("full_name"),
    supabase
      .from("contractor_invoices")
      .select("profile_id, expected, amount_paid, hours, hst, source_note")
      .is("archived_at", null),
  ]);
  const profiles = (profilesResult.data ?? []) as {
    id: string;
    full_name: string;
  }[];
  const invoices = (invoicesResult.data ?? []) as {
    profile_id: string;
    expected: number | string | null;
    amount_paid: number | string | null;
    hours: number | string | null;
    hst: number | string;
    source_note: string;
  }[];
  const withLines = profiles.filter((profile) =>
    invoices.some((invoice) => invoice.profile_id === profile.id),
  );

  return (
    <FinanceFrame
      title="People and invoices"
      current="people"
      notice={notice}
      lede="One page per person for invoices and pay lines. A line is underpaid when the amount paid is below the expected amount."
    >
      <ul className="flex flex-col gap-2">
        {withLines.map((profile) => {
          const rows = invoices.filter(
            (invoice) => invoice.profile_id === profile.id,
          );
          const summary = invoiceSummary(
            rows.map((row) => ({
              hours: row.hours === null ? null : Number(row.hours),
              expected: row.expected === null ? null : Number(row.expected),
              paid: row.amount_paid === null ? null : Number(row.amount_paid),
              hst: Number(row.hst),
            })),
          );
          return (
            <li
              key={profile.id}
              className="rounded-2xl border border-line bg-card p-3 text-sm"
            >
              <Link
                href={`/finances/people/${profile.id}`}
                className="font-medium text-ink"
              >
                {profile.full_name || "Unnamed person"}
              </Link>
              <p>
                Expected {money(summary.expected)} · Paid {money(summary.paid)}{" "}
                · Difference {money(summary.difference)}
              </p>
              {summary.underpaid > 0 ? (
                <p className="font-medium text-ink">
                  {summary.underpaid} underpaid
                </p>
              ) : null}
              <SourceLine note={rows[0]?.source_note} />
            </li>
          );
        })}
      </ul>
      <form className="grid gap-2" action={openPerson}>
        <label className="text-sm font-medium" htmlFor="profileId">
          Open a person
        </label>
        <select
          id="profileId"
          name="profileId"
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          {profiles.map((profile) => (
            <option key={profile.id} value={profile.id}>
              {profile.full_name || profile.id}
            </option>
          ))}
        </select>
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white"
        >
          Open
        </button>
      </form>
    </FinanceFrame>
  );
}
