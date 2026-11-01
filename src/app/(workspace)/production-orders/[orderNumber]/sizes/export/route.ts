import { canAccessArea } from "@/lib/auth/permissions";
import { getSessionState } from "@/lib/auth/session";
import { orderGridCsv, type GridRow } from "@/lib/orders/size-grid";
import { createClient } from "@/lib/supabase/server";

type StyleRow = {
  id: number;
  style_key: string;
  garment_description: string | null;
};

export async function GET(
  request: Request,
  context: { params: Promise<{ orderNumber: string }> },
) {
  const state = await getSessionState();
  if (state.status !== "ready") {
    return new Response("Sign in required", { status: 401 });
  }
  if (!canAccessArea(state.profile, "production-orders")) {
    return new Response("Not available", { status: 403 });
  }
  const orderNumber = decodeURIComponent((await context.params).orderNumber);
  const sheets = new URL(request.url).searchParams.get("sheets") === "1";
  const supabase = await createClient();
  const { data: order } = await supabase
    .from("costume_orders")
    .select("id, order_number")
    .eq("order_number", orderNumber)
    .maybeSingle();
  if (!order) return new Response("Order not found", { status: 404 });
  const [scaleResult, stylesResult, sizesResult] = await Promise.all([
    supabase
      .from("size_scale")
      .select("size_code")
      .is("archived_at", null)
      .order("sort_order"),
    supabase
      .from("styles")
      .select("id, style_key, garment_description")
      .eq("order_id", order.id)
      .is("archived_at", null)
      .order("style_key"),
    supabase
      .from("order_sizes")
      .select("style_id, size_code, qty")
      .eq("order_id", order.id),
  ]);
  const columns = ((scaleResult.data ?? []) as { size_code: string }[]).map(
    (size) => size.size_code,
  );
  const qty = new Map<string, number | null>();
  for (const row of (sizesResult.data ?? []) as {
    style_id: number;
    size_code: string;
    qty: number | null;
  }[]) {
    qty.set(`${row.style_id}:${row.size_code}`, row.qty);
  }
  const rows: GridRow[] = ((stylesResult.data ?? []) as StyleRow[]).map(
    (style) => ({
      label: style.garment_description ?? style.style_key,
      qty: Object.fromEntries(
        columns.map((code) => [code, qty.get(`${style.id}:${code}`) ?? null]),
      ),
    }),
  );
  const filename = sheets
    ? `order-${order.order_number}-sizes-google-sheets.csv`
    : `order-${order.order_number}-sizes.csv`;
  return csvResponse(orderGridCsv({ columns, rows }), filename);
}

function csvResponse(body: string, filename: string) {
  return new Response(body, {
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="${filename}"`,
    },
  });
}
