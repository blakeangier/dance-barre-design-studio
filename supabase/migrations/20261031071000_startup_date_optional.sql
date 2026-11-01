-- A startup estimate, such as a renovation, may not have a date yet.
-- occurred_on stays blank instead of a made-up day. 20261031070000 is already
-- written, so this is a new migration.

alter table public.startup_costs
  alter column occurred_on drop not null;

comment on column public.startup_costs.occurred_on is
  'Blank when the date is unknown. The amount still counts in the startup total.';
