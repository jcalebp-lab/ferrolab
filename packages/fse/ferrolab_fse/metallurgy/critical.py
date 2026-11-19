"""Temperaturas críticas a partir de la composición (wt %, resultado en °C)."""

from __future__ import annotations

import math
from dataclasses import dataclass

from .data import C_EUTECTOID, C_FERRITE_MAX


def _g(c: dict[str, float], el: str) -> float:
    return float(c.get(el, 0.0))


def ac1_andrews(c: dict[str, float]) -> float:
    # Andrews (1965): Ac1 = 723 − 10.7Mn − 16.9Ni + 29.1Si + 16.9Cr + 290As + 6.38W (sin término de Mo)
    return 723 - 10.7 * _g(c, "Mn") - 16.9 * _g(c, "Ni") + 29.1 * _g(c, "Si") + 16.9 * _g(c, "Cr") \
        + 290 * _g(c, "As") + 6.38 * _g(c, "W")


def ac3_andrews(c: dict[str, float]) -> float:
    # Andrews (1965): Ac3 = 910 − 203√C − 15.2Ni + 44.7Si + 104V + 31.5Mo + 13.1W − 30Mn − 11Cr − 20Cu
    #                       + 700P + 400Al + 120As + 400Ti
    return (910 - 203 * math.sqrt(_g(c, "C")) - 15.2 * _g(c, "Ni") + 44.7 * _g(c, "Si") + 104 * _g(c, "V")
            + 31.5 * _g(c, "Mo") + 13.1 * _g(c, "W") - 30 * _g(c, "Mn") - 11 * _g(c, "Cr") - 20 * _g(c, "Cu")
            + 700 * _g(c, "P") + 400 * _g(c, "Al") + 120 * _g(c, "As") + 400 * _g(c, "Ti"))


def ms_andrews(c: dict[str, float]) -> float:
    # Andrews lineal (Cambridge MAP Ref. 1): 539 − 423C − 30.39Mn − 12.14Cr − 17.69Ni − 7.46Mo
    return 539.0 - 423.0 * _g(c, "C") - 30.39 * _g(c, "Mn") - 12.14 * _g(c, "Cr") - 17.69 * _g(c, "Ni") \
        - 7.46 * _g(c, "Mo")


def bs_steven_haynes(c: dict[str, float]) -> float:
    # Steven & Haynes (1956): Bs = 830 − 270C − 90Mn − 37Ni − 70Cr − 83Mo
    return 830 - 270 * _g(c, "C") - 90 * _g(c, "Mn") - 37 * _g(c, "Ni") - 70 * _g(c, "Cr") - 83 * _g(c, "Mo")


def ferrite_equilibrium_fraction(c: dict[str, float]) -> float:
    """Regla de la palanca en el eutectoide (aceros hipoeutectoides)."""
    carbon = _g(c, "C")
    if carbon >= C_EUTECTOID:
        return 0.0
    return max(0.0, min(1.0, (C_EUTECTOID - carbon) / (C_EUTECTOID - C_FERRITE_MAX)))


@dataclass(frozen=True)
class Critical:
    ac1: float
    ac3: float
    ms: float
    mf_approx: float
    bs: float
    xf_eq: float

    def as_dict(self) -> dict[str, float]:
        return {"ac1_c": round(self.ac1, 1), "ac3_c": round(self.ac3, 1), "ms_c": round(self.ms, 1),
                "mf_c": round(self.mf_approx, 1), "bs_c": round(self.bs, 1),
                "ferrite_eq_fraction": round(self.xf_eq, 4)}


def critical_temperatures(c: dict[str, float]) -> Critical:
    ms = ms_andrews(c)
    return Critical(ac1=ac1_andrews(c), ac3=ac3_andrews(c), ms=ms, mf_approx=ms - 215.0,
                    bs=bs_steven_haynes(c), xf_eq=ferrite_equilibrium_fraction(c))


def austenite_fraction_on_heating(t_c: float, cr: Critical) -> float:
    """Fracción austenizada a la temperatura de mantenimiento (interpolación lineal Ac1→Ac3; supuesto)."""
    if t_c <= cr.ac1:
        return 0.0
    if t_c >= cr.ac3:
        return 1.0
    return (t_c - cr.ac1) / (cr.ac3 - cr.ac1)
