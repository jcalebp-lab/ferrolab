"""Tamaño de grano: crecimiento del grano austenítico, número ASTM y grano ferrítico.

Modelos PUBLICADOS (ver data.SOURCES y docs/FUENTES_MODELOS.md):

* Lee & Lee (2008) Mater. Des. 29:1840 — grano austenítico de aceros de baja aleación:
      d = 76671 · exp(−(89098 + 3581·C + 1211·Ni + 1443·Cr + 4031·Mo) / (R·T)) · t^0.211
  d en µm, T en K, t en s, R = 8.314 J/(mol·K), composición en % en masa. Ajustado con 16 aceros
  austenizados a 850–1200 °C durante hasta 3 h. Coeficientes según la reproducción de A. A. Gorni,
  «Steel Forming and Heat Treating Handbook» (el artículo original no se pudo consultar).
  Para ciclos no isotérmicos se aplica la regla de aditividad: d^(1/n) = A^(1/n)·Σ exp(−Q/(n·R·T))·Δt.
* ASTM E112 — número de tamaño de grano a partir del intercepto lineal medio ℓ̄ (mm):
      G = −6.643856·log10(ℓ̄) − 3.288
* Hodgson & Gibbs (1992) ISIJ Int. 32:1329 — grano ferrítico tras enfriamiento continuo, Ceq < 0.35,
  sin deformación retenida:  dα = (−0.4 + 6.37·Ceq) + (24.2 − 59·Ceq)·Ṫ^−0.5 + 22·(1 − exp(−0.015·dγ)),
  Ceq = C + Mn/6, Ṫ en K/s, dγ y dα en µm. Desarrollado para aceros C–Mn.
"""

from __future__ import annotations

import math

R = 8.314
LEE_A = 76671.0
LEE_Q0 = 89098.0
LEE_Q = {"C": 3581.0, "Ni": 1211.0, "Cr": 1443.0, "Mo": 4031.0}
LEE_N = 0.211
LEE_T_RANGE_C = (850.0, 1200.0)
LEE_T_MAX_S = 3 * 3600.0
ASTM_A, ASTM_B = -6.643856, -3.288
HG_CEQ_MAX = 0.35


def lee_activation(c: dict[str, float]) -> float:
    return LEE_Q0 + sum(k * c.get(el, 0.0) for el, k in LEE_Q.items())


def austenite_grain_um(c: dict[str, float], path: list[tuple[float, float]], ae3_c: float) -> tuple[float, float] | None:
    """Grano austenítico (µm) y tiempo isotérmico equivalente a la T máxima (s); None si no se superó Ae3."""
    q = lee_activation(c)
    s = 0.0
    t_max_k = None
    for (t0, a), (t1, b) in zip(path, path[1:], strict=False):
        tm = (a + b) / 2
        if tm <= ae3_c or t1 <= t0:
            continue
        tk = tm + 273.15
        s += math.exp(-q / (LEE_N * R * tk)) * (t1 - t0)
        t_max_k = tk if t_max_k is None else max(t_max_k, tk)
    if s <= 0 or t_max_k is None:
        return None
    d = LEE_A * s ** LEE_N
    # tiempo a la temperatura máxima que daría el mismo grano (para comprobar el dominio de 3 h)
    t_eq = s / math.exp(-q / (LEE_N * R * t_max_k))
    return d, t_eq


def astm_g_from_intercept_um(l_um: float) -> float:
    return ASTM_A * math.log10(l_um / 1000.0) + ASTM_B


def ceq(c: dict[str, float]) -> float:
    return c.get("C", 0.0) + c.get("Mn", 0.0) / 6


def ferrite_grain_um(c: dict[str, float], rate_k_s: float, d_gamma_um: float) -> float | None:
    """Hodgson & Gibbs (1992), rama Ceq < 0.35. None fuera de esa rama o si el resultado no es físico."""
    ce = ceq(c)
    if ce >= HG_CEQ_MAX or rate_k_s <= 0:
        return None
    d = (-0.4 + 6.37 * ce) + (24.2 - 59 * ce) * rate_k_s ** -0.5 + 22 * (1 - math.exp(-0.015 * d_gamma_um))
    return d if d > 0 else None


def estimate(comps: dict[str, dict[str, float]], path: list[tuple[float, float]], ae3_by_key: dict[str, float],
             t_peak_c: float) -> dict | None:
    """Grano austenítico previo (nominal y banda por rango de composición) con sus avisos de dominio."""
    nominal = austenite_grain_um(comps["nominal"], path, ae3_by_key["nominal"])
    if nominal is None:
        return None
    d, t_eq = nominal
    ds = [d]
    for key in ("low", "high"):
        r = austenite_grain_um(comps[key], path, ae3_by_key[key])
        if r is not None:
            ds.append(r[0])
    lo_t, hi_t = LEE_T_RANGE_C
    flags = []
    # tolerancia de 3 °C: el centro de la probeta se iguala con el horno a ±2 °C (criterio del modelo térmico)
    if t_peak_c < lo_t - 3:
        flags.append("below_850c")
    if t_peak_c > hi_t:
        flags.append("above_1200c")
    if t_eq > LEE_T_MAX_S:
        flags.append("longer_than_3h")
    return {
        "austenite_um": d,
        "austenite_um_range": (min(ds), max(ds)),
        "austenite_g": astm_g_from_intercept_um(d),
        "austenite_g_range": (astm_g_from_intercept_um(max(ds)), astm_g_from_intercept_um(min(ds))),
        "equivalent_time_s": t_eq,
        "extrapolation": flags,
    }
