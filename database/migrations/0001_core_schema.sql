-- FERROLAB 0001 — esquema núcleo (doc 05). Compatible con Supabase PostgreSQL.
-- Convención: columnas tipadas para identidad, FK, permisos y valores validados;
-- `body jsonb` guarda el registro completo validado por Pydantic (ferrolab_fse.snapshot).
-- Ninguna tabla contiene datos metalúrgicos: los datos llegan por el panel admin.

create extension if not exists pgcrypto;

create or replace function fl_touch_updated_at() returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- Columnas comunes de entidades publicables ---------------------------------
-- review_status, revision, created_at, updated_at, updated_by, reviewed_by, reviewed_at, published_at

create table if not exists sources (
  id text primary key,
  kind text not null check (kind in ('book','standard','article','dataset','web','editorial')),
  title text not null,
  verification_status text not null default 'unverified' check (verification_status in ('unverified','verified')),
  license_code text,
  body jsonb not null check (jsonb_typeof(body) = 'object'),
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid, reviewed_by uuid, reviewed_at timestamptz, published_at timestamptz
);

create table if not exists materials (
  id text primary key,
  family text not null check (family in ('steel','gray_cast_iron')),
  display_name text not null,
  body jsonb not null check (jsonb_typeof(body) = 'object'),
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid, reviewed_by uuid, reviewed_at timestamptz, published_at timestamptz
);

create table if not exists treatments (
  id text primary key check (id in ('quench','temper','anneal','normalize','austemper','martemper')),
  name_es text not null,
  name_en text not null,
  body jsonb not null check (jsonb_typeof(body) = 'object'),
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid, reviewed_by uuid, reviewed_at timestamptz, published_at timestamptz
);

create table if not exists scientific_evidence (
  id text primary key,
  source_id text not null references sources(id),
  material_id text references materials(id),
  treatment_id text references treatments(id),
  quantity_code text check (quantity_code in ('phase_fractions','microconstituent_fractions','hardness','grain_size','mechanical_properties')),
  evidence_kind text not null check (evidence_kind in ('measured','literature','modeled','illustrative','unavailable')),
  locator text,
  value double precision check (value is null or value not in ('NaN'::float8, 'Infinity'::float8, '-Infinity'::float8)),
  unit text,
  body jsonb not null check (jsonb_typeof(body) = 'object'),
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid, reviewed_by uuid, reviewed_at timestamptz, published_at timestamptz,
  constraint evidence_value_has_unit check (value is null or unit is not null),
  constraint evidence_published_value_has_locator check (
    value is null or review_status <> 'published' or (locator is not null and length(locator) > 0)
  )
);

create table if not exists material_compositions (
  id uuid primary key default gen_random_uuid(),
  material_id text not null references materials(id) on delete cascade,
  element text not null,
  min_wt_pct double precision,
  max_wt_pct double precision,
  nominal_wt_pct double precision,
  evidence_id text not null references scientific_evidence(id),
  constraint comp_bounds check (
    (min_wt_pct is null or min_wt_pct >= 0) and (max_wt_pct is null or max_wt_pct <= 100)
    and (min_wt_pct is null or max_wt_pct is null or min_wt_pct <= max_wt_pct)
  ),
  unique (material_id, element)
);

create table if not exists initial_conditions (
  id text primary key,
  material_id text not null references materials(id),
  source_id text references sources(id),
  hardened boolean,
  carburized boolean,
  body jsonb not null check (jsonb_typeof(body) = 'object'),
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid, reviewed_by uuid, reviewed_at timestamptz, published_at timestamptz
);

-- Protocolo completo (calentamiento, mesetas, traslado, enfriamiento y baños).
-- Unifica `cooling_profiles` + `protocol_stages` del doc 05 (ver DECISIONS D-04).
create table if not exists protocols (
  id text primary key,
  material_id text not null references materials(id),
  treatment_id text not null references treatments(id),
  version text not null,
  body jsonb not null check (jsonb_typeof(body) = 'object' and jsonb_typeof(body->'stages') = 'array'),
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid, reviewed_by uuid, reviewed_at timestamptz, published_at timestamptz,
  unique (material_id, treatment_id, version)
);

create table if not exists material_treatments (
  id uuid primary key default gen_random_uuid(),
  material_id text not null references materials(id),
  treatment_id text not null references treatments(id),
  compatibility_status text not null check (compatibility_status in ('supported','conditional','educational_only','unsupported')),
  quantitative_outputs_enabled boolean not null default false,
  protocol_id text references protocols(id),
  temperature_min_c double precision,
  temperature_max_c double precision,
  temperature_evidence_id text references scientific_evidence(id),
  hold_min_s double precision,
  hold_max_s double precision,
  hold_evidence_id text references scientific_evidence(id),
  body jsonb not null check (jsonb_typeof(body) = 'object'),
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid, reviewed_by uuid, reviewed_at timestamptz, published_at timestamptz,
  unique (material_id, treatment_id),
  constraint valid_temperature_bounds check (temperature_min_c is null or temperature_max_c is null or temperature_min_c <= temperature_max_c),
  constraint valid_time_bounds check ((hold_min_s is null or hold_min_s >= 0) and (hold_min_s is null or hold_max_s is null or hold_min_s <= hold_max_s)),
  constraint temp_range_needs_evidence check ((temperature_min_c is null and temperature_max_c is null) or temperature_evidence_id is not null),
  constraint hold_range_needs_evidence check ((hold_min_s is null and hold_max_s is null) or hold_evidence_id is not null),
  constraint educational_has_no_numbers check (
    not (quantitative_outputs_enabled and compatibility_status in ('educational_only','unsupported'))
  )
);
create index if not exists idx_mt_pair on material_treatments(material_id, treatment_id);

create table if not exists physical_guards (
  id text primary key,
  applies_to_family text not null check (applies_to_family in ('steel','gray_cast_iron')),
  max_temperature_c double precision not null check (max_temperature_c > 0),
  evidence_id text not null references scientific_evidence(id),
  body jsonb not null check (jsonb_typeof(body) = 'object'),
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid, reviewed_by uuid, reviewed_at timestamptz, published_at timestamptz
);

create table if not exists models (
  code text primary key check (code in ('koistinen_marburger','andrews_ms','jmak','e140_conversion')),
  name text not null,
  description text not null
);

create table if not exists model_versions (
  id text primary key,
  model_code text not null references models(code),
  version text not null,
  approved boolean not null default false,
  source_id text references sources(id),
  body jsonb not null check (jsonb_typeof(body) = 'object'),
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid, reviewed_by uuid, reviewed_at timestamptz, published_at timestamptz,
  approved_at timestamptz,
  unique (model_code, version),
  constraint approved_needs_source check (not approved or source_id is not null)
);

create table if not exists micrographs (
  id text primary key,
  material_id text not null references materials(id),
  treatment_id text references treatments(id),
  source_id text not null references sources(id),
  license_code text not null,
  license_verified boolean not null default false,
  magnification_x double precision check (magnification_x is null or magnification_x > 0),
  scale_bar_um double precision check (scale_bar_um is null or scale_bar_um > 0),
  match_quality text not null check (match_quality in ('exact','comparable','illustrative','none')),
  body jsonb not null check (jsonb_typeof(body) = 'object'),
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid, reviewed_by uuid, reviewed_at timestamptz, published_at timestamptz,
  constraint published_needs_license check (review_status <> 'published' or license_verified)
);
create index if not exists idx_micrographs_lookup on micrographs(material_id, treatment_id, review_status);

create table if not exists micrograph_annotations (
  id uuid primary key default gen_random_uuid(),
  micrograph_id text not null references micrographs(id) on delete cascade,
  phase_code text not null,
  geometry_json jsonb not null,
  evidence_level text not null check (evidence_level in ('validated','bounded_estimate','qualitative','insufficient_evidence','unsupported')),
  annotation_method text not null,
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired'))
);

create table if not exists media_license_reviews (
  id uuid primary key default gen_random_uuid(),
  micrograph_id text not null references micrographs(id),
  license_url text not null,
  verified_by uuid not null,
  verified_at timestamptz not null default now(),
  notes text
);

create table if not exists knowledge_entries (
  slug text primary key check (slug ~ '^[a-z0-9-]+$'),
  category text not null check (category in ('glossary','concept','faq')),
  body jsonb not null check (jsonb_typeof(body) = 'object'),
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid, reviewed_by uuid, reviewed_at timestamptz, published_at timestamptz
);

create table if not exists practice_questions (
  id text primary key,
  body jsonb not null check (jsonb_typeof(body) = 'object'),
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired')),
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid, reviewed_by uuid, reviewed_at timestamptz, published_at timestamptz
);

-- Diagramas TTT/CCT/Fe-C: solo puntos digitalizados con fuente y permiso (doc 05 §6).
create table if not exists diagram_sets (
  id text primary key,
  material_id text references materials(id),
  kind text not null check (kind in ('TTT','CCT','Fe-C')),
  source_id text not null references sources(id),
  validity_json jsonb not null default '{}'::jsonb,
  review_status text not null default 'draft' check (review_status in ('draft','reviewed','published','retired'))
);
create table if not exists diagram_curves (
  id uuid primary key default gen_random_uuid(),
  diagram_set_id text not null references diagram_sets(id) on delete cascade,
  curve_name text not null,
  points_json jsonb not null check (jsonb_typeof(points_json) = 'array'),
  unit_x text not null,
  unit_y text not null,
  x_log_scale boolean not null default false,
  provenance text not null,
  quality_status text not null default 'draft'
);

-- Publicaciones inmutables del paquete científico (doc 05 §14.6).
create table if not exists dataset_releases (
  id uuid primary key default gen_random_uuid(),
  semantic_version text not null unique,
  checksum text not null check (checksum ~ '^[0-9a-f]{64}$'),
  snapshot jsonb not null,
  contains_unreviewed_content boolean not null,
  is_active boolean not null default false,
  created_by uuid,
  created_at timestamptz not null default now(),
  notes text
);
create unique index if not exists one_active_release on dataset_releases ((true)) where is_active;

create or replace function fl_release_immutable() returns trigger language plpgsql as $$
begin
  if tg_op = 'DELETE' then
    raise exception 'dataset_releases es inmutable: no se borra (use retirar/activar otra)';
  end if;
  if new.snapshot is distinct from old.snapshot or new.checksum is distinct from old.checksum
     or new.semantic_version is distinct from old.semantic_version
     or new.contains_unreviewed_content is distinct from old.contains_unreviewed_content then
    raise exception 'dataset_releases es inmutable: publique una nueva versión';
  end if;
  return new;
end $$;
drop trigger if exists trg_release_immutable on dataset_releases;
create trigger trg_release_immutable before update or delete on dataset_releases
  for each row execute function fl_release_immutable();

-- Administración ---------------------------------------------------------------
create table if not exists admin_memberships (
  user_id uuid primary key,
  email text,
  role text not null check (role in ('editor','reviewer','admin')),
  status text not null default 'active' check (status in ('active','suspended')),
  created_at timestamptz not null default now()
);

create table if not exists audit_log (
  id bigserial primary key,
  actor_id uuid,
  action text not null,
  entity_type text not null,
  entity_id text not null,
  before jsonb,
  after jsonb,
  ts timestamptz not null default now()
);
create or replace function fl_audit_append_only() returns trigger language plpgsql as $$
begin
  raise exception 'audit_log es solo de inserción';
end $$;
drop trigger if exists trg_audit_append_only on audit_log;
create trigger trg_audit_append_only before update or delete on audit_log
  for each row execute function fl_audit_append_only();

-- Persistencia opcional de simulaciones (desactivada en P0; doc 03 §6) ----------
create table if not exists simulations (
  id uuid primary key default gen_random_uuid(),
  material_id text not null references materials(id),
  treatment_id text not null references treatments(id),
  temperature_c double precision not null check (temperature_c >= 0 and temperature_c <= 1600),
  hold_s double precision not null check (hold_s >= 0),
  initial_condition_id text,
  request_hash text not null,
  created_at timestamptz not null default now()
);
create index if not exists idx_simulations_hash on simulations(request_hash);
create table if not exists simulation_results (
  id uuid primary key default gen_random_uuid(),
  simulation_id uuid not null references simulations(id) on delete cascade,
  engine_version text not null,
  dataset_version text not null,
  simulation_status text not null check (simulation_status in ('completed','partial_result','insufficient_evidence','unsupported','invalid_input','internal_error')),
  result_json jsonb not null,
  created_at timestamptz not null default now()
);
create table if not exists result_components (
  id uuid primary key default gen_random_uuid(),
  result_id uuid not null references simulation_results(id) on delete cascade,
  quantity_code text not null,
  value_numeric double precision not null,
  unit text not null,
  evidence_kind text not null check (evidence_kind in ('measured','literature','modeled')),
  evidence_level text not null check (evidence_level in ('validated','bounded_estimate')),
  source_ids text[] not null check (cardinality(source_ids) > 0)
);
create table if not exists result_evidence (
  result_id uuid not null references simulation_results(id) on delete cascade,
  evidence_id text not null references scientific_evidence(id),
  usage text not null,
  primary key (result_id, evidence_id)
);

create table if not exists app_events (
  id bigserial primary key,
  event_name text not null,
  occurred_at timestamptz not null default now(),
  metadata_json jsonb not null default '{}'::jsonb
);
create index if not exists idx_app_events on app_events(occurred_at, event_name);

-- updated_at automático
do $$
declare t text;
begin
  foreach t in array array['sources','materials','treatments','scientific_evidence','initial_conditions','protocols',
    'material_treatments','physical_guards','model_versions','micrographs','knowledge_entries','practice_questions']
  loop
    execute format('drop trigger if exists trg_touch_%1$s on %1$I', t);
    execute format('create trigger trg_touch_%1$s before update on %1$I for each row execute function fl_touch_updated_at()', t);
  end loop;
end $$;

insert into models(code, name, description) values
  ('koistinen_marburger', 'Koistinen–Marburger (1959)', 'Fracción de austenita transformable a martensita; desactivado sin coeficientes verificados.'),
  ('andrews_ms', 'Andrews (1965) Ms', 'Estimación empírica de Ms; solo interfaz hasta transcribir la referencia primaria.'),
  ('jmak', 'JMAK / Avrami', 'Cinética isotérmica con k y n ajustados; no se usa para CCT.'),
  ('e140_conversion', 'Conversión ASTM E140', 'Conversión aproximada de durezas dentro de una tabla publicada; no predice dureza.')
on conflict (code) do nothing;
