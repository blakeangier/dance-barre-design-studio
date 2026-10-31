import { Suspense } from "react";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canSeePrivateRecords } from "@/lib/auth/permissions";
import { gateArea } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Suppliers" };

type SupplierRow = {
  id: number;
  supplier_code: string;
  name: string;
  website: string | null;
  notes: string | null;
};

type ContactRow = {
  supplier_id: number;
  contact_name: string | null;
  email: string | null;
  phone: string | null;
};

export default function SuppliersPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <SuppliersScreen />
    </Suspense>
  );
}

async function SuppliersScreen() {
  const gate = await gateArea("suppliers");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const supabase = await createClient();
  const suppliersResult = await supabase
    .from("suppliers")
    .select("id, supplier_code, name, website, notes")
    .order("name");
  const contactsResult = canSeePrivateRecords(gate.profile)
    ? await supabase
        .from("supplier_contacts")
        .select("supplier_id, contact_name, email, phone")
    : { data: [] };
  const contacts = new Map(
    ((contactsResult.data ?? []) as ContactRow[]).map((row) => [
      row.supplier_id,
      row,
    ]),
  );

  return (
    <div className="flex flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Suppliers</h1>
      <ul className="flex flex-col gap-3">
        {((suppliersResult.data ?? []) as SupplierRow[]).map((supplier) => {
          const contact = contacts.get(supplier.id);
          return (
            <li
              key={supplier.id}
              className="rounded-2xl border border-line bg-card p-4"
            >
              <p className="font-medium text-ink">{supplier.name}</p>
              <p className="text-sm text-muted">{supplier.supplier_code}</p>
              {supplier.website ? (
                <p className="text-sm text-muted">{supplier.website}</p>
              ) : null}
              {contact ? (
                <p className="mt-1 text-sm text-muted">
                  {[contact.contact_name, contact.email, contact.phone]
                    .filter(Boolean)
                    .join(" · ")}
                </p>
              ) : null}
              {supplier.notes ? (
                <p className="mt-1 text-sm text-ink">{supplier.notes}</p>
              ) : null}
            </li>
          );
        })}
      </ul>
    </div>
  );
}
