"""Punto de entrada de la API FERROLAB.

Ejecutar (desarrollo):  uv run uvicorn app.main:app --app-dir services/api --port 8000
"""

from __future__ import annotations

import logging
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import __version__
from .api.v1 import admin, public
from .core import errors
from .core.config import Settings, get_settings
from .core.middleware import RequestContextMiddleware
from .db.session import make_engine
from .repositories.postgres import PostgresRepository
from .services.state import AppState
from .services.tutor_service import TutorService


def create_app(settings: Settings | None = None) -> FastAPI:
    s = settings or get_settings()
    logging.basicConfig(level=s.log_level, format="%(asctime)s %(levelname)s %(name)s %(message)s")
    show_docs = s.expose_docs and not s.is_production
    app = FastAPI(
        title="FERROLAB API", version=__version__,
        description="Laboratorio virtual educativo de tratamientos térmicos. El FSE calcula; la IA solo explica.",
        docs_url="/docs" if show_docs else None, redoc_url=None,
        openapi_url="/openapi.json" if show_docs else None,
    )
    repo = PostgresRepository(make_engine(s.database_url.get_secret_value())) if s.database_url else None
    app.state.ferrolab = AppState(s, repo)
    app.state.tutor = TutorService(s)
    errors.install(app)
    app.add_middleware(RequestContextMiddleware, max_body_bytes=s.max_body_bytes)
    app.add_middleware(CORSMiddleware, allow_origins=s.allowed_origins, allow_credentials=False,
                       allow_methods=["GET", "POST", "PATCH"], allow_headers=["Authorization", "Content-Type",
                                                                              "If-None-Match"],
                       expose_headers=["X-Request-ID", "ETag", "Retry-After"], max_age=600)
    app.include_router(public.router)
    app.include_router(admin.router)
    # Micrografías reales redimensionadas (licencias libres; autor y licencia se envían en la API).
    from fastapi.staticfiles import StaticFiles as _Static

    media = Path(__file__).resolve().parent / "static"
    app.mount("/media", _Static(directory=media), name="media")
    if s.serve_web_app:
        from fastapi.staticfiles import StaticFiles

        if not (s.web_app_dir / "index.html").exists():
            raise RuntimeError(f"SERVE_WEB_APP=true pero no existe {s.web_app_dir}/index.html: compile la web primero")
        # Montado al final: las rutas /api/v1 tienen prioridad.
        app.mount("/", StaticFiles(directory=s.web_app_dir, html=True), name="web")
    return app


app = create_app()
