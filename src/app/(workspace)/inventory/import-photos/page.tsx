import Link from "next/link";
import { Suspense } from "react";
import { PhotoImportForm } from "@/app/(workspace)/inventory/import-photos/import-form";
import { LoadingLine } from "@/components/shell/loading-line";
import { NoAccess } from "@/components/shell/no-access";
import { canBulkImportPhotos } from "@/lib/auth/permissions";
import { gateArea } from "@/lib/auth/session";

export const metadata = { title: "Import photos" };

export default function ImportPhotosPage() {
  return (
    <Suspense fallback={<LoadingLine />}>
      <ImportPhotos />
    </Suspense>
  );
}

async function ImportPhotos() {
  const gate = await gateArea("inventory");
  if (!gate.ok) return <NoAccess reason={gate.reason} />;
  if (!canBulkImportPhotos(gate.profile)) return <NoAccess reason="denied" />;

  return (
    <div className="mx-auto flex w-full max-w-4xl flex-col gap-4">
      <Link href="/inventory" className="text-sm text-muted">
        Inventory
      </Link>
      <div>
        <h1 className="font-serif text-3xl text-ink">Import photos</h1>
        <p className="mt-2 max-w-prose text-sm leading-relaxed text-muted">
          Owners only. Photos are added. Nothing already on a material is
          replaced or removed. A photo becomes the primary only when that
          material does not have one yet. The source address is stored in the
          caption. The same source on the same material is skipped.
        </p>
      </div>
      <section className="rounded-2xl border border-line bg-card p-4 text-sm">
        <h2 className="font-medium text-ink">Manifest</h2>
        <p className="mt-2 text-muted">
          JSON, as a list or as <code>photos</code>. <code>material</code> is a
          material code such as F010-03, or use <code>materialId</code>.{" "}
          <code>file</code> matches the image name. <code>caption</code> and{" "}
          <code>sourceUrl</code> are optional. Leave <code>file</code> out when
          the image is only a link.
        </p>
        <pre className="mt-3 overflow-x-auto rounded-xl bg-paper p-3 text-xs text-ink">{`{
  "photos": [
    {
      "file": "F010-03.jpg",
      "material": "F010-03",
      "caption": "Studio swatch",
      "sourceUrl": "https://example.com/F010-03.jpg"
    },
    {
      "materialId": 42,
      "sourceUrl": "https://example.com/other.jpg"
    }
  ]
}`}</pre>
        <p className="mt-3 text-muted">
          CSV uses the header <code>file,material,caption,source_url</code>. A
          numeric <code>material_id</code> column works in place of{" "}
          <code>material</code>.
        </p>
        <pre className="mt-3 overflow-x-auto rounded-xl bg-paper p-3 text-xs text-ink">{`file,material,caption,source_url
F010-03.jpg,F010-03,Studio swatch,https://example.com/F010-03.jpg
,F010-04,,https://example.com/other.jpg`}</pre>
      </section>
      <PhotoImportForm />
    </div>
  );
}
