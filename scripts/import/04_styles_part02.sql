-- 04_styles_part02.sql
-- Idempotent import from the 2026-10-30 tracker export.
-- Run after the inventory migration. Safe to run again.

insert into public.styles (
        style_key, style_code, order_id, order_number_raw, production_song,
        garment_description, category, group_name, version_label, child_or_adult,
        character_note, fabric_code_raw, material_id, fabric_in_materials,
        size_qty_raw, flags, source_tab, source_row, source_label
      ) values (
        '003|L7-C-F021-28-26|Boys', 'L7-C-F021-28-26',
        (select id from public.costume_orders where order_number = '003'),
        '003', 'Yellow Brick Road', 'L/S Round Neck Leo', 'Boys',
        'Male', 'Boys', 'C', null,
        'F021-28',
        (select id from public.materials where material_code = 'F021-28'),
        'Yes', null, null,
        'Styles', 24, 'SOURCE: Product Development Tracking row 27'
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
          'Styles', 24
        from public.styles where style_key = '003|L7-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '2026-08-13 00:00:00', '2026-08-13',
          null, '1', true,
          'Styles', 24
        from public.styles where style_key = '003|L7-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 24
        from public.styles where style_key = '003|L7-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 24
        from public.styles where style_key = '003|L7-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 24
        from public.styles where style_key = '003|L7-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'complete', null,
          null, '1', true,
          'Styles', 24
        from public.styles where style_key = '003|L7-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 24
        from public.styles where style_key = '003|L7-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 24
        from public.styles where style_key = '003|L7-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 24
        from public.styles where style_key = '003|L7-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 24
        from public.styles where style_key = '003|L7-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 24
        from public.styles where style_key = '003|L7-C-F021-28-26|Boys'
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
        '003|P10-C-F021-28-26|Girls', 'P10-C-F021-28-26',
        (select id from public.costume_orders where order_number = '003'),
        '003', 'Yellow Brick Road', 'Straight Leg Pant', 'Girls',
        'Female', 'Girls', 'C', null,
        'F021-28',
        (select id from public.materials where material_code = 'F021-28'),
        'Yes', null, null,
        'Styles', 25, 'SOURCE: Product Development Tracking row 28'
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
          'Styles', 25
        from public.styles where style_key = '003|P10-C-F021-28-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 25
        from public.styles where style_key = '003|P10-C-F021-28-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 25
        from public.styles where style_key = '003|P10-C-F021-28-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 25
        from public.styles where style_key = '003|P10-C-F021-28-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 25
        from public.styles where style_key = '003|P10-C-F021-28-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, '2026-09-15 00:00:00', '2026-09-15',
          null, '1', true,
          'Styles', 25
        from public.styles where style_key = '003|P10-C-F021-28-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 25
        from public.styles where style_key = '003|P10-C-F021-28-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 25
        from public.styles where style_key = '003|P10-C-F021-28-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 25
        from public.styles where style_key = '003|P10-C-F021-28-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 25
        from public.styles where style_key = '003|P10-C-F021-28-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, 'Yes', null,
          true, '1', true,
          'Styles', 25
        from public.styles where style_key = '003|P10-C-F021-28-26|Girls'
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
        '003|P10-A-F021-28-26|Women''s', 'P10-A-F021-28-26',
        (select id from public.costume_orders where order_number = '003'),
        '003', 'Yellow Brick Road', 'Straight Leg Pant', 'Women''s',
        'Female', 'Girls', 'A', null,
        'F021-28',
        (select id from public.materials where material_code = 'F021-28'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 26, 'SOURCE: Product Development Tracking row 29'
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
          'Styles', 26
        from public.styles where style_key = '003|P10-A-F021-28-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 26
        from public.styles where style_key = '003|P10-A-F021-28-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 26
        from public.styles where style_key = '003|P10-A-F021-28-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 26
        from public.styles where style_key = '003|P10-A-F021-28-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 26
        from public.styles where style_key = '003|P10-A-F021-28-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, '2026-09-15 00:00:00', '2026-09-15',
          null, '1', true,
          'Styles', 26
        from public.styles where style_key = '003|P10-A-F021-28-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 26
        from public.styles where style_key = '003|P10-A-F021-28-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 26
        from public.styles where style_key = '003|P10-A-F021-28-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 26
        from public.styles where style_key = '003|P10-A-F021-28-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 26
        from public.styles where style_key = '003|P10-A-F021-28-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, 'Yes', null,
          true, '1', true,
          'Styles', 26
        from public.styles where style_key = '003|P10-A-F021-28-26|Women''s'
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
        '003|P11-C-F021-28-26|Boys', 'P11-C-F021-28-26',
        (select id from public.costume_orders where order_number = '003'),
        '003', 'Yellow Brick Road', 'Straight Leg Pant', 'Boys',
        'Male', 'Boys', 'C', null,
        'F021-28',
        (select id from public.materials where material_code = 'F021-28'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 27, 'SOURCE: Product Development Tracking row 30'
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
          'Styles', 27
        from public.styles where style_key = '003|P11-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 27
        from public.styles where style_key = '003|P11-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 27
        from public.styles where style_key = '003|P11-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 27
        from public.styles where style_key = '003|P11-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 27
        from public.styles where style_key = '003|P11-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, '2026-09-15 00:00:00', '2026-09-15',
          null, '1', true,
          'Styles', 27
        from public.styles where style_key = '003|P11-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 27
        from public.styles where style_key = '003|P11-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 27
        from public.styles where style_key = '003|P11-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 27
        from public.styles where style_key = '003|P11-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 27
        from public.styles where style_key = '003|P11-C-F021-28-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, 'Yes', null,
          true, '1', true,
          'Styles', 27
        from public.styles where style_key = '003|P11-C-F021-28-26|Boys'
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
        '003|A2-C-F007-12-26|Girls', 'A2-C-F007-12-26',
        (select id from public.costume_orders where order_number = '003'),
        '003', 'Yellow Brick Road', 'Bricks Belt', 'Girls',
        'Female', 'Girls', 'C', null,
        'F007-12',
        (select id from public.materials where material_code = 'F007-12'),
        'Yes', null, null,
        'Styles', 28, 'SOURCE: Product Development Tracking row 31'
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
        select id, 'Pattern Complete', 1, 'Yes MC/one size', null,
          null, '1', true,
          'Styles', 28
        from public.styles where style_key = '003|A2-C-F007-12-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '2026-09-01 00:00:00', '2026-09-01',
          null, '1', true,
          'Styles', 28
        from public.styles where style_key = '003|A2-C-F007-12-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '9/2/26 & 9/10/26', null,
          null, '1', true,
          'Styles', 28
        from public.styles where style_key = '003|A2-C-F007-12-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 28
        from public.styles where style_key = '003|A2-C-F007-12-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 28
        from public.styles where style_key = '003|A2-C-F007-12-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'N/A one size', null,
          null, '1', true,
          'Styles', 28
        from public.styles where style_key = '003|A2-C-F007-12-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 28
        from public.styles where style_key = '003|A2-C-F007-12-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 28
        from public.styles where style_key = '003|A2-C-F007-12-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 28
        from public.styles where style_key = '003|A2-C-F007-12-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 28
        from public.styles where style_key = '003|A2-C-F007-12-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 28
        from public.styles where style_key = '003|A2-C-F007-12-26|Girls'
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
        '004|L3-A-F002-59-26|Women''s', 'L3-A-F002-59-26',
        (select id from public.costume_orders where order_number = '004'),
        '004', 'Sunglasses At Night', 'Mesh Insert Leo', 'Women''s',
        'Female', 'Girls', 'A', null,
        'F002-59',
        (select id from public.materials where material_code = 'F002-59'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 29, 'SOURCE: Product Development Tracking row 35'
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
          'Styles', 29
        from public.styles where style_key = '004|L3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 29
        from public.styles where style_key = '004|L3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 29
        from public.styles where style_key = '004|L3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, '9/14/26 & 10/5/26', null,
          null, '1', true,
          'Styles', 29
        from public.styles where style_key = '004|L3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, '2026-09-10 00:00:00', '2026-09-10',
          null, '1', true,
          'Styles', 29
        from public.styles where style_key = '004|L3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, '9/23/26 but need to fix', null,
          null, '0', false,
          'Styles', 29
        from public.styles where style_key = '004|L3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 29
        from public.styles where style_key = '004|L3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 29
        from public.styles where style_key = '004|L3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 29
        from public.styles where style_key = '004|L3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 29
        from public.styles where style_key = '004|L3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 29
        from public.styles where style_key = '004|L3-A-F002-59-26|Women''s'
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
        '004|P14-A-F002-59-26|Men''s', 'P14-A-F002-59-26',
        (select id from public.costume_orders where order_number = '004'),
        '004', 'Sunglasses At Night', 'Straight Leg Pant', 'Men''s',
        'Male', 'Boys', 'A', null,
        'F002-59',
        (select id from public.materials where material_code = 'F002-59'),
        'Yes', null, null,
        'Styles', 30, 'SOURCE: Product Development Tracking row 36'
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
        select id, 'Pattern Complete', 1, 'Make in PAD SA', null,
          null, '1', true,
          'Styles', 30
        from public.styles where style_key = '004|P14-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '9/1/26 & 10/7/26', null,
          null, '1', true,
          'Styles', 30
        from public.styles where style_key = '004|P14-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '2026-09-25 00:00:00', '2026-09-25',
          null, '1', true,
          'Styles', 30
        from public.styles where style_key = '004|P14-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 30
        from public.styles where style_key = '004|P14-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 30
        from public.styles where style_key = '004|P14-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 30
        from public.styles where style_key = '004|P14-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 30
        from public.styles where style_key = '004|P14-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 30
        from public.styles where style_key = '004|P14-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 30
        from public.styles where style_key = '004|P14-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 30
        from public.styles where style_key = '004|P14-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 30
        from public.styles where style_key = '004|P14-A-F002-59-26|Men''s'
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
        '004|P3-A-F002-59-26|Women''s', 'P3-A-F002-59-26',
        (select id from public.costume_orders where order_number = '004'),
        '004', 'Sunglasses At Night', 'Straight Leg Pant', 'Women''s',
        'Female', 'Girls', 'A', null,
        'F002-59',
        (select id from public.materials where material_code = 'F002-59'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 31, 'SOURCE: Product Development Tracking row 37'
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
        select id, 'Pattern Complete', 1, 'MA', null,
          null, '1', true,
          'Styles', 31
        from public.styles where style_key = '004|P3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 31
        from public.styles where style_key = '004|P3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 31
        from public.styles where style_key = '004|P3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, '2026-09-14 00:00:00', '2026-09-14',
          null, '1', true,
          'Styles', 31
        from public.styles where style_key = '004|P3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 31
        from public.styles where style_key = '004|P3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, '2026-10-06 00:00:00', '2026-10-06',
          null, '1', true,
          'Styles', 31
        from public.styles where style_key = '004|P3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 31
        from public.styles where style_key = '004|P3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 31
        from public.styles where style_key = '004|P3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 31
        from public.styles where style_key = '004|P3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 31
        from public.styles where style_key = '004|P3-A-F002-59-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, 'Yes', null,
          true, '1', true,
          'Styles', 31
        from public.styles where style_key = '004|P3-A-F002-59-26|Women''s'
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
        '004|L4-A-F002-59-26|Men''s', 'L4-A-F002-59-26',
        (select id from public.costume_orders where order_number = '004'),
        '004', 'Sunglasses At Night', 'Crewneck Leo w/ Mesh Overlay', 'Men''s',
        'Male', 'Boys', 'A', null,
        'F002-59',
        (select id from public.materials where material_code = 'F002-59'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 32, 'SOURCE: Product Development Tracking row 39'
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
          'Styles', 32
        from public.styles where style_key = '004|L4-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '9/1/26 & 10/8/26', null,
          null, '1', true,
          'Styles', 32
        from public.styles where style_key = '004|L4-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 32
        from public.styles where style_key = '004|L4-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 32
        from public.styles where style_key = '004|L4-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 32
        from public.styles where style_key = '004|L4-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 32
        from public.styles where style_key = '004|L4-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 32
        from public.styles where style_key = '004|L4-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 32
        from public.styles where style_key = '004|L4-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 32
        from public.styles where style_key = '004|L4-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 32
        from public.styles where style_key = '004|L4-A-F002-59-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 32
        from public.styles where style_key = '004|L4-A-F002-59-26|Men''s'
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
        '005|L7-C-F001-06-26|Girls', 'L7-C-F001-06-26',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Boom Boom Pow', 'Scoopneck L/S Leo', 'Girls',
        'Female', 'Girls', 'C', null,
        'F001-06',
        (select id from public.materials where material_code = 'F001-06'),
        'Yes', '4', 'Style # used by more than one style',
        'Styles', 33, 'SOURCE: Product Development Tracking row 41'
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
        select id, 'Pattern Complete', 1, 'Yes MC & LC in PAD', null,
          null, '1', true,
          'Styles', 33
        from public.styles where style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '2026-08-13 00:00:00', '2026-08-13',
          null, '1', true,
          'Styles', 33
        from public.styles where style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '2026-08-17 00:00:00', '2026-08-17',
          null, '1', true,
          'Styles', 33
        from public.styles where style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 33
        from public.styles where style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, '2026-08-17 00:00:00', '2026-08-17',
          null, '1', true,
          'Styles', 33
        from public.styles where style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 33
        from public.styles where style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 33
        from public.styles where style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 33
        from public.styles where style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 33
        from public.styles where style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 33
        from public.styles where style_key = '005|L7-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 33
        from public.styles where style_key = '005|L7-C-F001-06-26|Girls'
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
        '005|L7-C-F001-06-26|Boys', 'L7-C-F001-06-26',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Boom Boom Pow', 'T-Shirt Neck L/S Leo', 'Boys',
        'Male', 'Boys', 'C', null,
        'F001-06',
        (select id from public.materials where material_code = 'F001-06'),
        'Yes', '1', 'Style # used by more than one style',
        'Styles', 34, 'SOURCE: Product Development Tracking row 42'
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
        select id, 'Pattern Complete', 1, 'Yes MC & LC in PAD', null,
          null, '1', true,
          'Styles', 34
        from public.styles where style_key = '005|L7-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '2026-08-13 00:00:00', '2026-08-13',
          null, '1', true,
          'Styles', 34
        from public.styles where style_key = '005|L7-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '*use same neck as girls to get the stretch to go over hips*', null,
          null, '1', true,
          'Styles', 34
        from public.styles where style_key = '005|L7-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 34
        from public.styles where style_key = '005|L7-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 34
        from public.styles where style_key = '005|L7-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 34
        from public.styles where style_key = '005|L7-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 34
        from public.styles where style_key = '005|L7-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 34
        from public.styles where style_key = '005|L7-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 34
        from public.styles where style_key = '005|L7-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 34
        from public.styles where style_key = '005|L7-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 34
        from public.styles where style_key = '005|L7-C-F001-06-26|Boys'
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
        '005|L6-A-F001-06-26|Women''s', 'L6-A-F001-06-26',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Boom Boom Pow', 'Scoopneck L/S Leo', 'Women''s',
        'Female', 'Girls', 'A', null,
        'F001-06',
        (select id from public.materials where material_code = 'F001-06'),
        'Yes', '60', null,
        'Styles', 35, 'SOURCE: Product Development Tracking row 43'
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
          'Styles', 35
        from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '2026-08-13 00:00:00', '2026-08-13',
          null, '1', true,
          'Styles', 35
        from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '2026-08-17 00:00:00', '2026-08-17',
          null, '1', true,
          'Styles', 35
        from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 35
        from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Approved', 5, '2026-08-17 00:00:00', '2026-08-17',
          null, '1', true,
          'Styles', 35
        from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 35
        from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 35
        from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 35
        from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 35
        from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 35
        from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 35
        from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'
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
        '005|L9-A-F001-06-26|Men''s', 'L9-A-F001-06-26',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Boom Boom Pow', 'T-Shirt Neck L/S Leo', 'Men''s',
        'Male', 'Boys', 'A', null,
        'F001-06',
        (select id from public.materials where material_code = 'F001-06'),
        'Yes', '3', null,
        'Styles', 36, 'SOURCE: Product Development Tracking row 44'
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
          'Styles', 36
        from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '8/13/26 & 10/8/26', null,
          null, '1', true,
          'Styles', 36
        from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 36
        from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, '9/3/26 & 9/28/26', null,
          null, '1', true,
          'Styles', 36
        from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 36
        from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 36
        from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 36
        from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 36
        from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 36
        from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 36
        from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 36
        from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'
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
        '005|P6-C-F001-06-26|Girls', 'P6-C-F001-06-26',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Boom Boom Pow', 'Straight Leg Pant w/ Contrast', 'Girls',
        'Female', 'Girls', 'C', null,
        'F001-06',
        (select id from public.materials where material_code = 'F001-06'),
        'Yes', '4', null,
        'Styles', 37, 'SOURCE: Product Development Tracking row 45'
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
          'Styles', 37
        from public.styles where style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 37
        from public.styles where style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 37
        from public.styles where style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 37
        from public.styles where style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 37
        from public.styles where style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'Already in PAD', null,
          null, '1', true,
          'Styles', 37
        from public.styles where style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, '2026-10-06 00:00:00', '2026-10-06',
          null, '1', true,
          'Styles', 37
        from public.styles where style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 37
        from public.styles where style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 37
        from public.styles where style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 37
        from public.styles where style_key = '005|P6-C-F001-06-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, 'Yes', null,
          true, '1', true,
          'Styles', 37
        from public.styles where style_key = '005|P6-C-F001-06-26|Girls'
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
        '005|P7-A-F001-06-26|Women''s', 'P7-A-F001-06-26',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Boom Boom Pow', 'Straight Leg Pant w/ Contrast', 'Women''s',
        'Female', 'Girls', 'A', null,
        'F001-06',
        (select id from public.materials where material_code = 'F001-06'),
        'Yes', '60', 'Description carried down from the row above (as laid out in source)',
        'Styles', 38, 'SOURCE: Product Development Tracking row 46'
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
          'Styles', 38
        from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 38
        from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 38
        from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 38
        from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 38
        from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'Already in PAD', null,
          null, '1', true,
          'Styles', 38
        from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, '2026-10-06 00:00:00', '2026-10-06',
          null, '1', true,
          'Styles', 38
        from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 38
        from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 38
        from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 38
        from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, 'Yes', null,
          true, '1', true,
          'Styles', 38
        from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'
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
        '005|P9-C-F001-06-26|Boys', 'P9-C-F001-06-26',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Boom Boom Pow', 'Straight Leg Pant w/ Contrast', 'Boys',
        'Male', 'Boys', 'C', null,
        'F001-06',
        (select id from public.materials where material_code = 'F001-06'),
        'Yes', '1', 'Description carried down from the row above (as laid out in source)',
        'Styles', 39, 'SOURCE: Product Development Tracking row 47'
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
          'Styles', 39
        from public.styles where style_key = '005|P9-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 39
        from public.styles where style_key = '005|P9-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 39
        from public.styles where style_key = '005|P9-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 39
        from public.styles where style_key = '005|P9-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 39
        from public.styles where style_key = '005|P9-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'Already in PAD', null,
          null, '1', true,
          'Styles', 39
        from public.styles where style_key = '005|P9-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, '2026-10-06 00:00:00', '2026-10-06',
          null, '1', true,
          'Styles', 39
        from public.styles where style_key = '005|P9-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 39
        from public.styles where style_key = '005|P9-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 39
        from public.styles where style_key = '005|P9-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 39
        from public.styles where style_key = '005|P9-C-F001-06-26|Boys'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, 'Yes', null,
          true, '1', true,
          'Styles', 39
        from public.styles where style_key = '005|P9-C-F001-06-26|Boys'
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
        '005|P9-A-F001-06-26|Men''s', 'P9-A-F001-06-26',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Boom Boom Pow', 'Straight Leg Pant w/ Contrast', 'Men''s',
        'Male', 'Boys', 'A', null,
        'F001-06',
        (select id from public.materials where material_code = 'F001-06'),
        'Yes', '3', 'Description carried down from the row above (as laid out in source)',
        'Styles', 40, 'SOURCE: Product Development Tracking row 48'
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
          'Styles', 40
        from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 40
        from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 40
        from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 40
        from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 40
        from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Grading', 6, 'Already in PAD', null,
          null, '1', true,
          'Styles', 40
        from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Marker', 7, '2026-10-06 00:00:00', '2026-10-06',
          null, '1', true,
          'Styles', 40
        from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 40
        from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 40
        from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 40
        from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Ready to Cut', 11, 'Yes', null,
          true, '1', true,
          'Styles', 40
        from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'
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
        '006|L8-A-F001-06-26|Women''s', 'L8-A-F001-06-26',
        (select id from public.costume_orders where order_number = '006'),
        '006', 'This Love', 'Mesh Insert L/S Flounce Cuff Unitard Leo', 'Women''s',
        'Female', 'Girls', 'A', null,
        'F001-06',
        (select id from public.materials where material_code = 'F001-06'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 41, 'SOURCE: Product Development Tracking row 51'
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
          'Styles', 41
        from public.styles where style_key = '006|L8-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '2026-08-28 00:00:00', '2026-08-28',
          null, '1', true,
          'Styles', 41
        from public.styles where style_key = '006|L8-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Fit Test', 3, '9/10/26 & 9/17/26', null,
          null, '1', true,
          'Styles', 41
        from public.styles where style_key = '006|L8-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, '2026-09-10 00:00:00', '2026-09-10',
          null, '1', true,
          'Styles', 41
        from public.styles where style_key = '006|L8-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 41
        from public.styles where style_key = '006|L8-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 41
        from public.styles where style_key = '006|L8-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 41
        from public.styles where style_key = '006|L8-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 41
        from public.styles where style_key = '006|L8-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'waiting on binding & bows', null,
          null, '0', false,
          'Styles', 41
        from public.styles where style_key = '006|L8-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 41
        from public.styles where style_key = '006|L8-A-F001-06-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 41
        from public.styles where style_key = '006|L8-A-F001-06-26|Women''s'
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
        '006|P5-A-F012-119-26|Women''s', 'P5-A-F012-119-26',
        (select id from public.costume_orders where order_number = '006'),
        '006', 'This Love', 'Balloon Pant', 'Women''s',
        'Female', 'Girls', 'A', null,
        'F012-119',
        (select id from public.materials where material_code = 'F012-119'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 42, 'SOURCE: Product Development Tracking row 53'
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
          'Styles', 42
        from public.styles where style_key = '006|P5-A-F012-119-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '2026-09-01 00:00:00', '2026-09-01',
          null, '1', true,
          'Styles', 42
        from public.styles where style_key = '006|P5-A-F012-119-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 42
        from public.styles where style_key = '006|P5-A-F012-119-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Corrections', 4, '2026-09-14 00:00:00', '2026-09-14',
          null, '1', true,
          'Styles', 42
        from public.styles where style_key = '006|P5-A-F012-119-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 42
        from public.styles where style_key = '006|P5-A-F012-119-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 42
        from public.styles where style_key = '006|P5-A-F012-119-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 42
        from public.styles where style_key = '006|P5-A-F012-119-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 42
        from public.styles where style_key = '006|P5-A-F012-119-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'waiting on bows', null,
          null, '0', false,
          'Styles', 42
        from public.styles where style_key = '006|P5-A-F012-119-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 42
        from public.styles where style_key = '006|P5-A-F012-119-26|Women''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 42
        from public.styles where style_key = '006|P5-A-F012-119-26|Women''s'
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
        '006|P6-A-F012-119-26|Men''s', 'P6-A-F012-119-26',
        (select id from public.costume_orders where order_number = '006'),
        '006', 'This Love', 'Balloon Pant', 'Men''s',
        'Male', 'Boys', 'A', null,
        'F012-119',
        (select id from public.materials where material_code = 'F012-119'),
        'Yes', null, 'Description carried down from the row above (as laid out in source)',
        'Styles', 43, 'SOURCE: Product Development Tracking row 54'
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
        select id, 'Pattern Complete', 1, 'Yes SA 8/25/26', null,
          null, '1', true,
          'Styles', 43
        from public.styles where style_key = '006|P6-A-F012-119-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Sample Completed', 2, '2026-09-01 00:00:00', '2026-09-01',
          null, '1', true,
          'Styles', 43
        from public.styles where style_key = '006|P6-A-F012-119-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 43
        from public.styles where style_key = '006|P6-A-F012-119-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 43
        from public.styles where style_key = '006|P6-A-F012-119-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 43
        from public.styles where style_key = '006|P6-A-F012-119-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 43
        from public.styles where style_key = '006|P6-A-F012-119-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 43
        from public.styles where style_key = '006|P6-A-F012-119-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 43
        from public.styles where style_key = '006|P6-A-F012-119-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Notions in stock', 9, 'waiting on bows', null,
          null, '0', false,
          'Styles', 43
        from public.styles where style_key = '006|P6-A-F012-119-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 43
        from public.styles where style_key = '006|P6-A-F012-119-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 43
        from public.styles where style_key = '006|P6-A-F012-119-26|Men''s'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;
