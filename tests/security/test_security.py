"""Seguridad (doc 13 §5): admin cerrado por defecto, sin secretos en el repositorio ni en el bundle."""

from __future__ import annotations

import re
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
ADMIN_ROUTES = [("get", "/api/v1/admin/me"), ("get", "/api/v1/admin/materials"), ("post", "/api/v1/admin/materials"),
                ("patch", "/api/v1/admin/materials/aisi_1045"), ("post", "/api/v1/admin/evidence/x/approve"),
                ("post", "/api/v1/admin/releases"), ("get", "/api/v1/admin/audit"),
                ("post", "/api/v1/admin/releases/x/activate"), ("post", "/api/v1/admin/materials/aisi_1045/transition")]


@pytest.mark.parametrize("method,path", ADMIN_ROUTES)
def test_sec02_admin_requires_token(client, method, path):
    r = client.request(method.upper(), path, json={} if method != "get" else None)
    assert r.status_code == 401
    assert r.json()["error"]["code"] == "unauthenticated"


def test_admin_rejects_bad_tokens(settings_factory, token, monkeypatch):
    from app.core import security
    from app.main import create_app
    from fastapi.testclient import TestClient

    c = TestClient(create_app(settings_factory()))
    for bad in [token("u", secret="otro-secreto-cualquiera-de-32-bytes!!"), token("u", exp_in=-100),
                token("u", aud="anon"), "no-es-un-jwt"]:
        with pytest.raises(security.ApiError) as e:
            security.verify_token(bad, c.app.state.ferrolab.settings)
        assert e.value.status == 401
    # Con firma válida pero sin base de datos: no hay forma de conceder rol.
    r = c.get("/api/v1/admin/me", headers={"Authorization": f"Bearer {token('u')}"})
    assert r.status_code == 503


def test_admin_unconfigured_auth_never_open(settings_factory, token):
    from app.core.config import Settings
    from app.main import create_app
    from fastapi.testclient import TestClient

    c = TestClient(create_app(Settings(_env_file=None, ferrolab_env="test")))
    r = c.get("/api/v1/admin/me", headers={"Authorization": f"Bearer {token('u')}"})
    assert r.status_code in (401, 503)


SECRET_PATTERNS = [
    re.compile(r"sk-ant-[A-Za-z0-9_-]{20,}"),
    re.compile(r"-----BEGIN (RSA |EC |)PRIVATE KEY-----"),
    re.compile(r"eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}"),  # JWT incrustado
    re.compile(r"(SUPABASE_SERVICE_ROLE_KEY|AI_API_KEY|SUPABASE_JWT_SECRET)\s*=\s*['\"]?[A-Za-z0-9_.-]{16,}"),
    re.compile(r"postgres(ql)?://[^:\s]+:[^@\s]{6,}@(?!localhost|127\.0\.0\.1)"),
]
SKIP_DIRS = {".git", ".venv", "node_modules", ".dart_tool", ".pytest_cache", ".hypothesis", "bluebook_original_backup"}


def _files(base: Path):
    for p in base.rglob("*"):
        if p.is_file() and not (set(p.relative_to(ROOT).parts) & SKIP_DIRS) and p.stat().st_size < 5_000_000:
            yield p


def test_sec06_no_secrets_in_repository():
    hits = []
    for p in _files(ROOT):
        if p.suffix in {".png", ".jpg", ".ico", ".woff2", ".ttf", ".otf", ".zip", ".wasm"}:
            continue
        text = p.read_text(errors="ignore")
        for pat in SECRET_PATTERNS:
            if pat.search(text):
                hits.append(f"{p.relative_to(ROOT)}: {pat.pattern[:30]}")
    assert hits == []


def test_sec06_flutter_sources_do_not_reference_server_secrets():
    client = ROOT / "apps" / "flutter_client"
    if not client.exists():
        pytest.skip("cliente Flutter aún no creado")
    for p in _files(client):
        if p.suffix in {".dart", ".json", ".yaml", ".html", ".js"}:
            t = p.read_text(errors="ignore")
            assert "service_role" not in t.lower() and "AI_API_KEY" not in t and "DATABASE_URL" not in t, p
