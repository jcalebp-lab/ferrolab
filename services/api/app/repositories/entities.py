"""Registro de entidades editables desde el panel admin.

Cada entidad se valida con el modelo Pydantic del FSE antes de escribirse, de
modo que la base de datos y el motor comparten un único contrato.
"""

from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass
from typing import Any

from ferrolab_fse import snapshot as S
from pydantic import BaseModel


@dataclass(frozen=True)
class Entity:
    name: str  # segmento de URL
    table: str
    model: type[BaseModel]
    snapshot_key: str
    key_fields: tuple[str, ...]
    columns: Callable[[BaseModel], dict[str, Any]]

    def key_of(self, obj: BaseModel) -> str:
        return ":".join(str(getattr(obj, f)) for f in self.key_fields)

    def key_filter(self, key: str) -> dict[str, str]:
        parts = key.split(":")
        if len(parts) != len(self.key_fields):
            raise KeyError(key)
        return dict(zip(self.key_fields, parts, strict=True))


def _c(*names: str) -> Callable[[BaseModel], dict[str, Any]]:
    def f(m: BaseModel) -> dict[str, Any]:
        out = {}
        for n in names:
            v = getattr(m, n)
            out[n] = v.value if hasattr(v, "value") else v
        return out

    return f


ENTITIES: dict[str, Entity] = {
    e.name: e
    for e in [
        Entity("sources", "sources", S.Source, "sources", ("id",), _c("id", "kind", "title", "verification_status", "license_code")),
        Entity("evidence", "scientific_evidence", S.EvidenceRecord, "evidence", ("id",),
               _c("id", "source_id", "material_id", "treatment_id", "quantity_code", "evidence_kind", "locator", "value", "unit")),
        Entity("materials", "materials", S.Material, "materials", ("id",), _c("id", "family", "display_name")),
        Entity("treatments", "treatments", S.Treatment, "treatments", ("id",), _c("id", "name_es", "name_en")),
        Entity("initial-conditions", "initial_conditions", S.InitialCondition, "initial_conditions", ("id",),
               _c("id", "material_id", "source_id", "hardened", "carburized")),
        Entity("protocols", "protocols", S.Protocol, "protocols", ("id",), _c("id", "material_id", "treatment_id", "version")),
        Entity("material-treatments", "material_treatments", S.MaterialTreatment, "material_treatments",
               ("material_id", "treatment_id"),
               _c("material_id", "treatment_id", "compatibility_status", "quantitative_outputs_enabled", "protocol_id",
                  "temperature_min_c", "temperature_max_c", "temperature_evidence_id", "hold_min_s", "hold_max_s",
                  "hold_evidence_id")),
        Entity("physical-guards", "physical_guards", S.PhysicalGuard, "physical_guards", ("id",),
               _c("id", "applies_to_family", "max_temperature_c", "evidence_id")),
        Entity("model-versions", "model_versions", S.ModelVersion, "model_versions", ("id",),
               _c("id", "model_code", "version", "approved", "source_id")),
        Entity("micrographs", "micrographs", S.Micrograph, "micrographs", ("id",),
               _c("id", "material_id", "treatment_id", "source_id", "license_code", "license_verified", "magnification_x",
                  "scale_bar_um", "match_quality")),
        Entity("knowledge", "knowledge_entries", S.KnowledgeEntry, "knowledge", ("slug",), _c("slug", "category")),
        Entity("practice-questions", "practice_questions", S.PracticeQuestion, "practice_questions", ("id",), _c("id")),
    ]
}

# Orden de inserción que respeta las claves foráneas.
INSERT_ORDER = [
    "sources", "materials", "treatments", "evidence", "initial-conditions", "protocols", "material-treatments",
    "physical-guards", "model-versions", "micrographs", "knowledge", "practice-questions",
]
