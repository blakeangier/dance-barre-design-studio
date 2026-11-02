import Link from "next/link";
import { Suspense } from "react";
import { ownerGate } from "@/app/(workspace)/finances/guard";
import {
  FinanceFrame,
  financeButton,
  financeField,
} from "@/components/finances/frame";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { firstQueryValue } from "@/lib/auth/notices";
import {
  cleanProgramFilter,
  cleanSeasonFilter,
  currentOutsideComparison,
  filterHistoricalLines,
  isCreditLine,
  pastSpendHref,
  PAST_SPEND_PROGRAM_FILTERS,
  summarizeBySeason,
  topPayees,
  type CurrentOutsideLine,
  type HistoricalSpendLine,
  type SeasonSpend,
} from "@/lib/finances/historical-spend";
import { cents } from "@/lib/finances/money";
import { money } from "@/lib/inventory/format";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Past costume spend" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type HistoryRow = {
  id: number;
  season: string;
  program: string;
  txn_date: string;
  payee: string;
  source_ref: string | null;
  je_number: string;
  debit: number | string | null;
  credit: number | string | null;
  net: number | string | null;
};

type OutsideRow = {
  amount: number | string | null;
  currency: string | null;
  purchased_on: string | null;
  is_refund: boolean | null;
  flag_duplicate: boolean | null;
  flag_canceled: boolean | null;
  programs: { name: string } | { name: string }[] | null;
};

export default function PastSpendPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <PastSpend searchParams={props.searchParams} />
    </Suspense>
  );
}

async function PastSpend({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  if (gate.profile.role !== "owner") return <NoAccess reason="denied" />;

  const [params, supabase] = await Promise.all([searchParams, createClient()]);
  const season = cleanSeasonFilter(firstQueryValue(params.season) ?? "");
  const program = cleanProgramFilter(firstQueryValue(params.program) ?? "");
  const [historyResult, outsideResult] = await Promise.all([
    supabase
      .from("historical_costume_spend")
      .select(
        "id, season, program, txn_date, payee, source_ref, je_number, debit, credit, net",
      )
      .order("txn_date", { ascending: false })
      .limit(2000),
    supabase
      .from("outside_costume_purchases")
      .select(
        "amount, currency, purchased_on, is_refund, flag_duplicate, flag_canceled, programs(name)",
      )
      .is("archived_at", null)
      .limit(2000),
  ]);

  const lines = ((historyResult.data ?? []) as HistoryRow[]).map(toLine);
  const summary = summarizeBySeason(lines);
  const comparison = currentOutsideComparison(
    ((outsideResult.data ?? []) as OutsideRow[]).map(toOutsideLine),
  );
  const visible = filterHistoricalLines(lines, { season, program }).sort(
    (left, right) =>
      right.txnDate.localeCompare(left.txnDate) ||
      left.payee.localeCompare(right.payee) ||
      left.jeNumber.localeCompare(right.jeNumber),
  );
  const payees = season ? topPayees(lines, season) : [];
  const seasons = summary.map((row) => row.season);

  return (
    <FinanceFrame
      title="Past costume spend"
      current="past"
      wide
      lede="Past seasons are studio general-ledger costume purchases, 1 June through 31 May, summed on net (debit minus credit). The 2026-27 comparison is Design Studio outside-costume spend for Elite Company and CREW, in CAD. It is not from that ledger. This page is read-only."
    >
      {historyResult.error ? (
        <p className="text-sm text-ink">
          Past costume lines could not be loaded.
        </p>
      ) : (
        <SummaryTable rows={summary} />
      )}
      {outsideResult.error ? (
        <p className="text-sm text-ink">
          The 2026-27 outside-costume comparison could not be loaded.
        </p>
      ) : (
        <ComparisonTable rows={summary} comparison={comparison} />
      )}
      <FilterForm season={season} program={program} seasons={seasons} />
      {season || program ? (
        <Transactions
          season={season}
          program={program}
          lines={visible}
          payees={payees}
        />
      ) : (
        <p className="text-sm text-muted">
          Click a season and program in the summary, or use the filters, to see
          the lines.
        </p>
      )}
    </FinanceFrame>
  );
}

function SummaryTable({ rows }: { rows: SeasonSpend[] }) {
  return (
    <section className="flex flex-col gap-2">
      <h2 className="font-serif text-2xl text-ink">By season</h2>
      <p className="text-sm text-muted">
        Other is ABC plus Kickstart. Each amount is the net of that column.
        Click a cell to open the lines.
      </p>
      {rows.length === 0 ? (
        <p className="text-sm text-muted">No past costume lines are loaded.</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full min-w-[40rem] text-left text-sm">
            <caption className="sr-only">
              Past costume spend by season and program, on net
            </caption>
            <thead>
              <tr className="text-muted">
                <th className="py-2 pr-3 font-medium">Season</th>
                <th className="py-2 pr-3 font-medium">Elite Company</th>
                <th className="py-2 pr-3 font-medium">Recreational</th>
                <th className="py-2 pr-3 font-medium">CREW</th>
                <th className="py-2 pr-3 font-medium">Other</th>
                <th className="py-2 font-medium">Total</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => (
                <tr key={row.season} className="border-t border-line">
                  <th className="py-2 pr-3 text-left font-medium text-ink">
                    <CellLink season={row.season} label={row.season} />
                  </th>
                  <td className="py-2 pr-3">
                    <CellLink
                      season={row.season}
                      program="Elite Company"
                      label={money(row.elite)}
                    />
                  </td>
                  <td className="py-2 pr-3">
                    <CellLink
                      season={row.season}
                      program="Recreational"
                      label={money(row.recreational)}
                    />
                  </td>
                  <td className="py-2 pr-3">
                    <CellLink
                      season={row.season}
                      program="CREW"
                      label={money(row.crew)}
                    />
                  </td>
                  <td className="py-2 pr-3">
                    <CellLink
                      season={row.season}
                      program="Other"
                      label={money(row.other)}
                    />
                  </td>
                  <td className="py-2 font-medium">
                    <CellLink season={row.season} label={money(row.total)} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </section>
  );
}

function ComparisonTable({
  rows,
  comparison,
}: {
  rows: SeasonSpend[];
  comparison: ReturnType<typeof currentOutsideComparison>;
}) {
  return (
    <section className="flex flex-col gap-2">
      <h2 className="font-serif text-2xl text-ink">
        Elite and CREW beside 2026-27
      </h2>
      <p className="text-sm text-muted">
        Past rows are studio general-ledger net. The {comparison.season} row is
        Design Studio outside-costume spend in CAD, from{" "}
        {formatDay(comparison.start)} to {formatDay(comparison.end)}, for Elite
        Company and CREW only. Recreational, Petite Elite, ABC, and Kickstart
        are not in that row. USD is not added into the CAD amounts.
      </p>
      <div className="overflow-x-auto">
        <table className="w-full min-w-[40rem] text-left text-sm">
          <caption className="sr-only">
            Elite Company and CREW past studio ledger net beside current Design
            Studio outside-costume CAD
          </caption>
          <thead>
            <tr className="text-muted">
              <th className="py-2 pr-3 font-medium">Season</th>
              <th className="py-2 pr-3 font-medium">What this row is</th>
              <th className="py-2 pr-3 font-medium">Elite Company</th>
              <th className="py-2 pr-3 font-medium">CREW</th>
              <th className="py-2 font-medium">Elite + CREW</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.season} className="border-t border-line">
                <th className="py-2 pr-3 text-left font-medium">
                  {row.season}
                </th>
                <td className="py-2 pr-3">Studio GL net</td>
                <td className="py-2 pr-3">{money(row.elite)}</td>
                <td className="py-2 pr-3">{money(row.crew)}</td>
                <td className="py-2">{money(cents(row.elite + row.crew))}</td>
              </tr>
            ))}
            <tr className="border-t border-line bg-teal/20">
              <th className="py-2 pr-3 text-left font-medium">
                {comparison.season}
              </th>
              <td className="py-2 pr-3">Design Studio outside costumes, CAD</td>
              <td className="py-2 pr-3">{money(comparison.eliteCad)}</td>
              <td className="py-2 pr-3">{money(comparison.crewCad)}</td>
              <td className="py-2 font-medium">{money(comparison.totalCad)}</td>
            </tr>
          </tbody>
        </table>
      </div>
      {comparison.totalUsd !== 0 ? (
        <p className="text-sm text-ink">
          USD in this window, not included above: Elite Company{" "}
          {usd(comparison.eliteUsd)}, CREW {usd(comparison.crewUsd)}.
        </p>
      ) : null}
      {comparison.skippedUndated > 0 || comparison.skippedOutsideWindow > 0 ? (
        <p className="text-sm text-muted">
          Left out of the {comparison.season} row: {comparison.skippedUndated}{" "}
          with no date, {comparison.skippedOutsideWindow} dated outside{" "}
          {formatDay(comparison.start)}–{formatDay(comparison.end)}.
        </p>
      ) : null}
    </section>
  );
}

function FilterForm({
  season,
  program,
  seasons,
}: {
  season: string;
  program: string;
  seasons: string[];
}) {
  return (
    <form method="get" className="grid gap-2 sm:grid-cols-3">
      <label className="flex flex-col gap-1 text-sm font-medium">
        Season
        <select name="season" defaultValue={season} className={financeField}>
          <option value="">Every season</option>
          {seasons.map((item) => (
            <option key={item} value={item}>
              {item}
            </option>
          ))}
        </select>
      </label>
      <label className="flex flex-col gap-1 text-sm font-medium">
        Program
        <select name="program" defaultValue={program} className={financeField}>
          <option value="">Every program</option>
          {PAST_SPEND_PROGRAM_FILTERS.map((item) => (
            <option key={item} value={item}>
              {item === "Other" ? "Other (ABC + Kickstart)" : item}
            </option>
          ))}
        </select>
      </label>
      <div className="flex items-end gap-2">
        <button type="submit" className={financeButton}>
          Filter
        </button>
        {season || program ? (
          <Link
            href="/finances/past-spend"
            className="inline-flex min-h-12 items-center rounded-full border border-ink px-4 text-sm font-medium"
          >
            Clear
          </Link>
        ) : null}
      </div>
    </form>
  );
}

function Transactions({
  season,
  program,
  lines,
  payees,
}: {
  season: string;
  program: string;
  lines: HistoricalSpendLine[];
  payees: { payee: string; net: number; lines: number }[];
}) {
  const scope = [season, programLabel(program)].filter(Boolean).join(" · ");
  return (
    <>
      <section className="flex flex-col gap-2">
        <h2 className="font-serif text-2xl text-ink">Lines</h2>
        <p className="text-sm text-muted">
          {scope || "Filtered lines"}. {lines.length}{" "}
          {lines.length === 1 ? "line" : "lines"}. Highlighted rows are credits
          or refunds.
        </p>
        {lines.length === 0 ? (
          <p className="text-sm text-muted">No lines match this filter.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full min-w-[48rem] text-left text-sm">
              <caption className="sr-only">
                Costume spend lines for {scope}
              </caption>
              <thead>
                <tr className="text-muted">
                  <th className="py-2 pr-3 font-medium">Date</th>
                  <th className="py-2 pr-3 font-medium">Payee</th>
                  <th className="py-2 pr-3 font-medium">Source</th>
                  <th className="py-2 pr-3 font-medium">JE#</th>
                  <th className="py-2 pr-3 font-medium">Debit</th>
                  <th className="py-2 pr-3 font-medium">Credit</th>
                  <th className="py-2 font-medium">Net</th>
                </tr>
              </thead>
              <tbody>
                {lines.map((line) => {
                  const credit = isCreditLine(line);
                  return (
                    <tr
                      key={line.id}
                      className={`border-t border-line ${credit ? "bg-orange/20" : ""}`}
                    >
                      <td className="py-2 pr-3">{formatDay(line.txnDate)}</td>
                      <td className="py-2 pr-3">
                        {line.payee}
                        {credit ? (
                          <span className="ml-2 font-medium">Credit</span>
                        ) : null}
                      </td>
                      <td className="py-2 pr-3">{line.sourceRef || "—"}</td>
                      <td className="py-2 pr-3">{line.jeNumber}</td>
                      <td className="py-2 pr-3">{money(line.debit)}</td>
                      <td className="py-2 pr-3">{money(line.credit)}</td>
                      <td className="py-2">{money(line.net)}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </section>
      {season ? (
        <section className="flex flex-col gap-2">
          <h2 className="font-serif text-2xl text-ink">
            Top payees for {season}
          </h2>
          <p className="text-sm text-muted">
            Every program in {season}, ranked by net. The program filter does
            not change this list.
          </p>
          {payees.length === 0 ? (
            <p className="text-sm text-muted">No payees in this season.</p>
          ) : (
            <ul className="text-sm">
              {payees.map((row) => (
                <li key={row.payee}>
                  {row.payee} · {money(row.net)} · {row.lines}{" "}
                  {row.lines === 1 ? "line" : "lines"}
                </li>
              ))}
            </ul>
          )}
        </section>
      ) : null}
    </>
  );
}

function CellLink({
  season,
  program = "",
  label,
}: {
  season: string;
  program?: string;
  label: string;
}) {
  const name = program ? `${season} ${program}` : `${season} total`;
  return (
    <Link
      href={pastSpendHref(season, program)}
      className="font-medium text-ink underline decoration-line underline-offset-4"
    >
      {label}
      <span className="sr-only"> {name}</span>
    </Link>
  );
}

function programLabel(program: string): string {
  if (program === "Other") return "ABC and Kickstart";
  return program;
}

function formatDay(iso: string): string {
  const match = /^(\d{4})-(\d{2})-(\d{2})/.exec(iso);
  if (!match) return iso;
  const date = new Date(
    Date.UTC(Number(match[1]), Number(match[2]) - 1, Number(match[3])),
  );
  return new Intl.DateTimeFormat("en-CA", {
    day: "numeric",
    month: "short",
    year: "numeric",
    timeZone: "UTC",
  }).format(date);
}

function usd(value: number): string {
  return value.toLocaleString("en-CA", { style: "currency", currency: "USD" });
}

function asNumber(value: number | string | null | undefined): number {
  if (value === null || value === undefined || value === "") return 0;
  const number = typeof value === "number" ? value : Number(value);
  return Number.isFinite(number) ? number : 0;
}

function programName(
  value: { name: string } | { name: string }[] | null,
): string {
  if (!value) return "";
  return Array.isArray(value) ? (value[0]?.name ?? "") : value.name;
}

function toLine(row: HistoryRow): HistoricalSpendLine {
  const debit = asNumber(row.debit);
  const credit = asNumber(row.credit);
  const net =
    row.net === null || row.net === "" ? debit - credit : asNumber(row.net);
  return {
    id: row.id,
    season: row.season,
    program: row.program,
    txnDate: row.txn_date,
    payee: row.payee,
    sourceRef: row.source_ref,
    jeNumber: row.je_number,
    debit,
    credit,
    net,
  };
}

function toOutsideLine(row: OutsideRow): CurrentOutsideLine {
  return {
    program: programName(row.programs),
    amount:
      row.amount === null || row.amount === "" ? null : asNumber(row.amount),
    currency: row.currency === "USD" ? "USD" : "CAD",
    purchasedOn: row.purchased_on,
    refund: Boolean(row.is_refund),
    archived: false,
    duplicate: Boolean(row.flag_duplicate),
    canceled: Boolean(row.flag_canceled),
  };
}
