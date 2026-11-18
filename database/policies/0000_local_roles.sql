-- SOLO DESARROLLO LOCAL: crea los roles que Supabase ya trae (anon, authenticated)
-- para poder probar la denegación por defecto. En Supabase este archivo no hace nada.
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin;
  end if;
end $$;
grant usage on schema public to anon, authenticated;
