import Link from "next/link";
import { Suspense } from "react";
import {
  saveAlteration,
  saveFitting,
} from "@/app/(workspace)/records/production-actions";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { SIZE_CODES } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Fittings" };

type PageProps = {
  params: Promise<{ orderNumber: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function FittingsPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <FittingsScreen params={props.params} searchParams={props.searchParams} />
    </Suspense>
  );
}

async function FittingsScreen({ params, searchParams }: PageProps) {
  const gate = await gateArea("production-orders");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const orderNumber = decodeURIComponent((await params).orderNumber);
  const notice = firstQueryValue((await searchParams).notice);
  const editor = canEditInventory(gate.profile);
  const supabase = await createClient();
  const { data: order } = await supabase
    .from("costume_orders")
    .select("id")
    .eq("order_number", orderNumber)
    .maybeSingle();
  if (!order) return <h1 className="font-serif text-3xl">Order not found</h1>;
  const [fittingsResult, alterationsResult, checksResult] = await Promise.all([
    supabase
      .from("fittings")
      .select("id, dancer_label, size_label, outcome, fit_notes, fitting_on")
      .eq("order_id", order.id)
      .is("archived_at", null),
    supabase
      .from("alterations")
      .select("id, request, asked_by, status, done_on")
      .eq("order_id", order.id)
      .is("archived_at", null),
    supabase
      .from("fitting_checks")
      .select("check_name, completed_text")
      .eq("order_id", order.id),
  ]);

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link
        href={`/production-orders/${encodeURIComponent(orderNumber)}`}
        className="text-sm text-muted"
      >
        {orderNumber}
      </Link>
      <h1 className="font-serif text-3xl text-ink">Fittings</h1>
      {notice === "saved" ? <StatusNote>Saved.</StatusNote> : null}
      {notice === "failed" ? (
        <StatusNote tone="error">
          Use a first name and one last initial, such as Ava M.
        </StatusNote>
      ) : null}
      {editor ? (
        <form
          action={saveFitting}
          className="flex flex-col gap-2 rounded-2xl border border-line bg-card p-4"
        >
          <input type="hidden" name="orderNumber" value={orderNumber} />
          <label className="text-sm font-medium" htmlFor="firstName">
            First name
          </label>
          <input
            id="firstName"
            name="firstName"
            required
            className="min-h-12 rounded-xl border border-line px-3"
          />
          <label className="text-sm font-medium" htmlFor="lastInitial">
            Last initial
          </label>
          <input
            id="lastInitial"
            name="lastInitial"
            required
            maxLength={1}
            className="min-h-12 rounded-xl border border-line px-3"
          />
          <select
            name="sizeCode"
            className="min-h-12 rounded-xl border border-line px-3"
          >
            {SIZE_CODES.map((code) => (
              <option key={code} value={code}>
                {code}
              </option>
            ))}
          </select>
          <select
            name="outcome"
            className="min-h-12 rounded-xl border border-line px-3"
            defaultValue="approved"
          >
            <option value="approved">Approved</option>
            <option value="alter">Alter</option>
            <option value="remake">Remake</option>
          </select>
          <input
            name="fittingOn"
            type="date"
            className="min-h-12 rounded-xl border border-line px-3"
          />
          <textarea
            name="fitNotes"
            placeholder="Fit notes"
            className="min-h-20 rounded-xl border border-line px-3 py-2"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full bg-ink px-4 font-medium text-white"
          >
            Save fitting
          </button>
        </form>
      ) : null}
      <ul className="flex flex-col gap-2">
        {(
          (fittingsResult.data ?? []) as {
            id: number;
            dancer_label: string | null;
            size_label: string | null;
            outcome: string | null;
            fit_notes: string | null;
            fitting_on: string | null;
          }[]
        ).map((fitting) => (
          <li
            key={fitting.id}
            className="rounded-2xl border border-line bg-card p-3 text-sm"
          >
            <p className="font-medium text-ink">
              {fitting.dancer_label ?? "Fitting"} ·{" "}
              {fitting.size_label ?? "size not set"} ·{" "}
              {fitting.outcome ?? "no outcome"}
            </p>
            <p className="text-muted">{fitting.fitting_on}</p>
            {fitting.fit_notes ? <p>{fitting.fit_notes}</p> : null}
          </li>
        ))}
      </ul>
      <h2 className="font-serif text-2xl text-ink">Alterations</h2>
      {editor ? (
        <form action={saveAlteration} className="flex flex-col gap-2">
          <input type="hidden" name="orderNumber" value={orderNumber} />
          <textarea
            name="request"
            required
            placeholder="What needs altering"
            className="min-h-20 rounded-xl border border-line px-3 py-2"
          />
          <input
            name="askedBy"
            placeholder="Who asked"
            className="min-h-12 rounded-xl border border-line px-3"
          />
          <button
            type="submit"
            className="min-h-12 rounded-full border border-ink px-4 text-sm font-medium"
          >
            Log alteration
          </button>
        </form>
      ) : null}
      <ul className="flex flex-col gap-2">
        {(
          (alterationsResult.data ?? []) as {
            id: number;
            request: string;
            asked_by: string | null;
            status: string;
            done_on: string | null;
          }[]
        ).map((row) => (
          <li key={row.id} className="text-sm text-ink">
            {row.request} · {row.status}
            {row.asked_by ? ` · ${row.asked_by}` : ""}
            {row.done_on ? ` · ${row.done_on}` : ""}
          </li>
        ))}
      </ul>
      <h2 className="font-serif text-2xl text-ink">Imported fitting checks</h2>
      {(
        (checksResult.data ?? []) as {
          check_name: string;
          completed_text: string | null;
        }[]
      ).map((row) => (
        <p key={row.check_name} className="text-sm text-ink">
          {row.check_name}
          {row.completed_text ? ` · ${row.completed_text}` : ""}
        </p>
      ))}
    </div>
  );
}
