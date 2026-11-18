"""Koistinen–Marburger (1959), forma simbólica de doc 04 §13.5:

    f = 1 - exp[-alpha (Ms - T)]   para T < Ms

`f` es la fracción de la austenita *transformable* según la versión del modelo,
NO la fracción de martensita de todo el material. No hay `alpha` ni `Ms` por
defecto: deben venir de un `ModelVersion` activable.
"""

from __future__ import annotations

import math

from ..snapshot import ModelVersion
from .gate import require_active

MODEL_CODE = "koistinen_marburger"


def km_transformed_fraction(ms_c: float, temperature_c: float, alpha_per_c: float) -> float:
    """Álgebra pura (sin datos). Devuelve 0 por encima de Ms."""
    for v in (ms_c, temperature_c, alpha_per_c):
        if not math.isfinite(v):
            raise ValueError("argumentos no finitos")
    if alpha_per_c <= 0:
        raise ValueError("alpha debe ser > 0")
    if temperature_c >= ms_c:
        return 0.0
    f = 1.0 - math.exp(-alpha_per_c * (ms_c - temperature_c))
    return min(max(f, 0.0), 1.0)


def evaluate(mv: ModelVersion | None, temperature_c: float) -> float:
    model = require_active(mv, MODEL_CODE)
    t_min = model.validity.get("temperature_min_c")
    t_max = model.validity.get("temperature_max_c")
    if (t_min is not None and temperature_c < t_min) or (t_max is not None and temperature_c > t_max):
        raise ValueError("temperatura fuera del dominio de validez del modelo: no se extrapola")
    return km_transformed_fraction(model.parameters["ms_c"], temperature_c, model.parameters["alpha_per_c"])
