-- 04_styles_part04.sql
-- Idempotent import from the 2026-10-30 tracker export.
-- Run after the inventory migration. Safe to run again.

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '015|P4-C-F014-01-26|Girls', 'P4-C-F014-01-26',
        (select id from public.costume_orders where order_number = '015'),
        '015', 'Wang Dang', 'Wide Leg Pant w/ wide cuff', 'Girls',
        'Female', 'Girls', 'C', null,
        'F014-01',
        (select id from public.materials where material_code = 'F014-01'),
        'Yes', null, null,
        'Styles', 64, 'SOURCE: Product Development Tracking row 94'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'Yes MC', null,
          null, '1', true,
          'Styles', 64
        from public.styles where style_key = '015|P4-C-F014-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '8?', null,
          null, '0', false,
          'Styles', 64
        from public.styles where style_key = '015|P4-C-F014-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '8?', null,
          null, '0', false,
          'Styles', 64
        from public.styles where style_key = '015|P4-C-F014-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, '2026-08-20 00:00:00', '2026-08-20',
          null, '1', true,
          'Styles', 64
        from public.styles where style_key = '015|P4-C-F014-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, '9?', null,
          null, '0', false,
          'Styles', 64
        from public.styles where style_key = '015|P4-C-F014-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, '9?', null,
          null, '0', false,
          'Styles', 64
        from public.styles where style_key = '015|P4-C-F014-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, 'N/A handcut', null,
          null, '1', true,
          'Styles', 64
        from public.styles where style_key = '015|P4-C-F014-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 64
        from public.styles where style_key = '015|P4-C-F014-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 64
        from public.styles where style_key = '015|P4-C-F014-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, 'Partially cut', null,
          null, '1', true,
          'Styles', 64
        from public.styles where style_key = '015|P4-C-F014-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 64
        from public.styles where style_key = '015|P4-C-F014-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '015|P4-A-F014-01-26|Women', 'P4-A-F014-01-26',
        (select id from public.costume_orders where order_number = '015'),
        '015', 'Wang Dang', 'Wide Leg Pant w/ wide cuff', 'Women',
        'Female', 'Girls', 'A', null,
        'F014-01',
        (select id from public.materials where material_code = 'F014-01'),
        'Yes', null, null,
        'Styles', 65, 'SOURCE: Product Development Tracking row 95'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'Yes MA', null,
          null, '1', true,
          'Styles', 65
        from public.styles where style_key = '015|P4-A-F014-01-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '8/10/2026', null,
          null, '1', true,
          'Styles', 65
        from public.styles where style_key = '015|P4-A-F014-01-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '2026-08-20 00:00:00', '2026-08-20',
          null, '1', true,
          'Styles', 65
        from public.styles where style_key = '015|P4-A-F014-01-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, '2026-08-20 00:00:00', '2026-08-20',
          null, '1', true,
          'Styles', 65
        from public.styles where style_key = '015|P4-A-F014-01-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, '2026-09-02 00:00:00', '2026-09-02',
          null, '1', true,
          'Styles', 65
        from public.styles where style_key = '015|P4-A-F014-01-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, '2026-09-04 00:00:00', '2026-09-04',
          null, '1', true,
          'Styles', 65
        from public.styles where style_key = '015|P4-A-F014-01-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, 'N/A handcut', null,
          null, '1', true,
          'Styles', 65
        from public.styles where style_key = '015|P4-A-F014-01-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 65
        from public.styles where style_key = '015|P4-A-F014-01-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 65
        from public.styles where style_key = '015|P4-A-F014-01-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, 'Partially cut', null,
          null, '1', true,
          'Styles', 65
        from public.styles where style_key = '015|P4-A-F014-01-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 65
        from public.styles where style_key = '015|P4-A-F014-01-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '016|D4-A-F001-02-26|Women''s', 'D4-A-F001-02-26',
        (select id from public.costume_orders where order_number = '016'),
        '016', 'I Thought I Was Different', 'Mockneck L/S Keyhole Dress', 'Women''s',
        'Female', 'Girls', 'A', null,
        'F001-02',
        (select id from public.materials where material_code = 'F001-02'),
        'Yes', null, null,
        'Styles', 66, 'SOURCE: Product Development Tracking row 98'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, '2026-09-16 00:00:00', '2026-09-16',
          null, '1', true,
          'Styles', 66
        from public.styles where style_key = '016|D4-A-F001-02-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, null, null,
          null, '0', false,
          'Styles', 66
        from public.styles where style_key = '016|D4-A-F001-02-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, null, null,
          null, '0', false,
          'Styles', 66
        from public.styles where style_key = '016|D4-A-F001-02-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, null, null,
          null, '0', false,
          'Styles', 66
        from public.styles where style_key = '016|D4-A-F001-02-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 66
        from public.styles where style_key = '016|D4-A-F001-02-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, null, null,
          null, '0', false,
          'Styles', 66
        from public.styles where style_key = '016|D4-A-F001-02-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 66
        from public.styles where style_key = '016|D4-A-F001-02-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 66
        from public.styles where style_key = '016|D4-A-F001-02-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 66
        from public.styles where style_key = '016|D4-A-F001-02-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 66
        from public.styles where style_key = '016|D4-A-F001-02-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 66
        from public.styles where style_key = '016|D4-A-F001-02-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '016|D4-C-F001-02-26|Girls', 'D4-C-F001-02-26',
        (select id from public.costume_orders where order_number = '016'),
        '016', 'I Thought I Was Different', 'Mockneck L/S Keyhole Dress', 'Girls',
        'Female', 'Girls', 'C', null,
        'F001-02',
        (select id from public.materials where material_code = 'F001-02'),
        'Yes', null, null,
        'Styles', 67, 'SOURCE: Product Development Tracking row 99'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, '2026-09-16 00:00:00', '2026-09-16',
          null, '1', true,
          'Styles', 67
        from public.styles where style_key = '016|D4-C-F001-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, null, null,
          null, '0', false,
          'Styles', 67
        from public.styles where style_key = '016|D4-C-F001-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, null, null,
          null, '0', false,
          'Styles', 67
        from public.styles where style_key = '016|D4-C-F001-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, null, null,
          null, '0', false,
          'Styles', 67
        from public.styles where style_key = '016|D4-C-F001-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 67
        from public.styles where style_key = '016|D4-C-F001-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'N/A one size only', null,
          null, '1', true,
          'Styles', 67
        from public.styles where style_key = '016|D4-C-F001-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 67
        from public.styles where style_key = '016|D4-C-F001-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 67
        from public.styles where style_key = '016|D4-C-F001-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 67
        from public.styles where style_key = '016|D4-C-F001-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 67
        from public.styles where style_key = '016|D4-C-F001-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 67
        from public.styles where style_key = '016|D4-C-F001-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '017|P10-A-F003-08-26|Women''s', 'P10-A-F003-08-26',
        (select id from public.costume_orders where order_number = '017'),
        '017', 'Valerie', 'HW SL Pant', 'Women''s',
        'Female', 'Girls', 'A', null,
        'F003-08',
        (select id from public.materials where material_code = 'F003-08'),
        'Yes', null, null,
        'Styles', 68, 'SOURCE: Product Development Tracking row 105'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, '2026-09-28 00:00:00', '2026-09-28',
          null, '1', true,
          'Styles', 68
        from public.styles where style_key = '017|P10-A-F003-08-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '2026-09-28 00:00:00', '2026-09-28',
          null, '1', true,
          'Styles', 68
        from public.styles where style_key = '017|P10-A-F003-08-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '2026-09-29 00:00:00', '2026-09-29',
          null, '1', true,
          'Styles', 68
        from public.styles where style_key = '017|P10-A-F003-08-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, 'N/A', null,
          null, '1', true,
          'Styles', 68
        from public.styles where style_key = '017|P10-A-F003-08-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, '2026-09-29 00:00:00', '2026-09-29',
          null, '1', true,
          'Styles', 68
        from public.styles where style_key = '017|P10-A-F003-08-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'already graded', null,
          null, '1', true,
          'Styles', 68
        from public.styles where style_key = '017|P10-A-F003-08-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 68
        from public.styles where style_key = '017|P10-A-F003-08-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 68
        from public.styles where style_key = '017|P10-A-F003-08-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 68
        from public.styles where style_key = '017|P10-A-F003-08-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, 'already completed', null,
          null, '1', true,
          'Styles', 68
        from public.styles where style_key = '017|P10-A-F003-08-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 68
        from public.styles where style_key = '017|P10-A-F003-08-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '017|P10-C-F002-08-26|Girls', 'P10-C-F002-08-26',
        (select id from public.costume_orders where order_number = '017'),
        '017', 'Valerie', 'HW SL Pant', 'Girls',
        'Female', 'Girls', 'C', null,
        'F002-08',
        (select id from public.materials where material_code = 'F002-08'),
        'NOT FOUND', null, null,
        'Styles', 69, 'SOURCE: Product Development Tracking row 106'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, '2026-09-28 00:00:00', '2026-09-28',
          null, '1', true,
          'Styles', 69
        from public.styles where style_key = '017|P10-C-F002-08-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '2026-09-28 00:00:00', '2026-09-28',
          null, '1', true,
          'Styles', 69
        from public.styles where style_key = '017|P10-C-F002-08-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '2026-09-29 00:00:00', '2026-09-29',
          null, '1', true,
          'Styles', 69
        from public.styles where style_key = '017|P10-C-F002-08-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, 'N/A', null,
          null, '1', true,
          'Styles', 69
        from public.styles where style_key = '017|P10-C-F002-08-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, '2026-09-29 00:00:00', '2026-09-29',
          null, '1', true,
          'Styles', 69
        from public.styles where style_key = '017|P10-C-F002-08-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'already graded', null,
          null, '1', true,
          'Styles', 69
        from public.styles where style_key = '017|P10-C-F002-08-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 69
        from public.styles where style_key = '017|P10-C-F002-08-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 69
        from public.styles where style_key = '017|P10-C-F002-08-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 69
        from public.styles where style_key = '017|P10-C-F002-08-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, 'already completed', null,
          null, '1', true,
          'Styles', 69
        from public.styles where style_key = '017|P10-C-F002-08-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 69
        from public.styles where style_key = '017|P10-C-F002-08-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '017|P12-A-F002-08-26|Men''s', 'P12-A-F002-08-26',
        (select id from public.costume_orders where order_number = '017'),
        '017', 'Valerie', 'HW SL Pant', 'Men''s',
        'Male', 'Boys', 'A', null,
        'F002-08',
        (select id from public.materials where material_code = 'F002-08'),
        'NOT FOUND', null, null,
        'Styles', 70, 'SOURCE: Product Development Tracking row 107'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, '2026-09-28 00:00:00', '2026-09-28',
          null, '1', true,
          'Styles', 70
        from public.styles where style_key = '017|P12-A-F002-08-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '2026-09-28 00:00:00', '2026-09-28',
          null, '1', true,
          'Styles', 70
        from public.styles where style_key = '017|P12-A-F002-08-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '2026-09-30 00:00:00', '2026-09-30',
          null, '1', true,
          'Styles', 70
        from public.styles where style_key = '017|P12-A-F002-08-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, 'N/A', null,
          null, '1', true,
          'Styles', 70
        from public.styles where style_key = '017|P12-A-F002-08-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, '2026-09-30 00:00:00', '2026-09-30',
          null, '1', true,
          'Styles', 70
        from public.styles where style_key = '017|P12-A-F002-08-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'already graded', null,
          null, '1', true,
          'Styles', 70
        from public.styles where style_key = '017|P12-A-F002-08-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 70
        from public.styles where style_key = '017|P12-A-F002-08-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 70
        from public.styles where style_key = '017|P12-A-F002-08-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 70
        from public.styles where style_key = '017|P12-A-F002-08-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, 'already completed', null,
          null, '1', true,
          'Styles', 70
        from public.styles where style_key = '017|P12-A-F002-08-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 70
        from public.styles where style_key = '017|P12-A-F002-08-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '018|D2-A-F025-02-26|Women & Boys', 'D2-A-F025-02-26',
        (select id from public.costume_orders where order_number = '018'),
        '018', 'Here I Am', 'A-Line L/S Dress Crewneck w/ Slits', 'Women & Boys',
        null, null, 'A', null,
        'F025-02',
        (select id from public.materials where material_code = 'F025-02'),
        'Yes', null, null,
        'Styles', 71, 'SOURCE: Product Development Tracking row 110'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'SA 9/2/26', null,
          null, '1', true,
          'Styles', 71
        from public.styles where style_key = '018|D2-A-F025-02-26|Women & Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '?', null,
          null, '0', false,
          'Styles', 71
        from public.styles where style_key = '018|D2-A-F025-02-26|Women & Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '2026-10-02 00:00:00', '2026-10-02',
          null, '1', true,
          'Styles', 71
        from public.styles where style_key = '018|D2-A-F025-02-26|Women & Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, '2026-10-05 00:00:00', '2026-10-05',
          null, '1', true,
          'Styles', 71
        from public.styles where style_key = '018|D2-A-F025-02-26|Women & Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 71
        from public.styles where style_key = '018|D2-A-F025-02-26|Women & Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, null, null,
          null, '0', false,
          'Styles', 71
        from public.styles where style_key = '018|D2-A-F025-02-26|Women & Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 71
        from public.styles where style_key = '018|D2-A-F025-02-26|Women & Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 71
        from public.styles where style_key = '018|D2-A-F025-02-26|Women & Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 71
        from public.styles where style_key = '018|D2-A-F025-02-26|Women & Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 71
        from public.styles where style_key = '018|D2-A-F025-02-26|Women & Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 71
        from public.styles where style_key = '018|D2-A-F025-02-26|Women & Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '018|P11-A-F001-02-26|Women', 'P11-A-F001-02-26',
        (select id from public.costume_orders where order_number = '018'),
        '018', 'Here I Am', 'Fitted HW Ankle Pant', 'Women',
        'Female', 'Girls', 'A', null,
        'F001-02',
        (select id from public.materials where material_code = 'F001-02'),
        'Yes', null, null,
        'Styles', 72, 'SOURCE: Product Development Tracking row 111'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'SA 9/2/26', null,
          null, '1', true,
          'Styles', 72
        from public.styles where style_key = '018|P11-A-F001-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '2026-09-10 00:00:00', '2026-09-10',
          null, '1', true,
          'Styles', 72
        from public.styles where style_key = '018|P11-A-F001-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '2026-09-10 00:00:00', '2026-09-10',
          null, '1', true,
          'Styles', 72
        from public.styles where style_key = '018|P11-A-F001-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, 'N/A', null,
          null, '1', true,
          'Styles', 72
        from public.styles where style_key = '018|P11-A-F001-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, '2026-10-02 00:00:00', '2026-10-02',
          null, '1', true,
          'Styles', 72
        from public.styles where style_key = '018|P11-A-F001-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, null, null,
          null, '0', false,
          'Styles', 72
        from public.styles where style_key = '018|P11-A-F001-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 72
        from public.styles where style_key = '018|P11-A-F001-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 72
        from public.styles where style_key = '018|P11-A-F001-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 72
        from public.styles where style_key = '018|P11-A-F001-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 72
        from public.styles where style_key = '018|P11-A-F001-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 72
        from public.styles where style_key = '018|P11-A-F001-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '018|P12-A-F001-02-26|Mens', 'P12-A-F001-02-26',
        (select id from public.costume_orders where order_number = '018'),
        '018', 'Here I Am', 'HW SL Pant', 'Mens',
        'Male', 'Boys', 'A', null,
        'F001-02',
        (select id from public.materials where material_code = 'F001-02'),
        'Yes', null, null,
        'Styles', 73, 'SOURCE: Product Development Tracking row 112'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'Make in PAD', null,
          null, '1', true,
          'Styles', 73
        from public.styles where style_key = '018|P12-A-F001-02-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, 'N/A', null,
          null, '1', true,
          'Styles', 73
        from public.styles where style_key = '018|P12-A-F001-02-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, 'N/A', null,
          null, '1', true,
          'Styles', 73
        from public.styles where style_key = '018|P12-A-F001-02-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, 'N/A', null,
          null, '1', true,
          'Styles', 73
        from public.styles where style_key = '018|P12-A-F001-02-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 73
        from public.styles where style_key = '018|P12-A-F001-02-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'already graded', null,
          null, '1', true,
          'Styles', 73
        from public.styles where style_key = '018|P12-A-F001-02-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 73
        from public.styles where style_key = '018|P12-A-F001-02-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 73
        from public.styles where style_key = '018|P12-A-F001-02-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 73
        from public.styles where style_key = '018|P12-A-F001-02-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 73
        from public.styles where style_key = '018|P12-A-F001-02-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 73
        from public.styles where style_key = '018|P12-A-F001-02-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '019|T1-A-F003-03-26|Men & Women', 'T1-A-F003-03-26',
        (select id from public.costume_orders where order_number = '019'),
        '019', 'Mr. Cellophane', 'Boxy Hip length Vest', 'Men & Women',
        null, null, 'A', null,
        'F003-03',
        (select id from public.materials where material_code = 'F003-03'),
        'Yes', null, null,
        'Styles', 74, 'SOURCE: Product Development Tracking row 113'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'SA 9/9/26', null,
          null, '1', true,
          'Styles', 74
        from public.styles where style_key = '019|T1-A-F003-03-26|Men & Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, null, null,
          null, '0', false,
          'Styles', 74
        from public.styles where style_key = '019|T1-A-F003-03-26|Men & Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, null, null,
          null, '0', false,
          'Styles', 74
        from public.styles where style_key = '019|T1-A-F003-03-26|Men & Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, null, null,
          null, '0', false,
          'Styles', 74
        from public.styles where style_key = '019|T1-A-F003-03-26|Men & Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 74
        from public.styles where style_key = '019|T1-A-F003-03-26|Men & Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, null, null,
          null, '0', false,
          'Styles', 74
        from public.styles where style_key = '019|T1-A-F003-03-26|Men & Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 74
        from public.styles where style_key = '019|T1-A-F003-03-26|Men & Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 74
        from public.styles where style_key = '019|T1-A-F003-03-26|Men & Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'waiting on buttons', null,
          null, '0', false,
          'Styles', 74
        from public.styles where style_key = '019|T1-A-F003-03-26|Men & Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 74
        from public.styles where style_key = '019|T1-A-F003-03-26|Men & Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 74
        from public.styles where style_key = '019|T1-A-F003-03-26|Men & Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '019|SH1-A-F003-03-26|Women', 'SH1-A-F003-03-26',
        (select id from public.costume_orders where order_number = '019'),
        '019', 'Mr. Cellophane', 'HW Wide Knee Short', 'Women',
        'Female', 'Girls', 'A', null,
        'F003-03',
        (select id from public.materials where material_code = 'F003-03'),
        'Yes', null, null,
        'Styles', 75, 'SOURCE: Product Development Tracking row 114'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'SA 9/9/26', null,
          null, '1', true,
          'Styles', 75
        from public.styles where style_key = '019|SH1-A-F003-03-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, null, null,
          null, '0', false,
          'Styles', 75
        from public.styles where style_key = '019|SH1-A-F003-03-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, null, null,
          null, '0', false,
          'Styles', 75
        from public.styles where style_key = '019|SH1-A-F003-03-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, null, null,
          null, '0', false,
          'Styles', 75
        from public.styles where style_key = '019|SH1-A-F003-03-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 75
        from public.styles where style_key = '019|SH1-A-F003-03-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, null, null,
          null, '0', false,
          'Styles', 75
        from public.styles where style_key = '019|SH1-A-F003-03-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 75
        from public.styles where style_key = '019|SH1-A-F003-03-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 75
        from public.styles where style_key = '019|SH1-A-F003-03-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, null, null,
          null, '0', false,
          'Styles', 75
        from public.styles where style_key = '019|SH1-A-F003-03-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 75
        from public.styles where style_key = '019|SH1-A-F003-03-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 75
        from public.styles where style_key = '019|SH1-A-F003-03-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '019|SH2-A-F003-03-26|Men', 'SH2-A-F003-03-26',
        (select id from public.costume_orders where order_number = '019'),
        '019', 'Mr. Cellophane', 'HW Wide Knee Short', 'Men',
        'Male', 'Boys', 'A', null,
        'F003-03',
        (select id from public.materials where material_code = 'F003-03'),
        'Yes', null, null,
        'Styles', 76, 'SOURCE: Product Development Tracking row 115'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'SA 9/9/26', null,
          null, '1', true,
          'Styles', 76
        from public.styles where style_key = '019|SH2-A-F003-03-26|Men'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, null, null,
          null, '0', false,
          'Styles', 76
        from public.styles where style_key = '019|SH2-A-F003-03-26|Men'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, null, null,
          null, '0', false,
          'Styles', 76
        from public.styles where style_key = '019|SH2-A-F003-03-26|Men'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, null, null,
          null, '0', false,
          'Styles', 76
        from public.styles where style_key = '019|SH2-A-F003-03-26|Men'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 76
        from public.styles where style_key = '019|SH2-A-F003-03-26|Men'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'N/A one size only', null,
          null, '1', true,
          'Styles', 76
        from public.styles where style_key = '019|SH2-A-F003-03-26|Men'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 76
        from public.styles where style_key = '019|SH2-A-F003-03-26|Men'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 76
        from public.styles where style_key = '019|SH2-A-F003-03-26|Men'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, null, null,
          null, '0', false,
          'Styles', 76
        from public.styles where style_key = '019|SH2-A-F003-03-26|Men'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 76
        from public.styles where style_key = '019|SH2-A-F003-03-26|Men'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 76
        from public.styles where style_key = '019|SH2-A-F003-03-26|Men'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '020|D5-A-F021-09-26|Women', 'D5-A-F021-09-26',
        (select id from public.costume_orders where order_number = '020'),
        '020', 'Out Of Body', '1-Sleeve Asymmetrical Dress w/ Back Keyhole', 'Women',
        'Female', 'Girls', 'A', null,
        'F021-09',
        (select id from public.materials where material_code = 'F021-09'),
        'Yes', null, null,
        'Styles', 77, 'SOURCE: Product Development Tracking row 116'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'SA 9/22/26', null,
          null, '1', true,
          'Styles', 77
        from public.styles where style_key = '020|D5-A-F021-09-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, null, null,
          null, '0', false,
          'Styles', 77
        from public.styles where style_key = '020|D5-A-F021-09-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, null, null,
          null, '0', false,
          'Styles', 77
        from public.styles where style_key = '020|D5-A-F021-09-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, null, null,
          null, '0', false,
          'Styles', 77
        from public.styles where style_key = '020|D5-A-F021-09-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 77
        from public.styles where style_key = '020|D5-A-F021-09-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, null, null,
          null, '0', false,
          'Styles', 77
        from public.styles where style_key = '020|D5-A-F021-09-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 77
        from public.styles where style_key = '020|D5-A-F021-09-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 77
        from public.styles where style_key = '020|D5-A-F021-09-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 77
        from public.styles where style_key = '020|D5-A-F021-09-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 77
        from public.styles where style_key = '020|D5-A-F021-09-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 77
        from public.styles where style_key = '020|D5-A-F021-09-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '020|P15-A-F009-02-26|Women', 'P15-A-F009-02-26',
        (select id from public.costume_orders where order_number = '020'),
        '020', 'Out Of Body', 'Fitted Lace HW Flare Pant w/ WB', 'Women',
        'Female', 'Girls', 'A', null,
        'F009-02',
        (select id from public.materials where material_code = 'F009-02'),
        'Yes', null, null,
        'Styles', 78, 'SOURCE: Product Development Tracking row 117'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'SA 9/22/26', null,
          null, '1', true,
          'Styles', 78
        from public.styles where style_key = '020|P15-A-F009-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, null, null,
          null, '0', false,
          'Styles', 78
        from public.styles where style_key = '020|P15-A-F009-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, null, null,
          null, '0', false,
          'Styles', 78
        from public.styles where style_key = '020|P15-A-F009-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, null, null,
          null, '0', false,
          'Styles', 78
        from public.styles where style_key = '020|P15-A-F009-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 78
        from public.styles where style_key = '020|P15-A-F009-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, null, null,
          null, '0', false,
          'Styles', 78
        from public.styles where style_key = '020|P15-A-F009-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 78
        from public.styles where style_key = '020|P15-A-F009-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 78
        from public.styles where style_key = '020|P15-A-F009-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 78
        from public.styles where style_key = '020|P15-A-F009-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 78
        from public.styles where style_key = '020|P15-A-F009-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 78
        from public.styles where style_key = '020|P15-A-F009-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '021|D6-C-F001-11-26|Girls', 'D6-C-F001-11-26',
        (select id from public.costume_orders where order_number = '021'),
        '021', 'Open Hands', 'Flutter Slv V Dress w/ Attached Leo', 'Girls',
        'Female', 'Girls', 'C', null,
        'F001-11',
        (select id from public.materials where material_code = 'F001-11'),
        'Yes', null, null,
        'Styles', 79, 'SOURCE: Product Development Tracking row 121'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'MC 9/24/26', null,
          null, '1', true,
          'Styles', 79
        from public.styles where style_key = '021|D6-C-F001-11-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, null, null,
          null, '0', false,
          'Styles', 79
        from public.styles where style_key = '021|D6-C-F001-11-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, null, null,
          null, '0', false,
          'Styles', 79
        from public.styles where style_key = '021|D6-C-F001-11-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, null, null,
          null, '0', false,
          'Styles', 79
        from public.styles where style_key = '021|D6-C-F001-11-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 79
        from public.styles where style_key = '021|D6-C-F001-11-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, null, null,
          null, '0', false,
          'Styles', 79
        from public.styles where style_key = '021|D6-C-F001-11-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 79
        from public.styles where style_key = '021|D6-C-F001-11-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 79
        from public.styles where style_key = '021|D6-C-F001-11-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 79
        from public.styles where style_key = '021|D6-C-F001-11-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 79
        from public.styles where style_key = '021|D6-C-F001-11-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 79
        from public.styles where style_key = '021|D6-C-F001-11-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '022|D3-A-F002-02-26|Women', 'D3-A-F002-02-26',
        (select id from public.costume_orders where order_number = '022'),
        '022', 'Rhythm of the Night', 'Asymm Hem Contrast Panel & Straps Dress', 'Women',
        'Female', 'Girls', 'A', null,
        'F002-02',
        (select id from public.materials where material_code = 'F002-02'),
        'Yes', null, null,
        'Styles', 80, 'SOURCE: Product Development Tracking row 124'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'MA 9/10/26', null,
          null, '1', true,
          'Styles', 80
        from public.styles where style_key = '022|D3-A-F002-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '?', null,
          null, '0', false,
          'Styles', 80
        from public.styles where style_key = '022|D3-A-F002-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '2026-10-02 00:00:00', '2026-10-02',
          null, '1', true,
          'Styles', 80
        from public.styles where style_key = '022|D3-A-F002-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, '2026-10-05 00:00:00', '2026-10-05',
          null, '1', true,
          'Styles', 80
        from public.styles where style_key = '022|D3-A-F002-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 80
        from public.styles where style_key = '022|D3-A-F002-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, null, null,
          null, '0', false,
          'Styles', 80
        from public.styles where style_key = '022|D3-A-F002-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 80
        from public.styles where style_key = '022|D3-A-F002-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 80
        from public.styles where style_key = '022|D3-A-F002-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 80
        from public.styles where style_key = '022|D3-A-F002-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 80
        from public.styles where style_key = '022|D3-A-F002-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 80
        from public.styles where style_key = '022|D3-A-F002-02-26|Women'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '022|D3-C-F002-02-26|Girls', 'D3-C-F002-02-26',
        (select id from public.costume_orders where order_number = '022'),
        '022', 'Rhythm of the Night', 'Asymm Hem Contrast Panel & Straps Dress', 'Girls',
        'Female', 'Girls', 'C', null,
        'F002-02',
        (select id from public.materials where material_code = 'F002-02'),
        'Yes', null, null,
        'Styles', 81, 'SOURCE: Product Development Tracking row 125'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'MC 9/10/26', null,
          null, '1', true,
          'Styles', 81
        from public.styles where style_key = '022|D3-C-F002-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '?', null,
          null, '0', false,
          'Styles', 81
        from public.styles where style_key = '022|D3-C-F002-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '2026-10-02 00:00:00', '2026-10-02',
          null, '1', true,
          'Styles', 81
        from public.styles where style_key = '022|D3-C-F002-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, '2026-10-05 00:00:00', '2026-10-05',
          null, '1', true,
          'Styles', 81
        from public.styles where style_key = '022|D3-C-F002-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 81
        from public.styles where style_key = '022|D3-C-F002-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, null, null,
          null, '0', false,
          'Styles', 81
        from public.styles where style_key = '022|D3-C-F002-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 81
        from public.styles where style_key = '022|D3-C-F002-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 81
        from public.styles where style_key = '022|D3-C-F002-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 81
        from public.styles where style_key = '022|D3-C-F002-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, null, null,
          null, '0', false,
          'Styles', 81
        from public.styles where style_key = '022|D3-C-F002-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 81
        from public.styles where style_key = '022|D3-C-F002-02-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '023|P10-A-F003-02|Womens', 'P10-A-F003-02',
        (select id from public.costume_orders where order_number = '023'),
        '023', 'Night Changes', 'HW SL Pant', 'Womens',
        'Female', 'Girls', 'A', null,
        'F003-02',
        (select id from public.materials where material_code = 'F003-02'),
        'Yes', null, 'Style # does not follow the full convention',
        'Styles', 82, 'SOURCE: Product Development Tracking row 129'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'already in PAD', null,
          null, '1', true,
          'Styles', 82
        from public.styles where style_key = '023|P10-A-F003-02|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, null, null,
          null, '0', false,
          'Styles', 82
        from public.styles where style_key = '023|P10-A-F003-02|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, 'N/A', null,
          null, '1', true,
          'Styles', 82
        from public.styles where style_key = '023|P10-A-F003-02|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, 'N/A', null,
          null, '1', true,
          'Styles', 82
        from public.styles where style_key = '023|P10-A-F003-02|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 82
        from public.styles where style_key = '023|P10-A-F003-02|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'already graded', null,
          null, '1', true,
          'Styles', 82
        from public.styles where style_key = '023|P10-A-F003-02|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 82
        from public.styles where style_key = '023|P10-A-F003-02|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 82
        from public.styles where style_key = '023|P10-A-F003-02|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 82
        from public.styles where style_key = '023|P10-A-F003-02|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, 'waiting on sizes', null,
          null, '0', false,
          'Styles', 82
        from public.styles where style_key = '023|P10-A-F003-02|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 82
        from public.styles where style_key = '023|P10-A-F003-02|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '023|P11-C-F003-02|Boys', 'P11-C-F003-02',
        (select id from public.costume_orders where order_number = '023'),
        '023', 'Night Changes', 'HW SL Pant', 'Boys',
        'Male', 'Boys', 'C', null,
        'F003-02',
        (select id from public.materials where material_code = 'F003-02'),
        'Yes', null, 'Style # does not follow the full convention',
        'Styles', 83, 'SOURCE: Product Development Tracking row 130'
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
        source_label = excluded.source_label;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'already in PAD', null,
          null, '1', true,
          'Styles', 83
        from public.styles where style_key = '023|P11-C-F003-02|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, null, null,
          null, '0', false,
          'Styles', 83
        from public.styles where style_key = '023|P11-C-F003-02|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, 'N/A', null,
          null, '1', true,
          'Styles', 83
        from public.styles where style_key = '023|P11-C-F003-02|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, 'N/A', null,
          null, '1', true,
          'Styles', 83
        from public.styles where style_key = '023|P11-C-F003-02|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, null, null,
          null, '0', false,
          'Styles', 83
        from public.styles where style_key = '023|P11-C-F003-02|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'already graded', null,
          null, '1', true,
          'Styles', 83
        from public.styles where style_key = '023|P11-C-F003-02|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, null, null,
          null, '0', false,
          'Styles', 83
        from public.styles where style_key = '023|P11-C-F003-02|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fabrics in stock', 8, 'Yes', null,
          true, '1', true,
          'Styles', 83
        from public.styles where style_key = '023|P11-C-F003-02|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'Yes', null,
          true, '1', true,
          'Styles', 83
        from public.styles where style_key = '023|P11-C-F003-02|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Cut Ticket Created', 10, 'waiting on sizes', null,
          null, '0', false,
          'Styles', 83
        from public.styles where style_key = '023|P11-C-F003-02|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, null, null,
          null, '0', false,
          'Styles', 83
        from public.styles where style_key = '023|P11-C-F003-02|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;
