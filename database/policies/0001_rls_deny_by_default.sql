-- FERROLAB — RLS: denegación por defecto (doc 05 §14.4, SEC-05).
-- Flutter NO lee Supabase directamente: toda lectura pública pasa por FastAPI,
-- que se conecta con el rol propietario. Los roles `anon` y `authenticated`
-- (creados por Supabase; en local por 0000_local_roles.sql) no tienen acceso.

do $$
declare t text;
begin
  foreach t in array array[
    'sources','materials','treatments','scientific_evidence','material_compositions','initial_conditions',
    'protocols','material_treatments','physical_guards','models','model_versions','micrographs',
    'micrograph_annotations','media_license_reviews','knowledge_entries','practice_questions','diagram_sets',
    'diagram_curves','dataset_releases','admin_memberships','audit_log','simulations','simulation_results',
    'result_components','result_evidence','app_events','schema_migrations']
  loop
    execute format('alter table %I enable row level security', t);
    -- Sin políticas => nadie salvo el propietario/bypassrls ve filas.
    if exists (select 1 from pg_roles where rolname = 'anon') then
      execute format('revoke all on table %I from anon', t);
    end if;
    if exists (select 1 from pg_roles where rolname = 'authenticated') then
      execute format('revoke all on table %I from authenticated', t);
    end if;
    execute format('revoke all on table %I from public', t);
  end loop;
end $$;

-- Secuencias tampoco accesibles para roles públicos.
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    execute 'revoke all on all sequences in schema public from anon';
  end if;
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    execute 'revoke all on all sequences in schema public from authenticated';
  end if;
end $$;
