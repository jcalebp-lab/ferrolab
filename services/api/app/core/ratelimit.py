"""Límite de solicitudes en memoria (ventana deslizante). Suficiente para un proceso;
no guarda IPs de forma persistente (doc 13 §5)."""

from __future__ import annotations

import time
from collections import defaultdict, deque
from threading import Lock


class RateLimiter:
    def __init__(self) -> None:
        self._hits: dict[tuple[str, str], deque[float]] = defaultdict(deque)
        self._lock = Lock()

    def check(self, bucket: str, client: str, limit: int, window_s: float = 60.0) -> float | None:
        """Devuelve None si se permite o los segundos de espera sugeridos."""
        if limit <= 0:
            return window_s
        now = time.monotonic()
        key = (bucket, client)
        with self._lock:
            q = self._hits[key]
            while q and now - q[0] > window_s:
                q.popleft()
            if len(q) >= limit:
                return max(1.0, window_s - (now - q[0]))
            q.append(now)
            if len(self._hits) > 50_000:  # higiene de memoria
                self._hits = defaultdict(deque, {k: v for k, v in self._hits.items() if v})
        return None

    def reset(self) -> None:
        with self._lock:
            self._hits.clear()
