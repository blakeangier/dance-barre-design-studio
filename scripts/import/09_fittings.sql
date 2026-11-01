-- 09_fittings.sql
-- Idempotent import from the 2026-10-30 tracker export.
-- Run after the inventory migration. Safe to run again.

insert into public.fittings (
        fitting_code, order_id, order_number_raw, style_id, style_key_raw, sample_label,
        garment, version_label, size_label, pattern_status, sample_complete, fit_test_raw,
        corrections_required, corrections_complete, approval_status, approved_by,
        approval_raw, comments, source_tab, source_row, source_label
      ) values (
        'FIT001',
        (select id from public.costume_orders where order_number = '005'),
        '005',
        (select id from public.styles where style_key = '005|L7-C-F001-06-26|Girls'),
        '005|L7-C-F001-06-26|Girls', '1.0', 'Leo', 'Girls',
        'M/C', 'Basic block', null, null,
        null, null, 'Not Started', null,
        null, null, 'Fittings', 4, 'SOURCE: Order 005 sheet (Sample & Prototype row 5); Style Key matched by garment, version and size (M/C = child, M/A = adult)'
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
        source_label = excluded.source_label;

insert into public.fittings (
        fitting_code, order_id, order_number_raw, style_id, style_key_raw, sample_label,
        garment, version_label, size_label, pattern_status, sample_complete, fit_test_raw,
        corrections_required, corrections_complete, approval_status, approved_by,
        approval_raw, comments, source_tab, source_row, source_label
      ) values (
        'FIT002',
        (select id from public.costume_orders where order_number = '005'),
        '005',
        (select id from public.styles where style_key = '005|L7-C-F001-06-26|Boys'),
        '005|L7-C-F001-06-26|Boys', '1.0', 'Leo', 'Boys',
        'M/C', 'Basic block / higher scoop', null, null,
        null, null, 'Not Started', null,
        null, null, 'Fittings', 5, 'SOURCE: Order 005 sheet (Sample & Prototype row 6); Style Key matched by garment, version and size (M/C = child, M/A = adult)'
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
        source_label = excluded.source_label;

insert into public.fittings (
        fitting_code, order_id, order_number_raw, style_id, style_key_raw, sample_label,
        garment, version_label, size_label, pattern_status, sample_complete, fit_test_raw,
        corrections_required, corrections_complete, approval_status, approved_by,
        approval_raw, comments, source_tab, source_row, source_label
      ) values (
        'FIT003',
        (select id from public.costume_orders where order_number = '005'),
        '005',
        (select id from public.styles where style_key = '005|P6-C-F001-06-26|Girls'),
        '005|P6-C-F001-06-26|Girls', '1.0', 'Pant', 'Girls',
        'M/C', 'Basic block', null, null,
        null, null, 'Not Started', null,
        null, null, 'Fittings', 6, 'SOURCE: Order 005 sheet (Sample & Prototype row 7); Style Key matched by garment, version and size (M/C = child, M/A = adult)'
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
        source_label = excluded.source_label;

insert into public.fittings (
        fitting_code, order_id, order_number_raw, style_id, style_key_raw, sample_label,
        garment, version_label, size_label, pattern_status, sample_complete, fit_test_raw,
        corrections_required, corrections_complete, approval_status, approved_by,
        approval_raw, comments, source_tab, source_row, source_label
      ) values (
        'FIT004',
        (select id from public.costume_orders where order_number = '005'),
        '005',
        (select id from public.styles where style_key = '005|P9-C-F001-06-26|Boys'),
        '005|P9-C-F001-06-26|Boys', '1.0', 'Pant', 'Boys',
        'M/C', 'Basic block', null, null,
        null, null, 'Not Started', null,
        null, null, 'Fittings', 7, 'SOURCE: Order 005 sheet (Sample & Prototype row 8); Style Key matched by garment, version and size (M/C = child, M/A = adult)'
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
        source_label = excluded.source_label;

insert into public.fittings (
        fitting_code, order_id, order_number_raw, style_id, style_key_raw, sample_label,
        garment, version_label, size_label, pattern_status, sample_complete, fit_test_raw,
        corrections_required, corrections_complete, approval_status, approved_by,
        approval_raw, comments, source_tab, source_row, source_label
      ) values (
        'FIT005',
        (select id from public.costume_orders where order_number = '005'),
        '005',
        (select id from public.styles where style_key = '005|L6-A-F001-06-26|Women''s'),
        '005|L6-A-F001-06-26|Women''s', '2.0', 'Leo', 'Girls',
        'M/A', 'Basic block', null, null,
        null, null, 'Not Started', null,
        null, null, 'Fittings', 8, 'SOURCE: Order 005 sheet (Sample & Prototype row 9); Style Key matched by garment, version and size (M/C = child, M/A = adult)'
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
        source_label = excluded.source_label;

insert into public.fittings (
        fitting_code, order_id, order_number_raw, style_id, style_key_raw, sample_label,
        garment, version_label, size_label, pattern_status, sample_complete, fit_test_raw,
        corrections_required, corrections_complete, approval_status, approved_by,
        approval_raw, comments, source_tab, source_row, source_label
      ) values (
        'FIT006',
        (select id from public.costume_orders where order_number = '005'),
        '005',
        (select id from public.styles where style_key = '005|L9-A-F001-06-26|Men''s'),
        '005|L9-A-F001-06-26|Men''s', '2.0', 'Leo', 'Boys',
        'M/A', 'Basic block / higher scoop', null, null,
        null, null, 'Not Started', null,
        null, null, 'Fittings', 9, 'SOURCE: Order 005 sheet (Sample & Prototype row 10); Style Key matched by garment, version and size (M/C = child, M/A = adult)'
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
        source_label = excluded.source_label;

insert into public.fittings (
        fitting_code, order_id, order_number_raw, style_id, style_key_raw, sample_label,
        garment, version_label, size_label, pattern_status, sample_complete, fit_test_raw,
        corrections_required, corrections_complete, approval_status, approved_by,
        approval_raw, comments, source_tab, source_row, source_label
      ) values (
        'FIT007',
        (select id from public.costume_orders where order_number = '005'),
        '005',
        (select id from public.styles where style_key = '005|P7-A-F001-06-26|Women''s'),
        '005|P7-A-F001-06-26|Women''s', '2.0', 'Pant', 'Girls',
        'M/A', 'Basic block', null, null,
        null, null, 'Not Started', null,
        null, null, 'Fittings', 10, 'SOURCE: Order 005 sheet (Sample & Prototype row 11); Style Key matched by garment, version and size (M/C = child, M/A = adult)'
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
        source_label = excluded.source_label;

insert into public.fittings (
        fitting_code, order_id, order_number_raw, style_id, style_key_raw, sample_label,
        garment, version_label, size_label, pattern_status, sample_complete, fit_test_raw,
        corrections_required, corrections_complete, approval_status, approved_by,
        approval_raw, comments, source_tab, source_row, source_label
      ) values (
        'FIT008',
        (select id from public.costume_orders where order_number = '005'),
        '005',
        (select id from public.styles where style_key = '005|P9-A-F001-06-26|Men''s'),
        '005|P9-A-F001-06-26|Men''s', '2.0', 'Pant', 'Boys',
        'M/A', 'Basic block', null, null,
        null, null, 'Not Started', null,
        null, null, 'Fittings', 11, 'SOURCE: Order 005 sheet (Sample & Prototype row 12); Style Key matched by garment, version and size (M/C = child, M/A = adult)'
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
        source_label = excluded.source_label;

insert into public.fitting_checks (
          order_id, order_number_raw, check_name, required_text, completed_text,
          check_date_raw, approved_by, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Fit / measurements', 'Yes', null,
          null, null, null,
          'Fittings', 71, 'SOURCE: Order 005 sheet (Sample & Prototype row 17)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, check_name) do update set
          order_id = excluded.order_id,
          required_text = excluded.required_text,
          completed_text = excluded.completed_text,
          check_date_raw = excluded.check_date_raw,
          approved_by = excluded.approved_by,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.fitting_checks (
          order_id, order_number_raw, check_name, required_text, completed_text,
          check_date_raw, approved_by, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Neckline / armhole', 'Yes', null,
          null, null, null,
          'Fittings', 72, 'SOURCE: Order 005 sheet (Sample & Prototype row 18)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, check_name) do update set
          order_id = excluded.order_id,
          required_text = excluded.required_text,
          completed_text = excluded.completed_text,
          check_date_raw = excluded.check_date_raw,
          approved_by = excluded.approved_by,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.fitting_checks (
          order_id, order_number_raw, check_name, required_text, completed_text,
          check_date_raw, approved_by, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Leg / pant fit', 'Yes', null,
          null, null, null,
          'Fittings', 73, 'SOURCE: Order 005 sheet (Sample & Prototype row 19)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, check_name) do update set
          order_id = excluded.order_id,
          required_text = excluded.required_text,
          completed_text = excluded.completed_text,
          check_date_raw = excluded.check_date_raw,
          approved_by = excluded.approved_by,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.fitting_checks (
          order_id, order_number_raw, check_name, required_text, completed_text,
          check_date_raw, approved_by, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Fabric colour placement', 'Yes', null,
          null, null, null,
          'Fittings', 74, 'SOURCE: Order 005 sheet (Sample & Prototype row 20)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, check_name) do update set
          order_id = excluded.order_id,
          required_text = excluded.required_text,
          completed_text = excluded.completed_text,
          check_date_raw = excluded.check_date_raw,
          approved_by = excluded.approved_by,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.fitting_checks (
          order_id, order_number_raw, check_name, required_text, completed_text,
          check_date_raw, approved_by, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Seam / construction', 'Yes', null,
          null, null, null,
          'Fittings', 75, 'SOURCE: Order 005 sheet (Sample & Prototype row 21)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, check_name) do update set
          order_id = excluded.order_id,
          required_text = excluded.required_text,
          completed_text = excluded.completed_text,
          check_date_raw = excluded.check_date_raw,
          approved_by = excluded.approved_by,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.fitting_checks (
          order_id, order_number_raw, check_name, required_text, completed_text,
          check_date_raw, approved_by, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Stretch / recovery', 'Yes', null,
          null, null, null,
          'Fittings', 76, 'SOURCE: Order 005 sheet (Sample & Prototype row 22)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, check_name) do update set
          order_id = excluded.order_id,
          required_text = excluded.required_text,
          completed_text = excluded.completed_text,
          check_date_raw = excluded.check_date_raw,
          approved_by = excluded.approved_by,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.fitting_checks (
          order_id, order_number_raw, check_name, required_text, completed_text,
          check_date_raw, approved_by, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Final appearance', 'Yes', null,
          null, null, null,
          'Fittings', 77, 'SOURCE: Order 005 sheet (Sample & Prototype row 23)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, check_name) do update set
          order_id = excluded.order_id,
          required_text = excluded.required_text,
          completed_text = excluded.completed_text,
          check_date_raw = excluded.check_date_raw,
          approved_by = excluded.approved_by,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.fitting_checks (
          order_id, order_number_raw, check_name, required_text, completed_text,
          check_date_raw, approved_by, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Client / production approval', 'Yes', null,
          null, null, null,
          'Fittings', 78, 'SOURCE: Order 005 sheet (Sample & Prototype row 24)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, check_name) do update set
          order_id = excluded.order_id,
          required_text = excluded.required_text,
          completed_text = excluded.completed_text,
          check_date_raw = excluded.check_date_raw,
          approved_by = excluded.approved_by,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Sample 1 complete', null, null,
          'Pattern / Sample', 'Not Started', null, null,
          'Fittings', 101, 'SOURCE: Order 005 sheet (Production Overview row 29)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Fit test complete', null, null,
          'Production', 'Not Started', null, null,
          'Fittings', 102, 'SOURCE: Order 005 sheet (Production Overview row 30)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Prototype corrections complete', null, null,
          'Pattern / Sample', 'Not Started', null, null,
          'Fittings', 103, 'SOURCE: Order 005 sheet (Production Overview row 31)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Prototype approved', null, null,
          'Elaine / Client', 'Not Started', null, null,
          'Fittings', 104, 'SOURCE: Order 005 sheet (Production Overview row 32)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Final pattern locked', null, null,
          'Pattern Maker', 'Not Started', null, null,
          'Fittings', 105, 'SOURCE: Order 005 sheet (Production Overview row 33)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Grading completed', null, null,
          'Pattern Maker', 'Not Started', null, null,
          'Fittings', 106, 'SOURCE: Order 005 sheet (Production Overview row 34)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Marker / cut plan approved', null, null,
          'Cutting', 'Not Started', null, null,
          'Fittings', 107, 'SOURCE: Order 005 sheet (Production Overview row 35)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Fabric received / inspected', null, null,
          'Production', 'Not Started', null, null,
          'Fittings', 108, 'SOURCE: Order 005 sheet (Production Overview row 36)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Cutting complete', null, null,
          'Cutting', 'Not Started', null, null,
          'Fittings', 109, 'SOURCE: Order 005 sheet (Production Overview row 37)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Sewing complete', null, null,
          'Sewing', 'Not Started', null, null,
          'Fittings', 110, 'SOURCE: Order 005 sheet (Production Overview row 38)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Final QC / finishing complete', null, null,
          'Production', 'Not Started', null, null,
          'Fittings', 111, 'SOURCE: Order 005 sheet (Production Overview row 39)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;

insert into public.production_gates (
          order_id, order_number_raw, gate_name, target_raw, completed_raw, owner_name,
          status_raw, approval_raw, notes, source_tab, source_row, source_label
        )
        select id, '005', 'Ready for fittings', null, null,
          'Production', 'Not Started', null, null,
          'Fittings', 112, 'SOURCE: Order 005 sheet (Production Overview row 40)'
        from public.costume_orders where order_number = '005'
        on conflict (order_number_raw, gate_name) do update set
          order_id = excluded.order_id,
          target_raw = excluded.target_raw,
          completed_raw = excluded.completed_raw,
          owner_name = excluded.owner_name,
          status_raw = excluded.status_raw,
          approval_raw = excluded.approval_raw,
          notes = excluded.notes,
          source_row = excluded.source_row,
          source_label = excluded.source_label;
