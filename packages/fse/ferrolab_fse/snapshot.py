"""Snapshot científico inmutable (doc 05 §14.6).

El FSE nunca consulta la red ni la base de datos: recibe un `DatasetSnapshot`
construido a partir de una publicación (`dataset_releases`). Toda cifra que el
motor pueda usar vive aquí con su `evidence_id` y su fuente.
"""

from __future__ import annotations

import hashlib
import json
import math
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from .enums import (
    CompatibilityStatus,
    EvidenceKind,
    EvidenceLevel,
    MatchQuality,
    MaterialFamily,
    MaterialId,
    QuantityCode,
    ReviewStatus,
    SchematicLevel,
    StageKind,
    TreatmentId,
)


class _Frozen(BaseModel):
    model_config = ConfigDict(frozen=True, extra="forbid")


def _finite(v: float | None) -> float | None:
    if v is not None and not math.isfinite(v):
        raise ValueError("los valores numéricos deben ser finitos")
    return v


# ---------------------------------------------------------------- fuentes
class Source(_Frozen):
    id: str
    kind: Literal["book", "standard", "article", "dataset", "web", "editorial"]
    title: str
    authors: str | None = None
    year: int | None = None
    publisher: str | None = None
    edition: str | None = None
    doi: str | None = None
    url: str | None = None
    license_code: str | None = None
    license_url: str | None = None
    # "unverified": la referencia existe en el Bluebook pero nadie del proyecto
    # ha consultado el contenido; NO respalda cifras.
    verification_status: Literal["unverified", "verified"] = "unverified"
    notes: str | None = None


class EvidenceRecord(_Frozen):
    """Evidencia granular. Una cifra sin `source_id`+`locator` no se publica."""

    id: str
    source_id: str
    locator: str | None = None
    claim_es: str
    claim_en: str
    evidence_kind: EvidenceKind
    evidence_level: EvidenceLevel = EvidenceLevel.QUALITATIVE
    method: str | None = None
    material_id: MaterialId | None = None
    treatment_id: TreatmentId | None = None
    initial_condition_id: str | None = None
    protocol_id: str | None = None
    quantity_code: QuantityCode | None = None
    quantity_key: str | None = None  # p. ej. "martensite" dentro de fracciones
    value: float | None = None
    unit: str | None = None
    fraction_basis: str | None = None
    validity: dict[str, Any] = Field(default_factory=dict)
    uncertainty: dict[str, Any] | None = None
    review_status: ReviewStatus = ReviewStatus.DRAFT

    @field_validator("value")
    @classmethod
    def _value_finite(cls, v: float | None) -> float | None:
        return _finite(v)

    @model_validator(mode="after")
    def _numeric_needs_provenance(self) -> "EvidenceRecord":
        if self.value is not None:
            if not self.unit:
                raise ValueError(f"evidencia {self.id}: valor numérico sin unidad")
            if self.review_status == ReviewStatus.PUBLISHED and not self.locator:
                raise ValueError(f"evidencia {self.id}: cifra publicada sin localizador")
        return self


# ---------------------------------------------------------------- catálogo
class CompositionRange(_Frozen):
    element: str
    min_wt_pct: float | None = None
    max_wt_pct: float | None = None
    nominal_wt_pct: float | None = None
    evidence_id: str

    @model_validator(mode="after")
    def _bounds(self) -> "CompositionRange":
        for v in (self.min_wt_pct, self.max_wt_pct, self.nominal_wt_pct):
            _finite(v)
            if v is not None and not (0 <= v <= 100):
                raise ValueError("porcentaje en masa fuera de [0, 100]")
        if (
            self.min_wt_pct is not None
            and self.max_wt_pct is not None
            and self.min_wt_pct > self.max_wt_pct
        ):
            raise ValueError("min_wt_pct > max_wt_pct")
        return self


class Material(_Frozen):
    id: MaterialId
    family: MaterialFamily
    display_name: str
    standard_note_es: str
    standard_note_en: str
    description_es: str
    description_en: str
    limitations_es: list[str] = Field(default_factory=list)
    limitations_en: list[str] = Field(default_factory=list)
    compositions: list[CompositionRange] = Field(default_factory=list)
    suggested_source_ids: list[str] = Field(default_factory=list)
    review_status: ReviewStatus = ReviewStatus.DRAFT


class InitialCondition(_Frozen):
    id: str
    material_id: MaterialId
    name_es: str
    name_en: str
    description_es: str
    description_en: str
    # None = desconocido / no documentado. Nunca se infiere.
    hardened: bool | None = None
    carburized: bool | None = None
    matrix: str | None = None
    graphite_morphology: str | None = None
    source_id: str | None = None
    review_status: ReviewStatus = ReviewStatus.DRAFT


class Treatment(_Frozen):
    id: TreatmentId
    name_es: str
    name_en: str
    purpose_es: str
    purpose_en: str
    prerequisites_es: str
    prerequisites_en: str
    qualitative_outcome_es: str
    qualitative_outcome_en: str
    # Estructura de la máquina de estados (doc 04 §13.4), sin cifras.
    stage_outline: list["StageTemplate"]
    suggested_source_ids: list[str] = Field(default_factory=list)
    review_status: ReviewStatus = ReviewStatus.DRAFT


class StageTemplate(_Frozen):
    kind: StageKind
    label_key: str
    end_level: SchematicLevel
    user_hold: bool = False


class MaterialTreatment(_Frozen):
    material_id: MaterialId
    treatment_id: TreatmentId
    compatibility_status: CompatibilityStatus
    reason_es: str
    reason_en: str
    quantitative_outputs_enabled: bool = False
    protocol_id: str | None = None
    required_initial_state: dict[str, Any] = Field(default_factory=dict)
    temperature_min_c: float | None = None
    temperature_max_c: float | None = None
    temperature_evidence_id: str | None = None
    hold_min_s: float | None = None
    hold_max_s: float | None = None
    hold_evidence_id: str | None = None
    review_status: ReviewStatus = ReviewStatus.DRAFT

    @model_validator(mode="after")
    def _bounds(self) -> "MaterialTreatment":
        for v in (self.temperature_min_c, self.temperature_max_c, self.hold_min_s, self.hold_max_s):
            _finite(v)
        if (self.temperature_min_c is not None or self.temperature_max_c is not None) and not self.temperature_evidence_id:
            raise ValueError("rango de temperatura sin evidence_id")
        if (self.hold_min_s is not None or self.hold_max_s is not None) and not self.hold_evidence_id:
            raise ValueError("rango de mantenimiento sin evidence_id")
        if (
            self.temperature_min_c is not None
            and self.temperature_max_c is not None
            and self.temperature_min_c > self.temperature_max_c
        ):
            raise ValueError("temperature_min_c > temperature_max_c")
        if self.hold_min_s is not None and self.hold_min_s < 0:
            raise ValueError("hold_min_s < 0")
        if self.hold_min_s is not None and self.hold_max_s is not None and self.hold_min_s > self.hold_max_s:
            raise ValueError("hold_min_s > hold_max_s")
        if self.compatibility_status in (
            CompatibilityStatus.EDUCATIONAL_ONLY,
            CompatibilityStatus.UNSUPPORTED,
        ) and self.quantitative_outputs_enabled:
            raise ValueError("una pareja educativa/no soportada no puede emitir cifras")
        return self


class ProtocolStage(_Frozen):
    """Etapa de un protocolo. Cada cifra exige `*_evidence_id`."""

    ordinal: int
    kind: StageKind
    label_key: str
    end_level: SchematicLevel
    end_temperature_mode: Literal["user_target", "ambient", "value", "unpublished"]
    end_temperature_c: float | None = None
    end_temperature_evidence_id: str | None = None
    duration_mode: Literal["user_hold", "value", "rate", "unpublished"]
    duration_s: float | None = None
    rate_c_per_s: float | None = None
    duration_evidence_id: str | None = None

    @model_validator(mode="after")
    def _consistency(self) -> "ProtocolStage":
        _finite(self.end_temperature_c)
        _finite(self.duration_s)
        _finite(self.rate_c_per_s)
        if self.end_temperature_mode == "value":
            if self.end_temperature_c is None or not self.end_temperature_evidence_id:
                raise ValueError(f"etapa {self.ordinal}: temperatura sin valor o evidencia")
        if self.duration_mode == "value":
            if self.duration_s is None or self.duration_s <= 0 or not self.duration_evidence_id:
                raise ValueError(f"etapa {self.ordinal}: duración sin valor positivo o evidencia")
        if self.duration_mode == "rate":
            if self.rate_c_per_s is None or self.rate_c_per_s <= 0 or not self.duration_evidence_id:
                raise ValueError(f"etapa {self.ordinal}: velocidad sin valor positivo o evidencia")
        if self.kind in (StageKind.HOLD, StageKind.ISOTHERMAL_HOLD) and self.duration_mode == "rate":
            raise ValueError("una meseta no se define por velocidad")
        return self

    @property
    def is_fully_specified(self) -> bool:
        return self.end_temperature_mode != "unpublished" and self.duration_mode != "unpublished"


class Protocol(_Frozen):
    id: str
    version: str
    material_id: MaterialId
    treatment_id: TreatmentId
    variant_es: str | None = None
    variant_en: str | None = None
    medium_es: str
    medium_en: str
    medium_evidence_id: str | None = None
    stages: list[ProtocolStage]
    review_status: ReviewStatus = ReviewStatus.DRAFT

    @model_validator(mode="after")
    def _ordered(self) -> "Protocol":
        ords = [s.ordinal for s in self.stages]
        if ords != sorted(ords) or len(set(ords)) != len(ords):
            raise ValueError("etapas de protocolo fuera de orden o repetidas")
        if sum(1 for s in self.stages if s.duration_mode == "user_hold") > 1:
            raise ValueError("solo una etapa puede usar el tiempo del estudiante")
        return self

    @property
    def is_fully_specified(self) -> bool:
        return all(s.is_fully_specified for s in self.stages)


class PhysicalGuard(_Frozen):
    """Límite que SOLO bloquea (nunca produce un resultado).

    Se aplica incluso en borrador porque bloquear es la alternativa segura
    (README §6); su estado de revisión se muestra al estudiante.
    """

    id: str
    applies_to_family: MaterialFamily
    max_temperature_c: float
    reason_es: str
    reason_en: str
    evidence_id: str
    review_status: ReviewStatus = ReviewStatus.DRAFT


class ModelVersion(_Frozen):
    id: str
    model_code: Literal["koistinen_marburger", "andrews_ms", "jmak", "e140_conversion"]
    version: str
    approved: bool = False
    material_id: MaterialId | None = None
    initial_condition_id: str | None = None
    parameters: dict[str, float] = Field(default_factory=dict)
    parameter_evidence_ids: dict[str, str] = Field(default_factory=dict)
    validity: dict[str, Any] = Field(default_factory=dict)
    source_id: str | None = None
    golden_case_ids: list[str] = Field(default_factory=list)

    @property
    def activatable(self) -> bool:
        """GATE-C2/SCI-09: aprobado, con fuente, golden case y evidencia por parámetro."""
        return (
            self.approved
            and self.source_id is not None
            and len(self.golden_case_ids) > 0
            and bool(self.parameters)
            and all(k in self.parameter_evidence_ids for k in self.parameters)
        )


class Micrograph(_Frozen):
    id: str
    material_id: MaterialId
    treatment_id: TreatmentId | None = None
    initial_condition_id: str | None = None
    image_url: str
    source_id: str
    author: str
    attribution: str
    license_code: str
    license_url: str
    license_verified: bool = False
    magnification_x: float | None = None
    scale_bar_um: float | None = None
    pixel_size_um: float | None = None
    preparation: str | None = None
    imaging_method: Literal["optical", "sem", "illustration"]
    match_quality: MatchQuality
    constituents: list[str] = Field(default_factory=list)
    alt_es: str
    alt_en: str
    review_status: ReviewStatus = ReviewStatus.DRAFT

    @model_validator(mode="after")
    def _checks(self) -> "Micrograph":
        if self.magnification_x is not None and self.magnification_x <= 0:
            raise ValueError("magnification_x debe ser > 0")
        if self.scale_bar_um is not None and self.scale_bar_um <= 0:
            raise ValueError("scale_bar_um debe ser > 0")
        return self


class KnowledgeEntry(_Frozen):
    slug: str
    category: Literal["glossary", "concept", "faq"]
    title_es: str
    title_en: str
    body_es: str
    body_en: str
    related_slugs: list[str] = Field(default_factory=list)
    suggested_source_ids: list[str] = Field(default_factory=list)
    review_status: ReviewStatus = ReviewStatus.DRAFT


class PracticeQuestion(_Frozen):
    id: str
    prompt_es: str
    prompt_en: str
    options_es: list[str]
    options_en: list[str]
    correct_index: int
    feedback_es: str
    feedback_en: str
    related_slug: str | None = None
    review_status: ReviewStatus = ReviewStatus.DRAFT

    @model_validator(mode="after")
    def _opts(self) -> "PracticeQuestion":
        if len(self.options_es) != len(self.options_en) or not (0 <= self.correct_index < len(self.options_es)):
            raise ValueError(f"pregunta {self.id}: opciones inconsistentes")
        return self


class InterfaceConventions(_Frozen):
    """Convenciones de INTERFAZ, no datos metalúrgicos."""

    furnace_ui_min_c: float = 20.0
    furnace_ui_max_c: float = 1600.0
    hold_ui_max_min: float = 1440.0
    # Temperatura de partida del ciclo dibujado: convención de interfaz.
    ambient_reference_c: float = 20.0


class DatasetSnapshot(_Frozen):
    dataset_version: str
    contains_unreviewed_content: bool
    interface: InterfaceConventions = InterfaceConventions()
    sources: list[Source] = Field(default_factory=list)
    evidence: list[EvidenceRecord] = Field(default_factory=list)
    materials: list[Material]
    initial_conditions: list[InitialCondition] = Field(default_factory=list)
    treatments: list[Treatment]
    material_treatments: list[MaterialTreatment]
    protocols: list[Protocol] = Field(default_factory=list)
    physical_guards: list[PhysicalGuard] = Field(default_factory=list)
    model_versions: list[ModelVersion] = Field(default_factory=list)
    micrographs: list[Micrograph] = Field(default_factory=list)
    knowledge: list[KnowledgeEntry] = Field(default_factory=list)
    practice_questions: list[PracticeQuestion] = Field(default_factory=list)

    @model_validator(mode="after")
    def _referential_integrity(self) -> "DatasetSnapshot":
        src = {s.id for s in self.sources}
        ev = {e.id for e in self.evidence}
        mats = {m.id for m in self.materials}
        ics = {c.id for c in self.initial_conditions}
        prots = {p.id for p in self.protocols}
        for e in self.evidence:
            if e.source_id not in src:
                raise ValueError(f"evidencia huérfana {e.id} -> {e.source_id}")
        for m in self.materials:
            for c in m.compositions:
                if c.evidence_id not in ev:
                    raise ValueError(f"composición de {m.id} sin evidencia existente")
        for c in self.initial_conditions:
            if c.material_id not in mats:
                raise ValueError(f"condición {c.id} con material inexistente")
        pairs = set()
        for mt in self.material_treatments:
            key = (mt.material_id, mt.treatment_id)
            if key in pairs:
                raise ValueError(f"pareja duplicada {key}")
            pairs.add(key)
            for eid in (mt.temperature_evidence_id, mt.hold_evidence_id):
                if eid and eid not in ev:
                    raise ValueError(f"pareja {key}: evidencia inexistente {eid}")
            if mt.protocol_id and mt.protocol_id not in prots:
                raise ValueError(f"pareja {key}: protocolo inexistente")
        for p in self.protocols:
            for s in p.stages:
                for eid in (s.end_temperature_evidence_id, s.duration_evidence_id):
                    if eid and eid not in ev:
                        raise ValueError(f"protocolo {p.id}: evidencia inexistente {eid}")
        for g in self.physical_guards:
            if g.evidence_id not in ev:
                raise ValueError(f"guardia {g.id}: evidencia inexistente")
        for mg in self.micrographs:
            if mg.source_id not in src:
                raise ValueError(f"micrografía {mg.id}: fuente inexistente")
        for mv in self.model_versions:
            for eid in mv.parameter_evidence_ids.values():
                if eid not in ev:
                    raise ValueError(f"modelo {mv.id}: evidencia inexistente {eid}")
        del ics
        return self

    # ---------------------------------------------------------- utilidades
    def canonical_json(self) -> str:
        return json.dumps(self.model_dump(mode="json"), sort_keys=True, separators=(",", ":"), ensure_ascii=False)

    def checksum(self) -> str:
        return hashlib.sha256(self.canonical_json().encode("utf-8")).hexdigest()

    def material(self, mid: str) -> Material | None:
        return next((m for m in self.materials if m.id == mid), None)

    def treatment(self, tid: str) -> Treatment | None:
        return next((t for t in self.treatments if t.id == tid), None)

    def pair(self, mid: str, tid: str) -> MaterialTreatment | None:
        return next(
            (p for p in self.material_treatments if p.material_id == mid and p.treatment_id == tid),
            None,
        )

    def protocol(self, pid: str | None) -> Protocol | None:
        return next((p for p in self.protocols if p.id == pid), None) if pid else None

    def conditions_for(self, mid: str) -> list[InitialCondition]:
        return [c for c in self.initial_conditions if c.material_id == mid]

    def evidence_by_id(self, eid: str | None) -> EvidenceRecord | None:
        return next((e for e in self.evidence if e.id == eid), None) if eid else None

    def source(self, sid: str | None) -> Source | None:
        return next((s for s in self.sources if s.id == sid), None) if sid else None


Treatment.model_rebuild()
