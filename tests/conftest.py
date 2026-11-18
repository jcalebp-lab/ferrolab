from __future__ import annotations

import copy
import json
import os
import sys
import time
from pathlib import Path

import jwt
import pytest
from fastapi.testclient import TestClient
from ferrolab_fse import DatasetSnapshot

ROOT = Path(__file__).resolve().parents[1]
SEED = ROOT / "database" / "seeds" / "catalog_seed.json"
sys.path.insert(0, str(ROOT / "services" / "api"))

from app.core.config import Settings  # noqa: E402
from app.main import create_app  # noqa: E402


@pytest.fixture(scope="session")
def seed_data() -> dict:
    return json.loads(SEED.read_text(encoding="utf-8"))


@pytest.fixture()
def seed_snapshot(seed_data) -> DatasetSnapshot:
    return DatasetSnapshot.model_validate(seed_data)


@pytest.fixture()
def synthetic_published_snapshot(seed_data) -> DatasetSnapshot:
    """Snapshot SINTÉTICO para probar la tubería (parsing/álgebra), NO metalurgia.

    Todas las cifras son marcadores de prueba (p. ej. 111, 222) atribuidos a una
    fuente llamada explícitamente «SYNTHETIC TEST FIXTURE». Nunca se usa en seeds.
    """
    d = copy.deepcopy(seed_data)
    d["dataset_version"] = "test-synthetic"
    d["contains_unreviewed_content"] = False
    d["sources"].append({"id": "src_synthetic", "kind": "editorial", "title": "SYNTHETIC TEST FIXTURE — NOT DATA",
                         "verification_status": "verified"})

    def ev(id, **kw):
        base = {"id": id, "source_id": "src_synthetic", "locator": "fixture", "claim_es": "sintético",
                "claim_en": "synthetic", "evidence_kind": "literature", "review_status": "published"}
        base.update(kw)
        d["evidence"].append(base)

    ev("ev_t_range", value=111.0, unit="°C")
    ev("ev_heat_rate", value=1.0, unit="°C/s")
    ev("ev_transfer", value=10.0, unit="s")
    ev("ev_cool", value=60.0, unit="s")
    ev("ev_hv", evidence_kind="measured", evidence_level="validated", method="synthetic_lookup",
       material_id="aisi_1045", treatment_id="quench", initial_condition_id="ic_aisi_1045_unspecified",
       protocol_id="prot_aisi_1045_quench", quantity_code="hardness", value=222.0, unit="HV",
       validity={"temperature_min_c": 100.0, "temperature_max_c": 300.0, "hold_min_s": 0.0, "hold_max_s": 3600.0})
    for ic in d["initial_conditions"]:
        if ic["id"] == "ic_aisi_1045_unspecified":
            ic["review_status"] = "published"
    for p in d["material_treatments"]:
        if p["material_id"] == "aisi_1045" and p["treatment_id"] == "quench":
            p.update(quantitative_outputs_enabled=True, review_status="published", temperature_min_c=100.0,
                     temperature_max_c=300.0, temperature_evidence_id="ev_t_range")
    for pr in d["protocols"]:
        if pr["id"] == "prot_aisi_1045_quench":
            pr["review_status"] = "published"
            pr["version"] = "test-1"
            pr["stages"] = [
                {"ordinal": 1, "kind": "heat", "label_key": "heat_to_austenitizing", "end_level": "target",
                 "end_temperature_mode": "user_target", "duration_mode": "rate", "rate_c_per_s": 1.0,
                 "duration_evidence_id": "ev_heat_rate"},
                {"ordinal": 2, "kind": "hold", "label_key": "hold_austenitizing", "end_level": "target",
                 "end_temperature_mode": "user_target", "duration_mode": "user_hold"},
                {"ordinal": 3, "kind": "transfer", "label_key": "transfer_to_medium", "end_level": "target",
                 "end_temperature_mode": "user_target", "duration_mode": "value", "duration_s": 10.0,
                 "duration_evidence_id": "ev_transfer"},
                {"ordinal": 4, "kind": "cool", "label_key": "quench_cool", "end_level": "ambient",
                 "end_temperature_mode": "ambient", "duration_mode": "value", "duration_s": 60.0,
                 "duration_evidence_id": "ev_cool"},
            ]
    return DatasetSnapshot.model_validate(d)


TEST_SECRET = "test-only-secret-not-used-anywhere-else-0123456789"


def make_token(sub: str, secret: str = TEST_SECRET, aud: str = "authenticated", exp_in: int = 600) -> str:
    now = int(time.time())
    return jwt.encode({"sub": sub, "aud": aud, "iat": now, "exp": now + exp_in}, secret, algorithm="HS256")


@pytest.fixture()
def client() -> TestClient:
    s = Settings(_env_file=None, ferrolab_env="test", supabase_jwt_secret=TEST_SECRET)
    return TestClient(create_app(s))


@pytest.fixture()
def settings_factory():
    def f(**kw):
        base = {"ferrolab_env": "test", "supabase_jwt_secret": TEST_SECRET}
        return Settings(_env_file=None, **{**base, **kw})
    return f


DB_URL = os.environ.get("TEST_DATABASE_URL")


@pytest.fixture()
def token():
    return make_token
