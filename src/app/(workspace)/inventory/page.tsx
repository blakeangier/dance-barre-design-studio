import { Suspense } from "react";
import { InventoryBrowser } from "@/components/inventory/inventory-browser";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canEditInventory } from "@/lib/auth/permissions";
import { gateArea } from "@/lib/auth/session";
import { firstQueryValue } from "@/lib/auth/notices";
import { photosForMaterials } from "@/lib/inventory/photo-urls";
import {
  supplierSearchText,
  type InventoryMaterial,
} from "@/lib/inventory/search";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Inventory" };

type InventoryProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type SupplierEmbed = { name: string | null } | null;

type MaterialRow = {
  id: number;
  material_code: string;
  fabric_name: string | null;
  colour_name: string | null;
  fabric_type: string | null;
  content: string | null;
  bin_location: string | null;
  needs_review: boolean;
  supplier_as_written: string | null;
  suppliers: SupplierEmbed | SupplierEmbed[];
};

type StockRow = {
  material_id: number;
  on_hand_m: number | string | null;
  reserved_m: number | string | null;
  available_m: number | string | null;
  is_low_stock: boolean;
};

function asNumber(value: number | string | null | undefined): number | null {
  if (value === null || value === undefined || value === "") return null;
  const number = typeof value === "number" ? value : Number(value);
  return Number.isFinite(number) ? number : null;
}

function linkedSupplierName(
  suppliers: MaterialRow["suppliers"],
): string | null {
  const linked = Array.isArray(suppliers) ? suppliers[0] : suppliers;
  return linked?.name ?? null;
}

export default function InventoryPage(props: InventoryProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <InventoryScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function InventoryScreen({
  searchParams,
}: {
  searchParams: InventoryProps["searchParams"];
}) {
  const gate = await gateArea("inventory");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;

  const params = await searchParams;
  const showArchived = firstQueryValue(params.archived) === "1";
  const supabase = await createClient();
  let materialsQuery = supabase
    .from("materials")
    .select(
      "id, material_code, fabric_name, colour_name, fabric_type, content, bin_location, needs_review, supplier_as_written, suppliers(name)",
    )
    .order("material_code");
  if (!showArchived) materialsQuery = materialsQuery.is("archived_at", null);
  const [materialsResult, stockResult] = await Promise.all([
    materialsQuery,
    supabase
      .from("material_availability")
      .select("material_id, on_hand_m, reserved_m, available_m, is_low_stock"),
  ]);

  const stock = new Map(
    ((stockResult.data ?? []) as StockRow[]).map((row) => [
      row.material_id,
      row,
    ]),
  );
  const materialRows = (materialsResult.data ?? []) as MaterialRow[];
  const photos = await photosForMaterials(materialRows.map((row) => row.id));
  const items: InventoryMaterial[] = materialRows.map((material) => {
    const levels = stock.get(material.id);
    return {
      id: material.id,
      materialCode: material.material_code,
      fabricName: material.fabric_name,
      colourName: material.colour_name,
      fabricType: material.fabric_type,
      content: material.content,
      supplierName: supplierSearchText(
        linkedSupplierName(material.suppliers),
        material.supplier_as_written,
      ),
      binLocation: material.bin_location,
      needsReview: material.needs_review,
      onHandM: asNumber(levels?.on_hand_m),
      reservedM: asNumber(levels?.reserved_m),
      availableM: asNumber(levels?.available_m),
      isLowStock: levels?.is_low_stock ?? false,
      photoThumbUrl: photos.get(material.id)?.thumbUrl ?? null,
      photoFullUrl: photos.get(material.id)?.fullUrl ?? null,
    };
  });

  return (
    <InventoryBrowser
      items={items}
      loadError={Boolean(materialsResult.error)}
      initialQuery={firstQueryValue(params.q) ?? ""}
      initialType={firstQueryValue(params.type) ?? ""}
      initialLow={firstQueryValue(params.low) === "1"}
      initialReview={firstQueryValue(params.review) === "1"}
      showArchived={showArchived}
      missingPhoto={firstQueryValue(params.nophoto) === "1"}
      canEdit={canEditInventory(gate.profile)}
    />
  );
}
