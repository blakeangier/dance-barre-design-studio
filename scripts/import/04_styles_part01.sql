-- 04_styles_part01.sql
-- Idempotent import from the 2026-10-30 tracker export.
-- Run after the inventory migration. Safe to run again.

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '001|L1-C-F002-02-26|Girls', 'L1-C-F002-02-26',
        (select id from public.costume_orders where order_number = '001'),
        '001', 'Sing Sing Sing', 'Halter Neck Slvless Leotard', 'Girls',
        'Female', 'Girls', 'C', null,
        'F002-02',
        (select id from public.materials where material_code = 'F002-02'),
        'Yes', null, null,
        'Styles', 4, 'SOURCE: Product Development Tracking row 4'
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
          'Styles', 4
        from public.styles where style_key = '001|L1-C-F002-02-26|Girls'
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
        select id, 'Sample Completed', 2, '2026-08-17 00:00:00', '2026-08-17',
          null, '1', true,
          'Styles', 4
        from public.styles where style_key = '001|L1-C-F002-02-26|Girls'
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
          'Styles', 4
        from public.styles where style_key = '001|L1-C-F002-02-26|Girls'
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
          'Styles', 4
        from public.styles where style_key = '001|L1-C-F002-02-26|Girls'
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
        select id, 'Approved', 5, '2026-08-20 00:00:00', '2026-08-20',
          null, '1', true,
          'Styles', 4
        from public.styles where style_key = '001|L1-C-F002-02-26|Girls'
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
          'Styles', 4
        from public.styles where style_key = '001|L1-C-F002-02-26|Girls'
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
        select id, 'Marker', 7, '2026-09-22 00:00:00', '2026-09-22',
          null, '1', true,
          'Styles', 4
        from public.styles where style_key = '001|L1-C-F002-02-26|Girls'
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
          'Styles', 4
        from public.styles where style_key = '001|L1-C-F002-02-26|Girls'
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
          'Styles', 4
        from public.styles where style_key = '001|L1-C-F002-02-26|Girls'
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
          'Styles', 4
        from public.styles where style_key = '001|L1-C-F002-02-26|Girls'
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
          'Styles', 4
        from public.styles where style_key = '001|L1-C-F002-02-26|Girls'
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
        '001|L1-A-F002-02-26|Women''s', 'L1-A-F002-02-26',
        (select id from public.costume_orders where order_number = '001'),
        '001', 'Sing Sing Sing', 'Halter Neck Slvless Leotard', 'Women''s',
        'Female', 'Girls', 'A', null,
        'F002-02',
        (select id from public.materials where material_code = 'F002-02'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 5, 'SOURCE: Product Development Tracking row 5'
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
          'Styles', 5
        from public.styles where style_key = '001|L1-A-F002-02-26|Women''s'
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
        select id, 'Sample Completed', 2, '2026-08-17 00:00:00', '2026-08-17',
          null, '1', true,
          'Styles', 5
        from public.styles where style_key = '001|L1-A-F002-02-26|Women''s'
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
        select id, 'Fit Test', 3, '2026-08-21 00:00:00', '2026-08-21',
          null, '1', true,
          'Styles', 5
        from public.styles where style_key = '001|L1-A-F002-02-26|Women''s'
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
        select id, 'Corrections', 4, '2026-08-24 00:00:00', '2026-08-24',
          null, '1', true,
          'Styles', 5
        from public.styles where style_key = '001|L1-A-F002-02-26|Women''s'
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
        select id, 'Approved', 5, '2026-08-21 00:00:00', '2026-08-21',
          null, '1', true,
          'Styles', 5
        from public.styles where style_key = '001|L1-A-F002-02-26|Women''s'
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
        select id, 'Grading', 6, '2026-09-02 00:00:00', '2026-09-02',
          null, '1', true,
          'Styles', 5
        from public.styles where style_key = '001|L1-A-F002-02-26|Women''s'
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
        select id, 'Marker', 7, '2026-09-22 00:00:00', '2026-09-22',
          null, '1', true,
          'Styles', 5
        from public.styles where style_key = '001|L1-A-F002-02-26|Women''s'
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
          'Styles', 5
        from public.styles where style_key = '001|L1-A-F002-02-26|Women''s'
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
          'Styles', 5
        from public.styles where style_key = '001|L1-A-F002-02-26|Women''s'
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
        select id, 'Cut Ticket Created', 10, 'already in cutting', null,
          null, '1', true,
          'Styles', 5
        from public.styles where style_key = '001|L1-A-F002-02-26|Women''s'
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
          'Styles', 5
        from public.styles where style_key = '001|L1-A-F002-02-26|Women''s'
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
        '001|L2-C-F001-02-26|Boys', 'L2-C-F001-02-26',
        (select id from public.costume_orders where order_number = '001'),
        '001', 'Sing Sing Sing', 'Sleeveless Collared Leotard', 'Boys',
        'Male', 'Boys', 'C', null,
        'F001-02',
        (select id from public.materials where material_code = 'F001-02'),
        'Yes', null, null,
        'Styles', 6, 'SOURCE: Product Development Tracking row 6'
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
          'Styles', 6
        from public.styles where style_key = '001|L2-C-F001-02-26|Boys'
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
        select id, 'Sample Completed', 2, '2026-08-17 00:00:00', '2026-08-17',
          null, '1', true,
          'Styles', 6
        from public.styles where style_key = '001|L2-C-F001-02-26|Boys'
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
        select id, 'Fit Test', 3, '2026-08-31 00:00:00', '2026-08-31',
          null, '1', true,
          'Styles', 6
        from public.styles where style_key = '001|L2-C-F001-02-26|Boys'
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
        select id, 'Corrections', 4, '2026-09-03 00:00:00', '2026-09-03',
          null, '1', true,
          'Styles', 6
        from public.styles where style_key = '001|L2-C-F001-02-26|Boys'
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
        select id, 'Approved', 5, '2026-09-16 00:00:00', '2026-09-16',
          null, '1', true,
          'Styles', 6
        from public.styles where style_key = '001|L2-C-F001-02-26|Boys'
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
          'Styles', 6
        from public.styles where style_key = '001|L2-C-F001-02-26|Boys'
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
          'Styles', 6
        from public.styles where style_key = '001|L2-C-F001-02-26|Boys'
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
          'Styles', 6
        from public.styles where style_key = '001|L2-C-F001-02-26|Boys'
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
          'Styles', 6
        from public.styles where style_key = '001|L2-C-F001-02-26|Boys'
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
          'Styles', 6
        from public.styles where style_key = '001|L2-C-F001-02-26|Boys'
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
          'Styles', 6
        from public.styles where style_key = '001|L2-C-F001-02-26|Boys'
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
        '001|L2-A-F001-02-26|Men''s', 'L2-A-F001-02-26',
        (select id from public.costume_orders where order_number = '001'),
        '001', 'Sing Sing Sing', 'Sleeveless Collared Leotard', 'Men''s',
        'Male', 'Boys', 'A', null,
        'F001-02',
        (select id from public.materials where material_code = 'F001-02'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 7, 'SOURCE: Product Development Tracking row 7'
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
          'Styles', 7
        from public.styles where style_key = '001|L2-A-F001-02-26|Men''s'
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
        select id, 'Sample Completed', 2, 'P2 10/2/26', null,
          null, '1', true,
          'Styles', 7
        from public.styles where style_key = '001|L2-A-F001-02-26|Men''s'
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
          'Styles', 7
        from public.styles where style_key = '001|L2-A-F001-02-26|Men''s'
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
        select id, 'Corrections', 4, '2026-09-28 00:00:00', '2026-09-28',
          null, '1', true,
          'Styles', 7
        from public.styles where style_key = '001|L2-A-F001-02-26|Men''s'
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
          'Styles', 7
        from public.styles where style_key = '001|L2-A-F001-02-26|Men''s'
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
          'Styles', 7
        from public.styles where style_key = '001|L2-A-F001-02-26|Men''s'
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
          'Styles', 7
        from public.styles where style_key = '001|L2-A-F001-02-26|Men''s'
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
          'Styles', 7
        from public.styles where style_key = '001|L2-A-F001-02-26|Men''s'
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
          'Styles', 7
        from public.styles where style_key = '001|L2-A-F001-02-26|Men''s'
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
          'Styles', 7
        from public.styles where style_key = '001|L2-A-F001-02-26|Men''s'
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
          'Styles', 7
        from public.styles where style_key = '001|L2-A-F001-02-26|Men''s'
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
        '001|A1-C-F011-01-26|All', 'A1-C-F011-01-26',
        (select id from public.costume_orders where order_number = '001'),
        '001', 'Sing Sing Sing', 'Faux Cuffs', 'All',
        null, null, 'C', null,
        'F011-01',
        (select id from public.materials where material_code = 'F011-01'),
        'NOT FOUND', null, null,
        'Styles', 8, 'SOURCE: Product Development Tracking row 8'
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
        select id, 'Pattern Complete', 1, 'Yes', null,
          true, '1', true,
          'Styles', 8
        from public.styles where style_key = '001|A1-C-F011-01-26|All'
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
          'Styles', 8
        from public.styles where style_key = '001|A1-C-F011-01-26|All'
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
        select id, 'Fit Test', 3, '?', null,
          null, '0', false,
          'Styles', 8
        from public.styles where style_key = '001|A1-C-F011-01-26|All'
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
        select id, 'Corrections', 4, '?', null,
          null, '0', false,
          'Styles', 8
        from public.styles where style_key = '001|A1-C-F011-01-26|All'
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
        select id, 'Approved', 5, '?', null,
          null, '0', false,
          'Styles', 8
        from public.styles where style_key = '001|A1-C-F011-01-26|All'
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
        select id, 'Grading', 6, 'N/A', null,
          null, '1', true,
          'Styles', 8
        from public.styles where style_key = '001|A1-C-F011-01-26|All'
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
        select id, 'Marker', 7, '2026-09-15 00:00:00', '2026-09-15',
          null, '1', true,
          'Styles', 8
        from public.styles where style_key = '001|A1-C-F011-01-26|All'
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
          'Styles', 8
        from public.styles where style_key = '001|A1-C-F011-01-26|All'
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
          'Styles', 8
        from public.styles where style_key = '001|A1-C-F011-01-26|All'
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
          'Styles', 8
        from public.styles where style_key = '001|A1-C-F011-01-26|All'
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
          'Styles', 8
        from public.styles where style_key = '001|A1-C-F011-01-26|All'
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
        '001|P1-C-F012-02-26|Girls', 'P1-C-F012-02-26',
        (select id from public.costume_orders where order_number = '001'),
        '001', 'Sing Sing Sing', 'Mesh Pant w/ SS Ribbon Stripe', 'Girls',
        'Female', 'Girls', 'C', null,
        'F012-02',
        (select id from public.materials where material_code = 'F012-02'),
        'Yes', null, null,
        'Styles', 9, 'SOURCE: Product Development Tracking row 9'
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
        select id, 'Pattern Complete', 1, 'Make in PAD MC', null,
          null, '1', true,
          'Styles', 9
        from public.styles where style_key = '001|P1-C-F012-02-26|Girls'
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
        select id, 'Sample Completed', 2, '2026-08-19 00:00:00', '2026-08-19',
          null, '1', true,
          'Styles', 9
        from public.styles where style_key = '001|P1-C-F012-02-26|Girls'
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
        select id, 'Fit Test', 3, '8/20/26 & 9/17/26', null,
          null, '1', true,
          'Styles', 9
        from public.styles where style_key = '001|P1-C-F012-02-26|Girls'
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
        select id, 'Corrections', 4, '2026-09-22 00:00:00', '2026-09-22',
          null, '1', true,
          'Styles', 9
        from public.styles where style_key = '001|P1-C-F012-02-26|Girls'
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
        select id, 'Approved', 5, '2026-10-05 00:00:00', '2026-10-05',
          null, '1', true,
          'Styles', 9
        from public.styles where style_key = '001|P1-C-F012-02-26|Girls'
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
          'Styles', 9
        from public.styles where style_key = '001|P1-C-F012-02-26|Girls'
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
          'Styles', 9
        from public.styles where style_key = '001|P1-C-F012-02-26|Girls'
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
        select id, 'Fabrics in stock', 8, null, null,
          null, '0', false,
          'Styles', 9
        from public.styles where style_key = '001|P1-C-F012-02-26|Girls'
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
          'Styles', 9
        from public.styles where style_key = '001|P1-C-F012-02-26|Girls'
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
        select id, 'Cut Ticket Created', 10, 'already cut', null,
          null, '1', true,
          'Styles', 9
        from public.styles where style_key = '001|P1-C-F012-02-26|Girls'
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
          'Styles', 9
        from public.styles where style_key = '001|P1-C-F012-02-26|Girls'
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
        '001|P1-A-F012-02-26|Women''s', 'P1-A-F012-02-26',
        (select id from public.costume_orders where order_number = '001'),
        '001', 'Sing Sing Sing', 'Mesh Pant w/ SS Ribbon Stripe', 'Women''s',
        'Female', 'Girls', 'A', null,
        'F012-02',
        (select id from public.materials where material_code = 'F012-02'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 10, 'SOURCE: Product Development Tracking row 10'
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
        select id, 'Pattern Complete', 1, 'Make in PAD MA', null,
          null, '1', true,
          'Styles', 10
        from public.styles where style_key = '001|P1-A-F012-02-26|Women''s'
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
        select id, 'Sample Completed', 2, '2026-08-19 00:00:00', '2026-08-19',
          null, '1', true,
          'Styles', 10
        from public.styles where style_key = '001|P1-A-F012-02-26|Women''s'
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
        select id, 'Fit Test', 3, '8/21/26 & 9/10/26 & 9/16/26', null,
          null, '1', true,
          'Styles', 10
        from public.styles where style_key = '001|P1-A-F012-02-26|Women''s'
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
        select id, 'Corrections', 4, '8/28/2026 & 9/14/26', null,
          null, '1', true,
          'Styles', 10
        from public.styles where style_key = '001|P1-A-F012-02-26|Women''s'
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
        select id, 'Approved', 5, '2026-09-17 00:00:00', '2026-09-17',
          null, '1', true,
          'Styles', 10
        from public.styles where style_key = '001|P1-A-F012-02-26|Women''s'
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
        select id, 'Grading', 6, '2026-09-22 00:00:00', '2026-09-22',
          null, '1', true,
          'Styles', 10
        from public.styles where style_key = '001|P1-A-F012-02-26|Women''s'
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
        select id, 'Marker', 7, '2026-09-24 00:00:00', '2026-09-24',
          null, '1', true,
          'Styles', 10
        from public.styles where style_key = '001|P1-A-F012-02-26|Women''s'
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
          'Styles', 10
        from public.styles where style_key = '001|P1-A-F012-02-26|Women''s'
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
          'Styles', 10
        from public.styles where style_key = '001|P1-A-F012-02-26|Women''s'
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
        select id, 'Cut Ticket Created', 10, 'already cut', null,
          null, '1', true,
          'Styles', 10
        from public.styles where style_key = '001|P1-A-F012-02-26|Women''s'
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
          'Styles', 10
        from public.styles where style_key = '001|P1-A-F012-02-26|Women''s'
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
        '001|P2-C-F003-02-26|Boys', 'P2-C-F003-02-26',
        (select id from public.costume_orders where order_number = '001'),
        '001', 'Sing Sing Sing', 'Cotton Scuba Pant w/ SS Stripe', 'Boys',
        'Male', 'Boys', 'C', null,
        'F003-02',
        (select id from public.materials where material_code = 'F003-02'),
        'Yes', null, null,
        'Styles', 11, 'SOURCE: Product Development Tracking row 11'
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
          'Styles', 11
        from public.styles where style_key = '001|P2-C-F003-02-26|Boys'
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
        select id, 'Sample Completed', 2, '2026-10-02 00:00:00', '2026-10-02',
          null, '1', true,
          'Styles', 11
        from public.styles where style_key = '001|P2-C-F003-02-26|Boys'
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
          'Styles', 11
        from public.styles where style_key = '001|P2-C-F003-02-26|Boys'
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
          'Styles', 11
        from public.styles where style_key = '001|P2-C-F003-02-26|Boys'
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
          'Styles', 11
        from public.styles where style_key = '001|P2-C-F003-02-26|Boys'
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
          'Styles', 11
        from public.styles where style_key = '001|P2-C-F003-02-26|Boys'
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
          'Styles', 11
        from public.styles where style_key = '001|P2-C-F003-02-26|Boys'
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
          'Styles', 11
        from public.styles where style_key = '001|P2-C-F003-02-26|Boys'
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
          'Styles', 11
        from public.styles where style_key = '001|P2-C-F003-02-26|Boys'
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
          'Styles', 11
        from public.styles where style_key = '001|P2-C-F003-02-26|Boys'
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
          'Styles', 11
        from public.styles where style_key = '001|P2-C-F003-02-26|Boys'
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
        '001|P2-A-F003-02-26|Men''s', 'P2-A-F003-02-26',
        (select id from public.costume_orders where order_number = '001'),
        '001', 'Sing Sing Sing', 'Cotton Scuba Pant w/ SS Stripe', 'Men''s',
        'Male', 'Boys', 'A', null,
        'F003-02',
        (select id from public.materials where material_code = 'F003-02'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 12, 'SOURCE: Product Development Tracking row 12'
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
        select id, 'Pattern Complete', 1, 'Yes SA', null,
          null, '1', true,
          'Styles', 12
        from public.styles where style_key = '001|P2-A-F003-02-26|Men''s'
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
        select id, 'Sample Completed', 2, '2026-10-26 00:00:00', '2026-10-26',
          null, '1', true,
          'Styles', 12
        from public.styles where style_key = '001|P2-A-F003-02-26|Men''s'
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
          'Styles', 12
        from public.styles where style_key = '001|P2-A-F003-02-26|Men''s'
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
          'Styles', 12
        from public.styles where style_key = '001|P2-A-F003-02-26|Men''s'
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
          'Styles', 12
        from public.styles where style_key = '001|P2-A-F003-02-26|Men''s'
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
          'Styles', 12
        from public.styles where style_key = '001|P2-A-F003-02-26|Men''s'
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
          'Styles', 12
        from public.styles where style_key = '001|P2-A-F003-02-26|Men''s'
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
          'Styles', 12
        from public.styles where style_key = '001|P2-A-F003-02-26|Men''s'
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
          'Styles', 12
        from public.styles where style_key = '001|P2-A-F003-02-26|Men''s'
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
          'Styles', 12
        from public.styles where style_key = '001|P2-A-F003-02-26|Men''s'
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
          'Styles', 12
        from public.styles where style_key = '001|P2-A-F003-02-26|Men''s'
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
        '002|L8-C-F013-01-26|Girls', 'L8-C-F013-01-26',
        (select id from public.costume_orders where order_number = '002'),
        '002', 'Can''t Turn You Loose', 'Tank Leo w/ Flutter Slv & Skirt', 'Girls',
        'Female', 'Girls', 'C', null,
        'F013-01',
        (select id from public.materials where material_code = 'F013-01'),
        'Yes', null, null,
        'Styles', 13, 'SOURCE: Product Development Tracking row 14'
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
          'Styles', 13
        from public.styles where style_key = '002|L8-C-F013-01-26|Girls'
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
        select id, 'Sample Completed', 2, '2026-08-24 00:00:00', '2026-08-24',
          null, '1', true,
          'Styles', 13
        from public.styles where style_key = '002|L8-C-F013-01-26|Girls'
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
        select id, 'Fit Test', 3, '2026-08-31 00:00:00', '2026-08-31',
          null, '1', true,
          'Styles', 13
        from public.styles where style_key = '002|L8-C-F013-01-26|Girls'
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
          'Styles', 13
        from public.styles where style_key = '002|L8-C-F013-01-26|Girls'
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
          'Styles', 13
        from public.styles where style_key = '002|L8-C-F013-01-26|Girls'
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
          'Styles', 13
        from public.styles where style_key = '002|L8-C-F013-01-26|Girls'
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
          'Styles', 13
        from public.styles where style_key = '002|L8-C-F013-01-26|Girls'
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
          'Styles', 13
        from public.styles where style_key = '002|L8-C-F013-01-26|Girls'
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
        select id, 'Notions in stock', 9, 'waiting on binding', null,
          null, '0', false,
          'Styles', 13
        from public.styles where style_key = '002|L8-C-F013-01-26|Girls'
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
          'Styles', 13
        from public.styles where style_key = '002|L8-C-F013-01-26|Girls'
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
          'Styles', 13
        from public.styles where style_key = '002|L8-C-F013-01-26|Girls'
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
        '002|L11-A-F013-01-26|Womens', 'L11-A-F013-01-26',
        (select id from public.costume_orders where order_number = '002'),
        '002', 'Can''t Turn You Loose', 'Tank Leo w/ Flutter Slv & Skirt', 'Womens',
        'Female', 'Girls', 'A', null,
        'F013-01',
        (select id from public.materials where material_code = 'F013-01'),
        'Yes', null, null,
        'Styles', 14, 'SOURCE: Product Development Tracking row 15'
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
        select id, 'Pattern Complete', 1, null, null,
          null, '0', false,
          'Styles', 14
        from public.styles where style_key = '002|L11-A-F013-01-26|Womens'
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
          'Styles', 14
        from public.styles where style_key = '002|L11-A-F013-01-26|Womens'
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
          'Styles', 14
        from public.styles where style_key = '002|L11-A-F013-01-26|Womens'
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
          'Styles', 14
        from public.styles where style_key = '002|L11-A-F013-01-26|Womens'
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
          'Styles', 14
        from public.styles where style_key = '002|L11-A-F013-01-26|Womens'
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
          'Styles', 14
        from public.styles where style_key = '002|L11-A-F013-01-26|Womens'
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
          'Styles', 14
        from public.styles where style_key = '002|L11-A-F013-01-26|Womens'
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
          'Styles', 14
        from public.styles where style_key = '002|L11-A-F013-01-26|Womens'
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
        select id, 'Notions in stock', 9, 'waiting on binding', null,
          null, '0', false,
          'Styles', 14
        from public.styles where style_key = '002|L11-A-F013-01-26|Womens'
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
          'Styles', 14
        from public.styles where style_key = '002|L11-A-F013-01-26|Womens'
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
          'Styles', 14
        from public.styles where style_key = '002|L11-A-F013-01-26|Womens'
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
        '002|L9-C-F013-01-26|Boys', 'L9-C-F013-01-26',
        (select id from public.costume_orders where order_number = '002'),
        '002', 'Can''t Turn You Loose', 'Collared S/S Leotard', 'Boys',
        'Male', 'Boys', 'C', null,
        'F013-01',
        (select id from public.materials where material_code = 'F013-01'),
        'Yes', null, null,
        'Styles', 15, 'SOURCE: Product Development Tracking row 16'
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
          'Styles', 15
        from public.styles where style_key = '002|L9-C-F013-01-26|Boys'
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
        select id, 'Sample Completed', 2, '2026-08-24 00:00:00', '2026-08-24',
          null, '1', true,
          'Styles', 15
        from public.styles where style_key = '002|L9-C-F013-01-26|Boys'
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
        select id, 'Fit Test', 3, '2026-09-02 00:00:00', '2026-09-02',
          null, '1', true,
          'Styles', 15
        from public.styles where style_key = '002|L9-C-F013-01-26|Boys'
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
        select id, 'Corrections', 4, '2026-09-03 00:00:00', '2026-09-03',
          null, '1', true,
          'Styles', 15
        from public.styles where style_key = '002|L9-C-F013-01-26|Boys'
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
          'Styles', 15
        from public.styles where style_key = '002|L9-C-F013-01-26|Boys'
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
          'Styles', 15
        from public.styles where style_key = '002|L9-C-F013-01-26|Boys'
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
          'Styles', 15
        from public.styles where style_key = '002|L9-C-F013-01-26|Boys'
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
          'Styles', 15
        from public.styles where style_key = '002|L9-C-F013-01-26|Boys'
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
        select id, 'Notions in stock', 9, 'waiting on binding', null,
          null, '0', false,
          'Styles', 15
        from public.styles where style_key = '002|L9-C-F013-01-26|Boys'
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
          'Styles', 15
        from public.styles where style_key = '002|L9-C-F013-01-26|Boys'
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
          'Styles', 15
        from public.styles where style_key = '002|L9-C-F013-01-26|Boys'
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
        '002|P7-C-F003-02-26|Boys', 'P7-C-F003-02-26',
        (select id from public.costume_orders where order_number = '002'),
        '002', 'Can''t Turn You Loose', 'Straight Leg Pant w/ Waistband', 'Boys',
        'Male', 'Boys', 'C', null,
        'F003-02',
        (select id from public.materials where material_code = 'F003-02'),
        'Yes', null, null,
        'Styles', 16, 'SOURCE: Product Development Tracking row 17'
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
        select id, 'Pattern Complete', 1, '2026-09-15 00:00:00', '2026-09-15',
          null, '1', true,
          'Styles', 16
        from public.styles where style_key = '002|P7-C-F003-02-26|Boys'
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
          'Styles', 16
        from public.styles where style_key = '002|P7-C-F003-02-26|Boys'
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
          'Styles', 16
        from public.styles where style_key = '002|P7-C-F003-02-26|Boys'
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
          'Styles', 16
        from public.styles where style_key = '002|P7-C-F003-02-26|Boys'
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
          'Styles', 16
        from public.styles where style_key = '002|P7-C-F003-02-26|Boys'
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
          'Styles', 16
        from public.styles where style_key = '002|P7-C-F003-02-26|Boys'
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
          'Styles', 16
        from public.styles where style_key = '002|P7-C-F003-02-26|Boys'
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
          'Styles', 16
        from public.styles where style_key = '002|P7-C-F003-02-26|Boys'
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
        select id, 'Notions in stock', 9, 'N/A', null,
          null, '1', true,
          'Styles', 16
        from public.styles where style_key = '002|P7-C-F003-02-26|Boys'
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
          'Styles', 16
        from public.styles where style_key = '002|P7-C-F003-02-26|Boys'
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
          'Styles', 16
        from public.styles where style_key = '002|P7-C-F003-02-26|Boys'
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
        '003|L5-C-F021-28-26|Girls', 'L5-C-F021-28-26',
        (select id from public.costume_orders where order_number = '003'),
        '003', 'Yellow Brick Road', 'Boatneck L/S Leo', 'Girls',
        'Female', 'Girls', 'C', null,
        'F021-28',
        (select id from public.materials where material_code = 'F021-28'),
        'Yes', null, null,
        'Styles', 17, 'SOURCE: Product Development Tracking row 19'
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
          'Styles', 17
        from public.styles where style_key = '003|L5-C-F021-28-26|Girls'
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
        select id, 'Sample Completed', 2, '2026-08-26 00:00:00', '2026-08-26',
          null, '1', true,
          'Styles', 17
        from public.styles where style_key = '003|L5-C-F021-28-26|Girls'
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
        select id, 'Fit Test', 3, '2026-08-31 00:00:00', '2026-08-31',
          null, '1', true,
          'Styles', 17
        from public.styles where style_key = '003|L5-C-F021-28-26|Girls'
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
        select id, 'Corrections', 4, '2026-08-31 00:00:00', '2026-08-31',
          null, '1', true,
          'Styles', 17
        from public.styles where style_key = '003|L5-C-F021-28-26|Girls'
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
          'Styles', 17
        from public.styles where style_key = '003|L5-C-F021-28-26|Girls'
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
          'Styles', 17
        from public.styles where style_key = '003|L5-C-F021-28-26|Girls'
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
          'Styles', 17
        from public.styles where style_key = '003|L5-C-F021-28-26|Girls'
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
          'Styles', 17
        from public.styles where style_key = '003|L5-C-F021-28-26|Girls'
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
          'Styles', 17
        from public.styles where style_key = '003|L5-C-F021-28-26|Girls'
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
          'Styles', 17
        from public.styles where style_key = '003|L5-C-F021-28-26|Girls'
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
          'Styles', 17
        from public.styles where style_key = '003|L5-C-F021-28-26|Girls'
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
        '003|L5-A-F021-28-26|Women''s', 'L5-A-F021-28-26',
        (select id from public.costume_orders where order_number = '003'),
        '003', 'Yellow Brick Road', 'Boatneck L/S Leo', 'Women''s',
        'Female', 'Girls', 'A', null,
        'F021-28',
        (select id from public.materials where material_code = 'F021-28'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 18, 'SOURCE: Product Development Tracking row 20'
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
        select id, 'Pattern Complete', 1, 'Yes MA/XSA', null,
          null, '1', true,
          'Styles', 18
        from public.styles where style_key = '003|L5-A-F021-28-26|Women''s'
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
        select id, 'Sample Completed', 2, '2026-08-26 00:00:00', '2026-08-26',
          null, '1', true,
          'Styles', 18
        from public.styles where style_key = '003|L5-A-F021-28-26|Women''s'
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
        select id, 'Fit Test', 3, '?', null,
          null, '0', false,
          'Styles', 18
        from public.styles where style_key = '003|L5-A-F021-28-26|Women''s'
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
        select id, 'Corrections', 4, '2026-08-17 00:00:00', '2026-08-17',
          null, '1', true,
          'Styles', 18
        from public.styles where style_key = '003|L5-A-F021-28-26|Women''s'
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
          'Styles', 18
        from public.styles where style_key = '003|L5-A-F021-28-26|Women''s'
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
        select id, 'Grading', 6, '9/25/26 but need to fix', null,
          null, '0', false,
          'Styles', 18
        from public.styles where style_key = '003|L5-A-F021-28-26|Women''s'
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
          'Styles', 18
        from public.styles where style_key = '003|L5-A-F021-28-26|Women''s'
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
          'Styles', 18
        from public.styles where style_key = '003|L5-A-F021-28-26|Women''s'
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
          'Styles', 18
        from public.styles where style_key = '003|L5-A-F021-28-26|Women''s'
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
          'Styles', 18
        from public.styles where style_key = '003|L5-A-F021-28-26|Women''s'
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
          'Styles', 18
        from public.styles where style_key = '003|L5-A-F021-28-26|Women''s'
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
        '003|L13-A-F017-01-26|Women''s', 'L13-A-F017-01-26',
        (select id from public.costume_orders where order_number = '003'),
        '003', 'Yellow Brick Road', 'A-Line Dress w/ Attached Unitard', 'Women''s',
        'Female', 'Girls', 'A', 'Dorothy',
        'F017-01',
        (select id from public.materials where material_code = 'F017-01'),
        'Yes', null, null,
        'Styles', 19, 'SOURCE: Product Development Tracking row 21'
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
        select id, 'Pattern Complete', 1, 'Yes XSA 9/29/26', null,
          null, '1', true,
          'Styles', 19
        from public.styles where style_key = '003|L13-A-F017-01-26|Women''s'
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
          'Styles', 19
        from public.styles where style_key = '003|L13-A-F017-01-26|Women''s'
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
          'Styles', 19
        from public.styles where style_key = '003|L13-A-F017-01-26|Women''s'
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
          'Styles', 19
        from public.styles where style_key = '003|L13-A-F017-01-26|Women''s'
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
          'Styles', 19
        from public.styles where style_key = '003|L13-A-F017-01-26|Women''s'
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
          'Styles', 19
        from public.styles where style_key = '003|L13-A-F017-01-26|Women''s'
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
          'Styles', 19
        from public.styles where style_key = '003|L13-A-F017-01-26|Women''s'
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
          'Styles', 19
        from public.styles where style_key = '003|L13-A-F017-01-26|Women''s'
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
          'Styles', 19
        from public.styles where style_key = '003|L13-A-F017-01-26|Women''s'
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
          'Styles', 19
        from public.styles where style_key = '003|L13-A-F017-01-26|Women''s'
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
          'Styles', 19
        from public.styles where style_key = '003|L13-A-F017-01-26|Women''s'
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
        '003|L13-A-F021-29-26|Women''s', 'L13-A-F021-29-26',
        (select id from public.costume_orders where order_number = '003'),
        '003', 'Yellow Brick Road', 'A-Line Dress w/ Attached Unitard', 'Women''s',
        'Female', 'Girls', 'A', 'Tinman',
        'F021-29',
        (select id from public.materials where material_code = 'F021-29'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 20, 'SOURCE: Product Development Tracking row 22'
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
          'Styles', 20
        from public.styles where style_key = '003|L13-A-F021-29-26|Women''s'
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
          'Styles', 20
        from public.styles where style_key = '003|L13-A-F021-29-26|Women''s'
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
          'Styles', 20
        from public.styles where style_key = '003|L13-A-F021-29-26|Women''s'
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
          'Styles', 20
        from public.styles where style_key = '003|L13-A-F021-29-26|Women''s'
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
          'Styles', 20
        from public.styles where style_key = '003|L13-A-F021-29-26|Women''s'
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
          'Styles', 20
        from public.styles where style_key = '003|L13-A-F021-29-26|Women''s'
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
          'Styles', 20
        from public.styles where style_key = '003|L13-A-F021-29-26|Women''s'
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
          'Styles', 20
        from public.styles where style_key = '003|L13-A-F021-29-26|Women''s'
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
          'Styles', 20
        from public.styles where style_key = '003|L13-A-F021-29-26|Women''s'
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
          'Styles', 20
        from public.styles where style_key = '003|L13-A-F021-29-26|Women''s'
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
          'Styles', 20
        from public.styles where style_key = '003|L13-A-F021-29-26|Women''s'
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
        '003|L6-C-F021-23-26|Girls', 'L6-C-F021-23-26',
        (select id from public.costume_orders where order_number = '003'),
        '003', 'Yellow Brick Road', 'A-Line Dress w/ Attached Unitard', 'Girls',
        'Female', 'Girls', 'C', 'Scarecrow',
        'F021-23',
        (select id from public.materials where material_code = 'F021-23'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 21, 'SOURCE: Product Development Tracking row 23'
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
          'Styles', 21
        from public.styles where style_key = '003|L6-C-F021-23-26|Girls'
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
          'Styles', 21
        from public.styles where style_key = '003|L6-C-F021-23-26|Girls'
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
          'Styles', 21
        from public.styles where style_key = '003|L6-C-F021-23-26|Girls'
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
          'Styles', 21
        from public.styles where style_key = '003|L6-C-F021-23-26|Girls'
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
          'Styles', 21
        from public.styles where style_key = '003|L6-C-F021-23-26|Girls'
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
          'Styles', 21
        from public.styles where style_key = '003|L6-C-F021-23-26|Girls'
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
          'Styles', 21
        from public.styles where style_key = '003|L6-C-F021-23-26|Girls'
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
          'Styles', 21
        from public.styles where style_key = '003|L6-C-F021-23-26|Girls'
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
          'Styles', 21
        from public.styles where style_key = '003|L6-C-F021-23-26|Girls'
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
          'Styles', 21
        from public.styles where style_key = '003|L6-C-F021-23-26|Girls'
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
          'Styles', 21
        from public.styles where style_key = '003|L6-C-F021-23-26|Girls'
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
        '003|L6-C-F021-12-26|Girls', 'L6-C-F021-12-26',
        (select id from public.costume_orders where order_number = '003'),
        '003', 'Yellow Brick Road', 'A-Line Dress w/ Attached Unitard', 'Girls',
        'Female', 'Girls', 'C', 'Lion',
        'F021-12',
        (select id from public.materials where material_code = 'F021-12'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 22, 'SOURCE: Product Development Tracking row 24'
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
          'Styles', 22
        from public.styles where style_key = '003|L6-C-F021-12-26|Girls'
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
        select id, 'Sample Completed', 2, '2026-08-26 00:00:00', '2026-08-26',
          null, '1', true,
          'Styles', 22
        from public.styles where style_key = '003|L6-C-F021-12-26|Girls'
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
        select id, 'Fit Test', 3, '2026-08-31 00:00:00', '2026-08-31',
          null, '1', true,
          'Styles', 22
        from public.styles where style_key = '003|L6-C-F021-12-26|Girls'
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
        select id, 'Corrections', 4, '2026-09-17 00:00:00', '2026-09-17',
          null, '1', true,
          'Styles', 22
        from public.styles where style_key = '003|L6-C-F021-12-26|Girls'
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
          'Styles', 22
        from public.styles where style_key = '003|L6-C-F021-12-26|Girls'
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
          'Styles', 22
        from public.styles where style_key = '003|L6-C-F021-12-26|Girls'
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
          'Styles', 22
        from public.styles where style_key = '003|L6-C-F021-12-26|Girls'
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
          'Styles', 22
        from public.styles where style_key = '003|L6-C-F021-12-26|Girls'
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
          'Styles', 22
        from public.styles where style_key = '003|L6-C-F021-12-26|Girls'
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
          'Styles', 22
        from public.styles where style_key = '003|L6-C-F021-12-26|Girls'
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
          'Styles', 22
        from public.styles where style_key = '003|L6-C-F021-12-26|Girls'
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
        '003|L6-C-F021-09-26|Girls', 'L6-C-F021-09-26',
        (select id from public.costume_orders where order_number = '003'),
        '003', 'Yellow Brick Road', 'A-Line Dress w/ Attached Unitard', 'Girls',
        'Female', 'Girls', 'C', 'Wizard',
        'F021-09',
        (select id from public.materials where material_code = 'F021-09'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 23, 'SOURCE: Product Development Tracking row 25'
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
          'Styles', 23
        from public.styles where style_key = '003|L6-C-F021-09-26|Girls'
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
          'Styles', 23
        from public.styles where style_key = '003|L6-C-F021-09-26|Girls'
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
          'Styles', 23
        from public.styles where style_key = '003|L6-C-F021-09-26|Girls'
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
          'Styles', 23
        from public.styles where style_key = '003|L6-C-F021-09-26|Girls'
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
          'Styles', 23
        from public.styles where style_key = '003|L6-C-F021-09-26|Girls'
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
          'Styles', 23
        from public.styles where style_key = '003|L6-C-F021-09-26|Girls'
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
          'Styles', 23
        from public.styles where style_key = '003|L6-C-F021-09-26|Girls'
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
          'Styles', 23
        from public.styles where style_key = '003|L6-C-F021-09-26|Girls'
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
          'Styles', 23
        from public.styles where style_key = '003|L6-C-F021-09-26|Girls'
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
          'Styles', 23
        from public.styles where style_key = '003|L6-C-F021-09-26|Girls'
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
          'Styles', 23
        from public.styles where style_key = '003|L6-C-F021-09-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;
