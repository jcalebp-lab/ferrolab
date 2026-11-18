from __future__ import annotations

from fastapi import Depends, Query, Request

from ..core.errors import ApiError
from ..core.security import AdminPrincipal, bearer, verify_token
from ..services.state import AppState


def get_state(request: Request) -> AppState:
    return request.app.state.ferrolab


def client_key(request: Request) -> str:
    # Sin X-Forwarded-For por defecto (falsificable). Detrás de un proxy, configúrelo en el servidor ASGI.
    return request.client.host if request.client else "unknown"


def rate_limit(bucket: str, attr: str):
    def dep(request: Request, st: AppState = Depends(get_state)) -> None:
        limit = getattr(st.settings, attr)
        wait = st.limiter.check(bucket, client_key(request), limit)
        if wait is not None:
            raise ApiError(429, "rate_limited", "Demasiadas solicitudes; espera un momento",
                           {"retry_after_s": round(wait)}, headers={"Retry-After": str(round(wait))})
    return dep


def locale_q(locale: str = Query("es", pattern="^(es|en)$")) -> str:
    return locale


def admin(request: Request, st: AppState = Depends(get_state)) -> AdminPrincipal:
    token = bearer(request)
    if st.repo is None:
        raise ApiError(503, "dependency_unavailable", "La administración requiere base de datos")
    claims = verify_token(token, st.settings)
    m = st.repo.membership(str(claims["sub"]))
    if m is None or m["status"] != "active":
        raise ApiError(403, "forbidden", "Tu cuenta no tiene permisos de administración")
    return AdminPrincipal(user_id=str(m["user_id"]), email=m.get("email"), role=m["role"])
