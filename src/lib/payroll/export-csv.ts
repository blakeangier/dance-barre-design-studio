export type PayrollExportRow = {
  employeeName: string;
  periodStart: string;
  periodEnd: string;
  regularHours: number;
  totalHours: number;
  notes: string;
};

// Contractors are paid by e-transfer, so their timesheets stay out of this file.
// profiles.employment_type gains 'contractor' in the inventory migration
// 20261031052000_contractor_employment.sql.
export function includeInPayrollExport(
  employmentType: string | null | undefined,
): boolean {
  return employmentType !== "contractor";
}

function cell(value: string | number): string {
  const text = String(value);
  if (/[",\n]/.test(text)) return `"${text.replaceAll('"', '""')}"`;
  return text;
}

export function payrollCsv(rows: PayrollExportRow[]): string {
  const header = [
    "employee_name",
    "pay_period_start",
    "pay_period_end",
    "regular_hours",
    "total_hours",
    "notes",
  ];
  const lines = [
    "# Not an ADP import file. Rebecca's ADP template is not in yet. Unpaid breaks are already subtracted. Overtime is not calculated.",
    header.join(","),
    ...rows.map((row) =>
      [
        cell(row.employeeName),
        cell(row.periodStart),
        cell(row.periodEnd),
        cell(row.regularHours),
        cell(row.totalHours),
        cell(row.notes),
      ].join(","),
    ),
  ];
  return `${lines.join("\n")}\n`;
}
