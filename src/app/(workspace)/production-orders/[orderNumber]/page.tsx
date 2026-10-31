import Link from "next/link";
import { Suspense } from "react";
import {
  saveFitting,
  saveOrder,
} from "@/app/(workspace)/records/order-actions";
import {
  AreaField,
  CheckField,
  SaveButton,
  SelectField,
  TextField,
} from "@/components/records/fields";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory, canSeePrivateRecords } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { EDIT_NOTICES, ORDER_STATUSES } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Order" };

type PageProps = {
  params: Promise<{ orderNumber: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type OrderRow = {
  id: number;
  order_number: string;
  production_song: string | null;
  status: string | null;
  order_date: string | null;
  fitting_target_raw: string | null;
  accessory: string | null;
  female_total: number | null;
  male_total: number | null;
  notes: string | null;
  archived_at: string | null;
};

type PrivateRow = {
  contacts: string | null;
  contact_emails: string | null;
  budget_per_costume: number | null;
  restricted_notes: string | null;
};

type StyleLink = {
  id: number;
  style_key: string;
  garment_description: string | null;
};
type FittingRow = {
  id: number;
  fitting_code: string;
  garment: string | null;
  size_label: string | null;
  approval_status: string | null;
  comments: string | null;
  archived_at: string | null;
};

export default function OrderPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <OrderScreen params={props.params} searchParams={props.searchParams} />
    </Suspense>
  );
}

async function OrderScreen({ params, searchParams }: PageProps) {
  const gate = await gateArea("production-orders");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const orderNumber = decodeURIComponent((await params).orderNumber);
  const notice =
    EDIT_NOTICES[firstQueryValue((await searchParams).notice) ?? ""];
  const editor = canEditInventory(gate.profile);
  const canPrivate = canSeePrivateRecords(gate.profile);
  const supabase = await createClient();
  const { data: order } = await supabase
    .from("costume_orders")
    .select(
      "id, order_number, production_song, status, order_date, fitting_target_raw, accessory, female_total, male_total, notes, archived_at",
    )
    .eq("order_number", orderNumber)
    .maybeSingle();
  if (!order) {
    return (
      <section>
        <h1 className="font-serif text-3xl text-ink">Order not found</h1>
        <Link href="/production-orders" className="mt-3 inline-block text-sm">
          Back to orders
        </Link>
      </section>
    );
  }
  const typed = order as OrderRow;
  const [privateResult, stylesResult, fittingsResult] = await Promise.all([
    canPrivate
      ? supabase
          .from("order_private")
          .select(
            "contacts, contact_emails, budget_per_costume, restricted_notes",
          )
          .eq("order_id", typed.id)
          .maybeSingle()
      : Promise.resolve({ data: null }),
    supabase
      .from("styles")
      .select("id, style_key, garment_description")
      .eq("order_id", typed.id)
      .order("style_key"),
    supabase
      .from("fittings")
      .select(
        "id, fitting_code, garment, size_label, approval_status, comments, archived_at",
      )
      .eq("order_id", typed.id)
      .order("fitting_code"),
  ]);
  const hidden = privateResult.data as PrivateRow | null;
  const styles = (stylesResult.data ?? []) as StyleLink[];
  const fittings = (fittingsResult.data ?? []) as FittingRow[];

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/production-orders" className="text-sm text-muted">
        Orders
      </Link>
      <h1 className="font-serif text-3xl text-ink">{typed.order_number}</h1>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      {editor ? (
        <form
          action={saveOrder}
          className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
        >
          <h2 className="font-serif text-2xl text-ink">Edit order</h2>
          <input type="hidden" name="id" value={typed.id} />
          <input type="hidden" name="returnNumber" value={typed.order_number} />
          <input
            type="hidden"
            name="archivedAt"
            value={typed.archived_at ?? ""}
          />
          <TextField
            id="orderNumber"
            name="orderNumber"
            label="Order number"
            required
            defaultValue={typed.order_number}
          />
          <TextField
            id="productionSong"
            name="productionSong"
            label="Production or song"
            defaultValue={typed.production_song}
          />
          <SelectField
            id="status"
            name="status"
            label="Status"
            defaultValue={typed.status ?? ""}
          >
            {ORDER_STATUSES.map((status) => (
              <option key={status.label} value={status.value}>
                {status.label}
              </option>
            ))}
          </SelectField>
          <TextField
            id="orderDate"
            name="orderDate"
            label="Order date"
            type="date"
            defaultValue={typed.order_date}
          />
          <TextField
            id="fittingTarget"
            name="fittingTarget"
            label="Fitting target"
            defaultValue={typed.fitting_target_raw}
          />
          <TextField
            id="accessory"
            name="accessory"
            label="Accessory"
            defaultValue={typed.accessory}
          />
          <TextField
            id="femaleTotal"
            name="femaleTotal"
            label="Female total"
            inputMode="decimal"
            defaultValue={typed.female_total}
          />
          <TextField
            id="maleTotal"
            name="maleTotal"
            label="Male total"
            inputMode="decimal"
            defaultValue={typed.male_total}
          />
          <AreaField
            id="notes"
            name="notes"
            label="Notes"
            defaultValue={typed.notes}
          />
          {canPrivate ? (
            <>
              <TextField
                id="contacts"
                name="contacts"
                label="Contacts"
                defaultValue={hidden?.contacts}
              />
              <TextField
                id="contactEmails"
                name="contactEmails"
                label="Client emails"
                defaultValue={hidden?.contact_emails}
              />
              <TextField
                id="budget"
                name="budget"
                label="Budget per costume"
                inputMode="decimal"
                defaultValue={hidden?.budget_per_costume}
              />
              <AreaField
                id="privateNotes"
                name="privateNotes"
                label="Notes that include an email"
                defaultValue={hidden?.restricted_notes}
              />
            </>
          ) : null}
          <CheckField
            name="archive"
            label="Archive (hide from the default list)"
            defaultChecked={Boolean(typed.archived_at)}
          />
          <SaveButton label="Save order" />
        </form>
      ) : (
        <p className="text-sm text-muted">
          {typed.production_song ?? "No song"} ·{" "}
          {typed.status === "cancelled" ? "Cancelled" : "In progress"}
        </p>
      )}
      <section className="flex flex-col gap-2">
        <h2 className="font-serif text-2xl text-ink">Styles</h2>
        {styles.map((style) => (
          <Link
            key={style.id}
            href={`/styles/${style.id}`}
            className="inline-flex min-h-12 items-center text-ink"
          >
            {style.garment_description ?? style.style_key}
          </Link>
        ))}
      </section>
      <section className="flex flex-col gap-3">
        <h2 className="font-serif text-2xl text-ink">Fittings</h2>
        {fittings.map((fitting) =>
          editor ? (
            <form
              key={fitting.id}
              action={saveFitting}
              className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
            >
              <input type="hidden" name="id" value={fitting.id} />
              <input type="hidden" name="orderId" value={typed.id} />
              <input
                type="hidden"
                name="orderNumber"
                value={typed.order_number}
              />
              <input
                type="hidden"
                name="archivedAt"
                value={fitting.archived_at ?? ""}
              />
              <TextField
                id={`fitting-${fitting.id}`}
                name="fittingCode"
                label="Fitting"
                required
                defaultValue={fitting.fitting_code}
              />
              <TextField
                id={`garment-${fitting.id}`}
                name="garment"
                label="Garment"
                defaultValue={fitting.garment}
              />
              <TextField
                id={`size-${fitting.id}`}
                name="sizeLabel"
                label="Size"
                defaultValue={fitting.size_label}
              />
              <TextField
                id={`approval-${fitting.id}`}
                name="approvalStatus"
                label="Approval"
                defaultValue={fitting.approval_status}
              />
              <AreaField
                id={`comments-${fitting.id}`}
                name="comments"
                label="Comments"
                defaultValue={fitting.comments}
              />
              <CheckField
                name="archive"
                label="Archive this fitting"
                defaultChecked={Boolean(fitting.archived_at)}
              />
              <SaveButton label="Save fitting" />
            </form>
          ) : (
            <p key={fitting.id} className="text-sm text-ink">
              {fitting.fitting_code}
              {fitting.garment ? ` · ${fitting.garment}` : ""}
            </p>
          ),
        )}
        {editor ? (
          <form
            action={saveFitting}
            className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
          >
            <h3 className="font-serif text-xl text-ink">Add a fitting</h3>
            <input type="hidden" name="orderId" value={typed.id} />
            <input
              type="hidden"
              name="orderNumber"
              value={typed.order_number}
            />
            <TextField
              id="newFitting"
              name="fittingCode"
              label="Fitting code"
              required
            />
            <TextField id="newGarment" name="garment" label="Garment" />
            <SaveButton label="Add fitting" />
          </form>
        ) : null}
      </section>
    </div>
  );
}
