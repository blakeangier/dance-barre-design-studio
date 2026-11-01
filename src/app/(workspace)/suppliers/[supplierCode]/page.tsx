import Link from "next/link";
import { Suspense } from "react";
import { saveSupplier } from "@/app/(workspace)/records/supplier-actions";
import {
  AreaField,
  CheckField,
  SaveButton,
  TextField,
} from "@/components/records/fields";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory, canSeePrivateRecords } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { EDIT_NOTICES } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Supplier" };

type PageProps = {
  params: Promise<{ supplierCode: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type SupplierRow = {
  id: number;
  supplier_code: string;
  name: string;
  website: string | null;
  lead_time_days: number | null;
  minimum_order: string | null;
  notes: string | null;
  archived_at: string | null;
};

type ContactRow = {
  contact_name: string | null;
  email: string | null;
  phone: string | null;
  address: string | null;
  account_number: string | null;
};

export default function SupplierPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <SupplierScreen params={props.params} searchParams={props.searchParams} />
    </Suspense>
  );
}

async function SupplierScreen({ params, searchParams }: PageProps) {
  const gate = await gateArea("suppliers");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const code = decodeURIComponent((await params).supplierCode);
  const notice =
    EDIT_NOTICES[firstQueryValue((await searchParams).notice) ?? ""];
  const editor = canEditInventory(gate.profile);
  const canPrivate = canSeePrivateRecords(gate.profile);
  const supabase = await createClient();
  const { data } = await supabase
    .from("suppliers")
    .select(
      "id, supplier_code, name, website, lead_time_days, minimum_order, notes, archived_at",
    )
    .eq("supplier_code", code)
    .maybeSingle();
  if (!data) {
    return (
      <section>
        <h1 className="font-serif text-3xl text-ink">Supplier not found</h1>
        <Link href="/suppliers" className="mt-3 inline-block text-sm">
          Back to suppliers
        </Link>
      </section>
    );
  }
  const supplier = data as SupplierRow;
  const contactResult = canPrivate
    ? await supabase
        .from("supplier_contacts")
        .select("contact_name, email, phone, address, account_number")
        .eq("supplier_id", supplier.id)
        .maybeSingle()
    : { data: null };
  const contact = contactResult.data as ContactRow | null;

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/suppliers" className="text-sm text-muted">
        Suppliers
      </Link>
      <h1 className="font-serif text-3xl text-ink">{supplier.name}</h1>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      {editor ? (
        <form
          action={saveSupplier}
          className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
        >
          <input type="hidden" name="id" value={supplier.id} />
          <input
            type="hidden"
            name="returnCode"
            value={supplier.supplier_code}
          />
          <input
            type="hidden"
            name="archivedAt"
            value={supplier.archived_at ?? ""}
          />
          <TextField
            id="supplierCode"
            name="supplierCode"
            label="Supplier code"
            required
            defaultValue={supplier.supplier_code}
          />
          <TextField
            id="name"
            name="name"
            label="Name"
            required
            defaultValue={supplier.name}
          />
          <TextField
            id="website"
            name="website"
            label="Website"
            defaultValue={supplier.website}
          />
          <TextField
            id="leadTimeDays"
            name="leadTimeDays"
            label="Lead time (days)"
            inputMode="decimal"
            defaultValue={supplier.lead_time_days}
          />
          <TextField
            id="minimumOrder"
            name="minimumOrder"
            label="Minimum order"
            defaultValue={supplier.minimum_order}
          />
          <AreaField
            id="notes"
            name="notes"
            label="Notes"
            defaultValue={supplier.notes}
          />
          {canPrivate ? (
            <>
              <h2 className="font-serif text-2xl text-ink">Contact</h2>
              <TextField
                id="contactName"
                name="contactName"
                label="Contact name"
                defaultValue={contact?.contact_name}
              />
              <TextField
                id="email"
                name="email"
                label="Email"
                defaultValue={contact?.email}
              />
              <TextField
                id="phone"
                name="phone"
                label="Phone"
                defaultValue={contact?.phone}
              />
              <AreaField
                id="address"
                name="address"
                label="Address"
                defaultValue={contact?.address}
              />
              <TextField
                id="accountNumber"
                name="accountNumber"
                label="Account number"
                defaultValue={contact?.account_number}
              />
            </>
          ) : null}
          <CheckField
            name="archive"
            label="Archive this supplier"
            defaultChecked={Boolean(supplier.archived_at)}
          />
          <SaveButton label="Save supplier" />
        </form>
      ) : (
        <p className="text-sm text-muted">{supplier.supplier_code}</p>
      )}
    </div>
  );
}
