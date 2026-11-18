"""Contrato público (doc 06 §16.7, doc 13 API-01/02)."""

from __future__ import annotations

import itertools
import json
from pathlib import Path

import pytest

BASE = {"material_id": "aisi_1045", "treatment_id": "quench", "target_temperature_c": 850, "hold_time_min": 30}
ENVELOPE = {"request_id", "simulation_status", "dataset_version", "protocol_version", "engine_version",
            "model_version", "input", "compatibility_status", "protocol", "thermal_history", "results",
            "micrograph", "diagrams", "warnings", "evidence", "assumptions"}


def test_health(client):
    assert client.get("/api/v1/health/live").json() == {"status": "ok"}
    r = client.get("/api/v1/health/ready").json()
    assert r["dataset_contains_unreviewed_content"] is True and r["ai_enabled"] is False
    assert "secret" not in json.dumps(r).lower()


def test_catalog_three_materials_six_treatments(client):
    mats = client.get("/api/v1/materials").json()["items"]
    assert [m["id"] for m in mats] == ["aisi_1045", "aisi_8620", "astm_a48_class_30"]
    assert all(m["compositions"] == [] for m in mats)
    assert mats[2]["family"] == "gray_cast_iron"
    trts = client.get("/api/v1/treatments?locale=en").json()["items"]
    assert [t["name"] for t in trts] == ["Quenching", "Tempering", "Annealing", "Normalizing", "Austempering",
                                         "Martempering (marquenching)"]
    pairs = client.get("/api/v1/materials/aisi_1045/treatments").json()
    assert len(pairs["items"]) == 6 and pairs["interface"]["furnace_ui_max_c"] == 1600
    assert all(p["compatibility_status"] != "supported" and p["protocol"]["fully_specified"] is False
               for p in pairs["items"])


def test_etag_cache(client):
    r = client.get("/api/v1/materials")
    r2 = client.get("/api/v1/materials", headers={"If-None-Match": r.headers["ETag"]})
    assert r2.status_code == 304


def test_unknown_material_404(client):
    r = client.get("/api/v1/materials/aisi_4140")
    assert r.status_code == 404 and r.json()["error"]["code"] == "not_found"
    assert r.json()["error"]["request_id"].startswith("req_")


def test_simulation_envelope_and_nulls(client):
    r = client.post("/api/v1/simulations", json=BASE)
    assert r.status_code == 200
    body = r.json()
    assert ENVELOPE <= set(body)
    assert body["simulation_status"] == "insufficient_evidence"
    assert all(v is None for v in body["results"].values())
    assert body["micrograph"] is None
    assert any(w["code"] == "NO_SUITABLE_MICROGRAPH" for w in body["warnings"])
    assert body["thermal_history"] == [] and body["schematic_cycle"]["time_basis"] == "schematic_not_to_scale"
    assert r.headers["X-Request-ID"] == body["request_id"]


@pytest.mark.parametrize("extra", [{"cooling_profile_id": "x"}, {"cooling_medium": "water"},
                                   {"model_version": "x"}, {"phase_percentages": {"martensite": 99}}])
def test_sec01_forbidden_fields_rejected(client, extra):
    r = client.post("/api/v1/simulations", json={**BASE, **extra})
    assert r.status_code == 422 and r.json()["error"]["code"] == "validation_error"


@pytest.mark.parametrize("field,value", [("target_temperature_c", -5), ("target_temperature_c", 1601),
                                         ("hold_time_min", -1), ("hold_time_min", 99999),
                                         ("target_temperature_c", "NaN"), ("material_id", "aisi_4140"),
                                         ("treatment_id", "carburize")])
def test_api01_structural_validation(client, field, value):
    assert client.post("/api/v1/simulations", json={**BASE, field: value}).status_code == 422


def test_domain_block_is_200_invalid_input(client):
    r = client.post("/api/v1/simulations", json={**BASE, "target_temperature_c": 1600})
    assert r.status_code == 200 and r.json()["simulation_status"] == "invalid_input"
    v = client.post("/api/v1/simulations/validate", json={**BASE, "target_temperature_c": 1600}).json()
    assert v["can_run"] is False and v["predicted_status"] == "invalid_input"


def test_determinism_over_http(client):
    a = client.post("/api/v1/simulations", json=BASE).json()
    b = client.post("/api/v1/simulations", json=BASE).json()
    assert a.pop("request_id") != b.pop("request_id")
    assert a == b


@pytest.mark.parametrize("m,t", list(itertools.product(["aisi_1045", "aisi_8620", "astm_a48_class_30"],
                                                       ["quench", "temper", "anneal", "normalize", "austemper",
                                                        "martemper"])))
def test_all_pairs_answer_honestly(client, m, t):
    body = client.post("/api/v1/simulations", json={**BASE, "material_id": m, "treatment_id": t,
                                                    "target_temperature_c": 600}).json()
    assert body["simulation_status"] in ("insufficient_evidence", "unsupported")
    assert all(v is None for v in body["results"].values())
    assert body["explanation"]["compatibility_reason"]


def test_locale_en(client):
    body = client.post("/api/v1/simulations", json={**BASE, "locale": "en"}).json()
    assert body["protocol"]["stages"][0]["label"] == "Heating to target temperature"


def test_payload_too_large(client):
    r = client.post("/api/v1/simulations", content=b"{" + b" " * 40000 + b"}",
                    headers={"content-type": "application/json"})
    assert r.status_code == 413


def test_rate_limit_429(settings_factory):
    from app.main import create_app
    from fastapi.testclient import TestClient

    c = TestClient(create_app(settings_factory(simulation_rate_limit_per_minute=2)))
    codes = [c.post("/api/v1/simulations", json=BASE).status_code for _ in range(3)]
    assert codes == [200, 200, 429]


def test_knowledge_and_practice(client):
    k = client.get("/api/v1/knowledge?category=glossary").json()["items"]
    assert {"perlita", "martensita", "austenita"} <= {x["slug"] for x in k}
    assert client.get("/api/v1/knowledge/no-existe").status_code == 404
    p = client.get("/api/v1/practice?locale=en").json()["items"]
    assert p and all(0 <= q["correct_index"] < len(q["options"]) for q in p)
    srcs = client.get("/api/v1/sources").json()["items"]
    assert all(s["verification_status"] == "unverified" for s in srcs)


def test_micrograph_absent_is_404(client):
    assert client.get("/api/v1/micrographs/x").status_code == 404
    assert client.get("/api/v1/micrographs").json()["items"] == []


def test_openapi_exported_matches(client):
    """El OpenAPI del repositorio debe coincidir con el generado (scripts/gen_contracts.py)."""
    exported = Path(__file__).resolve().parents[2] / "packages" / "contracts" / "openapi.json"
    live = client.get("/openapi.json").json()
    assert json.loads(exported.read_text()) == live, "Ejecuta: uv run python scripts/gen_contracts.py"


def test_production_refuses_unreviewed_snapshot(settings_factory):
    from app.main import create_app
    from fastapi.testclient import TestClient

    c = TestClient(create_app(settings_factory(ferrolab_env="production")))
    r = c.get("/api/v1/materials")
    assert r.status_code == 503 and r.json()["error"]["code"] == "dependency_unavailable"
    assert c.get("/docs").status_code == 404


def test_allowed_origins_from_comma_separated_env(monkeypatch):
    from app.core.config import Settings

    monkeypatch.setenv("ALLOWED_ORIGINS", "http://a.example, http://b.example")
    assert Settings(_env_file=None).allowed_origins == ["http://a.example", "http://b.example"]


def test_serve_web_app_same_origin(settings_factory, tmp_path):
    from fastapi.testclient import TestClient

    from app.main import create_app

    (tmp_path / "index.html").write_text("<html>FERROLAB</html>")
    c = TestClient(create_app(settings_factory(serve_web_app=True, web_app_dir=tmp_path)))
    page = c.get("/")
    assert page.status_code == 200 and "FERROLAB" in page.text
    assert "frame-ancestors" not in page.headers.get("content-security-policy", "")
    api = c.get("/api/v1/health/live")
    assert api.json() == {"status": "ok"} and "default-src 'none'" in api.headers["content-security-policy"]
