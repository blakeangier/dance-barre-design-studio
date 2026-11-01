import Link from "next/link";
import { Suspense } from "react";
import { saveSupplier } from "@/app/(workspace)/records/supplier-actions";
import { SaveButton, TextField } from "@/components/records/fields";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { EDIT_NOTICES } from "@/lib/records/edit";

export const metadata = { title: "New supplier" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function NewSupplierPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <NewSupplier searchParams={props.searchParams} />
    </Suspense>
  );
}

async function NewSupplier({
  searchParams,
}: {
  searchParams: PageProps["searchParams"];
}) {
  const gate = await gateArea("suppliers");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  if (!canEditInventory(gate.profile)) return <NoAccess reason="denied" />;
  const notice =
    EDIT_NOTICES[firstQueryValue((await searchParams).notice) ?? ""];

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/suppliers" className="text-sm text-muted">
        Suppliers
      </Link>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      <form
        action={saveSupplier}
        className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
      >
        <h1 className="font-serif text-3xl text-ink">New supplier</h1>
        <TextField
          id="supplierCode"
          name="supplierCode"
          label="Supplier code"
          required
        />
        <TextField id="name" name="name" label="Name" required />
        <SaveButton label="Create supplier" />
      </form>
    </div>
  );
}
