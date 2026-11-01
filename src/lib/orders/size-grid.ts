export type SizeColumn = { code: string; sortOrder: number };

export type GridRow = {
  label: string;
  qty: Record<string, number | null>;
};

export function countsForStyle(
  sizes: readonly { styleId: number | null; sizeCode: string; count: number }[],
  styleId: number | null,
): { sizeCode: string; count: number }[] {
  const relevant =
    styleId === null ? sizes : sizes.filter((size) => size.styleId === styleId);
  const totals = new Map<string, number>();
  for (const size of relevant) {
    totals.set(size.sizeCode, (totals.get(size.sizeCode) ?? 0) + size.count);
  }
  return [...totals].map(([sizeCode, count]) => ({ sizeCode, count }));
}

export function gridTotals(
  columns: readonly string[],
  rows: readonly GridRow[],
): { rowTotals: number[]; columnTotals: number[]; grand: number } {
  const rowTotals = rows.map((row) =>
    columns.reduce((sum, code) => sum + (row.qty[code] ?? 0), 0),
  );
  const columnTotals = columns.map((code) =>
    rows.reduce((sum, row) => sum + (row.qty[code] ?? 0), 0),
  );
  const grand = rowTotals.reduce((sum, total) => sum + total, 0);
  return { rowTotals, columnTotals, grand };
}

function csvCell(value: string): string {
  if (/[",\r\n]/.test(value)) return `"${value.replaceAll('"', '""')}"`;
  return value;
}

export function toCsv(rows: readonly (readonly string[])[]): string {
  const body = rows.map((row) => row.map(csvCell).join(",")).join("\r\n");
  return `\uFEFF${body}\r\n`;
}

export function orderGridCsv(input: {
  columns: readonly string[];
  rows: readonly GridRow[];
}): string {
  const totals = gridTotals(input.columns, input.rows);
  const header = ["Style", ...input.columns, "Total"];
  const body = input.rows.map((row, index) => [
    row.label,
    ...input.columns.map((code) => formatQty(row.qty[code])),
    String(totals.rowTotals[index] ?? 0),
  ]);
  const footer = [
    "Total",
    ...totals.columnTotals.map((total) => String(total)),
    String(totals.grand),
  ];
  return toCsv([header, ...body, footer]);
}

export function longSizeCsv(
  rows: readonly {
    orderNumber: string;
    program: string;
    style: string;
    size: string;
    quantity: number;
  }[],
): string {
  return toCsv([
    ["Order", "Program", "Style", "Size", "Quantity"],
    ...rows.map((row) => [
      row.orderNumber,
      row.program,
      row.style,
      row.size,
      String(row.quantity),
    ]),
  ]);
}

export function wideSizeCsv(input: {
  columns: readonly string[];
  rows: readonly {
    orderNumber: string;
    program: string;
    style: string;
    qty: Record<string, number | null>;
  }[];
}): string {
  const header = ["Order", "Program", "Style", ...input.columns, "Total"];
  const body = input.rows.map((row) => {
    const total = input.columns.reduce(
      (sum, code) => sum + (row.qty[code] ?? 0),
      0,
    );
    return [
      row.orderNumber,
      row.program,
      row.style,
      ...input.columns.map((code) => formatQty(row.qty[code])),
      String(total),
    ];
  });
  return toCsv([header, ...body]);
}

function formatQty(value: number | null | undefined): string {
  if (value === null || value === undefined) return "";
  return String(value);
}
