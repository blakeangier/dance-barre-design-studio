import Link from "next/link";
import { Suspense } from "react";
import { saveStyle } from "@/app/(workspace)/records/style-actions";
import {
  AreaField,
  CheckField,
  SaveButton,
  SelectField,
  TextField,
} from "@/components/records/fields";
import { PhotoThumb } from "@/components/inventory/photo-thumb";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory, canSeeCosts } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { photosForMaterials } from "@/lib/inventory/photo-urls";
import { EDIT_NOTICES, SIZE_CODES } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Style" };

type PageProps = {
  params: Promise<{ styleId: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type StyleRow = {
  id: number;
  style_key: string;
  style_code: string | null;
  order_number_raw: string | null;
  garment_description: string | null;
  category: string | null;
  group_name: string | null;
  version_label: string | null;
  child_or_adult: string | null;
  character_note: string | null;
  fabric_code_raw: string | null;
  material_id: number | null;
  archived_at: string | null;
};

type StageRow = {
  id: number;
  stage_name: string;
  stage_order: number;
  cell_text: string | null;
  interpreted_on: string | null;
  interpreted_yes: boolean | null;
};

type SizeRow = { id: number; size_code: string; qty: number | null };
type BomRow = {
  id: number;
  line_code: string;
  component: string | null;
  fabric_as_written: string | null;
  material_id: number | null;
  consumption_per_unit_m: number | string | null;
  archived_at: string | null;
};
type MaterialOption = { id: number; material_code: string };
type CostRow = {
  bom_line_id: number;
  price_per_m_used: number | string | null;
};

export default function StylePage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <StyleScreen params={props.params} searchParams={props.searchParams} />
    </Suspense>
  );
}

async function StyleScreen({ params, searchParams }: PageProps) {
  const gate = await gateArea("styles");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const styleId = Number((await params).styleId);
  if (!Number.isInteger(styleId)) return <NoAccess reason="denied" />;
  const notice =
    EDIT_NOTICES[firstQueryValue((await searchParams).notice) ?? ""];
  const editor = canEditInventory(gate.profile);
  const seeCosts = canSeeCosts(gate.profile);
  const supabase = await createClient();
  const { data: style } = await supabase
    .from("styles")
    .select(
      "id, style_key, style_code, order_number_raw, garment_description, category, group_name, version_label, child_or_adult, character_note, fabric_code_raw, material_id, archived_at",
    )
    .eq("id", styleId)
    .maybeSingle();
  if (!style) {
    return (
      <section>
        <h1 className="font-serif text-3xl text-ink">Style not found</h1>
        <Link href="/styles" className="mt-3 inline-block text-sm">
          Back to styles
        </Link>
      </section>
    );
  }
  const typed = style as StyleRow;
  const [stagesResult, sizesResult, bomResult, materialsResult] =
    await Promise.all([
      supabase
        .from("style_stages")
        .select(
          "id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes",
        )
        .eq("style_id", typed.id)
        .order("stage_order"),
      supabase
        .from("order_sizes")
        .select("id, size_code, qty")
        .eq("style_id", typed.id),
      supabase
        .from("bom_lines")
        .select(
          "id, line_code, component, fabric_as_written, material_id, consumption_per_unit_m, archived_at",
        )
        .eq("style_id", typed.id)
        .order("line_code"),
      supabase
        .from("materials")
        .select("id, material_code")
        .order("material_code"),
    ]);
  const stages = (stagesResult.data ?? []) as StageRow[];
  const sizes = new Map(
    ((sizesResult.data ?? []) as SizeRow[]).map((row) => [row.size_code, row]),
  );
  const bomLines = (bomResult.data ?? []) as BomRow[];
  const materials = (materialsResult.data ?? []) as MaterialOption[];
  const photoIds = [
    typed.material_id,
    ...bomLines.map((line) => line.material_id),
  ].filter((id): id is number => id !== null);
  const photos = await photosForMaterials(photoIds);
  const linked = photos.get(typed.material_id ?? -1);
  const costs = new Map<number, CostRow>();
  if (seeCosts && bomLines.length > 0) {
    const { data } = await supabase
      .from("bom_costs")
      .select("bom_line_id, price_per_m_used")
      .in(
        "bom_line_id",
        bomLines.map((line) => line.id),
      );
    for (const row of (data ?? []) as CostRow[])
      costs.set(row.bom_line_id, row);
  }

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/styles" className="text-sm text-muted">
        Styles
      </Link>
      <h1 className="font-serif text-3xl text-ink">
        {typed.garment_description ?? typed.style_key}
      </h1>
      <Link
        href={`/styles/${typed.id}/tech-pack`}
        className="inline-flex min-h-11 items-center text-sm text-ink"
      >
        Tech pack
      </Link>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      {editor ? (
        <form
          action={saveStyle}
          className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
        >
          <input type="hidden" name="id" value={typed.id} />
          <input
            type="hidden"
            name="archivedAt"
            value={typed.archived_at ?? ""}
          />
          <TextField
            id="styleKey"
            name="styleKey"
            label="Style key"
            required
            defaultValue={typed.style_key}
          />
          <TextField
            id="styleCode"
            name="styleCode"
            label="Style number"
            defaultValue={typed.style_code}
          />
          <TextField
            id="orderNumber"
            name="orderNumber"
            label="Order number"
            defaultValue={typed.order_number_raw}
          />
          <TextField
            id="garment"
            name="garment"
            label="Garment"
            defaultValue={typed.garment_description}
          />
          <TextField
            id="category"
            name="category"
            label="Category"
            defaultValue={typed.category}
          />
          <TextField
            id="groupName"
            name="groupName"
            label="Group"
            defaultValue={typed.group_name}
          />
          <TextField
            id="versionLabel"
            name="versionLabel"
            label="Version"
            defaultValue={typed.version_label}
          />
          <TextField
            id="childOrAdult"
            name="childOrAdult"
            label="Child or adult"
            defaultValue={typed.child_or_adult}
          />
          <AreaField
            id="characterNote"
            name="characterNote"
            label="Character note"
            defaultValue={typed.character_note}
          />
          <TextField
            id="fabricCode"
            name="fabricCode"
            label="Fabric as written"
            defaultValue={typed.fabric_code_raw}
          />
          {typed.material_id ? (
            <div className="flex items-center gap-3">
              <PhotoThumb
                thumbUrl={linked?.thumbUrl ?? null}
                fullUrl={linked?.fullUrl ?? null}
                label={
                  materials.find((item) => item.id === typed.material_id)
                    ?.material_code ?? "Fabric"
                }
              />
              <p className="text-sm text-ink">
                {materials.find((item) => item.id === typed.material_id)
                  ?.material_code ?? "Linked fabric"}
              </p>
            </div>
          ) : null}
          <SelectField
            id="materialId"
            name="materialId"
            label="Linked material"
            defaultValue={typed.material_id ? String(typed.material_id) : ""}
          >
            <option value="">No linked material</option>
            {materials.map((material) => (
              <option key={material.id} value={material.id}>
                {material.material_code}
              </option>
            ))}
          </SelectField>
          <CheckField
            name="archive"
            label="Archive this style"
            defaultChecked={Boolean(typed.archived_at)}
          />
          <h2 className="font-serif text-2xl text-ink">Stages</h2>
          {stages.map((stage) => (
            <fieldset
              key={stage.id}
              className="flex flex-col gap-2 border-t border-line pt-3"
            >
              <legend className="text-sm font-medium">
                {stage.stage_name}
              </legend>
              <input type="hidden" name="stageId" value={stage.id} />
              <TextField
                id={`stage-date-${stage.id}`}
                name={`stageDate_${stage.id}`}
                label="Date"
                type="date"
                defaultValue={stage.interpreted_on}
              />
              <SelectField
                id={`stage-yes-${stage.id}`}
                name={`stageYes_${stage.id}`}
                label="Done"
                defaultValue={
                  stage.interpreted_yes === true
                    ? "yes"
                    : stage.interpreted_yes === false
                      ? "no"
                      : ""
                }
              >
                <option value="">Not a yes or no</option>
                <option value="yes">Yes</option>
                <option value="no">No</option>
              </SelectField>
              <AreaField
                id={`stage-text-${stage.id}`}
                name={`stageText_${stage.id}`}
                label="Note"
                defaultValue={stage.cell_text}
              />
            </fieldset>
          ))}
          <h2 className="font-serif text-2xl text-ink">Sizes</h2>
          {SIZE_CODES.map((code) => {
            const row = sizes.get(code);
            return (
              <div key={code}>
                {row ? (
                  <input type="hidden" name={`sizeId_${code}`} value={row.id} />
                ) : null}
                <TextField
                  id={`size-${code}`}
                  name={`size_${code}`}
                  label={code}
                  inputMode="decimal"
                  defaultValue={row?.qty}
                />
              </div>
            );
          })}
          <h2 className="font-serif text-2xl text-ink">Fabric use</h2>
          {bomLines.map((line) => (
            <fieldset
              key={line.id}
              className="flex flex-col gap-2 border-t border-line pt-3"
            >
              <legend className="text-sm font-medium">
                {line.line_code}
                {line.component ? ` · ${line.component}` : ""}
              </legend>
              <div className="flex items-center gap-3">
                <PhotoThumb
                  thumbUrl={
                    line.material_id
                      ? (photos.get(line.material_id)?.thumbUrl ?? null)
                      : null
                  }
                  fullUrl={
                    line.material_id
                      ? (photos.get(line.material_id)?.fullUrl ?? null)
                      : null
                  }
                  label={
                    materials.find((item) => item.id === line.material_id)
                      ?.material_code ??
                    line.fabric_as_written ??
                    "Fabric"
                  }
                />
                <p className="text-sm text-ink">
                  {materials.find((item) => item.id === line.material_id)
                    ?.material_code ??
                    line.fabric_as_written ??
                    "No linked fabric"}
                </p>
              </div>
              <input type="hidden" name="bomId" value={line.id} />
              <input
                type="hidden"
                name={`bomArchivedAt_${line.id}`}
                value={line.archived_at ?? ""}
              />
              <TextField
                id={`bom-written-${line.id}`}
                name={`bomWritten_${line.id}`}
                label="Fabric as written"
                defaultValue={line.fabric_as_written}
              />
              <SelectField
                id={`bom-material-${line.id}`}
                name={`bomMaterial_${line.id}`}
                label="Linked material"
                defaultValue={line.material_id ? String(line.material_id) : ""}
              >
                <option value="">Not linked</option>
                {materials.map((material) => (
                  <option key={material.id} value={material.id}>
                    {material.material_code}
                  </option>
                ))}
              </SelectField>
              <TextField
                id={`bom-qty-${line.id}`}
                name={`bomQty_${line.id}`}
                label="Metres per unit"
                inputMode="decimal"
                defaultValue={line.consumption_per_unit_m}
              />
              {seeCosts ? (
                <TextField
                  id={`bom-price-${line.id}`}
                  name={`bomPrice_${line.id}`}
                  label="Price per metre used"
                  inputMode="decimal"
                  defaultValue={costs.get(line.id)?.price_per_m_used}
                />
              ) : null}
              <CheckField
                name={`bomArchive_${line.id}`}
                label="Archive this line"
                defaultChecked={Boolean(line.archived_at)}
              />
            </fieldset>
          ))}
          <h3 className="font-medium text-ink">Add a fabric line</h3>
          <TextField
            id="newBomComponent"
            name="newBomComponent"
            label="Component"
          />
          <SelectField
            id="newBomMaterial"
            name="newBomMaterial"
            label="Material"
          >
            <option value="">Not linked</option>
            {materials.map((material) => (
              <option key={material.id} value={material.id}>
                {material.material_code}
              </option>
            ))}
          </SelectField>
          <TextField
            id="newBomQty"
            name="newBomQty"
            label="Metres per unit"
            inputMode="decimal"
          />
          <SaveButton label="Save style" />
        </form>
      ) : (
        <div className="flex flex-col gap-3">
          <p className="text-sm text-muted">
            {typed.style_key}
            {typed.order_number_raw ? ` · Order ${typed.order_number_raw}` : ""}
          </p>
          {bomLines.map((line) => (
            <div key={line.id} className="flex items-center gap-3">
              <PhotoThumb
                thumbUrl={
                  line.material_id
                    ? (photos.get(line.material_id)?.thumbUrl ?? null)
                    : null
                }
                fullUrl={
                  line.material_id
                    ? (photos.get(line.material_id)?.fullUrl ?? null)
                    : null
                }
                label={line.fabric_as_written ?? "Fabric"}
              />
              <p className="text-sm text-ink">
                {materials.find((item) => item.id === line.material_id)
                  ?.material_code ??
                  line.fabric_as_written ??
                  "No linked fabric"}
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
