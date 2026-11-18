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
    """Entrada canónica interna. El tiempo físico se guarda en segundos."""

    model_config = ConfigDict(frozen=True, extra="forbid")
    material_id: str
    treatment_id: str
    initial_condition_id: str | None = None
    target_temperature_c: float = Field(ge=0, le=1600, allow_inf_nan=False)
    hold_time_min: float = Field(ge=0, allow_inf_nan=False)
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
    published: bool


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


@dataclass
class _Ctx:
    req: SimulationRequest
    snap: DatasetSnapshot
    locale: Locale
    warnings: list[Warning] = field(default_factory=list)

    def warn(self, code: str, severity: str, field_: str | None = None, **params: Any) -> None:
        if any(w.code == code for w in self.warnings):
            return
        self.warnings.append(
            Warning(
                code=code,
                severity=severity,  # type: ignore[arg-type]
                message_key=f"scientific.{code.lower()}",
                message=localize(MESSAGES, code, self.locale, **params),
                params=params,
                field=field_,
            )
        )

    @property
    def blocking(self) -> bool:
        return any(w.severity == "blocking" for w in self.warnings)


def _fmt(v: float) -> str:
    return f"{v:g}"


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
        conds = snap.conditions_for(material.id)
        ic: InitialCondition | None
        if req.initial_condition_id is not None:
            ic = next((c for c in conds if c.id == req.initial_condition_id), None)
            if ic is None:
                raise UnknownEntity("initial_condition_id", req.initial_condition_id)
        elif len(conds) == 1:
            ic = conds[0]
        elif not conds:
            ic = None
        else:
            raise InvalidState(
                "invalid_state",
                "Hay varias condiciones iniciales para este material: elige una.",
                "initial_condition_id",
            )
        pair = snap.pair(material.id, treatment.id)
        protocol = snap.protocol(pair.protocol_id) if pair else None
        return material, treatment, ic, pair, protocol

    def _domains(self, pair: MaterialTreatment | None) -> tuple[Domain, Domain]:
        snap = self.snapshot

        def pub(eid: str | None) -> bool:
            ev = snap.evidence_by_id(eid)
            return ev is not None and ev.review_status == ReviewStatus.PUBLISHED and bool(ev.locator)

        if pair is None:
            empty_t = Domain(min=None, max=None, unit="°C", evidence_id=None, published=False)
            return empty_t, Domain(min=None, max=None, unit="s", evidence_id=None, published=False)
        t_dom = Domain(
            min=pair.temperature_min_c,
            max=pair.temperature_max_c,
            unit="°C",
            evidence_id=pair.temperature_evidence_id,
            published=pub(pair.temperature_evidence_id),
        )
        h_dom = Domain(
            min=pair.hold_min_s,
            max=pair.hold_max_s,
            unit="s",
            evidence_id=pair.hold_evidence_id,
            published=pub(pair.hold_evidence_id),
        )
        return t_dom, h_dom

    def _physical_limit(self, family: MaterialFamily):
        guards = [g for g in self.snapshot.physical_guards if g.applies_to_family == family]
        return min(guards, key=lambda g: g.max_temperature_c) if guards else None

    # --------------------------------------------------------- validación
    def _check(self, ctx: _Ctx):
        req = ctx.req
        material, treatment, ic, pair, protocol = self._resolve(req)
        t_dom, h_dom = self._domains(pair)
        guard = self._physical_limit(material.family)

        if self.snapshot.contains_unreviewed_content:
            ctx.warn("DATASET_CONTAINS_UNREVIEWED_CONTENT", "info")

        # 1. Límite físico (solo bloquea).
        if guard is not None and req.target_temperature_c >= guard.max_temperature_c:
            ctx.warn(
                "TEMPERATURE_ABOVE_PHYSICAL_LIMIT",
                "blocking",
                "target_temperature_c",
                temperature_c=_fmt(req.target_temperature_c),
                limit_c=_fmt(guard.max_temperature_c),
                guard_review=guard.review_status.value,
            )
            if guard.review_status != ReviewStatus.PUBLISHED:
                ctx.warn("PHYSICAL_LIMIT_UNREVIEWED", "info")

        # 2. Dominio del protocolo.
        if t_dom.published and t_dom.min is not None and t_dom.max is not None:
            if not (t_dom.min <= req.target_temperature_c <= t_dom.max):
                ctx.warn(
                    "TEMPERATURE_OUTSIDE_PROTOCOL_RANGE",
                    "blocking",
                    "target_temperature_c",
                    min_c=_fmt(t_dom.min),
                    max_c=_fmt(t_dom.max),
                )
        else:
            ctx.warn("TEMPERATURE_DOMAIN_UNPUBLISHED", "limitation", "target_temperature_c")
        if h_dom.published and h_dom.min is not None and h_dom.max is not None:
            if not (h_dom.min <= req.hold_s <= h_dom.max):
                ctx.warn(
                    "HOLD_OUTSIDE_PROTOCOL_RANGE",
                    "blocking",
                    "hold_time_min",
                    min_min=_fmt(h_dom.min / 60),
                    max_min=_fmt(h_dom.max / 60),
                )
        else:
            ctx.warn("HOLD_DOMAIN_UNPUBLISHED", "limitation", "hold_time_min")
        if req.hold_time_min > self.snapshot.interface.hold_ui_max_min:
            # rango de interfaz: lo valida el esquema de la API; defensa en profundidad
            ctx.warn("HOLD_OUTSIDE_PROTOCOL_RANGE", "blocking", "hold_time_min",
                     min_min="0", max_min=_fmt(self.snapshot.interface.hold_ui_max_min))

        # 3. Compatibilidad.
        compat = pair.compatibility_status if pair else CompatibilityStatus.UNSUPPORTED
        if compat == CompatibilityStatus.UNSUPPORTED:
            ctx.warn("COMBINATION_UNSUPPORTED", "limitation")

        # 4. Reglas por material / tratamiento.
        state_ok = True
        if treatment.id == TreatmentId.TEMPER and (ic is None or ic.hardened is not True):
            ctx.warn("TEMPER_REQUIRES_HARDENED_STATE", "limitation", "initial_condition_id")
            state_ok = False
        if pair and pair.required_initial_state and ic is not None:
            for k, expected in pair.required_initial_state.items():
                if treatment.id == TreatmentId.TEMPER and k == "hardened":
                    continue  # ya cubierto por TEMPER_REQUIRES_HARDENED_STATE
                if getattr(ic, k, None) != expected:
                    ctx.warn("REQUIRED_INITIAL_STATE_NOT_MET", "limitation", "initial_condition_id",
                             requirement=f"{k}={expected}")
                    state_ok = False
        if material.id == "aisi_8620" and (ic is None or ic.carburized is not True):
            ctx.warn("CARBURIZED_CASE_NOT_ASSUMED", "info")
        if material.family == MaterialFamily.GRAY_CAST_IRON:
            ctx.warn("CAST_IRON_NO_STEEL_MODELS", "info")
        if treatment.id == TreatmentId.ANNEAL and (protocol is None or not protocol.variant_es):
            ctx.warn("ANNEAL_VARIANT_REQUIRED", "limitation")
        if treatment.id in (TreatmentId.AUSTEMPER, TreatmentId.MARTEMPER) and (
            protocol is None or not protocol.is_fully_specified
        ):
            ctx.warn("STAGED_PROTOCOL_PENDING", "limitation")

        protocol_ok = (
            protocol is not None
            and protocol.review_status == ReviewStatus.PUBLISHED
            and protocol.is_fully_specified
        )
        if not protocol_ok:
            ctx.warn("MISSING_VALIDATED_PROTOCOL", "limitation")

        quantitative = (
            compat in (CompatibilityStatus.SUPPORTED, CompatibilityStatus.CONDITIONAL)
            and pair is not None
            and pair.quantitative_outputs_enabled
            and pair.review_status == ReviewStatus.PUBLISHED
            and protocol_ok
            and state_ok
            and (ic is None or ic.review_status == ReviewStatus.PUBLISHED)
            and not self.snapshot.contains_unreviewed_content
        )
        if pair is not None and compat != CompatibilityStatus.UNSUPPORTED and not pair.quantitative_outputs_enabled:
            ctx.warn("PAIR_NOT_QUANTITATIVE", "limitation")
        return material, treatment, ic, pair, protocol, t_dom, h_dom, guard, compat, quantitative

    def validate(self, req: SimulationRequest) -> ValidationReport:
        ctx = _Ctx(req=req, snap=self.snapshot, locale=req.locale)
        _m, _t, ic, _p, _pr, t_dom, h_dom, guard, compat, quant = self._check(ctx)
        if ctx.blocking:
            status = SimulationStatus.INVALID_INPUT
        elif compat == CompatibilityStatus.UNSUPPORTED:
            status = SimulationStatus.UNSUPPORTED
        elif quant:
            status = SimulationStatus.COMPLETED  # predicción optimista; se confirma al simular
        else:
            status = SimulationStatus.INSUFFICIENT_EVIDENCE
        return ValidationReport(
            can_run=not ctx.blocking,
            predicted_status=status,
            compatibility_status=compat,
            quantitative_eligible=quant,
            temperature_domain=t_dom,
            hold_domain=h_dom,
            physical_limit_c=guard.max_temperature_c if guard else None,
            initial_condition_id=ic.id if ic else None,
            warnings=ctx.warnings,
        )

    # ------------------------------------------------------- historial
    def build_thermal_history(self, req: SimulationRequest) -> ThermalHistory | None:
        _m, _t, _ic, pair, protocol = self._resolve(req)
        if protocol is None or protocol.review_status != ReviewStatus.PUBLISHED:
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
            "dataset_checksum": self._checksum,
            "engine_version": ENGINE_VERSION,
        }
        raw = json.dumps(canonical, sort_keys=True, separators=(",", ":"))
        return hashlib.sha256(raw.encode()).hexdigest()

    def simulate(self, req: SimulationRequest) -> SimulationResult:
        loc = req.locale
        ctx = _Ctx(req=req, snap=self.snapshot, locale=loc)
        material, treatment, ic, pair, protocol, _td, _hd, _g, compat, quant = self._check(ctx)

        history: ThermalHistory | None = None
        schematic = None
        facts: dict[str, Any] = {}
        used_models: list[str] = []
        used_evidence: list[EvidenceRecord] = []

        if ctx.blocking:
            status = SimulationStatus.INVALID_INPUT
        elif compat == CompatibilityStatus.UNSUPPORTED:
            status = SimulationStatus.UNSUPPORTED
        else:
            if protocol is not None and protocol.review_status == ReviewStatus.PUBLISHED:
                history = build_physical_history(
                    protocol,
                    target_temperature_c=req.target_temperature_c,
                    hold_s=req.hold_s,
                    ambient_c=self.snapshot.interface.ambient_reference_c,
                )
            if history is None:
                templates = protocol.stages if protocol is not None else treatment.stage_outline
                schematic = build_schematic_cycle(
                    templates, target_temperature_c=req.target_temperature_c, hold_s=req.hold_s
                )
                ctx.warn("SCHEMATIC_CYCLE_ONLY", "info")
            if req.hold_time_min == 0:
                ctx.warn("HOLD_ZERO", "info")
            if quant and history is not None:
                facts, used_models, used_evidence = self._quantify(ctx, material.id, treatment.id, ic, protocol, history)
            n_facts = sum(1 for v in facts.values() if v)
            if n_facts == 0:
                status = SimulationStatus.INSUFFICIENT_EVIDENCE
                if quant:
                    ctx.warn("NO_QUANTITATIVE_EVIDENCE", "limitation")
            elif n_facts == len(QuantityCode):
                status = SimulationStatus.COMPLETED
            else:
                status = SimulationStatus.PARTIAL_RESULT

        user_hold_label = None
        if protocol is not None:
            hold_stage = next((s for s in protocol.stages if s.duration_mode == "user_hold"), None)
            if hold_stage:
                user_hold_label = localize(STAGE_LABELS, hold_stage.label_key, loc)
        elif treatment.stage_outline:
            hold_tpl = next((s for s in treatment.stage_outline if s.user_hold), None)
            if hold_tpl:
                user_hold_label = localize(STAGE_LABELS, hold_tpl.label_key, loc)
        if user_hold_label and status not in (SimulationStatus.INVALID_INPUT, SimulationStatus.UNSUPPORTED):
            ctx.warn("HOLD_REFERS_TO_STAGE", "info", "hold_time_min", stage=user_hold_label)

        results = Results(**facts)
        result_status = {
            q: self._quantity_status(q, facts.get(q.value), status, loc) for q in QuantityCode
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
            evidence=self._evidence_refs(material, treatment, used_evidence, used_models),
            assumptions=[
                Assumption(code=c, text=localize(ASSUMPTIONS, c, loc))
                for c in (
                    "GEOMETRY_OMITTED",
                    "COOLING_FIXED_BY_PROTOCOL",
                    "EDUCATIONAL_NOT_INDUSTRIAL",
                    "LINEAR_SEGMENTS_ILLUSTRATIVE",
                )
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

    @staticmethod
    def _quantity_status(q: QuantityCode, fact, status: SimulationStatus, loc: str) -> QuantityStatus:
        if fact:
            first = fact if isinstance(fact, ResultFact) else next(iter(fact.values()))
            return QuantityStatus(evidence_level=first.evidence_level, reason_code="SUPPORTED_BY_EVIDENCE",
                                  reason="Respaldado por evidencia publicada" if loc == "es" else "Supported by published evidence")
        if status == SimulationStatus.INVALID_INPUT:
            return QuantityStatus(evidence_level=EvidenceLevel.UNSUPPORTED, reason_code="INVALID_INPUT",
                                  reason="Corrige la entrada para continuar" if loc == "es" else "Correct the input to continue")
        if status == SimulationStatus.UNSUPPORTED:
            return QuantityStatus(evidence_level=EvidenceLevel.UNSUPPORTED, reason_code="COMBINATION_UNSUPPORTED",
                                  reason=localize(MESSAGES, "COMBINATION_UNSUPPORTED", loc))
        return QuantityStatus(
            evidence_level=EvidenceLevel.INSUFFICIENT_EVIDENCE,
            reason_code="NO_QUANTITATIVE_EVIDENCE",
            reason="No estimable con la evidencia actual" if loc == "es" else "Not estimable from current evidence",
        )

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
