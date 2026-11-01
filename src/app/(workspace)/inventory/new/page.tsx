import Link from "next/link";
import { Suspense } from "react";
import { MaterialForm } from "@/components/records/material-form";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { StatusNote } from "@/components/shell/status-note";
import { canEditInventory } from "@/lib/auth/permissions";
import { gateArea } from "@/lib/auth/session";
import { firstQueryValue } from "@/lib/auth/notices";
import { EDIT_NOTICES } from "@/lib/records/edit";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "New material" };

type PageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default function NewMaterialPage(props: PageProps) {
  return (
    <Suspense fallback={<LoadingLine />}>
      <NewMaterial searchParams={props.searchParams} />
    </Suspense>
  );
}

async function NewMaterial({
  searchParams,
}: {
  searchParams: PageProps["searchParams"];
}) {
  const gate = await gateArea("inventory");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  if (!canEditInventory(gate.profile)) {
    return <NoAccess reason="denied" />;
  }
  const params = await searchParams;
  const notice = EDIT_NOTICES[firstQueryValue(params.notice) ?? ""];
  const supabase = await createClient();
  const { data: suppliers } = await supabase
    .from("suppliers")
    .select("id, name")
    .order("name");

  return (
    <div className="mx-auto flex w-full max-w-lg flex-col gap-4">
      <Link href="/inventory" className="text-sm text-muted">
        Inventory
      </Link>
      {notice ? (
        <StatusNote tone={notice.tone}>{notice.text}</StatusNote>
      ) : null}
      <MaterialForm
        material={null}
        suppliers={(suppliers ?? []) as { id: number; name: string }[]}
        cost={null}
      />
    </div>
  );
}
