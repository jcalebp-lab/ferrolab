from __future__ import annotations

import logging
import secrets
import time

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse, Response

log = logging.getLogger("ferrolab.access")


class RequestContextMiddleware(BaseHTTPMiddleware):
    """request_id generado por el servidor, límite de tamaño, cabeceras de seguridad y log sin secretos."""

    def __init__(self, app, max_body_bytes: int) -> None:
        super().__init__(app)
        self.max_body_bytes = max_body_bytes

    async def dispatch(self, request: Request, call_next) -> Response:
        rid = "req_" + secrets.token_hex(8)
        request.state.request_id = rid
        start = time.perf_counter()
        if request.method in ("POST", "PATCH", "PUT"):
            cl = request.headers.get("content-length")
            too_big = cl is not None and cl.isdigit() and int(cl) > self.max_body_bytes
            if not too_big:
                body = await request.body()
                too_big = len(body) > self.max_body_bytes
            if too_big:
                return JSONResponse({"error": {"code": "payload_too_large", "message": "Solicitud demasiado grande",
                                               "message_key": "error.payload_too_large", "details": {},
                                               "request_id": rid}}, 413, headers={"X-Request-ID": rid})
        response = await call_next(request)
        response.headers["X-Request-ID"] = rid
        response.headers.setdefault("X-Content-Type-Options", "nosniff")
        response.headers.setdefault("Referrer-Policy", "no-referrer")
        path = request.url.path
        if path.startswith("/api/"):
            # Respuestas JSON: sin incrustación ni caché.
            response.headers.setdefault("X-Frame-Options", "DENY")
            response.headers.setdefault("Cross-Origin-Resource-Policy", "same-site")
            response.headers.setdefault("Content-Security-Policy", "default-src 'none'; frame-ancestors 'none'")
            response.headers.setdefault("Cache-Control", "no-store")
        elif not path.startswith(("/docs", "/redoc", "/openapi")):
            # App web estática (si SERVE_WEB_APP): revalidar para no servir versiones viejas.
            response.headers.setdefault("Cache-Control", "no-cache")
        log.info("%s %s %s %.1fms rid=%s", request.method, request.url.path, response.status_code,
                 (time.perf_counter() - start) * 1000, rid)
        return response
