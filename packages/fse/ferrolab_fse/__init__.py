"""Ferrolab Scientific Engine (FSE)."""

ENGINE_VERSION = "0.2.0"

from .engine import InvalidState, ScientificEngine, SimulationRequest, UnknownEntity  # noqa: E402
from .snapshot import DatasetSnapshot  # noqa: E402

__all__ = [
    "ENGINE_VERSION",
    "DatasetSnapshot",
    "InvalidState",
    "ScientificEngine",
    "SimulationRequest",
    "UnknownEntity",
]
