"""Ferrolab Scientific Engine (doc 04 §3, §8).

Determinista: no usa red, reloj, aleatoriedad ni IA. Misma entrada + mismo
snapshot + misma versión de motor => mismo resultado (NFR-01, SCI-08).
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass, field
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field

from . import ENGINE_VERSION
from . import model_estimate as ME
from . import protocol_runtime as PR
from .enums import (
    CompatibilityStatus,
    EvidenceKind,
    EvidenceLevel,
    MaterialFamily,
    QuantityCode,
    ReviewStatus,
    SimulationStatus,
    TreatmentId,
)
from .messages import ASSUMPTIONS, MESSAGES, STAGE_LABELS, localize
from .metallurgy import practice as metallurgy_practice
from .models import ModelNotActivated
from .models import koistinen_marburger as km
from .result import (
    Assumption,
    EvidenceRef,
    Explanation,
    InitialConditionOut,
    MaterialRef,
    ProtocolOut,
    ProtocolStageOut,
    QuantityStatus,
    ResultFact,
    Results,
    SimulationInputEcho,
    SimulationResult,
    Warning,
)
from .snapshot import DatasetSnapshot, EvidenceRecord, InitialCondition, MaterialTreatment, Protocol
from .thermal import ThermalHistory, build_physical_history, build_schematic_cycle

Locale = Literal["es", "en"]


class UnknownEntity(LookupError):
    """Material/tratamiento/condición inexistente en el snapshot (HTTP 404)."""

    def __init__(self, field: str, value: str) -> None:
        super().__init__(f"{field}={value}")
        self.field = field
        self.value = value


class InvalidState(ValueError):
    """Estado inicial ambiguo o incoherente (HTTP 400 invalid_state)."""

    def __init__(self, code: str, message: str, field: str) -> None:
        super().__init__(message)
        self.code = code
        self.field = field


class SimulationRequest(BaseModel):
    """Entrada canónica interna. El tiempo físico se guarda en segundos.

    `target_temperature_c` y `hold_time_min` son la temperatura del horno y el sostenimiento de la etapa de
    austenización (o de revenido). El baño de austemperizado/martemperizado tiene sus propios parámetros.
    """

    model_config = ConfigDict(frozen=True, extra="forbid")
    material_id: str
    treatment_id: str
    initial_condition_id: str | None = None
    target_temperature_c: float = Field(ge=0, le=1600, allow_inf_nan=False)
    hold_time_min: float = Field(ge=0, allow_inf_nan=False)
    protocol_id: str | None = None
    bath_temperature_c: float | None = Field(default=None, ge=0, le=1600, allow_inf_nan=False)
    bath_time_min: float | None = Field(default=None, ge=0, le=100000, allow_inf_nan=False)
    # Revenido: de dónde sale el estado templado de partida.
    prior_mode: Literal["reference", "history", "theory"] = "reference"
    prior_protocol_id: str | None = None
    prior_temperature_c: float | None = Field(default=None, ge=0, le=1600, allow_inf_nan=False)
    prior_hold_min: float | None = Field(default=None, ge=0, allow_inf_nan=False)
    locale: Locale = "es"

    @property
    def hold_s(self) -> float:
        return self.hold_time_min * 60.0


class Domain(BaseModel):
    model_config = ConfigDict(frozen=True)
    min: float | None
    max: float | None
    unit: str
    evidence_id: str | None
    published: bool  # True = rango documentado (con fuente y localizador) para el protocolo elegido


class ValidationReport(BaseModel):
    model_config = ConfigDict(frozen=True)
    can_run: bool
    predicted_status: SimulationStatus
    compatibility_status: CompatibilityStatus | None
    quantitative_eligible: bool
    temperature_domain: Domain
    hold_domain: Domain
    physical_limit_c: float | None
    initial_condition_id: str | None
    warnings: list[Warning]
    result_level: str | None = None
    headline: dict[str, Any] | None = None
    protocol: dict[str, Any] | None = None


@dataclass
class _Ctx:
    req: SimulationRequest
    snap: DatasetSnapshot
    locale: Locale
    warnings: list[Warning] = field(default_factory=list)

    def warn(self, code: str, severity: str, field_: str | None = None, group: str | None = None,
             key: str | None = None, **params: Any) -> None:
        dedupe = key or code
        if any((w.params.get("_key") or w.code) == dedupe for w in self.warnings):
            return
        shown = {k: v for k, v in params.items() if not k.startswith("_")}
        self.warnings.append(
            Warning(
                code=code,
                severity=severity,  # type: ignore[arg-type]
                message_key=f"scientific.{code.lower()}",
                message=localize(MESSAGES, code, self.locale, **shown),
                params={**shown, **({"_key": key} if key else {})},
                field=field_,
                group=group,
            )
        )

    @property
    def blocking(self) -> bool:
        return any(w.severity == "blocking" for w in self.warnings)


_MEDIUM_NAMES = {"water": ("agua", "water"), "oil": ("aceite", "oil"), "air": ("aire", "air"),
                 "furnace": ("horno", "furnace"), "salt_bath": ("baño de sales", "salt bath")}
_PARAM_NAMES = {"furnace_temperature": ("La temperatura del horno", "The furnace temperature"),
                "hold_time": ("El tiempo de sostenimiento", "The holding time"),
                "bath_temperature": ("La temperatura del baño", "The bath temperature"),
                "bath_time": ("El tiempo en el baño", "The bath time")}
_PARAM_FIELDS = {"furnace_temperature": "target_temperature_c", "hold_time": "hold_time_min",
                 "bath_temperature": "bath_temperature_c", "bath_time": "bath_time_min"}


def _fmt(v: float) -> str:
    return f"{v:g}"


@dataclass
class _Checked:
    material: Any
    treatment: Any
    ic: InitialCondition | None
    pair: MaterialTreatment | None
    protocol: Protocol | None
    resolved: PR.Resolved | None
    t_dom: Domain
    h_dom: Domain
    guard: Any
    compat: CompatibilityStatus
    quantitative: bool
    dependency: str | None
    level: str


ASSUMPTION_NOTES = {"MODEL_GRAIN_LEE", "MODEL_GRAIN_EXTRAPOLATED"}  # se explican en la tarjeta de grano y en los supuestos


class ScientificEngine:
    def __init__(self, snapshot: DatasetSnapshot) -> None:
        self.snapshot = snapshot
        self._checksum = snapshot.checksum()

    @property
    def dataset_checksum(self) -> str:
        return self._checksum

    # ------------------------------------------------------------ helpers
    def _resolve(self, req: SimulationRequest):
        snap = self.snapshot
        material = snap.material(req.material_id)
        if material is None:
            raise UnknownEntity("material_id", req.material_id)
        treatment = snap.treatment(req.treatment_id)
        if treatment is None:
            raise UnknownEntity("treatment_id", req.treatment_id)
        protocol = PR.choose(snap, material.id, treatment.id, req.protocol_id)
        if req.protocol_id is not None and protocol is None:
            raise UnknownEntity("protocol_id", req.protocol_id)
        conds = snap.conditions_for(material.id)
        ic: InitialCondition | None
        if req.initial_condition_id is not None:
            ic = next((c for c in conds if c.id == req.initial_condition_id), None)
            if ic is None:
                raise UnknownEntity("initial_condition_id", req.initial_condition_id)
        elif protocol is not None and protocol.default_initial_condition_id:
            ic = next((c for c in conds if c.id == protocol.default_initial_condition_id), None)
        elif len(conds) == 1:
            ic = conds[0]
        elif not conds:
            ic = None
        else:
            ic = conds[0]  # condición base del material (la primera del catálogo; nunca se supone templada)
        pair = snap.pair(material.id, treatment.id)
        return material, treatment, ic, pair, protocol

    def _legacy_domains(self, pair: MaterialTreatment | None) -> tuple[Domain, Domain]:
        """Rango de la pareja (solo cuando hay evidencia PUBLICADA: ruta cuantitativa experimental)."""
        snap = self.snapshot

        def pub(eid: str | None) -> bool:
            ev = snap.evidence_by_id(eid)
            return ev is not None and ev.review_status == ReviewStatus.PUBLISHED and bool(ev.locator)

        if pair is None:
            return (Domain(min=None, max=None, unit="°C", evidence_id=None, published=False),
                    Domain(min=None, max=None, unit="s", evidence_id=None, published=False))
        return (Domain(min=pair.temperature_min_c, max=pair.temperature_max_c, unit="°C",
                       evidence_id=pair.temperature_evidence_id, published=pub(pair.temperature_evidence_id)),
                Domain(min=pair.hold_min_s, max=pair.hold_max_s, unit="s", evidence_id=pair.hold_evidence_id,
                       published=pub(pair.hold_evidence_id)))

    def _physical_limit(self, family: MaterialFamily):
        guards = [g for g in self.snapshot.physical_guards if g.applies_to_family == family]
        return min(guards, key=lambda g: g.max_temperature_c) if guards else None

    @staticmethod
    def _model_outside(resolved: PR.Resolved, treatment_id: TreatmentId, is_steel: bool) -> bool:
        """¿Algún parámetro fuera de rango invalida el modelo? En aceros, el sostenimiento de austenización no
        cambia la cinética (se supone austenización completa): solo avisa. En el revenido sí cuenta (Kang & Lee)."""
        return any(p.outside and not (p.key == "hold_time" and is_steel
                                      and treatment_id not in (TreatmentId.TEMPER, TreatmentId.QUENCH_TEMPER))
                   for p in resolved.params.values())

    @staticmethod
    def _is_legacy(protocol: Protocol | None) -> bool:
        return protocol is not None and all(s.role is None for s in protocol.stages)

    # --------------------------------------------------------- validación
    def _check(self, ctx: _Ctx) -> _Checked:
        req = ctx.req
        loc = ctx.locale
        material, treatment, ic, pair, protocol = self._resolve(req)
        guard = self._physical_limit(material.family)
        is_steel = material.family == MaterialFamily.STEEL


        # 1. Límite físico (solo bloquea).
        if guard is not None and req.target_temperature_c >= guard.max_temperature_c:
            ctx.warn("TEMPERATURE_ABOVE_PHYSICAL_LIMIT", "blocking", "target_temperature_c", group="input",
                     temperature_c=_fmt(req.target_temperature_c), limit_c=_fmt(guard.max_temperature_c),
                     guard_review=guard.review_status.value)
        if req.hold_time_min > self.snapshot.interface.hold_ui_max_min:
            ctx.warn("HOLD_OUTSIDE_PROTOCOL_RANGE", "blocking", "hold_time_min", group="input",
                     min_min="0", max_min=_fmt(self.snapshot.interface.hold_ui_max_min))

        # 2. Dominio con evidencia publicada (ruta experimental heredada).
        t_dom, h_dom = self._legacy_domains(pair)
        if t_dom.published and t_dom.min is not None and t_dom.max is not None \
                and not (t_dom.min <= req.target_temperature_c <= t_dom.max):
            ctx.warn("TEMPERATURE_OUTSIDE_PROTOCOL_RANGE", "blocking", "target_temperature_c", group="input",
                     min_c=_fmt(t_dom.min), max_c=_fmt(t_dom.max))
        if h_dom.published and h_dom.min is not None and h_dom.max is not None \
                and not (h_dom.min <= req.hold_s <= h_dom.max):
            ctx.warn("HOLD_OUTSIDE_PROTOCOL_RANGE", "blocking", "hold_time_min", group="input",
                     min_min=_fmt(h_dom.min / 60), max_min=_fmt(h_dom.max / 60))

        # 3. Compatibilidad.
        compat = pair.compatibility_status if pair else CompatibilityStatus.UNSUPPORTED
        if compat == CompatibilityStatus.UNSUPPORTED:
            ctx.warn("COMBINATION_UNSUPPORTED", "limitation", group="protocol")

        # 4. Protocolo de la biblioteca: parámetros, rangos y lo que falta (un aviso por causa).
        resolved = None
        if protocol is None:
            ctx.warn("NO_PROTOCOL", "limitation", group="protocol")
        elif not self._is_legacy(protocol):
            resolved = PR.resolve(self.snapshot, protocol, furnace_c=req.target_temperature_c, hold_s=req.hold_s,
                                  bath_c=req.bath_temperature_c,
                                  bath_s=None if req.bath_time_min is None else req.bath_time_min * 60)
            fu = resolved.params.get("furnace_temperature")
            if fu is not None:
                t_dom = Domain(min=fu.min, max=fu.max, unit="°C", evidence_id=fu.evidence_id,
                               published=fu.basis in ("source", "rule"))
            ho = resolved.params.get("hold_time")
            if ho is not None:
                h_dom = Domain(min=None if ho.min is None else ho.min * 60, max=None if ho.max is None else ho.max * 60,
                               unit="s", evidence_id=ho.evidence_id, published=ho.basis in ("source", "rule"))
            for i in resolved.issues:
                p = dict(i.params)
                key = None
                if "param" in p:
                    name = _PARAM_NAMES[p["param"]][loc == "en"]
                    key = f"{i.code}:{p['param']}"
                    if i.code == "PARAM_UNDOCUMENTED":
                        extra = MESSAGES["PARAM_UNDOCUMENTED_STEEL_HOLD" if p.get("steel_hold")
                                         else "PARAM_UNDOCUMENTED_DRAW"][loc == "en"]
                        p = {"param_name": name, "extra": extra}
                    else:
                        p["param_name"] = name
                        p.pop("param", None)
                    ctx.warn(i.code, i.severity, _PARAM_FIELDS.get(i.params["param"]), group=i.group, key=key, **p)
                else:
                    ctx.warn(i.code, i.severity, group=i.group, **p)

        # 5. Dependencias del estado inicial.
        dependency = None
        if treatment.id == TreatmentId.TEMPER and compat != CompatibilityStatus.UNSUPPORTED:
            hardened = ic is not None and ic.hardened is True
            if req.prior_mode == "theory":
                dependency = "theory"
                ctx.warn("DEPENDENCY_THEORY", "limitation", group="dependency")
            elif req.prior_mode == "history" and req.prior_temperature_c is not None:
                dependency = "history"
                ctx.warn("DEPENDENCY_HISTORY", "info", group="dependency",
                         temperature_c=_fmt(req.prior_temperature_c))
            elif protocol is not None and protocol.prior_protocol_id:
                dependency = "reference"
                prior = self.snapshot.protocol(protocol.prior_protocol_id)
                ctx.warn("DEPENDENCY_REFERENCE", "info", group="dependency",
                         prior=(prior.name_en if loc == "en" else prior.name_es) if prior else "—")
            elif not hardened:
                dependency = "theory"
                ctx.warn("TEMPER_REQUIRES_HARDENED_STATE", "limitation", "initial_condition_id", group="dependency")
        if protocol is not None and protocol.required_initial_state and ic is not None:
            for k, expected in protocol.required_initial_state.items():
                if treatment.id == TreatmentId.TEMPER and k == "hardened":
                    continue
                if getattr(ic, k, None) != expected:
                    ctx.warn("REQUIRED_INITIAL_STATE_NOT_MET", "limitation", "initial_condition_id",
                             group="dependency", requirement=f"{k}={expected}")
        if material.id == "aisi_8620":
            if ic is not None and ic.carburized is True:
                ctx.warn("CARBURIZED_CASE_NOT_MODELED", "info", group="model")
            else:
                ctx.warn("CARBURIZED_CASE_NOT_ASSUMED", "info", group="model")
        if material.family == MaterialFamily.GRAY_CAST_IRON:
            ctx.warn("CAST_IRON_NO_STEEL_MODELS", "info", group="model")

        # 6. Ruta experimental (evidencia medida publicada) — sin cambios.
        protocol_ok = (protocol is not None and protocol.review_status == ReviewStatus.PUBLISHED
                       and protocol.is_fully_specified)
        quantitative = (
            compat in (CompatibilityStatus.SUPPORTED, CompatibilityStatus.CONDITIONAL)
            and pair is not None and pair.quantitative_outputs_enabled and pair.review_status == ReviewStatus.PUBLISHED
            and protocol_ok and (treatment.id != TreatmentId.TEMPER or (ic is not None and ic.hardened is True))
            and (ic is None or ic.review_status == ReviewStatus.PUBLISHED)
            and not self.snapshot.contains_unreviewed_content
        )

        # 7. Nivel de resultado previsto (A/B/C).
        if ctx.blocking or compat == CompatibilityStatus.UNSUPPORTED or protocol is None:
            level = "C"
        elif self._is_legacy(protocol):
            level = "A" if quantitative else "C"
        elif protocol.evidence_status != "source_verified" or dependency == "theory":
            level = "C"
        elif not (is_steel and protocol.model_applicable and ME.supported(material.id)):
            level = "B"
        elif resolved is not None and self._model_outside(resolved, treatment.id, is_steel):
            level = "B"
        else:
            level = "A"
        return _Checked(material, treatment, ic, pair, protocol, resolved, t_dom, h_dom, guard, compat, quantitative,
                        dependency, level)

    def _headline(self, ctx: _Ctx, k: _Checked, level: str, gray_reference: bool = False) -> dict[str, Any]:
        loc = ctx.locale
        if ctx.blocking:
            w = next(w for w in ctx.warnings if w.severity == "blocking")
            return {"code": "BLOCKED", "kind": "warning", "message": w.message}
        if k.compat == CompatibilityStatus.UNSUPPORTED:
            return {"code": "UNSUPPORTED", "kind": "limitation", "message": localize(MESSAGES, "COMBINATION_UNSUPPORTED", loc)}
        out = [w for w in ctx.warnings if w.code == "OUTSIDE_PROTOCOL_RANGE"]
        if out:
            hard = k.resolved is not None and self._model_outside(
                k.resolved, k.treatment.id, k.material.family == MaterialFamily.STEEL)
            code = "HEADLINE_OUT_OF_RANGE" if hard or level != "A" else "HEADLINE_OUT_OF_RANGE_SOFT"
            return {"code": code, "kind": "warning",
                    "message": localize(MESSAGES, code, loc, param_name=out[0].params["param_name"])}
        name = None if k.protocol is None else (k.protocol.name_en if loc == "en" else k.protocol.name_es)
        if k.dependency == "reference":
            return {"code": "HEADLINE_DEPENDENCY", "kind": "info", "message": localize(MESSAGES, "HEADLINE_DEPENDENCY", loc)}
        if level == "C":
            code = "HEADLINE_UNVERIFIED" if k.protocol is not None and k.protocol.evidence_status == "source_unverified" \
                else "HEADLINE_ILLUSTRATIVE"
            return {"code": code, "kind": "limitation", "message": localize(MESSAGES, code, loc)}
        if level == "B":
            # Fundición gris con dureza publicada de otra muestra: el encabezado no debe decir que no hay dureza.
            code = "HEADLINE_GRAY_REFERENCE" if gray_reference else "HEADLINE_PARTIAL"
            return {"code": code, "kind": "limitation", "message": localize(MESSAGES, code, loc)}
        code = "HEADLINE_VALID" if k.protocol is not None and k.protocol.is_reference else "HEADLINE_VALID_VARIANT"
        return {"code": code, "kind": "ok", "message": localize(MESSAGES, code, loc, name=name or "—")}

    def validate(self, req: SimulationRequest) -> ValidationReport:
        ctx = _Ctx(req=req, snap=self.snapshot, locale=req.locale)
        k = self._check(ctx)
        if ctx.blocking:
            status = SimulationStatus.INVALID_INPUT
        elif k.compat == CompatibilityStatus.UNSUPPORTED:
            status = SimulationStatus.UNSUPPORTED
        elif k.quantitative:
            status = SimulationStatus.COMPLETED  # predicción optimista; se confirma al simular
        elif k.level == "A":
            status = SimulationStatus.PARTIAL_RESULT
        else:
            status = SimulationStatus.INSUFFICIENT_EVIDENCE
        return ValidationReport(
            can_run=not ctx.blocking,
            predicted_status=status,
            compatibility_status=k.compat,
            quantitative_eligible=k.quantitative,
            temperature_domain=k.t_dom,
            hold_domain=k.h_dom,
            physical_limit_c=k.guard.max_temperature_c if k.guard else None,
            initial_condition_id=k.ic.id if k.ic else None,
            warnings=ctx.warnings,
            result_level=k.level,
            headline=self._headline(ctx, k, k.level),
            protocol=None if k.protocol is None or self._is_legacy(k.protocol)
            else PR.card(self.snapshot, k.protocol, req.locale, k.resolved),
        )

    # ------------------------------------------------------- historial
    def build_thermal_history(self, req: SimulationRequest) -> ThermalHistory | None:
        _m, _t, _ic, _pair, protocol = self._resolve(req)
        if protocol is None or protocol.review_status != ReviewStatus.PUBLISHED or not self._is_legacy(protocol):
            return None
        return build_physical_history(
            protocol,
            target_temperature_c=req.target_temperature_c,
            hold_s=req.hold_s,
            ambient_c=self.snapshot.interface.ambient_reference_c,
        )

    # ------------------------------------------------------- simulación
    def request_hash(self, req: SimulationRequest) -> str:
        canonical = {
            "material_id": req.material_id,
            "treatment_id": req.treatment_id,
            "initial_condition_id": req.initial_condition_id,
            "target_temperature_c": float(req.target_temperature_c),
            "hold_s": float(req.hold_s),
            "protocol_id": req.protocol_id,
            "bath_temperature_c": req.bath_temperature_c,
            "bath_time_min": req.bath_time_min,
            "prior": [req.prior_mode, req.prior_protocol_id, req.prior_temperature_c, req.prior_hold_min],
            "dataset_checksum": self._checksum,
            "engine_version": ENGINE_VERSION,
        }
        raw = json.dumps(canonical, sort_keys=True, separators=(",", ":"))
        return hashlib.sha256(raw.encode()).hexdigest()

    def _quench_temper(self, req: SimulationRequest, k: _Checked, model_ok: bool):
        """Bonificado: el temple del propio protocolo (cifras fijas con fuente) seguido del revenido del estudiante."""
        steps = k.resolved.steps
        q = next((i for i, s in enumerate(steps) if s.kind == "quench"), None)
        i = None if q is None else next((j for j in range(q + 1, len(steps)) if steps[j].kind == "heat"), None)
        if i is None:  # protocolo incompleto (sin temple o sin recalentamiento): solo la parte válida, sin cifras
            valid = [s for s in steps[: len(steps) if q is None else q + 1]
                     if not (s.kind in ("heat", "hold") and s.temperature_c is None)]
            return metallurgy_practice.simulate_steps(k.material.id, "quench_temper", valid, model=False,
                                                      diagrams=False)
        aust = next((s for s in steps[:q] if s.kind == "heat"), None)
        soak = next((s for s in steps[:q] if s.kind == "hold"), None)
        hp = k.resolved.params.get("hold_time")
        info = {"source": "protocol", "protocol_id": k.protocol.id,
                "quench_temperature_c": aust.temperature_c if aust else None,
                "quench_hold_min": None if soak is None or soak.duration_s is None else soak.duration_s / 60}
        return metallurgy_practice.simulate_quench_temper(
            k.material.id, steps[:i], info, steps[i:], req.target_temperature_c, (hp.value or 0) * 60 if hp else 0.0,
            model=model_ok)

    def _prior(self, req: SimulationRequest, k: _Checked):
        """Estado templado de partida del revenido: protocolo de referencia o una práctica del historial."""
        snap = self.snapshot
        if k.dependency == "history":
            prior = snap.protocol(req.prior_protocol_id) if req.prior_protocol_id else None
            if prior is None or prior.material_id != k.material.id or prior.treatment_id != TreatmentId.QUENCH:
                prior = snap.protocol(k.protocol.prior_protocol_id) if k.protocol.prior_protocol_id else None
            if prior is None:
                return None, None
            r = PR.resolve(snap, prior, furnace_c=float(req.prior_temperature_c), hold_s=(req.prior_hold_min or 0) * 60)
            return r.steps, {"source": "history", "protocol_id": prior.id,
                             "quench_temperature_c": req.prior_temperature_c, "quench_hold_min": req.prior_hold_min}
        prior = snap.protocol(k.protocol.prior_protocol_id) if k.protocol.prior_protocol_id else None
        if prior is None:
            return None, None
        r = PR.resolve(snap, prior, furnace_c=0, hold_s=0, use_reference=True)
        fu, ho = r.params.get("furnace_temperature"), r.params.get("hold_time")
        return r.steps, {"source": "reference", "protocol_id": prior.id,
                         "quench_temperature_c": fu.value if fu else None, "quench_hold_min": ho.value if ho else None}

    def simulate(self, req: SimulationRequest) -> SimulationResult:
        loc = req.locale
        ctx = _Ctx(req=req, snap=self.snapshot, locale=loc)
        k = self._check(ctx)
        material, treatment, ic, pair, protocol, compat = k.material, k.treatment, k.ic, k.pair, k.protocol, k.compat

        history: ThermalHistory | None = None
        schematic = None
        diagrams: list[dict[str, Any]] = []
        practice = None
        model_sources: list[str] = []
        facts: dict[str, Any] = {}
        used_models: list[str] = []
        used_evidence: list[EvidenceRecord] = []
        level = k.level

        if ctx.blocking:
            status = SimulationStatus.INVALID_INPUT
        elif compat == CompatibilityStatus.UNSUPPORTED:
            status = SimulationStatus.UNSUPPORTED
        else:
            if self._is_legacy(protocol) and protocol.review_status == ReviewStatus.PUBLISHED:
                history = build_physical_history(protocol, target_temperature_c=req.target_temperature_c,
                                                 hold_s=req.hold_s, ambient_c=self.snapshot.interface.ambient_reference_c)
            if k.quantitative and history is not None:
                facts, used_models, used_evidence = self._quantify(ctx, material.id, treatment.id, ic, protocol, history)
            if k.resolved is not None:
                model_ok = level == "A"
                is_steel = material.family == MaterialFamily.STEEL
                if treatment.id == TreatmentId.TEMPER and k.dependency in ("reference", "history"):
                    prior_steps, prior_info = self._prior(req, k)
                    if prior_steps is None:
                        practice = metallurgy_practice.simulate_steps(material.id, "temper", k.resolved.steps, model=False)
                    else:
                        hp = k.resolved.params.get("hold_time")
                        practice = metallurgy_practice.simulate_temper(
                            material.id, prior_steps, prior_info, k.resolved.steps, req.target_temperature_c,
                            (hp.value or 0) * 60 if hp else 0.0, model=model_ok)
                elif treatment.id == TreatmentId.QUENCH_TEMPER:
                    practice = self._quench_temper(req, k, model_ok)
                else:
                    practice = metallurgy_practice.simulate_steps(material.id, treatment.id, k.resolved.steps,
                                                                  model=model_ok, diagrams=is_steel)
                history = ME.thermal_history(practice, illustrative=not is_steel)
                ctx.warn("MODEL_THERMAL_HISTORY" if is_steel else "THERMAL_CURVE_ILLUSTRATIVE", "info", group="model")
                diagrams = practice.diagrams
                if model_ok:
                    for key, v in ME.facts(practice, self.snapshot.dataset_version).items():
                        facts.setdefault(key, v)
                    used_models.append(metallurgy_practice.MODEL_VERSION)
                    model_sources = list(metallurgy_practice.MODEL_SOURCES)
                    for note in practice.notes:
                        if note in ASSUMPTION_NOTES:
                            continue
                        ctx.warn(note, "limitation" if note in ("MODEL_NO_AUSTENITIZATION", "MODEL_TEMPER_ABOVE_AE1",
                                                                "MODEL_OVERHEATING", "MODEL_TEMPER_OUTSIDE_VALIDITY")
                                 else "info", group="model")
                    if treatment.id == TreatmentId.MARTEMPER and practice.fractions \
                            and practice.fractions.get("bainite", 0) > 0.05:
                        ctx.warn("MARTEMPER_BAINITE_FORMED", "limitation", group="model",
                                 pct=f"{practice.fractions['bainite'] * 100:.0f}")
                elif is_steel and level == "B" and self._model_outside(k.resolved, treatment.id, is_steel):
                    ctx.warn("EXPLORATION_NO_NUMBERS", "info", group="model")
            elif protocol is None:
                schematic = build_schematic_cycle(treatment.stage_outline, target_temperature_c=req.target_temperature_c,
                                                  hold_s=req.hold_s)
                ctx.warn("SCHEMATIC_CYCLE_ONLY", "info", group="model")
            if req.hold_time_min == 0 and (k.resolved is None or ("hold_time" in k.resolved.params
                                                                   and k.resolved.params["hold_time"].basis != "pending")):
                ctx.warn("HOLD_ZERO", "info", group="input")
            n_facts = sum(1 for v in facts.values() if v)
            if material.family == MaterialFamily.GRAY_CAST_IRON and "mechanical_properties" not in facts:
                # Referencia de la norma para la clase (colada, sin tratar): no cuenta como resultado del tratamiento.
                facts["mechanical_properties"] = ME.gray_iron_mechanical(self.snapshot.dataset_version)
                model_sources.append("src_astm_a48_class35")
            if material.family == MaterialFamily.GRAY_CAST_IRON and "hardness" not in facts \
                    and (hl := ME.gray_iron_hardness(treatment.id.value, self.snapshot.dataset_version)) is not None:
                facts["hardness"] = hl
                model_sources += [s for s in hl.source_ids if s not in model_sources]
            if n_facts == 0:
                status = SimulationStatus.INSUFFICIENT_EVIDENCE
                if level == "A":
                    level = "B"
                if k.quantitative:
                    ctx.warn("NO_QUANTITATIVE_EVIDENCE", "limitation", group="evidence")
            elif n_facts == len(QuantityCode):
                status = SimulationStatus.COMPLETED
            else:
                status = SimulationStatus.PARTIAL_RESULT

        card = None if protocol is None or self._is_legacy(protocol) else PR.card(self.snapshot, protocol, loc, k.resolved)
        estimate = ME.estimate_block(practice if facts or (practice and practice.prior) else None, material.id,
                                     treatment.id, loc)
        illustration = ME.illustration(material.id, treatment.id, self.request_hash(req),
                                       practice if level == "A" else None, material.family.value,
                                       matrix_hint=None if protocol is None else protocol.variant_code,
                                       reason=self._illustration_reason(k, level, ctx))
        if protocol is not None:
            model_sources += [s for s in protocol.source_ids if s not in model_sources]

        why = self._why_missing(k, level, ctx, practice)
        why_q = {q: why for q in QuantityCode}
        if level == "A" and practice is not None:
            # Cifras que faltan POR DISEÑO aunque el protocolo sea válido: motivo concreto, no «usa el recomendado».
            if treatment.id in (TreatmentId.TEMPER, TreatmentId.QUENCH_TEMPER) and not facts.get("phase_fractions"):
                why_q[QuantityCode.PHASE_FRACTIONS] = "WHY_TEMPER_PHASES_LOW"
            if facts.get("hardness") is not None and not facts.get("mechanical_properties"):
                why_q[QuantityCode.MECHANICAL_PROPERTIES] = "WHY_STRENGTH_HV_RANGE"
        results = Results(**facts)
        result_status = {
            q: self._quantity_status(q, facts.get(q.value), status, loc, why_q[q]) for q in QuantityCode
        }

        return SimulationResult(
            request_hash=self.request_hash(req),
            simulation_status=status,
            dataset_version=self.snapshot.dataset_version,
            dataset_contains_unreviewed_content=self.snapshot.contains_unreviewed_content,
            protocol_version=(protocol.version if protocol and protocol.review_status == ReviewStatus.PUBLISHED else None),
            engine_version=ENGINE_VERSION,
            model_version=",".join(sorted(used_models)) or None,
            input=SimulationInputEcho(
                material_id=req.material_id,
                treatment_id=req.treatment_id,
                initial_condition_id=ic.id if ic else None,
                target_temperature_c=req.target_temperature_c,
                hold_time_min=req.hold_time_min,
                protocol_id=protocol.id if protocol else None,
                bath_temperature_c=req.bath_temperature_c,
                bath_time_min=req.bath_time_min,
                prior_mode=req.prior_mode if treatment.id == TreatmentId.TEMPER else None,
            ),
            compatibility_status=compat,
            material=MaterialRef(id=material.id, display_name=material.display_name, family=material.family),
            initial_condition=self._ic_out(ic, loc),
            protocol=self._protocol_out(protocol, req, loc),
            thermal_history=history.points if history else [],
            thermal_stages=history.stages if history else [],
            schematic_cycle=schematic,
            results=results,
            result_status=result_status,
            warnings=ctx.warnings,
            evidence=self._evidence_refs(material, treatment, used_evidence, used_models)
            + self._protocol_source_refs(model_sources),
            diagrams=diagrams,
            model_estimate=estimate,
            microstructure_illustration=illustration,
            result_level=level,
            headline=self._headline(ctx, k, level, gray_reference=material.family == MaterialFamily.GRAY_CAST_IRON
                                    and facts.get("hardness") is not None),
            protocol_card=card,
            assumptions=[
                Assumption(code=c, text=localize(ASSUMPTIONS, c, loc))
                for c in self._assumption_codes(facts, practice, material)
            ],
            explanation=Explanation(
                review_status=treatment.review_status.value,
                treatment_purpose=treatment.purpose_en if loc == "en" else treatment.purpose_es,
                prerequisites=treatment.prerequisites_en if loc == "en" else treatment.prerequisites_es,
                qualitative_outcome=treatment.qualitative_outcome_en if loc == "en" else treatment.qualitative_outcome_es,
                material_description=material.description_en if loc == "en" else material.description_es,
                material_limitations=material.limitations_en if loc == "en" else material.limitations_es,
                compatibility_reason=(pair.reason_en if loc == "en" else pair.reason_es) if pair else
                localize(MESSAGES, "COMBINATION_UNSUPPORTED", loc),
            ),
        )

    def _assumption_codes(self, facts: dict[str, Any], practice, material) -> list[str]:
        """Supuestos y procedencia de las cifras (se muestran en «Supuestos y fuentes», no como avisos)."""
        codes = ["GEOMETRY_OMITTED", "COOLING_FIXED_BY_PROTOCOL"]
        modeled = any(
            (f.evidence_kind == EvidenceKind.MODELED) for v in facts.values() if v
            for f in ([v] if isinstance(v, ResultFact) else v.values()))
        if modeled:
            codes.append("MODEL_ESTIMATES")
        if facts.get("grain_size") is not None:
            codes.append("GRAIN_MODEL")
        mech = facts.get("mechanical_properties") or {}
        if any(k in mech for k in ("yield_strength", "tensile_strength")):
            codes.append("STRENGTH_FROM_HARDNESS")
        if "tensile_strength_min" in mech:
            codes.append("A48C35_CLASS_REFERENCE")
        hd = facts.get("hardness")
        if hd is not None and hd.method == "literature_reference_other_specimen":
            codes.append("GRAY_HARDNESS_LITERATURE")
        codes.append("EDUCATIONAL_NOT_INDUSTRIAL")
        return codes

    def _illustration_reason(self, k: _Checked, level: str, ctx: _Ctx) -> str | None:
        """Por qué no hay microestructura calculada que dibujar (la interfaz lo explica al estudiante)."""
        if level == "A":
            return None
        if ctx.blocking:
            return "invalid_input"
        if k.dependency == "theory":
            return "theory"
        if k.protocol is not None and k.protocol.evidence_status == "source_unverified":
            return "unverified"
        if k.resolved is not None and self._model_outside(k.resolved, k.treatment.id,
                                                          k.material.family == MaterialFamily.STEEL):
            return "outside_range"
        if k.protocol is not None and not k.protocol.model_applicable:
            return "carburized_case" if k.ic is not None and k.ic.carburized else "not_modeled"
        return "not_computed"

    def _protocol_source_refs(self, ids: list[str]) -> list[EvidenceRef]:
        """Fuentes del protocolo (catálogo) y de los modelos (catálogo interno del motor)."""
        refs = []
        for sid in ids:
            s = self.snapshot.source(sid)
            if s is not None:
                refs.append(EvidenceRef(source_id=s.id, title=s.title, authors=s.authors, year=s.year, edition=s.edition,
                                        doi=s.doi, url=s.url, kind=s.kind, verification_status=s.verification_status,
                                        usage="supports_value"))
            else:
                refs += ME.source_refs([sid])
        return refs

    # ------------------------------------------------------- cuantificación
    def _quantify(self, ctx, material_id, treatment_id, ic, protocol: Protocol, history: ThermalHistory):
        facts: dict[str, Any] = {}
        used_ev: list[EvidenceRecord] = []
        used_models: list[str] = []
        snap = self.snapshot
        req = ctx.req
        for ev in snap.evidence:
            if not self._evidence_matches(ev, material_id, treatment_id, ic, protocol, req):
                continue
            fact = ResultFact(
                value=ev.value,  # type: ignore[arg-type]
                unit=ev.unit,  # type: ignore[arg-type]
                scale=ev.unit if ev.unit in ("HRC", "HV", "HBW", "HRB") else None,
                fraction_basis=ev.fraction_basis,
                method=ev.method or "experimental_lookup",
                evidence_kind=ev.evidence_kind,
                evidence_level=ev.evidence_level,
                source_ids=[ev.source_id],
                evidence_ids=[ev.id],
                dataset_version=snap.dataset_version,
                validity=ev.validity,
                uncertainty=ev.uncertainty,
            )
            q = ev.quantity_code.value  # type: ignore[union-attr]
            if q in ("phase_fractions", "microconstituent_fractions", "mechanical_properties"):
                facts.setdefault(q, {})[ev.quantity_key or "value"] = fact
            elif q not in facts:
                facts[q] = fact
            used_ev.append(ev)

        # Koistinen–Marburger: solo temple, con versión activable para esta condición.
        if treatment_id == TreatmentId.QUENCH and "microconstituent_fractions" not in facts:
            mv = next(
                (m for m in snap.model_versions if m.model_code == km.MODEL_CODE and m.material_id == material_id
                 and m.initial_condition_id == (ic.id if ic else None)),
                None,
            )
            if mv is not None:
                try:
                    final_t = history.points[-1].temperature_c
                    f = km.evaluate(mv, final_t)
                    facts["microconstituent_fractions"] = {
                        "martensite": ResultFact(
                            value=f,
                            unit="fraction",
                            fraction_basis="transformable_austenite_fraction",
                            method="koistinen_marburger",
                            evidence_kind=EvidenceKind.MODELED,
                            evidence_level=EvidenceLevel.BOUNDED_ESTIMATE,
                            source_ids=[mv.source_id],  # type: ignore[list-item]
                            evidence_ids=list(mv.parameter_evidence_ids.values()),
                            model_version=f"{mv.id}@{mv.version}",
                            dataset_version=snap.dataset_version,
                            validity=mv.validity,
                        )
                    }
                    used_models.append(f"{mv.id}@{mv.version}")
                except ModelNotActivated:
                    ctx.warn("MODEL_NOT_ACTIVATED", "info", model="Koistinen–Marburger")
                except ValueError:
                    ctx.warn("MODEL_NOT_ACTIVATED", "info", model="Koistinen–Marburger")
        return facts, used_models, used_ev

    @staticmethod
    def _evidence_matches(ev: EvidenceRecord, material_id, treatment_id, ic, protocol, req) -> bool:
        if ev.value is None or ev.quantity_code is None or ev.review_status != ReviewStatus.PUBLISHED:
            return False
        if not ev.locator or ev.evidence_kind in (EvidenceKind.ILLUSTRATIVE, EvidenceKind.UNAVAILABLE):
            return False
        if ev.material_id != material_id or ev.treatment_id != treatment_id:
            return False
        if ev.initial_condition_id != (ic.id if ic else None) or ev.protocol_id != protocol.id:
            return False
        v = ev.validity

        def inside(value: float, exact_key: str, lo_key: str, hi_key: str) -> bool:
            if exact_key in v:
                return float(v[exact_key]) == value
            if lo_key in v and hi_key in v:
                return float(v[lo_key]) <= value <= float(v[hi_key])
            return False  # sin dominio declarado no se aplica (conservador)

        return inside(req.target_temperature_c, "temperature_c", "temperature_min_c", "temperature_max_c") and inside(
            req.hold_s, "hold_s", "hold_min_s", "hold_max_s"
        )

    def _why_missing(self, k: _Checked, level: str, ctx: _Ctx, practice) -> str:
        """Motivo concreto (y qué hacer) cuando una cifra no se puede dar."""
        if k.material.family == MaterialFamily.GRAY_CAST_IRON:
            return "WHY_GRAY_IRON"
        code = self._illustration_reason(k, level, ctx)
        if code is None and practice is not None and "MODEL_NO_AUSTENITIZATION" in practice.notes:
            return "WHY_NO_AUSTENITIZATION"
        if code is None and practice is not None and "MODEL_GRAIN_INTERCRITICAL" in practice.notes:
            return "WHY_INTERCRITICAL"
        return {"theory": "WHY_THEORY", "unverified": "WHY_UNVERIFIED", "outside_range": "WHY_OUTSIDE_RANGE",
                "carburized_case": "WHY_CARBURIZED", "not_modeled": "WHY_NOT_MODELED"}.get(code or "", "WHY_GENERIC")

    @staticmethod
    def _quantity_status(q: QuantityCode, fact, status: SimulationStatus, loc: str, why: str = "WHY_GENERIC") -> QuantityStatus:
        if fact:
            first = fact if isinstance(fact, ResultFact) else next(iter(fact.values()))
            if first.evidence_kind == EvidenceKind.MODELED and first.method != "koistinen_marburger":
                return QuantityStatus(evidence_level=first.evidence_level, reason_code="MODEL_ESTIMATE",
                                      reason="Calculado con modelos publicados (ver «Supuestos y origen de las cifras»)"
                                      if loc == "es" else "Computed with published models (see «Assumptions and origin "
                                      "of the figures»)")
            return QuantityStatus(evidence_level=first.evidence_level, reason_code="SUPPORTED_BY_EVIDENCE",
                                  reason="Respaldado por evidencia publicada" if loc == "es" else "Supported by published evidence")
        if status == SimulationStatus.INVALID_INPUT:
            return QuantityStatus(evidence_level=EvidenceLevel.UNSUPPORTED, reason_code="INVALID_INPUT",
                                  reason="Corrige la entrada para continuar" if loc == "es" else "Correct the input to continue")
        if status == SimulationStatus.UNSUPPORTED:
            return QuantityStatus(evidence_level=EvidenceLevel.UNSUPPORTED, reason_code="COMBINATION_UNSUPPORTED",
                                  reason=localize(MESSAGES, "COMBINATION_UNSUPPORTED", loc))
        if why == "WHY_GRAY_IRON" and q == QuantityCode.GRAIN_SIZE:
            why = "WHY_GRAY_IRON_GRAIN"
        return QuantityStatus(evidence_level=EvidenceLevel.INSUFFICIENT_EVIDENCE,
                              reason_code="NOT_APPLICABLE" if why == "WHY_GRAY_IRON_GRAIN" else why,
                              reason=localize(MESSAGES, why, loc))

    # ------------------------------------------------------- salida
    @staticmethod
    def _ic_out(ic: InitialCondition | None, loc: str) -> InitialConditionOut | None:
        if ic is None:
            return None
        return InitialConditionOut(
            id=ic.id,
            name=ic.name_en if loc == "en" else ic.name_es,
            description=ic.description_en if loc == "en" else ic.description_es,
            hardened=ic.hardened,
            carburized=ic.carburized,
            review_status=ic.review_status.value,
        )

    def _protocol_out(self, p: Protocol | None, req: SimulationRequest, loc: str) -> ProtocolOut | None:
        if p is None:
            return None
        stages = []
        for s in p.stages:
            if s.end_temperature_mode == "user_target":
                et, eb = req.target_temperature_c, "user_input"
            elif s.end_temperature_mode == "value":
                et, eb = s.end_temperature_c, "published_evidence"
            elif s.end_temperature_mode == "ambient":
                et, eb = None, "ambient_convention"
            else:
                et, eb = None, "not_published"
            if s.duration_mode == "user_hold":
                du, db = req.hold_s, "user_input"
            elif s.duration_mode == "value":
                du, db = s.duration_s, "published_evidence"
            elif s.duration_mode == "rate":
                du, db = None, "published_rate"
            else:
                du, db = None, "not_published"
            stages.append(ProtocolStageOut(
                ordinal=s.ordinal, kind=s.kind.value, label_key=s.label_key,
                label=localize(STAGE_LABELS, s.label_key, loc),
                end_temperature_c=et, end_temperature_basis=eb, duration_s=du, duration_basis=db,
            ))
        hold = next((s for s in p.stages if s.duration_mode == "user_hold"), None)
        return ProtocolOut(
            id=p.id,
            version=p.version,
            review_status=p.review_status.value,
            medium=p.medium_en if loc == "en" else p.medium_es,
            medium_documented=p.medium_evidence_id is not None,
            variant=(p.variant_en if loc == "en" else p.variant_es),
            fully_specified=p.is_fully_specified,
            user_hold_stage_label=localize(STAGE_LABELS, hold.label_key, loc) if hold else None,
            stages=stages,
        )

    def _evidence_refs(self, material, treatment, used_ev: list[EvidenceRecord], used_models: list[str]) -> list[EvidenceRef]:
        snap = self.snapshot
        refs: list[EvidenceRef] = []
        seen: set[tuple[str, str | None]] = set()

        def add(sid: str, usage: str, ev: EvidenceRecord | None = None) -> None:
            s = snap.source(sid)
            key = (sid, ev.id if ev else None)
            if s is None or key in seen:
                return
            seen.add(key)
            refs.append(EvidenceRef(
                source_id=s.id, title=s.title, authors=s.authors, year=s.year, edition=s.edition,
                doi=s.doi, url=s.url, kind=s.kind, verification_status=s.verification_status,
                usage=usage,  # type: ignore[arg-type]
                evidence_id=ev.id if ev else None, locator=ev.locator if ev else None,
            ))

        for ev in used_ev:
            add(ev.source_id, "supports_value", ev)
        for mv in snap.model_versions:
            if f"{mv.id}@{mv.version}" in used_models and mv.source_id:
                add(mv.source_id, "supports_value")
        guard = self._physical_limit(material.family)
        if guard is not None:
            ev = snap.evidence_by_id(guard.evidence_id)
            if ev:
                add(ev.source_id, "supports_limit", ev)
        for sid in list(treatment.suggested_source_ids) + list(material.suggested_source_ids):
            add(sid, "suggested_reading")
        return refs
