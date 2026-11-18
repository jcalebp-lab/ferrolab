"""Contrato de resultado del FSE (doc 04 §4, doc 06 §16.4).

Regla GATE-C1: un `ResultFact` con valor numérico sin unidad, método, fuente y
versión es rechazado en construcción. Los campos ausentes son `null`, nunca 0.
"""

from __future__ import annotations

import math
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field, model_validator

from .enums import CompatibilityStatus, EvidenceKind, EvidenceLevel, QuantityCode, SimulationStatus
from .thermal import SchematicCycle, ThermalPoint, ThermalStageOut

PHASE_KEYS = {"ferrite", "austenite", "cementite", "graphite", "martensite"}
MICROCONSTITUENT_KEYS = {
    "pearlite",
    "bainite",
    "martensite",
    "proeutectoid_ferrite",
    "proeutectoid_cementite",
    "retained_austenite",
    "graphite_flakes",
}


class ResultFact(BaseModel):
    model_config = ConfigDict(frozen=True, extra="forbid")
    value: float
    unit: str
    scale: str | None = None
    fraction_basis: str | None = None
    method: str
    evidence_kind: EvidenceKind
    evidence_level: EvidenceLevel
    source_ids: list[str]
    evidence_ids: list[str] = Field(default_factory=list)
    model_version: str | None = None
    dataset_version: str
    validity: dict[str, Any] = Field(default_factory=dict)
    uncertainty: dict[str, Any] | None = None

    @model_validator(mode="after")
    def _gate_c1(self) -> ResultFact:
        if not math.isfinite(self.value):
            raise ValueError("valor no finito")
        if not self.unit or not self.method or not self.source_ids:
            raise ValueError("GATE-C1: cifra sin unidad, método o fuente")
        if self.evidence_kind in (EvidenceKind.ILLUSTRATIVE, EvidenceKind.UNAVAILABLE):
            raise ValueError("una ilustración no puede emitir una cifra de resultado")
        if self.evidence_kind == EvidenceKind.MODELED and not self.model_version:
            raise ValueError("cifra modelada sin model_version")
        if self.unit == "fraction" and not (0.0 <= self.value <= 1.0):
            raise ValueError("fracción fuera de [0, 1]")
        return self


class Results(BaseModel):
    model_config = ConfigDict(frozen=True, extra="forbid")
    phase_fractions: dict[str, ResultFact] | None = None
    microconstituent_fractions: dict[str, ResultFact] | None = None
    hardness: ResultFact | None = None
    grain_size: ResultFact | None = None
    mechanical_properties: dict[str, ResultFact] | None = None

    @model_validator(mode="after")
    def _gate_c5(self) -> Results:
        for name, group, allowed in (
            ("phase_fractions", self.phase_fractions, PHASE_KEYS),
            ("microconstituent_fractions", self.microconstituent_fractions, MICROCONSTITUENT_KEYS),
        ):
            if not group:
                continue
            bad = set(group) - allowed
            if bad:
                raise ValueError(f"GATE-C5: {sorted(bad)} no pertenece a {name}")
            bases = {f.fraction_basis for f in group.values()}
            if len(bases) != 1 or None in bases:
                raise ValueError(f"{name}: todas las fracciones requieren la misma base declarada")
            if sum(f.value for f in group.values()) > 1.0 + 1e-9:
                raise ValueError(f"{name}: la suma supera 1")
        return self


class QuantityStatus(BaseModel):
    model_config = ConfigDict(frozen=True)
    evidence_level: EvidenceLevel
    reason_code: str
    reason: str


class Warning(BaseModel):
    model_config = ConfigDict(frozen=True)
    code: str
    severity: Literal["blocking", "limitation", "info"]
    message_key: str
    message: str
    params: dict[str, Any] = Field(default_factory=dict)
    field: str | None = None


class Assumption(BaseModel):
    model_config = ConfigDict(frozen=True)
    code: str
    text: str


class EvidenceRef(BaseModel):
    model_config = ConfigDict(frozen=True)
    source_id: str
    title: str
    authors: str | None
    year: int | None
    edition: str | None
    doi: str | None
    url: str | None
    kind: str
    verification_status: str
    usage: Literal["supports_value", "supports_limit", "suggested_reading"]
    evidence_id: str | None = None
    locator: str | None = None


class ProtocolStageOut(BaseModel):
    model_config = ConfigDict(frozen=True)
    ordinal: int
    kind: str
    label_key: str
    label: str
    end_temperature_c: float | None
    end_temperature_basis: str
    duration_s: float | None
    duration_basis: str


class ProtocolOut(BaseModel):
    model_config = ConfigDict(frozen=True)
    id: str
    version: str
    review_status: str
    medium: str
    medium_documented: bool
    variant: str | None
    fully_specified: bool
    user_hold_stage_label: str | None
    stages: list[ProtocolStageOut]


class Explanation(BaseModel):
    model_config = ConfigDict(frozen=True)
    mode: Literal["editorial"] = "editorial"
    review_status: str
    treatment_purpose: str
    prerequisites: str
    qualitative_outcome: str
    material_description: str
    material_limitations: list[str]
    compatibility_reason: str


class MaterialRef(BaseModel):
    model_config = ConfigDict(frozen=True)
    id: str
    display_name: str
    family: str


class InitialConditionOut(BaseModel):
    model_config = ConfigDict(frozen=True)
    id: str
    name: str
    description: str
    hardened: bool | None
    carburized: bool | None
    review_status: str


class SimulationInputEcho(BaseModel):
    model_config = ConfigDict(frozen=True)
    material_id: str
    treatment_id: str
    initial_condition_id: str | None
    target_temperature_c: float
    hold_time_min: float


class SimulationResult(BaseModel):
    """Envelope canónico. Campos extra (documentados en docs/DECISIONS.md):
    `request_hash`, `schematic_cycle`, `result_status`, `explanation`,
    `material`, `initial_condition`, `dataset_contains_unreviewed_content`."""

    model_config = ConfigDict(frozen=True)
    request_id: str | None = None
    request_hash: str
    simulation_status: SimulationStatus
    dataset_version: str
    dataset_contains_unreviewed_content: bool
    protocol_version: str | None
    engine_version: str
    model_version: str | None
    input: SimulationInputEcho
    compatibility_status: CompatibilityStatus | None
    material: MaterialRef
    initial_condition: InitialConditionOut | None
    protocol: ProtocolOut | None
    thermal_history: list[ThermalPoint]
    thermal_stages: list[ThermalStageOut]
    schematic_cycle: SchematicCycle | None
    results: Results
    result_status: dict[QuantityCode, QuantityStatus]
    micrograph: dict[str, Any] | None = None
    diagrams: list[dict[str, Any]] = Field(default_factory=list)
    warnings: list[Warning]
    evidence: list[EvidenceRef]
    assumptions: list[Assumption]
    explanation: Explanation

    def scientific_content(self) -> dict[str, Any]:
        """Contenido científico para comparar determinismo (sin request_id)."""
        d = self.model_dump(mode="json")
        d.pop("request_id", None)
        return d
