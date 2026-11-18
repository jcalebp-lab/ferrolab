"""Vocabulario canónico de FERROLAB (README §4, doc 15 §F).

Fuente única de verdad: el cliente Flutter recibe estos valores generados en
`packages/contracts/enums.json` mediante `scripts/gen_contracts.py`.
"""

from enum import StrEnum


class MaterialId(StrEnum):
    AISI_1045 = "aisi_1045"
    AISI_8620 = "aisi_8620"
    ASTM_A48_CLASS_30 = "astm_a48_class_30"


class TreatmentId(StrEnum):
    QUENCH = "quench"
    TEMPER = "temper"
    ANNEAL = "anneal"
    NORMALIZE = "normalize"
    AUSTEMPER = "austemper"
    MARTEMPER = "martemper"


class MaterialFamily(StrEnum):
    STEEL = "steel"
    GRAY_CAST_IRON = "gray_cast_iron"


class CompatibilityStatus(StrEnum):
    SUPPORTED = "supported"
    CONDITIONAL = "conditional"
    EDUCATIONAL_ONLY = "educational_only"
    UNSUPPORTED = "unsupported"


class SimulationStatus(StrEnum):
    COMPLETED = "completed"
    PARTIAL_RESULT = "partial_result"
    INSUFFICIENT_EVIDENCE = "insufficient_evidence"
    UNSUPPORTED = "unsupported"
    INVALID_INPUT = "invalid_input"
    INTERNAL_ERROR = "internal_error"


class EvidenceKind(StrEnum):
    MEASURED = "measured"
    LITERATURE = "literature"
    MODELED = "modeled"
    ILLUSTRATIVE = "illustrative"
    UNAVAILABLE = "unavailable"


class EvidenceLevel(StrEnum):
    VALIDATED = "validated"
    BOUNDED_ESTIMATE = "bounded_estimate"
    QUALITATIVE = "qualitative"
    INSUFFICIENT_EVIDENCE = "insufficient_evidence"
    UNSUPPORTED = "unsupported"


class ReviewStatus(StrEnum):
    DRAFT = "draft"
    REVIEWED = "reviewed"
    PUBLISHED = "published"
    RETIRED = "retired"


class StageKind(StrEnum):
    HEAT = "heat"
    HOLD = "hold"
    TRANSFER = "transfer"
    COOL = "cool"
    ISOTHERMAL_HOLD = "isothermal_hold"


class SchematicLevel(StrEnum):
    """Nivel cualitativo de una etapa en el ciclo esquemático (sin cifra)."""

    AMBIENT = "ambient"
    TARGET = "target"
    BATH = "bath"


class QuantityCode(StrEnum):
    PHASE_FRACTIONS = "phase_fractions"
    MICROCONSTITUENT_FRACTIONS = "microconstituent_fractions"
    HARDNESS = "hardness"
    GRAIN_SIZE = "grain_size"
    MECHANICAL_PROPERTIES = "mechanical_properties"


class MatchQuality(StrEnum):
    EXACT = "exact"
    COMPARABLE = "comparable"
    ILLUSTRATIVE = "illustrative"
    NONE = "none"


class AdminRole(StrEnum):
    EDITOR = "editor"
    REVIEWER = "reviewer"
    ADMIN = "admin"


ALL_ENUMS: dict[str, type[StrEnum]] = {
    "material_id": MaterialId,
    "treatment_id": TreatmentId,
    "material_family": MaterialFamily,
    "compatibility_status": CompatibilityStatus,
    "simulation_status": SimulationStatus,
    "evidence_kind": EvidenceKind,
    "evidence_level": EvidenceLevel,
    "review_status": ReviewStatus,
    "stage_kind": StageKind,
    "schematic_level": SchematicLevel,
    "quantity_code": QuantityCode,
    "match_quality": MatchQuality,
    "admin_role": AdminRole,
}
