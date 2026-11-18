"""Autenticación de ADMINISTRADORES (los estudiantes no se autentican).

Flujo (doc 06 §16.6): verificar JWT (firma, emisor, audiencia, expiración) ->
buscar membresía en `admin_memberships` (servidor) -> autorizar por rol.
Nunca se confía en un rol enviado en el cuerpo o en claims editables.
"""

from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache

import jwt
from fastapi import Request
from ferrolab_fse.enums import AdminRole

from .config import Settings
from .errors import ApiError

ROLE_RANK = {AdminRole.EDITOR: 1, AdminRole.REVIEWER: 2, AdminRole.ADMIN: 3}


@dataclass(frozen=True)
class AdminPrincipal:
    user_id: str
    email: str | None
    role: AdminRole

    def require(self, minimum: AdminRole) -> None:
        if ROLE_RANK[self.role] < ROLE_RANK[minimum]:
            raise ApiError(403, "forbidden", "Tu rol no permite esta operación", {"required_role": minimum.value})


@lru_cache(maxsize=4)
def _jwks_client(url: str) -> jwt.PyJWKClient:
    return jwt.PyJWKClient(url, cache_keys=True, timeout=5)


def verify_token(token: str, s: Settings) -> dict:
    options = {"require": ["exp", "sub", "aud"]}
    kwargs = {"audience": s.supabase_jwt_audience, "options": options, "leeway": 10}
    if s.supabase_jwt_issuer:
        kwargs["issuer"] = s.supabase_jwt_issuer
    try:
        if s.supabase_jwks_url:
            key = _jwks_client(s.supabase_jwks_url).get_signing_key_from_jwt(token).key
            return jwt.decode(token, key, algorithms=["RS256", "ES256"], **kwargs)
        if s.supabase_jwt_secret:
            return jwt.decode(token, s.supabase_jwt_secret.get_secret_value(), algorithms=["HS256"], **kwargs)
    except jwt.PyJWTError as exc:
        raise ApiError(401, "unauthenticated", "Token inválido o expirado") from exc
    raise ApiError(503, "dependency_unavailable", "La autenticación de administración no está configurada")


def bearer(request: Request) -> str:
    auth = request.headers.get("authorization", "")
    scheme, _, token = auth.partition(" ")
    if scheme.lower() != "bearer" or not token:
        raise ApiError(401, "unauthenticated", "Se requiere autenticación de administrador",
                       headers={"WWW-Authenticate": "Bearer"})
    return token.strip()
