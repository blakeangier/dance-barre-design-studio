-- 05_transactions.sql
-- Idempotent import from the 2026-10-30 tracker export.
-- Run after the inventory migration. Safe to run again.

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0001', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F001-02'),
        'F001-02', 100, '100.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 100m)', null,
        'Transactions', 4, 'SOURCE: Fabric Registry (Sept 13, 2026) row 5'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0002', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 155, '155.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 155m)', null,
        'Transactions', 5, 'SOURCE: Fabric Registry (Sept 13, 2026) row 6'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0003', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F002-01'),
        'F002-01', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 6, 'SOURCE: Fabric Registry (Sept 13, 2026) row 14'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0004', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F002-02'),
        'F002-02', 153, '153.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 153m)', null,
        'Transactions', 7, 'SOURCE: Fabric Registry (Sept 13, 2026) row 15'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0005', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F002-10'),
        'F002-10', 17, '17.0',
        (select id from public.costume_orders where order_number = null),
        null, '2084720', 'Opening balance (registry "Total In stock" = 17m)', null,
        'Transactions', 8, 'SOURCE: Fabric Registry (Sept 13, 2026) row 17'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0006', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F002-39'),
        'F002-39', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, '2084720', 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 9, 'SOURCE: Fabric Registry (Sept 13, 2026) row 26'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0007', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F002-59'),
        'F002-59', 25, '25.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 25m)', null,
        'Transactions', 10, 'SOURCE: Fabric Registry (Sept 13, 2026) row 28'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0008', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F003-03'),
        'F003-03', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 11, 'SOURCE: Fabric Registry (Sept 13, 2026) row 35'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0009', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F003-08'),
        'F003-08', 32, '32.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 32m)', null,
        'Transactions', 12, 'SOURCE: Fabric Registry (Sept 13, 2026) row 37'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0010', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F004-19'),
        'F004-19', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 13, 'SOURCE: Fabric Registry (Sept 13, 2026) row 38'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0011', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F005-02'),
        'F005-02', 100, '100.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 100m)', null,
        'Transactions', 14, 'SOURCE: Fabric Registry (Sept 13, 2026) row 42'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0012', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F006-02'),
        'F006-02', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 15, 'SOURCE: Fabric Registry (Sept 13, 2026) row 43'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0013', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F007-20'),
        'F007-20', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 16, 'SOURCE: Fabric Registry (Sept 13, 2026) row 45'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0014', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F008-06'),
        'F008-06', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 17, 'SOURCE: Fabric Registry (Sept 13, 2026) row 46'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0015', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F009-01'),
        'F009-01', 26, '26.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 26m)', null,
        'Transactions', 18, 'SOURCE: Fabric Registry (Sept 13, 2026) row 47'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0016', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F009-02'),
        'F009-02', 14, '14.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 14m)', null,
        'Transactions', 19, 'SOURCE: Fabric Registry (Sept 13, 2026) row 48'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0017', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F010-03'),
        'F010-03', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 20, 'SOURCE: Fabric Registry (Sept 13, 2026) row 50'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0018', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F011-02'),
        'F011-02', 19, '19.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 19m)', null,
        'Transactions', 21, 'SOURCE: Fabric Registry (Sept 13, 2026) row 51'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0019', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F011-06'),
        'F011-06', 13.7, '13.7',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 13.7m)', null,
        'Transactions', 22, 'SOURCE: Fabric Registry (Sept 13, 2026) row 53'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0020', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F011-07'),
        'F011-07', 19.4, '19.4',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 19.4m)', null,
        'Transactions', 23, 'SOURCE: Fabric Registry (Sept 13, 2026) row 54'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0021', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F011-09'),
        'F011-09', 17.2, '17.2',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 17.2m)', null,
        'Transactions', 24, 'SOURCE: Fabric Registry (Sept 13, 2026) row 55'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0022', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F012-01'),
        'F012-01', 106, '106.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 106m)', null,
        'Transactions', 25, 'SOURCE: Fabric Registry (Sept 13, 2026) row 56'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0023', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F012-02'),
        'F012-02', 137, '137.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 137m)', null,
        'Transactions', 26, 'SOURCE: Fabric Registry (Sept 13, 2026) row 57'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0024', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F013-01'),
        'F013-01', 54, '54.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 54m)', null,
        'Transactions', 27, 'SOURCE: Fabric Registry (Sept 13, 2026) row 66'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0025', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F015'),
        'F015', 35, '35.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 35m)', null,
        'Transactions', 28, 'SOURCE: Fabric Registry (Sept 13, 2026) row 69'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0026', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F016-18'),
        'F016-18', 2, '2.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 2m)', null,
        'Transactions', 29, 'SOURCE: Fabric Registry (Sept 13, 2026) row 70'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0027', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F017-01'),
        'F017-01', 2, '2.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 2m)', null,
        'Transactions', 30, 'SOURCE: Fabric Registry (Sept 13, 2026) row 71'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0028', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F017-02'),
        'F017-02', 8, '8.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 8m)', null,
        'Transactions', 31, 'SOURCE: Fabric Registry (Sept 13, 2026) row 72'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0029', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F018'),
        'F018', 2, '2.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 2m)', null,
        'Transactions', 32, 'SOURCE: Fabric Registry (Sept 13, 2026) row 73'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0030', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F019'),
        'F019', 2, '2.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 2m)', null,
        'Transactions', 33, 'SOURCE: Fabric Registry (Sept 13, 2026) row 74'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0031', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F020'),
        'F020', 3, '3.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 3m)', null,
        'Transactions', 34, 'SOURCE: Fabric Registry (Sept 13, 2026) row 75'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0032', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F021-09'),
        'F021-09', 25, '25.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 25m)', null,
        'Transactions', 35, 'SOURCE: Fabric Registry (Sept 13, 2026) row 79'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0033', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F021-12'),
        'F021-12', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 36, 'SOURCE: Fabric Registry (Sept 13, 2026) row 80'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0034', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F021-23'),
        'F021-23', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 37, 'SOURCE: Fabric Registry (Sept 13, 2026) row 81'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0035', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F021-28'),
        'F021-28', 62, '62.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 62m)', null,
        'Transactions', 38, 'SOURCE: Fabric Registry (Sept 13, 2026) row 82'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0036', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F021-29'),
        'F021-29', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 39, 'SOURCE: Fabric Registry (Sept 13, 2026) row 83'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0037', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F023-144'),
        'F023-144', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 40, 'SOURCE: Fabric Registry (Sept 13, 2026) row 88'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0038', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F023-02'),
        'F023-02', 31.1, '31.1',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 31.1m)', null,
        'Transactions', 41, 'SOURCE: Fabric Registry (Sept 13, 2026) row 89'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0039', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F027-17'),
        'F027-17', 16, '16.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 16m)', null,
        'Transactions', 42, 'SOURCE: Fabric Registry (Sept 13, 2026) row 99'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0040', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F028-04'),
        'F028-04', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 43, 'SOURCE: Fabric Registry (Sept 13, 2026) row 100'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0041', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F031'),
        'F031', 16, '16.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 16m)', null,
        'Transactions', 44, 'SOURCE: Fabric Registry (Sept 13, 2026) row 104'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0042', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F035'),
        'F035', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 45, 'SOURCE: Fabric Registry (Sept 13, 2026) row 108'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0043', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F036'),
        'F036', 15, '15.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 15m)', null,
        'Transactions', 46, 'SOURCE: Fabric Registry (Sept 13, 2026) row 109'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0044', '2026-09-13', '2026-09-13 00:00:00', 'receive',
        (select id from public.materials where material_code = 'F037'),
        'F037', 2, '2.0',
        (select id from public.costume_orders where order_number = null),
        null, null, 'Opening balance (registry "Total In stock" = 2m)', null,
        'Transactions', 47, 'SOURCE: Fabric Registry (Sept 13, 2026) row 110'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0045', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F001-01'),
        'F001-01', 15, '15.0',
        (select id from public.costume_orders where order_number = '028'),
        '028', null, 'Allocation: "order 28 leo=15m"', null,
        'Transactions', 48, 'SOURCE: Fabric Registry (Sept 13, 2026) row 4'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0046', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F001-02'),
        'F001-02', 12, '12.0',
        (select id from public.costume_orders where order_number = '016'),
        '016', null, 'Allocation: "order 016:dress= 12m"', null,
        'Transactions', 49, 'SOURCE: Fabric Registry (Sept 13, 2026) row 5'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0047', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 130, '130.0',
        (select id from public.costume_orders where order_number = '005'),
        '005', null, 'Allocation: "order 005 leo & pant = 130m"', null,
        'Transactions', 50, 'SOURCE: Fabric Registry (Sept 13, 2026) row 6'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0048', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 28, '28.0',
        (select id from public.costume_orders where order_number = '006'),
        '006', null, 'Allocation: "order 006 leo= 28m"', null,
        'Transactions', 51, 'SOURCE: Fabric Registry (Sept 13, 2026) row 6'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0049', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 9, '9.0',
        (select id from public.costume_orders where order_number = '039'),
        '039', null, 'Allocation: "order 039 pant = 9m"', null,
        'Transactions', 52, 'SOURCE: Fabric Registry (Sept 13, 2026) row 6'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0050', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F001-11'),
        'F001-11', 6, '6.0',
        (select id from public.costume_orders where order_number = '009'),
        '009', null, 'Allocation: "order 009: leo=6m"', null,
        'Transactions', 53, 'SOURCE: Fabric Registry (Sept 13, 2026) row 7'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0051', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F001-11'),
        'F001-11', 14, '14.0',
        (select id from public.costume_orders where order_number = '021'),
        '021', null, 'Allocation: "order 021: leo=14m"', null,
        'Transactions', 54, 'SOURCE: Fabric Registry (Sept 13, 2026) row 7'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0052', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F001-19'),
        'F001-19', 16, '16.0',
        (select id from public.costume_orders where order_number = '035'),
        '035', null, 'Allocation: "order 035: pant = 16m"', null,
        'Transactions', 55, 'SOURCE: Fabric Registry (Sept 13, 2026) row 8'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0053', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F001-20'),
        'F001-20', 22, '22.0',
        (select id from public.costume_orders where order_number = '031'),
        '031', null, 'Allocation: "order 031 pants=22m"', null,
        'Transactions', 56, 'SOURCE: Fabric Registry (Sept 13, 2026) row 9'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0054', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F001-20'),
        'F001-20', 15, '15.0',
        (select id from public.costume_orders where order_number = '038'),
        '038', null, 'Allocation: "order 038 pants=15m"', null,
        'Transactions', 57, 'SOURCE: Fabric Registry (Sept 13, 2026) row 9'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0055', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F001-34'),
        'F001-34', 19, '19.0',
        (select id from public.costume_orders where order_number = '031'),
        '031', null, 'Allocation: "order 031 leo=19m"', null,
        'Transactions', 58, 'SOURCE: Fabric Registry (Sept 13, 2026) row 11'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0056', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-01'),
        'F002-01', 15, '15.0',
        (select id from public.costume_orders where order_number = '005'),
        '005', null, 'Allocation: "order 005: leo lining = 15m"', null,
        'Transactions', 59, 'SOURCE: Fabric Registry (Sept 13, 2026) row 14'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0057', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-02'),
        'F002-02', 75, '75.0',
        (select id from public.costume_orders where order_number = '001'),
        '001', null, 'Allocation: "order 001=75m"', null,
        'Transactions', 60, 'SOURCE: Fabric Registry (Sept 13, 2026) row 15'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0058', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-02'),
        'F002-02', 16, '16.0',
        (select id from public.costume_orders where order_number = '018'),
        '018', null, 'Allocation: "order 018: leggings=16m"', null,
        'Transactions', 61, 'SOURCE: Fabric Registry (Sept 13, 2026) row 15'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0059', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-02'),
        'F002-02', 14, '14.0',
        (select id from public.costume_orders where order_number = '022'),
        '022', null, 'Allocation: "order 22=14m"', null,
        'Transactions', 62, 'SOURCE: Fabric Registry (Sept 13, 2026) row 15'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0060', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-02'),
        'F002-02', 17, '17.0',
        (select id from public.costume_orders where order_number = '024'),
        '024', null, 'Allocation: "order 24=17m"', null,
        'Transactions', 63, 'SOURCE: Fabric Registry (Sept 13, 2026) row 15'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0061', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-06'),
        'F002-06', 7, '7.0',
        (select id from public.costume_orders where order_number = '012'),
        '012', null, 'Allocation: "order 012: LEO=7m"', null,
        'Transactions', 64, 'SOURCE: Fabric Registry (Sept 13, 2026) row 16'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0062', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-10'),
        'F002-10', 5, '5.0',
        (select id from public.costume_orders where order_number = '002'),
        '002', null, 'Allocation: "order 002: WB for leo & boy''s pant=5m"', null,
        'Transactions', 65, 'SOURCE: Fabric Registry (Sept 13, 2026) row 17'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0063', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-10'),
        'F002-10', 78, '78.0',
        (select id from public.costume_orders where order_number = '007'),
        '007', null, 'Allocation: "orders 007: pants & CF tab=78m"', null,
        'Transactions', 66, 'SOURCE: Fabric Registry (Sept 13, 2026) row 17'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0064', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-19'),
        'F002-19', 8, '8.0',
        (select id from public.costume_orders where order_number = '008'),
        '008', null, 'Allocation: "order 008: leo=8m"', null,
        'Transactions', 67, 'SOURCE: Fabric Registry (Sept 13, 2026) row 19'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0065', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-19'),
        'F002-19', 1, '1.0',
        (select id from public.costume_orders where order_number = '016'),
        '016', null, 'Allocation: "order 016: applique=1m"', null,
        'Transactions', 68, 'SOURCE: Fabric Registry (Sept 13, 2026) row 19'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0066', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-19'),
        'F002-19', 2, '2.0',
        (select id from public.costume_orders where order_number = '019'),
        '019', null, 'Allocation: "order 019: cuffs=2m"', null,
        'Transactions', 69, 'SOURCE: Fabric Registry (Sept 13, 2026) row 19'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0067', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-121'),
        'F002-121', 3, '3.0',
        (select id from public.costume_orders where order_number = '028'),
        '028', null, 'Allocation: "order 028: Cuffs & Hair Bow=3m"', null,
        'Transactions', 70, 'SOURCE: Fabric Registry (Sept 13, 2026) row 20'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0068', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-24'),
        'F002-24', 22, '22.0',
        (select id from public.costume_orders where order_number = '007'),
        '007', null, 'Allocation: "order 007: SLV=22m"', null,
        'Transactions', 71, 'SOURCE: Fabric Registry (Sept 13, 2026) row 23'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0069', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-125'),
        'F002-125', 95, '95.0',
        (select id from public.costume_orders where order_number = '005'),
        '005', null, 'Allocation: "order 005 - Leo & Pant=95m"', null,
        'Transactions', 72, 'SOURCE: Fabric Registry (Sept 13, 2026) row 24'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0070', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-33'),
        'F002-33', 22, '22.0',
        (select id from public.costume_orders where order_number = '007'),
        '007', null, 'Allocation: "order 007: SLV=22m"', null,
        'Transactions', 73, 'SOURCE: Fabric Registry (Sept 13, 2026) row 25'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0071', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-39'),
        'F002-39', 9, '9.0',
        (select id from public.costume_orders where order_number = '002'),
        '002', null, 'Allocation: "order 002: SLV ruffle & boy''s collar= 9m"', null,
        'Transactions', 74, 'SOURCE: Fabric Registry (Sept 13, 2026) row 26'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0072', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-58'),
        'F002-58', 4, '4.0',
        (select id from public.costume_orders where order_number = '008'),
        '008', null, 'Allocation: "order 008:straps & WB=4m"', null,
        'Transactions', 75, 'SOURCE: Fabric Registry (Sept 13, 2026) row 27'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0073', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-59'),
        'F002-59', 22, '22.0',
        (select id from public.costume_orders where order_number = '004'),
        '004', null, 'Allocation: "order 004: leo,pant=22m"', null,
        'Transactions', 76, 'SOURCE: Fabric Registry (Sept 13, 2026) row 28'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0074', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-98'),
        'F002-98', 8, '8.0',
        (select id from public.costume_orders where order_number = '011'),
        '011', null, 'Allocation: "order 11: Skirts=8m"', null,
        'Transactions', 77, 'SOURCE: Fabric Registry (Sept 13, 2026) row 29'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0075', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-98'),
        'F002-98', 0.5, '0.5',
        (select id from public.costume_orders where order_number = '013'),
        '013', null, 'Allocation: "order 13=.5m"', null,
        'Transactions', 78, 'SOURCE: Fabric Registry (Sept 13, 2026) row 29'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0076', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-98'),
        'F002-98', 10, '10.0',
        (select id from public.costume_orders where order_number = '025'),
        '025', null, 'Allocation: "order 25=10m"', null,
        'Transactions', 79, 'SOURCE: Fabric Registry (Sept 13, 2026) row 29'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0077', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-106'),
        'F002-106', 9, '9.0',
        (select id from public.costume_orders where order_number = '029'),
        '029', null, 'Allocation: "order 029: leo=9m"', null,
        'Transactions', 80, 'SOURCE: Fabric Registry (Sept 13, 2026) row 32'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0078', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-121#2'),
        'F002-121#2', 9, '9.0',
        (select id from public.costume_orders where order_number = '013'),
        '013', null, 'Allocation: "order 013=9m"', null,
        'Transactions', 81, 'SOURCE: Fabric Registry (Sept 13, 2026) row 34'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0079', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F002-121#2'),
        'F002-121#2', 3, '3.0',
        (select id from public.costume_orders where order_number = '028'),
        '028', null, 'Allocation: "order 028=3m"', null,
        'Transactions', 82, 'SOURCE: Fabric Registry (Sept 13, 2026) row 34'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0080', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F003-03'),
        'F003-03', 15, '15.0',
        (select id from public.costume_orders where order_number = '019'),
        '019', null, 'Allocation: "order 019: vest/pant=15m"', null,
        'Transactions', 83, 'SOURCE: Fabric Registry (Sept 13, 2026) row 35'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0081', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F003-02'),
        'F003-02', 5, '5.0',
        (select id from public.costume_orders where order_number = '001'),
        '001', null, 'Allocation: "order 001: boys pant=5m"', null,
        'Transactions', 84, 'SOURCE: Fabric Registry (Sept 13, 2026) row 36'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0082', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F003-02'),
        'F003-02', 1.2, '1.2',
        (select id from public.costume_orders where order_number = '002'),
        '002', null, 'Allocation: "order 002: boys pant=1.2m"', null,
        'Transactions', 85, 'SOURCE: Fabric Registry (Sept 13, 2026) row 36'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0083', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F003-02'),
        'F003-02', 22, '22.0',
        (select id from public.costume_orders where order_number = '023'),
        '023', null, 'Allocation: "order 023: pants=22m"', null,
        'Transactions', 86, 'SOURCE: Fabric Registry (Sept 13, 2026) row 36'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0084', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F003-08'),
        'F003-08', 21, '21.0',
        (select id from public.costume_orders where order_number = '017'),
        '017', null, 'Allocation: "order 017: pants=21m"', null,
        'Transactions', 87, 'SOURCE: Fabric Registry (Sept 13, 2026) row 37'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0085', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F005-03'),
        'F005-03', 15, '15.0',
        (select id from public.costume_orders where order_number = '003'),
        '003', null, 'Allocation: "Order 003: lining for Leo=15m"', null,
        'Transactions', 88, 'SOURCE: Fabric Registry (Sept 13, 2026) row 41'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0086', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F005-02'),
        'F005-02', 15, '15.0',
        (select id from public.costume_orders where order_number = '001'),
        '001', null, 'Allocation: "order 001: lining for Leo=15m"', null,
        'Transactions', 89, 'SOURCE: Fabric Registry (Sept 13, 2026) row 42'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0087', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F005-02'),
        'F005-02', 12, '12.0',
        (select id from public.costume_orders where order_number = '002'),
        '002', null, 'Allocation: "order 002: lining for Leo=12m"', null,
        'Transactions', 90, 'SOURCE: Fabric Registry (Sept 13, 2026) row 42'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0088', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F005-02'),
        'F005-02', 3, '3.0',
        (select id from public.costume_orders where order_number = '004'),
        '004', null, 'Allocation: "order 004: lining for Leo=3m"', null,
        'Transactions', 91, 'SOURCE: Fabric Registry (Sept 13, 2026) row 42'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0089', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F007-12'),
        'F007-12', 10, '10.0',
        (select id from public.costume_orders where order_number = '003'),
        '003', null, 'Allocation: "Order 003-brick panels=10m"', null,
        'Transactions', 92, 'SOURCE: Fabric Registry (Sept 13, 2026) row 44'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0090', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F009-01'),
        'F009-01', 26, '26.0',
        (select id from public.costume_orders where order_number = '028'),
        '028', null, 'Allocation: "Order 28 - dress = 26m"', null,
        'Transactions', 93, 'SOURCE: Fabric Registry (Sept 13, 2026) row 47'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0091', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F009-02'),
        'F009-02', 10, '10.0',
        (select id from public.costume_orders where order_number = '020'),
        '020', null, 'Allocation: "order 20: pants=10m"', null,
        'Transactions', 94, 'SOURCE: Fabric Registry (Sept 13, 2026) row 48'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0092', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F011-02'),
        'F011-02', 11, '11.0',
        (select id from public.costume_orders where order_number = '001'),
        '001', null, 'Allocation: "order 001=11m"', null,
        'Transactions', 95, 'SOURCE: Fabric Registry (Sept 13, 2026) row 51'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0093', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F011-06'),
        'F011-06', 8, '8.0',
        (select id from public.costume_orders where order_number = '001'),
        '001', null, 'Allocation: "order 001=8m"', null,
        'Transactions', 96, 'SOURCE: Fabric Registry (Sept 13, 2026) row 53'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0094', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F011-07'),
        'F011-07', 6, '6.0',
        (select id from public.costume_orders where order_number = '001'),
        '001', null, 'Allocation: "order 001=6m"', null,
        'Transactions', 97, 'SOURCE: Fabric Registry (Sept 13, 2026) row 54'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0095', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F011-09'),
        'F011-09', 6, '6.0',
        (select id from public.costume_orders where order_number = '001'),
        '001', null, 'Allocation: "order 001=6m"', null,
        'Transactions', 98, 'SOURCE: Fabric Registry (Sept 13, 2026) row 55'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0096', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F012-02'),
        'F012-02', 75, '75.0',
        (select id from public.costume_orders where order_number = '001'),
        '001', null, 'Allocation: "order 001=75m"', null,
        'Transactions', 99, 'SOURCE: Fabric Registry (Sept 13, 2026) row 57'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0097', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F012-02'),
        'F012-02', 4, '4.0',
        (select id from public.costume_orders where order_number = '002'),
        '002', null, 'Allocation: "order 002=4m"', null,
        'Transactions', 100, 'SOURCE: Fabric Registry (Sept 13, 2026) row 57'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0098', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F012-02'),
        'F012-02', 24, '24.0',
        (select id from public.costume_orders where order_number = '004'),
        '004', null, 'Allocation: "order 004: leo,pant=24m"', null,
        'Transactions', 101, 'SOURCE: Fabric Registry (Sept 13, 2026) row 57'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0099', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F012-02'),
        'F012-02', 4, '4.0',
        (select id from public.costume_orders where order_number = '018'),
        '018', null, 'Allocation: "order 018 SLV flaps=4m"', null,
        'Transactions', 102, 'SOURCE: Fabric Registry (Sept 13, 2026) row 57'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0100', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F012-119'),
        'F012-119', 60, '60.0',
        (select id from public.costume_orders where order_number = '006'),
        '006', null, 'Allocation: "order 006:inserts, cuffs, pant & dress=60m"', null,
        'Transactions', 103, 'SOURCE: Fabric Registry (Sept 13, 2026) row 65'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0101', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F013-01'),
        'F013-01', 30, '30.0',
        (select id from public.costume_orders where order_number = '002'),
        '002', null, 'Allocation: "order 002: leo w/skirt = 30m"', null,
        'Transactions', 104, 'SOURCE: Fabric Registry (Sept 13, 2026) row 66'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0102', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F013-01'),
        'F013-01', 10, '10.0',
        (select id from public.costume_orders where order_number = '034'),
        '034', null, 'Allocation: "order 034: shorts = 10m"', null,
        'Transactions', 105, 'SOURCE: Fabric Registry (Sept 13, 2026) row 66'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0103', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F014-01'),
        'F014-01', 30, '30.0',
        (select id from public.costume_orders where order_number = '015'),
        '015', null, 'Allocation: "order 015: pants=30m"', null,
        'Transactions', 106, 'SOURCE: Fabric Registry (Sept 13, 2026) row 67'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0104', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F015'),
        'F015', 35, '35.0',
        (select id from public.costume_orders where order_number = '007'),
        '007', null, 'Allocation: "order 007: leo FR&BK = 35m"', null,
        'Transactions', 107, 'SOURCE: Fabric Registry (Sept 13, 2026) row 69'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0105', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F017-01'),
        'F017-01', 2, '2.0',
        (select id from public.costume_orders where order_number = '003'),
        '003', null, 'Allocation: "order 003: solo - Dorothy = 2m"', null,
        'Transactions', 108, 'SOURCE: Fabric Registry (Sept 13, 2026) row 71'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0106', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F017-02'),
        'F017-02', 8, '8.0',
        (select id from public.costume_orders where order_number = '008'),
        '008', null, 'Allocation: "order 008: skirts=8m"', null,
        'Transactions', 109, 'SOURCE: Fabric Registry (Sept 13, 2026) row 72'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0107', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F021-09'),
        'F021-09', 3, '3.0',
        (select id from public.costume_orders where order_number = '003'),
        '003', null, 'Allocation: "Orders 003-wizard=3m"', null,
        'Transactions', 110, 'SOURCE: Fabric Registry (Sept 13, 2026) row 79'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0108', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F021-09'),
        'F021-09', 20, '20.0',
        (select id from public.costume_orders where order_number = '020'),
        '020', null, 'Allocation: "Order 020: leo/dress=20m"', null,
        'Transactions', 111, 'SOURCE: Fabric Registry (Sept 13, 2026) row 79'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0109', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F021-12'),
        'F021-12', 3, '3.0',
        (select id from public.costume_orders where order_number = '003'),
        '003', null, 'Allocation: "Order 003-Lion=3m"', null,
        'Transactions', 112, 'SOURCE: Fabric Registry (Sept 13, 2026) row 80'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0110', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F021-12'),
        'F021-12', 3, '3.0',
        (select id from public.costume_orders where order_number = '015'),
        '015', null, 'Allocation: "Order 015-pant cuff=3m"', null,
        'Transactions', 113, 'SOURCE: Fabric Registry (Sept 13, 2026) row 80'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0111', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F021-23'),
        'F021-23', 3, '3.0',
        (select id from public.costume_orders where order_number = '003'),
        '003', null, 'Allocation: "Order 003-scarecrow=3m"', null,
        'Transactions', 114, 'SOURCE: Fabric Registry (Sept 13, 2026) row 81'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0112', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F021-28'),
        'F021-28', 55, '55.0',
        (select id from public.costume_orders where order_number = '003'),
        '003', null, 'Allocation: "Order 003-main leo/pant=55m"', null,
        'Transactions', 115, 'SOURCE: Fabric Registry (Sept 13, 2026) row 82'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0113', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F021-29'),
        'F021-29', 3, '3.0',
        (select id from public.costume_orders where order_number = '003'),
        '003', null, 'Allocation: "Order 003 -tin man=3m"', null,
        'Transactions', 116, 'SOURCE: Fabric Registry (Sept 13, 2026) row 83'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0114', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F023-144'),
        'F023-144', 2, '2.0',
        (select id from public.costume_orders where order_number = '014'),
        '014', null, 'Allocation: "Order 014: 6 belts=2m"', null,
        'Transactions', 117, 'SOURCE: Fabric Registry (Sept 13, 2026) row 88'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0115', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F023-02'),
        'F023-02', 15, '15.0',
        (select id from public.costume_orders where order_number = '001'),
        '001', null, 'Allocation: "Order 001 Bows =15m"', null,
        'Transactions', 118, 'SOURCE: Fabric Registry (Sept 13, 2026) row 89'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0116', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F023-02'),
        'F023-02', 15, '15.0',
        (select id from public.costume_orders where order_number = '040'),
        '040', null, 'Allocation: "order 040: skirts = 15m"', null,
        'Transactions', 119, 'SOURCE: Fabric Registry (Sept 13, 2026) row 89'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0117', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F024-01'),
        'F024-01', 25, '25.0',
        (select id from public.costume_orders where order_number = '009'),
        '009', null, 'Allocation: "order 009 - LS dress=25m"', null,
        'Transactions', 120, 'SOURCE: Fabric Registry (Sept 13, 2026) row 91'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0118', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F025-02'),
        'F025-02', 30, '30.0',
        (select id from public.costume_orders where order_number = '018'),
        '018', null, 'Allocation: "order 018: LS dress = 30m"', null,
        'Transactions', 121, 'SOURCE: Fabric Registry (Sept 13, 2026) row 92'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0119', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F026-11'),
        'F026-11', 26, '26.0',
        (select id from public.costume_orders where order_number = '021'),
        '021', null, 'Allocation: "order 021-dress overlay=26m"', null,
        'Transactions', 122, 'SOURCE: Fabric Registry (Sept 13, 2026) row 94'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0120', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F026-19'),
        'F026-19', 15, '15.0',
        (select id from public.costume_orders where order_number = '035'),
        '035', null, 'Allocation: "order 035: skirt = 15m"', null,
        'Transactions', 123, 'SOURCE: Fabric Registry (Sept 13, 2026) row 95'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0121', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F026-25'),
        'F026-25', 12, '12.0',
        (select id from public.costume_orders where order_number = '025'),
        '025', null, 'Allocation: "order 025 skirts=12m"', null,
        'Transactions', 124, 'SOURCE: Fabric Registry (Sept 13, 2026) row 96'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0122', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F026-27'),
        'F026-27', 12, '12.0',
        (select id from public.costume_orders where order_number = '025'),
        '025', null, 'Allocation: "order 025 skirts=12m"', null,
        'Transactions', 125, 'SOURCE: Fabric Registry (Sept 13, 2026) row 97'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0123', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F027-07'),
        'F027-07', 11, '11.0',
        (select id from public.costume_orders where order_number = '040'),
        '040', null, 'Allocation: "order 040 tank/vest=11m"', null,
        'Transactions', 126, 'SOURCE: Fabric Registry (Sept 13, 2026) row 98'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0124', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F027-17'),
        'F027-17', 8, '8.0',
        (select id from public.costume_orders where order_number = '022'),
        '022', null, 'Allocation: "order 22 middle panel=8m"', null,
        'Transactions', 127, 'SOURCE: Fabric Registry (Sept 13, 2026) row 99'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0125', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F027-17'),
        'F027-17', 8, '8.0',
        (select id from public.costume_orders where order_number = '012'),
        '012', null, 'Allocation: "order 12=8m"', null,
        'Transactions', 128, 'SOURCE: Fabric Registry (Sept 13, 2026) row 99'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0126', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F028-04'),
        'F028-04', 4, '4.0',
        (select id from public.costume_orders where order_number = '031'),
        '031', null, 'Allocation: "order 031 for belts=4m"', null,
        'Transactions', 129, 'SOURCE: Fabric Registry (Sept 13, 2026) row 100'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0127', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F029-01'),
        'F029-01', 20, '20.0',
        (select id from public.costume_orders where order_number = '029'),
        '029', null, 'Allocation: "order 029 - pant & cowl=20m"', null,
        'Transactions', 130, 'SOURCE: Fabric Registry (Sept 13, 2026) row 101'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0128', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F035'),
        'F035', 12, '12.0',
        (select id from public.costume_orders where order_number = '011'),
        '011', null, 'Allocation: "order 011: skirts= 12m"', null,
        'Transactions', 131, 'SOURCE: Fabric Registry (Sept 13, 2026) row 108'
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
        source_label = excluded.source_label;

insert into public.stock_transactions (
        txn_code, occurred_on, occurred_on_raw, txn_type, material_id, material_code_raw,
        qty_m, qty_raw, order_id, order_number_raw, po_ref, description, entered_by,
        source_tab, source_row, source_label
      ) values (
        'T0129', '2026-09-13', '2026-09-13 00:00:00', 'reserve',
        (select id from public.materials where material_code = 'F036'),
        'F036', 15, '15.0',
        (select id from public.costume_orders where order_number = '014'),
        '014', null, 'Allocation: "order 14 - unitard=15m"', null,
        'Transactions', 132, 'SOURCE: Fabric Registry (Sept 13, 2026) row 109'
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
        source_label = excluded.source_label;
