from __future__ import annotations

from sqlalchemy import Engine, create_engine


def make_engine(url: str) -> Engine:
    if url.startswith("postgresql://"):
        url = "postgresql+psycopg://" + url[len("postgresql://"):]
    return create_engine(url, pool_pre_ping=True, pool_size=5, max_overflow=5, future=True)
