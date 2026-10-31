import Link from "next/link";
import { Suspense } from "react";
import { reverseFabricUse } from "@/app/(workspace)/inventory/use-actions";
import { PhotoThumb } from "@/components/inventory/photo-thumb";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory } from "@/lib/auth/permissions";
import { gateArea } from "@/lib/auth/session";
import { firstQueryValue } from "@/lib/auth/notices";
import { metres } from "@/lib/inventory/format";
import {
  photosForMaterials,
  signedUsagePhotos,
  type MaterialPhotoLink,
} from "@/lib/inventory/photo-urls";
import {
  canReverseUsage,
  filterUsageLog,
  isIsoDate,
  summarizeUsage,
  toMetres,
  type UsageLogEntry,
  type UsagePurpose,
} from "@/lib/inventory/usage";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Usage log" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

const NOTICES: Record<string, { tone: "ok" | "error"; text: string }> = {
  reversed: {
    tone: "ok",
    text: "That entry was corrected. The metres are back on hand.",
  },
  denied: { tone: "error", text: "That entry can no longer be corrected." },
  missing: { tone: "error", text: "That entry was not found." },
  failed: { tone: "error", text: "The correction did not save." },
};

type LedgerRow = {
  id: number;
  occurred_on: string | null;
  txn_type: string;
  material_id: number | null;
  qty_m: number | string | null;
  order_id: number | null;
  style_id: number | null;
  description: string | null;
  entered_by: string | null;
  created_by: string | null;
  created_at: string;
  usage_kind: UsagePurpose | null;
  is_waste: boolean;
  reservation_drawdown_m: number | string | null;
  reverses_id: number | null;
  photo_path: string | null;
  order_number_raw: string | null;
};

type VisibleEntry = UsageLogEntry & {
  waste: boolean;
  orderId: number | null;
  styleId: number | null;
  reversed: boolean;
  txnType: string;
  createdAt: string;
  note: string | null;
  photoPath: string | null;
  materialId: number | null;
  loggedBy: string | null;
};

export default function UsagePage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <UsageScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function UsageScreen({ searchParams }: PageProps) {
  const gate = await gateArea("inventory");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const params = await searchParams;
  const notice = NOTICES[firstQueryValue(params.notice) ?? ""];
  const seeAll = canEditInventory(gate.profile);
  const material = firstQueryValue(params.material) ?? "";
  const order = firstQueryValue(params.order) ?? "";
  const style = firstQueryValue(params.style) ?? "";
  const person = firstQueryValue(params.person) ?? "";
  const from = firstQueryValue(params.from) ?? "";
  const to = firstQueryValue(params.to) ?? "";
  const kindParam = firstQueryValue(params.kind) ?? "all";
  const kind =
    kindParam === "sample" || kindParam === "production" ? kindParam : "all";

  const supabase = await createClient();
  const [
    ledgerResult,
    materialsResult,
    ordersResult,
    stylesResult,
    peopleResult,
  ] = await Promise.all([
    supabase
      .from("stock_transactions")
      .select(
        "id, occurred_on, txn_type, material_id, qty_m, order_id, style_id, description, entered_by, created_by, created_at, usage_kind, is_waste, reservation_drawdown_m, reverses_id, photo_path, order_number_raw",
      )
      .or("usage_kind.not.is.null,reverses_id.not.is.null")
      .order("created_at", { ascending: false }),
    supabase.from("materials").select("id, material_code, fabric_name"),
    supabase.from("costume_orders").select("id, order_number"),
    supabase.from("styles").select("id, style_key, garment_description"),
    seeAll
      ? supabase.from("profiles").select("id, full_name").order("full_name")
      : Promise.resolve({ data: [], error: null }),
  ]);

  if (ledgerResult.error) {
    return (
      <section className="mx-auto w-full max-w-lg">
        <h1 className="font-serif text-3xl text-ink">Usage log</h1>
        <p className="mt-2 text-sm text-muted">
          The usage log appears after the fabric-use migration is applied.
        </p>
      </section>
    );
  }

  const rows = (ledgerResult.data ?? []) as LedgerRow[];
  const byId = new Map(rows.map((row) => [row.id, row]));
  const ownIds = new Set(
    rows
      .filter((row) => row.created_by === gate.profile.id)
      .map((row) => row.id),
  );
  const visibleRows = seeAll
    ? rows
    : rows.filter(
        (row) =>
          row.created_by === gate.profile.id ||
          (row.reverses_id !== null && ownIds.has(row.reverses_id)),
      );
  const reversedIds = new Set(
    rows
      .map((row) => row.reverses_id)
      .filter((id): id is number => id !== null),
  );
  const materialName = new Map(
    (
      (materialsResult.data ?? []) as {
        id: number;
        material_code: string;
        fabric_name: string | null;
      }[]
    ).map((row) => [row.id, row]),
  );
  const orderNumber = new Map(
    ((ordersResult.data ?? []) as { id: number; order_number: string }[]).map(
      (row) => [row.id, row.order_number],
    ),
  );
  const styleLabel = new Map(
    (
      (stylesResult.data ?? []) as {
        id: number;
        style_key: string;
        garment_description: string | null;
      }[]
    ).map((row) => [
      row.id,
      [row.style_key, row.garment_description].filter(Boolean).join(" · "),
    ]),
  );
  const personName = new Map(
    ((peopleResult.data ?? []) as { id: string; full_name: string }[]).map(
      (row) => [row.id, row.full_name],
    ),
  );

  const entries: VisibleEntry[] = visibleRows.flatMap((row) => {
    const original = row.reverses_id ? byId.get(row.reverses_id) : undefined;
    const purpose = row.usage_kind ?? original?.usage_kind ?? null;
    const material = row.material_id
      ? materialName.get(row.material_id)
      : undefined;
    const qty = toMetres(row.qty_m);
    if (qty === null) return [];
    return [
      {
        id: row.id,
        createdBy: row.created_by,
        occurredOn: row.occurred_on,
        purpose,
        materialCode: material?.material_code ?? "Fabric",
        materialName: material?.fabric_name ?? null,
        orderNumber:
          (row.order_id ? orderNumber.get(row.order_id) : null) ??
          row.order_number_raw,
        styleLabel: row.style_id
          ? (styleLabel.get(row.style_id) ?? null)
          : null,
        qtyM: qty,
        waste: row.is_waste,
        orderId: row.order_id,
        styleId: row.style_id,
        reversed: reversedIds.has(row.id),
        txnType: row.txn_type,
        createdAt: row.created_at,
        note: row.description,
        photoPath: row.photo_path,
        materialId: row.material_id,
        loggedBy: row.entered_by,
      },
    ];
  });

  const filtered = filterUsageLog(entries, {
    material,
    order,
    style,
    personId: seeAll && person ? person : null,
    from: isIsoDate(from) ? from : null,
    to: isIsoDate(to) ? to : null,
    kind,
  });
  const totals = summarizeUsage(
    filtered.flatMap((entry) => {
      if (entry.txnType !== "use" || !entry.purpose) return [];
      return [
        {
          orderId: entry.orderId,
          styleId: entry.styleId,
          purpose: entry.purpose,
          waste: entry.waste,
          qtyM: entry.qtyM,
          reversed: entry.reversed,
        },
      ];
    }),
  );
  const photos = await photosForMaterials(
    filtered
      .map((entry) => entry.materialId)
      .filter((id): id is number => id !== null),
  );
  const usePhotos = await signedUsagePhotos(
    filtered
      .map((entry) => entry.photoPath)
      .filter((path): path is string => Boolean(path)),
  );
  const now = new Date();

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <div>
        <h1 className="font-serif text-3xl text-ink">Usage log</h1>
        <p className="mt-2 text-sm text-muted">
          Sample metres and production metres are totaled apart. Amounts are
          metres, not costs.
        </p>
      </div>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      <Link
        href="/inventory/use"
        className="inline-flex min-h-14 items-center justify-center rounded-full bg-ink px-4 text-lg font-medium text-white"
      >
        Log fabric use
      </Link>
      <form
        method="get"
        className="grid gap-3 rounded-2xl border border-line bg-card p-4"
      >
        <FilterField id="material" label="Fabric" defaultValue={material} />
        <FilterField id="order" label="Order" defaultValue={order} />
        <FilterField id="style" label="Style" defaultValue={style} />
        {seeAll ? (
          <label
            className="flex flex-col gap-1 text-sm font-medium"
            htmlFor="person"
          >
            Person
            <select
              id="person"
              name="person"
              defaultValue={person}
              className="min-h-12 rounded-xl border border-line bg-card px-3 text-base font-normal"
            >
              <option value="">Everyone</option>
              {(
                (peopleResult.data ?? []) as { id: string; full_name: string }[]
              ).map((personRow) => (
                <option key={personRow.id} value={personRow.id}>
                  {personRow.full_name}
                </option>
              ))}
            </select>
          </label>
        ) : null}
        <FilterField id="from" label="From" type="date" defaultValue={from} />
        <FilterField id="to" label="To" type="date" defaultValue={to} />
        <label
          className="flex flex-col gap-1 text-sm font-medium"
          htmlFor="kind"
        >
          Sample or production
          <select
            id="kind"
            name="kind"
            defaultValue={kind}
            className="min-h-12 rounded-xl border border-line bg-card px-3 text-base font-normal"
          >
            <option value="all">All</option>
            <option value="sample">Sample / development</option>
            <option value="production">Production order</option>
          </select>
        </label>
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
        >
          Apply filters
        </button>
      </form>

      <section className="flex flex-col gap-2">
        <h2 className="font-serif text-2xl text-ink">By order</h2>
        {totals.orders.length === 0 ? (
          <p className="text-sm text-muted">
            No production metres in this list.
          </p>
        ) : (
          totals.orders.map((total) => (
            <p key={total.orderId} className="text-sm text-ink">
              {orderNumber.get(total.orderId) ?? "Order"} · used{" "}
              {metres(total.usedM)}
              {total.wasteM > 0 ? ` · waste ${metres(total.wasteM)}` : ""}
            </p>
          ))
        )}
      </section>
      <section className="flex flex-col gap-2">
        <h2 className="font-serif text-2xl text-ink">By style</h2>
        {totals.styles.length === 0 ? (
          <p className="text-sm text-muted">No style metres in this list.</p>
        ) : (
          totals.styles.map((total) => (
            <p key={total.styleId} className="text-sm text-ink">
              {styleLabel.get(total.styleId) ?? "Style"} · sample{" "}
              {metres(total.sampleUsedM)}
              {total.sampleWasteM > 0
                ? ` (waste ${metres(total.sampleWasteM)})`
                : ""}
              {" · production "}
              {metres(total.productionUsedM)}
              {total.productionWasteM > 0
                ? ` (waste ${metres(total.productionWasteM)})`
                : ""}
            </p>
          ))
        )}
      </section>

      {filtered.length === 0 ? (
        <p className="text-sm text-muted">
          No fabric use matches these filters.
        </p>
      ) : (
        <ul className="flex flex-col gap-3">
          {filtered.map((entry) => {
            const materialPhoto = entry.materialId
              ? photos.get(entry.materialId)
              : undefined;
            const usePhoto = entry.photoPath
              ? usePhotos.get(entry.photoPath)
              : undefined;
            const canUndo =
              entry.txnType === "use" &&
              entry.purpose !== null &&
              canReverseUsage({
                createdBy: entry.createdBy,
                createdAt: new Date(entry.createdAt),
                alreadyReversed: entry.reversed,
                actorId: gate.profile.id,
                actorCanCorrectAny: seeAll,
                now,
              });
            return (
              <li
                key={entry.id}
                className="rounded-2xl border border-line bg-card p-4"
              >
                <div className="flex items-start gap-3">
                  <PhotoThumb
                    thumbUrl={materialPhoto?.thumbUrl ?? null}
                    fullUrl={materialPhoto?.fullUrl ?? null}
                    label={entry.materialCode}
                  />
                  <div className="min-w-0">
                    <p className="font-medium text-ink">{entry.materialCode}</p>
                    {entry.materialName ? (
                      <p className="text-sm text-muted">{entry.materialName}</p>
                    ) : null}
                    <p className="text-sm text-ink">
                      {entry.txnType === "adjust"
                        ? "Correction"
                        : entry.waste
                          ? "Waste"
                          : "Used"}{" "}
                      {metres(entry.qtyM)}
                      {entry.purpose === "sample" ? " · sample" : ""}
                      {entry.purpose === "production" ? " · production" : ""}
                    </p>
                    <p className="text-sm text-muted">
                      {[
                        entry.occurredOn,
                        entry.orderNumber,
                        entry.styleLabel,
                        seeAll
                          ? (entry.loggedBy ??
                            personName.get(entry.createdBy ?? "") ??
                            null)
                          : null,
                      ]
                        .filter(Boolean)
                        .join(" · ")}
                    </p>
                    {entry.note ? (
                      <p className="mt-1 text-sm text-ink">{entry.note}</p>
                    ) : null}
                    {entry.reversed ? (
                      <p className="mt-1 text-sm text-ink">Corrected</p>
                    ) : null}
                  </div>
                </div>
                {usePhoto ? (
                  <div className="mt-3">
                    <UsePhoto photo={usePhoto} label={entry.materialCode} />
                  </div>
                ) : null}
                {canUndo ? (
                  <form action={reverseFabricUse} className="mt-3">
                    <input type="hidden" name="entryId" value={entry.id} />
                    <button
                      type="submit"
                      className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium text-ink"
                    >
                      Undo this entry
                    </button>
                  </form>
                ) : null}
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}

function UsePhoto({
  photo,
  label,
}: {
  photo: MaterialPhotoLink;
  label: string;
}) {
  return (
    <PhotoThumb
      thumbUrl={photo.thumbUrl}
      fullUrl={photo.fullUrl}
      label={`Use photo of ${label}`}
    />
  );
}

function FilterField({
  id,
  label,
  defaultValue,
  type = "text",
}: {
  id: string;
  label: string;
  defaultValue: string;
  type?: string;
}) {
  return (
    <label className="flex flex-col gap-1 text-sm font-medium" htmlFor={id}>
      {label}
      <input
        id={id}
        name={id}
        type={type}
        defaultValue={defaultValue}
        className="min-h-12 rounded-xl border border-line bg-card px-3 text-base font-normal"
      />
    </label>
  );
}
