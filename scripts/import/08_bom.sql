-- 08_bom.sql
-- Idempotent import from the 2026-10-30 tracker export.
-- Run after the inventory migration. Safe to run again.

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B001',
        (select id from public.styles where style_key = '005|L7-C-F001-06-26|Girls'),
        '005|L7-C-F001-06-26|Girls',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Leo', 'Girls', 'Self',
        'Both SLVs, BK of leo',
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 'Mova Flex', '06 Beige',
        0.7, '0.7', 'EST .7m per garment (Order Form)',
        null, false, null,
        'BOM', 4, 'SOURCE: Order 005 Order Form rows 50-61'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '6.95', 6.95, '6.95',
        4.865, '4.865', 19.46, '19.46'
      from public.bom_lines where line_code = 'B001'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B002',
        (select id from public.styles where style_key = '005|L7-C-F001-06-26|Girls'),
        '005|L7-C-F001-06-26|Girls',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Leo', 'Girls', 'Contrast 1',
        'FR of leo',
        null,
        'F002-125 (Order Form, Registry, Purchases) / F002-25 (Order 005 sheet: Production Overview, Cut Breakdown)', 'Thalassa Swim Knit', '125 lime green (Order Form) / 25 Lime Green (Order 005 sheet)',
        0.4, '0.4', 'EST .4m per garment (Order Form)',
        'CONFLICT: Fabric ID F002-125 vs F002-25. Material ID left blank on purpose (see Needs Review).', true, 'F002-125 and F002-25 are both named. The line is not linked to either.',
        'BOM', 5, 'SOURCE: Order 005 Order Form rows 63-73 + Order 005 sheet row 18'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '4.9', 4.9, '4.9',
        1.96, '1.96', 7.84, '7.84'
      from public.bom_lines where line_code = 'B002'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B003',
        (select id from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'),
        '005|L6-A-F001-06-26|Women''s',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Leo', 'Girls', 'Self',
        'Both SLVs, BK of leo',
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 'Mova Flex', '06 Beige',
        0.7, '0.7', 'EST .7m per garment (Order Form)',
        null, false, null,
        'BOM', 6, 'SOURCE: Order 005 Order Form rows 50-61'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '6.95', 6.95, '6.95',
        4.865, '4.865', 291.9, '291.9'
      from public.bom_lines where line_code = 'B003'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B004',
        (select id from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'),
        '005|L6-A-F001-06-26|Women''s',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Leo', 'Girls', 'Contrast 1',
        'FR of leo',
        null,
        'F002-125 (Order Form, Registry, Purchases) / F002-25 (Order 005 sheet: Production Overview, Cut Breakdown)', 'Thalassa Swim Knit', '125 lime green (Order Form) / 25 Lime Green (Order 005 sheet)',
        0.4, '0.4', 'EST .4m per garment (Order Form)',
        'CONFLICT: Fabric ID F002-125 vs F002-25. Material ID left blank on purpose (see Needs Review).', true, 'F002-125 and F002-25 are both named. The line is not linked to either.',
        'BOM', 7, 'SOURCE: Order 005 Order Form rows 63-73 + Order 005 sheet row 18'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '4.9', 4.9, '4.9',
        1.96, '1.96', 117.6, '117.6'
      from public.bom_lines where line_code = 'B004'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B005',
        (select id from public.styles where style_key = '005|L7-C-F001-06-26|Boys'),
        '005|L7-C-F001-06-26|Boys',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Leo', 'Boys', 'Self',
        'Both SLVs, BK of leo',
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 'Mova Flex', '06 Beige',
        0.7, '0.7', 'EST .7m per garment (Order Form); boys "all other details same as girls"',
        null, false, null,
        'BOM', 8, 'SOURCE: Order 005 Order Form rows 50-61, 76-79'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '6.95', 6.95, '6.95',
        4.865, '4.865', 4.865, '4.865'
      from public.bom_lines where line_code = 'B005'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B006',
        (select id from public.styles where style_key = '005|L7-C-F001-06-26|Boys'),
        '005|L7-C-F001-06-26|Boys',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Leo', 'Boys', 'Contrast 1',
        'FR of leo',
        null,
        'F002-125 (Order Form, Registry, Purchases) / F002-25 (Order 005 sheet: Production Overview, Cut Breakdown)', 'Thalassa Swim Knit', '125 lime green (Order Form) / 25 Lime Green (Order 005 sheet)',
        0.4, '0.4', 'EST .4m per garment (Order Form)',
        'CONFLICT: Fabric ID F002-125 vs F002-25. Material ID left blank on purpose (see Needs Review).', true, 'F002-125 and F002-25 are both named. The line is not linked to either.',
        'BOM', 9, 'SOURCE: Order 005 Order Form rows 63-73 + Order 005 sheet row 20'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '4.9', 4.9, '4.9',
        1.96, '1.96', 1.96, '1.96'
      from public.bom_lines where line_code = 'B006'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B007',
        (select id from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'),
        '005|L9-A-F001-06-26|Men''s',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Leo', 'Boys', 'Self',
        'Both SLVs, BK of leo',
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 'Mova Flex', '06 Beige',
        0.7, '0.7', 'EST .7m per garment (Order Form); boys "all other details same as girls"',
        null, false, null,
        'BOM', 10, 'SOURCE: Order 005 Order Form rows 50-61, 76-79'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '6.95', 6.95, '6.95',
        4.865, '4.865', 14.595, '14.595'
      from public.bom_lines where line_code = 'B007'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B008',
        (select id from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'),
        '005|L9-A-F001-06-26|Men''s',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Leo', 'Boys', 'Contrast 1',
        'FR of leo',
        null,
        'F002-125 (Order Form, Registry, Purchases) / F002-25 (Order 005 sheet: Production Overview, Cut Breakdown)', 'Thalassa Swim Knit', '125 lime green (Order Form) / 25 Lime Green (Order 005 sheet)',
        0.4, '0.4', 'EST .4m per garment (Order Form)',
        'CONFLICT: Fabric ID F002-125 vs F002-25. Material ID left blank on purpose (see Needs Review).', true, 'F002-125 and F002-25 are both named. The line is not linked to either.',
        'BOM', 11, 'SOURCE: Order 005 Order Form rows 63-73 + Order 005 sheet row 20'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '4.9', 4.9, '4.9',
        1.96, '1.96', 5.88, '5.88'
      from public.bom_lines where line_code = 'B008'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B009',
        (select id from public.styles where style_key = '005|P6-C-F001-06-26|Girls'),
        '005|P6-C-F001-06-26|Girls',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Pant', 'Girls', 'Self',
        'BK of WB, BK of legs',
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 'Mova Flex', '06 Beige',
        1, '1.0', 'EST "1m?" per garment (Order Form) – UNCONFIRMED',
        'Consumption unconfirmed ("1m?")', false, null,
        'BOM', 12, 'SOURCE: Order 005 Order Form rows 90-100'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '6.95', 6.95, '6.95',
        6.95, '6.95', 27.8, '27.8'
      from public.bom_lines where line_code = 'B009'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B010',
        (select id from public.styles where style_key = '005|P6-C-F001-06-26|Girls'),
        '005|P6-C-F001-06-26|Girls',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Pant', 'Girls', 'Contrast 1',
        'FR of WB, FR of pants',
        null,
        'F002-125 (Order Form, Registry, Purchases) / F002-25 (Order 005 sheet: Production Overview, Cut Breakdown)', 'Thalassa Swim Knit', '125 lime green (Order Form) / 25 Lime Green (Order 005 sheet)',
        1, '1.0', 'EST "1m?" per garment (Order Form) – UNCONFIRMED',
        'CONFLICT: Fabric ID F002-125 vs F002-25; consumption unconfirmed ("1m?")', true, 'F002-125 and F002-25 are both named. The line is not linked to either.',
        'BOM', 13, 'SOURCE: Order 005 Order Form rows 103-113 + Order 005 sheet row 22'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '4.9', 4.9, '4.9',
        4.9, '4.9', 19.6, '19.6'
      from public.bom_lines where line_code = 'B010'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B011',
        (select id from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'),
        '005|P7-A-F001-06-26|Women''s',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Pant', 'Girls', 'Self',
        'BK of WB, BK of legs',
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 'Mova Flex', '06 Beige',
        1, '1.0', 'EST "1m?" per garment (Order Form) – UNCONFIRMED',
        'Consumption unconfirmed ("1m?")', false, null,
        'BOM', 14, 'SOURCE: Order 005 Order Form rows 90-100'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '6.95', 6.95, '6.95',
        6.95, '6.95', 417, '417'
      from public.bom_lines where line_code = 'B011'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B012',
        (select id from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'),
        '005|P7-A-F001-06-26|Women''s',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Pant', 'Girls', 'Contrast 1',
        'FR of WB, FR of pants',
        null,
        'F002-125 (Order Form, Registry, Purchases) / F002-25 (Order 005 sheet: Production Overview, Cut Breakdown)', 'Thalassa Swim Knit', '125 lime green (Order Form) / 25 Lime Green (Order 005 sheet)',
        1, '1.0', 'EST "1m?" per garment (Order Form) – UNCONFIRMED',
        'CONFLICT: Fabric ID F002-125 vs F002-25; consumption unconfirmed ("1m?")', true, 'F002-125 and F002-25 are both named. The line is not linked to either.',
        'BOM', 15, 'SOURCE: Order 005 Order Form rows 103-113 + Order 005 sheet row 22'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '4.9', 4.9, '4.9',
        4.9, '4.9', 294, '294'
      from public.bom_lines where line_code = 'B012'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B013',
        (select id from public.styles where style_key = '005|P9-C-F001-06-26|Boys'),
        '005|P9-C-F001-06-26|Boys',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Pant', 'Boys', 'Self',
        'BK of WB, BK of legs',
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 'Mova Flex', '06 Beige',
        1, '1.0', 'EST "1m?" per garment (Order Form) – UNCONFIRMED',
        'Consumption unconfirmed ("1m?")', false, null,
        'BOM', 16, 'SOURCE: Order 005 Order Form rows 90-100'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '6.95', 6.95, '6.95',
        6.95, '6.95', 6.95, '6.95'
      from public.bom_lines where line_code = 'B013'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B014',
        (select id from public.styles where style_key = '005|P9-C-F001-06-26|Boys'),
        '005|P9-C-F001-06-26|Boys',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Pant', 'Boys', 'Contrast 1',
        'FR of WB, FR of pants',
        null,
        'F002-125 (Order Form, Registry, Purchases) / F002-25 (Order 005 sheet: Production Overview, Cut Breakdown)', 'Thalassa Swim Knit', '125 lime green (Order Form) / 25 Lime Green (Order 005 sheet)',
        1, '1.0', 'EST "1m?" per garment (Order Form) – UNCONFIRMED',
        'CONFLICT: Fabric ID F002-125 vs F002-25; consumption unconfirmed ("1m?")', true, 'F002-125 and F002-25 are both named. The line is not linked to either.',
        'BOM', 17, 'SOURCE: Order 005 Order Form rows 103-113 + Order 005 sheet row 24'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '4.9', 4.9, '4.9',
        4.9, '4.9', 4.9, '4.9'
      from public.bom_lines where line_code = 'B014'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B015',
        (select id from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'),
        '005|P9-A-F001-06-26|Men''s',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Pant', 'Boys', 'Self',
        'BK of WB, BK of legs',
        (select id from public.materials where material_code = 'F001-06'),
        'F001-06', 'Mova Flex', '06 Beige',
        1, '1.0', 'EST "1m?" per garment (Order Form) – UNCONFIRMED',
        'Consumption unconfirmed ("1m?")', false, null,
        'BOM', 18, 'SOURCE: Order 005 Order Form rows 90-100'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '6.95', 6.95, '6.95',
        6.95, '6.95', 20.85, '20.85'
      from public.bom_lines where line_code = 'B015'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;

insert into public.bom_lines (
        line_code, style_id, style_key_raw, order_id, order_number_raw, garment,
        version_label, component, placement, material_id, fabric_as_written,
        fabric_name, colour, consumption_per_unit_m, consumption_raw, consumption_basis,
        flag, needs_review, needs_review_reason, source_tab, source_row, source_label
      ) values (
        'B016',
        (select id from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'),
        '005|P9-A-F001-06-26|Men''s',
        (select id from public.costume_orders where order_number = '005'),
        '005', 'Pant', 'Boys', 'Contrast 1',
        'FR of WB, FR of pants',
        null,
        'F002-125 (Order Form, Registry, Purchases) / F002-25 (Order 005 sheet: Production Overview, Cut Breakdown)', 'Thalassa Swim Knit', '125 lime green (Order Form) / 25 Lime Green (Order 005 sheet)',
        1, '1.0', 'EST "1m?" per garment (Order Form) – UNCONFIRMED',
        'CONFLICT: Fabric ID F002-125 vs F002-25; consumption unconfirmed ("1m?")', true, 'F002-125 and F002-25 are both named. The line is not linked to either.',
        'BOM', 19, 'SOURCE: Order 005 Order Form rows 103-113 + Order 005 sheet row 24'
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
        source_label = excluded.source_label;

insert into public.bom_costs (
        bom_line_id, price_per_m_source, price_per_m_used, price_per_m_used_raw,
        cost_per_unit, cost_per_unit_raw, total_cost, total_cost_raw
      )
      select id, '4.9', 4.9, '4.9',
        4.9, '4.9', 14.7, '14.7'
      from public.bom_lines where line_code = 'B016'
      on conflict (bom_line_id) do update set
        price_per_m_source = excluded.price_per_m_source,
        price_per_m_used = excluded.price_per_m_used,
        price_per_m_used_raw = excluded.price_per_m_used_raw,
        cost_per_unit = excluded.cost_per_unit,
        cost_per_unit_raw = excluded.cost_per_unit_raw,
        total_cost = excluded.total_cost,
        total_cost_raw = excluded.total_cost_raw;
