-- FERROLAB 0003 — Biblioteca de protocolos versionada (decisión D-30).
-- 1) Varias variantes por par material–tratamiento: la unicidad pasa a (material, tratamiento, variante, versión).
-- 2) Registro explícito de revisiones científicas (quién cambió el estado de revisión de qué, y por qué).
-- 3) Columnas de consulta para la biblioteca (el contenido completo sigue en body jsonb, validado por el FSE).

alter table protocols drop constraint if exists protocols_material_id_treatment_id_version_key;
alter table protocols add column if not exists variant_code text;
alter table protocols add column if not exists is_reference boolean not null default false;
alter table protocols add column if not exists evidence_status text not null default 'pending_research'
  check (evidence_status in ('source_verified','source_unverified','pending_research'));
create unique index if not exists uq_protocol_variant_version
  on protocols (material_id, treatment_id, coalesce(variant_code, id), version);
-- A lo sumo un protocolo de referencia vigente por par.
create unique index if not exists uq_protocol_reference
  on protocols (material_id, treatment_id) where is_reference and review_status <> 'retired';

create table if not exists scientific_reviews (
  id bigserial primary key,
  entity_type text not null,
  entity_id text not null,
  revision integer not null check (revision >= 1),
  from_status text not null check (from_status in ('draft','reviewed','published','retired')),
  to_status text not null check (to_status in ('draft','reviewed','published','retired')),
  reviewer_id uuid,
  notes text,
  ts timestamptz not null default now()
);
create index if not exists idx_reviews_entity on scientific_reviews (entity_type, entity_id);

create or replace function fl_reviews_append_only() returns trigger language plpgsql set search_path = '' as $$
begin
  raise exception 'scientific_reviews es solo de inserción';
end $$;
drop trigger if exists trg_reviews_append_only on scientific_reviews;
create trigger trg_reviews_append_only before update or delete on scientific_reviews
  for each row execute function fl_reviews_append_only();
