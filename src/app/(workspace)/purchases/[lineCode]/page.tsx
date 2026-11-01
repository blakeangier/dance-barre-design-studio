import Link from "next/link";
import { Suspense } from "react";
import { savePurchase } from "@/app/(workspace)/records/purchase-actions";
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
import { canRecordPurchase, canSeeCosts } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { metres, money } from "@/lib/inventory/format";
import { photosForMaterials } from "@/lib/inventory/photo-urls";
import { EDIT_NOTICES } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Purchase" };

type PageProps = {
  params: Promise<{ lineCode: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type LineRow = {
  id: number;
  line_code: string;
  material_id: number | null;
  material_code_raw: string | null;
  fabric_name_as_written: string | null;
  qty_ordered_m: number | string | null;
  line_note: string | null;
  archived_at: string | null;
  purchase_orders: {
    id: number;
    po_ref: string;
    supplier_id: number | null;
    supplier_as_written: string | null;
    po_date: string | null;
    archived_at: string | null;
  } | null;
};

export default function PurchaseLinePage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <PurchaseScreen params={props.params} searchParams={props.searchParams} />
    </Suspense>
  );
}

async function PurchaseScreen({ params, searchParams }: PageProps) {
  const gate = await gateArea("purchases");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const lineCode = decodeURIComponent((await params).lineCode);
  const notice =
    EDIT_NOTICES[firstQueryValue((await searchParams).notice) ?? ""];
  const editor = canRecordPurchase(gate.profile);
  const seeCosts = canSeeCosts(gate.profile);
  const supabase = await createClient();
  const { data } = await supabase
    .from("purchase_order_lines")
    .select(
      "id, line_code, material_id, material_code_raw, fabric_name_as_written, qty_ordered_m, line_note, archived_at, purchase_orders(id, po_ref, supplier_id, supplier_as_written, po_date, archived_at)",
    )
    .eq("line_code", lineCode)
    .maybeSingle();
  if (!data) {
    return (
      <section>
        <h1 className="font-serif text-3xl text-ink">Purchase not found</h1>
        <Link href="/purchases" className="mt-3 inline-block text-sm">
          Back to purchases
        </Link>
      </section>
    );
  }
  const line = data as unknown as LineRow;
  const po = line.purchase_orders;
  const photos = await photosForMaterials(
    line.material_id ? [line.material_id] : [],
  );
  const photo = line.material_id ? photos.get(line.material_id) : null;
  const [suppliers, materials, priceResult] = await Promise.all([
    editor
      ? supabase.from("suppliers").select("id, name").order("name")
      : Promise.resolve({ data: [] }),
    editor
      ? supabase
          .from("materials")
          .select("id, material_code")
          .order("material_code")
      : Promise.resolve({ data: [] }),
    seeCosts
      ? supabase
          .from("purchase_line_prices")
          .select("price_per_m")
          .eq("line_id", line.id)
          .maybeSingle()
      : Promise.resolve({ data: null }),
  ]);

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/purchases" className="text-sm text-muted">
        Purchases
      </Link>
      <div className="flex items-start gap-3">
        <PhotoThumb
          thumbUrl={photo?.thumbUrl ?? null}
          fullUrl={photo?.fullUrl ?? null}
          label={line.material_code_raw ?? line.line_code}
        />
        <h1 className="font-serif text-3xl text-ink">{line.line_code}</h1>
      </div>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      {editor ? (
        <form
          action={savePurchase}
          className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
        >
          <input type="hidden" name="lineId" value={line.id} />
          <input type="hidden" name="lineCode" value={line.line_code} />
          <input
            type="hidden"
            name="archivedAt"
            value={line.archived_at ?? ""}
          />
          <input
            type="hidden"
            name="poArchivedAt"
            value={po?.archived_at ?? ""}
          />
          <TextField
            id="poRef"
            name="poRef"
            label="PO reference"
            required
            defaultValue={po?.po_ref}
          />
          <SelectField
            id="supplierId"
            name="supplierId"
            label="Supplier"
            defaultValue={po?.supplier_id ? String(po.supplier_id) : ""}
          >
            <option value="">No linked supplier</option>
            {((suppliers.data ?? []) as { id: number; name: string }[]).map(
              (supplier) => (
                <option key={supplier.id} value={supplier.id}>
                  {supplier.name}
                </option>
              ),
            )}
          </SelectField>
          <TextField
            id="supplierWritten"
            name="supplierWritten"
            label="Supplier as written"
            defaultValue={po?.supplier_as_written}
          />
          <TextField
            id="poDate"
            name="poDate"
            label="PO date"
            type="date"
            defaultValue={po?.po_date}
          />
          <SelectField
            id="materialId"
            name="materialId"
            label="Material"
            defaultValue={line.material_id ? String(line.material_id) : ""}
          >
            <option value="">Not linked</option>
            {(
              (materials.data ?? []) as { id: number; material_code: string }[]
            ).map((material) => (
              <option key={material.id} value={material.id}>
                {material.material_code}
              </option>
            ))}
          </SelectField>
          <TextField
            id="materialRaw"
            name="materialRaw"
            label="Material as written"
            defaultValue={line.material_code_raw}
          />
          <TextField
            id="fabricName"
            name="fabricName"
            label="Fabric name"
            defaultValue={line.fabric_name_as_written}
          />
          <TextField
            id="qty"
            name="qty"
            label="Metres ordered"
            inputMode="decimal"
            defaultValue={line.qty_ordered_m}
          />
          <TextField
            id="price"
            name="price"
            label="Price per metre"
            inputMode="decimal"
            defaultValue={priceResult.data?.price_per_m}
          />
          <AreaField
            id="lineNote"
            name="lineNote"
            label="Note"
            defaultValue={line.line_note}
          />
          <CheckField
            name="archivePo"
            label="Archive the whole purchase order"
            defaultChecked={Boolean(po?.archived_at)}
          />
          <CheckField
            name="archive"
            label="Archive this line"
            defaultChecked={Boolean(line.archived_at)}
          />
          <SaveButton label="Save purchase" />
        </form>
      ) : (
        <p className="text-sm text-muted">
          {po?.po_ref} · {metres(line.qty_ordered_m)}
          {seeCosts && priceResult.data
            ? ` · ${money(priceResult.data.price_per_m)} / m`
            : ""}
        </p>
      )}
    </div>
  );
}
