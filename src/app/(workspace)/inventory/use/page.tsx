import Link from "next/link";
import { Suspense } from "react";
import { LogUseForm } from "@/components/inventory/log-use-form";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canEditInventory } from "@/lib/auth/permissions";
import { gateArea } from "@/lib/auth/session";
import { firstQueryValue } from "@/lib/auth/notices";
import { metres } from "@/lib/inventory/format";
import { photosForMaterials } from "@/lib/inventory/photo-urls";
import type { InventoryMaterial } from "@/lib/inventory/search";
import {
  todayInToronto,
  toMetres,
  type FabricLineOption,
  type FabricOrderOption,
  type FabricStyleOption,
  type ReservationSlice,
  type UsagePurpose,
} from "@/lib/inventory/usage";
import { orderChoiceLabel, toOrderChoice } from "@/lib/orders/label";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Log material use" };

const GROUP_ID =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function LogUsePage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <LogUseScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function LogUseScreen({ searchParams }: PageProps) {
  const gate = await gateArea("inventory");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const params = await searchParams;
  const logged = firstQueryValue(params.logged) ?? "";
  if (GROUP_ID.test(logged)) {
    return (
      <LoggedUse
        groupId={logged}
        userId={gate.profile.id}
        canSeeAll={canEditInventory(gate.profile)}
      />
    );
  }

  const materialCode = firstQueryValue(params.material) ?? "";
  const supabase = await createClient();
  const [
    materialsResult,
    stockResult,
    ordersResult,
    stylesResult,
    linesResult,
    reservationResult,
  ] = await Promise.all([
    supabase
      .from("materials")
      .select(
        "id, material_code, fabric_name, colour_name, fabric_type, content",
      )
      .is("archived_at", null)
      .order("material_code"),
    supabase
      .from("material_availability")
      .select("material_id, on_hand_m, reserved_m, available_m, is_low_stock"),
    supabase
      .from("costume_orders")
      .select(
        "id, order_number, production_song, status, archived_at, programs(name)",
      )
      .order("order_number"),
    supabase
      .from("styles")
      .select("id, style_key, garment_description, order_id, archived_at")
      .order("style_key"),
    supabase
      .from("bom_lines")
      .select(
        "id, line_code, order_id, style_id, material_id, fabric_name, fabric_as_written, archived_at",
      ),
    supabase
      .from("stock_transactions")
      .select(
        "id, material_id, order_id, txn_type, qty_m, usage_kind, is_waste, reservation_drawdown_m, reverses_id",
      )
      .in("txn_type", ["reserve", "use", "adjust"])
      .not("order_id", "is", null),
  ]);

  if (materialsResult.error) {
    return <p className="text-sm text-muted">The fabric list did not load.</p>;
  }

  const stock = new Map(
    (
      (stockResult.data ?? []) as {
        material_id: number;
        on_hand_m: number | string | null;
        reserved_m: number | string | null;
        available_m: number | string | null;
        is_low_stock: boolean;
      }[]
    ).map((row) => [row.material_id, row]),
  );
  const materialRows = (materialsResult.data ?? []) as {
    id: number;
    material_code: string;
    fabric_name: string | null;
    colour_name: string | null;
    fabric_type: string | null;
    content: string | null;
  }[];
  const photos = await photosForMaterials(materialRows.map((row) => row.id));
  const materials: InventoryMaterial[] = materialRows.map((material) => {
    const levels = stock.get(material.id);
    return {
      id: material.id,
      materialCode: material.material_code,
      fabricName: material.fabric_name,
      colourName: material.colour_name,
      fabricType: material.fabric_type,
      content: material.content,
      supplierName: null,
      binLocation: null,
      needsReview: false,
      onHandM: toMetres(levels?.on_hand_m),
      reservedM: toMetres(levels?.reserved_m),
      availableM: toMetres(levels?.available_m),
      isLowStock: levels?.is_low_stock ?? false,
      photoThumbUrl: photos.get(material.id)?.thumbUrl ?? null,
      photoFullUrl: photos.get(material.id)?.fullUrl ?? null,
    };
  });
  const initial = materials.find(
    (material) => material.materialCode === materialCode,
  );

  const orders: FabricOrderOption[] = (
    (ordersResult.data ?? []) as {
      id: number;
      order_number: string;
      production_song: string | null;
      status: string | null;
      archived_at: string | null;
      programs: { name: string } | { name: string }[] | null;
    }[]
  )
    .filter((order) => !order.archived_at && order.status !== "cancelled")
    .map((order) => ({
      id: order.id,
      orderNumber: order.order_number,
      label: orderChoiceLabel(toOrderChoice(order)),
    }));

  const styles: FabricStyleOption[] = (
    (stylesResult.data ?? []) as {
      id: number;
      style_key: string;
      garment_description: string | null;
      order_id: number | null;
      archived_at: string | null;
    }[]
  )
    .filter((style) => !style.archived_at)
    .map((style) => ({
      id: style.id,
      orderId: style.order_id,
      label: clip([style.style_key, style.garment_description]),
    }));

  const lines: FabricLineOption[] = (
    (linesResult.data ?? []) as {
      id: number;
      line_code: string;
      order_id: number | null;
      style_id: number | null;
      material_id: number | null;
      fabric_name: string | null;
      fabric_as_written: string | null;
      archived_at: string | null;
    }[]
  )
    .filter((line) => !line.archived_at)
    .map((line) => ({
      id: line.id,
      orderId: line.order_id,
      styleId: line.style_id,
      materialId: line.material_id,
      label: clip([line.line_code, line.fabric_name, line.fabric_as_written]),
    }));

  const reservations: ReservationSlice[] = reservationResult.error
    ? []
    : (
        (reservationResult.data ?? []) as {
          id: number;
          material_id: number | null;
          order_id: number | null;
          txn_type: string;
          qty_m: number | string | null;
          usage_kind: string | null;
          is_waste: boolean;
          reservation_drawdown_m: number | string | null;
          reverses_id: number | null;
        }[]
      ).flatMap((row) => {
        const txnType = asTxn(row.txn_type);
        if (!txnType || row.material_id === null || row.order_id === null)
          return [];
        return [
          {
            id: row.id,
            materialId: row.material_id,
            orderId: row.order_id,
            txnType,
            qtyM: toMetres(row.qty_m),
            usageKind: asKind(row.usage_kind),
            waste: row.is_waste,
            drawdownM: toMetres(row.reservation_drawdown_m),
            reversesId: row.reverses_id,
          },
        ];
      });

  return (
    <div className="flex flex-col gap-3">
      {reservationResult.error ? (
        <p className="mx-auto w-full max-w-lg text-sm text-muted">
          Reservation totals appear after the fabric-use migration is applied.
        </p>
      ) : null}
      <LogUseForm
        materials={materials}
        orders={orders}
        styles={styles}
        lines={lines}
        reservations={reservations}
        initialMaterialId={initial?.id ?? null}
        today={todayInToronto()}
        userId={gate.profile.id}
      />
      <p className="mx-auto w-full max-w-lg">
        <Link
          href="/inventory/usage"
          className="inline-flex min-h-12 items-center text-sm text-ink"
        >
          Usage log
        </Link>
      </p>
    </div>
  );
}

async function LoggedUse({
  groupId,
  userId,
  canSeeAll,
}: {
  groupId: string;
  userId: string;
  canSeeAll: boolean;
}) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("stock_transactions")
    .select(
      "id, qty_m, is_waste, material_id, material_code_raw, created_by, usage_kind",
    )
    .eq("usage_group", groupId);
  const rows = (data ?? []) as {
    id: number;
    qty_m: number | string | null;
    is_waste: boolean;
    material_id: number | null;
    material_code_raw: string | null;
    created_by: string | null;
    usage_kind: string | null;
  }[];
  const visible = rows.filter((row) => canSeeAll || row.created_by === userId);
  if (visible.length === 0) {
    return (
      <section className="mx-auto w-full max-w-lg">
        <h1 className="font-serif text-3xl text-ink">Use logged</h1>
        <p className="mt-2 text-sm text-muted">That entry was not found.</p>
      </section>
    );
  }
  const materialId = visible[0]?.material_id ?? null;
  const code = visible[0]?.material_code_raw;
  const { data: stock } = materialId
    ? await supabase
        .from("material_availability")
        .select("on_hand_m, available_m")
        .eq("material_id", materialId)
        .maybeSingle()
    : { data: null };
  const levels = stock as {
    on_hand_m: number | string | null;
    available_m: number | string | null;
  } | null;

  return (
    <section className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Use logged</h1>
      <div className="rounded-2xl border border-line bg-card p-4">
        {code ? (
          <p className="font-medium text-ink">
            <Link href={`/inventory/${encodeURIComponent(code)}`}>{code}</Link>
          </p>
        ) : null}
        {visible.map((row) => (
          <p key={row.id} className="mt-1 text-sm text-ink">
            {row.is_waste ? "Waste" : "Used"} {metres(row.qty_m)}
            {row.usage_kind === "sample" ? " · sample" : ""}
            {row.usage_kind === "production" ? " · production" : ""}
          </p>
        ))}
        <p className="mt-3 text-sm text-ink">
          On hand now {metres(levels?.on_hand_m)}
        </p>
        <p className="text-sm text-ink">
          Available now {metres(levels?.available_m)}
        </p>
      </div>
      <Link
        href={
          code
            ? `/inventory/use?material=${encodeURIComponent(code)}`
            : "/inventory/use"
        }
        className="inline-flex min-h-14 items-center justify-center rounded-full bg-ink px-4 text-lg font-medium text-white"
      >
        Log another
      </Link>
      <Link
        href="/inventory/usage"
        className="inline-flex min-h-12 items-center text-sm text-ink"
      >
        Usage log
      </Link>
    </section>
  );
}

function clip(parts: (string | null | undefined)[]): string {
  const text = parts
    .map((part) => part?.trim())
    .filter((part): part is string => Boolean(part))
    .join(" · ");
  return text.length > 90 ? `${text.slice(0, 89)}…` : text;
}

function asKind(value: string | null): UsagePurpose | null {
  return value === "sample" || value === "production" ? value : null;
}

function asTxn(value: string): ReservationSlice["txnType"] | null {
  if (
    value === "reserve" ||
    value === "use" ||
    value === "adjust" ||
    value === "receive" ||
    value === "return"
  ) {
    return value;
  }
  return null;
}
