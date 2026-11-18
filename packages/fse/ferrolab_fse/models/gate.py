from __future__ import annotations

from ..snapshot import ModelVersion


class ModelNotActivated(RuntimeError):
    """El modelo no cumple GATE-C2: no se calcula nada."""

    def __init__(self, model_code: str, reason: str) -> None:
        super().__init__(f"{model_code}: {reason}")
        self.model_code = model_code
        self.reason = reason


def require_active(mv: ModelVersion | None, model_code: str) -> ModelVersion:
    if mv is None:
        raise ModelNotActivated(model_code, "no existe una versión del modelo en el snapshot")
    if mv.model_code != model_code:
        raise ModelNotActivated(model_code, "versión de otro modelo")
    if not mv.activatable:
        raise ModelNotActivated(
            model_code,
            "requiere aprobación, fuente, evidencia por parámetro y al menos un golden case",
        )
    return mv
