"""Descomposición de la austenita: modelo de Li et al. (1998) con la lógica secuencial de la
implementación abierta de Collins et al. (2023, Metals 13:1168; código MIT en Zenodo 10.5281/zenodo.7767620),
regla de aditividad de Scheil y Koistinen–Marburger.

Coeficientes según el código abierto de Collins et al. (2023), que reproduce la forma de Li (1998); en la perlita el
molibdeno entra como 5.19·√Mo.
Solo para ACEROS de baja aleación; nunca para la fundición gris.
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from functools import lru_cache

from .data import KM_ALPHA

Q_OVER_R = 27500.0 / 1.987  # K  (Li 1998: 27 500 cal/mol)
X_NUC = 0.01
REACTIONS = ("ferrite", "pearlite", "bainite")


def _g(c: dict[str, float], el: str) -> float:
    return c.get(el, 0.0)  # las composiciones ya son float (se llama ~10⁵ veces por simulación)


# ---------------------------------------------------------------- temperaturas del modelo de Li
def ae3_li(c: dict[str, float]) -> float:
    """Grange (1961) en °F → °C: 1570 − 323C − 25Mn + 80Si − 3Cr − 32Ni."""
    return (1570 - 323 * _g(c, "C") - 25 * _g(c, "Mn") + 80 * _g(c, "Si") - 3 * _g(c, "Cr") - 32 * _g(c, "Ni") - 32) * 5 / 9


def ae1_li(c: dict[str, float]) -> float:
    """Grange (1961) en °F → °C: 1333 − 25Mn + 40Si + 42Cr − 26Ni."""
    return (1333 - 25 * _g(c, "Mn") + 40 * _g(c, "Si") + 42 * _g(c, "Cr") - 26 * _g(c, "Ni") - 32) * 5 / 9


def bs_li(c: dict[str, float]) -> float:
    """Li et al. (1998): 637 − 58C − 35Mn − 15Ni − 34Cr − 41Mo."""
    return 637 - 58 * _g(c, "C") - 35 * _g(c, "Mn") - 15 * _g(c, "Ni") - 34 * _g(c, "Cr") - 41 * _g(c, "Mo")


def ms_andrews(c: dict[str, float]) -> float:
    return 539.0 - 423.0 * _g(c, "C") - 30.4 * _g(c, "Mn") - 17.7 * _g(c, "Ni") - 12.1 * _g(c, "Cr") \
        - 7.5 * _g(c, "Mo") - 7.5 * _g(c, "Si") + 10 * _g(c, "Co")


def ae3_carbon_at(c: dict[str, float], t_c: float) -> float:
    """Carbono de la línea Ae3 a la temperatura T (inversa de Grange)."""
    t_f = t_c * 9 / 5 + 32
    return (t_f - 1570 + 25 * _g(c, "Mn") - 80 * _g(c, "Si") + 3 * _g(c, "Cr") + 32 * _g(c, "Ni")) / -323


FERRITE_CARBON = 0.03  # wt% C de la ferrita en el balance (Collins: sf = 0.03)


def max_ferrite(c: dict[str, float], t_c: float) -> float:
    """Regla de la palanca a T (fracción másica; Collins aplica además corrección de densidad)."""
    # Por debajo de Ae1 la línea Ae3 no se prolonga: el C de la austenita queda en el eutectoide.
    ca = ae3_carbon_at(c, max(t_c, ae1_li(c)))
    carbon = _g(c, "C")
    if ca <= carbon:
        return 0.0
    return max(0.0, min(1.0, (ca - carbon) / (ca - FERRITE_CARBON)))


# ---------------------------------------------------------------- funciones del modelo
def f_ferrite(c):
    return math.exp(1 + 6.31 * _g(c, "C") + 1.78 * _g(c, "Mn") + 0.31 * _g(c, "Si") + 1.12 * _g(c, "Ni")
                    + 2.7 * _g(c, "Cr") + 4.06 * _g(c, "Mo"))


def f_pearlite(c):
    return math.exp(-4.25 + 4.12 * _g(c, "C") + 4.36 * _g(c, "Mn") + 0.44 * _g(c, "Si") + 1.71 * _g(c, "Ni")
                    + 3.33 * _g(c, "Cr") + 5.19 * math.sqrt(_g(c, "Mo")))


def f_bainite(c):
    return math.exp(-10.23 + 10.18 * _g(c, "C") + 0.85 * _g(c, "Mn") + 0.55 * _g(c, "Ni") + 0.9 * _g(c, "Cr")
                    + 0.36 * _g(c, "Mo"))


_EXP = {"ferrite": (0.41, 3), "pearlite": (0.32, 3), "bainite": (0.29, 2)}


def _sx_integrand(x: float) -> float:
    return x ** (0.4 * (1 - x)) * (1 - x) ** (0.4 * x)


@lru_cache(maxsize=256)
def sigmoid_s(x: float) -> float:
    """S(X) = ∫0^X dx / (X^{0.4(1−X)} (1−X)^{0.4X})."""
    x = min(max(x, 1e-9), 0.999)
    a = min(1e-4, x)
    total = a ** 0.6 / 0.6
    if x <= a:
        return total
    n = 1000
    h = (x - a) / n
    s = 1 / _sx_integrand(a) + 1 / _sx_integrand(x)
    for i in range(1, n):
        s += (4 if i % 2 else 2) / _sx_integrand(a + i * h)
    return total + s * h / 3


@dataclass(frozen=True)
class Temps:
    ae3: float
    ae1: float
    bs: float
    ms: float


def li_temps(c: dict[str, float]) -> Temps:
    return Temps(ae3=ae3_li(c), ae1=ae1_li(c), bs=bs_li(c), ms=ms_andrews(c))


_F = {"ferrite": f_ferrite, "pearlite": f_pearlite, "bainite": f_bainite}


def factors(c: dict[str, float]) -> dict[str, float]:
    """Factores de composición F de Li para las tres reacciones (se calculan una vez por composición)."""
    return {r: fn(c) for r, fn in _F.items()}


def rate_k(reaction: str, t_c: float, c: dict[str, float], tm: Temps, grain: float, f: float | None = None) -> float:
    """1/τ sin S(X) [1/s]: 2^{aG} ΔT^n exp(−Q/RT) / F. `f` evita recalcular F si ya se conoce."""
    a, n = _EXP[reaction]
    top = tm.ae3 if reaction == "ferrite" else tm.ae1 if reaction == "pearlite" else tm.bs
    dt = top - t_c
    if dt <= 0 or t_c <= tm.ms:
        return 0.0
    if f is None:
        f = _F[reaction](c)
    return (2 ** (a * grain)) * dt ** n * math.exp(-Q_OVER_R / (t_c + 273.15)) / f


def tau(reaction: str, x: float, t_c: float, c: dict[str, float], tm: Temps, grain: float) -> float | None:
    k = rate_k(reaction, t_c, c, tm, grain)
    return None if k <= 0 else sigmoid_s(x) / k


# ---------------------------------------------------------------- integración sobre trayectorias
@dataclass
class State:
    austenite: float
    untransformed_ferrite: float = 0.0
    frac: dict[str, float] = field(default_factory=lambda: {r: 0.0 for r in REACTIONS})
    nucl: dict[str, float] = field(default_factory=lambda: {r: 0.0 for r in REACTIONS})
    started: dict[str, tuple[float, float] | None] = field(default_factory=lambda: {r: None for r in REACTIONS})
    carbon_austenite: float = 0.0
    t_min_below_ms: float | None = None
    ms_effective: float | None = None


def _allowed(st: State, r: str) -> bool:
    if r == "ferrite":
        return st.started["pearlite"] is None and st.started["bainite"] is None
    if r == "pearlite":
        return st.started["bainite"] is None
    return True


def integrate(path: list[tuple[float, float]], c: dict[str, float], grain: float, austenite0: float = 1.0,
              carbon0: float | None = None) -> State:
    """Trayectoria (t_s, T_c) desde la austenización hasta el final. Pasos ≤ 1 K y limitados por la cinética."""
    tm = li_temps(c)
    st = State(austenite=austenite0, untransformed_ferrite=1 - austenite0,
               carbon_austenite=_g(c, "C") if carbon0 is None else carbon0)
    f_nom = factors(c)  # la ferrita usa la composición nominal: F constante en toda la trayectoria
    max_f = {}  # palanca de ferrita por temperatura (solo depende de la composición nominal)
    for (t0, a), (t1, b) in zip(path, path[1:], strict=False):
        span = t1 - t0
        if span <= 0:
            continue
        n = max(1, math.ceil(abs(b - a)))
        sub = span / n
        for i in range(n):
            tc = a + (b - a) * (i + 0.5) / n
            local = dict(c, C=st.carbon_austenite)  # la austenita enriquecida en C gobierna lo que sigue
            ltm = Temps(ae3=tm.ae3, ae1=tm.ae1, bs=bs_li(local) if st.started["bainite"] is None else tm.bs,
                        ms=ms_andrews(local))
            remaining, now = sub, t0 + i * sub
            # F de perlita/bainita con el C de la austenita en este subpaso (una vez, no en cada iteración)
            fk = {"ferrite": f_nom["ferrite"], "pearlite": f_pearlite(local), "bainite": f_bainite(local)}
            while remaining > 1e-9 and st.austenite > 1e-6:
                dt = remaining
                for r in REACTIONS:
                    if not _allowed(st, r):
                        continue
                    k = rate_k(r, tc, local if r != "ferrite" else c, ltm, grain, fk[r])
                    if k > 0:
                        if st.started[r] is None:
                            dt = min(dt, max(0.05 * sigmoid_s(X_NUC) / k, 1e-4))
                        else:
                            dt = min(dt, max(0.005 / k, 1e-4))
                if tc not in max_f:
                    max_f[tc] = max_ferrite(c, tc)
                _advance_mixed(st, tc, dt, now + dt, c, local, ltm, grain, fk, max_f[tc])
                remaining -= dt
                now += dt
            if tc < ltm.ms:
                st.ms_effective = ltm.ms if st.ms_effective is None else st.ms_effective
                st.t_min_below_ms = tc if st.t_min_below_ms is None else min(st.t_min_below_ms, tc)
    return st


def _advance_mixed(st, tc, dt, now, c, local, tm, grain, fk=None, max_f=None):
    """Ferrita con la composición nominal; perlita/bainita con la austenita enriquecida."""
    for r in REACTIONS:
        comp = c if r == "ferrite" else local
        if st.austenite <= 1e-6 or not _allowed(st, r):
            continue
        k = rate_k(r, tc, comp, tm, grain, None if fk is None else fk[r])
        if k <= 0:
            continue
        if st.started[r] is None:
            st.nucl[r] += dt * k / sigmoid_s(X_NUC)
            if st.nucl[r] < 1.0:
                continue
            st.started[r] = (now, tc)
            inc = X_NUC
        else:
            inc = dt * k * _sx_integrand(max(min(st.frac[r], 0.999), X_NUC))
        if r == "ferrite":
            mf = max_ferrite(c, tc) if max_f is None else max_f
            inc = min(inc, max(0.0, mf - st.frac["ferrite"] - st.untransformed_ferrite))
        inc = min(inc, st.austenite)
        if inc <= 0:
            continue
        st.frac[r] += inc
        st.austenite -= inc
        if r == "ferrite" and st.austenite > 1e-6:
            total_f = st.frac["ferrite"] + st.untransformed_ferrite
            st.carbon_austenite = (_g(c, "C") - total_f * FERRITE_CARBON) / max(1 - total_f, 1e-6)


def final_microstructure(st: State) -> dict[str, float]:
    martensite = 0.0
    if st.t_min_below_ms is not None and st.austenite > 0 and st.ms_effective is not None:
        martensite = st.austenite * (1 - math.exp(-KM_ALPHA * (st.ms_effective - st.t_min_below_ms)))
    return {
        "proeutectoid_ferrite": st.frac["ferrite"] + st.untransformed_ferrite,
        "pearlite": st.frac["pearlite"],
        "bainite": st.frac["bainite"],
        "martensite": martensite,
        "retained_austenite": max(0.0, st.austenite - martensite),
    }


# ---------------------------------------------------------------- diagramas
def ttt_diagram(c: dict[str, float], grain: float) -> dict:
    tm = li_temps(c)
    specs = [("ferrite", X_NUC, "Fs"), ("pearlite", X_NUC, "Ps"), ("pearlite", 0.99, "Pf"),
             ("bainite", X_NUC, "Bs"), ("bainite", 0.99, "Bf")]
    curves = []
    for reaction, x, label in specs:
        top = {"ferrite": tm.ae3, "pearlite": tm.ae1, "bainite": tm.bs}[reaction]
        pts = []
        t_c = math.floor(top) - 1
        while t_c > tm.ms:
            v = tau(reaction, x, t_c, c, tm, grain)
            if v is not None and 1e-2 <= v <= 1e6:
                pts.append([round(v, 4), float(t_c)])
            t_c -= 4
        curves.append({"name": label, "reaction": reaction, "fraction": x, "points": pts})
    return {"kind": "TTT", "x_log_scale": True, "unit_x": "s", "unit_y": "°C", "curves": curves,
            "lines": {"Ae3": round(tm.ae3, 1), "Ae1": round(tm.ae1, 1), "Bs": round(tm.bs, 1), "Ms": round(tm.ms, 1)}}


CCT_RATES = (0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200, 500)


def cct_diagram(c: dict[str, float], grain: float, t_start: float, rates=CCT_RATES) -> dict:
    tm = li_temps(c)
    starts: dict[str, list] = {r: [] for r in REACTIONS}
    runs = []
    for rate in rates:
        st = integrate([(0.0, t_start), ((t_start - 20.0) / rate, 20.0)], c, grain)
        micro = final_microstructure(st)
        for r in REACTIONS:
            if st.started[r] is not None:
                starts[r].append([round(max(st.started[r][0], 1e-2), 3), round(st.started[r][1], 1)])
        runs.append({"rate_k_s": rate, "fractions": {k: round(v, 3) for k, v in micro.items()}})
    curves = [{"name": {"ferrite": "Fs", "pearlite": "Ps", "bainite": "Bs"}[r], "reaction": r, "fraction": X_NUC,
               "points": sorted(starts[r])} for r in REACTIONS]
    return {"kind": "CCT", "x_log_scale": True, "unit_x": "s", "unit_y": "°C", "curves": curves, "runs": runs,
            "t_start_c": t_start, "lines": {"Ae3": round(tm.ae3, 1), "Ae1": round(tm.ae1, 1), "Ms": round(tm.ms, 1)}}
