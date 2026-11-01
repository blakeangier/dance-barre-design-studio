export const SUGGESTION_LIMIT = 8;

export type InventoryMaterial = {
  id: number;
  materialCode: string;
  fabricName: string | null;
  colourName: string | null;
  fabricType: string | null;
  content: string | null;
  supplierName: string | null;
  binLocation: string | null;
  needsReview: boolean;
  onHandM: number | null;
  reservedM: number | null;
  availableM: number | null;
  isLowStock: boolean;
  photoThumbUrl?: string | null;
  photoFullUrl?: string | null;
};

export type InventoryFilters = {
  query: string;
  type: string;
  lowOnly: boolean;
  reviewOnly: boolean;
};

export function supplierSearchText(
  linkedName: string | null | undefined,
  writtenName: string | null | undefined,
): string | null {
  const linked = linkedName?.trim() ?? "";
  const written = writtenName?.trim() ?? "";
  if (!linked) return written || null;
  if (!written || linked.toLowerCase() === written.toLowerCase()) return linked;
  return `${linked} ${written}`;
}

export function materialHaystack(material: InventoryMaterial): string {
  return [
    material.materialCode,
    material.fabricName,
    material.colourName,
    material.fabricType,
    material.content,
    material.supplierName,
  ]
    .filter((part): part is string => Boolean(part && part.trim()))
    .join(" ")
    .toLowerCase();
}

// Each word is matched on its own, so F002-125 matches "f002", "125", and "002-12".
export function matchesMaterialQuery(
  material: InventoryMaterial,
  query: string,
): boolean {
  const normalized = query.trim().toLowerCase();
  if (!normalized) return true;
  const haystack = materialHaystack(material);
  return normalized.split(/\s+/).every((token) => haystack.includes(token));
}

export function matchesInventoryFilters(
  material: InventoryMaterial,
  filters: InventoryFilters,
): boolean {
  if (!matchesMaterialQuery(material, filters.query)) return false;
  const type = filters.type.trim().toLowerCase();
  if (type) {
    const kind =
      `${material.fabricType ?? ""} ${material.content ?? ""}`.toLowerCase();
    if (!kind.includes(type)) return false;
  }
  if (filters.lowOnly && !material.isLowStock) return false;
  if (filters.reviewOnly && !material.needsReview) return false;
  return true;
}

export function filterMaterials(
  materials: readonly InventoryMaterial[],
  filters: InventoryFilters,
): InventoryMaterial[] {
  return materials.filter((material) =>
    matchesInventoryFilters(material, filters),
  );
}

export function suggestMaterials(
  materials: readonly InventoryMaterial[],
  filters: InventoryFilters,
  limit = SUGGESTION_LIMIT,
): InventoryMaterial[] {
  if (!filters.query.trim()) return [];
  return filterMaterials(materials, filters).slice(0, limit);
}
