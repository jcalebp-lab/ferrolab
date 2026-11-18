"""Proveedor del snapshot activo y del motor (caché por checksum)."""

from __future__ import annotations

import json
import logging
from dataclasses import dataclass
from threading import Lock

from ferrolab_fse import DatasetSnapshot, ScientificEngine

from ..core.config import Settings
from ..core.errors import ApiError
from ..core.ratelimit import RateLimiter
from ..repositories.postgres import PostgresRepository

log = logging.getLogger("ferrolab.state")


@dataclass
class Loaded:
    snapshot: DatasetSnapshot
    engine: ScientificEngine
    checksum: str
    origin: str  # "database_release" | "seed_file"


class AppState:
    def __init__(self, settings: Settings, repo: PostgresRepository | None) -> None:
        self.settings = settings
        self.repo = repo
        self.limiter = RateLimiter()
        self._loaded: Loaded | None = None
        self._lock = Lock()
        self.ai_requests_today = 0
        self.ai_day: str | None = None

    def reload(self) -> None:
        with self._lock:
            self._loaded = None

    def current(self) -> Loaded:
        with self._lock:
            if self._loaded is None:
                self._loaded = self._load()
            return self._loaded

    def _load(self) -> Loaded:
        if self.repo is not None:
            try:
                got = self.repo.active_snapshot()
            except Exception as exc:  # BD caída: no se simula con datos obsoletos en silencio
                log.error("db_unavailable: %s", type(exc).__name__)
                raise ApiError(503, "dependency_unavailable", "La base de datos científica no está disponible") from exc
            if got is None:
                raise ApiError(503, "dependency_unavailable", "No hay una publicación científica activa")
            snap, checksum = got
            origin = "database_release"
        else:
            if self.settings.is_production:
                raise ApiError(503, "dependency_unavailable", "Producción requiere DATABASE_URL")
            snap = DatasetSnapshot.model_validate(json.loads(self.settings.snapshot_file.read_text(encoding="utf-8")))
            checksum = snap.checksum()
            origin = "seed_file"
        if snap.contains_unreviewed_content and self.settings.is_production:
            raise ApiError(503, "dependency_unavailable", "La publicación activa contiene contenido no revisado")
        return Loaded(snapshot=snap, engine=ScientificEngine(snap), checksum=checksum, origin=origin)
