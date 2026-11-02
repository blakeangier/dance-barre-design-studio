// Pure rules for the owner photo import. No database and no network.

export const PHOTO_IMPORT_LIMIT = 40;
export const CAPTION_LIMIT = 200;

export type ManifestRow = {
  row: number;
  file: string | null;
  material: string | null;
  caption: string | null;
  sourceUrl: string | null;
};

export type ManifestParse =
  { ok: true; rows: ManifestRow[] } | { ok: false; message: string };

export type KnownMaterial = {
  id: number;
  code: string;
  name: string | null;
  colour: string | null;
  archived: boolean;
  hasPrimary: boolean;
  captions: string[];
};

export type PlannedImport = {
  row: number;
  label: string;
  fileName: string | null;
  sourceUrl: string | null;
  materialId: number | null;
  materialCode: string | null;
  materialName: string | null;
  colour: string | null;
  caption: string | null;
  status: "import" | "skip";
  reason: string | null;
  willBePrimary: boolean;
};

const SOURCE_MARK = " — ";

export function parsePhotoManifest(
  text: string,
  filename: string,
): ManifestParse {
  const trimmed = text.replace(/^\uFEFF/, "").trim();
  if (!trimmed) return { ok: false, message: "The manifest is empty." };
  const lower = filename.toLowerCase();
  if (
    lower.endsWith(".json") ||
    trimmed.startsWith("{") ||
    trimmed.startsWith("[")
  ) {
    return parseJsonManifest(trimmed);
  }
  return parseCsvManifest(trimmed);
}

export function captionForPhoto(
  caption: string | null,
  sourceUrl: string | null,
): { ok: true; caption: string | null } | { ok: false; reason: string } {
  const note = blankToNull(caption);
  const source = blankToNull(sourceUrl);
  const text =
    note && source ? `${note}${SOURCE_MARK}${source}` : (source ?? note);
  if (text && text.length > CAPTION_LIMIT) {
    return {
      ok: false,
      reason: "Caption and source URL are longer than 200 characters.",
    };
  }
  return { ok: true, caption: text };
}

export function captionHasSource(
  caption: string | null,
  sourceUrl: string,
): boolean {
  if (!caption) return false;
  return (
    caption === sourceUrl || caption.endsWith(`${SOURCE_MARK}${sourceUrl}`)
  );
}

export function publicHttpsUrl(value: string): string | null {
  const trimmed = value.trim();
  if (!trimmed) return null;
  let url: URL;
  try {
    url = new URL(trimmed);
  } catch {
    return null;
  }
  if (url.protocol !== "https:") return null;
  if (url.username || url.password) return null;
  if (isBlockedHost(url.hostname)) return null;
  return url.toString();
}

export function isBlockedHost(hostname: string): boolean {
  const host = hostname.toLowerCase().replace(/\.+$/, "");
  if (!host) return true;
  if (
    host === "localhost" ||
    host.endsWith(".localhost") ||
    host.endsWith(".local") ||
    host === "metadata.google.internal"
  ) {
    return true;
  }
  if (host.includes(":") || /^\d+\.\d+\.\d+\.\d+$/.test(host)) {
    return isBlockedAddress(host);
  }
  return false;
}

export function isBlockedAddress(address: string): boolean {
  const value = address.toLowerCase().replace(/^\[|\]$/g, "");
  if (value.includes(":")) {
    return (
      value === "::1" ||
      value === "::" ||
      value.startsWith("fe80:") ||
      value.startsWith("fc") ||
      value.startsWith("fd")
    );
  }
  if (value === "0.0.0.0") return true;
  const parts = value.split(".").map((part) => Number(part));
  if (
    parts.length !== 4 ||
    parts.some((part) => !Number.isInteger(part) || part < 0 || part > 255)
  ) {
    return false;
  }
  const [a, b] = parts;
  if (a === 10 || a === 127 || a === 0) return true;
  if (a === 169 && b === 254) return true;
  if (a === 172 && b !== undefined && b >= 16 && b <= 31) return true;
  if (a === 192 && b === 168) return true;
  if (a === 100 && b !== undefined && b >= 64 && b <= 127) return true;
  return false;
}

export function sniffImageType(
  bytes: Uint8Array,
): "jpeg" | "png" | "webp" | null {
  if (
    bytes.length >= 3 &&
    bytes[0] === 0xff &&
    bytes[1] === 0xd8 &&
    bytes[2] === 0xff
  ) {
    return "jpeg";
  }
  if (
    bytes.length >= 8 &&
    bytes[0] === 0x89 &&
    bytes[1] === 0x50 &&
    bytes[2] === 0x4e &&
    bytes[3] === 0x47
  ) {
    return "png";
  }
  if (
    bytes.length >= 12 &&
    bytes[0] === 0x52 &&
    bytes[1] === 0x49 &&
    bytes[2] === 0x46 &&
    bytes[3] === 0x46 &&
    bytes[8] === 0x57 &&
    bytes[9] === 0x45 &&
    bytes[10] === 0x42 &&
    bytes[11] === 0x50
  ) {
    return "webp";
  }
  return null;
}

export function planPhotoImport(input: {
  rows: ManifestRow[];
  availableFiles: readonly string[];
  materials: readonly KnownMaterial[];
  byteErrors?: ReadonlyMap<number, string>;
}): PlannedImport[] {
  const names = new Map<string, number>();
  for (const fileName of input.availableFiles) {
    const base = basename(fileName).toLowerCase();
    names.set(base, (names.get(base) ?? 0) + 1);
  }
  const structural = input.rows.map((row) =>
    planRow(row, names, input.materials, input.byteErrors?.get(row.row)),
  );
  return finalize(structural, input.materials);
}

function planRow(
  row: ManifestRow,
  names: Map<string, number>,
  materials: readonly KnownMaterial[],
  byteError: string | undefined,
): PlannedImport {
  const fileName = blankToNull(row.file);
  const label =
    fileName ?? (row.sourceUrl ? `Link ${row.row}` : `Row ${row.row}`);
  const base: PlannedImport = {
    row: row.row,
    label,
    fileName,
    sourceUrl: null,
    materialId: null,
    materialCode: null,
    materialName: null,
    colour: null,
    caption: null,
    status: "skip",
    reason: null,
    willBePrimary: false,
  };
  const materialRef = blankToNull(row.material);
  if (!materialRef) {
    return { ...base, reason: "No material code or id." };
  }
  const material = findMaterial(materialRef, materials);
  if (!material) {
    return { ...base, reason: `Unknown material code ${materialRef}.` };
  }
  base.materialId = material.id;
  base.materialCode = material.code;
  base.materialName = material.name;
  base.colour = material.colour;
  if (material.archived) {
    return { ...base, reason: `${material.code} is archived.` };
  }
  const rawSource = blankToNull(row.sourceUrl);
  if (rawSource) {
    const source = publicHttpsUrl(rawSource);
    if (!source) {
      return {
        ...base,
        reason: "The source link must be a public https address.",
      };
    }
    base.sourceUrl = source;
  }
  if (!fileName && !base.sourceUrl) {
    return { ...base, reason: "No image file or link." };
  }
  if (fileName) {
    const count = names.get(basename(fileName).toLowerCase()) ?? 0;
    if (count === 0) {
      return {
        ...base,
        reason: `Image file ${basename(fileName)} was not in the upload.`,
      };
    }
    if (count > 1) {
      return {
        ...base,
        reason: `More than one file is named ${basename(fileName)}.`,
      };
    }
  }
  const caption = captionForPhoto(row.caption, base.sourceUrl);
  if (!caption.ok) return { ...base, reason: caption.reason };
  base.caption = caption.caption;
  if (byteError) return { ...base, reason: byteError };
  return { ...base, status: "import", reason: null };
}

function finalize(
  rows: PlannedImport[],
  materials: readonly KnownMaterial[],
): PlannedImport[] {
  const byId = new Map(materials.map((material) => [material.id, material]));
  const seen = new Set<string>();
  const gaining = new Set<number>();
  return rows.map((row) => {
    if (row.status !== "import" || row.materialId == null) {
      return { ...row, willBePrimary: false };
    }
    if (row.sourceUrl) {
      const key = `${row.materialId}|${row.sourceUrl}`;
      const existing = byId.get(row.materialId)?.captions ?? [];
      const duplicate =
        seen.has(key) ||
        existing.some((caption) => captionHasSource(caption, row.sourceUrl!));
      if (duplicate) {
        return {
          ...row,
          status: "skip",
          willBePrimary: false,
          reason: "This source URL is already on that material.",
        };
      }
      seen.add(key);
    }
    const material = byId.get(row.materialId);
    const taken = Boolean(material?.hasPrimary) || gaining.has(row.materialId);
    if (!taken) gaining.add(row.materialId);
    return { ...row, willBePrimary: !taken };
  });
}

function findMaterial(
  ref: string,
  materials: readonly KnownMaterial[],
): KnownMaterial | null {
  const trimmed = ref.trim();
  const byCode = materials.filter(
    (material) => material.code.toLowerCase() === trimmed.toLowerCase(),
  );
  if (byCode.length === 1) return byCode[0] ?? null;
  if (byCode.length > 1) return null;
  if (/^\d+$/.test(trimmed)) {
    const id = Number(trimmed);
    return materials.find((material) => material.id === id) ?? null;
  }
  return null;
}

function parseJsonManifest(text: string): ManifestParse {
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch {
    return { ok: false, message: "The JSON manifest could not be read." };
  }
  const list = Array.isArray(parsed)
    ? parsed
    : parsed &&
        typeof parsed === "object" &&
        Array.isArray((parsed as { photos?: unknown }).photos)
      ? (parsed as { photos: unknown[] }).photos
      : null;
  if (!list) {
    return {
      ok: false,
      message: 'JSON must be a list, or an object with a "photos" list.',
    };
  }
  if (list.length > PHOTO_IMPORT_LIMIT) {
    return {
      ok: false,
      message: `Import up to ${PHOTO_IMPORT_LIMIT} photos at a time.`,
    };
  }
  const rows: ManifestRow[] = [];
  for (const [index, item] of list.entries()) {
    if (!item || typeof item !== "object" || Array.isArray(item)) {
      return {
        ok: false,
        message: `Photo ${index + 1} in the JSON manifest is not an object.`,
      };
    }
    const record = item as Record<string, unknown>;
    rows.push({
      row: index + 1,
      file: textField(record, ["file", "filename"]),
      material:
        textField(record, ["material", "material_code", "materialCode"]) ??
        textField(record, ["material_id", "materialId"]),
      caption: textField(record, ["caption"]),
      sourceUrl: textField(record, ["sourceUrl", "source_url", "source"]),
    });
  }
  return { ok: true, rows };
}

function parseCsvManifest(text: string): ManifestParse {
  const table = parseCsv(text);
  const header = table[0];
  if (!header) return { ok: false, message: "The CSV manifest is empty." };
  const columns = header.map((cell) => cell.trim().toLowerCase());
  const fileIndex = columns.findIndex(
    (cell) => cell === "file" || cell === "filename",
  );
  const materialIndex = columns.findIndex((cell) =>
    ["material", "material_code", "materialcode"].includes(cell),
  );
  const idIndex = columns.findIndex((cell) =>
    ["material_id", "materialid"].includes(cell),
  );
  const captionIndex = columns.findIndex((cell) => cell === "caption");
  const sourceIndex = columns.findIndex((cell) =>
    ["source_url", "sourceurl", "source"].includes(cell),
  );
  if (materialIndex < 0 && idIndex < 0) {
    return {
      ok: false,
      message: "The CSV needs a material or material_id column.",
    };
  }
  const body = table
    .slice(1)
    .filter((cells) => cells.some((cell) => cell.trim()));
  if (body.length > PHOTO_IMPORT_LIMIT) {
    return {
      ok: false,
      message: `Import up to ${PHOTO_IMPORT_LIMIT} photos at a time.`,
    };
  }
  return {
    ok: true,
    rows: body.map((cells, index) => ({
      row: index + 1,
      file: cellAt(cells, fileIndex),
      material: cellAt(cells, materialIndex) ?? cellAt(cells, idIndex),
      caption: cellAt(cells, captionIndex),
      sourceUrl: cellAt(cells, sourceIndex),
    })),
  };
}

function parseCsv(text: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [];
  let cell = "";
  let quoted = false;
  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    if (quoted) {
      if (char === '"') {
        if (text[index + 1] === '"') {
          cell += '"';
          index += 1;
        } else {
          quoted = false;
        }
      } else {
        cell += char ?? "";
      }
      continue;
    }
    if (char === '"') {
      quoted = true;
    } else if (char === ",") {
      row.push(cell);
      cell = "";
    } else if (char === "\n" || char === "\r") {
      if (char === "\r" && text[index + 1] === "\n") index += 1;
      row.push(cell);
      cell = "";
      rows.push(row);
      row = [];
    } else {
      cell += char ?? "";
    }
  }
  if (cell.length > 0 || row.length > 0) {
    row.push(cell);
    rows.push(row);
  }
  return rows.filter((cells) => cells.some((value) => value.trim() !== ""));
}

function textField(
  record: Record<string, unknown>,
  keys: string[],
): string | null {
  for (const key of keys) {
    const value = record[key];
    if (typeof value === "string" && value.trim()) return value.trim();
    if (typeof value === "number" && Number.isFinite(value))
      return String(value);
  }
  return null;
}

function cellAt(cells: string[], index: number): string | null {
  if (index < 0) return null;
  return blankToNull(cells[index] ?? null);
}

function blankToNull(value: string | null | undefined): string | null {
  const trimmed = value?.trim() ?? "";
  return trimmed ? trimmed : null;
}

function basename(fileName: string): string {
  const parts = fileName.split(/[/\\]/);
  return parts[parts.length - 1] ?? fileName;
}
