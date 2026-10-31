import Link from "next/link";
import { Suspense } from "react";
import { logStock } from "@/app/(workspace)/inventory/actions";
import {
  archivePhoto,
  setPrimaryPhoto,
} from "@/app/(workspace)/inventory/photo-actions";
import { AddPhoto } from "@/components/inventory/add-photo";
import { PhotoThumb } from "@/components/inventory/photo-thumb";
import { StockBadge } from "@/components/inventory/stock-badge";
import { MaterialForm } from "@/components/records/material-form";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory, canSeeCosts } from "@/lib/auth/permissions";
import { gateArea } from "@/lib/auth/session";
import { firstQueryValue, noticeText } from "@/lib/auth/notices";
import { metres, money } from "@/lib/inventory/format";
import { galleryForMaterial } from "@/lib/inventory/photo-urls";
import { EDIT_NOTICES } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

type DetailProps = {
  params: Promise<{ materialCode: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

const NOTICES: Record<string, string> = {
  saved: "Stock entry saved.",
  denied: "Receive and adjust are for Elaine and the owners.",
  qty: "Enter a quantity in metres.",
  type: "Choose receive or adjust.",
  failed: "That stock entry did not save.",
};

export const metadata = { title: "Material" };

export default function MaterialPage(props: DetailProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <MaterialScreen params={props.params} searchParams={props.searchParams} />
    </Suspense>
  );
}

async function MaterialScreen({ params, searchParams }: DetailProps) {
  const gate = await gateArea("inventory");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;

  const { materialCode } = await params;
  const code = decodeURIComponent(materialCode);
  const query = await searchParams;
  const noticeCode = firstQueryValue(query.notice) ?? "";
  const notice =
    NOTICES[noticeCode] ??
    noticeText(noticeCode) ??
    EDIT_NOTICES[noticeCode]?.text ??
    null;
  const noticeTone = EDIT_NOTICES[noticeCode]?.tone;
  const supabase = await createClient();
  const { data: material } = await supabase
    .from("materials")
    .select(
      "id, material_code, fabric_name, colour_name, colour_number, fabric_number, content, fabric_type, width_cm, gsm, bin_location, supplier_id, supplier_as_written, needs_review, needs_review_reason, registry_notes, registry_stock_raw, archived_at",
    )
    .eq("material_code", code)
    .maybeSingle();

  if (!material) {
    return (
      <section>
        <h1 className="font-serif text-3xl text-ink">Material not found</h1>
        <Link href="/inventory" className="mt-3 inline-block text-sm text-ink">
          Back to inventory
        </Link>
      </section>
    );
  }

  const editor = canEditInventory(gate.profile);
  const gallery = await galleryForMaterial(material.id);
  const primary = gallery.find((photo) => photo.isPrimary) ?? gallery[0];
  const [stockResult, historyResult, costResult, suppliersResult] =
    await Promise.all([
      supabase
        .from("material_availability")
        .select("on_hand_m, reserved_m, available_m, is_low_stock")
        .eq("material_id", material.id)
        .maybeSingle(),
      supabase
        .from("stock_transactions")
        .select(
          "txn_code, occurred_on, txn_type, qty_m, order_number_raw, description, entered_by",
        )
        .eq("material_id", material.id)
        .order("occurred_on", { ascending: false })
        .order("txn_code", { ascending: false }),
      canSeeCosts(gate.profile)
        ? supabase
            .from("material_costs")
            .select("list_price_per_m, net_price_per_m, discount_entered")
            .eq("material_id", material.id)
            .maybeSingle()
        : Promise.resolve({ data: null }),
      editor
        ? supabase.from("suppliers").select("id, name").order("name")
        : Promise.resolve({ data: [] }),
    ]);

  return (
    <div className="flex flex-col gap-4">
      <div>
        <Link href="/inventory" className="text-sm text-muted">
          Inventory
        </Link>
        <div className="mt-1 flex items-start gap-3">
          <PhotoThumb
            thumbUrl={primary?.thumbUrl ?? null}
            fullUrl={primary?.fullUrl ?? null}
            label={material.material_code}
          />
          <div>
            <h1 className="font-serif text-3xl text-ink">
              {material.material_code}
            </h1>
            <p className="mt-1 text-sm text-muted">
              {[material.fabric_name, material.colour_name, material.content]
                .filter(Boolean)
                .join(" · ")}
            </p>
            <p className="text-sm text-muted">
              {[
                material.supplier_as_written,
                material.bin_location ? `Bin ${material.bin_location}` : null,
                material.width_cm ? `${material.width_cm} cm` : null,
              ]
                .filter(Boolean)
                .join(" · ")}
            </p>
            {material.needs_review ? (
              <p className="mt-2 text-sm text-ink">
                {material.needs_review_reason}
              </p>
            ) : null}
            {material.registry_stock_raw ? (
              <p className="mt-1 text-sm text-muted">
                Registry stock text: {material.registry_stock_raw}
              </p>
            ) : null}
            <StockBadge
              onHand={stockResult.data?.on_hand_m ?? null}
              reserved={stockResult.data?.reserved_m ?? null}
              available={stockResult.data?.available_m ?? null}
              low={stockResult.data?.is_low_stock ?? false}
            />
            {costResult.data ? (
              <p className="mt-2 text-sm text-muted">
                List {money(costResult.data.list_price_per_m)} / m · Net{" "}
                {money(costResult.data.net_price_per_m)} / m
              </p>
            ) : null}
          </div>
        </div>
      </div>
      <section className="flex flex-col gap-3">
        <h2 className="font-serif text-2xl text-ink">Photos</h2>
        {gallery.length === 0 ? (
          <p className="text-sm text-muted">No photo yet.</p>
        ) : (
          <ul className="flex flex-col gap-3">
            {gallery.map((photo) => (
              <li
                key={photo.id}
                className="flex items-start gap-3 rounded-2xl border border-line bg-card p-3"
              >
                <PhotoThumb
                  thumbUrl={photo.thumbUrl}
                  fullUrl={photo.fullUrl}
                  label={material.material_code}
                />
                <div className="flex flex-col gap-2">
                  <p className="text-sm text-ink">
                    {photo.isPrimary ? "Primary photo" : "Extra photo"}
                  </p>
                  {editor ? (
                    <>
                      {photo.isPrimary ? null : (
                        <form action={setPrimaryPhoto}>
                          <input
                            type="hidden"
                            name="photoId"
                            value={photo.id}
                          />
                          <input
                            type="hidden"
                            name="materialCode"
                            value={material.material_code}
                          />
                          <button
                            type="submit"
                            className="min-h-11 text-sm text-ink"
                          >
                            Set as primary
                          </button>
                        </form>
                      )}
                      <form action={archivePhoto}>
                        <input type="hidden" name="photoId" value={photo.id} />
                        <input
                          type="hidden"
                          name="materialCode"
                          value={material.material_code}
                        />
                        <button
                          type="submit"
                          className="min-h-11 text-sm text-ink"
                        >
                          Archive photo
                        </button>
                      </form>
                      <AddPhoto
                        materialId={material.id}
                        replacePath={photo.storagePath}
                      />
                    </>
                  ) : null}
                </div>
              </li>
            ))}
          </ul>
        )}
        {editor ? <AddPhoto materialId={material.id} /> : null}
      </section>
      {notice ? (
        <StatusNote tone={noticeTone === "error" ? "error" : "ok"}>
          {notice}
        </StatusNote>
      ) : null}
      {editor ? (
        <MaterialForm
          material={material}
          suppliers={
            (suppliersResult.data ?? []) as { id: number; name: string }[]
          }
          cost={costResult.data}
        />
      ) : null}
      <Link
        href={`/inventory/use?material=${encodeURIComponent(material.material_code)}`}
        className="inline-flex min-h-14 items-center justify-center rounded-full bg-ink px-4 text-lg font-medium text-white"
      >
        Log fabric use
      </Link>
      {editor ? (
        <form
          action={logStock.bind(null, material.material_code)}
          className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
        >
          <h2 className="font-serif text-2xl text-ink">Log stock</h2>
          <label className="text-sm font-medium" htmlFor="txnType">
            Type
          </label>
          <select
            id="txnType"
            name="txnType"
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
            defaultValue="receive"
          >
            <option value="receive">Receive</option>
            <option value="adjust">Adjust</option>
          </select>
          <label className="text-sm font-medium" htmlFor="qty">
            Metres
          </label>
          <input
            id="qty"
            name="qty"
            inputMode="decimal"
            required
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <label className="text-sm font-medium" htmlFor="orderNumber">
            Order number
          </label>
          <input
            id="orderNumber"
            name="orderNumber"
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base"
          />
          <label className="text-sm font-medium" htmlFor="note">
            Note
          </label>
          <textarea
            id="note"
            name="note"
            className="min-h-24 rounded-xl border border-line bg-card px-3 py-2 text-base"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
          >
            Save
          </button>
        </form>
      ) : null}
      <section>
        <div className="flex items-center justify-between gap-3">
          <h2 className="font-serif text-2xl text-ink">History</h2>
          <Link
            href={`/inventory/usage?material=${encodeURIComponent(material.material_code)}`}
            className="inline-flex min-h-12 items-center text-sm text-ink"
          >
            Usage log
          </Link>
        </div>
        <ul className="mt-3 flex flex-col gap-3">
          {(historyResult.data ?? []).map((entry) => (
            <li
              key={entry.txn_code}
              className="rounded-2xl border border-line bg-card p-4 text-sm"
            >
              <p className="font-medium text-ink">
                {entry.txn_type} · {metres(entry.qty_m)}
              </p>
              <p className="text-muted">
                {[entry.occurred_on, entry.order_number_raw, entry.entered_by]
                  .filter(Boolean)
                  .join(" · ")}
              </p>
              {entry.description ? (
                <p className="mt-1 text-ink">{entry.description}</p>
              ) : null}
            </li>
          ))}
        </ul>
      </section>
    </div>
  );
}
