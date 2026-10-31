// Builds the logo files and home-screen icons from the Dance Barre mark.
// Run with: node scripts/generate-icons.mjs
//
// The source JPEG is the uploaded brand logo. If it is not in the uploads
// folder, the script rebuilds the icons from public/brand/dancebarre-logo.png.

import { mkdirSync, writeFileSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "sharp";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const brandDir = join(root, "public", "brand");
const iconDir = join(root, "public", "icons");
const logoPng = join(brandDir, "dancebarre-logo.png");
const sourceCandidates = [
  join(root, "brand", "dancebarre-logo.jpg"),
  "/home/ubuntu/.cursor/projects/workspace/uploads/dancebarre-logo_822b.jpg",
];

mkdirSync(brandDir, { recursive: true });
mkdirSync(iconDir, { recursive: true });

const logo = await loadLogo();
await logo
  .clone()
  .png({ compressionLevel: 9, palette: true, quality: 90, effort: 8 })
  .toFile(logoPng);
await logo
  .clone()
  .webp({ quality: 80 })
  .toFile(join(brandDir, "dancebarre-logo.webp"));

const trimmed = sharp(logoPng);
const meta = await trimmed.metadata();

await writeIcon(join(iconDir, "icon-192.png"), 192, 0.14);
await writeIcon(join(iconDir, "icon-512.png"), 512, 0.16);
await writeIcon(join(iconDir, "apple-touch-icon.png"), 180, 0.14);
await squareLogo(32, 0.08)
  .ensureAlpha()
  .png()
  .toFile(join(root, "src", "app", "icon.png"));

const faviconPng = await squareLogo(32, 0.08).ensureAlpha().png().toBuffer();
writeFileSync(
  join(root, "src", "app", "favicon.ico"),
  pngToIco(faviconPng, 32),
);

console.log(
  `Logo ${meta.width}x${meta.height}. Wrote public/brand and the PWA icons.`,
);

async function loadLogo() {
  const source = sourceCandidates.find((path) => existsSync(path));
  if (source) {
    const trimmed = sharp(source)
      .trim({ threshold: 12 })
      .resize({ width: 1000, withoutEnlargement: true });
    return knockOutWhite(trimmed);
  }
  if (existsSync(logoPng)) return sharp(logoPng);
  throw new Error("Dance Barre logo source was not found.");
}

function knockOutWhite(pipeline) {
  return pipeline
    .ensureAlpha()
    .raw()
    .toBuffer({ resolveWithObject: true })
    .then(({ data, info }) => {
      for (let i = 0; i < data.length; i += 4) {
        if (data[i] >= 248 && data[i + 1] >= 248 && data[i + 2] >= 248) {
          data[i + 3] = 0;
        }
      }
      return sharp(data, {
        raw: { width: info.width, height: info.height, channels: 4 },
      });
    });
}

function squareLogo(size, paddingRatio) {
  const inner = Math.round(size * (1 - paddingRatio * 2));
  return sharp(logoPng)
    .flatten({ background: "#ffffff" })
    .resize({
      width: inner,
      height: inner,
      fit: "contain",
      background: "#ffffff",
    })
    .extend({
      top: Math.floor((size - inner) / 2),
      bottom: Math.ceil((size - inner) / 2),
      left: Math.floor((size - inner) / 2),
      right: Math.ceil((size - inner) / 2),
      background: "#ffffff",
    });
}

async function writeIcon(path, size, paddingRatio) {
  await squareLogo(size, paddingRatio).ensureAlpha().png().toFile(path);
}

function pngToIco(png, size) {
  const header = Buffer.alloc(6);
  header.writeUInt16LE(0, 0);
  header.writeUInt16LE(1, 2);
  header.writeUInt16LE(1, 4);
  const entry = Buffer.alloc(16);
  entry[0] = size >= 256 ? 0 : size;
  entry[1] = size >= 256 ? 0 : size;
  entry.writeUInt16LE(1, 4);
  entry.writeUInt16LE(32, 6);
  entry.writeUInt32LE(png.length, 8);
  entry.writeUInt32LE(22, 12);
  return Buffer.concat([header, entry, png]);
}
