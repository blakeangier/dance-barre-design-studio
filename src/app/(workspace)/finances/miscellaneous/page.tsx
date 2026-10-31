import { Suspense } from "react";
import { ownerGate } from "@/app/(workspace)/finances/guard";
import { FinanceTabs } from "@/components/finances/tabs";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { money } from "@/lib/inventory/format";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Miscellaneous" };

export default function MiscellaneousPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <Miscellaneous />
    </Suspense>
  );
}

async function Miscellaneous() {
  const gate = await ownerGate();
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const supabase = await createClient();
  const { data: category } = await supabase
    .from("finance_categories")
    .select("id, name")
    .eq("name", "Miscellaneous")
    .maybeSingle();
  const categoryId = (category as { id: number } | null)?.id;
  const [startupResult, cardResult, recurringResult] = categoryId
    ? await Promise.all([
        supabase
          .from("startup_costs")
          .select("id, occurred_on, description, amount_cad, hst_cad")
          .eq("category_id", categoryId)
          .is("archived_at", null),
        supabase
          .from("card_transactions")
          .select(
            "id, transaction_date, merchant, amount_cad, hst_cad, excluded",
          )
          .eq("category_id", categoryId)
          .is("archived_at", null),
        supabase
          .from("recurring_costs")
          .select("id, name, amount_cad, hst_cad, frequency")
          .eq("category_id", categoryId)
          .is("archived_at", null),
      ])
    : [{ data: [] }, { data: [] }, { data: [] }];

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Miscellaneous</h1>
      <FinanceTabs current="miscellaneous" />
      <p className="text-sm text-muted">
        Lines in the Miscellaneous category. Pre-tax and HST stay separate.
      </p>
      <h2 className="font-serif text-2xl">Startup</h2>
      <Lines
        rows={(
          (startupResult.data ?? []) as {
            id: number;
            occurred_on: string;
            description: string;
            amount_cad: number | string;
            hst_cad: number | string;
          }[]
        ).map((row) => ({
          id: row.id,
          label: `${row.occurred_on} · ${row.description}`,
          amount: Number(row.amount_cad),
          hst: Number(row.hst_cad),
        }))}
      />
      <h2 className="font-serif text-2xl">Card</h2>
      <Lines
        rows={(
          (cardResult.data ?? []) as {
            id: number;
            transaction_date: string;
            merchant: string;
            amount_cad: number | string;
            hst_cad: number | string;
            excluded: boolean;
          }[]
        ).map((row) => ({
          id: row.id,
          label: `${row.transaction_date} · ${row.merchant}${row.excluded ? " · excluded" : ""}`,
          amount: Number(row.amount_cad),
          hst: Number(row.hst_cad),
        }))}
      />
      <h2 className="font-serif text-2xl">Recurring</h2>
      <Lines
        rows={(
          (recurringResult.data ?? []) as {
            id: number;
            name: string;
            amount_cad: number | string;
            hst_cad: number | string;
            frequency: string;
          }[]
        ).map((row) => ({
          id: row.id,
          label: `${row.name} · ${row.frequency}`,
          amount: Number(row.amount_cad),
          hst: Number(row.hst_cad),
        }))}
      />
    </div>
  );
}

function Lines({
  rows,
}: {
  rows: { id: number; label: string; amount: number; hst: number }[];
}) {
  if (rows.length === 0) return <p className="text-sm text-muted">None.</p>;
  return (
    <ul className="flex flex-col gap-2 text-sm">
      {rows.map((row) => (
        <li key={row.id}>
          {row.label} · {money(row.amount)} pre-tax · HST {money(row.hst)}
        </li>
      ))}
    </ul>
  );
}
