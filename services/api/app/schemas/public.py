"""Contrato público de entrada (doc 06 §16.5). Campos extra => 422."""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

MaterialCode = Literal["aisi_1045", "aisi_8620", "astm_a48_class_30"]
TreatmentCode = Literal["quench", "temper", "anneal", "normalize", "austemper", "martemper"]
Locale = Literal["es", "en"]


class SimulationCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")
    material_id: MaterialCode
    treatment_id: TreatmentCode
    initial_condition_id: str | None = Field(default=None, max_length=80, pattern=r"^[a-z0-9_]+$")
    # Validación ESTRUCTURAL de interfaz; el dominio científico lo valida el FSE.
    target_temperature_c: float = Field(ge=0, le=1600, allow_inf_nan=False)
    hold_time_min: float = Field(ge=0, le=1440, allow_inf_nan=False)
    locale: Locale = "es"


class TutorExplain(BaseModel):
    model_config = ConfigDict(extra="forbid")
    simulation: SimulationCreate
    locale: Locale = "es"


class TutorAsk(BaseModel):
    model_config = ConfigDict(extra="forbid")
    question: str = Field(min_length=1, max_length=500)
    simulation: SimulationCreate | None = None
    locale: Locale = "es"
