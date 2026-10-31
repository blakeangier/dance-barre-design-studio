import Link from "next/link";
import { Suspense } from "react";
import { ListHeader } from "@/components/records/list-header";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canEditInventory } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Styles" };

type StyleRow = {
  id: number;
  style_key: string;
  style_code: string | null;
  order_number_raw: string | null;
  garment_description: string | null;
  fabric_code_raw: string | null;
  fabric_in_materials: string | null;
};

type StylesProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function StylesPage(props: StylesProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <StylesScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function StylesScreen({
  searchParams,
}: {
  searchParams: StylesProps["searchParams"];
}) {
  const gate = await gateArea("styles");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const showArchived = firstQueryValue((await searchParams).archived) === "1";
  const supabase = await createClient();
  let query = supabase
    .from("styles")
    .select(
      "id, style_key, style_code, order_number_raw, garment_description, fabric_code_raw, fabric_in_materials",
    )
    .order("style_key");
  if (!showArchived) query = query.is("archived_at", null);
  const { data } = await query;

  return (
    <div className="flex flex-col gap-4">
      <ListHeader
        title="Styles"
        newHref="/styles/new"
        newLabel="New style"
        showArchived={showArchived}
        canCreate={canEditInventory(gate.profile)}
      />
      <ul className="flex flex-col gap-3">
        {((data ?? []) as StyleRow[]).map((style) => (
          <li
            key={style.id}
            className="rounded-2xl border border-line bg-card p-4"
          >
            <Link
              href={`/styles/${style.id}`}
              className="inline-flex min-h-11 items-center font-medium text-ink"
            >
              {style.garment_description ?? style.style_key}
            </Link>
            <p className="text-sm text-muted">
              Order {style.order_number_raw} ·{" "}
              {style.style_code ?? "No style number"}
            </p>
            <p className="text-sm text-muted">
              Fabric {style.fabric_code_raw ?? "—"}
              {style.fabric_in_materials
                ? ` · ${style.fabric_in_materials}`
                : ""}
            </p>
          </li>
        ))}
      </ul>
    </div>
  );
}
