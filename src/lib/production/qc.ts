export type QcResult = "pass" | "needs_fix" | "fail";

export type QcCheck = {
  itemName: string;
  result: QcResult;
  resolved: boolean;
};

export function qcBlocksPickup(input: {
  templateNames: readonly string[];
  checks: readonly QcCheck[];
  hasOverride: boolean;
}): boolean {
  if (input.hasOverride) return false;
  if (input.templateNames.length === 0 || input.checks.length === 0)
    return true;
  const open = input.checks.some(
    (check) =>
      (check.result === "fail" || check.result === "needs_fix") &&
      !check.resolved,
  );
  if (open) return true;
  return input.templateNames.some(
    (name) =>
      !input.checks.some(
        (check) =>
          check.itemName === name &&
          (check.result === "pass" || check.resolved),
      ),
  );
}

export const DEFAULT_QC_ITEMS = [
  "Seams secure",
  "Elastic correct tension",
  "Size label matches",
  "Measurements in tolerance",
  "Trims and embellishments secure",
  "No loose threads",
  "Pressed",
  "Correct fabric and colour",
] as const;
