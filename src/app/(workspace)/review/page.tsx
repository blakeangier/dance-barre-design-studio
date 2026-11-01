import Link from "next/link";
import { Suspense } from "react";
import { saveReview } from "@/app/(workspace)/records/review-actions";
import { PhotoThumb } from "@/components/inventory/photo-thumb";
import { ListHeader } from "@/components/records/list-header";
import {
  AreaField,
  SaveButton,
  SelectField,
} from "@/components/records/fields";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { photosForMaterials } from "@/lib/inventory/photo-urls";
import { EDIT_NOTICES, REVIEW_STATUSES } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Review" };

type ReviewProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

type ReviewRow = {
  id: number;
  review_code: string;
  source_sheet: string | null;
  record_label: string | null;
  question: string | null;
  priority: string | null;
  status: string;
  original_text: string | null;
  resolution: string | null;
  materials:
    | { id: number; material_code: string }
    | { id: number; material_code: string }[]
    | null;
  costume_orders: { order_number: string } | { order_number: string }[] | null;
  styles:
    | { id: number; style_key: string }
    | { id: number; style_key: string }[]
    | null;
};

const PRIORITY: Record<string, string> = {
  high: "border border-red bg-card text-ink",
  medium: "bg-orange text-ink",
  low: "bg-lime text-ink",
};

function one<T>(value: T | T[] | null): T | null {
  if (!value) return null;
  return Array.isArray(value) ? (value[0] ?? null) : value;
}

export default function ReviewPage(props: ReviewProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ReviewScreen searchParams={props.searchParams} />
    </Suspense>
  );
}

async function ReviewScreen({
  searchParams,
}: {
  searchParams: ReviewProps["searchParams"];
}) {
  const gate = await gateArea("review");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const params = await searchParams;
  const showArchived = firstQueryValue(params.archived) === "1";
  const notice = EDIT_NOTICES[firstQueryValue(params.notice) ?? ""];
  const editor = canEditInventory(gate.profile);
  const supabase = await createClient();
  let query = supabase
    .from("review_items")
    .select(
      "id, review_code, source_sheet, record_label, question, priority, status, original_text, resolution, materials(id, material_code), costume_orders(order_number), styles(id, style_key)",
    )
    .order("priority")
    .order("review_code");
  if (!showArchived) query = query.neq("status", "closed");
  const { data } = await query;
  const items = (data ?? []) as unknown as ReviewRow[];
  const photos = await photosForMaterials(
    items.flatMap((item) => {
      const material = one(item.materials);
      return material ? [material.id] : [];
    }),
  );

  return (
    <div className="flex flex-col gap-4">
      <ListHeader
        title="Review"
        showArchived={showArchived}
        canCreate={false}
      />
      <p className="text-sm text-muted">
        Closed questions stay hidden until you show archived.
      </p>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      <ul className="flex flex-col gap-3">
        {items.map((item) => {
          const material = one(item.materials);
          const order = one(item.costume_orders);
          const style = one(item.styles);
          return (
            <li
              key={item.id}
              className="rounded-2xl border border-line bg-card p-4"
            >
              <p className="flex flex-wrap items-center gap-2">
                <span className="font-medium text-ink">{item.review_code}</span>
                <span
                  className={`rounded-full px-2 py-0.5 text-xs font-medium ${PRIORITY[item.priority ?? ""] ?? "bg-card text-ink"}`}
                >
                  {item.priority ?? "unspecified"}
                </span>
                <span className="text-xs text-muted">{item.status}</span>
              </p>
              <p className="mt-1 text-sm text-muted">
                {item.source_sheet} · {item.record_label}
              </p>
              <p className="mt-2 flex flex-col gap-1 text-sm">
                {material ? (
                  <span className="flex items-center gap-3">
                    <PhotoThumb
                      thumbUrl={photos.get(material.id)?.thumbUrl ?? null}
                      fullUrl={photos.get(material.id)?.fullUrl ?? null}
                      label={material.material_code}
                    />
                    <Link
                      href={`/inventory/${encodeURIComponent(material.material_code)}`}
                      className="min-h-11 text-ink"
                    >
                      Material {material.material_code}
                    </Link>
                  </span>
                ) : null}
                {order ? (
                  <Link
                    href={`/production-orders/${encodeURIComponent(order.order_number)}`}
                    className="min-h-11 text-ink"
                  >
                    Order {order.order_number}
                  </Link>
                ) : null}
                {style ? (
                  <Link
                    href={`/styles/${style.id}`}
                    className="min-h-11 text-ink"
                  >
                    Style {style.style_key}
                  </Link>
                ) : null}
              </p>
              <p className="mt-2 text-sm text-ink">{item.question}</p>
              {item.original_text ? (
                <p className="mt-1 text-sm text-muted">
                  Original: {item.original_text}
                </p>
              ) : null}
              {item.resolution ? (
                <p className="mt-1 text-sm text-ink">
                  Answer: {item.resolution}
                </p>
              ) : null}
              {editor ? (
                <form action={saveReview} className="mt-3 flex flex-col gap-3">
                  <input type="hidden" name="id" value={item.id} />
                  <SelectField
                    id={`status-${item.id}`}
                    name="status"
                    label="Status"
                    defaultValue={item.status}
                  >
                    {REVIEW_STATUSES.map((status) => (
                      <option key={status.value} value={status.value}>
                        {status.label}
                      </option>
                    ))}
                  </SelectField>
                  <AreaField
                    id={`answer-${item.id}`}
                    name="answer"
                    label="Answer"
                    defaultValue={item.resolution}
                  />
                  <SaveButton label="Save answer" />
                </form>
              ) : null}
            </li>
          );
        })}
      </ul>
    </div>
  );
}
