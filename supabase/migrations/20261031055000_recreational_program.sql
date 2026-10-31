-- Fourth program. No director is linked yet.

insert into public.programs (name)
values ('Recreational')
on conflict (name) do nothing;
