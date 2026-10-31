import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  SUGGESTION_LIMIT,
  filterMaterials,
  suggestMaterials,
  supplierSearchText,
  type InventoryMaterial,
} from "./search.ts";

function material(
  overrides: Partial<InventoryMaterial> &
    Pick<InventoryMaterial, "id" | "materialCode">,
): InventoryMaterial {
  return {
    fabricName: null,
    colourName: null,
    fabricType: null,
    content: null,
    supplierName: null,
    binLocation: null,
    needsReview: false,
    onHandM: null,
    reservedM: null,
    availableM: null,
    isLowStock: false,
    ...overrides,
  };
}

const lime = material({
  id: 1,
  materialCode: "F002-125",
  fabricName: "Thalassa swim knit",
  colourName: "lime green",
  fabricType: "knit",
  content: "nylon",
  supplierName: "Telio",
  availableM: 12,
  isLowStock: true,
  needsReview: true,
});

const peach = material({
  id: 2,
  materialCode: "F002-121",
  fabricName: "Peach jersey",
  colourName: "peach",
  content: "cotton",
  supplierName: "Ann's Fabric Shop",
  availableM: 4,
});

const other = material({
  id: 3,
  materialCode: "F003-02",
  fabricName: "Black mesh",
  colourName: "black",
  supplierName: "Rose E Dee",
  availableM: 20,
});

const catalog = [lime, peach, other];
const none = { query: "", type: "", lowOnly: false, reviewOnly: false };

describe("material search", () => {
  it("matches a material id by prefix, colour number, or middle fragment", () => {
    const codes = (query: string) =>
      filterMaterials(catalog, { ...none, query }).map(
        (item) => item.materialCode,
      );

    assert.deepEqual(codes("f002"), ["F002-125", "F002-121"]);
    assert.deepEqual(codes("F002"), ["F002-125", "F002-121"]);
    assert.deepEqual(codes("125"), ["F002-125"]);
    assert.deepEqual(codes("F002-125"), ["F002-125"]);
    // 002-12 is inside both F002-125 and F002-121, and not inside F003-02.
    assert.deepEqual(codes("002-12"), ["F002-125", "F002-121"]);
  });

  it("matches name, colour, type, content, and supplier without case", () => {
    assert.equal(
      filterMaterials(catalog, { ...none, query: "SWIM" })[0]?.materialCode,
      "F002-125",
    );
    assert.equal(
      filterMaterials(catalog, { ...none, query: "Lime" })[0]?.materialCode,
      "F002-125",
    );
    assert.equal(
      filterMaterials(catalog, { ...none, query: "KNIT" })[0]?.materialCode,
      "F002-125",
    );
    assert.equal(
      filterMaterials(catalog, { ...none, query: "Nylon" })[0]?.materialCode,
      "F002-125",
    );
    assert.equal(
      filterMaterials(catalog, { ...none, query: "telio" })[0]?.materialCode,
      "F002-125",
    );
    assert.equal(
      filterMaterials(catalog, { ...none, query: "ann's" })[0]?.materialCode,
      "F002-121",
    );
  });

  it("requires every word to match and ignores a price-like string that is not a material field", () => {
    assert.equal(
      filterMaterials(catalog, { ...none, query: "f002 lime" }).length,
      1,
    );
    assert.equal(
      filterMaterials(catalog, { ...none, query: "f002 black" }).length,
      0,
    );
    assert.equal(
      filterMaterials(catalog, { ...none, query: "12.50" }).length,
      0,
    );
  });

  it("applies type, low stock, and needs review together with the query", () => {
    const filters = {
      query: "f002",
      type: "nylon",
      lowOnly: true,
      reviewOnly: true,
    };
    assert.deepEqual(
      filterMaterials(catalog, filters).map((item) => item.materialCode),
      ["F002-125"],
    );
    assert.deepEqual(
      filterMaterials(catalog, { ...filters, type: "cotton" }).map(
        (item) => item.materialCode,
      ),
      [],
    );
  });

  it("suggests at most eight matches and nothing when the query is blank", () => {
    const many = Array.from({ length: 10 }, (_, index) =>
      material({
        id: index + 1,
        materialCode: `F002-${index}`,
        fabricName: "knit",
      }),
    );
    assert.equal(suggestMaterials(catalog, none).length, 0);
    assert.equal(
      suggestMaterials(many, { ...none, query: "f002" }).length,
      SUGGESTION_LIMIT,
    );
    assert.equal(
      suggestMaterials(many, { ...none, query: "knit" })[0]?.materialCode,
      "F002-0",
    );
  });

  it("keeps both supplier names when the link and the written name differ", () => {
    assert.equal(supplierSearchText("Telio", "Telio"), "Telio");
    assert.equal(supplierSearchText("Telio", "  "), "Telio");
    assert.equal(
      supplierSearchText("Ann's Fabric Shop", "Ann's"),
      "Ann's Fabric Shop Ann's",
    );
    assert.equal(supplierSearchText(null, "Rose E Dee"), "Rose E Dee");
  });
});
