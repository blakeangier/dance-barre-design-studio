-- 07_sizes.sql
-- Idempotent import from the 2026-10-30 tracker export.
-- Run after the inventory migration. Safe to run again.

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'MC', 2, '2.0',
          'Sizes', 4
        from public.styles s where s.style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'MC-L', 1, '1.0',
          'Sizes', 4
        from public.styles s where s.style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'LC', 1, '1.0',
          'Sizes', 4
        from public.styles s where s.style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'XSA', 11, '11.0',
          'Sizes', 5
        from public.styles s where s.style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'SA', 29, '29.0',
          'Sizes', 5
        from public.styles s where s.style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'SA-L', 3, '3.0',
          'Sizes', 5
        from public.styles s where s.style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'MA', 6, '6.0',
          'Sizes', 5
        from public.styles s where s.style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'LA', 9, '9.0',
          'Sizes', 5
        from public.styles s where s.style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'XLA', 2, '2.0',
          'Sizes', 5
        from public.styles s where s.style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'LC', 1, '1.0',
          'Sizes', 6
        from public.styles s where s.style_key = '005|L7-C-F001-06-26|Boys'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'SA', 2, '2.0',
          'Sizes', 7
        from public.styles s where s.style_key = '005|L9-A-F001-06-26|Men''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'MA', 1, '1.0',
          'Sizes', 7
        from public.styles s where s.style_key = '005|L9-A-F001-06-26|Men''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'IC', 1, '1.0',
          'Sizes', 8
        from public.styles s where s.style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'MC', 1, '1.0',
          'Sizes', 8
        from public.styles s where s.style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'MC-L', 1, '1.0',
          'Sizes', 8
        from public.styles s where s.style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'LC', 1, '1.0',
          'Sizes', 8
        from public.styles s where s.style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'XSA', 11, '11.0',
          'Sizes', 9
        from public.styles s where s.style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'SA', 29, '29.0',
          'Sizes', 9
        from public.styles s where s.style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'SA-L', 3, '3.0',
          'Sizes', 9
        from public.styles s where s.style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'MA', 7, '7.0',
          'Sizes', 9
        from public.styles s where s.style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'LA', 8, '8.0',
          'Sizes', 9
        from public.styles s where s.style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'XLA', 2, '2.0',
          'Sizes', 9
        from public.styles s where s.style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'LC', 1, '1.0',
          'Sizes', 10
        from public.styles s where s.style_key = '005|P9-C-F001-06-26|Boys'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'SA', 2, '2.0',
          'Sizes', 11
        from public.styles s where s.style_key = '005|P9-A-F001-06-26|Men''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;

insert into public.order_sizes (
          style_id, order_id, size_code, qty, qty_raw, source_tab, source_row
        )
        select s.id, s.order_id, 'MA', 1, '1.0',
          'Sizes', 11
        from public.styles s where s.style_key = '005|P9-A-F001-06-26|Men''s'
        on conflict (style_id, size_code) do update set
          qty = excluded.qty,
          qty_raw = excluded.qty_raw,
          source_row = excluded.source_row;
