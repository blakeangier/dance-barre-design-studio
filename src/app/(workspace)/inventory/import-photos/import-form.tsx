"use client";

import { useRef, useState } from "react";
import {
  importMaterialPhotos,
  previewPhotoImport,
  type ImportPreviewRow,
  type ImportReport,
} from "@/app/(workspace)/inventory/import-photos/actions";

type LinkRow = { material: string; caption: string; sourceUrl: string };

export function PhotoImportForm() {
  const formRef = useRef<HTMLFormElement>(null);
  const [links, setLinks] = useState<LinkRow[]>([
    { material: "", caption: "", sourceUrl: "" },
  ]);
  const [preview, setPreview] = useState<ImportPreviewRow[] | null>(null);
  const [report, setReport] = useState<Extract<
    ImportReport,
    { ok: true }
  > | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [busy, setBusy] = useState<"preview" | "import" | null>(null);

  function formData(): FormData {
    const data = new FormData(formRef.current ?? undefined);
    data.delete("linkMaterial");
    data.delete("linkCaption");
    data.delete("linkSourceUrl");
    for (const link of links) {
      data.append("linkMaterial", link.material);
      data.append("linkCaption", link.caption);
      data.append("linkSourceUrl", link.sourceUrl);
    }
    return data;
  }

  async function onPreview() {
    setBusy("preview");
    setMessage(null);
    setReport(null);
    const result = await previewPhotoImport(formData());
    setBusy(null);
    if (!result.ok) {
      setPreview(null);
      setMessage(result.message);
      return;
    }
    setPreview(result.rows);
  }

  async function onImport() {
    setBusy("import");
    setMessage(null);
    const result = await importMaterialPhotos(formData());
    setBusy(null);
    if (!result.ok) {
      setMessage(result.message);
      return;
    }
    setReport(result);
    setPreview(null);
  }

  const ready = preview?.some((row) => row.status === "import") ?? false;

  return (
    <form ref={formRef} className="flex flex-col gap-4">
      <section className="rounded-2xl border border-line bg-card p-4">
        <h2 className="font-serif text-2xl text-ink">Files</h2>
        <p className="mt-2 text-sm text-muted">
          Upload a .zip, or several images, plus a manifest. A manifest named
          manifest.json or manifest.csv inside the zip is used when you do not
          attach one separately.
        </p>
        <label className="mt-3 block text-sm font-medium" htmlFor="archive">
          Zip
        </label>
        <input
          id="archive"
          name="archive"
          type="file"
          accept=".zip,application/zip"
          className="mt-1 block w-full text-sm"
        />
        <label className="mt-3 block text-sm font-medium" htmlFor="images">
          Images
        </label>
        <input
          id="images"
          name="images"
          type="file"
          accept="image/jpeg,image/png,image/webp"
          multiple
          className="mt-1 block w-full text-sm"
        />
        <label className="mt-3 block text-sm font-medium" htmlFor="manifest">
          Manifest (.json or .csv)
        </label>
        <input
          id="manifest"
          name="manifest"
          type="file"
          accept=".json,.csv,application/json,text/csv"
          className="mt-1 block w-full text-sm"
        />
      </section>

      <section className="rounded-2xl border border-line bg-card p-4">
        <h2 className="font-serif text-2xl text-ink">Add photo from link</h2>
        <p className="mt-2 text-sm text-muted">
          An https image address. The server fetches it. Nothing is sent from
          the browser straight to storage.
        </p>
        <div className="mt-3 flex flex-col gap-3">
          {links.map((link, index) => (
            <div key={index} className="grid gap-2 sm:grid-cols-3">
              <input
                aria-label={`Material for link ${index + 1}`}
                value={link.material}
                placeholder="Material code or id"
                onChange={(event) =>
                  setLinks((current) =>
                    current.map((item, itemIndex) =>
                      itemIndex === index
                        ? { ...item, material: event.target.value }
                        : item,
                    ),
                  )
                }
                className="min-h-12 rounded-xl border border-line px-3"
              />
              <input
                aria-label={`Caption for link ${index + 1}`}
                value={link.caption}
                placeholder="Caption"
                onChange={(event) =>
                  setLinks((current) =>
                    current.map((item, itemIndex) =>
                      itemIndex === index
                        ? { ...item, caption: event.target.value }
                        : item,
                    ),
                  )
                }
                className="min-h-12 rounded-xl border border-line px-3"
              />
              <input
                aria-label={`URL for link ${index + 1}`}
                value={link.sourceUrl}
                placeholder="https://…"
                onChange={(event) =>
                  setLinks((current) =>
                    current.map((item, itemIndex) =>
                      itemIndex === index
                        ? { ...item, sourceUrl: event.target.value }
                        : item,
                    ),
                  )
                }
                className="min-h-12 rounded-xl border border-line px-3"
              />
            </div>
          ))}
        </div>
        <button
          type="button"
          className="mt-3 min-h-12 text-sm font-medium"
          onClick={() =>
            setLinks((current) => [
              ...current,
              { material: "", caption: "", sourceUrl: "" },
            ])
          }
        >
          Add another link
        </button>
      </section>

      <div className="flex flex-wrap gap-2">
        <button
          type="button"
          disabled={busy !== null}
          onClick={() => void onPreview()}
          className="min-h-12 rounded-full bg-ink px-4 font-medium text-white disabled:opacity-60"
        >
          {busy === "preview" ? "Checking…" : "Preview"}
        </button>
        <button
          type="button"
          disabled={busy !== null || !ready}
          onClick={() => void onImport()}
          className="min-h-12 rounded-full border border-ink px-4 font-medium text-ink disabled:opacity-60"
        >
          {busy === "import" ? "Importing…" : "Import"}
        </button>
      </div>
      {message ? <p className="text-sm text-ink">{message}</p> : null}
      {preview ? <PreviewTable rows={preview} /> : null}
      {report ? <ResultReport report={report} /> : null}
    </form>
  );
}

function PreviewTable({ rows }: { rows: ImportPreviewRow[] }) {
  return (
    <section className="rounded-2xl border border-line bg-card p-4">
      <h2 className="font-serif text-2xl text-ink">Preview</h2>
      <p className="mt-2 text-sm text-muted">
        Nothing is saved until you press Import. Existing photos stay as they
        are.
      </p>
      <div className="mt-3 overflow-x-auto">
        <table className="w-full min-w-[760px] border-collapse text-sm">
          <thead>
            <tr>
              {["Photo", "Material", "Match", "Will become primary"].map(
                (heading) => (
                  <th
                    key={heading}
                    className="border border-line bg-paper px-2 py-2 text-left"
                  >
                    {heading}
                  </th>
                ),
              )}
            </tr>
          </thead>
          <tbody>
            {rows.map((row, index) => (
              <tr key={`${row.label}-${index}`}>
                <td className="border border-line px-2 py-2">
                  <div className="flex items-center gap-2">
                    {row.thumb ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={row.thumb}
                        alt=""
                        className="h-16 w-16 rounded-lg object-cover"
                      />
                    ) : (
                      <span className="inline-block h-16 w-16 rounded-lg bg-paper" />
                    )}
                    <span>{row.label}</span>
                  </div>
                </td>
                <td className="border border-line px-2 py-2">
                  {row.materialCode
                    ? `${row.materialCode}${row.materialName ? ` · ${row.materialName}` : ""}${row.colour ? ` · ${row.colour}` : ""}`
                    : "—"}
                </td>
                <td className="border border-line px-2 py-2">
                  {row.status === "import" ? "Ready" : `Skip: ${row.reason}`}
                </td>
                <td className="border border-line px-2 py-2">
                  {row.willBePrimary ? "Yes" : "No"}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}

function ResultReport({
  report,
}: {
  report: Extract<ImportReport, { ok: true }>;
}) {
  return (
    <section className="rounded-2xl border border-line bg-card p-4">
      <h2 className="font-serif text-2xl text-ink">Results</h2>
      <p className="mt-2 text-sm text-ink">
        Imported {report.imported}. Skipped {report.skipped.length}.
      </p>
      {report.skipped.length > 0 ? (
        <ul className="mt-3 flex flex-col gap-2 text-sm">
          {report.skipped.map((row, index) => (
            <li key={`${row.label}-${index}`}>
              {row.label}: {row.reason}
            </li>
          ))}
        </ul>
      ) : (
        <p className="mt-3 text-sm text-muted">Nothing was skipped.</p>
      )}
    </section>
  );
}
