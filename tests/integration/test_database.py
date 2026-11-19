"""Pruebas de base de datos: RLS, restricciones, auditoría y publicaciones (doc 05 §12, §14.7).

Requieren TEST_DATABASE_URL apuntando a una base desechable (se reinicia el esquema).
"""

from __future__ import annotations

import json
import os

import pytest
from app.db.migrate import apply
from app.db.session import make_engine
from app.repositories.entities import ENTITIES, INSERT_ORDER
from app.repositories.postgres import PostgresRepository, RepoError
from app.services.release_builder import DEV, OFFICIAL, ReleaseBuildError, build_snapshot
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError

URL = os.environ.get("TEST_DATABASE_URL")
pytestmark = [pytest.mark.db, pytest.mark.skipif(not URL, reason="TEST_DATABASE_URL no configurada")]
ADMIN = "00000000-0000-4000-8000-000000000001"


@pytest.fixture(scope="module")
def engine(seed_data):
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
    yield eng
    eng.dispose()


@pytest.fixture()
def repo(engine):
    return PostgresRepository(engine)


def test_migrations_idempotent(engine):
    applied = apply(engine, local_roles=True)
    assert all(a.startswith("policy:") for a in applied)


@pytest.mark.parametrize("role", ["anon", "authenticated"])
@pytest.mark.parametrize("table", ["materials", "scientific_evidence", "audit_log", "dataset_releases", "admin_memberships"])
def test_sec05_rls_denies_public_roles(engine, role, table):
    with engine.connect() as c:
        c.execute(text(f"set role {role}"))
        with pytest.raises(DBAPIError):
            c.execute(text(f"select * from {table}")).all()
        c.rollback()
        c.execute(text(f"set role {role}"))
        with pytest.raises(DBAPIError):
            c.execute(text(f"delete from {table}"))
        c.rollback()


def test_rls_enabled_everywhere(engine):
    with engine.connect() as c:
        rows = c.execute(text("select relname from pg_class where relkind='r' and relnamespace='public'::regnamespace "
                              "and not relrowsecurity")).all()
    assert rows == []


def _exec_fails(engine, sql, params=None):
    with pytest.raises(DBAPIError):
        with engine.begin() as c:
            c.execute(text(sql), params or {})


def test_constraints_block_unsourced_numbers(engine):
    base = "insert into scientific_evidence(id, source_id, evidence_kind, value, unit, locator, review_status, body) values "
    _exec_fails(engine, base + "('x1','src_callister','measured', 1, null, 'p', 'draft', '{}')")  # sin unidad
    _exec_fails(engine, base + "('x2','src_callister','measured', 1, 'HV', null, 'published', '{}')")  # sin localizador
    _exec_fails(engine, base + "('x3','src_callister','measured', 'NaN', 'HV', 'p', 'draft', '{}')")  # NaN
    _exec_fails(engine, "update material_treatments set quantitative_outputs_enabled = true, "
                        "compatibility_status = 'educational_only' where material_id='aisi_1045' and treatment_id='temper'")
    _exec_fails(engine, "update material_treatments set temperature_min_c = 1 where material_id='aisi_1045' "
                        "and treatment_id='quench'")  # rango sin evidencia
    _exec_fails(engine, "insert into materials(id, family, display_name, body) values ('x', 'aluminum', 'x', '{}')")


def test_audit_log_append_only(engine):
    _exec_fails(engine, "update audit_log set action = 'x'")
    _exec_fails(engine, "delete from audit_log")


def test_dev_release_and_immutability(repo, engine):
    with engine.connect() as c:
        rows = repo.load_rows(c, DEV)
    snap, _ = build_snapshot(rows, version="0.1.0-dev+test", include_drafts=True)
    assert snap.contains_unreviewed_content is True
    rel = repo.create_release(snap.dataset_version, snap, ADMIN, None, activate=True, mark_published=False)
    active, checksum = repo.active_snapshot()
    assert active.dataset_version == "0.1.0-dev+test" and checksum == snap.checksum()
    _exec_fails(engine, "update dataset_releases set snapshot = '{}'::jsonb")
    _exec_fails(engine, "delete from dataset_releases")
    with pytest.raises(RepoError):
        repo.create_release(snap.dataset_version, snap, ADMIN, None, activate=True, mark_published=False)
    assert rel["is_active"]


def test_official_release_refused_while_drafts(repo, engine):
    with engine.connect() as c:
        rows = repo.load_rows(c, OFFICIAL)
    with pytest.raises(ReleaseBuildError) as e:
        build_snapshot(rows, version="1.0.0", include_drafts=False)
    assert any("límites físicos" in p for p in e.value.problems)


def test_revision_conflict_and_edit_resets_review(repo):
    ent = ENTITIES["knowledge"]
    cur = repo.get(ent, "ferrita")
    rev = cur["_meta"]["revision"]
    reviewed = repo.transition(ent, "ferrita", "reviewed", rev, ADMIN, False)
    assert reviewed["review_status"] == "reviewed"
    with pytest.raises(RepoError) as e:
        repo.update(ent, "ferrita", {"title_es": "Ferrita α"}, rev, ADMIN)  # revisión vieja
    assert e.value.code == "revision_conflict"
    upd = repo.update(ent, "ferrita", {"title_es": "Ferrita α"}, reviewed["_meta"]["revision"], ADMIN)
    assert upd["review_status"] == "draft" and upd["title_es"] == "Ferrita α"


def test_review_gate_requires_locator(repo):
    ent = ENTITIES["evidence"]
    cur = repo.get(ent, "ev_fe_melting_point")
    with pytest.raises(RepoError) as e:
        repo.transition(ent, "ev_fe_melting_point", "reviewed", cur["_meta"]["revision"], ADMIN, False)
    assert "localizador" in e.value.message


def test_full_review_publish_and_rollback(repo, engine):
    """Recorrido completo con marcadores de prueba: revisar todo -> publicar -> revertir."""
    ev = ENTITIES["evidence"]
    cur = repo.get(ev, "ev_fe_melting_point")
    cur = repo.update(ev, "ev_fe_melting_point", {"locator": "TEST-LOCATOR (prueba automatizada)"},
                      cur["_meta"]["revision"], ADMIN)
    for name in INSERT_ORDER:
        ent = ENTITIES[name]
        for item in repo.list(ent, status="draft", limit=500):
            key = ent.key_of(ent.model.model_validate({k: v for k, v in item.items() if k != "_meta"}))
            try:
                repo.transition(ent, key, "reviewed", item["_meta"]["revision"], ADMIN, False)
            except RepoError:
                # Solo los protocolos sin fuente verificada o sin temperatura documentada se rechazan.
                assert name == "protocols"
    with engine.connect() as c:
        rows = repo.load_rows(c, OFFICIAL)
    snap, report = build_snapshot(rows, version="1.0.0-test", include_drafts=False)
    assert snap.contains_unreviewed_content is False
    ev_ids = {e.id for e in snap.evidence}
    assert all(c.evidence_id in ev_ids for m in snap.materials for c in m.compositions)
    assert all(p.evidence_status == "source_verified" for p in snap.protocols)
    with engine.connect() as c:
        assert c.execute(text("select count(*) from scientific_reviews")).scalar() > 0
    repo.create_release("1.0.0-test", snap, ADMIN, "prueba", activate=True, mark_published=True)
    assert repo.get(ENTITIES["materials"], "aisi_1045")["review_status"] == "published"
    active, _ = repo.active_snapshot()
    assert active.dataset_version == "1.0.0-test"
    previous = next(r for r in repo.list_releases() if r["semantic_version"] == "0.1.0-dev+test")
    repo.activate_release(previous["id"], ADMIN)
    assert repo.active_snapshot()[0].dataset_version == "0.1.0-dev+test"
    actions = [a["action"] for a in repo.audit(500)]
    assert "release:create" in actions and "release:activate" in actions and "transition:reviewed" in actions
    assert json.dumps(report)  # el informe es serializable
