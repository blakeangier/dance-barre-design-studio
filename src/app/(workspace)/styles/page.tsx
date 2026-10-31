import { Suspense } from "react";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { gateArea } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Styles" };

type StyleRow = {
  style_key: string;
  style_code: string | null;
  order_number_raw: string | null;
  garment_description: string | null;
  fabric_code_raw: string | null;
  fabric_in_materials: string | null;
};

export default function StylesPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <StylesScreen />
    </Suspense>
  );
}

async function StylesScreen() {
  const gate = await gateArea("styles");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const supabase = await createClient();
  const { data } = await supabase
    .from("styles")
    .select(
      "style_key, style_code, order_number_raw, garment_description, fabric_code_raw, fabric_in_materials",
    )
    .order("style_key");

  return (
    <div className="flex flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Styles</h1>
      <ul className="flex flex-col gap-3">
        {((data ?? []) as StyleRow[]).map((style) => (
          <li
            key={style.style_key}
            className="rounded-2xl border border-line bg-card p-4"
          >
            <p className="font-medium text-ink">
              {style.garment_description ?? style.style_key}
            </p>
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
