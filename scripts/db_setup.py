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
    print("Migraciones:", apply(engine, local_roles=True))
    repo = PostgresRepository(engine)
    seed = json.loads((ROOT / "database" / "seeds" / "catalog_seed.json").read_text(encoding="utf-8"))
    created = 0
    for name in INSERT_ORDER:
        ent = ENTITIES[name]
        for item in seed.get(ent.snapshot_key, []):
            with engine.connect() as c:
                clause = " and ".join(f"{k} = :{k}" for k in ent.key_fields)
                exists = c.execute(text(f"select 1 from {ent.table} where {clause}"),
                                   {k: str(item[k]) for k in ent.key_fields}).first()
            if not exists:
                repo.create(ent, item, actor=None)
                created += 1
    print(f"Registros de catálogo creados: {created}")
    with engine.connect() as c:
        has_active = c.execute(text("select 1 from dataset_releases where is_active")).first()
        rows = repo.load_rows(c, DEV)
    if not has_active:
        snap, report = build_snapshot(rows, version=seed["dataset_version"], include_drafts=True,
                                      interface=seed["interface"])
        repo.create_release(seed["dataset_version"], snap, None, "Release de desarrollo con borradores", True, False)
        print(f"Release dev activa: {snap.dataset_version} ({snap.checksum()[:12]}…) avisos={len(report)}")
    if args.admin_user:
        repo.upsert_membership(args.admin_user, args.admin_email, args.role)
        print(f"Membresía {args.role} para {args.admin_user}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
