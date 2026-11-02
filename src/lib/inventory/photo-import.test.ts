import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  captionForPhoto,
  captionHasSource,
  parsePhotoManifest,
  planPhotoImport,
  publicHttpsUrl,
  sniffImageType,
  type KnownMaterial,
} from "./photo-import.ts";

const fabric: KnownMaterial = {
  id: 7,
  code: "F010-03",
  name: "Stretch mesh",
  colour: "Nude",
  archived: false,
  hasPrimary: false,
  captions: [],
};

describe("photo manifest", () => {
  it("reads a JSON photos list with a code, a caption, and a source", () => {
    const parsed = parsePhotoManifest(
      JSON.stringify({
        photos: [
          {
            file: "F010-03.jpg",
            material: "F010-03",
            caption: "Studio swatch",
            sourceUrl: "https://example.com/F010-03.jpg",
          },
          { materialId: 7, source_url: "https://example.com/link.jpg" },
        ],
      }),
      "manifest.json",
    );
    assert.equal(parsed.ok, true);
    if (!parsed.ok) return;
    assert.equal(parsed.rows[0]?.file, "F010-03.jpg");
    assert.equal(parsed.rows[0]?.material, "F010-03");
    assert.equal(parsed.rows[0]?.caption, "Studio swatch");
    assert.equal(parsed.rows[1]?.material, "7");
    assert.equal(parsed.rows[1]?.file, null);
  });

  it("reads a CSV and keeps a comma that is inside quotes", () => {
    const parsed = parsePhotoManifest(
      'file,material,caption,source_url\nF010-03.jpg,F010-03,"swatch, front",https://example.com/a.jpg\n',
      "manifest.csv",
    );
    assert.equal(parsed.ok, true);
    if (!parsed.ok) return;
    assert.equal(parsed.rows[0]?.caption, "swatch, front");
    assert.equal(parsed.rows[0]?.sourceUrl, "https://example.com/a.jpg");
  });

  it("rejects JSON that is not a photo list", () => {
    const parsed = parsePhotoManifest('{"hello":1}', "manifest.json");
    assert.equal(parsed.ok, false);
  });
});

describe("photo import plan", () => {
  it("matches a code, keeps the source in the caption, and makes the first photo primary", () => {
    const parsed = parsePhotoManifest(
      JSON.stringify({
        photos: [
          {
            file: "one.jpg",
            material: "F010-03",
            caption: "Front",
            sourceUrl: "https://example.com/one.jpg",
          },
          {
            file: "two.jpg",
            material: "f010-03",
            sourceUrl: "https://example.com/two.jpg",
          },
        ],
      }),
      "manifest.json",
    );
    assert.equal(parsed.ok, true);
    if (!parsed.ok) return;
    const plan = planPhotoImport({
      rows: parsed.rows,
      availableFiles: ["one.jpg", "two.jpg"],
      materials: [fabric],
    });
    assert.equal(plan[0]?.status, "import");
    assert.equal(plan[0]?.willBePrimary, true);
    assert.equal(plan[0]?.caption, "Front — https://example.com/one.jpg");
    assert.equal(plan[1]?.status, "import");
    assert.equal(plan[1]?.willBePrimary, false);
    assert.equal(plan[1]?.materialCode, "F010-03");
  });

  it("skips an unknown code, a missing file, and a repeated source URL", () => {
    const plan = planPhotoImport({
      rows: [
        {
          row: 1,
          file: "missing.jpg",
          material: "F010-03",
          caption: null,
          sourceUrl: null,
        },
        {
          row: 2,
          file: "known.jpg",
          material: "NO-SUCH",
          caption: null,
          sourceUrl: null,
        },
        {
          row: 3,
          file: "again.jpg",
          material: "F010-03",
          caption: null,
          sourceUrl: "https://example.com/again.jpg",
        },
        {
          row: 4,
          file: null,
          material: "F010-03",
          caption: null,
          sourceUrl: "https://example.com/again.jpg",
        },
      ],
      availableFiles: ["known.jpg", "again.jpg"],
      materials: [
        {
          ...fabric,
          captions: ["https://example.com/again.jpg"],
        },
      ],
    });
    assert.match(plan[0]?.reason ?? "", /was not in the upload/);
    assert.match(plan[1]?.reason ?? "", /Unknown material code/);
    assert.match(plan[2]?.reason ?? "", /already on that material/);
    assert.equal(plan[3]?.status, "skip");
    assert.equal(plan[2]?.willBePrimary, false);
  });

  it("does not make a later photo primary when an earlier one in the batch is", () => {
    const plan = planPhotoImport({
      rows: [
        {
          row: 1,
          file: null,
          material: "7",
          caption: null,
          sourceUrl: "https://example.com/a.jpg",
        },
        {
          row: 2,
          file: null,
          material: "7",
          caption: null,
          sourceUrl: "https://example.com/b.jpg",
        },
      ],
      availableFiles: [],
      materials: [{ ...fabric, hasPrimary: false }],
    });
    assert.equal(plan[0]?.willBePrimary, true);
    assert.equal(plan[1]?.willBePrimary, false);
    assert.equal(plan[1]?.materialId, 7);
  });

  it("leaves primary off when the material already has one", () => {
    const plan = planPhotoImport({
      rows: [
        {
          row: 1,
          file: "one.jpg",
          material: "F010-03",
          caption: null,
          sourceUrl: null,
        },
      ],
      availableFiles: ["one.jpg"],
      materials: [{ ...fabric, hasPrimary: true }],
    });
    assert.equal(plan[0]?.status, "import");
    assert.equal(plan[0]?.willBePrimary, false);
  });

  it("rejects a caption that cannot fit the source URL", () => {
    const result = captionForPhoto(
      "x".repeat(180),
      "https://example.com/very-long",
    );
    assert.equal(result.ok, false);
    assert.equal(
      captionHasSource(
        "Front — https://example.com/a.jpg",
        "https://example.com/a.jpg",
      ),
      true,
    );
  });

  it("accepts a public https link and rejects a private one", () => {
    assert.equal(
      publicHttpsUrl("https://example.com/a.jpg"),
      "https://example.com/a.jpg",
    );
    assert.equal(publicHttpsUrl("http://example.com/a.jpg"), null);
    assert.equal(publicHttpsUrl("https://127.0.0.1/a.jpg"), null);
    assert.equal(publicHttpsUrl("https://192.168.1.4/a.jpg"), null);
  });

  it("recognises jpeg, png, and webp", () => {
    assert.equal(
      sniffImageType(Uint8Array.from([0xff, 0xd8, 0xff, 0x00])),
      "jpeg",
    );
    assert.equal(
      sniffImageType(Uint8Array.from([0x89, 0x50, 0x4e, 0x47, 0, 0, 0, 0])),
      "png",
    );
    const webp = new Uint8Array(12);
    webp.set([0x52, 0x49, 0x46, 0x46], 0);
    webp.set([0x57, 0x45, 0x42, 0x50], 8);
    assert.equal(sniffImageType(webp), "webp");
    assert.equal(sniffImageType(Uint8Array.from([1, 2, 3])), null);
  });
});
