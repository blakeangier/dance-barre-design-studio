-- 02_materials_part03.sql
-- Idempotent import from the 2026-10-30 tracker export.
-- Run after the inventory migration. Safe to run again.

insert into public.material_costs (
        material_id, list_price_per_m, list_price_raw, discount_entered, discount_raw,
        net_price_per_m, net_price_raw, source_tab, source_row
      )
      select id, 13.5, '13.5', null, null,
        13.5, '13.5', 'Materials', 94
      from public.materials where material_code = 'F037'
      on conflict (material_id) do update set
        list_price_per_m = excluded.list_price_per_m,
        list_price_raw = excluded.list_price_raw,
        discount_entered = excluded.discount_entered,
        discount_raw = excluded.discount_raw,
        net_price_per_m = excluded.net_price_per_m,
        net_price_raw = excluded.net_price_raw,
        source_tab = excluded.source_tab,
        source_row = excluded.source_row;
