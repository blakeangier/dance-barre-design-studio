-- Trims and notions share the materials ledger. Existing rows stay fabric
-- measured in metres. qty_m on the ledger is the quantity in this unit.

alter table public.materials
  add column material_kind text not null default 'fabric',
  add column unit_kind text not null default 'metres';

alter table public.materials
  add constraint materials_kind_check check (
    material_kind in (
      'fabric',
      'elastic',
      'thread',
      'label',
      'binding',
      'zipper_closure',
      'embellishment',
      'other'
    )
  ),
  add constraint materials_unit_check check (
    unit_kind in ('metres', 'units', 'spools', 'pieces')
  );

comment on column public.materials.material_kind is
  'Fabric or a trim/notion. Trims can be BOM lines and use the same stock ledger.';

comment on column public.materials.unit_kind is
  'How quantities on this material are counted. The ledger column qty_m stores that unit.';
