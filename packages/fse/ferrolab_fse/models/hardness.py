"""Dureza: sin predicción universal (doc 04 §5.5).

ASTM E140 es una tabla de conversión aproximada, no un predictor. La
conversión solo funciona con una tabla publicada (pares de valores con
evidencia) y rechaza valores fuera de la tabla. No hay tabla en el repositorio.
"""

from __future__ import annotations

SCALES = ("HRC", "HV", "HBW", "HRB")


def convert_with_table(value: float, table: list[tuple[float, float]]) -> float:
    """Interpolación lineal DENTRO de una tabla publicada; fuera de rango -> error."""
    if len(table) < 2:
        raise ValueError("tabla de conversión no disponible")
    pts = sorted(table)
    if not (pts[0][0] <= value <= pts[-1][0]):
        raise ValueError("valor fuera del dominio de la tabla de conversión")
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        if x0 <= value <= x1:
            return y0 if x1 == x0 else y0 + (y1 - y0) * (value - x0) / (x1 - x0)
    raise ValueError("valor fuera del dominio")  # pragma: no cover
