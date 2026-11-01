import { Suspense } from "react";
import { OrderTabs } from "@/components/orders/order-tabs";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { PRODUCTION_STATUSES } from "@/lib/orders/production-status";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Size export" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function SizesPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <SizesScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function SizesScreen({ searchParams }: PageProps) {
  const gate = await gateArea("production-orders");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const params = await searchParams;
  const program = firstQueryValue(params.program) ?? "";
  const status = firstQueryValue(params.status) ?? "";
  const supabase = await createClient();
  const { data: programs } = await supabase
    .from("programs")
    .select("id, name")
    .order("name");
  const query = new URLSearchParams();
  if (program) query.set("program", program);
  if (status) query.set("status", status);
  const suffix = query.toString();
  const href = (shape: "long" | "wide", sheets: boolean) => {
    const next = new URLSearchParams(suffix);
    next.set("shape", shape);
    if (sheets) next.set("sheets", "1");
    return `/production-orders/sizes/export?${next.toString()}`;
  };

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Size export</h1>
      <OrderTabs current="sizes" />
      <p className="text-sm text-muted">
        Long format is one row per order, style, and size. Wide format is the
        same grid as the order page. In Google Sheets, choose File, then Import,
        then Upload. Program directors only receive their own orders.
      </p>
      <form className="flex flex-col gap-2" method="get">
        <label className="text-sm font-medium" htmlFor="program">
          Program
        </label>
        <select
          id="program"
          name="program"
          defaultValue={program}
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <option value="">Every program</option>
          <option value="none">No program</option>
          {((programs ?? []) as { id: number; name: string }[]).map((item) => (
            <option key={item.id} value={item.id}>
              {item.name}
            </option>
          ))}
        </select>
        <label className="text-sm font-medium" htmlFor="status">
          Status
        </label>
        <select
          id="status"
          name="status"
          defaultValue={status}
          className="min-h-12 rounded-xl border border-line bg-card px-3"
        >
          <option value="">Every status</option>
          <option value="cancelled">Cancelled</option>
          {PRODUCTION_STATUSES.map((item) => (
            <option key={item.value} value={item.value}>
              {item.label}
            </option>
          ))}
        </select>
        <button
          type="submit"
          className="min-h-12 rounded-full bg-ink px-4 text-sm font-medium text-white"
        >
          Apply filter
        </button>
      </form>
      <div className="flex flex-col gap-2">
        <a
          className="inline-flex min-h-12 items-center text-ink"
          href={href("long", false)}
        >
          Download long CSV
        </a>
        <a
          className="inline-flex min-h-12 items-center text-ink"
          href={href("wide", false)}
        >
          Download wide CSV
        </a>
        <a
          className="inline-flex min-h-12 items-center text-ink"
          href={href("long", true)}
        >
          Export long CSV to Google Sheets
        </a>
        <a
          className="inline-flex min-h-12 items-center text-ink"
          href={href("wide", true)}
        >
          Export wide CSV to Google Sheets
        </a>
      </div>
    </div>
  );
}
