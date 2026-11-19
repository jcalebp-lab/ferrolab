"""Historia térmica física de una probeta cilíndrica de referencia (conducción radial 1-D implícita).

Supuestos declarados (data.ASSUMPTIONS): diámetro 12.7 mm, k, ρ, cp constantes; medios de temple
caracterizados por la severidad de Grossmann H (h = 2·k·H); aire en calma = convección natural +
radiación; enfriamiento en horno a velocidad fija (Compraco 1045, «Complete annealing»).
"""

from __future__ import annotations

import math
from dataclasses import dataclass

from .data import ASSUMPTIONS, GROSSMANN_H

SIGMA = 5.670374419e-8  # constante de Stefan-Boltzmann (CODATA)
INCH = 0.0254
N_NODES = 9


@dataclass(frozen=True)
class Medium:
    code: str          # water | oil | air | furnace | salt_bath
    temperature_c: float
    grossmann_h: float | None = None  # 1/in


def _h(medium: Medium, surface_c: float) -> float:
    k = ASSUMPTIONS["k_w_mk"]
    if medium.grossmann_h is not None:
        return 2 * k * medium.grossmann_h / INCH
    ts, ta = surface_c + 273.15, medium.temperature_c + 273.15
    eps = ASSUMPTIONS["emissivity"]
    rad = eps * SIGMA * (ts ** 2 + ta ** 2) * (ts + ta)
    conv = ASSUMPTIONS["h_air_conv_w_m2k"] if medium.code in ("air", "furnace") else 0.0
    return conv + rad


def _solve_tridiagonal(a, b, c, d):
    n = len(d)
    cp, dp = [0.0] * n, [0.0] * n
    cp[0], dp[0] = c[0] / b[0], d[0] / b[0]
    for i in range(1, n):
        m = b[i] - a[i] * cp[i - 1]
        cp[i] = c[i] / m if i < n - 1 else 0.0
        dp[i] = (d[i] - a[i] * dp[i - 1]) / m
    x = [0.0] * n
    x[-1] = dp[-1]
    for i in range(n - 2, -1, -1):
        x[i] = dp[i] - cp[i] * x[i + 1]
    return x


class Bar:
    """Cilindro largo de radio R discretizado en N nodos (volúmenes finitos, Euler implícito)."""

    def __init__(self, temperature_c: float, diameter_m: float | None = None) -> None:
        self.r = (diameter_m or ASSUMPTIONS["reference_diameter_m"]) / 2
        self.n = N_NODES
        self.dr = self.r / (self.n - 1)
        self.t = [float(temperature_c)] * self.n
        self.alpha_vol = ASSUMPTIONS["rho_kg_m3"] * ASSUMPTIONS["cp_j_kgk"]

    @property
    def center(self) -> float:
        return self.t[0]

    @property
    def surface(self) -> float:
        return self.t[-1]

    def step(self, dt: float, medium: Medium) -> None:
        k, dr, n = ASSUMPTIONS["k_w_mk"], self.dr, self.n
        h = _h(medium, self.surface)
        a, b, c, d = [0.0] * n, [0.0] * n, [0.0] * n, [0.0] * n
        for i in range(n):
            ri = i * dr
            r_in = max(ri - dr / 2, 0.0)
            r_out = min(ri + dr / 2, self.r)
            vol = (r_out ** 2 - r_in ** 2) / 2  # por radián y unidad de longitud
            cap = self.alpha_vol * vol / dt
            g_in = k * r_in / dr if i > 0 else 0.0
            g_out = k * r_out / dr if i < n - 1 else 0.0
            a[i], c[i] = -g_in, -g_out
            b[i] = cap + g_in + g_out
            d[i] = cap * self.t[i]
            if i == n - 1:
                b[i] += h * self.r
                d[i] += h * self.r * medium.temperature_c
        self.t = _solve_tridiagonal(a, b, c, d)


@dataclass
class Segment:
    kind: str            # heat | hold | transfer | cool | isothermal_hold | furnace_cool
    label_key: str
    t_start_s: float
    t_end_s: float
    medium: str


@dataclass
class ThermalRun:
    center: list[tuple[float, float]]
    surface: list[tuple[float, float]]
    segments: list[Segment]
    max_center_c: float

    @property
    def total_s(self) -> float:
        return self.center[-1][0]


class Runner:
    def __init__(self, start_c: float) -> None:
        self.bar = Bar(start_c)
        self.time = 0.0
        self.center = [(0.0, start_c)]
        self.surface = [(0.0, start_c)]
        self.segments: list[Segment] = []
        self.max_center = start_c

    def _record(self) -> None:
        self.center.append((self.time, self.bar.center))
        self.surface.append((self.time, self.bar.surface))
        self.max_center = max(self.max_center, self.bar.center)

    def run(self, kind: str, label: str, medium: Medium, *, duration_s: float | None = None,
            until_center_below: float | None = None, until_center_within: float | None = None,
            max_s: float = 4 * 3600) -> None:
        t0 = self.time
        elapsed = 0.0
        while True:
            if duration_s is not None and elapsed >= duration_s - 1e-9:
                break
            if until_center_below is not None and self.bar.center <= until_center_below:
                break
            if until_center_within is not None and abs(self.bar.center - medium.temperature_c) <= until_center_within:
                break
            if elapsed >= max_s:
                break
            gap = max(abs(self.bar.surface - medium.temperature_c), abs(self.bar.center - medium.temperature_c))
            dt = 0.05 if medium.grossmann_h is not None and gap > 30 else (0.5 if gap > 30 else 5.0)
            if duration_s is not None:
                dt = min(dt, duration_s - elapsed)
            self.bar.step(dt, medium)
            self.time += dt
            elapsed += dt
            self._record()
        self.segments.append(Segment(kind, label, t0, self.time, medium.code))

    def furnace_cool(self, label: str, rate_c_per_h: float, until_c: float) -> None:
        """Enfriamiento en horno a velocidad impuesta (pieza ≈ horno)."""
        t0 = self.time
        start = self.bar.center
        if start > until_c:
            dur = (start - until_c) / rate_c_per_h * 3600
            n = max(2, int(start - until_c))
            for i in range(1, n + 1):
                tc = start - (start - until_c) * i / n
                self.time = t0 + dur * i / n
                self.bar.t = [tc] * self.bar.n
                self._record()
        self.segments.append(Segment("furnace_cool", label, t0, self.time, "furnace"))

    def result(self) -> ThermalRun:
        return ThermalRun(self.center, self.surface, self.segments, self.max_center)


def medium(code: str, temperature_c: float | None = None) -> Medium:
    amb = ASSUMPTIONS["ambient_c"]
    if code in GROSSMANN_H:
        return Medium(code, amb if temperature_c is None else temperature_c, GROSSMANN_H[code])
    if code == "salt_bath":  # supuesto: severidad equivalente a aceite sin agitar
        return Medium(code, float(temperature_c), GROSSMANN_H["oil"])
    return Medium(code, amb if temperature_c is None else temperature_c, None)


def thin(points: list[tuple[float, float]], max_points: int = 400) -> list[tuple[float, float]]:
    """Reduce puntos conservando forma (umbral de 1 °C y extremos), sin superar max_points."""
    if len(points) <= max_points:
        return points
    out = [points[0]]
    for p in points[1:-1]:
        if abs(p[1] - out[-1][1]) >= 1.0 or p[0] - out[-1][0] > points[-1][0] / max_points:
            out.append(p)
    out.append(points[-1])
    if len(out) > max_points:
        step = math.ceil(len(out) / max_points)
        out = out[::step] + [points[-1]]
    return out


def rate_at(points: list[tuple[float, float]], t_c: float) -> float | None:
    """Velocidad de enfriamiento (K/s, positiva) al cruzar t_c por primera vez bajando."""
    for (t0, a), (t1, b) in zip(points, points[1:], strict=False):
        if a >= t_c > b and t1 > t0:
            return (a - b) / (t1 - t0)
    return None
