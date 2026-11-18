"""JMAK/Avrami: X(t) = 1 - exp(-k t^n), solo ISOTÉRMICO (doc 04 §13.5).

k y n deben estar medidos/ajustados para material, fase y temperatura. No se
usa para enfriamiento continuo (CCT).
"""

from __future__ import annotations

import math

from ..snapshot import ModelVersion
from .gate import require_active

MODEL_CODE = "jmak"


def jmak_fraction(t_s: float, k: float, n: float) -> float:
    if t_s < 0 or k <= 0 or n <= 0 or not all(math.isfinite(v) for v in (t_s, k, n)):
        raise ValueError("argumentos inválidos")
    return 1.0 - math.exp(-k * t_s**n)


def evaluate_isothermal(mv: ModelVersion | None, t_s: float, *, isothermal: bool) -> float:
    model = require_active(mv, MODEL_CODE)
    if not isothermal:
        raise ValueError("JMAK solo para trayectorias isotérmicas; no se aplica a CCT")
    return jmak_fraction(t_s, model.parameters["k"], model.parameters["n"])
