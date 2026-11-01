export function dancerLabel(
  firstName: string,
  lastInitial: string,
): string | null {
  const first = firstName.trim();
  const last = lastInitial.trim().toUpperCase();
  if (!/^[A-Za-z][A-Za-z' -]{0,40}$/.test(first)) return null;
  if (!/^[A-Z]$/.test(last)) return null;
  return `${first} ${last}`;
}

export const SEWING_ROUTE = [
  "Prep",
  "Join body",
  "Sleeves",
  "Panty/pant",
  "Waistband",
  "Elastic/binding",
  "Coverstitch",
  "Labels",
  "Press",
  "QC",
] as const;

export const MATERIAL_KINDS = [
  { value: "fabric", label: "Fabric" },
  { value: "elastic", label: "Elastic" },
  { value: "thread", label: "Thread" },
  { value: "label", label: "Label" },
  { value: "binding", label: "Binding" },
  { value: "zipper_closure", label: "Zipper/closure" },
  { value: "embellishment", label: "Embellishment" },
  { value: "other", label: "Other" },
] as const;

export const UNIT_KINDS = [
  { value: "metres", label: "Metres" },
  { value: "units", label: "Units" },
  { value: "spools", label: "Spools" },
  { value: "pieces", label: "Pieces" },
] as const;
