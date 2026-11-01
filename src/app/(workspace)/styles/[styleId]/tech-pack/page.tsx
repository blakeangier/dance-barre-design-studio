import Link from "next/link";
import { Suspense } from "react";
import { saveTechPack } from "@/app/(workspace)/records/production-actions";
import { PhotoThumb } from "@/components/inventory/photo-thumb";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canEditInventory } from "@/lib/auth/permissions";
import { gateArea } from "@/lib/auth/session";
import { photosForMaterials } from "@/lib/inventory/photo-urls";
import { SEWING_ROUTE } from "@/lib/production/dancer";
import { SIZE_CODES } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Tech pack" };

type PageProps = { params: Promise<{ styleId: string }> };

export default function TechPackPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <TechPackScreen params={props.params} />
    </Suspense>
  );
}

async function TechPackScreen({ params }: PageProps) {
  const gate = await gateArea("styles");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const styleId = Number((await params).styleId);
  const editor = canEditInventory(gate.profile);
  const supabase = await createClient();
  const { data: style } = await supabase
    .from("styles")
    .select("id, style_key, garment_description")
    .eq("id", styleId)
    .maybeSingle();
  if (!style) return <h1 className="font-serif text-3xl">Style not found</h1>;
  const [versionsResult, bomResult, routeResult] = await Promise.all([
    supabase
      .from("tech_pack_versions")
      .select("id, version_no, description, construction_notes, created_at")
      .eq("style_id", styleId)
      .order("version_no", { ascending: false }),
    supabase
      .from("bom_lines")
      .select("id, component, fabric_name, material_id")
      .eq("style_id", styleId)
      .is("archived_at", null),
    supabase
      .from("sewing_route_template")
      .select("operation_name")
      .order("sort_order"),
  ]);
  const versions = (versionsResult.data ?? []) as {
    id: number;
    version_no: number;
    description: string | null;
    construction_notes: string | null;
    created_at: string;
  }[];
  const latest = versions[0];
  const measures = latest
    ? await supabase
        .from("tech_pack_measures")
        .select("point_name, size_code, value_cm, tolerance_cm")
        .eq("version_id", latest.id)
    : { data: [] };
  const operations = latest
    ? await supabase
        .from("tech_pack_operations")
        .select("operation_name, sort_order")
        .eq("version_id", latest.id)
        .order("sort_order")
    : { data: [] };
  const bom = (bomResult.data ?? []) as {
    id: number;
    component: string | null;
    fabric_name: string | null;
    material_id: number | null;
  }[];
  const photos = await photosForMaterials(
    bom
      .map((line) => line.material_id)
      .filter((id): id is number => id !== null),
  );
  const route =
    (operations.data ?? []).length > 0
      ? (operations.data ?? []).map((row) => row.operation_name as string)
      : (routeResult.data ?? []).map((row) => row.operation_name as string)
            .length
        ? (routeResult.data ?? []).map((row) => row.operation_name as string)
        : [...SEWING_ROUTE];

  return (
    <div className="mx-auto flex w-full max-w-3xl flex-col gap-4">
      <Link href={`/styles/${styleId}`} className="no-print text-sm text-muted">
        Style
      </Link>
      <h1 className="font-serif text-3xl text-ink">
        {style.garment_description ?? style.style_key}
      </h1>
      <p className="text-sm text-muted">
        Version {latest?.version_no ?? "not saved yet"}. Costs are not on this
        sheet.
      </p>
      {latest?.description ? <p>{latest.description}</p> : null}
      <h2 className="font-serif text-2xl">Fabrics and trims</h2>
      {bom.map((line) => {
        const photo = line.material_id
          ? photos.get(line.material_id)
          : undefined;
        return (
          <div key={line.id} className="flex items-center gap-3">
            <PhotoThumb
              thumbUrl={photo?.thumbUrl ?? null}
              fullUrl={photo?.fullUrl ?? null}
              label={line.fabric_name ?? line.component ?? "Material"}
            />
            <p className="text-sm text-ink">
              {line.component ?? "Component"} · {line.fabric_name ?? "Unlinked"}
            </p>
          </div>
        );
      })}
      <h2 className="font-serif text-2xl">Measurements</h2>
      <ul className="text-sm">
        {(
          (measures.data ?? []) as {
            point_name: string;
            size_code: string;
            value_cm: number | null;
            tolerance_cm: number | null;
          }[]
        ).map((row) => (
          <li key={`${row.point_name}-${row.size_code}`}>
            {row.point_name} · {row.size_code} · {row.value_cm ?? "—"} cm
            {row.tolerance_cm !== null ? ` ± ${row.tolerance_cm}` : ""}
          </li>
        ))}
      </ul>
      <h2 className="font-serif text-2xl">Construction</h2>
      <p className="text-sm">{latest?.construction_notes ?? "No notes yet."}</p>
      <h2 className="font-serif text-2xl">Sewing</h2>
      <ol className="list-decimal pl-5 text-sm">
        {route.map((step) => (
          <li key={step}>{step}</li>
        ))}
      </ol>
      <h2 className="font-serif text-2xl">Versions</h2>
      <ul className="text-sm text-muted">
        {versions.map((version) => (
          <li key={version.id}>
            Version {version.version_no} · {version.created_at.slice(0, 10)}
          </li>
        ))}
      </ul>
      {editor ? (
        <form
          action={saveTechPack}
          className="no-print flex flex-col gap-2 rounded-2xl border border-line bg-card p-4"
        >
          <h2 className="font-serif text-2xl">Save a new version</h2>
          <input type="hidden" name="styleId" value={styleId} />
          <textarea
            name="description"
            placeholder="Description"
            className="min-h-20 rounded-xl border border-line px-3 py-2"
          />
          <textarea
            name="constructionNotes"
            placeholder="Construction notes"
            className="min-h-20 rounded-xl border border-line px-3 py-2"
          />
          <input
            name="pointName"
            placeholder="Point of measure"
            className="min-h-12 rounded-xl border border-line px-3"
          />
          <select
            name="sizeCode"
            className="min-h-12 rounded-xl border border-line px-3"
          >
            {SIZE_CODES.map((code) => (
              <option key={code} value={code}>
                {code}
              </option>
            ))}
          </select>
          <input
            name="valueCm"
            inputMode="decimal"
            placeholder="Measurement cm"
            className="min-h-12 rounded-xl border border-line px-3"
          />
          <input
            name="toleranceCm"
            inputMode="decimal"
            placeholder="Tolerance cm"
            className="min-h-12 rounded-xl border border-line px-3"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
          >
            Save version
          </button>
        </form>
      ) : null}
      <p className="no-print text-sm text-muted">
        Use the browser print dialog to save a PDF. Costs are not on this page.
      </p>
    </div>
  );
}
