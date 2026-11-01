import { roundMetres } from "../inventory/usage.ts";

export type SizePiece = { sizeCode: string; metresPerPiece: number };
export type SizeCount = { sizeCode: string; count: number };

export function fabricNeeded(input: {
  sizePieces: readonly SizePiece[];
  sizeCounts: readonly SizeCount[];
  wastePercent: number | null;
  estimateMetresPerPiece: number | null;
  isEstimate: boolean;
}): { metres: number; estimate: boolean } {
  const factor = 1 + Math.max(0, input.wastePercent ?? 0) / 100;
  const counts = new Map(
    input.sizeCounts.map((size) => [size.sizeCode, size.count]),
  );
  if (input.sizePieces.length > 0) {
    const raw = input.sizePieces.reduce(
      (sum, size) =>
        sum + size.metresPerPiece * (counts.get(size.sizeCode) ?? 0),
      0,
    );
    return { metres: roundMetres(raw * factor), estimate: false };
  }
  if (input.isEstimate && input.estimateMetresPerPiece !== null) {
    const pieces = input.sizeCounts.reduce((sum, size) => sum + size.count, 0);
    return {
      metres: roundMetres(input.estimateMetresPerPiece * pieces * factor),
      estimate: true,
    };
  }
  return { metres: 0, estimate: input.isEstimate };
}

export function shortageMetres(
  needed: number,
  available: number | null,
): number | null {
  if (available === null) return null;
  return roundMetres(Math.max(0, needed - available));
}

export function reserveQuantity(
  needed: number,
  alreadyReserved: number,
): number {
  return roundMetres(Math.max(0, needed - alreadyReserved));
}
