-- 01_suppliers.sql
-- Idempotent import from the 2026-10-30 tracker export.
-- Run after the inventory migration. Safe to run again.

insert into public.suppliers (
        supplier_code, name, website, lead_time_days, lead_time_raw,
        minimum_order, volume_discount, notes, needs_data,
        source_tab, source_row, source_label
      ) values (
        'SUP-TELIO', 'Telio', 'www.telio.com',
        null, null,
        null, '10% off at 100m+ (registry notes). Order Form says "-10% for 110m+"', 'Showroom hours M–F 9–5, closed 12–1 daily. Account # and log-in left blank in source.', 'Account #; Lead time; Minimum order',
        'Suppliers', 4, 'SOURCE: Fabric Registry (Sept 13, 2026) Suppliers row 3'
      )
      on conflict (supplier_code) do update set
        name = excluded.name,
        website = excluded.website,
        lead_time_days = excluded.lead_time_days,
        lead_time_raw = excluded.lead_time_raw,
        minimum_order = excluded.minimum_order,
        volume_discount = excluded.volume_discount,
        notes = excluded.notes,
        needs_data = excluded.needs_data,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;

insert into public.supplier_contacts (
        supplier_id, contact_name, email, phone, address, account_number
      )
      select id, 'Toronto Showroom – Sarah Haunts', 'toronto@telio.com', '416 532 9444',
        '219 Dufferin St. Suite 106A, Toronto, ON M6K 1Y9', null
      from public.suppliers where supplier_code = 'SUP-TELIO'
      on conflict (supplier_id) do update set
        contact_name = excluded.contact_name,
        email = excluded.email,
        phone = excluded.phone,
        address = excluded.address,
        account_number = excluded.account_number;

insert into public.suppliers (
        supplier_code, name, website, lead_time_days, lead_time_raw,
        minimum_order, volume_discount, notes, needs_data,
        source_tab, source_row, source_label
      ) values (
        'SUP-PRITCHARD', 'Pritchard Paper Products', null,
        null, null,
        null, null, 'Listed in registry Suppliers tab with no details (likely pattern/marker paper).', 'All contact details; what is purchased',
        'Suppliers', 5, 'SOURCE: Fabric Registry (Sept 13, 2026) Suppliers row 11'
      )
      on conflict (supplier_code) do update set
        name = excluded.name,
        website = excluded.website,
        lead_time_days = excluded.lead_time_days,
        lead_time_raw = excluded.lead_time_raw,
        minimum_order = excluded.minimum_order,
        volume_discount = excluded.volume_discount,
        notes = excluded.notes,
        needs_data = excluded.needs_data,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;

insert into public.supplier_contacts (
        supplier_id, contact_name, email, phone, address, account_number
      )
      select id, null, null, null,
        null, null
      from public.suppliers where supplier_code = 'SUP-PRITCHARD'
      on conflict (supplier_id) do update set
        contact_name = excluded.contact_name,
        email = excluded.email,
        phone = excluded.phone,
        address = excluded.address,
        account_number = excluded.account_number;

insert into public.suppliers (
        supplier_code, name, website, lead_time_days, lead_time_raw,
        minimum_order, volume_discount, notes, needs_data,
        source_tab, source_row, source_label
      ) values (
        'SUP-ANNS', 'Ann''s Fabric Shop', null,
        null, null,
        null, null, 'Written as "Ann''s", "Ann''s Fabric Shop", "Ann''s Fabrics" in the source. Invoice 36719 (2026-07-29).', 'Email, phone, address, lead time, minimums',
        'Suppliers', 6, 'SOURCE: Fabric Registry (Sept 13, 2026) Inventory + Purchases rows 52-57'
      )
      on conflict (supplier_code) do update set
        name = excluded.name,
        website = excluded.website,
        lead_time_days = excluded.lead_time_days,
        lead_time_raw = excluded.lead_time_raw,
        minimum_order = excluded.minimum_order,
        volume_discount = excluded.volume_discount,
        notes = excluded.notes,
        needs_data = excluded.needs_data,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;

insert into public.supplier_contacts (
        supplier_id, contact_name, email, phone, address, account_number
      )
      select id, 'Melissa', null, null,
        null, null
      from public.suppliers where supplier_code = 'SUP-ANNS'
      on conflict (supplier_id) do update set
        contact_name = excluded.contact_name,
        email = excluded.email,
        phone = excluded.phone,
        address = excluded.address,
        account_number = excluded.account_number;

insert into public.suppliers (
        supplier_code, name, website, lead_time_days, lead_time_raw,
        minimum_order, volume_discount, notes, needs_data,
        source_tab, source_row, source_label
      ) values (
        'SUP-ROSEEDEE', 'Rose E Dee', null,
        null, null,
        null, null, 'Order emailed Sept 4, 2026.', 'Email, phone, address, lead time, minimums',
        'Suppliers', 7, 'SOURCE: Fabric Registry (Sept 13, 2026) Inventory + Purchases rows 60-64'
      )
      on conflict (supplier_code) do update set
        name = excluded.name,
        website = excluded.website,
        lead_time_days = excluded.lead_time_days,
        lead_time_raw = excluded.lead_time_raw,
        minimum_order = excluded.minimum_order,
        volume_discount = excluded.volume_discount,
        notes = excluded.notes,
        needs_data = excluded.needs_data,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;

insert into public.supplier_contacts (
        supplier_id, contact_name, email, phone, address, account_number
      )
      select id, 'Maria', null, null,
        null, null
      from public.suppliers where supplier_code = 'SUP-ROSEEDEE'
      on conflict (supplier_id) do update set
        contact_name = excluded.contact_name,
        email = excluded.email,
        phone = excluded.phone,
        address = excluded.address,
        account_number = excluded.account_number;

insert into public.suppliers (
        supplier_code, name, website, lead_time_days, lead_time_raw,
        minimum_order, volume_discount, notes, needs_data,
        source_tab, source_row, source_label
      ) values (
        'SUP-FL', 'F.L.', null,
        null, null,
        null, null, 'Abbreviation only (F037 Red Satin).', 'Full name and all details',
        'Suppliers', 8, 'SOURCE: Fabric Registry (Sept 13, 2026) Inventory row 110'
      )
      on conflict (supplier_code) do update set
        name = excluded.name,
        website = excluded.website,
        lead_time_days = excluded.lead_time_days,
        lead_time_raw = excluded.lead_time_raw,
        minimum_order = excluded.minimum_order,
        volume_discount = excluded.volume_discount,
        notes = excluded.notes,
        needs_data = excluded.needs_data,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row,
        source_label = excluded.source_label;

insert into public.supplier_contacts (
        supplier_id, contact_name, email, phone, address, account_number
      )
      select id, null, null, null,
        null, null
      from public.suppliers where supplier_code = 'SUP-FL'
      on conflict (supplier_id) do update set
        contact_name = excluded.contact_name,
        email = excluded.email,
        phone = excluded.phone,
        address = excluded.address,
        account_number = excluded.account_number;
