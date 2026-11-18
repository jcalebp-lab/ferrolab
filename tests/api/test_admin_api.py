"""Panel admin con base de datos real: roles, revisión, publicación y reversión (SEC-02…04, SEC-09)."""

from __future__ import annotations

import os

import pytest
from app.db.migrate import apply
from app.db.session import make_engine
from app.main import create_app
from app.repositories.entities import ENTITIES, INSERT_ORDER
from app.repositories.postgres import PostgresRepository
from app.services.release_builder import DEV, build_snapshot
from fastapi.testclient import TestClient
from sqlalchemy import text

URL = os.environ.get("TEST_DATABASE_URL")
pytestmark = [pytest.mark.db, pytest.mark.skipif(not URL, reason="TEST_DATABASE_URL no configurada")]
EDITOR, REVIEWER, ADMIN, STRANGER = (f"00000000-0000-4000-8000-00000000000{i}" for i in (1, 2, 3, 9))


@pytest.fixture(scope="module")
def api(seed_data):
    eng = make_engine(URL)
    with eng.begin() as c:
        c.execute(text("drop schema public cascade"))
        c.execute(text("create schema public"))
        c.execute(text("grant usage on schema public to anon, authenticated"))
    apply(eng, local_roles=True)
    repo = PostgresRepository(eng)
    for name in INSERT_ORDER:
        for item in seed_data.get(ENTITIES[name].snapshot_key, []):
            repo.create(ENTITIES[name], item, actor=None)
    with eng.connect() as c:
        snap, _ = build_snapshot(repo.load_rows(c, DEV), version="0.1.0-dev+unreviewed", include_drafts=True)
    repo.create_release(snap.dataset_version, snap, None, None, True, False)
    for uid, role in ((EDITOR, "editor"), (REVIEWER, "reviewer"), (ADMIN, "admin")):
        repo.upsert_membership(uid, None, role)
    yield eng
    eng.dispose()


@pytest.fixture()
def c(api, settings_factory):
    return TestClient(create_app(settings_factory(database_url=URL, rate_limit_per_minute=10_000)))


def h(token, uid):
    return {"Authorization": f"Bearer {token(uid)}"}


def test_roles(c, token):
    assert c.get("/api/v1/admin/me", headers=h(token, STRANGER)).status_code == 403
    me = c.get("/api/v1/admin/me", headers=h(token, EDITOR)).json()
    assert me["role"] == "editor"
    # SEC-03: el editor no publica ni revisa.
    assert c.post("/api/v1/admin/releases", headers=h(token, EDITOR), json={"version": "1.0.0"}).status_code == 403
    rec = c.get("/api/v1/admin/knowledge/ferrita", headers=h(token, EDITOR)).json()
    r = c.post("/api/v1/admin/knowledge/ferrita/transition", headers=h(token, EDITOR),
               json={"to": "reviewed", "revision": rec["_meta"]["revision"]})
    assert r.status_code == 403
    # el body no puede elevar el rol
    assert c.post("/api/v1/admin/memberships", headers=h(token, REVIEWER),
                  json={"user_id": STRANGER, "role": "admin"}).status_code == 403


def test_public_cannot_see_drafts_via_admin_paths(c):
    assert c.get("/api/v1/admin/materials").status_code == 401


def test_editor_edit_creates_draft_and_audit(c, token):
    rec = c.get("/api/v1/admin/knowledge/cementita", headers=h(token, EDITOR)).json()
    r = c.patch("/api/v1/admin/knowledge/cementita", headers=h(token, EDITOR),
                json={"revision": rec["_meta"]["revision"], "changes": {"title_es": "Cementita (carburo de hierro)"}})
    assert r.status_code == 200 and r.json()["review_status"] == "draft"
    stale = c.patch("/api/v1/admin/knowledge/cementita", headers=h(token, EDITOR),
                    json={"revision": rec["_meta"]["revision"], "changes": {"title_es": "x"}})
    assert stale.status_code == 409
    bad = c.patch("/api/v1/admin/material-treatments/aisi_1045:temper", headers=h(token, EDITOR),
                  json={"revision": 1, "changes": {"quantitative_outputs_enabled": True}})
    assert bad.status_code in (409, 422)
    audit = c.get("/api/v1/admin/audit", headers=h(token, REVIEWER)).json()["items"]
    assert any(a["action"] == "update" and a["entity_id"] == "cementita" for a in audit)


def test_sec04_number_without_locator_cannot_be_reviewed(c, token):
    rec = c.get("/api/v1/admin/evidence/ev_fe_melting_point", headers=h(token, REVIEWER)).json()
    r = c.post("/api/v1/admin/evidence/ev_fe_melting_point/approve", headers=h(token, REVIEWER),
               json={"to": "reviewed", "revision": rec["_meta"]["revision"]})
    assert r.status_code == 422


def test_sec09_micrograph_without_license_cannot_be_reviewed(c, token):
    body = {"id": "mg_test", "material_id": "aisi_1045", "treatment_id": "quench", "image_url": "https://example.org/x.png",
            "source_id": "src_callister", "author": "Desconocido", "attribution": "—", "license_code": "unknown",
            "license_url": "https://example.org", "license_verified": False, "imaging_method": "optical",
            "match_quality": "comparable", "alt_es": "x", "alt_en": "x"}
    created = c.post("/api/v1/admin/micrographs", headers=h(token, EDITOR), json=body)
    assert created.status_code == 201 and created.json()["review_status"] == "draft"
    r = c.post("/api/v1/admin/micrographs/mg_test/transition", headers=h(token, REVIEWER),
               json={"to": "reviewed", "revision": created.json()["_meta"]["revision"]})
    assert r.status_code == 422
    assert c.get("/api/v1/micrographs/mg_test").status_code == 404


def test_release_gates_then_publish_and_rollback(c, token):
    r = c.post("/api/v1/admin/releases/preview", headers=h(token, REVIEWER), json={"version": "1.0.0-test"})
    assert r.status_code == 422 and r.json()["error"]["details"]["problems"]
    # Recorrido técnico con marcador de prueba (no es una verificación científica real).
    ev = c.get("/api/v1/admin/evidence/ev_fe_melting_point", headers=h(token, EDITOR)).json()
    c.patch("/api/v1/admin/evidence/ev_fe_melting_point", headers=h(token, EDITOR),
            json={"revision": ev["_meta"]["revision"], "changes": {"locator": "TEST-LOCATOR"}})
    for name in INSERT_ORDER:
        if name == "micrographs":
            continue
        for item in c.get(f"/api/v1/admin/{name}?status=draft&limit=500", headers=h(token, REVIEWER)).json()["items"]:
            key = ":".join(str(item[f]) for f in ENTITIES[name].key_fields)
            rr = c.post(f"/api/v1/admin/{name}/{key}/transition", headers=h(token, REVIEWER),
                        json={"to": "reviewed", "revision": item["_meta"]["revision"]})
            assert rr.status_code == 200, rr.text
    created = c.post("/api/v1/admin/releases", headers=h(token, REVIEWER), json={"version": "1.0.0-test"})
    assert created.status_code == 201, created.text
    ready = c.get("/api/v1/health/ready").json()
    assert ready["dataset_version"] == "1.0.0-test" and ready["dataset_contains_unreviewed_content"] is False
    sim = c.post("/api/v1/simulations", json={"material_id": "aisi_1045", "treatment_id": "quench",
                                              "target_temperature_c": 850, "hold_time_min": 30}).json()
    assert sim["simulation_status"] == "insufficient_evidence" and sim["results"]["hardness"] is None
    assert c.get("/api/v1/materials").json()["items"][0]["review_status"] == "published"
    rels = c.get("/api/v1/admin/releases", headers=h(token, REVIEWER)).json()["items"]
    old = next(x for x in rels if x["semantic_version"] == "0.1.0-dev+unreviewed")
    assert c.post(f"/api/v1/admin/releases/{old['id']}/activate", headers=h(token, REVIEWER)).status_code == 200
    assert c.get("/api/v1/health/ready").json()["dataset_version"] == "0.1.0-dev+unreviewed"
