-- 04_styles_part06.sql
-- Idempotent import from the 2026-10-30 tracker export.
-- Run after the inventory migration. Safe to run again.

insert into public.style_stages (
          style_id, stage_name, stage_order, cell_text, interpreted_on, interpreted_yes,
          check_text, check_yes, source_tab, source_row
        )
        select id, 'Pattern Complete', 1, 'MC 10/6/26', null,
          null, '1', true,
          'Styles', 104
        from public.styles where style_key = '034|SH3-C-F013-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 104
        from public.styles where style_key = '034|SH3-C-F013-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 104
        from public.styles where style_key = '034|SH3-C-F013-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 104
        from public.styles where style_key = '034|SH3-C-F013-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 104
        from public.styles where style_key = '034|SH3-C-F013-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 104
        from public.styles where style_key = '034|SH3-C-F013-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 104
        from public.styles where style_key = '034|SH3-C-F013-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 104
        from public.styles where style_key = '034|SH3-C-F013-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 104
        from public.styles where style_key = '034|SH3-C-F013-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 104
        from public.styles where style_key = '034|SH3-C-F013-01-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 104
        from public.styles where style_key = '034|SH3-C-F013-01-26|Girls'
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
        '035|P17-A-F001-19-26|Womens', 'P17-A-F001-19-26',
        (select id from public.costume_orders where order_number = '035'),
        '035', 'Hypericum', 'HW SL Pant w/ Attached Mesh Skirt', 'Womens',
        'Female', 'Girls', 'A', null,
        'F001-19',
        (select id from public.materials where material_code = 'F001-19'),
        'Yes', null, null,
        'Styles', 105, 'SOURCE: Product Development Tracking row 172'
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
        select id, 'Pattern Complete', 1, 'SA 10/7/26', null,
          null, '1', true,
          'Styles', 105
        from public.styles where style_key = '035|P17-A-F001-19-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 105
        from public.styles where style_key = '035|P17-A-F001-19-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 105
        from public.styles where style_key = '035|P17-A-F001-19-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 105
        from public.styles where style_key = '035|P17-A-F001-19-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 105
        from public.styles where style_key = '035|P17-A-F001-19-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 105
        from public.styles where style_key = '035|P17-A-F001-19-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 105
        from public.styles where style_key = '035|P17-A-F001-19-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 105
        from public.styles where style_key = '035|P17-A-F001-19-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 105
        from public.styles where style_key = '035|P17-A-F001-19-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 105
        from public.styles where style_key = '035|P17-A-F001-19-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 105
        from public.styles where style_key = '035|P17-A-F001-19-26|Womens'
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
        '035|P17-C-F001-19-26|Girls', 'P17-C-F001-19-26',
        (select id from public.costume_orders where order_number = '035'),
        '035', 'Hypericum', 'HW SL Pant w/ Attached Mesh Skirt', 'Girls',
        'Female', 'Girls', 'C', null,
        'F001-19',
        (select id from public.materials where material_code = 'F001-19'),
        'Yes', null, null,
        'Styles', 106, 'SOURCE: Product Development Tracking row 173'
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
        select id, 'Pattern Complete', 1, 'MC 10/7/26', null,
          null, '1', true,
          'Styles', 106
        from public.styles where style_key = '035|P17-C-F001-19-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 106
        from public.styles where style_key = '035|P17-C-F001-19-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 106
        from public.styles where style_key = '035|P17-C-F001-19-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 106
        from public.styles where style_key = '035|P17-C-F001-19-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 106
        from public.styles where style_key = '035|P17-C-F001-19-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 106
        from public.styles where style_key = '035|P17-C-F001-19-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 106
        from public.styles where style_key = '035|P17-C-F001-19-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 106
        from public.styles where style_key = '035|P17-C-F001-19-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 106
        from public.styles where style_key = '035|P17-C-F001-19-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 106
        from public.styles where style_key = '035|P17-C-F001-19-26|Girls'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 106
        from public.styles where style_key = '035|P17-C-F001-19-26|Girls'
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
        '039|T4-A-F026-03-26|Womens & Mens', 'T4-A-F026-03-26',
        (select id from public.costume_orders where order_number = '039'),
        '039', 'Penance', 'Sleeveless Boatneck Tunic', 'Womens & Mens',
        null, null, 'A', null,
        'F026-03',
        (select id from public.materials where material_code = 'F026-03'),
        'Yes', null, null,
        'Styles', 107, 'SOURCE: Product Development Tracking row 187'
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
          'Styles', 107
        from public.styles where style_key = '039|T4-A-F026-03-26|Womens & Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 107
        from public.styles where style_key = '039|T4-A-F026-03-26|Womens & Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 107
        from public.styles where style_key = '039|T4-A-F026-03-26|Womens & Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 107
        from public.styles where style_key = '039|T4-A-F026-03-26|Womens & Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 107
        from public.styles where style_key = '039|T4-A-F026-03-26|Womens & Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 107
        from public.styles where style_key = '039|T4-A-F026-03-26|Womens & Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 107
        from public.styles where style_key = '039|T4-A-F026-03-26|Womens & Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 107
        from public.styles where style_key = '039|T4-A-F026-03-26|Womens & Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 107
        from public.styles where style_key = '039|T4-A-F026-03-26|Womens & Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 107
        from public.styles where style_key = '039|T4-A-F026-03-26|Womens & Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 107
        from public.styles where style_key = '039|T4-A-F026-03-26|Womens & Mens'
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
        '039|P18-A-F001-06-26|Womens', 'P18-A-F001-06-26',
        (select id from public.costume_orders where order_number = '039'),
        '039', 'Penance', 'HW SL Pant', 'Womens',
        'Female', 'Girls', 'A', null,
        'F001-06',
        (select id from public.materials where material_code = 'F001-06'),
        'Yes', null, null,
        'Styles', 108, 'SOURCE: Product Development Tracking row 188'
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
        select id, 'Pattern Complete', 1, 'MA 10/8/26', null,
          null, '1', true,
          'Styles', 108
        from public.styles where style_key = '039|P18-A-F001-06-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 108
        from public.styles where style_key = '039|P18-A-F001-06-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 108
        from public.styles where style_key = '039|P18-A-F001-06-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 108
        from public.styles where style_key = '039|P18-A-F001-06-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 108
        from public.styles where style_key = '039|P18-A-F001-06-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 108
        from public.styles where style_key = '039|P18-A-F001-06-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 108
        from public.styles where style_key = '039|P18-A-F001-06-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 108
        from public.styles where style_key = '039|P18-A-F001-06-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 108
        from public.styles where style_key = '039|P18-A-F001-06-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 108
        from public.styles where style_key = '039|P18-A-F001-06-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 108
        from public.styles where style_key = '039|P18-A-F001-06-26|Womens'
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
        '039|P19-A-F001-06-26|Mens', 'P19-A-F001-06-26',
        (select id from public.costume_orders where order_number = '039'),
        '039', 'Penance', 'HW SL Pant', 'Mens',
        'Male', 'Boys', 'A', null,
        'F001-06',
        (select id from public.materials where material_code = 'F001-06'),
        'Yes', null, null,
        'Styles', 109, 'SOURCE: Product Development Tracking row 189'
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
        select id, 'Pattern Complete', 1, 'SA 10/8/26', null,
          null, '1', true,
          'Styles', 109
        from public.styles where style_key = '039|P19-A-F001-06-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 109
        from public.styles where style_key = '039|P19-A-F001-06-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 109
        from public.styles where style_key = '039|P19-A-F001-06-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 109
        from public.styles where style_key = '039|P19-A-F001-06-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 109
        from public.styles where style_key = '039|P19-A-F001-06-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 109
        from public.styles where style_key = '039|P19-A-F001-06-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 109
        from public.styles where style_key = '039|P19-A-F001-06-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 109
        from public.styles where style_key = '039|P19-A-F001-06-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 109
        from public.styles where style_key = '039|P19-A-F001-06-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 109
        from public.styles where style_key = '039|P19-A-F001-06-26|Mens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 109
        from public.styles where style_key = '039|P19-A-F001-06-26|Mens'
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
        '040|T3-A-F027-07-26|Womens', 'T3-A-F027-07-26',
        (select id from public.costume_orders where order_number = '040'),
        '040', 'Cheri Cheri Lady', 'Boxy Sleeveless Tank', 'Womens',
        'Female', 'Girls', 'A', null,
        'F027-07',
        (select id from public.materials where material_code = 'F027-07'),
        'Yes', null, null,
        'Styles', 110, 'SOURCE: Product Development Tracking row 191'
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
        select id, 'Pattern Complete', 1, 'MA 10/8/26', null,
          null, '1', true,
          'Styles', 110
        from public.styles where style_key = '040|T3-A-F027-07-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 110
        from public.styles where style_key = '040|T3-A-F027-07-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 110
        from public.styles where style_key = '040|T3-A-F027-07-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 110
        from public.styles where style_key = '040|T3-A-F027-07-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 110
        from public.styles where style_key = '040|T3-A-F027-07-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 110
        from public.styles where style_key = '040|T3-A-F027-07-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 110
        from public.styles where style_key = '040|T3-A-F027-07-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 110
        from public.styles where style_key = '040|T3-A-F027-07-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 110
        from public.styles where style_key = '040|T3-A-F027-07-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 110
        from public.styles where style_key = '040|T3-A-F027-07-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 110
        from public.styles where style_key = '040|T3-A-F027-07-26|Womens'
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
        '040|SK2-A-F023-02-26|Womens', 'SK2-A-F023-02-26',
        (select id from public.costume_orders where order_number = '040'),
        '040', 'Cheri Cheri Lady', 'Wrap Skirt', 'Womens',
        'Female', 'Girls', 'A', null,
        'F023-02',
        (select id from public.materials where material_code = 'F023-02'),
        'Yes', null, null,
        'Styles', 111, 'SOURCE: Product Development Tracking row 192'
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
          'Styles', 111
        from public.styles where style_key = '040|SK2-A-F023-02-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 111
        from public.styles where style_key = '040|SK2-A-F023-02-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 111
        from public.styles where style_key = '040|SK2-A-F023-02-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 111
        from public.styles where style_key = '040|SK2-A-F023-02-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 111
        from public.styles where style_key = '040|SK2-A-F023-02-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 111
        from public.styles where style_key = '040|SK2-A-F023-02-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 111
        from public.styles where style_key = '040|SK2-A-F023-02-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 111
        from public.styles where style_key = '040|SK2-A-F023-02-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 111
        from public.styles where style_key = '040|SK2-A-F023-02-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 111
        from public.styles where style_key = '040|SK2-A-F023-02-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
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
          'Styles', 111
        from public.styles where style_key = '040|SK2-A-F023-02-26|Womens'
        on conflict (style_id, stage_name) do update set
          cell_text = excluded.cell_text,
          interpreted_on = excluded.interpreted_on,
          interpreted_yes = excluded.interpreted_yes,
          check_text = excluded.check_text,
          check_yes = excluded.check_yes,
          source_row = excluded.source_row;
