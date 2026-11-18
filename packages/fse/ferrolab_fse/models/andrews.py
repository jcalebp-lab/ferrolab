"""Andrews (1965) para Ms: SOLO interfaz (doc 04 §13.5).

No se codifican coeficientes de memoria. Cuando un editor registre la
formulación y sus coeficientes desde la referencia primaria, vivirán en
`ModelVersion.parameters` (un coeficiente por elemento) y se evaluará aquí.
"""

from __future__ import annotations

from ..snapshot import ModelVersion
from .gate import require_active

MODEL_CODE = "andrews_ms"


def estimate_ms(mv: ModelVersion | None, composition_wt_pct: dict[str, float]) -> float:
    model = require_active(mv, MODEL_CODE)
    params = dict(model.parameters)
    intercept = params.pop("intercept_c")
    domain = model.validity.get("composition_wt_pct", {})
    for el, value in composition_wt_pct.items():
        rng = domain.get(el)
        if rng is None or not (rng[0] <= value <= rng[1]):
            raise ValueError(f"{el} fuera del dominio de la formulación: no se extrapola")
    missing = [el for el in params if el not in composition_wt_pct]
    if missing:
        raise ValueError(f"composición incompleta para la formulación: {missing}")
    return intercept + sum(coef * composition_wt_pct[el] for el, coef in params.items())
