import Link from "next/link";
import { Suspense } from "react";
import { saveOrder } from "@/app/(workspace)/records/order-actions";
import {
  SaveButton,
  SelectField,
  TextField,
} from "@/components/records/fields";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { EDIT_NOTICES, ORDER_STATUSES } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "New order" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function NewOrderPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <NewOrder searchParams={props.searchParams} />
    </Suspense>
  );
}

async function NewOrder({
  searchParams,
}: {
  searchParams: PageProps["searchParams"];
}) {
  const gate = await gateArea("production-orders");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  if (!canEditInventory(gate.profile)) return <NoAccess reason="denied" />;
  const notice =
    EDIT_NOTICES[firstQueryValue((await searchParams).notice) ?? ""];
  const supabase = await createClient();
  const { data: programRows } = await supabase
    .from("programs")
    .select("id, name")
    .order("name");
  const programs = (programRows ?? []) as { id: number; name: string }[];

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/production-orders" className="text-sm text-muted">
        Orders
      </Link>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      <form
        action={saveOrder}
        className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
      >
        <h1 className="font-serif text-3xl text-ink">New order</h1>
        <TextField
          id="orderNumber"
          name="orderNumber"
          label="Order number"
          required
        />
        <TextField
          id="productionSong"
          name="productionSong"
          label="Production or song"
        />
        <SelectField id="status" name="status" label="Status" defaultValue="">
          {ORDER_STATUSES.map((status) => (
            <option key={status.label} value={status.value}>
              {status.label}
            </option>
          ))}
        </SelectField>
        {programs.length > 0 ? (
          <SelectField id="programId" name="programId" label="Program">
            <option value="">Unassigned</option>
            {programs.map((program) => (
              <option key={program.id} value={program.id}>
                {program.name}
              </option>
            ))}
          </SelectField>
        ) : null}
        <SaveButton label="Create order" />
      </form>
    </div>
  );
}
