import { canAccessArea } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { isProductionStatus } from "@/lib/orders/production-status";
import { longSizeCsv, wideSizeCsv } from "@/lib/orders/size-grid";
import { createClient } from "@/lib/supabase/server";

export async function GET(request: Request) {
  const state = await getSessionState();
  if (state.status !== "ready") {
    return new Response("Sign in required", { status: 401 });
  }
  if (!canAccessArea(state.profile, "production-orders")) {
    return new Response("Not available", { status: 403 });
  }
  const url = new URL(request.url);
  const shape = url.searchParams.get("shape") === "wide" ? "wide" : "long";
  const sheets = url.searchParams.get("sheets") === "1";
  const program = url.searchParams.get("program") ?? "";
  const status = url.searchParams.get("status") ?? "";
  const supabase = await createClient();
  let ordersQuery = supabase
    .from("costume_orders")
    .select(
      "id, order_number, production_status, status, program_id, programs(name)",
    )
    .is("archived_at", null)
    .order("order_number");
  if (status === "cancelled")
    ordersQuery = ordersQuery.eq("status", "cancelled");
  else if (isProductionStatus(status)) {
    ordersQuery = ordersQuery
      .eq("production_status", status)
      .is("status", null);
  }
  if (program === "none") ordersQuery = ordersQuery.is("program_id", null);
  else if (/^\d+$/.test(program)) {
    ordersQuery = ordersQuery.eq("program_id", Number(program));
  }
  const [ordersResult, scaleResult] = await Promise.all([
    ordersQuery,
    supabase
      .from("size_scale")
      .select("size_code")
      .is("archived_at", null)
      .order("sort_order"),
  ]);
  const orders = (ordersResult.data ?? []) as {
    id: number;
    order_number: string;
    programs: { name: string } | { name: string }[] | null;
  }[];
  const orderIds = orders.map((order) => order.id);
  const stylesResult =
    orderIds.length === 0
      ? { data: [] }
      : await supabase
          .from("styles")
          .select("id, order_id, style_key, garment_description")
          .in("order_id", orderIds)
          .is("archived_at", null)
          .order("style_key");
  const styles = (stylesResult.data ?? []) as {
    id: number;
    order_id: number;
    style_key: string;
    garment_description: string | null;
  }[];
  const styleIds = styles.map((style) => style.id);
  const sizesResult =
    styleIds.length === 0
      ? { data: [] }
      : await supabase
          .from("order_sizes")
          .select("style_id, size_code, qty")
          .in("style_id", styleIds);
  const columns = ((scaleResult.data ?? []) as { size_code: string }[]).map(
    (size) => size.size_code,
  );
  const orderById = new Map(orders.map((order) => [order.id, order]));
  const qtyByStyle = new Map<number, Record<string, number | null>>();
  for (const row of (sizesResult.data ?? []) as {
    style_id: number;
    size_code: string;
    qty: number | null;
  }[]) {
    const current = qtyByStyle.get(row.style_id) ?? {};
    current[row.size_code] = row.qty;
    qtyByStyle.set(row.style_id, current);
  }
  const wideRows = styles.map((style) => {
    const order = orderById.get(style.order_id);
    const program = programName(order?.programs ?? null);
    return {
      orderNumber: order?.order_number ?? "",
      program,
      style: style.garment_description ?? style.style_key,
      qty: qtyByStyle.get(style.id) ?? {},
    };
  });
  const filename = `all-orders-sizes-${shape}${sheets ? "-google-sheets" : ""}.csv`;
  if (shape === "wide") {
    return csvResponse(wideSizeCsv({ columns, rows: wideRows }), filename);
  }
  const longRows = wideRows.flatMap((row) =>
    columns.flatMap((code) => {
      const quantity = row.qty[code];
      if (quantity === null || quantity === undefined) return [];
      return [
        {
          orderNumber: row.orderNumber,
          program: row.program,
          style: row.style,
          size: code,
          quantity,
        },
      ];
    }),
  );
  return csvResponse(longSizeCsv(longRows), filename);
}

function programName(
  programs: { name: string } | { name: string }[] | null,
): string {
  if (!programs) return "";
  if (Array.isArray(programs)) return programs[0]?.name ?? "";
  return programs.name;
}

function csvResponse(body: string, filename: string) {
  return new Response(body, {
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="${filename}"`,
    },
  });
}
