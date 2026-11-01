import { Suspense } from "react";
import {
  saveCostLine,
  saveStartupShare,
  saveUnitSettings,
} from "@/app/(workspace)/finances/workbook-actions";
import { ownerGate } from "@/app/(workspace)/finances/guard";
import {
  ArchiveForm,
  FinanceFrame,
  SourceLine,
  financeButton,
  financeField,
} from "@/components/finances/frame";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { firstQueryValue } from "@/lib/auth/notices";
import { money } from "@/lib/inventory/format";
import { costComparison, startupCounted } from "@/lib/finances/workbook";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Startup vs cost to make" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function CostPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Cost searchParams={props.searchParams} />
    </Suspense>
  );
}

type CostRow = {
  id: number;
  section: "make_in_house" | "purchased_outside";
  label: string;
  amount: number | string;
  hst: number | string;
  adjustment: string;
  source_note: string;
};

async function Cost({ searchParams }: PageProps) {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const notice = firstQueryValue((await searchParams).notice);
  const supabase = await createClient();
  const [startupResult, costResult, owedResult, unitsResult] =
    await Promise.all([
      supabase
        .from("startup_costs")
        .select(
          "id, description, amount_cad, hst_cad, startup_share_percent, source_note",
        )
        .is("archived_at", null)
        .order("description"),
      supabase
        .from("finance_cost_lines")
        .select("id, section, label, amount, hst, adjustment, source_note")
        .is("archived_at", null)
        .order("sort_order"),
      supabase
        .from("finance_committed_items")
        .select("amount")
        .eq("counts_as_startup", true)
        .is("archived_at", null),
      supabase
        .from("finance_unit_settings")
        .select("units, cost_per_unit, source_note")
        .eq("id", true)
        .maybeSingle(),
    ]);
  const startup = (startupResult.data ?? []) as {
    id: number;
    description: string;
    amount_cad: number | string;
    hst_cad: number | string;
    startup_share_percent: number | string;
    source_note: string;
  }[];
  const startupTotal = startup.reduce((sum, row) => {
    return (
      sum +
      startupCounted(
        Number(row.amount_cad),
        Number(row.hst_cad),
        Number(row.startup_share_percent),
      ).pretax
    );
  }, 0);
  const costs = (costResult.data ?? []) as CostRow[];
  const make = costs
    .filter((row) => row.section === "make_in_house")
    .reduce((sum, row) => sum + Number(row.amount), 0);
  const purchased = costs
    .filter((row) => row.section === "purchased_outside")
    .reduce((sum, row) => sum + Number(row.amount), 0);
  const owed = (
    (owedResult.data ?? []) as { amount: number | string }[]
  ).reduce((sum, row) => sum + Number(row.amount), 0);
  const units = unitsResult.data as {
    units: number | string | null;
    cost_per_unit: number | string | null;
    source_note: string;
  } | null;
  const comparison = costComparison({
    startup: startupTotal,
    make,
    purchased,
    startupOwed: owed,
    units:
      units?.units === null || units?.units === undefined
        ? null
        : Number(units.units),
    costPerUnit:
      units?.cost_per_unit === null || units?.cost_per_unit === undefined
        ? null
        : Number(units.cost_per_unit),
  });

  return (
    <FinanceFrame
      title="Startup vs cost to make"
      current="cost"
      notice={notice}
      lede="Startup is one-time. In-house cost is from September onward plus materials. Outside purchases include canceled, duplicate, and owing adjustments. Pre-tax."
    >
      <CostSection
        title="Startup costs (one-time)"
        total={
          comparison.startupShare === 0 && startupTotal === 0 ? 0 : startupTotal
        }
        rows={startup.map((row) => {
          const counted = startupCounted(
            Number(row.amount_cad),
            Number(row.hst_cad),
            Number(row.startup_share_percent),
          );
          return {
            id: row.id,
            label: row.description,
            amount: counted.pretax,
            detail: `${row.startup_share_percent}% of ${money(Number(row.amount_cad))} · HST share ${money(counted.hst)}`,
            source: row.source_note,
            share: Number(row.startup_share_percent),
          };
        })}
      />
      <CostBlock
        title="Cost to make in-house"
        rows={costs.filter((row) => row.section === "make_in_house")}
        total={make}
      />
      <CostBlock
        title="Purchased from outside companies"
        rows={costs.filter((row) => row.section === "purchased_outside")}
        total={purchased}
      />
      <form action={saveCostLine} className="grid gap-2 sm:grid-cols-2">
        <select name="section" className={financeField}>
          <option value="make_in_house">Cost to make in-house</option>
          <option value="purchased_outside">
            Purchased from outside companies
          </option>
        </select>
        <input
          name="label"
          required
          placeholder="Label"
          className={financeField}
        />
        <input
          name="amount"
          required
          inputMode="decimal"
          placeholder="Pre-tax amount"
          className={financeField}
        />
        <input
          name="hst"
          inputMode="decimal"
          placeholder="HST"
          className={financeField}
        />
        <select name="adjustment" className={financeField}>
          <option value="none">No adjustment</option>
          <option value="canceled">Canceled</option>
          <option value="duplicate">Duplicate</option>
          <option value="owing">Balance owing</option>
        </select>
        <input
          name="sourceNote"
          placeholder="Source"
          className={financeField}
        />
        <button type="submit" className={financeButton}>
          Add cost line
        </button>
      </form>
      <section className="rounded-2xl border border-line bg-card p-4 text-sm">
        <h2 className="font-serif text-2xl text-ink">Comparison</h2>
        <p>All costs {money(comparison.all)}</p>
        <p>
          Startup {comparison.startupShare}% · Make {comparison.makeShare}% ·
          Buy {comparison.purchasedShare}%
        </p>
        <p>
          Season costume cost (make + buy) {money(comparison.seasonCostumes)}
        </p>
        <p>
          Units {comparison.units ?? "—"} · Cost per unit{" "}
          {comparison.costPerUnit === null
            ? "—"
            : money(comparison.costPerUnit)}
          {comparison.extendedUnits === null
            ? ""
            : ` · Extended ${money(comparison.extendedUnits)}`}
        </p>
        <SourceLine note={units?.source_note} />
        <p className="mt-2 font-medium text-ink">
          Full startup cost including what is still owed{" "}
          {money(comparison.fullStartup)}
        </p>
        <p className="text-muted">
          Still owed {money(owed)}, from committed lines marked as startup.
        </p>
      </section>
      <form action={saveUnitSettings} className="grid gap-2 sm:grid-cols-2">
        <input
          name="units"
          inputMode="decimal"
          placeholder="Units"
          defaultValue={units?.units ?? ""}
          className={financeField}
        />
        <input
          name="costPerUnit"
          inputMode="decimal"
          placeholder="Cost per unit"
          defaultValue={units?.cost_per_unit ?? ""}
          className={financeField}
        />
        <input
          name="sourceNote"
          placeholder="Source"
          defaultValue={units?.source_note ?? ""}
          className={financeField}
        />
        <button type="submit" className={financeButton}>
          Save units
        </button>
      </form>
    </FinanceFrame>
  );
}

function CostSection({
  title,
  total,
  rows,
}: {
  title: string;
  total: number;
  rows: {
    id: number;
    label: string;
    amount: number;
    detail: string;
    source: string;
    share: number;
  }[];
}) {
  return (
    <section className="flex flex-col gap-2">
      <h2 className="font-serif text-2xl text-ink">
        {title} · {money(total)}
      </h2>
      <div className="overflow-x-auto">
        <table className="w-full min-w-[40rem] text-left text-sm">
          <thead>
            <tr className="text-muted">
              <th className="py-2 pr-3 font-medium">Label</th>
              <th className="py-2 pr-3 font-medium">Counted</th>
              <th className="py-2 pr-3 font-medium">Startup share</th>
              <th className="py-2 font-medium">Source</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.id} className="border-t border-line">
                <td className="py-2 pr-3">
                  {row.label}
                  <span className="block text-muted">{row.detail}</span>
                </td>
                <td className="py-2 pr-3">{money(row.amount)}</td>
                <td className="py-2 pr-3">
                  <form
                    action={saveStartupShare}
                    className="flex flex-col gap-2"
                  >
                    <input type="hidden" name="id" value={row.id} />
                    <input
                      name="startupShare"
                      inputMode="decimal"
                      defaultValue={row.share}
                      aria-label={`Startup share for ${row.label}`}
                      className={financeField}
                    />
                    <input
                      name="sourceNote"
                      defaultValue={
                        row.source === "Not recorded" ? "" : row.source
                      }
                      placeholder="Source"
                      className={financeField}
                    />
                    <button
                      type="submit"
                      className="min-h-11 text-sm font-medium"
                    >
                      Save share
                    </button>
                  </form>
                </td>
                <td className="py-2">
                  <SourceLine note={row.source} />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}

function CostBlock({
  title,
  rows,
  total,
}: {
  title: string;
  rows: CostRow[];
  total: number;
}) {
  return (
    <section className="flex flex-col gap-2">
      <h2 className="font-serif text-2xl text-ink">
        {title} · {money(total)}
      </h2>
      <div className="overflow-x-auto">
        <table className="w-full min-w-[40rem] text-left text-sm">
          <thead>
            <tr className="text-muted">
              <th className="py-2 pr-3 font-medium">Label</th>
              <th className="py-2 pr-3 font-medium">Amount</th>
              <th className="py-2 pr-3 font-medium">Adjustment</th>
              <th className="py-2 font-medium">Source</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.id} className="border-t border-line">
                <td className="py-2 pr-3">{row.label}</td>
                <td className="py-2 pr-3">
                  {money(Number(row.amount))}
                  {Number(row.hst) ? ` · HST ${money(Number(row.hst))}` : ""}
                </td>
                <td className="py-2 pr-3">{row.adjustment}</td>
                <td className="py-2">
                  <SourceLine note={row.source_note} />
                  <ArchiveForm
                    table="finance_cost_lines"
                    id={row.id}
                    back="/finances/cost"
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}
