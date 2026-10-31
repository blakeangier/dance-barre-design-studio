import Link from "next/link";
import { ShowArchived } from "@/components/records/show-archived";

export function ListHeader({
  title,
  newHref,
  newLabel,
  showArchived,
  canCreate,
}: {
  title: string;
  newHref?: string;
  newLabel?: string;
  showArchived: boolean;
  canCreate: boolean;
}) {
  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="font-serif text-3xl text-ink">{title}</h1>
        {canCreate && newHref && newLabel ? (
          <Link
            href={newHref}
            className="inline-flex min-h-12 items-center rounded-full bg-ink px-4 font-medium text-white"
          >
            {newLabel}
          </Link>
        ) : null}
      </div>
      <ShowArchived checked={showArchived} />
    </div>
  );
}
