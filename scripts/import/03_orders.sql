-- 03_orders.sql
-- Idempotent import from the 2026-10-30 tracker export.
-- Run after the inventory migration. Safe to run again.

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '001', 'Sing Sing Sing', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 4, 'SOURCE: Product Development Tracking row 4'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '001'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '002', 'Can''t Turn You Loose', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 5, 'SOURCE: Product Development Tracking row 14'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '002'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '003', 'Yellow Brick Road', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 6, 'SOURCE: Product Development Tracking row 19'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '003'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '004', 'Sunglasses At Night', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 7, 'SOURCE: Product Development Tracking row 34'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '004'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '005', 'Boom Boom Pow', null, null,
        '2026-07-16', '2026-07-16 00:00:00', 'End Nov. 2026', 'Iridescent shrug – custom ordered, purchased (purchaser Lindsay, July 31, 2026)',
        64, '64.0', 4, '4.0',
        null,
        'Orders', 8, 'SOURCE: Order 005 sheet (Production Overview) + Order 005 Order Form + Product Development Tracking row 41'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, 'Lindsay / Malika', 'Lindsay: dancebarredirectors@dancebarre.ca; Malika: elitedancebarre@gmail.com',
        125, '125.0',
        35, '35.0',
        69, '69.0',
        'Budget $125 incl. accessory; total cost covers cut & sew and finishing. Accessory qty purchased 69 vs 68 units. Studio email designstudio.dancebarre@gmail.com. Notions: elastic.'
      from public.costume_orders where order_number = '005'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '006', 'This Love', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 9, 'SOURCE: Product Development Tracking row 50'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '006'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '007', 'Unspeakable Joy', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 10, 'SOURCE: Product Development Tracking row 58'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '007'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '008', 'Boot, Scooting Babies', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 11, 'SOURCE: Product Development Tracking row 65'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '008'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '009', 'Before Spring Ends', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 12, 'SOURCE: Product Development Tracking row 69'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '009'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '010', 'When You Come Back', 'cancelled', 'cancelled',
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 13, 'SOURCE: Product Development Tracking row 73'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '010'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '011', 'Shape of Water', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 14, 'SOURCE: Product Development Tracking row 77'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '011'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '012', 'A Glorious Feeling', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 15, 'SOURCE: Product Development Tracking row 82'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '012'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '013', 'Ballet-Sailed', null, null,
        null, null, null, null,
        null, null, null, null,
        'Marked * in tracking file (meaning not stated)',
        'Orders', 16, 'SOURCE: Product Development Tracking row 86'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '013'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '014', 'No Surprises', null, null,
        null, null, null, null,
        null, null, null, null,
        'Marked * in tracking file (meaning not stated)',
        'Orders', 17, 'SOURCE: Product Development Tracking row 90'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '014'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '015', 'Wang Dang', null, null,
        null, null, null, null,
        null, null, null, null,
        'Marked * in tracking file (meaning not stated)',
        'Orders', 18, 'SOURCE: Product Development Tracking row 94'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '015'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '016', 'I Thought I Was Different', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 19, 'SOURCE: Product Development Tracking row 98'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '016'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '017', 'Valerie', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 20, 'SOURCE: Product Development Tracking row 105'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '017'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '018', 'Here I Am', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 21, 'SOURCE: Product Development Tracking row 110'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '018'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '019', 'Mr. Cellophane', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 22, 'SOURCE: Product Development Tracking row 113'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '019'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '020', 'Out Of Body', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 23, 'SOURCE: Product Development Tracking row 116'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '020'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '021', 'Open Hands', null, null,
        null, null, null, null,
        null, null, null, null,
        'Order # missing in source; inferred from sequence',
        'Orders', 24, 'SOURCE: Product Development Tracking row'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '021'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '022', 'Rhythm of the Night', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 25, 'SOURCE: Product Development Tracking row 124'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '022'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '023', 'Night Changes', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 26, 'SOURCE: Product Development Tracking row 129'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '023'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '024', 'Hung Up', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 27, 'SOURCE: Product Development Tracking row 133'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '024'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '025', 'After All', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 28, 'SOURCE: Product Development Tracking row 137'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '025'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '026', 'Great Escape', 'cancelled', 'cancelled',
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 29, 'SOURCE: Product Development Tracking row 141'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '026'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '027', 'Public Affair', 'cancelled', 'cancelled',
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 30, 'SOURCE: Product Development Tracking row 145'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '027'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '028', 'Slipping Through My Fingers', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 31, 'SOURCE: Product Development Tracking row 148'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '028'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '029', 'Liminal', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 32, 'SOURCE: Product Development Tracking row 151'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '029'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '030', null, 'cancelled', 'Cancelled-purchasing',
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 33, 'SOURCE: Product Development Tracking row 155'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '030'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '031', 'Ya Ya Ya', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 34, 'SOURCE: Product Development Tracking row 159'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '031'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '032', null, 'cancelled', 'Cancelled-purchasing',
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 35, 'SOURCE: Product Development Tracking row 162'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '032'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '033', 'Jump, Jive & Wail', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 36, 'SOURCE: Product Development Tracking row 165'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '033'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '034', 'Freak Show on The Dance Floor', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 37, 'SOURCE: Product Development Tracking row 168'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '034'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '035', 'Hypericum', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 38, 'SOURCE: Product Development Tracking row 172'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '035'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '036', 'Funky Fonchi', 'cancelled', 'cancelled',
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 39, 'SOURCE: Product Development Tracking row 176'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '036'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '037', 'Shauneese Jazz', 'cancelled', 'cancelled',
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 40, 'SOURCE: Product Development Tracking row 179'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '037'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '038', 'Kevin Contemporary', 'cancelled', 'cancelled',
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 41, 'SOURCE: Product Development Tracking row 183'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '038'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '039', 'Penance', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 42, 'SOURCE: Product Development Tracking row 187'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '039'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;

insert into public.costume_orders (
        order_number, production_song, status, status_raw, order_date, order_date_raw,
        fitting_target_raw, accessory, female_total, female_total_raw, male_total,
        male_total_raw, notes, source_tab, source_row, source_label
      ) values (
        '040', 'Cheri Cheri Lady', null, null,
        null, null, null, null,
        null, null, null, null,
        null,
        'Orders', 43, 'SOURCE: Product Development Tracking row 191'
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
        source_label = excluded.source_label;

insert into public.order_private (
        order_id, contacts, contact_emails, budget_per_costume, budget_per_costume_raw,
        accessory_cost_each, accessory_cost_each_raw, accessory_qty, accessory_qty_raw,
        restricted_notes
      )
      select id, null, null,
        null, null,
        null, null,
        null, null,
        null
      from public.costume_orders where order_number = '040'
      on conflict (order_id) do update set
        contacts = excluded.contacts,
        contact_emails = excluded.contact_emails,
        budget_per_costume = excluded.budget_per_costume,
        budget_per_costume_raw = excluded.budget_per_costume_raw,
        accessory_cost_each = excluded.accessory_cost_each,
        accessory_cost_each_raw = excluded.accessory_cost_each_raw,
        accessory_qty = excluded.accessory_qty,
        accessory_qty_raw = excluded.accessory_qty_raw,
        restricted_notes = excluded.restricted_notes;
