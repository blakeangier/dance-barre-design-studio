import { redirect } from "next/navigation";
import { financesStatus } from "@/lib/finances/access";
import { parseCardCsv } from "@/lib/finances/money";
import { getSessionState } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

export async function POST(request: Request) {
  const state = await getSessionState();
  if (state.status !== "ready" || financesStatus(state.profile.role) === 403) {
    return new Response("Owners only", { status: 403 });
  }
  const form = await request.formData();
  const file = form.get("file");
  const statement =
    typeof form.get("statementPeriod") === "string"
      ? String(form.get("statementPeriod")).trim()
      : "";
  const startup = form.get("isStartup") === "on";
  if (!(file instanceof File)) redirect("/finances/cards?notice=failed");
  const parsed = parseCardCsv(await file.text());
  if (!parsed.ok) redirect("/finances/cards?notice=failed");
  const supabase = await createClient();
  const { data: categories } = await supabase
    .from("finance_categories")
    .select("id, name")
    .is("archived_at", null);
  const byName = new Map(
    ((categories ?? []) as { id: number; name: string }[]).map((category) => [
      category.name.toLowerCase(),
      category.id,
    ]),
  );
  const rows = [];
  for (const row of parsed.rows) {
    const categoryId = byName.get(row.category.toLowerCase());
    if (!categoryId) redirect("/finances/cards?notice=failed");
    rows.push({
      statement_period: statement || null,
      transaction_date: row.date,
      merchant: row.merchant,
      amount_cad: row.amountCad,
      hst_cad: 0,
      original_currency: "CAD",
      original_amount: row.amountCad,
      category_id: categoryId,
      notes: row.note || null,
      is_startup: startup,
      excluded: false,
      created_by: state.profile.id,
    });
  }
  const { error } = await supabase.from("card_transactions").insert(rows);
  if (error) redirect("/finances/cards?notice=failed");
  redirect("/finances/cards?notice=saved");
}
