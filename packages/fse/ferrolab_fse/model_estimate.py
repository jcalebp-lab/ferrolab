"""Puente entre el motor metalúrgico (ferrolab_fse.metallurgy) y el contrato de resultados del FSE.

Decisión D-26: a petición del propietario, el FSE emite ESTIMACIONES de modelos empíricos publicados
(evidence_kind=modeled, evidence_level=bounded_estimate) aunque el dataset no esté revisado. Cada cifra
lleva método, fuentes, versión de modelo, validez y banda de incertidumbre; nunca se presenta como medida.
"""

from __future__ import annotations

import hashlib
import math
from typing import Any

from .enums import EvidenceKind, EvidenceLevel, StageKind
from .metallurgy import grain as GR
from .metallurgy import practice as P
from .metallurgy.data import ASSUMPTIONS, COMPOSITION_RANGES
from .metallurgy.hardness import hv_to_hrc
from .result import EvidenceRef, ResultFact
from .thermal import ThermalHistory, ThermalPoint, ThermalStageOut

MODEL_SOURCE_CATALOG: dict[str, dict[str, Any]] = {
    "src_li_1998": {"title": "A computational model for the prediction of steel hardenability", "authors":
                    "M. V. Li, D. V. Niebuhr, L. L. Meekisho, D. G. Atteridge", "year": 1998,
                    "doi": "10.1007/s11663-998-0101-3", "url": None, "kind": "journal_article"},
    "src_collins_2023": {"title": "Steel-CCT-Predictor (implementación abierta del modelo de Li)", "authors":
                         "J. Collins et al.", "year": 2023, "doi": "10.5281/zenodo.7767620",
                         "url": "https://doi.org/10.5281/zenodo.7767620", "kind": "software"},
    "src_km_1959": {"title": "A general equation prescribing the extent of the austenite-martensite transformation",
                    "authors": "D. P. Koistinen, R. E. Marburger", "year": 1959,
                    "doi": "10.1016/0001-6160(59)90170-1", "url": None, "kind": "journal_article"},
    "src_maynier_1978": {"title": "A method for predicting the hardness of steels (Hardenability concepts with "
                         "applications to steel, AIME)", "authors": "P. Maynier, B. Jungmann, J. Dollet",
                         "year": 1978, "doi": None,
                         "url": "https://doc.comsol.com/6.1/doc/com.comsol.help.metal/metal_ug_theory.07.29.html",
                         "kind": "book_chapter"},
    "src_andrews_1965": {"title": "Empirical formulae for the calculation of some transformation temperatures",
                         "authors": "K. W. Andrews", "year": 1965, "doi": None,
                         "url": "https://www.phase-trans.msm.cam.ac.uk/map/steel/programs/ms-empirical.html",
                         "kind": "journal_article"},
    "src_kang_lee_2014": {"title": "Prediction of tempered martensite hardness incorporating the composition-dependent "
                          "tempering parameter in low alloy steels", "authors": "S. Kang, S.-J. Lee", "year": 2014,
                          "doi": "10.2320/matertrans.M2014004",
                          "url": "https://www.jstage.jst.go.jp/article/matertrans/55/7/55_M2014004/_article",
                          "kind": "journal_article"},
    "src_grange_1961": {"title": "Estimating critical ranges in heat treatment of steels", "authors": "R. A. Grange",
                        "year": 1961, "doi": None, "url": None, "kind": "journal_article"},
    "src_grossmann": {"title": "Heat treatment — quench severity (Grossmann H)", "authors": "NPTEL", "year": None,
                      "doi": None, "url": "https://nptel.ac.in/", "kind": "course"},
    "src_azom_1045": {"title": "AISI 1045 Medium Carbon Steel", "authors": "AZoM", "year": 2024, "doi": None,
                      "url": "https://www.azom.com/article.aspx?ArticleID=6130", "kind": "web"},
    "src_compraco_1045": {"title": "SAE/AISI 1045 — heat treatment", "authors": "Compraco", "year": None,
                          "doi": None, "url": "https://www.compraco.com.br/", "kind": "web"},
    "src_compraco_8620": {"title": "AISI 8620 — composition and ASM-type heat-treatment tables", "authors":
                          "Compraco", "year": None, "doi": None, "url": "https://www.compraco.com.br/", "kind": "web"},
    "src_compraco_gray": {"title": "Gray cast iron heat-treatment guide", "authors": "Compraco", "year": None,
                          "doi": None, "url": "https://www.compraco.com.br/", "kind": "web"},
    "src_wiki_martempering": {"title": "Martempering", "authors": "Wikipedia", "year": None, "doi": None,
                              "url": "https://en.wikipedia.org/wiki/Martempering", "kind": "encyclopedia"},
    "src_lee_2008": {"title": "Prediction of austenite grain growth during austenitization of low alloy steels",
                     "authors": "S.-J. Lee, Y.-K. Lee", "year": 2008, "doi": "10.1016/j.matdes.2008.03.009",
                     "url": "https://doi.org/10.1016/j.matdes.2008.03.009", "kind": "journal_article"},
    "src_gorni_handbook": {"title": "Steel Forming and Heat Treating Handbook (reproduce la ecuación de Lee & Lee 2008)",
                           "authors": "A. A. Gorni", "year": None, "doi": None,
                           "url": "https://www.gorni.eng.br/e/Gorni_SFHTHandbook.pdf", "kind": "book"},
    "src_astm_e112_g": {"title": "ASTM E112 — Standard Test Methods for Determining Average Grain Size "
                        "(G = −6.643856·log10 ℓ̄ − 3.288, ℓ̄ en mm)", "authors": "ASTM International", "year": None,
                        "doi": None, "url": "https://store.astm.org/e0112-13r21.html", "kind": "standard"},
    "src_hodgson_gibbs_1992": {"title": "A mathematical model to predict the mechanical properties of hot rolled "
                               "C-Mn and microalloyed steels", "authors": "P. D. Hodgson, R. K. Gibbs", "year": 1992,
                               "doi": "10.2355/isijinternational.32.1329",
                               "url": "https://doi.org/10.2355/isijinternational.32.1329", "kind": "journal_article"},
    "src_pavlina_2008": {"title": "Correlation of yield strength and tensile strength with hardness for steels",
                         "authors": "E. J. Pavlina, C. J. Van Tyne", "year": 2008, "doi": "10.1007/s11665-008-9225-5",
                         "url": "https://doi.org/10.1007/s11665-008-9225-5", "kind": "journal_article"},
    "src_astm_a48_class": {"title": "ASTM A48/A48M — Gray iron castings: el número de clase es la resistencia mínima "
                           "a tracción en ksi (clase 30 ≥ 30 ksi ≈ 207 MPa)", "authors": "ASTM International "
                           "(tabla reproducida por Portland Bolt y Total Materia)", "year": None, "doi": None,
                           "url": "https://www.portlandbolt.com/technical/specifications/astm-a48/", "kind": "standard"},
    "src_appsci_2026_agi": {"title": "Effect of Different Austenitizing Temperatures on the Microstructure and "
                            "Mechanical Properties of Austempering Gray Cast Iron (Applied Sciences 16(4):1828)",
                            "authors": "Applied Sciences (MDPI)", "year": 2026, "doi": "10.3390/app16041828",
                            "url": "https://doi.org/10.3390/app16041828", "kind": "journal_article"},
    "src_wiki_austempering": {"title": "Austempering", "authors": "Wikipedia", "year": None, "doi": None,
                              "url": "https://en.wikipedia.org/wiki/Austempering", "kind": "encyclopedia"},
}

FRACTION_BASIS = "volume_fraction_modeled_center"
PHASE_BASIS = "mass_fraction_modeled_center"
_SEG_KIND = {"heat": StageKind.HEAT, "hold": StageKind.HOLD, "transfer": StageKind.TRANSFER,
             "cool": StageKind.COOL, "furnace_cool": StageKind.COOL, "isothermal_hold": StageKind.ISOTHERMAL_HOLD}


def supported(material_id: str) -> bool:
    return material_id in COMPOSITION_RANGES


def source_refs(ids, usage: str = "supports_value") -> list[EvidenceRef]:
    out = []
    for sid in ids:
        s = MODEL_SOURCE_CATALOG.get(sid)
        if s is None:
            continue
        out.append(EvidenceRef(source_id=sid, title=s["title"], authors=s["authors"], year=s["year"], edition=None,
                               doi=s["doi"], url=s["url"], kind=s["kind"], verification_status="model_reference",
                               usage=usage))  # type: ignore[arg-type]
    return out


def thermal_history(p: P.Practice, illustrative: bool = False) -> ThermalHistory:
    pts = P.thin(p.runner_center, 400)
    stages = []
    for seg in p.segments:
        if seg.t_end_s <= seg.t_start_s:
            continue
        t0 = _temp_at(p.runner_center, seg.t_start_s)
        t1 = _temp_at(p.runner_center, seg.t_end_s)
        stages.append(ThermalStageOut(index=len(stages), kind=_SEG_KIND[seg.kind], label_key=seg.label_key,
                                      t_start_s=round(seg.t_start_s, 2), t_end_s=round(seg.t_end_s, 2),
                                      start_temperature_c=round(t0, 1), end_temperature_c=round(t1, 1),
                                      profile_kind="modeled_conduction" if seg.kind != "furnace_cool"
                                      else "furnace_rate", evidence_ids=[], medium=seg.medium))
    if not stages:  # nada que calentar ni enfriar (p. ej. temperatura objetivo ≤ ambiente y sin tiempo)
        return ThermalHistory(stages=[], points=[], total_time_s=0.0,
                              time_basis="illustrative_seconds" if illustrative else "modeled_seconds")
    points = []
    for t, temp in pts:
        idx = next((s.index for s in stages if s.t_start_s - 1e-6 <= t <= s.t_end_s + 1e-6), stages[-1].index)
        points.append(ThermalPoint(t_s=round(t, 2), temperature_c=round(temp, 1), stage_index=idx))
    return ThermalHistory(stages=stages, points=points, total_time_s=round(pts[-1][0], 2),
                          time_basis="illustrative_seconds" if illustrative else "modeled_seconds")


def _temp_at(points, t):
    best = points[0][1]
    for tt, temp in points:
        if tt > t + 1e-9:
            break
        best = temp
    return best


def _fact(value: float, unit: str, dataset_version: str, *, basis: str | None = None, scale: str | None = None,
          uncertainty: dict | None = None, method: str) -> ResultFact:
    return ResultFact(value=math.floor(value * 1e4) / 1e4 if unit == "fraction" else round(value, 1), unit=unit, scale=scale,
                      fraction_basis=basis, method=method, evidence_kind=EvidenceKind.MODELED,
                      evidence_level=EvidenceLevel.BOUNDED_ESTIMATE, source_ids=list(P.MODEL_SOURCES),
                      model_version=P.MODEL_VERSION, dataset_version=dataset_version,
                      validity={"reference_diameter_mm": ASSUMPTIONS["reference_diameter_m"] * 1000,
                                "report_point": ASSUMPTIONS["report_point"],
                                "grain_size": "lee_2008_computed_or_assumed_g7_if_intercritical",
                                "review": "not_reviewed_by_specialist"},
                      uncertainty=uncertainty)


def facts(p: P.Practice, dataset_version: str) -> dict[str, Any]:
    out: dict[str, Any] = {}
    if p.fractions:
        rng = p.fractions_range or {}
        out["microconstituent_fractions"] = {
            k: _fact(min(max(v, 0.0), 1.0), "fraction", dataset_version, basis=FRACTION_BASIS,
                     method="li_1998_scheil_km",
                     uncertainty={"min": round(rng[k][0], 4), "max": round(rng[k][1], 4),
                                  "basis": "composition_range_and_medium_severity"} if k in rng else None)
            for k, v in _normalized(p.fractions).items() if v >= 0.0005
        }
    if p.phases:
        out["phase_fractions"] = {
            k: _fact(min(max(v, 0.0), 1.0), "fraction", dataset_version, basis=PHASE_BASIS,
                     method="carbon_mass_balance") for k, v in _normalized(p.phases).items() if v >= 0.0005
        }
    if p.hardness_hv is not None:
        lo, hi = p.hardness_range or (p.hardness_hv, p.hardness_hv)
        method = "kang_lee_2014_tempering" if p.treatment_id == "temper" else "maynier_1978_mixture"
        out["hardness"] = _fact(p.hardness_hv, "HV", dataset_version, scale="HV", method=method,
                                uncertainty={"min": round(lo, 1), "max": round(hi, 1),
                                             "hrc": _r(hv_to_hrc(p.hardness_hv)), "hrc_min": _r(hv_to_hrc(lo)),
                                             "hrc_max": _r(hv_to_hrc(hi)),
                                             "surface_hv": _r(p.hardness_surface_hv),
                                             "surface_hrc": _r(hv_to_hrc(p.hardness_surface_hv))
                                             if p.hardness_surface_hv else None,
                                             "basis": "composition_range_and_medium_severity"})
    gf = grain_fact(p, dataset_version)
    if gf is not None:
        out["grain_size"] = gf
    mf = mechanical_facts(p, dataset_version)
    if mf:
        out["mechanical_properties"] = mf
    return out


GRAIN_SOURCES = ["src_lee_2008", "src_gorni_handbook", "src_astm_e112_g"]
PAVLINA_YS = (-90.7, 2.876, (129.0, 632.0))  # MPa = a + b·HV; dominio de HV de los datos
PAVLINA_TS = (-99.8, 3.734, (129.0, 592.0))
A48_CLASS30_MIN_MPA = 207.0  # 30 ksi


def _src_fact(value: float, unit: str, dataset_version: str, sources: list[str], method: str, validity: dict,
              uncertainty: dict | None, kind: EvidenceKind = EvidenceKind.MODELED,
              level: EvidenceLevel = EvidenceLevel.BOUNDED_ESTIMATE) -> ResultFact:
    return ResultFact(value=round(value, 1), unit=unit, method=method, evidence_kind=kind, evidence_level=level,
                      source_ids=sources, model_version=P.MODEL_VERSION if kind == EvidenceKind.MODELED else None,
                      dataset_version=dataset_version, validity=validity, uncertainty=uncertainty)


def grain_fact(p: P.Practice, dataset_version: str) -> ResultFact | None:
    g = p.grain
    if not g:
        return None
    ferrite = g.get("ferrite_um") is not None
    sources = GRAIN_SOURCES + (["src_hodgson_gibbs_1992"] if ferrite else [])
    lo, hi = g["austenite_g_range"]
    unc = {"min": round(lo, 1), "max": round(hi, 1), "austenite_um": round(g["austenite_um"], 1),
           "austenite_um_min": round(g["austenite_um_range"][0], 1),
           "austenite_um_max": round(g["austenite_um_range"][1], 1), "austenite_g": round(g["austenite_g"], 1),
           "equivalent_time_s": round(g["equivalent_time_s"]), "extrapolation": list(g["extrapolation"]),
           "basis": "composition_range"}
    if ferrite:
        unc.update({"ferrite_um": round(g["ferrite_um"], 1), "ferrite_g": round(g["ferrite_g"], 1),
                    "ferrite_cooling_k_s": round(g["ferrite_rate_k_s"], 3)})
    return _src_fact(g["austenite_g"], "ASTM_G", dataset_version, sources, "lee_2008_astm_e112",
                     {"grain": "prior_austenite", "temperature_range_c": list(GR.LEE_T_RANGE_C),
                      "max_time_s": GR.LEE_T_MAX_S, "report_point": "center",
                      "intercept_assumption": "model_d_as_mean_lineal_intercept"}, unc)


def mechanical_facts(p: P.Practice, dataset_version: str) -> dict[str, ResultFact] | None:
    if p.hardness_hv is None:
        return None
    lo, hi = p.hardness_range or (p.hardness_hv, p.hardness_hv)
    out = {}
    for key, (a, b, (hv_lo, hv_hi)) in (("yield_strength", PAVLINA_YS), ("tensile_strength", PAVLINA_TS)):
        if not hv_lo <= p.hardness_hv <= hv_hi:
            continue
        band_lo, band_hi = max(lo, hv_lo), min(hi, hv_hi)
        out[key] = _src_fact(a + b * p.hardness_hv, "MPa", dataset_version, ["src_pavlina_2008"],
                             "pavlina_van_tyne_2008_from_hv",
                             {"hv_range": [hv_lo, hv_hi], "steels": "non_austenitic_hypoeutectoid",
                              "from_hardness_hv": round(p.hardness_hv, 1)},
                             {"min": round(a + b * band_lo, 1), "max": round(a + b * band_hi, 1),
                              "basis": "hardness_band_without_regression_scatter"})
    return out or None


def gray_iron_mechanical(dataset_version: str) -> dict[str, ResultFact]:
    return {"tensile_strength_min": _src_fact(
        A48_CLASS30_MIN_MPA, "MPa", dataset_version, ["src_astm_a48_class"], "astm_a48_class_minimum",
        {"condition": "as_cast_separately_cast_test_bar", "applies_after_heat_treatment": False}, None,
        kind=EvidenceKind.LITERATURE, level=EvidenceLevel.QUALITATIVE)}


# Durezas PUBLICADAS de fundición gris tratada (otra muestra, condición indicada). Se muestran como referencia
# bibliográfica, no como cálculo de la probeta del estudiante.
GRAY_HARDNESS_LITERATURE = {
    "quench": {"value": 450.0, "min": 400.0, "max": 500.0, "unit": "HB", "source": "src_totalmateria_gray_2",
               "condition": "surface_flame_hardened_unalloyed_3C_1.7Si",
               "locator": "Total Materia, Heat Treating of Gray Irons, Part Two (flame hardening)"},
    "austemper": {"value": 247.6, "min": 187.6, "max": 247.6, "unit": "HBW", "source": "src_appsci_2026_agi",
                  "condition": "austenitized_930C_austempered_vs_187.6HBW_as_cast",
                  "locator": "Applied Sciences 2026, 16(4):1828, resumen"},
}


def gray_iron_hardness(treatment_id: str, dataset_version: str) -> ResultFact | None:
    d = GRAY_HARDNESS_LITERATURE.get(treatment_id)
    if d is None:
        return None
    return ResultFact(value=d["value"], unit=d["unit"], scale=d["unit"], method="literature_reference_other_specimen",
                      evidence_kind=EvidenceKind.LITERATURE, evidence_level=EvidenceLevel.QUALITATIVE,
                      source_ids=[d["source"]], dataset_version=dataset_version,
                      validity={"condition": d["condition"], "locator": d["locator"], "same_specimen": False},
                      uncertainty={"min": d["min"], "max": d["max"], "basis": "published_range"})


def _normalized(d: dict[str, float]) -> dict[str, float]:
    total = sum(max(v, 0.0) for v in d.values())
    if total <= 0:
        return d
    return {k: math.floor(max(v, 0.0) / total * 1e4) / 1e4 for k, v in d.items()}


def _r(v):
    return None if v is None else round(v, 1)


GRAY_MATRIX = {"quench": "martensite", "temper": "tempered_martensite", "normalize": "pearlite",
               "anneal": "ferrite_pearlite", "austemper": "ausferrite", "martemper": "martensite"}


GRAY_VARIANT_MATRIX = {"ferritizing": "ferrite_pearlite", "full": "ferrite_pearlite", "graphitizing": "pearlite",
                       "stress_relief": "pearlite"}


def illustration(material_id: str, treatment_id: str, request_hash: str, p: P.Practice | None,
                 family: str, matrix_hint: str | None = None, reason: str | None = None) -> dict:
    """Especificación para que el cliente DIBUJE una microestructura ilustrativa (no es una micrografía)."""
    seed = int(hashlib.sha256(request_hash.encode()).hexdigest()[:8], 16)
    spec: dict[str, Any] = {"kind": "generated_illustration", "seed": seed, "family": family,
                            "astm_grain_size": ASSUMPTIONS["astm_grain_size"], "etchant": "nital_2pct",
                            "label_key": "illustration_not_micrograph"}
    if family == "gray_cast_iron":
        matrix = GRAY_VARIANT_MATRIX.get(matrix_hint or "", GRAY_MATRIX.get(treatment_id, "pearlite"))
        spec.update({"graphite": "type_a_flakes", "matrix": matrix,
                     "fractions": None, "quantitative": False, "reason": "qualitative_cast_iron"})
        return spec
    if p is None:
        # Sin fracciones calculadas no se dibuja una microestructura nueva; se dice por qué.
        return spec | {"fractions": None, "quantitative": False, "reason": reason or "not_computed"}
    if p.grain:
        shown_ferrite = p.grain.get("ferrite_g") is not None and treatment_id in ("anneal", "normalize")
        spec["astm_grain_size"] = round(p.grain["ferrite_g"] if shown_ferrite else p.grain["austenite_g"], 2)
        spec["grain_kind"] = "ferrite" if shown_ferrite else "prior_austenite"
        spec["grain_computed"] = True
    if treatment_id == "temper" and p.prior and p.prior.get("fractions"):
        spec.update({"fractions": _normalized(p.prior["fractions"]), "tempered": True, "quantitative": True,
                     "tempering_temperature_c": round(p.max_center_c)})
    elif p.fractions:
        spec.update({"fractions": _normalized(p.fractions), "tempered": False, "quantitative": True})
    else:
        spec.update({"fractions": None, "quantitative": False, "unchanged_initial_state": True,
                     "reason": "no_austenitization" if "MODEL_NO_AUSTENITIZATION" in p.notes else "not_computed"})
    vr = p.vr_700_k_s
    spec["pearlite_spacing"] = "fine" if vr and vr > 1 else "coarse"
    return spec


def estimate_block(p: P.Practice | None, material_id: str, treatment_id: str, locale: str) -> dict:
    out: dict[str, Any] = {
        "model_version": P.MODEL_VERSION,
        "label": ("Estimación por modelos empíricos publicados; no revisada por un especialista."
                  if locale == "es" else "Estimate from published empirical models; not reviewed by a specialist."),
        "assumptions": {k: v for k, v in ASSUMPTIONS.items() if k != "ae_equals_ac"},
    }
    if p is None or material_id not in COMPOSITION_RANGES:
        return out
    out.update({
        "composition_nominal_wt_pct": {k: round(v, 3) for k, v in p.composition.items()},
        "composition_range_wt_pct": {k: list(v) for k, v in COMPOSITION_RANGES[material_id].items()},
        "critical_temperatures_c": p.critical,
        "max_center_temperature_c": round(p.max_center_c, 1),
        "austenite_fraction_at_hold": round(p.austenite_fraction, 3),
        "cooling_medium": p.medium_code,
        "bath_temperature_c": p.bath_c,
        "cooling_rate_700c_k_s": None if p.vr_700_k_s is None else round(p.vr_700_k_s, 3),
        "surface_fractions": None if p.surface_fractions is None else
        {k: round(v, 4) for k, v in _normalized(p.surface_fractions).items()},
        "fractions_range": None if p.fractions_range is None else
        {k: [round(a, 4), round(b, 4)] for k, (a, b) in p.fractions_range.items()},
        "notes": list(p.notes),
        "grain": None if not p.grain else {k: (list(v) if isinstance(v, tuple) else v) for k, v in p.grain.items()},
        "prior_state": None if p.prior is None else {
            **{k: v for k, v in p.prior.items() if k not in ("fractions", "hardness_range")},
            "fractions": None if not p.prior.get("fractions") else
            {k: round(v, 4) for k, v in _normalized(p.prior["fractions"]).items()},
            "hardness_hv": _r(p.prior.get("hardness_hv")),
            "hardness_hrc": _r(hv_to_hrc(p.prior["hardness_hv"])) if p.prior.get("hardness_hv") else None,
        },
    })
    return out
