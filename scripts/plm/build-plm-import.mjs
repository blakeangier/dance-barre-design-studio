// Reads the 2026-10-30 tracker CSVs and writes idempotent SQL.
// Run from the repo root: node scripts/plm/build-plm-import.mjs
// The SQL has no psql commands. Each file can be run on its own, in order.

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import {
  STAGE_NAMES,
  SIZE_CODES,
  blank,
  containsEmail,
  isSizeDataRow,
  materialIdForBom,
  parseCheckCell,
  parseDate,
  parseInteger,
  parseMetres,
  parseNumber,
  parseStageCell,
  text,
  normalizeOrderStatus,
} from "./parse-lib.mjs";

const root = join(dirname(fileURLToPath(import.meta.url)), "..", "..");
const dataDir = join(root, "data", "plm-export-2026-10-30");
const outDir = join(root, "scripts", "import");
const MAX_BYTES = 190_000;

const files = loadFiles();
const covered = new Set();
const extraReviews = [];
preloadCovered();
const statements = {
  suppliers: [],
  materials: [],
  orders: [],
  styles: [],
  transactions: [],
  purchases: [],
  sizes: [],
  bom: [],
  fittings: [],
  reviews: [],
};

buildSuppliers();
buildMaterials();
buildOrders();
buildStyles();
buildTransactions();
buildPurchases();
buildSizes();
buildBom();
buildFittings();
buildReviews();

const chunks = writeSql();
const counts = countStatements();
writeFileSync(
  join(outDir, "EXPECTED_COUNTS.txt"),
  [
    "Expected rows after running the import SQL on an empty inventory schema.",
    "Re-running the same files updates these rows; it does not add duplicates.",
    "",
    ...Object.entries(counts).map(([table, count]) => `${table}\t${count}`),
    "",
    `extra review items created by this import: ${extraReviews.length}`,
    ...summarizeExtra(),
    "",
    "Skipped tabs: Dashboard, Tasks, Tasks Done, Fabric Tags, README (except the 2 m threshold, which is in the migration), and the empty Form tabs.",
    "",
  ].join("\n"),
);

console.log(chunks.map((file) => `${file.name}\t${file.bytes}`).join("\n"));
console.log(counts);
console.log("extra reviews", extraReviews.length, summarizeExtra());

function loadFiles() {
  const names = [
    "Materials",
    "Transactions",
    "Suppliers",
    "Purchases",
    "Orders",
    "Styles",
    "Sizes",
    "BOM",
    "Fittings",
    "Needs_Review",
  ];
  const loaded = {};
  for (const name of names) {
    loaded[name] = parseCsv(readFileSync(join(dataDir, `${name}.csv`), "utf8"));
  }
  return loaded;
}

function preloadCovered() {
  for (const { row } of dataRows("Needs_Review")) {
    if (text(row[0])) covered.add(`${text(row[2])}|${text(row[5])}`);
  }
}

function dataRows(name) {
  return files[name].slice(3).map((row, index) => ({
    row,
    sourceRow: index + 4,
  }));
}

function buildSuppliers() {
  for (const { row, sourceRow } of dataRows("Suppliers")) {
    const code = text(row[0]);
    if (!code || code === "Supplier ID") continue;
    const lead = parseInteger(row[8]);
    statements.suppliers.push(
      `insert into public.suppliers (
        supplier_code, name, website, lead_time_days, lead_time_raw,
        minimum_order, volume_discount, notes, needs_data,
        source_tab, source_row, source_label
      ) values (
        ${q(code)}, ${q(text(row[1]))}, ${q(text(row[6]))},
        ${num(lead.integer)}, ${q(lead.raw)},
        ${q(text(row[9]))}, ${q(text(row[10]))}, ${q(text(row[11]))}, ${q(text(row[12]))},
        'Suppliers', ${sourceRow}, ${q(text(row[16]))}
      )
      on conflict (supplier_code) do update set
        name = excluded.name,
        website = excluded.website,
        lead_time_days = excluded.lead_time_days,
        lead_time_raw = excluded.lead_time_raw,
        minimum_order = excluded.minimum_order,
        volume_discount = excluded.volume_discount,
        notes = excluded.notes,
        needs_data = excluded.needs_data,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;`,
    );
    statements.suppliers.push(
      `insert into public.supplier_contacts (
        supplier_id, contact_name, email, phone, address, account_number
      )
      select id, ${q(text(row[2]))}, ${q(text(row[3]))}, ${q(text(row[4]))},
        ${q(text(row[5]))}, ${q(text(row[7]))}
      from public.suppliers where supplier_code = ${q(code)}
      on conflict (supplier_id) do update set
        contact_name = excluded.contact_name,
        email = excluded.email,
        phone = excluded.phone,
        address = excluded.address,
        account_number = excluded.account_number;`,
    );
  }
}

function buildMaterials() {
  for (const { row, sourceRow } of dataRows("Materials")) {
    const code = text(row[0]);
    if (!code) continue;
    const width = parseNumber(row[13]);
    const cuttable = parseNumber(row[14]);
    const gsm = parseNumber(row[15]);
    const reorder = parseMetres(row[27]);
    const registryStock = parseMetres(row[33]);
    const needsData = text(row[31]);
    const reviewReason = [
      needsData,
      registryStock.needsReview ? registryStock.reason : null,
    ]
      .filter(Boolean)
      .join(" ");
    statements.materials.push(
      `insert into public.materials (
        material_code, fabric_number, colour_number, colour_name, fabric_name,
        supplier_fabric_code, supplier_id, supplier_as_written, content, fabric_type,
        width_cm, width_raw, cuttable_width_cm, cuttable_width_raw, gsm, gsm_raw,
        eco_cert, care, roll_status, bin_location, swatch_link, stock_count_recorded,
        reorder_point_m, reorder_point_raw, needs_review, needs_review_reason,
        registry_stock_raw, registry_ordered_raw, registry_supplier_order,
        registry_order_date_raw, registry_date_received_raw, registry_received_raw,
        registry_allocated_raw, registry_order_history, registry_notes,
        source_stock_flag, source_tab, source_row, source_label
      ) values (
        ${q(code)}, ${q(text(row[1]))}, ${q(text(row[2]))}, ${q(text(row[3]))}, ${q(text(row[4]))},
        ${q(text(row[5]))},
        (select id from public.suppliers where supplier_code = ${q(text(row[6]))}),
        ${q(text(row[7]))}, ${q(text(row[8]))}, ${q(text(row[9]))},
        ${num(width.number)}, ${q(width.raw)}, ${num(cuttable.number)}, ${q(cuttable.raw)},
        ${num(gsm.number)}, ${q(gsm.raw)},
        ${q(text(row[16]))}, ${q(text(row[17]))}, ${q(text(row[18]))}, ${q(text(row[19]))},
        ${q(text(row[20]))}, ${q(text(row[21]))},
        ${num(reorder.metres)}, ${q(reorder.raw)},
        ${needsData || registryStock.needsReview ? "true" : "false"},
        ${q(reviewReason || null)},
        ${q(text(row[33]))}, ${q(text(row[34]))}, ${q(text(row[35]))},
        ${q(text(row[36]))}, ${q(text(row[37]))}, ${q(text(row[38]))},
        ${q(text(row[39]))}, ${q(text(row[40]))}, ${q(text(row[41]))},
        ${q(text(row[28]))}, 'Materials', ${sourceRow}, ${q(text(row[42]))}
      )
      on conflict (material_code) do update set
        fabric_number = excluded.fabric_number,
        colour_number = excluded.colour_number,
        colour_name = excluded.colour_name,
        fabric_name = excluded.fabric_name,
        supplier_fabric_code = excluded.supplier_fabric_code,
        supplier_id = excluded.supplier_id,
        supplier_as_written = excluded.supplier_as_written,
        content = excluded.content,
        fabric_type = excluded.fabric_type,
        width_cm = excluded.width_cm,
        width_raw = excluded.width_raw,
        cuttable_width_cm = excluded.cuttable_width_cm,
        cuttable_width_raw = excluded.cuttable_width_raw,
        gsm = excluded.gsm,
        gsm_raw = excluded.gsm_raw,
        eco_cert = excluded.eco_cert,
        care = excluded.care,
        roll_status = excluded.roll_status,
        bin_location = excluded.bin_location,
        swatch_link = excluded.swatch_link,
        stock_count_recorded = excluded.stock_count_recorded,
        reorder_point_m = excluded.reorder_point_m,
        reorder_point_raw = excluded.reorder_point_raw,
        needs_review = excluded.needs_review,
        needs_review_reason = excluded.needs_review_reason,
        registry_stock_raw = excluded.registry_stock_raw,
        registry_ordered_raw = excluded.registry_ordered_raw,
        registry_supplier_order = excluded.registry_supplier_order,
        registry_order_date_raw = excluded.registry_order_date_raw,
        registry_date_received_raw = excluded.registry_date_received_raw,
        registry_received_raw = excluded.registry_received_raw,
        registry_allocated_raw = excluded.registry_allocated_raw,
        registry_order_history = excluded.registry_order_history,
        registry_notes = excluded.registry_notes,
        source_stock_flag = excluded.source_stock_flag,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;`,
    );
    const list = parseNumber(row[10]);
    const discount = parseNumber(row[11]);
    const net = parseNumber(row[12]);
    statements.materials.push(
      `insert into public.material_costs (
        material_id, list_price_per_m, list_price_raw, discount_entered, discount_raw,
        net_price_per_m, net_price_raw, source_tab, source_row
      )
      select id, ${num(list.number)}, ${q(list.raw)}, ${num(discount.number)}, ${q(discount.raw)},
        ${num(net.number)}, ${q(net.raw)}, 'Materials', ${sourceRow}
      from public.materials where material_code = ${q(code)}
      on conflict (material_id) do update set
        list_price_per_m = excluded.list_price_per_m,
        list_price_raw = excluded.list_price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        net_price_per_m = excluded.net_price_per_m,
        net_price_raw = excluded.net_price_raw,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row;`,
    );
    if (registryStock.needsReview) {
      queueReview({
        sheet: "Materials",
        record: code,
        field: "Registry: Total In stock",
        original: registryStock.raw,
        issue: registryStock.reason,
        question: `What is the actual metres on hand for ${code}?`,
        priority: "high",
        sourceRow,
      });
    }
  }
}

function buildOrders() {
  for (const { row, sourceRow } of dataRows("Orders")) {
    const number = text(row[0]);
    if (!number || !/^\d+$/.test(number)) continue;
    const status = normalizeOrderStatus(row[2]);
    const orderDate = parseDate(row[3]);
    const female = parseInteger(row[11]);
    const male = parseInteger(row[12]);
    const notes = text(row[22]);
    const notesArePrivate = containsEmail(notes);
    statements.orders.push(
      `insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        ${q(number)}, ${q(text(row[1]))}, ${q(status.status)}, ${q(status.raw)},
        ${q(orderDate.date)}, ${q(orderDate.raw)}, ${q(text(row[4]))}, ${q(text(row[8]))},
        ${num(female.integer)}, ${q(female.raw)}, ${num(male.integer)}, ${q(male.raw)},
        ${q(notesArePrivate ? null : notes)},
        'Orders', ${sourceRow}, ${q(text(row[23]))}
      )
      on conflict (order_number) do update set
        production_song = excluded.production_song,
        status = excluded.status,
        status_raw = excluded.status_raw,
        order_date = excluded.order_date,
        order_date_raw = excluded.order_date_raw,
        fitting_target_raw = excluded.fitting_target_raw,
        accessory = excluded.accessory,
        female_total = excluded.female_total,
        female_total_raw = excluded.female_total_raw,
        male_total = excluded.male_total,
        male_total_raw = excluded.male_total_raw,
        notes = excluded.notes,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;`,
    );
    const budget = parseNumber(row[7]);
    const accessoryCost = parseNumber(row[9]);
    const accessoryQty = parseInteger(row[10]);
    statements.orders.push(
      `insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, ${q(text(row[5]))}, ${q(text(row[6]))},
        ${num(budget.number)}, ${q(budget.raw)},
        ${num(accessoryCost.number)}, ${q(accessoryCost.raw)},
        ${num(accessoryQty.integer)}, ${q(accessoryQty.raw)},
        ${q(notesArePrivate ? notes : null)}
      from public.costume_orders where order_number = ${q(number)}
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;`,
    );
  }
}

function buildStyles() {
  for (const { row, sourceRow } of dataRows("Styles")) {
    const key = text(row[0]);
    if (!key) continue;
    const fabric = text(row[10]);
    statements.styles.push(
      `insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        ${q(key)}, ${q(text(row[1]))},
        (select id from public.costume_orders where order_number = ${q(text(row[2]))}),
        ${q(text(row[2]))}, ${q(text(row[3]))}, ${q(text(row[4]))}, ${q(text(row[5]))},
        ${q(text(row[6]))}, ${q(text(row[7]))}, ${q(text(row[8]))}, ${q(text(row[9]))},
        ${q(fabric)},
        (select id from public.materials where material_code = ${q(fabric)}),
        ${q(text(row[11]))}, ${q(text(row[36]))}, ${q(text(row[37]))},
        'Styles', ${sourceRow}, ${q(text(row[38]))}
      )
      on conflict (style_key) do update set
        style_code = excluded.style_code,
        order_id = excluded.order_id,
        order_number_raw = excluded.order_number_raw,
        production_song = excluded.production_song,
        garment_description = excluded.garment_description,
        category = excluded.category,
        group_name = excluded.group_name,
        version_label = excluded.version_label,
        child_or_adult = excluded.child_or_adult,
        character_note = excluded.character_note,
        fabric_code_raw = excluded.fabric_code_raw,
        material_id = excluded.material_id,
        fabric_in_materials = excluded.fabric_in_materials,
        size_qty_raw = excluded.size_qty_raw,
        flags = excluded.flags,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;`,
    );
    STAGE_NAMES.forEach((stage, index) => {
      const parsed = parseStageCell(row[12 + index]);
      const check = parseCheckCell(row[23 + index]);
      statements.styles.push(
        `insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, ${q(stage)}, ${index + 1}, ${q(parsed.cellText)}, ${q(parsed.interpretedOn)},
          ${bool(parsed.interpretedYes)}, ${q(check.checkText)}, ${bool(check.checkYes)},
          'Styles', ${sourceRow}
        from public.styles where style_key = ${q(key)}
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;`,
      );
    });
  }
}

function buildTransactions() {
  for (const { row, sourceRow } of dataRows("Transactions")) {
    const code = text(row[0]);
    if (!code) continue;
    const kind = mapTxnType(row[2]);
    const qty = parseMetres(row[4]);
    const when = parseDate(row[1]);
    const material = text(row[3]);
    statements.transactions.push(
      `insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        ${q(code)}, ${q(when.date)}, ${q(when.raw)}, ${q(kind)},
        (select id from public.materials where material_code = ${q(material)}),
        ${q(material)}, ${num(qty.metres)}, ${q(qty.raw)},
        (select id from public.costume_orders where order_number = ${q(text(row[5]))}),
        ${q(text(row[5]))}, ${q(text(row[6]))}, ${q(text(row[7]))}, ${q(text(row[8]))},
        'Transactions', ${sourceRow}, ${q(text(row[9]))}
      )
      on conflict (txn_code) do update set
        occurred_on = excluded.occurred_on,
        occurred_on_raw = excluded.occurred_on_raw,
        txn_type = excluded.txn_type,
        material_id = excluded.material_id,
        material_code_raw = excluded.material_code_raw,
        qty_m = excluded.qty_m,
        qty_raw = excluded.qty_raw,
        order_id = excluded.order_id,
        order_number_raw = excluded.order_number_raw,
        po_ref = excluded.po_ref,
        description = excluded.description,
        entered_by = excluded.entered_by,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;`,
    );
    if (qty.needsReview) {
      queueReview({
        sheet: "Transactions",
        record: code,
        field: "Qty (m)",
        original: qty.raw,
        issue: qty.reason,
        question: `What quantity in metres should ${code} use?`,
        priority: "high",
        sourceRow,
      });
    }
  }
}

function buildPurchases() {
  const refs = new Set();
  for (const { row, sourceRow } of dataRows("Purchases")) {
    const line = text(row[0]);
    if (!line || line === "PO Line") continue;
    const ref = text(row[1]) ?? `UNNUMBERED-${line}`;
    if (!refs.has(ref)) {
      refs.add(ref);
      const poDate = parseDate(row[4]);
      statements.purchases.push(
        `insert into public.purchase_orders (
          po_ref, supplier_id, supplier_as_written, po_date, po_date_raw, ship_eta_raw,
          source_tab, source_row
        ) values (
          ${q(ref)},
          (select id from public.suppliers where supplier_code = ${q(text(row[2]))}),
          ${q(text(row[3]))}, ${q(poDate.date)}, ${q(poDate.raw)}, ${q(text(row[5]))},
          'Purchases', ${sourceRow}
        )
        on conflict (po_ref) do update set
          supplier_id = excluded.supplier_id,
          supplier_as_written = excluded.supplier_as_written,
          po_date = excluded.po_date,
          po_date_raw = excluded.po_date_raw,
          ship_eta_raw = excluded.ship_eta_raw;`,
      );
    }
    const idCheck = text(row[22]);
    const material = text(row[7]);
    const unknown =
      idCheck === "NO ID" || idCheck === "NOT IN MATERIALS" || !material;
    const qty = parseMetres(row[11]);
    const received = parseMetres(row[19]);
    const receivedOn = parseDate(row[20]);
    statements.purchases.push(
      `insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        ${q(line)},
        (select id from public.purchase_orders where po_ref = ${q(ref)}),
        ${unknown ? "null" : `(select id from public.materials where material_code = ${q(material)})`},
        ${q(material)}, ${q(text(row[8]))}, ${q(text(row[9]))}, ${q(text(row[10]))},
        ${q(text(row[15]))}, ${num(qty.metres)}, ${q(qty.raw)}, ${q(text(row[6]))},
        ${q(text(row[16]))}, ${q(text(row[17]))}, ${q(text(row[18]))},
        ${num(received.metres)}, ${q(received.raw)}, ${q(receivedOn.date)}, ${q(receivedOn.raw)},
        ${q(idCheck)}, ${unknown ? "true" : "false"},
        ${q(unknown ? `Material id check: ${idCheck ?? "blank"}` : null)},
        'Purchases', ${sourceRow}, ${q(text(row[23]))}
      )
      on conflict (line_code) do update set
        purchase_order_id = excluded.purchase_order_id,
        material_id = excluded.material_id,
        material_code_raw = excluded.material_code_raw,
        fabric_as_written = excluded.fabric_as_written,
        supplier_colour = excluded.supplier_colour,
        fabric_name_as_written = excluded.fabric_name_as_written,
        supplier_fabric_code = excluded.supplier_fabric_code,
        qty_ordered_m = excluded.qty_ordered_m,
        qty_ordered_raw = excluded.qty_ordered_raw,
        studio_orders_raw = excluded.studio_orders_raw,
        assigned_order_raw = excluded.assigned_order_raw,
        line_note = excluded.line_note,
        status_raw = excluded.status_raw,
        received_m = excluded.received_m,
        received_raw = excluded.received_raw,
        received_on = excluded.received_on,
        received_on_raw = excluded.received_on_raw,
        id_check = excluded.id_check,
        needs_review = excluded.needs_review,
        needs_review_reason = excluded.needs_review_reason,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;`,
    );
    const price = parseNumber(row[12]);
    const discount = parseNumber(row[13]);
    const total = parseNumber(row[14]);
    statements.purchases.push(
      `insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, ${num(price.number)}, ${q(price.raw)}, ${num(discount.number)}, ${q(discount.raw)},
        ${num(total.number)}, ${q(total.raw)}
      from public.purchase_order_lines where line_code = ${q(line)}
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;`,
    );
  }
}

function buildSizes() {
  const header = files.Sizes[2];
  const sizeIndexes = SIZE_CODES.map((code) => header.indexOf(code));
  for (const { row, sourceRow } of dataRows("Sizes")) {
    if (!isSizeDataRow(row)) continue;
    const key = text(row[0]);
    SIZE_CODES.forEach((code, index) => {
      const cell = row[sizeIndexes[index]] ?? "";
      if (blank(cell)) return;
      const qty = parseInteger(cell);
      statements.sizes.push(
        `insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, ${q(code)}, ${num(qty.integer)}, ${q(qty.raw)},
          'Sizes', ${sourceRow}
        from public.styles s where s.style_key = ${q(key)}
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;`,
      );
      if (qty.needsReview) {
        queueReview({
          sheet: "Sizes",
          record: key,
          field: code,
          original: qty.raw,
          issue: qty.reason,
          question: `What whole-number quantity should size ${code} be for ${key}?`,
          priority: "medium",
          sourceRow,
        });
      }
    });
  }
}

function buildBom() {
  for (const { row, sourceRow } of dataRows("BOM")) {
    const line = text(row[0]);
    if (!line) continue;
    const link = materialIdForBom(row[8], row[9]);
    const consumption = parseMetres(row[12]);
    const needsReview = link.needsReview || consumption.needsReview;
    const reason = [
      link.reason,
      consumption.needsReview ? consumption.reason : null,
    ]
      .filter(Boolean)
      .join(" ");
    statements.bom.push(
      `insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        ${q(line)},
        (select id from public.styles where style_key = ${q(text(row[1]))}),
        ${q(text(row[1]))},
        (select id from public.costume_orders where order_number = ${q(text(row[2]))}),
        ${q(text(row[2]))}, ${q(text(row[4]))}, ${q(text(row[5]))}, ${q(text(row[6]))},
        ${q(text(row[7]))},
        ${link.materialCode ? `(select id from public.materials where material_code = ${q(link.materialCode)})` : "null"},
        ${q(text(row[9]))}, ${q(text(row[10]))}, ${q(text(row[11]))},
        ${num(consumption.metres)}, ${q(consumption.raw)}, ${q(text(row[13]))},
        ${q(text(row[20]))}, ${needsReview ? "true" : "false"}, ${q(reason || null)},
        'BOM', ${sourceRow}, ${q(text(row[21]))}
      )
      on conflict (line_code) do update set
        style_id = excluded.style_id,
        style_key_raw = excluded.style_key_raw,
        order_id = excluded.order_id,
        order_number_raw = excluded.order_number_raw,
        garment = excluded.garment,
        version_label = excluded.version_label,
        component = excluded.component,
        placement = excluded.placement,
        material_id = excluded.material_id,
        fabric_as_written = excluded.fabric_as_written,
        fabric_name = excluded.fabric_name,
        colour = excluded.colour,
        consumption_per_unit_m = excluded.consumption_per_unit_m,
        consumption_raw = excluded.consumption_raw,
        consumption_basis = excluded.consumption_basis,
        flag = excluded.flag,
        needs_review = excluded.needs_review,
        needs_review_reason = excluded.needs_review_reason,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;`,
    );
    const used = parseNumber(row[17]);
    const perUnit = parseNumber(row[18]);
    const total = parseNumber(row[19]);
    statements.bom.push(
      `insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, ${q(text(row[16]))}, ${num(used.number)}, ${q(used.raw)},
        ${num(perUnit.number)}, ${q(perUnit.raw)}, ${num(total.number)}, ${q(total.raw)}
      from public.bom_lines where line_code = ${q(line)}
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;`,
    );
    if (consumption.needsReview) {
      queueReview({
        sheet: "BOM",
        record: line,
        field: "Consumption / Unit (m)",
        original: consumption.raw,
        issue: consumption.reason,
        question: `What consumption in metres should ${line} use?`,
        priority: "high",
        sourceRow,
      });
    }
  }
}

function buildFittings() {
  let section = "samples";
  for (const { row, sourceRow } of dataRows("Fittings")) {
    const code = text(row[0]);
    if (!code) continue;
    if (/checklist/i.test(code)) {
      section = "checks";
      continue;
    }
    if (/production gates/i.test(code)) {
      section = "gates";
      continue;
    }
    if (code === "Order #" || /^order 005 checklist/i.test(code)) continue;
    if (section === "checks") {
      statements.fittings.push(
        `insert into public.fitting_checks (
          order_id, order_number_raw, check_name, required_text, completed_text,
          check_date_raw, approved_by, notes, source_tab, source_row, source_label
        )
        select id, ${q(code)}, ${q(text(row[1]))}, ${q(text(row[2]))}, ${q(text(row[3]))},
          ${q(text(row[4]))}, ${q(text(row[5]))}, ${q(text(row[6]))},
          'Fittings', ${sourceRow}, ${q(text(row[7]))}
        from public.costume_orders where order_number = ${q(code)}
        on conflict (order_number_raw, check_name) do update set
          order_id = excluded.order_id,
          required_text = excluded.required_text,
          completed_text = excluded.completed_text,
          check_date_raw = excluded.check_date_raw,
          approved_by = excluded.approved_by,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;`,
      );
      continue;
    }
    if (section === "gates") {
      statements.fittings.push(
        `insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, ${q(code)}, ${q(text(row[1]))}, ${q(text(row[2]))}, ${q(text(row[3]))},
          ${q(text(row[4]))}, ${q(text(row[5]))}, ${q(text(row[6]))}, ${q(text(row[7]))},
          'Fittings', ${sourceRow}, ${q(text(row[8]))}
        from public.costume_orders where order_number = ${q(code)}
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;`,
      );
      continue;
    }
    if (!/^FIT\d+$/.test(code)) continue;
    statements.fittings.push(
      `insert into public.fittings (
        fitting_code, order_id, order_number_raw, style_id, style_key_raw, sample_label,
        garment, version_label, size_label, pattern_status, sample_complete, fit_test_raw,
        corrections_required, corrections_complete, approval_status, approved_by,
        approval_raw, comments, source_tab, source_row, source_label
      ) values (
        ${q(code)},
        (select id from public.costume_orders where order_number = ${q(text(row[1]))}),
        ${q(text(row[1]))},
        (select id from public.styles where style_key = ${q(text(row[2]))}),
        ${q(text(row[2]))}, ${q(text(row[3]))}, ${q(text(row[4]))}, ${q(text(row[5]))},
        ${q(text(row[6]))}, ${q(text(row[7]))}, ${q(text(row[8]))}, ${q(text(row[9]))},
        ${q(text(row[10]))}, ${q(text(row[11]))}, ${q(text(row[12]))}, ${q(text(row[13]))},
        ${q(text(row[14]))}, ${q(text(row[15]))}, 'Fittings', ${sourceRow}, ${q(text(row[16]))}
      )
      on conflict (fitting_code) do update set
        order_id = excluded.order_id,
        order_number_raw = excluded.order_number_raw,
        style_id = excluded.style_id,
        style_key_raw = excluded.style_key_raw,
        sample_label = excluded.sample_label,
        garment = excluded.garment,
        version_label = excluded.version_label,
        size_label = excluded.size_label,
        pattern_status = excluded.pattern_status,
        sample_complete = excluded.sample_complete,
        fit_test_raw = excluded.fit_test_raw,
        corrections_required = excluded.corrections_required,
        corrections_complete = excluded.corrections_complete,
        approval_status = excluded.approval_status,
        approved_by = excluded.approved_by,
        approval_raw = excluded.approval_raw,
        comments = excluded.comments,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;`,
    );
  }
}

function buildReviews() {
  for (const { row, sourceRow } of dataRows("Needs_Review")) {
    const code = text(row[0]);
    if (!code) continue;
    const priority = (text(row[8]) ?? "").toLowerCase();
    const statusRaw = text(row[9]);
    const status =
      statusRaw && statusRaw.toLowerCase() === "resolved" ? "resolved" : "open";
    covered.add(`${text(row[2])}|${text(row[5])}`);
    statements.reviews.push(
      reviewInsert({
        code,
        sheet: text(row[1]),
        record: text(row[2]),
        sourceDetail: text(row[3]),
        field: text(row[4]),
        original: text(row[5]),
        issue: text(row[6]),
        question: text(row[7]),
        priority: ["high", "medium", "low"].includes(priority)
          ? priority
          : null,
        status,
        statusRaw,
        resolution: text(row[10]),
        sourceTab: "Needs_Review",
        sourceRow,
      }),
    );
  }
  for (const review of extraReviews) {
    statements.reviews.push(reviewInsert(review));
  }
  statements.reviews.push(`
update public.review_items r
set material_id = m.id
from public.materials m
where r.material_id is null and r.record_label = m.material_code;

update public.review_items r
set order_id = o.id
from public.costume_orders o
where r.order_id is null and r.record_label = o.order_number;

update public.review_items r
set style_id = s.id
from public.styles s
where r.style_id is null and r.record_label = s.style_key;

update public.review_items r
set bom_line_id = b.id
from public.bom_lines b
where r.bom_line_id is null and r.record_label = b.line_code;

update public.review_items r
set purchase_line_id = p.id
from public.purchase_order_lines p
where r.purchase_line_id is null and r.record_label = p.line_code;

update public.review_items r
set supplier_id = s.id
from public.suppliers s
where r.supplier_id is null and r.record_label = s.supplier_code;
`);
}

function queueReview(review) {
  const key = `${review.record}|${review.original}`;
  if (covered.has(key)) return;
  covered.add(key);
  const code = `IMP-${review.sheet}-${review.sourceRow}-${slug(review.field)}`;
  extraReviews.push({
    code,
    sheet: review.sheet,
    record: review.record,
    sourceDetail: `Import of ${review.sheet}.csv row ${review.sourceRow}`,
    field: review.field,
    original: review.original,
    issue: review.issue,
    question: review.question,
    priority: review.priority,
    status: "open",
    statusRaw: "Open",
    resolution: null,
    sourceTab: review.sheet,
    sourceRow: review.sourceRow,
  });
}

function reviewInsert(review) {
  return `insert into public.review_items (
    review_code, source_sheet, record_label, source_detail, field_name, original_text,
    issue, question, priority, status, status_raw, resolution, source_tab, source_row
  ) values (
    ${q(review.code)}, ${q(review.sheet)}, ${q(review.record)}, ${q(review.sourceDetail)},
    ${q(review.field)}, ${q(review.original)}, ${q(review.issue)}, ${q(review.question)},
    ${q(review.priority)}, ${q(review.status)}, ${q(review.statusRaw)}, ${q(review.resolution)},
    ${q(review.sourceTab)}, ${review.sourceRow}
  )
  on conflict (review_code) do update set
    source_sheet = excluded.source_sheet,
    record_label = excluded.record_label,
    source_detail = excluded.source_detail,
    field_name = excluded.field_name,
    original_text = excluded.original_text,
    issue = excluded.issue,
    question = excluded.question,
    priority = excluded.priority,
    status = excluded.status,
    status_raw = excluded.status_raw,
    resolution = excluded.resolution,
    source_tab = excluded.source_tab,
    source_row = excluded.source_row;`;
}

function mapTxnType(value) {
  const raw = text(value);
  const map = {
    Receive: "receive",
    Reserve: "reserve",
    Issue: "use",
    Use: "use",
    Adjust: "adjust",
    Return: "return",
  };
  if (raw && map[raw]) return map[raw];
  throw new Error(`Unexpected transaction type: ${raw}`);
}

function writeSql() {
  mkdirSync(outDir, { recursive: true });
  const groups = [
    ["01_suppliers.sql", statements.suppliers],
    ["02_materials.sql", statements.materials],
    ["03_orders.sql", statements.orders],
    ["04_styles.sql", statements.styles],
    ["05_transactions.sql", statements.transactions],
    ["06_purchases.sql", statements.purchases],
    ["07_sizes.sql", statements.sizes],
    ["08_bom.sql", statements.bom],
    ["09_fittings.sql", statements.fittings],
    ["10_reviews.sql", statements.reviews],
  ];
  const written = [];
  for (const [name, lines] of groups) {
    const parts = splitStatements(name, lines);
    for (const part of parts) {
      const body = `-- ${part.name}\n-- Idempotent import from the 2026-10-30 tracker export.\n-- Run after the inventory migration. Safe to run again.\n\n${part.sql}\n`;
      writeFileSync(join(outDir, part.name), body);
      written.push({ name: part.name, bytes: Buffer.byteLength(body) });
    }
  }
  return written;
}

function splitStatements(name, lines) {
  const chunks = [];
  let current = [];
  let size = 0;
  let part = 1;
  for (const line of lines) {
    const bytes = Buffer.byteLength(line) + 2;
    if (size + bytes > MAX_BYTES && current.length > 0) {
      chunks.push({
        name: partName(name, part, true),
        sql: current.join("\n\n"),
      });
      part += 1;
      current = [];
      size = 0;
    }
    current.push(line);
    size += bytes;
  }
  if (current.length > 0) {
    chunks.push({
      name: part > 1 ? partName(name, part, true) : name,
      sql: current.join("\n\n"),
    });
  }
  if (part > 1) {
    chunks[0].name = partName(name, 1, true);
  }
  return chunks;
}

function partName(name, part, split) {
  if (!split) return name;
  return name.replace(".sql", `_part${String(part).padStart(2, "0")}.sql`);
}

function countStatements() {
  return {
    suppliers: statements.suppliers.filter((sql) =>
      sql.startsWith("insert into public.suppliers"),
    ).length,
    supplier_contacts: statements.suppliers.filter((sql) =>
      sql.includes("public.supplier_contacts"),
    ).length,
    materials: statements.materials.filter((sql) =>
      sql.startsWith("insert into public.materials"),
    ).length,
    material_costs: statements.materials.filter((sql) =>
      sql.includes("public.material_costs"),
    ).length,
    costume_orders: statements.orders.filter((sql) =>
      sql.startsWith("insert into public.costume_orders"),
    ).length,
    order_private: statements.orders.filter((sql) =>
      sql.includes("public.order_private"),
    ).length,
    styles: statements.styles.filter((sql) =>
      sql.startsWith("insert into public.styles"),
    ).length,
    style_stages: statements.styles.filter((sql) =>
      sql.includes("public.style_stages"),
    ).length,
    stock_transactions: statements.transactions.length,
    purchase_orders: statements.purchases.filter((sql) =>
      sql.startsWith("insert into public.purchase_orders"),
    ).length,
    purchase_order_lines: statements.purchases.filter((sql) =>
      sql.startsWith("insert into public.purchase_order_lines"),
    ).length,
    purchase_line_prices: statements.purchases.filter((sql) =>
      sql.includes("public.purchase_line_prices"),
    ).length,
    order_sizes: statements.sizes.length,
    bom_lines: statements.bom.filter((sql) =>
      sql.startsWith("insert into public.bom_lines"),
    ).length,
    bom_costs: statements.bom.filter((sql) => sql.includes("public.bom_costs"))
      .length,
    fittings: statements.fittings.filter((sql) =>
      sql.includes("public.fittings ("),
    ).length,
    fitting_checks: statements.fittings.filter((sql) =>
      sql.includes("public.fitting_checks"),
    ).length,
    production_gates: statements.fittings.filter((sql) =>
      sql.includes("public.production_gates"),
    ).length,
    review_items_from_sheet: statements.reviews.filter((sql) =>
      sql.includes("'Needs_Review'"),
    ).length,
    review_items_from_import: extraReviews.length,
    inventory_settings: 1,
  };
}

function summarizeExtra() {
  const counts = {};
  for (const review of extraReviews) {
    counts[review.sheet] = (counts[review.sheet] ?? 0) + 1;
  }
  return Object.entries(counts).map(([sheet, count]) => `${sheet}\t${count}`);
}

function q(value) {
  if (value === null || value === undefined) return "null";
  return `'${String(value).replaceAll("'", "''")}'`;
}

function num(value) {
  if (value === null || value === undefined || Number.isNaN(value))
    return "null";
  return String(value);
}

function bool(value) {
  if (value === null || value === undefined) return "null";
  return value ? "true" : "false";
}

function slug(value) {
  return String(value)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let cell = "";
  let quoted = false;
  for (let i = 0; i < text.length; i += 1) {
    const char = text[i];
    if (quoted) {
      if (char === '"') {
        if (text[i + 1] === '"') {
          cell += '"';
          i += 1;
        } else {
          quoted = false;
        }
      } else {
        cell += char;
      }
    } else if (char === '"') {
      quoted = true;
    } else if (char === ",") {
      row.push(cell);
      cell = "";
    } else if (char === "\n") {
      row.push(cell);
      rows.push(row);
      row = [];
      cell = "";
    } else if (char !== "\r") {
      cell += char;
    }
  }
  if (cell.length > 0 || row.length > 0) {
    row.push(cell);
    rows.push(row);
  }
  return rows;
}
