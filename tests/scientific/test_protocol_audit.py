"""Auditoría obligatoria de las 18 combinaciones material × tratamiento (D-30).

Cada combinación debe tener ficha científica, protocolo de referencia o explicación de lo que falta, etapas en
orden con unidades, límites documentados, baños bien representados, fuentes verificables y un estado de evidencia
coherente entre el motor, la ficha y la interfaz (mismo contrato de la API).
"""

from __future__ import annotations

import itertools

import pytest
from ferrolab_fse import ScientificEngine, SimulationRequest
from ferrolab_fse import protocol_runtime as PR
from ferrolab_fse.enums import MaterialId, TreatmentId

COMBOS = list(itertools.product(MaterialId, TreatmentId))
ROLE_ORDER = {"preheat": 0, "austenitize": 1, "subcritical": 1, "temper": 1, "soak": 2, "transfer": 3, "quench": 4,
              "bath": 4, "equalize": 4, "furnace_cool": 5, "air_cool": 6}


def _req(m, t, **kw):
    base = dict(material_id=m, treatment_id=t, target_temperature_c=850.0, hold_time_min=10.0)
    base.update(kw)
    return SimulationRequest(**base)


def _ref_request(snap, m, t, protocol=None):
    pr = protocol or PR.choose(snap, m, t, None)
    r = PR.resolve(snap, pr, furnace_c=0, hold_s=0, use_reference=True)
    fu, ho = r.params.get("furnace_temperature"), r.params.get("hold_time")
    furnace = fu.value if fu and fu.value else (fu.max if fu and fu.max else 500.0)
    hold = ho.value if ho and ho.value else 30.0
    return _req(m.value, t.value, target_temperature_c=furnace, hold_time_min=hold, protocol_id=pr.id)


@pytest.mark.parametrize("m,t", COMBOS)
def test_each_combination_has_a_complete_sheet(seed_snapshot, m, t):
    snap = seed_snapshot
    lib = snap.protocols_for(m.value, t.value)
    assert lib, "1. sin ficha"
    ref = lib[0]
    assert ref.is_reference and ref.treatment_id == t and ref.material_id == m  # 2. tratamiento identificado
    assert snap.material(m.value) is not None and snap.conditions_for(m.value)  # 3. condición material conocida
    for pr in lib:
        # 4. protocolo de referencia o explicación concreta de lo que falta
        assert pr.objective_es and pr.name_es and (pr.evidence_status == "source_verified" or pr.missing_es)
        # 5. etapas en orden (horno → [traslado] → enfriamiento/baño → enfriamiento final)
        roles = [s.role for s in pr.stages]
        main = [ROLE_ORDER.get(r, 1) for r in roles if r not in ("austenitize_2",)]
        first_cool = next((i for i, v in enumerate(main) if v >= 3), len(main))
        assert all(v >= 3 for v in main[first_cool:]) or pr.variant_code == "carburized_double_refine"
        assert pr.stages[-1].role in ("air_cool", "quench"), f"{pr.id}: el ciclo debe terminar enfriando"
        for s in pr.stages:
            # 6. valores con unidades y 7. límites documentados con evidencia
            for lo, hi in ((s.temperature_min_c, s.temperature_max_c), (s.duration_min_s, s.duration_max_s)):
                if lo is not None and hi is not None:
                    assert lo <= hi
            if any(v is not None for v in (s.temperature_min_c, s.temperature_max_c, s.temperature_ref_c)):
                ev = snap.evidence_by_id(s.end_temperature_evidence_id)
                assert ev is not None and ev.locator
        # 8. baños: austemper/martemper tienen baño con temperatura propia (publicada o ventana de modelo)
        if t in (TreatmentId.AUSTEMPER, TreatmentId.MARTEMPER):
            bath = [s for s in pr.stages if s.kind.value == "isothermal_hold"]
            assert len(bath) == 1 and bath[0].user_param == "bath_temperature" or bath[0].end_temperature_mode == "value"
            if t == TreatmentId.MARTEMPER:
                assert bath[0].duration_mode in ("until_equalized", "user_bath_time")
        # 12. referencias verificables
        assert pr.source_ids
        for sid in pr.source_ids:
            src = snap.source(sid)
            assert src is not None and (src.url or src.doi)
            if pr.evidence_status == "source_verified":
                assert any(snap.source(x).verification_status == "verified" for x in pr.source_ids)


@pytest.mark.parametrize("m,t", COMBOS)
def test_reference_simulation_is_coherent(seed_snapshot, m, t):
    eng = ScientificEngine(seed_snapshot)
    req = _ref_request(seed_snapshot, m, t)
    v = eng.validate(req)
    r = eng.simulate(req)
    assert v.can_run and r.simulation_status.value not in ("invalid_input", "internal_error")
    # 10. mismo estado de evidencia en validación (lo que ve la interfaz antes) y simulación
    assert v.protocol["id"] == r.protocol_card["id"] == req.protocol_id
    assert r.result_level in ("A", "B", "C") and r.headline["code"].startswith("HEADLINE_")
    if r.result_level == "A":
        assert v.result_level == "A"
    # 9. no se inventan resultados: cifras solo con modelo declarado y etiquetadas
    facts = [r.results.hardness] if r.results.hardness else []
    for g in (r.results.phase_fractions, r.results.microconstituent_fractions):
        facts += list((g or {}).values())
    if m == MaterialId.ASTM_A48_CLASS_30:
        assert not facts and r.result_level == "B"
    for f in facts:
        assert f.evidence_kind == "modeled" and f.model_version and f.source_ids
    # 11. sin advertencias contradictorias: un protocolo de referencia completo no avisa de documentación incompleta
    codes = [w.code for w in r.warnings]
    assert len(codes) == len({w.params.get("_key") or w.code for w in r.warnings})
    for legacy in ("TEMPERATURE_DOMAIN_UNPUBLISHED", "HOLD_DOMAIN_UNPUBLISHED", "MISSING_VALIDATED_PROTOCOL",
                   "PAIR_NOT_QUANTITATIVE", "STAGED_PROTOCOL_PENDING", "ANNEAL_VARIANT_REQUIRED"):
        assert legacy not in codes
    assert "OUTSIDE_PROTOCOL_RANGE" not in codes
    if r.result_level == "A":
        assert r.headline["code"] in ("HEADLINE_VALID", "HEADLINE_DEPENDENCY")
        assert not [w for w in r.warnings if w.group == "protocol" and w.severity == "limitation"]


def test_every_variant_runs(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    for pr in seed_snapshot.protocols:
        r = eng.simulate(_ref_request(seed_snapshot, pr.material_id, pr.treatment_id, pr))
        assert r.thermal_history, pr.id
        if pr.evidence_status == "source_unverified":
            assert r.result_level == "C" and r.headline["code"] == "HEADLINE_UNVERIFIED"
            assert r.results.hardness is None


# --------------------------------------------------------------------------------- casos específicos
def test_temper_without_prior_quench(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    r = eng.simulate(_req("aisi_1045", "temper", target_temperature_c=500, hold_time_min=30))
    assert r.headline["code"] == "HEADLINE_DEPENDENCY" and r.model_estimate["prior_state"]["source"] == "reference"
    base = eng.simulate(_req("aisi_1045", "temper", target_temperature_c=500, hold_time_min=30,
                             initial_condition_id="ic_aisi_1045_unspecified", prior_mode="theory"))
    assert base.results.hardness is None and base.result_level == "C"


def test_8620_uncarburized_vs_carburized(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    core = eng.simulate(_req("aisi_8620", "quench", target_temperature_c=845, hold_time_min=7.5))
    assert core.initial_condition.carburized is False and core.results.hardness is not None
    case = eng.simulate(_req("aisi_8620", "quench", target_temperature_c=835, hold_time_min=10,
                             protocol_id="prot_8620_quench_single_refine"))
    assert case.initial_condition.carburized is True
    assert case.results.hardness is None and case.result_level == "B"  # la capa no se modela
    assert any(w.code == "CARBURIZED_CASE_NOT_MODELED" for w in case.warnings)
    carb = eng.simulate(_req("aisi_8620", "austemper", target_temperature_c=850, hold_time_min=10,
                             protocol_id="prot_8620_carboaustemper_400"))
    pub = carb.protocol_card["published_results"]
    assert pub and "63–50 HRC" in pub[0]["text"]  # resultado medido del caso citado, no predicción
    assert carb.results.hardness is None


def test_gray_iron_unknown_composition(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    r = eng.simulate(_req("astm_a48_class_30", "quench", target_temperature_c=870, hold_time_min=30))
    assert r.results.hardness is None and r.diagrams == []
    assert r.model_estimate.get("critical_temperatures_c") is None
    assert any("ASTM A48" in x for x in r.protocol_card["restrictions"])
    assert r.thermal_history and any(w.code == "THERMAL_CURVE_ILLUSTRATIVE" for w in r.warnings)


def test_austemper_bath_without_validated_duration(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    r = eng.simulate(_req("astm_a48_class_30", "austemper", target_temperature_c=870, hold_time_min=30))
    assert any(w.code == "BATH_TIME_UNDOCUMENTED" for w in r.warnings)
    assert r.protocol_card["params"]["bath_time"]["basis"] == "pending"
    steel = eng.simulate(_req("aisi_8620", "austemper", target_temperature_c=845, hold_time_min=7.5,
                              bath_time_min=0.1))
    assert any(w.code == "AUSTEMPER_INCOMPLETE_BAINITE" for w in steel.warnings)


def test_martemper_excessive_hold(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    r = eng.simulate(_req("aisi_1045", "martemper", target_temperature_c=845, hold_time_min=7.5, bath_time_min=120))
    assert any(w.code == "MARTEMPER_EXCESSIVE_HOLD" for w in r.warnings)


def test_temperature_outside_applicable_range(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    r = eng.simulate(_req("aisi_8620", "normalize", target_temperature_c=1000, hold_time_min=15))
    assert r.headline["code"] == "HEADLINE_OUT_OF_RANGE" and r.result_level == "B"
    assert r.results.hardness is None and r.thermal_history and r.diagrams


def test_parameter_change_invalidates_model(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    ok = eng.simulate(_req("aisi_1045", "austemper", target_temperature_c=845, hold_time_min=7.5))
    assert ok.result_level == "A"
    low = eng.simulate(_req("aisi_1045", "austemper", target_temperature_c=845, hold_time_min=7.5,
                            bath_temperature_c=250))  # bajo el Ms: deja de ser austemperizado
    assert low.result_level == "B" and low.results.hardness is None
    soft = eng.simulate(_req("aisi_1045", "quench", target_temperature_c=845, hold_time_min=60))
    assert soft.result_level == "A" and soft.headline["code"] == "HEADLINE_OUT_OF_RANGE_SOFT"


def test_physically_invalid_inputs(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    r = eng.simulate(_req("aisi_1045", "quench", target_temperature_c=1600, hold_time_min=7.5))
    assert r.simulation_status.value == "invalid_input" and r.headline["code"] == "BLOCKED"
    with pytest.raises(ValueError):
        _req("aisi_1045", "quench", target_temperature_c=float("nan"))
    with pytest.raises(ValueError):
        _req("aisi_1045", "austemper", bath_temperature_c=-5)


def test_illustration_explains_why_nothing_is_drawn(seed_snapshot):
    eng = ScientificEngine(seed_snapshot)
    ok = eng.simulate(_req("aisi_1045", "quench", target_temperature_c=845, hold_time_min=7.5))
    assert ok.microstructure_illustration["fractions"] and ok.microstructure_illustration.get("reason") is None
    cases = {
        "outside_range": _req("aisi_1045", "quench", target_temperature_c=950, hold_time_min=7.5),
        "carburized_case": _req("aisi_8620", "quench", target_temperature_c=835, hold_time_min=10,
                                protocol_id="prot_8620_quench_single_refine"),
        "not_modeled": _req("aisi_1045", "anneal", target_temperature_c=695, hold_time_min=60,
                            protocol_id="prot_1045_anneal_subcritical"),
        "theory": _req("aisi_1045", "temper", target_temperature_c=550, hold_time_min=30, prior_mode="theory"),
        "qualitative_cast_iron": _req("astm_a48_class_30", "quench", target_temperature_c=870, hold_time_min=30),
    }
    for reason, rq in cases.items():
        il = eng.simulate(rq).microstructure_illustration
        assert il["reason"] == reason and il["fractions"] is None
