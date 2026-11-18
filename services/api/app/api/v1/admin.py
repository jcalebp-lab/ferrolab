"""Endpoints de administración: autenticación + rol obligatorios en TODAS las rutas."""

from __future__ import annotations

from typing import Any, Literal

from fastapi import APIRouter, Depends, Query
from ferrolab_fse.enums import AdminRole
from pydantic import BaseModel, ConfigDict, Field

from ...core.errors import ApiError
from ...core.security import AdminPrincipal
from ...repositories.entities import ENTITIES, Entity
from ...services.release_builder import DEV, OFFICIAL, ReleaseBuildError, build_snapshot
from ...services.state import AppState
from ..deps import admin, get_state, rate_limit

router = APIRouter(prefix="/api/v1/admin", tags=["admin"],
                   dependencies=[Depends(rate_limit("admin", "rate_limit_per_minute"))])


class Patch(BaseModel):
    model_config = ConfigDict(extra="forbid")
    revision: int = Field(ge=1)
    changes: dict[str, Any]


class Transition(BaseModel):
    model_config = ConfigDict(extra="forbid")
    to: Literal["reviewed", "draft", "retired"]
    revision: int = Field(ge=1)


class ReleaseCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")
    version: str = Field(pattern=r"^\d+\.\d+\.\d+([-+][0-9A-Za-z.+-]+)?$", max_length=64)
    notes: str | None = Field(default=None, max_length=2000)
    include_drafts: bool = False
    activate: bool = True


class Membership(BaseModel):
    model_config = ConfigDict(extra="forbid")
    user_id: str = Field(pattern=r"^[0-9a-fA-F-]{36}$")
    email: str | None = Field(default=None, max_length=200)
    role: AdminRole


def _entity(name: str) -> Entity:
    ent = ENTITIES.get(name)
    if ent is None:
        raise ApiError(404, "not_found", "Tipo de registro desconocido")
    return ent


def _repo(st: AppState):
    if st.repo is None:
        raise ApiError(503, "dependency_unavailable", "La administración requiere base de datos")
    return st.repo


@router.get("/me")
def me(p: AdminPrincipal = Depends(admin)):
    return {"user_id": p.user_id, "email": p.email, "role": p.role}


@router.get("/entities")
def entities(p: AdminPrincipal = Depends(admin)):
    return {"items": [{"name": e.name, "key_fields": list(e.key_fields),
                       "schema": e.model.model_json_schema()} for e in ENTITIES.values()]}


@router.get("/metrics")
def metrics(p: AdminPrincipal = Depends(admin), st: AppState = Depends(get_state)):
    loaded = st.current()
    return {"records_by_status": _repo(st).counts(), "active_dataset_version": loaded.snapshot.dataset_version,
            "active_contains_unreviewed_content": loaded.snapshot.contains_unreviewed_content,
            "note": "Sin analítica de usuarios: FERROLAB no identifica estudiantes."}


@router.get("/audit")
def audit(limit: int = Query(100, ge=1, le=500), p: AdminPrincipal = Depends(admin), st: AppState = Depends(get_state)):
    p.require(AdminRole.REVIEWER)
    return {"items": _repo(st).audit(limit)}


@router.post("/memberships")
def memberships(body: Membership, p: AdminPrincipal = Depends(admin), st: AppState = Depends(get_state)):
    p.require(AdminRole.ADMIN)
    _repo(st).upsert_membership(body.user_id, body.email, body.role.value)
    return {"ok": True}


# ------------------------------------------------------------------ publicaciones
@router.get("/releases")
def releases(p: AdminPrincipal = Depends(admin), st: AppState = Depends(get_state)):
    return {"items": _repo(st).list_releases()}


def _build(st: AppState, body: ReleaseCreate):
    if body.include_drafts and st.settings.is_production:
        raise ApiError(403, "forbidden", "En producción no se publican borradores")
    repo = _repo(st)
    with repo.engine.connect() as c:
        rows = repo.load_rows(c, DEV if body.include_drafts else OFFICIAL)
    try:
        return build_snapshot(rows, version=body.version, include_drafts=body.include_drafts,
                              interface=st.current().snapshot.interface.model_dump())
    except ReleaseBuildError as exc:
        raise ApiError(422, "validation_error", "La publicación no supera las comprobaciones",
                       {"problems": exc.problems}) from exc


@router.post("/releases/preview")
def release_preview(body: ReleaseCreate, p: AdminPrincipal = Depends(admin), st: AppState = Depends(get_state)):
    p.require(AdminRole.REVIEWER)
    snap, report = _build(st, body)
    return {"checksum": snap.checksum(), "contains_unreviewed_content": snap.contains_unreviewed_content,
            "report": report, "counts": {k: len(v) for k, v in snap.model_dump().items() if isinstance(v, list)}}


@router.post("/releases", status_code=201)
def release_create(body: ReleaseCreate, p: AdminPrincipal = Depends(admin), st: AppState = Depends(get_state)):
    p.require(AdminRole.REVIEWER)
    snap, report = _build(st, body)
    rel = _repo(st).create_release(body.version, snap, p.user_id, body.notes, body.activate,
                                   mark_published=not body.include_drafts)
    st.reload()
    return {**rel, "report": report}


@router.post("/releases/{release_id}/activate")
def release_activate(release_id: str, p: AdminPrincipal = Depends(admin), st: AppState = Depends(get_state)):
    p.require(AdminRole.REVIEWER)
    rel = _repo(st).activate_release(release_id, p.user_id)
    st.reload()
    try:
        st.current()
    except ApiError:
        pass  # p. ej. release no revisada en producción: la API responderá 503 y se verá en /health/ready
    return rel


# ------------------------------------------------------------------ registros
@router.post("/evidence/{key}/approve")
def approve_evidence(key: str, body: Transition, p: AdminPrincipal = Depends(admin), st: AppState = Depends(get_state)):
    """Alias de doc 06: marca evidencia como revisada (la publicación llega con la siguiente release)."""
    p.require(AdminRole.REVIEWER)
    return _repo(st).transition(ENTITIES["evidence"], key, "reviewed", body.revision, p.user_id,
                                st.settings.require_distinct_reviewer)


@router.get("/{entity}")
def list_records(entity: str, status: str | None = Query(None, pattern="^(draft|reviewed|published|retired)$"),
                 limit: int = Query(200, ge=1, le=500), offset: int = Query(0, ge=0),
                 p: AdminPrincipal = Depends(admin), st: AppState = Depends(get_state)):
    return {"items": _repo(st).list(_entity(entity), status, limit, offset)}


@router.get("/{entity}/{key}")
def get_record(entity: str, key: str, p: AdminPrincipal = Depends(admin), st: AppState = Depends(get_state)):
    return _repo(st).get(_entity(entity), key)


@router.post("/{entity}", status_code=201)
def create_record(entity: str, body: dict[str, Any], p: AdminPrincipal = Depends(admin),
                  st: AppState = Depends(get_state)):
    p.require(AdminRole.EDITOR)
    return _repo(st).create(_entity(entity), body, p.user_id)


@router.patch("/{entity}/{key}")
def patch_record(entity: str, key: str, body: Patch, p: AdminPrincipal = Depends(admin),
                 st: AppState = Depends(get_state)):
    p.require(AdminRole.EDITOR)
    return _repo(st).update(_entity(entity), key, body.changes, body.revision, p.user_id)


@router.post("/{entity}/{key}/transition")
def transition(entity: str, key: str, body: Transition, p: AdminPrincipal = Depends(admin),
               st: AppState = Depends(get_state)):
    p.require(AdminRole.REVIEWER)
    return _repo(st).transition(_entity(entity), key, body.to, body.revision, p.user_id,
                                st.settings.require_distinct_reviewer)
