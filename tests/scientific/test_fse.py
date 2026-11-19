"""Pruebas científicas obligatorias (doc 04 §9, doc 13 §3, GATE-C1…C8).

Ninguna prueba afirma un valor metalúrgico esperado. Las cifras que aparecen
son entradas del estudiante o marcadores sintéticos de la tubería.
"""

from __future__ import annotations

import ast
import itertools
import json
from pathlib import Path

import pytest
from ferrolab_fse import ScientificEngine, SimulationRequest
from ferrolab_fse.enums import CompatibilityStatus, MaterialId, SimulationStatus, TreatmentId
from ferrolab_fse.models import ModelNotActivated, andrews, jmak
from ferrolab_fse.models import koistinen_marburger as km
from ferrolab_fse.models.hardness import convert_with_table
from ferrolab_fse.result import ResultFact, Results
from ferrolab_fse.snapshot import ModelVersion
from ferrolab_fse.thermal import ThermalHistoryError, ThermalStage, validate_stages
from hypothesis import given, settings
from hypothesis import strategies as st
from pydantic import ValidationError

FSE_DIR = Path(__file__).resolve().parents[2] / "packages" / "fse" / "ferrolab_fse"


def req(m="aisi_1045", t="quench", temp=850.0, hold=30.0, **kw) -> SimulationRequest:
    return SimulationRequest(material_id=m, treatment_id=t, target_temperature_c=temp, hold_time_min=hold, **kw)


# SCI-01 ---------------------------------------------------------------------
def test_sci01_matrix_has_18_pairs_each_with_reference_protocol(seed_snapshot):
    pairs = {(p.material_id, p.treatment_id): p for p in seed_snapshot.material_treatments}
    assert set(pairs) == set(itertools.product(MaterialId, TreatmentId))
    for p in pairs.values():
        # Sin evidencia MEDIDA publicada, la ruta experimental sigue apagada (las cifras vienen de modelos).
        assert p.quantitative_outputs_enabled is False
        assert p.review_status == "draft"
        assert p.reason_es and p.reason_en
        prot = seed_snapshot.protocol(p.protocol_id)
        assert prot is not None and prot.is_reference and prot.evidence_status == "source_verified"


def test_db01_catalog_has_no_invented_numbers(seed_data):
    """DB-01: toda cifra del seed tiene fuente y localizador; no hay durezas, curvas ni micrografías propias."""
    ev = {e["id"]: e for e in seed_data["evidence"]}
    src = {s["id"]: s for s in seed_data["sources"]}
    for m in seed_data["materials"]:
        for c in m["compositions"]:
            assert ev[c["evidence_id"]]["locator"] and src[ev[c["evidence_id"]]["source_id"]]["verification_status"] == "verified"
        if m["family"] == "gray_cast_iron":
            assert m["compositions"] == []  # ASTM A48 no fija composición
    assert seed_data["model_versions"] == []
    # Micrografías: solo reales, con licencia libre verificada, autor y página de la fuente.
    for m in seed_data["micrographs"]:
        assert m["license_verified"] and m["license_code"] and m["author"] and m["page_url"]
        assert src[m["source_id"]]["verification_status"] == "verified"
    numeric = [e for e in seed_data["evidence"] if e.get("value") is not None]
    # Única cifra: el límite de bloqueo (fusión del Fe), en borrador.
    assert [e["id"] for e in numeric] == ["ev_fe_melting_point"]
    assert numeric[0]["review_status"] == "draft"
    for p in seed_data["material_treatments"]:
        assert p.get("temperature_min_c") is None and p.get("hold_min_s") is None


# SCI-02 ---------------------------------------------------------------------
def test_sci02_extreme_temperature_blocked(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    for m in MaterialId:
        r = eng.simulate(req(m=m, temp=1600))
        assert r.simulation_status == SimulationStatus.INVALID_INPUT
        assert any(w.code == "TEMPERATURE_ABOVE_PHYSICAL_LIMIT" and w.severity == "blocking" for w in r.warnings)
        assert r.thermal_history == [] and r.schematic_cycle is None


def test_sci02_structural_range_rejected():
    for bad in (-1, 1600.1, float("nan"), float("inf")):
        with pytest.raises(ValidationError):
            req(temp=bad)
    for bad in (-0.1, float("nan"), float("inf")):
        with pytest.raises(ValidationError):
            req(hold=bad)


def test_sci02_published_protocol_range_enforced(synthetic_published_snapshot):
    eng = ScientificEngine(synthetic_published_snapshot)
    r = eng.simulate(req(temp=400))  # rango sintético 100–300
    assert r.simulation_status == SimulationStatus.INVALID_INPUT
    assert any(w.code == "TEMPERATURE_OUTSIDE_PROTOCOL_RANGE" for w in r.warnings)


def test_extra_fields_rejected():
    with pytest.raises(ValidationError):
        SimulationRequest(material_id="aisi_1045", treatment_id="quench", target_temperature_c=850,
                          hold_time_min=10, cooling_profile_id="x")


# SCI-03 ---------------------------------------------------------------------
@pytest.mark.parametrize("m,t", list(itertools.product(MaterialId, TreatmentId)))
def test_sci03_all_seed_pairs_only_modeled_estimates(seed_snapshot, m, t):
    """Sin evidencia revisada, las únicas cifras son estimaciones de modelo (D-26), siempre etiquetadas."""
    r = ScientificEngine(seed_snapshot).simulate(req(m=m, t=t, temp=500, hold=30))
    res = r.results
    assert r.protocol_version is None
    if m == "astm_a48_class_30":
        # Solo la referencia de la norma (colada, sin tratar), nunca un cálculo del tratamiento.
        assert res.grain_size is None and set(res.mechanical_properties) == {"tensile_strength_min"}
        assert res.mechanical_properties["tensile_strength_min"].evidence_kind == "literature"
    elif t != "temper":
        assert res.grain_size is None and res.mechanical_properties is None
    hd = res.hardness
    if m == "astm_a48_class_30" and hd is not None:  # dureza publicada de otra muestra, nunca un cálculo
        assert hd.method == "literature_reference_other_specimen" and hd.evidence_kind == "literature"
        hd = None
    facts = [hd] if hd else []
    for group in (res.phase_fractions, res.microconstituent_fractions):
        facts += list((group or {}).values())
    for f in facts:
        assert f.evidence_kind == "modeled" and f.evidence_level == "bounded_estimate"
        assert f.model_version and f.source_ids and f.validity["review"] == "not_reviewed_by_specialist"
    if m == "astm_a48_class_30":
        assert not facts and r.result_level in ("B", "C")
    elif t != "temper":
        # 500 °C queda fuera de todo rango de austenización: exploración cualitativa, sin cifras.
        assert not facts and r.result_level == "B"
        assert any(w.code == "OUTSIDE_PROTOCOL_RANGE" for w in r.warnings)
    else:  # 500 °C está dentro del revenido documentado del 1045 (400–650) y del 8620 (200–650)
        assert res.hardness is not None and res.hardness.method == "kang_lee_2014_tempering"
        assert r.result_level == "A"


def test_kang_lee_2014_reproduces_paper_examples():
    """El artículo da C = 12.7 (AISI 1040) y 10.3 (AISI 4340)."""
    from ferrolab_fse.metallurgy.hardness import tempered_martensite_hv, tempering_c
    c1040 = {"C": 0.4, "Mn": 0.75, "Si": 0.23}
    assert round(tempering_c(c1040), 1) == 12.7
    assert round(tempering_c({**c1040, "Ni": 1.85, "Cr": 0.8, "Mo": 0.25}), 1) == 10.3
    # Más temperatura o más tiempo => menos dureza.
    assert tempered_martensite_hv(c1040, 600, 3600) < tempered_martensite_hv(c1040, 400, 3600)
    assert tempered_martensite_hv(c1040, 400, 36000) < tempered_martensite_hv(c1040, 400, 3600)


def test_temper_outside_model_validity_has_no_hardness(seed_snapshot):
    r = ScientificEngine(seed_snapshot).simulate(req(m="aisi_1045", t="temper", temp=100, hold=60))
    assert r.results.hardness is None and r.result_level == "B"
    assert any(w.code == "OUTSIDE_PROTOCOL_RANGE" for w in r.warnings)
    # Variante voestalpine (150–200 °C) sin tiempo documentado: sin tiempo no hay dureza de revenido.
    v = ScientificEngine(seed_snapshot).simulate(req(m="aisi_1045", t="temper", temp=180, hold=0,
                                                     protocol_id="prot_1045_temper_voest"))
    assert v.results.hardness is None
    assert any(w.code == "MODEL_TEMPER_OUTSIDE_VALIDITY" for w in v.warnings)


def test_model_estimates_at_recommended_practice(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    r = eng.simulate(req(m="aisi_1045", t="quench", temp=845, hold=7.5))
    assert r.simulation_status == SimulationStatus.COMPLETED
    gs = r.results.grain_size
    assert gs.unit == "ASTM_G" and 6 <= gs.value <= 10 and gs.uncertainty["austenite_um"] > 0
    mp = r.results.mechanical_properties
    assert mp["tensile_strength"].value > mp["yield_strength"].value > 0
    assert r.headline["code"] == "HEADLINE_VALID" and r.result_level == "A"
    micro = r.results.microconstituent_fractions
    assert micro and abs(sum(f.value for f in micro.values()) - 1) < 2e-3
    assert "martensite" in micro and r.results.hardness.unit == "HV"
    u = r.results.hardness.uncertainty
    assert u["min"] <= r.results.hardness.value <= u["max"]
    assert {d["kind"] for d in r.diagrams} == {"TTT", "CCT"}
    assert all(d["user_path"] for d in r.diagrams)
    assert r.thermal_history and r.microstructure_illustration["kind"] == "generated_illustration"
    assert not any(w.severity == "limitation" for w in r.warnings)
    bad = eng.simulate(req(m="aisi_1045", t="quench", temp=1100, hold=7.5))
    assert any(w.code == "OUTSIDE_PROTOCOL_RANGE" for w in bad.warnings) and bad.results.hardness is None
    v = eng.validate(req(m="aisi_1045", t="quench", temp=845, hold=7.5))
    assert v.protocol["params"]["furnace_temperature"]["min"] == 820


def test_sci03_fraction_balance_and_taxonomy():
    def f(v, basis="volume_fraction_phases"):
        return ResultFact(value=v, unit="fraction", fraction_basis=basis, method="m", evidence_kind="measured",
                          evidence_level="validated", source_ids=["s"], dataset_version="d")

    with pytest.raises(ValidationError):  # perlita no es fase (GATE-C5)
        Results(phase_fractions={"ferrite": f(0.3), "cementite": f(0.1), "pearlite": f(0.6)})
    with pytest.raises(ValidationError):  # suma > 1
        Results(phase_fractions={"ferrite": f(0.8), "cementite": f(0.5)})
    with pytest.raises(ValidationError):  # bases distintas
        Results(phase_fractions={"ferrite": f(0.5), "cementite": f(0.1, basis="other")})
    with pytest.raises(ValidationError):  # fracción fuera de [0,1]
        f(1.5)
    Results(phase_fractions={"ferrite": f(0.4), "cementite": f(0.1)})  # suma parcial válida, sin normalizar


# GATE-C1 / SCI-09 trazabilidad -----------------------------------------------
def test_gate_c1_number_without_source_rejected():
    with pytest.raises(ValidationError):
        ResultFact(value=1.0, unit="HV", method="m", evidence_kind="measured", evidence_level="validated",
                   source_ids=[], dataset_version="d")
    with pytest.raises(ValidationError):
        ResultFact(value=1.0, unit="HV", method="m", evidence_kind="illustrative", evidence_level="qualitative",
                   source_ids=["s"], dataset_version="d")
    with pytest.raises(ValidationError):
        ResultFact(value=1.0, unit="fraction", method="m", evidence_kind="modeled", evidence_level="bounded_estimate",
                   source_ids=["s"], dataset_version="d")  # modelado sin model_version


# SCI-05 revenido -----------------------------------------------------------------
def test_sci05_temper_dependency_on_prior_state(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    for m in ("aisi_1045", "aisi_8620"):
        r = eng.simulate(req(m=m, t="temper", temp=450, hold=30))
        assert r.compatibility_status == CompatibilityStatus.CONDITIONAL
        assert r.headline["code"] == "HEADLINE_DEPENDENCY"
        assert any(w.code == "DEPENDENCY_REFERENCE" for w in r.warnings)
        assert r.initial_condition.hardened is True
        assert r.model_estimate["prior_state"]["source"] == "reference"
        assert r.results.hardness.evidence_kind == "modeled"
        # Demostración teórica: sin estado de partida no hay cifras.
        t = eng.simulate(req(m=m, t="temper", temp=450, hold=30, prior_mode="theory"))
        assert t.results.hardness is None and t.result_level == "C"
        # Muestra del historial: austenizada a otra temperatura => otro estado de partida.
        h = eng.simulate(req(m=m, t="temper", temp=450, hold=30, prior_mode="history", prior_temperature_c=760,
                             prior_hold_min=10))
        assert any(w.code == "DEPENDENCY_HISTORY" for w in h.warnings)
        assert h.model_estimate["prior_state"]["quench_temperature_c"] == 760


# SCI-06 8620 ---------------------------------------------------------------------
def test_sci06_8620_not_carburized(seed_snapshot):
    r = ScientificEngine(seed_snapshot).simulate(req(m="aisi_8620"))
    assert r.initial_condition.carburized is False
    assert any(w.code == "CARBURIZED_CASE_NOT_ASSUMED" for w in r.warnings)
    assert r.results.hardness is None or r.results.hardness.evidence_kind == "modeled"


# SCI-07 A48 ----------------------------------------------------------------------
def test_sci07_a48_is_cast_iron_without_steel_models(seed_snapshot):
    mat = seed_snapshot.material("astm_a48_class_30")
    assert mat.family == "gray_cast_iron" and mat.compositions == []
    for t in TreatmentId:
        r = ScientificEngine(seed_snapshot).simulate(req(m="astm_a48_class_30", t=t, temp=500))
        assert r.compatibility_status in (CompatibilityStatus.CONDITIONAL, CompatibilityStatus.SUPPORTED)
        assert any(w.code == "CAST_IRON_NO_STEEL_MODELS" for w in r.warnings)
        assert r.diagrams == [] and r.results.microconstituent_fractions is None
        assert r.results.hardness is None or r.results.hardness.method == "literature_reference_other_specimen"
        assert r.microstructure_illustration["graphite"] == "type_a_flakes"


# SCI-08 determinismo ------------------------------------------------------------
@settings(max_examples=40, deadline=None)
@given(
    m=st.sampled_from(list(MaterialId)),
    t=st.sampled_from(list(TreatmentId)),
    temp=st.floats(min_value=0, max_value=1600, allow_nan=False),
    hold=st.floats(min_value=0, max_value=1440, allow_nan=False),
)
def test_sci08_determinism(seed_data, m, t, temp, hold):
    from ferrolab_fse import DatasetSnapshot

    snap = DatasetSnapshot.model_validate(seed_data)
    a = ScientificEngine(snap).simulate(req(m=m, t=t, temp=temp, hold=hold))
    b = ScientificEngine(DatasetSnapshot.model_validate(seed_data)).simulate(req(m=m, t=t, temp=temp, hold=hold))
    assert a.scientific_content() == b.scientific_content()
    assert a.request_hash == b.request_hash


def test_sci08_hash_changes_with_dataset(seed_snapshot, synthetic_published_snapshot):
    a = ScientificEngine(seed_snapshot).request_hash(req())
    b = ScientificEngine(synthetic_published_snapshot).request_hash(req())
    assert a != b


# SCI-09 modelos --------------------------------------------------------------------
def test_sci09_models_disabled_without_gate():
    with pytest.raises(ModelNotActivated):
        km.evaluate(None, 20)
    mv = ModelVersion(id="km_x", model_code="koistinen_marburger", version="1", approved=True,
                      parameters={"ms_c": 1.0, "alpha_per_c": 1.0}, parameter_evidence_ids={"ms_c": "e"},
                      source_id="s", golden_case_ids=["g"])
    with pytest.raises(ModelNotActivated):  # falta evidencia de un parámetro
        km.evaluate(mv, 0)
    with pytest.raises(ModelNotActivated):
        andrews.estimate_ms(None, {"C": 0.1})
    with pytest.raises(ModelNotActivated):
        jmak.evaluate_isothermal(None, 1.0, isothermal=True)


def test_sci09_model_algebra_only():
    # Álgebra con números sintéticos, no metalurgia.
    assert km.km_transformed_fraction(ms_c=10, temperature_c=20, alpha_per_c=0.5) == 0.0
    assert 0 < km.km_transformed_fraction(ms_c=10, temperature_c=0, alpha_per_c=0.5) < 1
    assert jmak.jmak_fraction(0, 1, 1) == 0.0
    mv = ModelVersion(id="j", model_code="jmak", version="1", approved=True, parameters={"k": 1.0, "n": 1.0},
                      parameter_evidence_ids={"k": "e", "n": "e"}, source_id="s", golden_case_ids=["g"])
    with pytest.raises(ValueError):  # JMAK no se aplica a CCT
        jmak.evaluate_isothermal(mv, 1.0, isothermal=False)


def test_e140_conversion_rejects_out_of_table():
    table = [(1.0, 10.0), (2.0, 20.0)]  # sintética
    assert convert_with_table(1.5, table) == 15.0
    with pytest.raises(ValueError):
        convert_with_table(3.0, table)
    with pytest.raises(ValueError):
        convert_with_table(1.0, [])


def test_no_hardcoded_coefficients_in_models():
    """Ningún módulo de modelos contiene literales numéricos distintos de 0/1."""
    for path in (FSE_DIR / "models").glob("*.py"):
        tree = ast.parse(path.read_text())
        nums = {n.value for n in ast.walk(tree) if isinstance(n, ast.Constant) and isinstance(n.value, float | int)
                and not isinstance(n.value, bool)}
        assert nums <= {0, 1, 2}, f"{path.name}: {nums}"


# SCI-10 historial térmico ---------------------------------------------------------
def test_sci10_physical_history_invariants(synthetic_published_snapshot):
    r = ScientificEngine(synthetic_published_snapshot).simulate(req(temp=200, hold=1))
    pts = r.thermal_history
    assert pts and r.schematic_cycle is None
    ts = [p.t_s for p in pts]
    assert ts == sorted(ts) and len(set(ts)) == len(ts)
    assert pts[0].temperature_c == 20.0 and pts[-1].temperature_c == 20.0
    hold = next(s for s in r.thermal_stages if s.kind == "hold")
    assert hold.t_end_s - hold.t_start_s == 60.0  # 1 min del estudiante -> 60 s
    heat = r.thermal_stages[0]
    assert heat.t_end_s == 180.0  # (200-20)/1 °C/s sintético


def test_sci10_validator_rejects_bad_stages():
    s1 = ThermalStage("heat", "a", 0, 10, 20, 100, "x", ())
    with pytest.raises(ThermalHistoryError):
        validate_stages([s1, ThermalStage("hold", "b", 11, 20, 100, 100, "x", ())])  # hueco temporal
    with pytest.raises(ThermalHistoryError):
        validate_stages([s1, ThermalStage("hold", "b", 10, 20, 90, 90, "x", ())])  # salto térmico
    with pytest.raises(ThermalHistoryError):
        validate_stages([ThermalStage("cool", "c", 0, 10, 20, 100, "x", ())])  # enfriar calentando
    with pytest.raises(ThermalHistoryError):
        validate_stages([ThermalStage("heat", "a", 0, 0, 20, 100, "x", ())])  # duración nula


def test_schematic_cycle_has_only_user_numbers(no_library_snapshot):
    for t in TreatmentId:
        r = ScientificEngine(no_library_snapshot).simulate(req(m="astm_a48_class_30", t=t, temp=777, hold=13))
        cyc = r.schematic_cycle
        assert cyc is not None and cyc.time_basis == "schematic_not_to_scale"
        for s in cyc.segments:
            assert s.end_temperature_c in (None, 777)
            assert s.duration_s in (None, 13 * 60)
        if t in ("austemper", "martemper"):
            assert any(s.kind == "isothermal_hold" and s.end_temperature_c is None for s in cyc.segments)
            assert any(w.code == "NO_PROTOCOL" for w in r.warnings)


def test_hold_zero_omits_stage(no_library_snapshot):
    r = ScientificEngine(no_library_snapshot).simulate(req(m="astm_a48_class_30", hold=0))
    assert not any(s.is_user_hold for s in r.schematic_cycle.segments)
    assert any(w.code == "HOLD_ZERO" for w in r.warnings)


# Ruta cuantitativa (tubería sintética) ---------------------------------------------
def test_experimental_lookup_requires_exact_domain(synthetic_published_snapshot):
    eng = ScientificEngine(synthetic_published_snapshot)
    inside = eng.simulate(req(temp=200, hold=10))
    assert inside.simulation_status == SimulationStatus.PARTIAL_RESULT
    h = inside.results.hardness
    assert h is not None and h.unit == "HV" and h.source_ids == ["src_synthetic"]
    assert inside.protocol_version == "test-1"
    assert inside.results.phase_fractions is None
    assert any(e.usage == "supports_value" for e in inside.evidence)
    # Tiempo fuera del dominio de la evidencia: no se extrapola.
    outside = eng.simulate(req(temp=200, hold=120))
    assert outside.results.hardness is None
    assert outside.simulation_status == SimulationStatus.INSUFFICIENT_EVIDENCE


def test_gate_c3_draft_evidence_never_used(synthetic_published_snapshot):
    d = synthetic_published_snapshot.model_dump(mode="json")
    for e in d["evidence"]:
        if e["id"] == "ev_hv":
            e["review_status"] = "reviewed"
    from ferrolab_fse import DatasetSnapshot

    r = ScientificEngine(DatasetSnapshot.model_validate(d)).simulate(req(temp=200, hold=10))
    assert r.results.hardness is None


def test_unreviewed_dataset_never_quantifies(synthetic_published_snapshot):
    d = synthetic_published_snapshot.model_dump(mode="json")
    d["contains_unreviewed_content"] = True
    from ferrolab_fse import DatasetSnapshot

    r = ScientificEngine(DatasetSnapshot.model_validate(d)).simulate(req(temp=200, hold=10))
    assert r.results.hardness is None


def test_educational_pair_cannot_enable_numbers(seed_data):
    from ferrolab_fse import DatasetSnapshot

    d = json.loads(json.dumps(seed_data))
    d["material_treatments"][1]["compatibility_status"] = "educational_only"
    d["material_treatments"][1]["quantitative_outputs_enabled"] = True
    with pytest.raises(ValidationError):
        DatasetSnapshot.model_validate(d)


# GATE-C7: sin red ni IA --------------------------------------------------------------
def test_gate_c7_engine_has_no_network_or_ai_imports():
    forbidden = {"httpx", "requests", "urllib", "socket", "anthropic", "openai", "random", "time", "datetime"}
    for path in FSE_DIR.rglob("*.py"):
        tree = ast.parse(path.read_text())
        for node in ast.walk(tree):
            names = []
            if isinstance(node, ast.Import):
                names = [a.name.split(".")[0] for a in node.names]
            elif isinstance(node, ast.ImportFrom) and node.module and node.level == 0:
                names = [node.module.split(".")[0]]
            assert not (set(names) & forbidden), f"{path.name} importa {names}"


# GATE-C8: mensajes comprensibles y bilingües -------------------------------------------
def test_gate_c8_messages_localized(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    es = eng.simulate(req(locale="es", temp=1600))
    en = eng.simulate(req(locale="en", temp=1600))
    assert [w.code for w in es.warnings] == [w.code for w in en.warnings]
    for a, b in zip(es.warnings, en.warnings, strict=True):
        assert a.message and b.message and a.message != b.message
        assert "{" not in a.message and "{" not in b.message


def test_unknown_entities(seed_snapshot):
    from ferrolab_fse import UnknownEntity

    with pytest.raises(UnknownEntity):
        ScientificEngine(seed_snapshot).simulate(req(m="aisi_9999"))
    with pytest.raises(UnknownEntity):
        ScientificEngine(seed_snapshot).simulate(req(initial_condition_id="nope"))


def test_seed_file_in_sync_with_generator(seed_data):
    import importlib.util

    path = Path(__file__).resolve().parents[2] / "scripts" / "build_catalog_seed.py"
    spec = importlib.util.spec_from_file_location("bcs", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    assert mod.build() == seed_data, "Ejecuta: uv run python scripts/build_catalog_seed.py"
