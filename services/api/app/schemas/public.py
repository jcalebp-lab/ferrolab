"""Contrato público de entrada (doc 06 §16.5). Campos extra => 422."""

from __future__ import annotations

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

MaterialCode = Literal["aisi_1045", "aisi_8620", "en_gjl_250"]
TreatmentCode = Literal["quench", "temper", "anneal", "normalize", "austemper", "martemper", "quench_temper"]
Locale = Literal["es", "en"]


class SimulationCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")
    material_id: MaterialCode
    treatment_id: TreatmentCode
    initial_condition_id: str | None = Field(default=None, max_length=80, pattern=r"^[a-z0-9_]+$")
    # Validación ESTRUCTURAL de interfaz; el dominio científico lo valida el FSE.
    target_temperature_c: float = Field(ge=0, le=1600, allow_inf_nan=False)
    hold_time_min: float = Field(ge=0, le=1440, allow_inf_nan=False)
    # Biblioteca de protocolos (D-30): variante elegida y parámetros del baño (independientes del horno).
    protocol_id: str | None = Field(default=None, max_length=80, pattern=r"^[a-z0-9_]+$")
    bath_temperature_c: float | None = Field(default=None, ge=0, le=1600, allow_inf_nan=False)
    bath_time_min: float | None = Field(default=None, ge=0, le=1440, allow_inf_nan=False)
    # Revenido: origen del estado templado de partida.
    prior_mode: Literal["reference", "history", "theory"] = "reference"
    prior_protocol_id: str | None = Field(default=None, max_length=80, pattern=r"^[a-z0-9_]+$")
    prior_temperature_c: float | None = Field(default=None, ge=0, le=1600, allow_inf_nan=False)
    prior_hold_min: float | None = Field(default=None, ge=0, le=1440, allow_inf_nan=False)
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
