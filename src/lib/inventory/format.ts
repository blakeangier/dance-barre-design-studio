export function money(value: number | string | null | undefined): string {
  if (value === null || value === undefined || value === "") return "—";
  const number = typeof value === "number" ? value : Number(value);
  if (Number.isNaN(number)) return "—";
  return number.toLocaleString("en-CA", {
    style: "currency",
    currency: "CAD",
  });
}

export function metres(value: number | string | null | undefined): string {
  if (value === null || value === undefined || value === "") return "—";
  const number = typeof value === "number" ? value : Number(value);
  if (Number.isNaN(number)) return "—";
  return `${number.toLocaleString("en-CA", { maximumFractionDigits: 2 })} m`;
}
