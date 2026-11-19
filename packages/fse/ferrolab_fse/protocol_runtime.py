"""Servicio de protocolos (D-30): elige el protocolo, resuelve sus parámetros y lo convierte en etapas físicas.

Separado del motor para que la selección de parámetros sea un servicio independiente y auditable:
- `choose()`         protocolo pedido o el de referencia del par.
- `resolve()`        parámetros editables (horno, sostenimiento, baño, tiempo de baño) con su rango, su valor de
                     referencia y el FUNDAMENTO de cada cifra (fuente, regla aplicada, modelo o pendiente).
- `Resolved.steps`   etapas con cifras para el modelo térmico.

Nunca inventa cifras: si una cifra no está publicada ni se puede calcular con un modelo declarado, el parámetro
queda «pendiente» y el problema se informa una sola vez.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Any

from .enums import MaterialFamily
from .messages import STAGE_LABELS, localize
from .metallurgy import kinetics as kin
from .metallurgy.data import ASSUMPTIONS
from .metallurgy.practice import Step, compositions
from .snapshot import DatasetSnapshot, Protocol, ProtocolStage

PARAM_KEYS = ("furnace_temperature", "hold_time", "bath_temperature", "bath_time")
PARAM_UNITS = {"furnace_temperature": "°C", "hold_time": "min", "bath_temperature": "°C", "bath_time": "min"}


@dataclass
class ParamSpec:
    key: str
    unit: str
    value: float | None
    min: float | None
    max: float | None
    ref: float | None
    basis: str  # source | rule | model | pending | computed
    stage_ordinal: int
    evidence_id: str | None = None
    rule_es: str | None = None
    rule_en: str | None = None
    editable: bool = True

    @property
    def outside(self) -> bool:
        if self.value is None:
            return False
        eps = 1e-6
        return (self.min is not None and self.value < self.min - eps) or (self.max is not None and self.value > self.max + eps)

    def as_dict(self, loc: str) -> dict[str, Any]:
        return {"key": self.key, "unit": self.unit, "value": _r(self.value), "min": _r(self.min), "max": _r(self.max),
                "ref": _r(self.ref), "basis": self.basis, "stage_ordinal": self.stage_ordinal,
                "evidence_id": self.evidence_id, "rule": self.rule_en if loc == "en" else self.rule_es,
                "editable": self.editable, "outside": self.outside}


def _r(v):
    return None if v is None else round(v, 2)


@dataclass
class Issue:
    code: str
    severity: str  # blocking | limitation | info
    group: str  # protocol | input | evidence | model | dependency | review
    params: dict[str, Any] = field(default_factory=dict)


@dataclass
class Resolved:
    protocol: Protocol
    params: dict[str, ParamSpec]
    steps: list[Step]
    issues: list[Issue]
    model_window: dict[str, float] | None = None
    bainite_start_s: float | None = None  # incubación de bainita a la temperatura del baño (martemperizado)

    @property
    def outside_any(self) -> bool:
        return any(p.outside for p in self.params.values())


def choose(snap: DatasetSnapshot, material_id: str, treatment_id: str, protocol_id: str | None) -> Protocol | None:
    lib = snap.protocols_for(material_id, treatment_id)
    if protocol_id:
        return next((p for p in lib if p.id == protocol_id), None)
    pair = snap.pair(material_id, treatment_id)
    if pair and pair.protocol_id:
        return snap.protocol(pair.protocol_id)
    return lib[0] if lib else None


# ---------------------------------------------------------------------------------------- ventana Ms–Bs
def model_window(material_id: str) -> dict[str, float] | None:
    """Ventana del baño calculada sobre TODO el rango de composición de la norma (Andrews / Li)."""
    comps = compositions(material_id)
    if comps is None:
        return None
    temps = [kin.li_temps(c) for c in comps.values()]
    ms_max = max(t.ms for t in temps)
    bs_min = min(t.bs for t in temps)
    lo, hi = math.ceil(ms_max), math.floor(bs_min)
    nominal = comps["nominal"]
    tm = kin.li_temps(nominal)
    grain = ASSUMPTIONS["astm_grain_size"]
    best_t, best_tau = None, None
    for t_c in range(lo, hi + 1):
        tau = kin.tau("bainite", 0.99, float(t_c), nominal, tm, grain)
        if tau is not None and (best_tau is None or tau < best_tau):
            best_t, best_tau = t_c, tau
    return {"ms_max_c": round(ms_max, 1), "bs_min_c": round(bs_min, 1), "min_c": float(lo), "max_c": float(hi),
            "austemper_ref_c": float(best_t) if best_t is not None else None,
            "austemper_ref_s": float(math.ceil(best_tau / 60.0) * 60.0) if best_tau else None,
            "martemper_ref_c": float(lo)}


def bainite_times(material_id: str, t_c: float) -> tuple[float | None, float | None]:
    comps = compositions(material_id)
    if comps is None:
        return None, None
    c = comps["nominal"]
    tm = kin.li_temps(c)
    g = ASSUMPTIONS["astm_grain_size"]
    return kin.tau("bainite", kin.X_NUC, t_c, c, tm, g), kin.tau("bainite", 0.99, t_c, c, tm, g)


# ---------------------------------------------------------------------------------------- resolución
def _range_basis(stage: ProtocolStage, lo, hi, ref) -> str:
    if lo is None and hi is None and ref is None:
        return "pending"
    return "rule" if stage.rule_es else "source"


def resolve(snap: DatasetSnapshot, protocol: Protocol, *, furnace_c: float, hold_s: float,
            bath_c: float | None = None, bath_s: float | None = None, use_reference: bool = False) -> Resolved:
    material = snap.material(protocol.material_id)
    is_steel = material is not None and material.family == MaterialFamily.STEEL
    params: dict[str, ParamSpec] = {}
    issues: list[Issue] = []
    win = model_window(protocol.material_id) if is_steel else None
    steps: list[Step] = []
    treatment = protocol.treatment_id.value
    bainite_start = None

    def first(param: str) -> ProtocolStage | None:
        return next((s for s in protocol.stages if s.user_param == param or s.user_time_param == param), None)

    # --- parámetros editables ----------------------------------------------------------------
    heat_st = next((s for s in protocol.stages if s.end_temperature_mode == "user_target"), None)
    if heat_st is not None:
        lo, hi, ref = heat_st.temperature_min_c, heat_st.temperature_max_c, heat_st.temperature_ref_c
        params["furnace_temperature"] = ParamSpec("furnace_temperature", "°C", ref if use_reference and ref else furnace_c,
                                                  lo, hi, ref, _range_basis(heat_st, lo, hi, ref), heat_st.ordinal,
                                                  heat_st.end_temperature_evidence_id, heat_st.rule_es, heat_st.rule_en)
    hold_st = first("hold_time")
    if hold_st is not None:
        lo, hi, ref = (None if v is None else v / 60 for v in
                       (hold_st.duration_min_s, hold_st.duration_max_s, hold_st.duration_ref_s))
        params["hold_time"] = ParamSpec("hold_time", "min", ref if use_reference and ref is not None else hold_s / 60,
                                        lo, hi, ref, _range_basis(hold_st, lo, hi, ref), hold_st.ordinal,
                                        hold_st.duration_evidence_id, hold_st.rule_es, hold_st.rule_en)
    bath_st = next((s for s in protocol.stages if s.kind.value == "isothermal_hold"), None)
    if bath_st is not None:
        if bath_st.end_temperature_mode == "model_window" and win is not None:
            ref = win["austemper_ref_c"] if treatment == "austemper" else win["martemper_ref_c"]
            lo, hi, basis = win["min_c"], win["max_c"], "model"
        elif bath_st.end_temperature_mode == "value":
            lo = hi = ref = bath_st.end_temperature_c
            basis = "source"
        else:
            lo, hi, ref = bath_st.temperature_min_c, bath_st.temperature_max_c, bath_st.temperature_ref_c
            basis = _range_basis(bath_st, lo, hi, ref)
        value = ref if (use_reference or bath_c is None) else bath_c
        params["bath_temperature"] = ParamSpec("bath_temperature", "°C", value, lo, hi, ref, basis, bath_st.ordinal,
                                               bath_st.end_temperature_evidence_id, bath_st.rule_es, bath_st.rule_en,
                                               editable=bath_st.end_temperature_mode != "value")
        # tiempo en el baño
        if bath_st.duration_mode == "value":
            d = bath_st.duration_s / 60
            params["bath_time"] = ParamSpec("bath_time", "min", d, d, d, d, "source", bath_st.ordinal,
                                            bath_st.duration_evidence_id, editable=False)
        elif bath_st.duration_mode == "until_equalized":
            params["bath_time"] = ParamSpec("bath_time", "min", None if use_reference or bath_s is None else bath_s / 60,
                                            None, None, None, "computed", bath_st.ordinal, None,
                                            "Hasta igualar la temperatura de la pieza con el baño (modelo térmico).",
                                            "Until the part temperature equalizes with the bath (thermal model).")
        else:
            lo, hi, ref = (None if v is None else v / 60 for v in
                           (bath_st.duration_min_s, bath_st.duration_max_s, bath_st.duration_ref_s))
            basis = _range_basis(bath_st, lo, hi, ref)
            if bath_st.end_temperature_mode == "model_window" and win is not None and treatment == "austemper":
                basis, lo, hi = "model", None, None
                t_bath = params["bath_temperature"].value
                _, t99 = bainite_times(protocol.material_id, t_bath) if t_bath is not None else (None, None)
                ref = math.ceil(t99 / 60.0) if t99 else None
            v = ref if (use_reference or bath_s is None) else bath_s / 60
            params["bath_time"] = ParamSpec("bath_time", "min", v, lo, hi, ref, basis, bath_st.ordinal,
                                            bath_st.duration_evidence_id, bath_st.rule_es, bath_st.rule_en)

    # --- problemas de parámetros (uno por causa) -------------------------------------------------
    for key in PARAM_KEYS:
        p = params.get(key)
        if p is None:
            continue
        if p.outside:
            issues.append(Issue("OUTSIDE_PROTOCOL_RANGE", "limitation", "input",
                                {"param": key, "value": _fmt(p.value), "min": _fmt(p.min), "max": _fmt(p.max),
                                 "unit": p.unit, "ref": _fmt(p.ref)}))
        if p.basis == "pending" and not (key == "bath_time" and p.value is None):
            issues.append(Issue("PARAM_UNDOCUMENTED", "info" if (key == "hold_time" and is_steel) else "limitation",
                                "protocol", {"param": key, "steel_hold": key == "hold_time" and is_steel}))
    if params.get("bath_time") and params["bath_time"].value is None and params["bath_time"].basis == "pending":
        issues.append(Issue("BATH_TIME_UNDOCUMENTED", "limitation", "protocol", {}))
    if protocol.evidence_status == "source_unverified":
        issues.append(Issue("PROTOCOL_SOURCE_UNVERIFIED", "limitation", "evidence", {}))

    # --- etapas físicas ------------------------------------------------------------------------
    furnace = params.get("furnace_temperature")
    t_furnace = furnace.value if furnace else None
    heat_seen = False
    for s in protocol.stages:
        role = s.role or s.kind.value
        if role == "preheat":
            steps.append(Step("preheat", s.label_key, temperature_c=s.end_temperature_c))
        elif s.kind.value == "heat":
            if s.end_temperature_mode == "user_target" and not heat_seen:
                t = t_furnace
            else:  # segundo calentamiento (p. ej. doble refinado): centro del rango publicado, declarado
                t = s.temperature_ref_c or (None if s.temperature_min_c is None or s.temperature_max_c is None
                                            else (s.temperature_min_c + s.temperature_max_c) / 2)
            if t is None:
                continue
            heat_seen = True
            steps.append(Step("heat", s.label_key, temperature_c=t))
        elif s.kind.value == "hold":
            hp = params.get("hold_time")
            steps.append(Step("hold", s.label_key, temperature_c=steps[-1].temperature_c if steps else t_furnace,
                              duration_s=(hp.value or 0) * 60 if hp else 0))
        elif s.kind.value == "transfer":
            steps.append(Step("transfer", s.label_key, duration_s=ASSUMPTIONS["transfer_s"], medium="air"))
        elif s.kind.value == "isothermal_hold":
            bt = params["bath_temperature"].value
            btime = params.get("bath_time")
            dur = None if btime is None or btime.value is None else btime.value * 60
            steps.append(Step("bath", s.label_key, temperature_c=bt, duration_s=dur, medium=s.medium or "salt_bath",
                              equalize=dur is None))
            if treatment == "martemper" and is_steel and bt is not None:
                bainite_start, _ = bainite_times(protocol.material_id, bt)
                if dur is not None and bainite_start is not None and dur > bainite_start:
                    issues.append(Issue("MARTEMPER_EXCESSIVE_HOLD", "limitation", "model",
                                        {"time_min": _fmt(dur / 60), "limit_min": _fmt(bainite_start / 60)}))
        elif s.kind.value == "cool":
            if s.role == "furnace_cool" or s.duration_mode == "rate":
                steps.append(Step("furnace_cool", s.label_key, rate_c_per_h=(s.rate_c_per_s or 0) * 3600,
                                  until_c=s.until_c or s.end_temperature_c))
            elif s.role == "quench":
                steps.append(Step("quench", s.label_key, medium=s.medium or "oil"))
            else:
                steps.append(Step("air", s.label_key, medium="air"))
    if treatment == "austemper" and is_steel and params.get("bath_temperature") and params.get("bath_time"):
        bt, btm = params["bath_temperature"].value, params["bath_time"].value
        if bt is not None and btm is not None:
            _, t99 = bainite_times(protocol.material_id, bt)
            if t99 is not None and btm * 60 < t99:
                issues.append(Issue("AUSTEMPER_INCOMPLETE_BAINITE", "info", "model",
                                    {"time_min": _fmt(btm), "needed_min": _fmt(t99 / 60)}))
    return Resolved(protocol, params, steps, issues, win, bainite_start)


def _fmt(v: float | None) -> str:
    if v is None:
        return "—"
    return f"{v:.1f}".rstrip("0").rstrip(".")


# ---------------------------------------------------------------------------------------- ficha
def card(snap: DatasetSnapshot, protocol: Protocol, loc: str, resolved: Resolved | None = None) -> dict[str, Any]:
    """Ficha científica del protocolo para la interfaz."""
    en = loc == "en"

    def L(es, en_):
        return en_ if en else es

    stages = []
    for s in protocol.stages:
        stages.append({
            "ordinal": s.ordinal, "kind": s.kind.value, "role": s.role, "label_key": s.label_key,
            "label": localize(STAGE_LABELS, s.label_key, loc), "medium": s.medium,
            "medium_note": L(s.medium_note_es, s.medium_note_en),
            "temperature_mode": s.end_temperature_mode, "duration_mode": s.duration_mode,
            "temperature_c": s.end_temperature_c, "temperature_min_c": s.temperature_min_c,
            "temperature_max_c": s.temperature_max_c, "temperature_ref_c": s.temperature_ref_c,
            "duration_s": s.duration_s, "duration_min_s": s.duration_min_s, "duration_max_s": s.duration_max_s,
            "duration_ref_s": s.duration_ref_s, "rate_c_per_h": None if s.rate_c_per_s is None else round(s.rate_c_per_s * 3600, 2),
            "until_c": s.until_c, "param": s.user_param, "time_param": s.user_time_param,
            "rule": L(s.rule_es, s.rule_en), "start_condition": L(s.start_condition_es, s.start_condition_en),
            "purpose": L(s.purpose_es, s.purpose_en),
            "evidence_ids": [e for e in (s.end_temperature_evidence_id, s.duration_evidence_id) if e],
        })
    sources = []
    for sid in protocol.source_ids:
        src = snap.source(sid)
        if src:
            sources.append({"id": src.id, "title": src.title, "authors": src.authors, "year": src.year, "url": src.url,
                            "doi": src.doi, "verification_status": src.verification_status})
    evidence = []
    for eid in sorted({e for s in protocol.stages for e in (s.end_temperature_evidence_id, s.duration_evidence_id) if e}
                      | {r.get("evidence_id") for r in protocol.published_results if r.get("evidence_id")}):
        ev = snap.evidence_by_id(eid)
        if ev:
            evidence.append({"id": ev.id, "source_id": ev.source_id, "locator": ev.locator,
                             "claim": ev.claim_en if en else ev.claim_es})
    out = {
        "id": protocol.id, "version": protocol.version, "variant_code": protocol.variant_code,
        "name": L(protocol.name_es or protocol.variant_es, protocol.name_en or protocol.variant_en),
        "objective": L(protocol.objective_es, protocol.objective_en), "goal": protocol.goal,
        "is_reference": protocol.is_reference, "evidence_status": protocol.evidence_status,
        "review_status": protocol.review_status.value, "medium": L(protocol.medium_es, protocol.medium_en),
        "material_condition": L(protocol.material_condition_es, protocol.material_condition_en),
        "required_initial_state": protocol.required_initial_state,
        "default_initial_condition_id": protocol.default_initial_condition_id,
        "prior_protocol_id": protocol.prior_protocol_id, "model_applicable": protocol.model_applicable,
        "expected": L(protocol.expected_es, protocol.expected_en),
        "restrictions": protocol.restrictions_en if en else protocol.restrictions_es,
        "assumptions": protocol.assumptions_en if en else protocol.assumptions_es,
        "missing": protocol.missing_en if en else protocol.missing_es,
        "published_results": [{"evidence_id": r.get("evidence_id"), "quantity": r.get("quantity"),
                               "text": r.get("text_en") if en else r.get("text_es")} for r in protocol.published_results],
        "validity": protocol.validity, "published_on": protocol.published_on, "stages": stages,
        "sources": sources, "evidence": evidence,
    }
    if resolved is not None:
        out["params"] = {k: v.as_dict(loc) for k, v in resolved.params.items()}
        out["model_window"] = resolved.model_window
    else:
        r0 = resolve(snap, protocol, furnace_c=0, hold_s=0, use_reference=True)
        out["params"] = {k: v.as_dict(loc) for k, v in r0.params.items()}
        out["model_window"] = r0.model_window
    return out
