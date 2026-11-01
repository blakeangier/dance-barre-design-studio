-- 06_purchases.sql
-- Idempotent import from the 2026-10-30 tracker export.
-- Run after the inventory migration. Safe to run again.

insert into public.purchase_orders (
          po_ref, supplier_id, supplier_as_written, po_date, po_date_raw, ship_eta_raw,
          source_tab, source_row
        ) values (
          '2084720',
          (select id from public.suppliers where supplier_code = 'SUP-TELIO'),
          'Telio', '2026-09-09', '2026-09-09 00:00:00', 'ASAP',
          'Purchases', 4
        )
        on conflict (po_ref) do update set
          supplier_id = excluded.supplier_id,
          supplier_as_written = excluded.supplier_as_written,
          po_date = excluded.po_date,
          po_date_raw = excluded.po_date_raw,
          ship_eta_raw = excluded.ship_eta_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL001',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F003-03'),
        'F003-03', 'F003-03 off white', '03 off white', 'Cotton Scuba',
        '45759', 15, '15.0', '019',
        'order 19: vest/shorts=15m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 4, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 8'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 7.65, '7.65', null, null,
        114.75, '114.75'
      from public.purchase_order_lines where line_code = 'PL001'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL002',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F023-02'),
        'F023-02', 'F023-02 blk', '02 blk', 'Roselyn Satin',
        '23599', 30, '30.0', '001',
        null, 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 5, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 9'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 6.35, '6.35', null, null,
        190.5, '190.5'
      from public.purchase_order_lines where line_code = 'PL002'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL003',
        (select id from public.purchase_orders where po_ref = '2084720'),
        null,
        'F023-04', 'F023-04 navy', '04 navy', 'Roselyn Satin',
        '23599', 15, '15.0', '014',
        'order 14 -', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'NOT IN MATERIALS', true,
        'Material id check: NOT IN MATERIALS',
        'Purchases', 6, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 10'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 6.35, '6.35', null, null,
        95.25, '95.25'
      from public.purchase_order_lines where line_code = 'PL003'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL004',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F021-29'),
        'F021-29', 'F021-29 blue', '29 blue', 'Poseidon',
        '27150', 15, '15.0', '003',
        'order 3=3m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 7, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 11'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 9.85, '9.85', null, null,
        147.75, '147.75'
      from public.purchase_order_lines where line_code = 'PL004'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL005',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F021-09'),
        'F021-09', 'F021-09 fushia', '09 fushia', 'Poseidon',
        '27150', 24, '24.0', '003, 020',
        'order 3=3m, order 20=20m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 8, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 12'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 9.85, '9.85', null, null,
        236.4, '236.4'
      from public.purchase_order_lines where line_code = 'PL005'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL006',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F001-01'),
        'F001-01', 'F001-01 white', '01 white', 'Mova Flex',
        '46536', 15, '15.0', '028',
        'order 28=15m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 9, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 13'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 6.95, '6.95', null, null,
        104.25, '104.25'
      from public.purchase_order_lines where line_code = 'PL006'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL007',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 'F001-06 beige- on B/O for 8-12 weeks', '06 beige', 'Mova Flex',
        '46536', 155, '155.0', '005, 006',
        'Order 005-130m, Order 6-28m', 'Telio order of Sept 9, 2026 | "on B/O for 8-12 weeks" (per Fabric/Col # cell)', 'Back-ordered',
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 10, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 14'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 6.95, '6.95', 0.1, '0.1',
        969.525, '969.525'
      from public.purchase_order_lines where line_code = 'PL007'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL008',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F001-11'),
        'F001-11', 'F001-11-mauve', '11-mauve', 'Mova Flex',
        '46536', 20, '20.0', '009, 021',
        'order 9=6m, order 21=14m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 11, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 15'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 6.95, '6.95', null, null,
        139, '139'
      from public.purchase_order_lines where line_code = 'PL008'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL009',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F001-20'),
        'F001-20', 'F001-20 brown', '20-brown', 'Mova Flex',
        '46536', 22, '22.0', '031',
        'order 31=22m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 12, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 16'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 6.95, '6.95', null, null,
        152.9, '152.9'
      from public.purchase_order_lines where line_code = 'PL009'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL010',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F001-34'),
        'F001-34', 'F001-34 green', '34 green', 'Mova Flex',
        '46536', 19, '19.0', '031',
        null, 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 13, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 17'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 6.95, '6.95', null, null,
        132.05, '132.05'
      from public.purchase_order_lines where line_code = 'PL010'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL011',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F002-125'),
        'F002-125', 'F002-125 lime', '125-lime', 'Thalassa Swim',
        '46535', 100, '100.0', '005',
        'order 5=100m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 14, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 18'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4.9, '4.9', 0.1, '0.1',
        441, '441'
      from public.purchase_order_lines where line_code = 'PL011'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL012',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F002-10'),
        'F002-10', 'F002-10 purple', '10 purple', 'Thalassa Swim',
        '46535', 100, '100.0', '007',
        'Order 007=81m,', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 15, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 19'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4.9, '4.9', 0.1, '0.1',
        441, '441'
      from public.purchase_order_lines where line_code = 'PL012'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL013',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F002-33'),
        'F002-33', 'F002-33 orange', '33 orange', 'Thalassa Swim',
        '46535', 22, '22.0', '007',
        null, 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 16, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 20'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4.9, '4.9', null, null,
        107.8, '107.8'
      from public.purchase_order_lines where line_code = 'PL013'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL014',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F002-24'),
        'F002-24', 'F002-24-hot pink', '24 hot pink', 'Thalassa Swim',
        '46535', 22, '22.0', '007',
        null, 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 17, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 21'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4.9, '4.9', null, null,
        107.8, '107.8'
      from public.purchase_order_lines where line_code = 'PL014'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL015',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F002-19'),
        'F002-19', 'F002-19 red', '19 red', 'Thalassa Swim',
        '46535', 15, '15.0', '008',
        'order 008=8m,', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 18, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 22'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4.9, '4.9', null, null,
        73.5, '73.5'
      from public.purchase_order_lines where line_code = 'PL015'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL016',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F002-98'),
        'F002-98', 'F002-98 blue', '98 - blue', 'Thalassa Swim',
        '46535', 22, '22.0', '011, 013, 025',
        'order 11=7m, order 13=.5m, order 25=10m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 19, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 23'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4.9, '4.9', null, null,
        107.8, '107.8'
      from public.purchase_order_lines where line_code = 'PL016'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL017',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F002-06'),
        'F002-06', 'F002-06 lt blue', '06 lt blue', 'Thalassa Swim',
        '46535', 15, '15.0', '012',
        'order 12=7m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 20, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 24'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4.9, '4.9', null, null,
        73.5, '73.5'
      from public.purchase_order_lines where line_code = 'PL017'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL018',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F002-106'),
        'F002-106', 'F002-106 clay', '106 clay', 'Thalassa Swim',
        '46535', 15, '15.0', '029',
        'order 29=9m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 21, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 25'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4.9, '4.9', null, null,
        73.5, '73.5'
      from public.purchase_order_lines where line_code = 'PL018'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL019',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F002-121'),
        'F002-121', 'F002-121 peach', '121 peach', 'Thalassa Swim',
        '46535', 15, '15.0', '013, 028',
        'order 013=9m, order 028=3m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 22, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 26'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4.9, '4.9', null, null,
        73.5, '73.5'
      from public.purchase_order_lines where line_code = 'PL019'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL020',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F012-119'),
        'F012-119', 'F012-119 nude', '119 nude', 'Mesh',
        '98808', 60, '60.0', '006',
        'order 6=60m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 23, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 27'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 5.8, '5.8', null, null,
        348, '348'
      from public.purchase_order_lines where line_code = 'PL020'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL021',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F027-17'),
        'F027-17', 'F027-17 pale blue', '17 pale blue', 'Repetto',
        '39560', 16, '16.0', '012, 022',
        'order 12=8m, order 22=8m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 24, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 28'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 9.85, '9.85', null, null,
        157.6, '157.6'
      from public.purchase_order_lines where line_code = 'PL021'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL022',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F022-07'),
        'F022-07', 'F022-07 wine', '07 wine', 'Norah Chenille Lace',
        '46597', 15, '15.0', '014',
        'order 14=15m', 'Telio order of Sept 9, 2026 | no stretch-cancelled', 'Cancelled',
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 25, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 29'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 8, '8.0', null, null,
        120, '120'
      from public.purchase_order_lines where line_code = 'PL022'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL023',
        (select id from public.purchase_orders where po_ref = '2084720'),
        null,
        'F036-06', 'F036-06', '06 wine', 'Elise Chenille',
        '46616', 15, '15.0', '014',
        'order 14=15m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'NOT IN MATERIALS', true,
        'Material id check: NOT IN MATERIALS',
        'Purchases', 26, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 30'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 6.25, '6.25', null, null,
        93.75, '93.75'
      from public.purchase_order_lines where line_code = 'PL023'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL024',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F025-02'),
        'F025-02', 'F025-02 blk', '02 blk', 'Digital Mesh Print',
        '47136', 30, '30.0', '018',
        'order 18-=30m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 27, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 31'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 3.95, '3.95', null, null,
        118.5, '118.5'
      from public.purchase_order_lines where line_code = 'PL024'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL025',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F009-02'),
        'F009-02', 'F009-02', '02 blk', 'Viola Lace',
        '44752', 15, '15.0', '020',
        'order 20=10m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 28, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 32'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4.15, '4.15', null, null,
        62.25, '62.25'
      from public.purchase_order_lines where line_code = 'PL025'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL026',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F009-01'),
        'F009-01', 'F009-01', '01 white', 'Viola Lace',
        '44752', 26, '26.0', '028',
        'order 28=26m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 29, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 33'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4.15, '4.15', null, null,
        107.9, '107.9'
      from public.purchase_order_lines where line_code = 'PL026'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL027',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F026-11'),
        'F026-11', 'F026-11', '11 mauve', 'Mova Air Mesh',
        '46537', 26, '26.0', '021',
        'order 21 =26m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 30, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 34'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 5.25, '5.25', null, null,
        136.5, '136.5'
      from public.purchase_order_lines where line_code = 'PL027'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL028',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F026-25'),
        'F026-25', 'F026-25', '25 beige', 'Mova Air Mesh',
        '46537', 15, '15.0', '025',
        'order 25=12m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 31, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 35'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 5.25, '5.25', null, null,
        78.75, '78.75'
      from public.purchase_order_lines where line_code = 'PL028'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL029',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F026-27'),
        'F026-27', 'F026-27', '27 pale blue', 'Mova Air Mesh',
        '46537', 15, '15.0', '025',
        'order 25=12m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 32, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 36'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 5.25, '5.25', null, null,
        78.75, '78.75'
      from public.purchase_order_lines where line_code = 'PL029'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL030',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F029-01'),
        'F029-01', 'F029-01', '01 multi', 'Patterned Mesh',
        '47160', 20, '20.0', '029',
        'order 29=20m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 33, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 37'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 5.95, '5.95', null, null,
        119, '119'
      from public.purchase_order_lines where line_code = 'PL030'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL031',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F028-04'),
        'F028-04', 'F028-04', '04 gold', 'Wanderlust',
        '46055', 15, '15.0', '031',
        'order 31=4m', 'Telio order of Sept 9, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 34, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 38'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4.15, '4.15', null, null,
        62.25, '62.25'
      from public.purchase_order_lines where line_code = 'PL031'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL032',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F021-28'),
        'F021-28', 'F021-28 gold', '28 - gold', 'Poseidon',
        '27150', 60, '60.0', '003',
        'order 3=55m', 'Added to Telio order 2084720 (emailed Aug 14 per source)', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 35, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 43'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 9.85, '9.85', null, null,
        591, '591'
      from public.purchase_order_lines where line_code = 'PL032'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL033',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F021-12'),
        'F021-12', 'F021-12 LT gold', '12 - LT gold', 'Poseidon',
        '27150', 15, '15.0', '003',
        'order 3=3m, order 15=5m', 'Added to Telio order 2084720 (emailed Aug 14 per source)', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 36, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 44'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 9.85, '9.85', null, null,
        147.75, '147.75'
      from public.purchase_order_lines where line_code = 'PL033'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL034',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F021-23'),
        'F021-23', 'F021-23 orange', '23 orange', 'Poseidon',
        '27150', 15, '15.0', '003',
        'order 3=3m', 'Added to Telio order 2084720 (emailed Aug 14 per source)', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 37, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 45'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 9.85, '9.85', null, null,
        147.75, '147.75'
      from public.purchase_order_lines where line_code = 'PL034'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL035',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F003-08'),
        'F003-08', 'F003-08 teal', '08 - teal', 'Cotton Scuba',
        '45759', 30, '30.0', '017',
        'order 17=20m', 'Added to Telio order 2084720 (emailed Aug 14 per source)', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 38, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 46'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 7.65, '7.65', null, null,
        229.5, '229.5'
      from public.purchase_order_lines where line_code = 'PL035'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL036',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F024-01'),
        'F024-01', 'F024-01', '01 print as is', 'Dakota Digital Print',
        '47122', 25, '25.0', '009',
        'order 9=25m', 'Added to Telio order 2084720 (emailed Aug 14 per source)', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 39, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 47'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 7.55, '7.55', null, null,
        188.75, '188.75'
      from public.purchase_order_lines where line_code = 'PL036'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL037',
        (select id from public.purchase_orders where po_ref = '2084720'),
        (select id from public.materials where material_code = 'F003-02'),
        'F003-02', 'F003-02 blk', '02 blk', 'Cotton Scuba',
        '45759', 40, '40.0', '002, 023',
        'order 002: boys pant=1.2m, Order 023=22m', 'Added to Telio order 2084720 (emailed Aug 14 per source)', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 40, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 48'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 7.65, '7.65', null, null,
        306, '306'
      from public.purchase_order_lines where line_code = 'PL037'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_orders (
          po_ref, supplier_id, supplier_as_written, po_date, po_date_raw, ship_eta_raw,
          source_tab, source_row
        ) values (
          'Ann''s Fabric Shop 2026-09-05 (no PO #)',
          (select id from public.suppliers where supplier_code = 'SUP-ANNS'),
          'Ann''s Fabric Shop', '2026-09-05', '2026-09-05 00:00:00', null,
          'Purchases', 41
        )
        on conflict (po_ref) do update set
          supplier_id = excluded.supplier_id,
          supplier_as_written = excluded.supplier_as_written,
          po_date = excluded.po_date,
          po_date_raw = excluded.po_date_raw,
          ship_eta_raw = excluded.ship_eta_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL038',
        (select id from public.purchase_orders where po_ref = 'Ann''s Fabric Shop 2026-09-05 (no PO #)'),
        (select id from public.materials where material_code = 'F031'),
        'F031', 'F031 navy/wht dot', 'navy/wht dot', 'lycra polka dot',
        null, 16, '16.0', '033',
        null, 'Placed with Melissa via email Sept 5, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 41, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 54'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 13, '13.0', null, null,
        208, '208'
      from public.purchase_order_lines where line_code = 'PL038'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL039',
        (select id from public.purchase_orders where po_ref = 'Ann''s Fabric Shop 2026-09-05 (no PO #)'),
        null,
        null, 'register it', 'blue', 'organza',
        null, 15, '15.0', '011',
        'order 11:skirts=12m', 'Placed with Melissa via email Sept 5, 2026', null,
        null, null, null, null,
        'NO ID', true,
        'Material id check: NO ID',
        'Purchases', 42, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 55'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 7, '7.0', null, null,
        105, '105'
      from public.purchase_order_lines where line_code = 'PL039'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL040',
        (select id from public.purchase_orders where po_ref = 'Ann''s Fabric Shop 2026-09-05 (no PO #)'),
        (select id from public.materials where material_code = 'F017-02'),
        'F017-02', 'F017-02', 'red/white', 'lycra gingham',
        null, 8, '8.0', '008',
        'order 008:skirts=8m', 'Placed with Melissa via email Sept 5, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 43, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 56'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 13, '13.0', null, null,
        104, '104'
      from public.purchase_order_lines where line_code = 'PL040'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL041',
        (select id from public.purchase_orders where po_ref = 'Ann''s Fabric Shop 2026-09-05 (no PO #)'),
        (select id from public.materials where material_code = 'F014-01'),
        'F014-01', 'F014-01', 'blue/yellow', 'plaid',
        null, 12, '12.0', '015',
        'already ordered it - need 10m more', 'Placed with Melissa via email Sept 5, 2026', null,
        null, null, null, null,
        'OK', false,
        null,
        'Purchases', 44, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 57'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 10, '10.0', null, null,
        120, '120'
      from public.purchase_order_lines where line_code = 'PL041'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_orders (
          po_ref, supplier_id, supplier_as_written, po_date, po_date_raw, ship_eta_raw,
          source_tab, source_row
        ) values (
          'Rose E Dee 2026-09-04 (no PO #)',
          (select id from public.suppliers where supplier_code = 'SUP-ROSEEDEE'),
          'Rose E Dee', '2026-09-04', '2026-09-04 00:00:00', null,
          'Purchases', 45
        )
        on conflict (po_ref) do update set
          supplier_id = excluded.supplier_id,
          supplier_as_written = excluded.supplier_as_written,
          po_date = excluded.po_date,
          po_date_raw = excluded.po_date_raw,
          ship_eta_raw = excluded.ship_eta_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL042',
        (select id from public.purchase_orders where po_ref = 'Rose E Dee 2026-09-04 (no PO #)'),
        null,
        null, null, 'blk', 'Organza - blk',
        null, 15, '15.0', '001',
        null, 'Emailed to Maria Sept 4, 2026', null,
        null, null, null, null,
        'NO ID', true,
        'Material id check: NO ID',
        'Purchases', 45, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 62'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, null, null, null, null,
        null, null
      from public.purchase_order_lines where line_code = 'PL042'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL043',
        (select id from public.purchase_orders where po_ref = 'Rose E Dee 2026-09-04 (no PO #)'),
        null,
        null, null, 'blk', 'Fusible Tricot-blk',
        null, 32, '32.0', null,
        null, 'Emailed to Maria Sept 4, 2026', null,
        null, null, null, null,
        'NO ID', true,
        'Material id check: NO ID',
        'Purchases', 46, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 63'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4, '4.0', null, null,
        128, '128'
      from public.purchase_order_lines where line_code = 'PL043'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;

insert into public.purchase_order_lines (
        line_code, purchase_order_id, material_id, material_code_raw, fabric_as_written,
        supplier_colour, fabric_name_as_written, supplier_fabric_code, qty_ordered_m,
        qty_ordered_raw, studio_orders_raw, assigned_order_raw, line_note, status_raw,
        received_m, received_raw, received_on, received_on_raw, id_check, needs_review,
        needs_review_reason, source_tab, source_row, source_label
      ) values (
        'PL044',
        (select id from public.purchase_orders where po_ref = 'Rose E Dee 2026-09-04 (no PO #)'),
        null,
        null, null, 'white', 'Fusible Tricot-wht',
        null, 32, '32.0', null,
        null, 'Emailed to Maria Sept 4, 2026', null,
        null, null, null, null,
        'NO ID', true,
        'Material id check: NO ID',
        'Purchases', 47, 'SOURCE: Fabric Registry (Sept 13, 2026) Purchases row 64'
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
        source_label = excluded.source_label;

insert into public.purchase_line_prices (
        line_id, price_per_m, price_raw, discount_entered, discount_raw,
        line_total, line_total_raw
      )
      select id, 4, '4.0', null, null,
        128, '128'
      from public.purchase_order_lines where line_code = 'PL044'
      on conflict (line_id) do update set
        price_per_m = excluded.price_per_m,
        price_raw = excluded.price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        line_total = excluded.line_total,
        line_total_raw = excluded.line_total_raw;
