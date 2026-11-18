"""Ejecutor mínimo de migraciones SQL versionadas (database/migrations + policies).

Uso: uv run python -m app.db.migrate   (requiere DATABASE_URL)
"""

from __future__ import annotations

import hashlib
import sys

from sqlalchemy import Engine, text

from ..core.config import REPO_ROOT, get_settings
from .session import make_engine

MIGRATIONS = REPO_ROOT / "database" / "migrations"
POLICIES = REPO_ROOT / "database" / "policies"


def _raw(conn, sql: str) -> None:
    """Ejecuta SQL sin interpretar '%' como parámetros (psycopg sin params)."""
    conn.connection.driver_connection.execute(sql)


def apply(engine: Engine, *, local_roles: bool) -> list[str]:
    applied: list[str] = []
    with engine.begin() as conn:
        conn.execute(text(
            "create table if not exists schema_migrations (name text primary key, checksum text not null, "
            "applied_at timestamptz not null default now())"
        ))
        done = {r[0]: r[1] for r in conn.execute(text("select name, checksum from schema_migrations"))}
    for path in sorted(MIGRATIONS.glob("*.sql")):
        sql = path.read_text(encoding="utf-8")
        digest = hashlib.sha256(sql.encode()).hexdigest()
        if path.name in done:
            if done[path.name] != digest:
                raise RuntimeError(f"La migración {path.name} cambió después de aplicarse: cree una nueva.")
            continue
        with engine.begin() as conn:
            _raw(conn, sql)
            conn.execute(text("insert into schema_migrations(name, checksum) values (:n, :c)"), {"n": path.name, "c": digest})
        applied.append(path.name)
    # Las políticas son idempotentes y se reaplican siempre.
    for path in sorted(POLICIES.glob("*.sql")):
        if path.name.startswith("0000_local") and not local_roles:
            continue
        with engine.begin() as conn:
            _raw(conn, path.read_text(encoding="utf-8"))
        applied.append(f"policy:{path.name}")
    return applied


def main() -> int:
    s = get_settings()
    if s.database_url is None:
        print("Falta DATABASE_URL", file=sys.stderr)
        return 2
    engine = make_engine(s.database_url.get_secret_value())
    done = apply(engine, local_roles="--local-roles" in sys.argv or not s.is_production)
    print("Aplicado:", ", ".join(done) or "nada nuevo")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
