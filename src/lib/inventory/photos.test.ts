import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  PHOTO_MAX_EDGE,
  fitWithin,
  isMaterialPhotoPath,
  thumbnailPath,
} from "./photos.ts";

describe("material photo files", () => {
  it("shrinks a large photo to 1600 px on the long edge and leaves a small one", () => {
    assert.deepEqual(fitWithin(4000, 3000, PHOTO_MAX_EDGE), {
      width: 1600,
      height: 1200,
    });
    assert.deepEqual(fitWithin(800, 600, PHOTO_MAX_EDGE), {
      width: 800,
      height: 600,
    });
    assert.deepEqual(fitWithin(800, 600, 320), { width: 320, height: 240 });
  });

  it("keeps the thumbnail beside the full photo", () => {
    assert.equal(
      thumbnailPath("12/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee.webp"),
      "12/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-thumb.webp",
    );
  });

  it("only accepts a path for that material", () => {
    const path = "4/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee.webp";
    assert.equal(isMaterialPhotoPath(4, path), true);
    assert.equal(isMaterialPhotoPath(5, path), false);
    assert.equal(isMaterialPhotoPath(4, "4/../1/secret.webp"), false);
  });
});
