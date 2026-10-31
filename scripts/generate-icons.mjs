// Draws the home-screen icons. Run with: node scripts/generate-icons.mjs

import { deflateSync } from "node:zlib";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const wine = [110, 36, 54, 255];
const cream = [243, 235, 227, 255];
const gold = [166, 132, 86, 255];

function crc32(buffer) {
  let crc = 0xffffffff;
  for (const byte of buffer) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit += 1) {
      crc = crc & 1 ? 0xedb88320 ^ (crc >>> 1) : crc >>> 1;
    }
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  const name = Buffer.from(type);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([name, data])));
  return Buffer.concat([length, name, data, crc]);
}

function png(size) {
  const raw = Buffer.alloc((size * 4 + 1) * size);
  const pad = size * 0.12;

  for (let y = 0; y < size; y += 1) {
    const row = y * (size * 4 + 1);
    raw[row] = 0;
    for (let x = 0; x < size; x += 1) {
      const offset = row + 1 + x * 4;
      const color = pixel(x, y, size, pad);
      raw[offset] = color[0];
      raw[offset + 1] = color[1];
      raw[offset + 2] = color[2];
      raw[offset + 3] = color[3];
    }
  }

  const header = Buffer.alloc(13);
  header.writeUInt32BE(size, 0);
  header.writeUInt32BE(size, 4);
  header[8] = 8;
  header[9] = 6;

  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk("IHDR", header),
    chunk("IDAT", deflateSync(raw)),
    chunk("IEND", Buffer.alloc(0)),
  ]);
}

function pixel(x, y, size, pad) {
  if (x < pad || y < pad || x >= size - pad || y >= size - pad) return wine;

  const inner = size - pad * 2;
  const nx = (x - pad) / inner;
  const ny = (y - pad) / inner;
  const barre = ny > 0.56 && ny < 0.64 && nx > 0.16 && nx < 0.84;
  const leftPost = nx > 0.2 && nx < 0.28 && ny > 0.28 && ny < 0.64;
  const rightPost = nx > 0.72 && nx < 0.8 && ny > 0.28 && ny < 0.64;

  if (barre) return gold;
  if (leftPost || rightPost) return cream;
  return wine;
}

const dir = join(root, "public", "icons");
mkdirSync(dir, { recursive: true });

const files = [
  ["icon-192.png", 192],
  ["icon-512.png", 512],
  ["apple-touch-icon.png", 180],
];

for (const [name, size] of files) {
  writeFileSync(join(dir, name), png(size));
}

console.log(`Wrote ${files.length} icons to public/icons`);
