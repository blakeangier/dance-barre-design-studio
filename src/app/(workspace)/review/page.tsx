import { Suspense } from "react";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { gateArea } from "@/lib/auth/session";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Review" };

type ReviewRow = {
  review_code: string;
  source_sheet: string | null;
  record_label: string | null;
  question: string | null;
  priority: string | null;
  status: string;
  original_text: string | null;
};

const PRIORITY: Record<string, string> = {
  high: "border border-red bg-card text-ink",
  medium: "bg-orange text-ink",
  low: "bg-lime text-ink",
};

export default function ReviewPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ReviewScreen />
    </Suspense>
  );
}

async function ReviewScreen() {
  const gate = await gateArea("review");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  const supabase = await createClient();
  const { data } = await supabase
    .from("review_items")
    .select(
      "review_code, source_sheet, record_label, question, priority, status, original_text",
    )
    .order("priority")
    .order("review_code");

  return (
    <div className="flex flex-col gap-4">
      <h1 className="font-serif text-3xl text-ink">Review</h1>
      <ul className="flex flex-col gap-3">
        {((data ?? []) as ReviewRow[]).map((item) => (
          <li
            key={item.review_code}
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
            <p className="mt-2 text-sm text-ink">{item.question}</p>
            {item.original_text ? (
              <p className="mt-1 text-sm text-muted">
                Original: {item.original_text}
              </p>
            ) : null}
          </li>
        ))}
      </ul>
    </div>
  );
}
