"""Errores homogéneos con request_id (doc 06 §10). Sin trazas internas."""

from __future__ import annotations

import logging
from typing import Any

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from ferrolab_fse import InvalidState, UnknownEntity
from starlette.exceptions import HTTPException as StarletteHTTPException

from ..repositories.postgres import RepoError

log = logging.getLogger("ferrolab.api")

STATUS_CODES = {400: "invalid_state", 401: "unauthenticated", 403: "forbidden", 404: "not_found", 405: "method_not_allowed",
                409: "revision_conflict", 413: "payload_too_large", 422: "validation_error", 429: "rate_limited",
                503: "dependency_unavailable"}


class ApiError(Exception):
    def __init__(self, status: int, code: str, message: str, details: dict[str, Any] | None = None,
                 headers: dict[str, str] | None = None) -> None:
        super().__init__(message)
        self.status, self.code, self.message = status, code, message
        self.details = details or {}
        self.headers = headers or {}


def error_body(request: Request, code: str, message: str, details: dict | None = None) -> dict:
    return {"error": {"code": code, "message": message, "message_key": f"error.{code}", "details": details or {},
                      "request_id": getattr(request.state, "request_id", None)}}


def install(app: FastAPI) -> None:
    @app.exception_handler(ApiError)
    async def _api(request: Request, exc: ApiError):
        return JSONResponse(error_body(request, exc.code, exc.message, exc.details), exc.status, headers=exc.headers)

    @app.exception_handler(RepoError)
    async def _repo(request: Request, exc: RepoError):
        return JSONResponse(error_body(request, exc.code, exc.message, exc.details), exc.status)

    @app.exception_handler(UnknownEntity)
    async def _unknown(request: Request, exc: UnknownEntity):
        return JSONResponse(error_body(request, "not_found", f"{exc.field} no existe o no está publicado",
                                       {"field": exc.field}), 404)

    @app.exception_handler(InvalidState)
    async def _state(request: Request, exc: InvalidState):
        return JSONResponse(error_body(request, "invalid_state", str(exc), {"field": exc.field}), 400)

    @app.exception_handler(RequestValidationError)
    async def _validation(request: Request, exc: RequestValidationError):
        errs = [{"loc": [str(x) for x in e.get("loc", [])], "msg": e.get("msg"), "type": e.get("type")}
                for e in exc.errors()]
        return JSONResponse(error_body(request, "validation_error", "Solicitud inválida", {"errors": errs}), 422)

    @app.exception_handler(StarletteHTTPException)
    async def _http(request: Request, exc: StarletteHTTPException):
        code = STATUS_CODES.get(exc.status_code, "http_error")
        return JSONResponse(error_body(request, code, str(exc.detail)), exc.status_code)

    @app.exception_handler(Exception)
    async def _internal(request: Request, exc: Exception):
        log.exception("internal_error request_id=%s", getattr(request.state, "request_id", None))
        return JSONResponse(error_body(request, "internal_error", "No pudimos completar esta solicitud"), 500)
