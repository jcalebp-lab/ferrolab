"""Historial térmico (doc 04 §5.3 y §13.3).

Dos representaciones claramente separadas:

* `ThermalHistory` (física): solo existe si TODAS las cifras del protocolo
  tienen evidencia. Tiempos en segundos, °C, tramos lineales etiquetados.
* `SchematicCycle` (didáctica): secuencia de etapas sin escala de tiempo; solo
  lleva las cifras que introdujo el estudiante (temperatura objetivo y tiempo
  de mantenimiento). Nunca se presenta como trayectoria medida.
"""

from __future__ import annotations

import math
from dataclasses import dataclass

from pydantic import BaseModel, ConfigDict

from .enums import SchematicLevel, StageKind
from .snapshot import Protocol, ProtocolStage, StageTemplate


class ThermalHistoryError(ValueError):
    pass


@dataclass(frozen=True)
class ThermalStage:
    kind: StageKind
    label_key: str
    t_start_s: float
    t_end_s: float
    start_temperature_c: float
    end_temperature_c: float
    profile_kind: str
    evidence_ids: tuple[str, ...]


class ThermalPoint(BaseModel):
    model_config = ConfigDict(frozen=True)
    t_s: float
    temperature_c: float
    stage_index: int


class ThermalStageOut(BaseModel):
    model_config = ConfigDict(frozen=True)
    index: int
    kind: StageKind
    label_key: str
    t_start_s: float
    t_end_s: float
    start_temperature_c: float
    end_temperature_c: float
    profile_kind: str
    evidence_ids: list[str]


class ThermalHistory(BaseModel):
    model_config = ConfigDict(frozen=True)
    stages: list[ThermalStageOut]
    points: list[ThermalPoint]
    total_time_s: float
    time_basis: str = "physical_seconds"


def validate_stages(stages: list[ThermalStage]) -> None:
    """Invariantes SCI-10: orden, continuidad, duraciones positivas, valores finitos."""
    if not stages:
        raise ThermalHistoryError("historial vacío")
    prev: ThermalStage | None = None
    for s in stages:
        vals = (s.t_start_s, s.t_end_s, s.start_temperature_c, s.end_temperature_c)
        if not all(math.isfinite(v) for v in vals):
            raise ThermalHistoryError("valores no finitos en el historial")
        if not s.t_end_s > s.t_start_s:
            raise ThermalHistoryError(f"etapa {s.label_key}: t_end_s debe ser > t_start_s")
        if s.kind in (StageKind.HOLD, StageKind.ISOTHERMAL_HOLD) and s.start_temperature_c != s.end_temperature_c:
            raise ThermalHistoryError(f"meseta {s.label_key} con cambio de temperatura")
        if s.kind == StageKind.HEAT and s.end_temperature_c < s.start_temperature_c:
            raise ThermalHistoryError(f"calentamiento {s.label_key} que enfría")
        if s.kind == StageKind.COOL and s.end_temperature_c > s.start_temperature_c:
            raise ThermalHistoryError(f"enfriamiento {s.label_key} que calienta")
        if prev is not None:
            if s.t_start_s != prev.t_end_s:
                raise ThermalHistoryError("discontinuidad temporal entre etapas")
            if s.start_temperature_c != prev.end_temperature_c:
                raise ThermalHistoryError("salto térmico implícito entre etapas")
        prev = s


def build_physical_history(
    protocol: Protocol,
    *,
    target_temperature_c: float,
    hold_s: float,
    ambient_c: float,
) -> ThermalHistory | None:
    """Construye el historial físico o devuelve None si falta alguna cifra publicada."""
    if not protocol.is_fully_specified:
        return None
    stages: list[ThermalStage] = []
    t = 0.0
    temp = ambient_c
    for ps in protocol.stages:
        end_temp = _resolve_end_temp(ps, temp, target_temperature_c, ambient_c)
        if ps.duration_mode == "user_hold":
            duration = hold_s
            if duration == 0:
                continue  # meseta omitida (advertencia HOLD_ZERO en el motor)
        elif ps.duration_mode == "value":
            duration = float(ps.duration_s or 0)
        else:  # rate
            delta = abs(end_temp - temp)
            if delta == 0:
                continue
            duration = delta / float(ps.rate_c_per_s or 1)
        evid = tuple(e for e in (ps.end_temperature_evidence_id, ps.duration_evidence_id) if e)
        stages.append(
            ThermalStage(
                kind=ps.kind,
                label_key=ps.label_key,
                t_start_s=t,
                t_end_s=t + duration,
                start_temperature_c=temp,
                end_temperature_c=end_temp,
                profile_kind="linear_illustrative",
                evidence_ids=evid,
            )
        )
        t += duration
        temp = end_temp
    validate_stages(stages)
    out = [
        ThermalStageOut(index=i, evidence_ids=list(s.evidence_ids), **{
            k: getattr(s, k)
            for k in ("kind", "label_key", "t_start_s", "t_end_s", "start_temperature_c", "end_temperature_c", "profile_kind")
        })
        for i, s in enumerate(stages)
    ]
    points = [ThermalPoint(t_s=stages[0].t_start_s, temperature_c=stages[0].start_temperature_c, stage_index=0)]
    points += [ThermalPoint(t_s=s.t_end_s, temperature_c=s.end_temperature_c, stage_index=i) for i, s in enumerate(stages)]
    return ThermalHistory(stages=out, points=points, total_time_s=t)


def _resolve_end_temp(ps: ProtocolStage, current: float, target: float, ambient: float) -> float:
    if ps.end_temperature_mode == "user_target":
        return target
    if ps.end_temperature_mode == "ambient":
        return ambient
    if ps.end_temperature_mode == "value":
        return float(ps.end_temperature_c)  # type: ignore[arg-type]
    raise ThermalHistoryError("temperatura no publicada")  # pragma: no cover


# ----------------------------------------------------------------- esquema
class SchematicSegment(BaseModel):
    model_config = ConfigDict(frozen=True)
    index: int
    kind: StageKind
    label_key: str
    end_level: SchematicLevel
    # Solo cifras introducidas por el estudiante; el resto es null.
    end_temperature_c: float | None
    duration_s: float | None
    duration_basis: str  # "user_input" | "not_published"
    is_user_hold: bool


class SchematicCycle(BaseModel):
    model_config = ConfigDict(frozen=True)
    time_basis: str = "schematic_not_to_scale"
    segments: list[SchematicSegment]


def build_schematic_cycle(
    templates: list[StageTemplate] | list[ProtocolStage],
    *,
    target_temperature_c: float,
    hold_s: float,
) -> SchematicCycle:
    segs: list[SchematicSegment] = []
    for tpl in templates:
        user_hold = tpl.user_hold if isinstance(tpl, StageTemplate) else tpl.duration_mode == "user_hold"
        if user_hold and hold_s == 0:
            continue
        segs.append(
            SchematicSegment(
                index=len(segs),
                kind=tpl.kind,
                label_key=tpl.label_key,
                end_level=tpl.end_level,
                end_temperature_c=target_temperature_c if tpl.end_level == SchematicLevel.TARGET else None,
                duration_s=hold_s if user_hold else None,
                duration_basis="user_input" if user_hold else "not_published",
                is_user_hold=user_hold,
            )
        )
    return SchematicCycle(segments=segs)
