"""Prepara una base de datos de DESARROLLO: migraciones, RLS, catálogo y release dev.

Uso (con PostgreSQL local o Supabase de pruebas):
    DATABASE_URL=postgresql://... uv run python scripts/db_setup.py [--admin-user UUID --admin-email X --role admin]

Nunca publica contenido como revisado: la release creada es `0.1.0-dev+unreviewed`.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "services" / "api"))

from app.core.config import get_settings  # noqa: E402
from app.db.migrate import apply  # noqa: E402
from app.db.session import make_engine  # noqa: E402
from app.repositories.entities import ENTITIES, INSERT_ORDER  # noqa: E402
from app.repositories.postgres import PostgresRepository  # noqa: E402
from app.services.release_builder import DEV, build_snapshot  # noqa: E402
from sqlalchemy import text  # noqa: E402

REFERENCING_TABLES = ("materials", "initial_conditions", "protocols", "material_treatments", "scientific_evidence",
                      "micrographs", "knowledge_entries", "model_versions", "physical_guards", "practice_questions")


def _referenced(engine, table: str, ident: str) -> bool:
    """¿Algún registro VIGENTE de otra tabla cita este identificador? Entonces no se retira: un registro editado por
    una persona (que la semilla ya no sobrescribe) puede seguir apoyándose en una fuente o evidencia antigua."""
    with engine.connect() as c:
        existing = {r[0] for r in c.execute(text("select table_name from information_schema.tables "
                                                  "where table_schema = current_schema()"))}
        for t in REFERENCING_TABLES:
            if t == table or t not in existing:
                continue
            # Solo cuentan los registros de una PERSONA (editados o revisados): los de la semilla que siguen vigentes
            # no citan ids retirados, y los obsoletos de la semilla también se retiran.
            hit = c.execute(text(f"select 1 from {t} where review_status <> 'retired' "
                                 "and (updated_by is not null or review_status in ('reviewed', 'published')) "
                                 "and body::text like :pat limit 1"), {"pat": f'%"{ident}"%'}).first()
            if hit:
                return True
    return False


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--admin-user")
    ap.add_argument("--admin-email")
    ap.add_argument("--role", default="admin", choices=["editor", "reviewer", "admin"])
    args = ap.parse_args()
    # En un servidor (Render) sin terminal: ADMIN_BOOTSTRAP_USER_ID = id del usuario en Supabase Auth.
    import os

    args.admin_user = args.admin_user or os.environ.get("ADMIN_BOOTSTRAP_USER_ID") or None
    args.admin_email = args.admin_email or os.environ.get("ADMIN_BOOTSTRAP_EMAIL") or None
    s = get_settings()
    if s.database_url is None:
        print("Falta DATABASE_URL", file=sys.stderr)
        return 2
    if s.is_production:
        print("db_setup es solo para desarrollo/pruebas", file=sys.stderr)
        return 2
    engine = make_engine(s.database_url.get_secret_value())
    # En Supabase los roles anon/authenticated ya existen: SKIP_LOCAL_DB_ROLES=true.
    local_roles = os.environ.get("SKIP_LOCAL_DB_ROLES", "").lower() != "true"
    print("Migraciones:", apply(engine, local_roles=local_roles))
    repo = PostgresRepository(engine)
    seed = json.loads((ROOT / "database" / "seeds" / "catalog_seed.json").read_text(encoding="utf-8"))
    created = updated = 0
    for name in INSERT_ORDER:
        ent = ENTITIES[name]
        for item in seed.get(ent.snapshot_key, []):
            key = ent.key_of(ent.model.model_validate(item))
            with engine.connect() as c:
                clause = " and ".join(f"{k} = :{k}" for k in ent.key_fields)
                row = c.execute(text(f"select revision, updated_by, review_status from {ent.table} where {clause}"),
                                {k: str(item[k]) for k in ent.key_fields}).first()
            if row is None:
                repo.create(ent, item, actor=None)
                created += 1
                continue
            # Sincroniza solo registros que siguen siendo del catálogo semilla: nadie los editó (updated_by nulo)
            # y siguen en borrador. Lo editado o revisado por una persona nunca se sobrescribe.
            if row.updated_by is None and row.review_status == "draft":
                current = repo.get(ent, key)
                clean = {k: v for k, v in current.items() if not k.startswith("_")}
                wanted = ent.model.model_validate(item).model_dump(mode="json")
                try:
                    have = ent.model.model_validate({**clean, "review_status": "draft"}).model_dump(mode="json")
                except ValueError:  # registro de una versión anterior que ya no cumple el esquema actual
                    have = None
                if have != wanted:
                    repo.update(ent, key, item, row.revision, actor=None)
                    updated += 1
    # Registros de la semilla anterior que ya no existen (p. ej. materiales reemplazados): se RETIRAN
    # (nunca se borran; quedan en el historial). Solo los que siguen siendo del catálogo semilla (sin editar, borrador).
    retired = 0
    for name in reversed(INSERT_ORDER):
        ent = ENTITIES[name]
        wanted = {ent.key_of(ent.model.model_validate(item)) for item in seed.get(ent.snapshot_key, [])}
        cols = ", ".join(ent.key_fields)
        with engine.connect() as c:
            stale = c.execute(text(f"select {cols}, revision from {ent.table} "
                                   "where updated_by is null and review_status = 'draft'")).all()
        for row in stale:
            key = ":".join(str(v) for v in row[:-1])
            if key not in wanted and not (len(ent.key_fields) == 1 and _referenced(engine, ent.table, key)):
                repo.transition(ent, key, "retired", row[-1], None, False)
                retired += 1
    print(f"Catálogo: {created} creados, {updated} actualizados, {retired} registros retirados desde la semilla")
    with engine.connect() as c:
        active = c.execute(text("select semantic_version, checksum, contains_unreviewed_content from dataset_releases "
                                "where is_active")).first()
        rows = repo.load_rows(c, DEV)
    # La suma de comprobación incluye la versión: se compara reconstruyendo con la versión de la release activa.
    same_as_active, _ = build_snapshot(rows, version=active.semantic_version if active else seed["dataset_version"],
                                       include_drafts=True, interface=seed["interface"])
    snap = same_as_active
    # Nueva release de desarrollo si no hay ninguna activa, o si la activa es de desarrollo y el catálogo cambió.
    if active is None or (active.contains_unreviewed_content and active.checksum != same_as_active.checksum()):
        version = seed["dataset_version"]
        with engine.connect() as c:
            if c.execute(text("select 1 from dataset_releases where semantic_version = :v"), {"v": version}).first():
                version = f"{version}.{snap.checksum()[:8]}"
        snap, report = build_snapshot(rows, version=version, include_drafts=True, interface=seed["interface"])
        repo.create_release(version, snap, None, "Release de desarrollo con borradores", True, False)
        print(f"Release dev activa: {snap.dataset_version} ({snap.checksum()[:12]}…) avisos={len(report)}")
    if args.admin_user:
        repo.upsert_membership(args.admin_user, args.admin_email, args.role)
        print(f"Membresía {args.role} para {args.admin_user}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
