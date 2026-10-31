import type { ReactNode } from "react";
import { archiveFinanceRow } from "@/app/(workspace)/finances/workbook-actions";
import { FinanceTabs, type FinanceTab } from "@/components/finances/tabs";
import { StatusNote } from "@/components/shell/status-note";
import { sourceText } from "@/lib/finances/workbook";

export const financeField =
  "min-h-12 rounded-xl border border-line bg-card px-3";
export const financeButton =
  "min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white";

export function FinanceFrame({
  title,
  current,
  notice,
  lede,
  wide = false,
  children,
}: {
  title: string;
  current?: FinanceTab;
  notice?: string | null;
  lede?: string;
  wide?: boolean;
  children: ReactNode;
}) {
  return (
    <div
      className={`mx-auto flex w-full flex-col gap-4 ${wide ? "max-w-6xl" : "max-w-3xl"}`}
    >
      <h1 className="font-serif text-3xl text-ink">{title}</h1>
      <FinanceTabs current={current} />
      {lede ? <p className="text-sm text-muted">{lede}</p> : null}
      {notice === "saved" ? <StatusNote>Saved.</StatusNote> : null}
      {notice === "failed" ? (
        <StatusNote tone="error">That did not save.</StatusNote>
      ) : null}
      {children}
    </div>
  );
}

export function SourceLine({ note }: { note: string | null | undefined }) {
  return <p className="text-muted">Source: {sourceText(note)}</p>;
}

export function ArchiveForm({
  table,
  id,
  back,
}: {
  table: string;
  id: number;
  back: string;
}) {
  return (
    <form action={archiveFinanceRow}>
      <input type="hidden" name="table" value={table} />
      <input type="hidden" name="id" value={id} />
      <input type="hidden" name="back" value={back} />
      <button type="submit" className="min-h-11 text-sm font-medium">
        Archive
      </button>
    </form>
  );
}
