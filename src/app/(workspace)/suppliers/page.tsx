import Link from "next/link";
import { Suspense } from "react";
import { ListHeader } from "@/components/records/list-header";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canEditInventory, canSeePrivateRecords } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
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

type SuppliersProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function SuppliersPage(props: SuppliersProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <SuppliersScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function SuppliersScreen({
  searchParams,
}: {
  searchParams: SuppliersProps["searchParams"];
}) {
  const gate = await gateArea("suppliers");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const showArchived = firstQueryValue((await searchParams).archived) === "1";
  const supabase = await createClient();
  let suppliersQuery = supabase
    .from("suppliers")
    .select("id, supplier_code, name, website, notes")
    .order("name");
  if (!showArchived) suppliersQuery = suppliersQuery.is("archived_at", null);
  const suppliersResult = await suppliersQuery;
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
      <ListHeader
        title="Suppliers"
        newHref="/suppliers/new"
        newLabel="New supplier"
        showArchived={showArchived}
        canCreate={canEditInventory(gate.profile)}
      />
      <ul className="flex flex-col gap-3">
        {((suppliersResult.data ?? []) as SupplierRow[]).map((supplier) => {
          const contact = contacts.get(supplier.id);
          return (
            <li
              key={supplier.id}
              className="rounded-2xl border border-line bg-card p-4"
            >
              <Link
                href={`/suppliers/${encodeURIComponent(supplier.supplier_code)}`}
                className="inline-flex min-h-11 items-center font-medium text-ink"
              >
                {supplier.name}
              </Link>
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
