"""Dureza por constituyente de Maynier et al. (1978) y conversión HV→HRC (COMSOL «Hardness»)."""

from __future__ import annotations

import math

from .data import HRC_COEFFS, MAYNIER


def _lin(base: tuple[float, dict[str, float]], c: dict[str, float]) -> float:
    k0, terms = base
    return k0 + sum(v * float(c.get(el, 0.0)) for el, v in terms.items())


def constituent_hv(c: dict[str, float], vr_k_per_h: float) -> dict[str, float]:
    """HV de martensita, bainita y ferrita-perlita para la velocidad Vr (K/h) a 700 °C."""
    lg = math.log10(max(vr_k_per_h, 1.0))
    return {name: _lin(a, c) + _lin(b, c) * lg for name, (a, b) in MAYNIER.items()}


def mixture_hv(fractions: dict[str, float], c: dict[str, float], vr_k_per_h: float) -> float:
    """Regla de mezclas. La austenita retenida (pocas %) se excluye y se renormaliza (supuesto declarado)."""
    hv = constituent_hv(c, vr_k_per_h)
    fm = fractions.get("martensite", 0.0)
    fb = fractions.get("bainite", 0.0)
    ffp = fractions.get("proeutectoid_ferrite", 0.0) + fractions.get("pearlite", 0.0)
    total = fm + fb + ffp
    if total <= 0:
        raise ValueError("sin constituyentes")
    return (fm * hv["martensite"] + fb * hv["bainite"] + ffp * hv["ferrite_pearlite"]) / total


def hv_to_hrc(hv: float) -> float | None:
    """Válida para aceros no austeníticos; None por debajo de 20 HRC (fuera de la escala C)."""
    a, b, c2, d = HRC_COEFFS
    hrc = a + b * hv + c2 * hv * hv + d / hv
    return hrc if hrc >= 20 else None
