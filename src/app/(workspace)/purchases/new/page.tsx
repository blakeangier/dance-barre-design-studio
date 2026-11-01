import Link from "next/link";
import { Suspense } from "react";
import { savePurchase } from "@/app/(workspace)/records/purchase-actions";
import {
  SaveButton,
  SelectField,
  TextField,
} from "@/components/records/fields";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canRecordPurchase } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { EDIT_NOTICES } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "New purchase" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function NewPurchasePage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <NewPurchase searchParams={props.searchParams} />
    </Suspense>
  );
}

async function NewPurchase({
  searchParams,
}: {
  searchParams: PageProps["searchParams"];
}) {
  const gate = await gateArea("purchases");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  if (!canRecordPurchase(gate.profile)) return <NoAccess reason="denied" />;
  const notice =
    EDIT_NOTICES[firstQueryValue((await searchParams).notice) ?? ""];
  const supabase = await createClient();
  const [{ data: suppliers }, { data: materials }] = await Promise.all([
    supabase.from("suppliers").select("id, name").order("name"),
    supabase
      .from("materials")
      .select("id, material_code")
      .order("material_code"),
  ]);

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/purchases" className="text-sm text-muted">
        Purchases
      </Link>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      <form
        action={savePurchase}
        className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
      >
        <h1 className="font-serif text-3xl text-ink">New purchase</h1>
        <TextField id="poRef" name="poRef" label="PO reference" required />
        <SelectField id="supplierId" name="supplierId" label="Supplier">
          <option value="">No linked supplier</option>
          {((suppliers ?? []) as { id: number; name: string }[]).map(
            (supplier) => (
              <option key={supplier.id} value={supplier.id}>
                {supplier.name}
              </option>
            ),
          )}
        </SelectField>
        <TextField
          id="supplierWritten"
          name="supplierWritten"
          label="Supplier as written"
        />
        <TextField id="poDate" name="poDate" label="PO date" type="date" />
        <SelectField id="materialId" name="materialId" label="Material">
          <option value="">Not linked</option>
          {((materials ?? []) as { id: number; material_code: string }[]).map(
            (material) => (
              <option key={material.id} value={material.id}>
                {material.material_code}
              </option>
            ),
          )}
        </SelectField>
        <TextField
          id="materialRaw"
          name="materialRaw"
          label="Material as written"
        />
        <TextField
          id="qty"
          name="qty"
          label="Metres ordered"
          inputMode="decimal"
        />
        <TextField
          id="price"
          name="price"
          label="Price per metre"
          inputMode="decimal"
        />
        <SaveButton label="Create purchase" />
      </form>
    </div>
  );
}
