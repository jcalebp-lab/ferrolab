"""Genera un token de administrador SOLO para desarrollo local.

Firma un JWT HS256 con SUPABASE_JWT_SECRET (un secreto local de desarrollo que
usted inventa en .env). La API sigue exigiendo que el usuario tenga membresía
en `admin_memberships`. Se niega a funcionar con FERROLAB_ENV=production.

Uso: uv run python scripts/dev_admin_token.py --user 00000000-0000-4000-8000-000000000001
"""

from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "services" / "api"))

import jwt  # noqa: E402
from app.core.config import get_settings  # noqa: E402


def mint(user_id: str, secret: str, audience: str, issuer: str | None, ttl_s: int = 3600) -> str:
    now = int(time.time())
    claims = {"sub": user_id, "aud": audience, "iat": now, "exp": now + ttl_s, "role": "authenticated"}
    if issuer:
        claims["iss"] = issuer
    return jwt.encode(claims, secret, algorithm="HS256")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--user", required=True)
    ap.add_argument("--ttl", type=int, default=3600)
    a = ap.parse_args()
    s = get_settings()
    if s.is_production or s.supabase_jwt_secret is None:
        print("Solo desarrollo y requiere SUPABASE_JWT_SECRET", file=sys.stderr)
        return 2
    print(mint(a.user, s.supabase_jwt_secret.get_secret_value(), s.supabase_jwt_audience, s.supabase_jwt_issuer, a.ttl))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
