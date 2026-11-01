-- New enum value only. Postgres cannot use a new enum label until this
-- migration commits, so the rest of the director work is the next file.

alter type public.app_role add value if not exists 'program_director';
