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


def test_catalog_three_materials_seven_treatments(client):
    mats = client.get("/api/v1/materials").json()["items"]
    assert [m["id"] for m in mats] == ["aisi_1045", "aisi_8620", "en_gjl_250"]
    assert mats[0]["compositions"] and mats[1]["compositions"] and mats[2]["compositions"] == []
    assert mats[2]["family"] == "gray_cast_iron"
    trts = client.get("/api/v1/treatments?locale=en").json()["items"]
    assert [t["name"] for t in trts] == ["Quenching", "Tempering", "Quench and temper", "Annealing", "Normalizing",
                                         "Austempering", "Martempering (marquenching)"]
    pairs = client.get("/api/v1/materials/aisi_1045/treatments").json()
    assert len(pairs["items"]) == 7 and pairs["interface"]["furnace_ui_max_c"] == 1600
    for p in pairs["items"]:
        ref = p["reference_protocol"]
        assert ref["is_reference"] and ref["evidence_status"] == "source_verified" and ref["sources"]
        assert p["protocols"][0]["id"] == ref["id"]  # el de referencia va primero
        assert p["result_level"] == "A" and p["headline"]["code"] in ("HEADLINE_VALID", "HEADLINE_DEPENDENCY")


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
    assert body["simulation_status"] == "completed"
    res = body["results"]
    assert res["grain_size"]["unit"] == "ASTM_G" and res["grain_size"]["method"] == "lee_2008_astm_e112"
    assert res["mechanical_properties"]["tensile_strength"]["unit"] == "MPa"
    assert res["hardness"]["evidence_kind"] == "modeled" and res["hardness"]["model_version"]
    # Micrografía real comparable (martensita en SAE 1045), con licencia verificada.
    assert body["micrograph"]["match_quality"] == "comparable" and body["micrograph"]["license_verified"]
    assert body["related_micrographs"]
    assert not any(w["code"] in ("MODEL_ESTIMATE_NOT_REVIEWED", "REVIEW_PENDING") for w in body["warnings"])
    assert {"MODEL_ESTIMATES", "GRAIN_MODEL", "STRENGTH_FROM_HARDNESS"} <= {a["code"] for a in body["assumptions"]}
    assert body["thermal_history"] and body["schematic_cycle"] is None
    assert body["protocol_card"]["params"]["furnace_temperature"]["ref"] == 845
    assert body["result_level"] in ("A", "B") and body["headline"]["code"].startswith("HEADLINE_")
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


@pytest.mark.parametrize("m,t", list(itertools.product(["aisi_1045", "aisi_8620", "en_gjl_250"],
                                                       ["quench", "temper", "anneal", "normalize", "austemper",
                                                        "martemper"])))
def test_all_pairs_answer_honestly(client, m, t):
    body = client.post("/api/v1/simulations", json={**BASE, "material_id": m, "treatment_id": t,
                                                    "target_temperature_c": 600}).json()
    # 600 °C no austeniza: solo el revenido (estado templado supuesto y declarado) puede dar cifra modelada.
    if t == "temper" and m != "en_gjl_250":
        assert body["simulation_status"] in ("partial_result", "completed")
        assert body["results"]["hardness"]["evidence_kind"] == "modeled"
        assert any(w["code"] == "DEPENDENCY_REFERENCE" for w in body["warnings"])
    else:
        assert body["simulation_status"] in ("insufficient_evidence", "unsupported")
        res = dict(body["results"])
        if m == "en_gjl_250":  # referencia de la norma, no un resultado del tratamiento
            assert set(res.pop("mechanical_properties")) == {"tensile_strength_min"}
            hd = res.pop("hardness")
            assert hd is None or hd["method"] == "literature_reference_other_specimen"
        assert all(v is None for v in res.values())
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
    # Solo las fuentes realmente consultadas por el proyecto están marcadas como verificadas.
    verified = {s["id"] for s in srcs if s["verification_status"] == "verified"}
    assert "src_voestalpine_1045" in verified and "src_vanguard_8620" in verified
    assert {"src_matweb_8620_carb", "src_asm_gray_ht", "src_jmrt_2022_agi"}.isdisjoint(verified)


def test_micrograph_library_only_verified_licenses(client):
    assert client.get("/api/v1/micrographs/x").status_code == 404
    items = client.get("/api/v1/micrographs").json()["items"]
    assert items, "la biblioteca de micrografías reales no debe estar vacía"
    for m in items:
        assert m["license_verified"] is True and m["license_code"] and m["license_url"] and m["author"]
        assert m["page_url"].startswith("https://commons.wikimedia.org/") and m["specimen"]
        assert m["constituents"] and m["match_quality"] in ("illustrative", "comparable", "exact")
    # Copia servida por FERROLAB cuando existe; si no, miniatura oficial de Commons (960 px).
    assert all(m["display_url"] or m["thumbnail_url"].startswith(("https://upload.wikimedia.org/",
                                                                     "https://thumb.wikimedia.org/")) for m in items)
    served = [m for m in items if m["display_url"]]
    assert served
    r = client.get(served[0]["display_url"])
    assert r.status_code == 200 and r.headers["content-type"] == "image/jpeg" and len(r.content) < 600_000


def test_simulation_offers_related_real_micrographs(client):
    body = client.post("/api/v1/simulations", json={"material_id": "aisi_1045", "treatment_id": "anneal",
                                                    "target_temperature_c": 830, "hold_time_min": 60}).json()
    rel = body["related_micrographs"]
    assert rel and all("pearlite" in m["constituents"] or "proeutectoid_ferrite" in m["constituents"] for m in rel)
    gray = client.post("/api/v1/simulations", json={"material_id": "en_gjl_250", "treatment_id": "normalize",
                                                    "target_temperature_c": 900, "hold_time_min": 30}).json()
    grel = gray["related_micrographs"]
    # Primero las fundiciones grises; después, ejemplos de la MATRIZ en otras muestras (nunca otra cosa).
    fams = [m["family"] for m in grel]
    assert fams[0] == "gray_cast_iron" and fams == sorted(fams, key=lambda f: f != "gray_cast_iron")
    assert all(m["family"] == "gray_cast_iron" or "pearlite" in m["constituents"] for m in grel)


@pytest.mark.parametrize("m,t", list(itertools.product(
    ["aisi_1045", "aisi_8620", "en_gjl_250"], ["quench", "temper", "anneal", "normalize", "austemper", "martemper"])))
def test_every_combination_shows_real_micrographs(client, m, t):
    body = client.post("/api/v1/simulations", json={"material_id": m, "treatment_id": t,
                                                    "target_temperature_c": 850, "hold_time_min": 30}).json()
    rel = body["related_micrographs"]
    assert rel and all(x["license_verified"] and x["page_url"] and x["author"] for x in rel)


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
    from app.main import create_app
    from fastapi.testclient import TestClient

    (tmp_path / "index.html").write_text("<html>FERROLAB</html>")
    c = TestClient(create_app(settings_factory(serve_web_app=True, web_app_dir=tmp_path)))
    page = c.get("/")
    assert page.status_code == 200 and "FERROLAB" in page.text
    assert "frame-ancestors" not in page.headers.get("content-security-policy", "")
    api = c.get("/api/v1/health/live")
    assert api.json() == {"status": "ok"} and "default-src 'none'" in api.headers["content-security-policy"]
