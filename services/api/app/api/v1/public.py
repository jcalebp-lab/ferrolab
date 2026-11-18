"""Endpoints públicos (sin cuenta). Solo lectura + simulación."""

from __future__ import annotations

from typing import Any

from fastapi import APIRouter, Depends, Request, Response
from ferrolab_fse import ENGINE_VERSION, SimulationRequest
from ferrolab_fse.messages import MESSAGES, STAGE_LABELS, localize
from ferrolab_fse.result import Warning as FseWarning

from ... import __version__
from ...core.errors import ApiError
from ...schemas.public import SimulationCreate, TutorAsk, TutorExplain
from ...services import micrograph_service as mg
from ...services.state import AppState
from ..deps import get_state, locale_q, rate_limit

router = APIRouter(prefix="/api/v1")
read_limit = Depends(rate_limit("read", "rate_limit_per_minute"))
sim_limit = Depends(rate_limit("simulate", "simulation_rate_limit_per_minute"))
tutor_limit = Depends(rate_limit("tutor", "tutor_rate_limit_per_minute"))


def _l(obj: Any, field: str, loc: str) -> Any:
    return getattr(obj, f"{field}_{'en' if loc == 'en' else 'es'}")


def _cache(response: Response, request: Request, etag: str) -> bool:
    response.headers["ETag"] = f'"{etag}"'
    response.headers["Cache-Control"] = "public, max-age=60"
    return request.headers.get("if-none-match") == f'"{etag}"'


def _source(snap, sid):
    s = snap.source(sid)
    return None if s is None else {"id": s.id, "title": s.title, "authors": s.authors, "year": s.year,
                                   "kind": s.kind, "url": s.url, "doi": s.doi,
                                   "verification_status": s.verification_status}


# ------------------------------------------------------------------ salud
@router.get("/health/live", tags=["health"])
def live() -> dict:
    return {"status": "ok"}


@router.get("/health/ready", tags=["health"])
def ready(request: Request, st: AppState = Depends(get_state)) -> dict:
    loaded = st.current()
    return {
        "status": "ok", "api_version": __version__, "engine_version": ENGINE_VERSION,
        "dataset_version": loaded.snapshot.dataset_version, "dataset_checksum": loaded.checksum,
        "dataset_contains_unreviewed_content": loaded.snapshot.contains_unreviewed_content,
        "dataset_origin": loaded.origin, "environment": st.settings.ferrolab_env,
        "database": st.repo is not None, "ai_enabled": request.app.state.tutor.ai_configured,
        "admin_available": st.repo is not None, "admin_dev_login": st.settings.dev_login_allowed,
        "supabase_url": st.settings.supabase_url, "supabase_anon_key": st.settings.supabase_anon_key,
    }


# ------------------------------------------------------------------ catálogo
def _composition_source(snap, evidence_id: str):
    ev = snap.evidence_by_id(evidence_id)
    return _source(snap, ev.source_id) if ev else None


def _material_out(snap, m, loc: str) -> dict:
    conds = snap.conditions_for(m.id)
    return {
        "id": m.id, "display_name": m.display_name, "family": m.family,
        "standard_note": _l(m, "standard_note", loc), "description": _l(m, "description", loc),
        "limitations": _l(m, "limitations", loc), "review_status": m.review_status,
        "compositions": [{**c.model_dump(), "source": _composition_source(snap, c.evidence_id)} for c in m.compositions],
        "initial_conditions": [{"id": c.id, "name": _l(c, "name", loc), "description": _l(c, "description", loc),
                                "hardened": c.hardened, "carburized": c.carburized, "matrix": c.matrix,
                                "graphite_morphology": c.graphite_morphology, "review_status": c.review_status}
                               for c in conds],
        "suggested_sources": [x for x in (_source(snap, s) for s in m.suggested_source_ids) if x],
    }


@router.get("/materials", tags=["catalog"], dependencies=[read_limit])
def materials(request: Request, response: Response, locale: str = Depends(locale_q), st: AppState = Depends(get_state)):
    loaded = st.current()
    if _cache(response, request, f"{loaded.checksum[:16]}-m-{locale}"):
        return Response(status_code=304, headers={"ETag": response.headers["ETag"]})
    snap = loaded.snapshot
    return {"dataset_version": snap.dataset_version, "contains_unreviewed_content": snap.contains_unreviewed_content,
            "items": [_material_out(snap, m, locale) for m in snap.materials]}


@router.get("/materials/{material_id}", tags=["catalog"], dependencies=[read_limit])
def material(material_id: str, locale: str = Depends(locale_q), st: AppState = Depends(get_state)):
    snap = st.current().snapshot
    m = snap.material(material_id)
    if m is None:
        raise ApiError(404, "not_found", "Material inexistente o no publicado")
    return _material_out(snap, m, locale)


@router.get("/treatments", tags=["catalog"], dependencies=[read_limit])
def treatments(locale: str = Depends(locale_q), st: AppState = Depends(get_state)):
    snap = st.current().snapshot
    return {"items": [{
        "id": t.id, "name": _l(t, "name", locale), "purpose": _l(t, "purpose", locale),
        "prerequisites": _l(t, "prerequisites", locale), "qualitative_outcome": _l(t, "qualitative_outcome", locale),
        "stage_outline": [{"kind": s.kind, "label": localize(STAGE_LABELS, s.label_key, locale), "user_hold": s.user_hold}
                          for s in t.stage_outline],
        "review_status": t.review_status,
        "suggested_sources": [x for x in (_source(snap, s) for s in t.suggested_source_ids) if x],
    } for t in snap.treatments]}


@router.get("/materials/{material_id}/treatments", tags=["catalog"], dependencies=[read_limit])
def material_treatments(material_id: str, locale: str = Depends(locale_q), st: AppState = Depends(get_state)):
    loaded = st.current()
    snap = loaded.snapshot
    if snap.material(material_id) is None:
        raise ApiError(404, "not_found", "Material inexistente o no publicado")
    out = []
    for t in snap.treatments:
        pair = snap.pair(material_id, t.id)
        req = SimulationRequest(material_id=material_id, treatment_id=t.id, target_temperature_c=20, hold_time_min=0,
                                locale=locale)  # solo para dominios/protocolo; no es una simulación
        report = loaded.engine.validate(req)
        proto = snap.protocol(pair.protocol_id) if pair else None
        out.append({
            "treatment_id": t.id, "name": _l(t, "name", locale),
            "compatibility_status": pair.compatibility_status if pair else "unsupported",
            "reason": _l(pair, "reason", locale) if pair else None,
            "quantitative_outputs_enabled": bool(pair and pair.quantitative_outputs_enabled),
            "review_status": pair.review_status if pair else None,
            "required_initial_state": pair.required_initial_state if pair else {},
            "temperature_domain": report.temperature_domain.model_dump(),
            "hold_domain": report.hold_domain.model_dump(),
            "physical_limit_c": report.physical_limit_c,
            "protocol": None if proto is None else {
                "id": proto.id, "version": proto.version, "review_status": proto.review_status,
                "medium": _l(proto, "medium", locale), "medium_documented": proto.medium_evidence_id is not None,
                "fully_specified": proto.is_fully_specified,
                "stages": [{"kind": s.kind, "label": localize(STAGE_LABELS, s.label_key, locale),
                            "user_hold": s.duration_mode == "user_hold"} for s in proto.stages],
            },
        })
    return {"material_id": material_id, "dataset_version": snap.dataset_version,
            "interface": snap.interface.model_dump(), "items": out}


# ------------------------------------------------------------------ simulación
def _to_req(body: SimulationCreate) -> SimulationRequest:
    return SimulationRequest(**body.model_dump())


@router.post("/simulations/validate", tags=["simulation"], dependencies=[sim_limit])
def validate(body: SimulationCreate, st: AppState = Depends(get_state)):
    return st.current().engine.validate(_to_req(body))


@router.post("/simulations", tags=["simulation"], dependencies=[sim_limit])
def simulate(body: SimulationCreate, request: Request, st: AppState = Depends(get_state)):
    loaded = st.current()
    result = loaded.engine.simulate(_to_req(body))
    micro = None
    warnings = list(result.warnings)
    if result.simulation_status not in ("invalid_input", "unsupported"):
        found = mg.select(loaded.snapshot, body.material_id, body.treatment_id, result.input.initial_condition_id)
        if found is None:
            warnings.append(FseWarning(code="NO_SUITABLE_MICROGRAPH", severity="info",
                                       message_key="scientific.no_suitable_micrograph",
                                       message=localize(MESSAGES, "NO_SUITABLE_MICROGRAPH", body.locale)))
        else:
            micro = mg.public_micrograph(found, body.locale)
    return result.model_copy(update={"request_id": request.state.request_id, "micrograph": micro,
                                     "warnings": warnings})


# ------------------------------------------------------------------ contenidos
@router.get("/micrographs/{micrograph_id}", tags=["media"], dependencies=[read_limit])
def micrograph(micrograph_id: str, locale: str = Depends(locale_q), st: AppState = Depends(get_state)):
    snap = st.current().snapshot
    m = next((x for x in snap.micrographs if x.id == micrograph_id and mg.is_public(x)), None)
    if m is None:
        raise ApiError(404, "not_found", "Micrografía inexistente o sin licencia verificada")
    return mg.public_micrograph(m, locale)


@router.get("/micrographs", tags=["media"], dependencies=[read_limit])
def micrographs(locale: str = Depends(locale_q), st: AppState = Depends(get_state)):
    snap = st.current().snapshot
    return {"items": [mg.public_micrograph(m, locale) for m in snap.micrographs if mg.is_public(m)]}


def _k(snap, k, loc):
    return {"slug": k.slug, "category": k.category, "title": _l(k, "title", loc), "body": _l(k, "body", loc),
            "related_slugs": k.related_slugs, "review_status": k.review_status,
            "suggested_sources": [x for x in (_source(snap, s) for s in k.suggested_source_ids) if x]}


@router.get("/knowledge", tags=["knowledge"], dependencies=[read_limit])
def knowledge(locale: str = Depends(locale_q), category: str | None = None, st: AppState = Depends(get_state)):
    snap = st.current().snapshot
    return {"items": [_k(snap, k, locale) for k in snap.knowledge if category in (None, k.category)]}


@router.get("/knowledge/{slug}", tags=["knowledge"], dependencies=[read_limit])
def knowledge_entry(slug: str, locale: str = Depends(locale_q), st: AppState = Depends(get_state)):
    snap = st.current().snapshot
    k = next((x for x in snap.knowledge if x.slug == slug), None)
    if k is None:
        raise ApiError(404, "not_found", "Entrada inexistente")
    return _k(snap, k, locale)


@router.get("/practice", tags=["knowledge"], dependencies=[read_limit])
def practice(locale: str = Depends(locale_q), st: AppState = Depends(get_state)):
    snap = st.current().snapshot
    return {"items": [{"id": q.id, "prompt": _l(q, "prompt", locale), "options": _l(q, "options", locale),
                       "correct_index": q.correct_index, "feedback": _l(q, "feedback", locale),
                       "related_slug": q.related_slug, "review_status": q.review_status}
                      for q in snap.practice_questions]}


@router.get("/sources", tags=["knowledge"], dependencies=[read_limit])
def sources(st: AppState = Depends(get_state)):
    snap = st.current().snapshot
    return {"items": [{**s.model_dump(mode="json")} for s in snap.sources]}


# ------------------------------------------------------------------ tutor
@router.post("/tutor/explain", tags=["tutor"], dependencies=[tutor_limit])
def tutor_explain(body: TutorExplain, request: Request, st: AppState = Depends(get_state)):
    loaded = st.current()
    result = loaded.engine.simulate(_to_req(body.simulation))  # el backend recalcula; no confía en JSON del cliente
    return request.app.state.tutor.answer(loaded.snapshot, body.locale, None, result)


@router.post("/tutor/ask", tags=["tutor"], dependencies=[tutor_limit])
def tutor_ask(body: TutorAsk, request: Request, st: AppState = Depends(get_state)):
    loaded = st.current()
    result = loaded.engine.simulate(_to_req(body.simulation)) if body.simulation else None
    return request.app.state.tutor.answer(loaded.snapshot, body.locale, body.question, result)

