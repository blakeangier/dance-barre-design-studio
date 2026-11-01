import Link from "next/link";
import { Suspense } from "react";
import { saveStyle } from "@/app/(workspace)/records/style-actions";
import { SaveButton, TextField } from "@/components/records/fields";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory } from "@/lib/auth/permissions";
import { firstQueryValue } from "@/lib/auth/notices";
import { gateArea } from "@/lib/auth/session";
import { EDIT_NOTICES } from "@/lib/records/edit";

export const metadata = { title: "New style" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function NewStylePage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <NewStyle searchParams={props.searchParams} />
    </Suspense>
  );
}

async function NewStyle({
  searchParams,
}: {
  searchParams: PageProps["searchParams"];
}) {
  const gate = await gateArea("styles");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  if (!canEditInventory(gate.profile)) return <NoAccess reason="denied" />;
  const notice =
    EDIT_NOTICES[firstQueryValue((await searchParams).notice) ?? ""];

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/styles" className="text-sm text-muted">
        Styles
      </Link>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      <form
        action={saveStyle}
        className="flex flex-col gap-3 rounded-2xl border border-line bg-card p-4"
      >
        <h1 className="font-serif text-3xl text-ink">New style</h1>
        <TextField id="styleKey" name="styleKey" label="Style key" required />
        <TextField id="styleCode" name="styleCode" label="Style number" />
        <TextField id="orderNumber" name="orderNumber" label="Order number" />
        <TextField id="garment" name="garment" label="Garment" />
        <SaveButton label="Create style" />
      </form>
    </div>
  );
}
