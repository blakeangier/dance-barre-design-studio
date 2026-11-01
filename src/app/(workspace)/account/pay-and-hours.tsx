import Link from "next/link";
import { canAccessArea } from "@/lib/auth/permissions";
import type { CurrentProfile } from "@/lib/auth/session";
import {
  currentPayRates,
  dayHourTotals,
  formatHourlyRate,
  formatHours,
  minutesBetween,
} from "@/lib/schedule/hours";
import { createClient } from "@/lib/supabase/server";

const STATUS_LABEL: Record<string, string> = {
  draft: "Draft",
  submitted: "Submitted",
  approved: "Approved",
  returned: "Sent back",
  sent: "Sent to payroll",
  processed: "Processed",
};

type RateRow = {
  hourly_rate: number | string;
  currency: string;
  effective_from: string;
  effective_to: string | null;
  entity_id: number;
};

type SheetRow = {
  id: number;
  period_start: string;
  period_end: string;
  status: string;
};

type EntryRow = {
  timesheet_id: number;
  work_date: string;
  actual_starts_at: string | null;
  actual_ends_at: string | null;
  actual_break_minutes: number;
  not_worked: boolean;
  status: string;
};

export async function PayAndHours({ profile }: { profile: CurrentProfile }) {
  const supabase = await createClient();
  const today = new Date().toLocaleDateString("en-CA", {
    timeZone: "America/Toronto",
  });
  const [ratesResult, entitiesResult, sheetsResult, settingsResult] =
    await Promise.all([
      supabase
        .from("employee_compensation")
        .select(
          "hourly_rate, currency, effective_from, effective_to, entity_id",
        )
        .eq("profile_id", profile.id),
      supabase.from("business_entities").select("id, legal_name"),
      supabase
        .from("timesheets")
        .select("id, period_start, period_end, status")
        .eq("profile_id", profile.id)
        .order("period_start", { ascending: false }),
      supabase
        .from("payroll_settings")
        .select("rounding_minutes")
        .eq("id", true)
        .maybeSingle(),
    ]);

  const sheets = (sheetsResult.data ?? []) as SheetRow[];
  const entriesResult =
    sheets.length === 0
      ? { data: [] as EntryRow[], error: null }
      : await supabase
          .from("timesheet_entries")
          .select(
            "timesheet_id, work_date, actual_starts_at, actual_ends_at, actual_break_minutes, not_worked, status",
          )
          .in(
            "timesheet_id",
            sheets.map((sheet) => sheet.id),
          );

  const names = new Map(
    ((entitiesResult.data ?? []) as { id: number; legal_name: string }[]).map(
      (entity) => [entity.id, entity.legal_name],
    ),
  );
  const current = currentPayRates(
    ((ratesResult.data ?? []) as RateRow[]).flatMap((row) => {
      const amount = Number(row.hourly_rate);
      if (!Number.isFinite(amount)) return [];
      return [
        {
          effectiveFrom: row.effective_from,
          effectiveTo: row.effective_to,
          label: names.get(row.entity_id) ?? row.currency,
          text: formatHourlyRate(amount, row.currency),
          since: row.effective_from,
        },
      ];
    }),
    today,
  );
  const rounding = settingsResult.data?.rounding_minutes ?? 0;
  const entries = (entriesResult.data ?? []) as EntryRow[];
  const periods = sheets.map((sheet) => {
    const days = dayHourTotals(
      entries
        .filter(
          (entry) =>
            entry.timesheet_id === sheet.id &&
            entry.status === "active" &&
            !entry.not_worked &&
            entry.actual_starts_at &&
            entry.actual_ends_at,
        )
        .map((entry) => ({
          workDate: entry.work_date,
          minutes:
            minutesBetween(
              entry.actual_starts_at!,
              entry.actual_ends_at!,
              entry.actual_break_minutes,
              rounding,
            ) ?? 0,
        })),
    );
    return {
      ...sheet,
      days,
      totalMinutes: days.reduce((sum, day) => sum + day.minutes, 0),
    };
  });
  const canOpenHours = canAccessArea(profile, "scheduling");

  return (
    <section className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4">
      <h2 className="font-serif text-2xl text-ink">My pay & hours</h2>
      <p className="text-sm leading-relaxed text-muted">
        Your own rate and timesheets. This is not a paycheque.
      </p>
      <div>
        <h3 className="text-sm font-medium">Pay rate</h3>
        {ratesResult.error ? (
          <p className="mt-1 text-sm text-muted">
            Your pay rate could not be loaded.
          </p>
        ) : current.length === 0 ? (
          <p className="mt-1 text-sm text-muted">No pay rate on file.</p>
        ) : (
          <ul className="mt-1 flex flex-col gap-1">
            {current.map((rate) => (
              <li
                key={`${rate.label}-${rate.since}-${rate.text}`}
                className="text-sm"
              >
                <span className="font-medium text-ink">{rate.text}</span>
                <span className="text-muted">
                  {" "}
                  · since {rate.since}
                  {current.length > 1 ? ` · ${rate.label}` : ""}
                </span>
              </li>
            ))}
          </ul>
        )}
      </div>
      <div>
        <h3 className="text-sm font-medium">Timesheets</h3>
        {sheetsResult.error || entriesResult.error ? (
          <p className="mt-1 text-sm text-muted">
            Your hours could not be loaded.
          </p>
        ) : periods.length === 0 ? (
          <p className="mt-1 text-sm text-muted">No timesheets yet.</p>
        ) : (
          <ul className="mt-2 flex flex-col gap-3">
            {periods.map((period) => (
              <li key={period.id}>
                <p className="text-sm font-medium text-ink">
                  {period.period_start} to {period.period_end}
                </p>
                <p className="text-sm text-muted">
                  {STATUS_LABEL[period.status] ?? period.status}
                  {" · "}
                  {formatHours(period.totalMinutes)} total
                </p>
                {period.days.length === 0 ? (
                  <p className="text-sm text-muted">No hours on this sheet.</p>
                ) : (
                  <ul className="mt-1">
                    {period.days.map((day) => (
                      <li
                        key={day.workDate}
                        className="flex justify-between gap-3 text-sm"
                      >
                        <span>{day.workDate}</span>
                        <span>{formatHours(day.minutes)}</span>
                      </li>
                    ))}
                  </ul>
                )}
              </li>
            ))}
          </ul>
        )}
        {canOpenHours ? (
          <Link
            href="/scheduling/hours"
            className="mt-2 inline-flex min-h-11 items-center text-sm font-medium text-ink underline decoration-line underline-offset-4"
          >
            Open the hours form
          </Link>
        ) : null}
      </div>
    </section>
  );
}
