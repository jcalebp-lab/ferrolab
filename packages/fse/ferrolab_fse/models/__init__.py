"""Modelos científicos. TODOS desactivados hasta tener coeficientes verificados.

El código implementa solo la forma matemática genérica; los parámetros llegan
desde `ModelVersion.parameters` con evidencia por parámetro (GATE-C2, SCI-09).
"""

from .gate import ModelNotActivated, require_active

__all__ = ["ModelNotActivated", "require_active"]
