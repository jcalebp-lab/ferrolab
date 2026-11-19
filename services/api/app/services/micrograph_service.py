"""Selector de micrografías autorizadas (doc 04 §5.7). Nunca inventa correspondencias."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from ferrolab_fse.enums import MatchQuality, ReviewStatus
from ferrolab_fse.snapshot import DatasetSnapshot, Micrograph

MEDIA_DIR = Path(__file__).resolve().parents[1] / "static" / "micrographs"


def public_micrograph(m: Micrograph, locale: str) -> dict[str, Any]:
    return {
        "id": m.id, "image_url": m.image_url, "material_id": m.material_id, "treatment_id": m.treatment_id,
        "author": m.author, "attribution": m.attribution, "license_code": m.license_code, "license_url": m.license_url,
        "source_id": m.source_id, "magnification_x": m.magnification_x, "scale_bar_um": m.scale_bar_um,
        "pixel_size_um": m.pixel_size_um, "preparation": m.preparation, "imaging_method": m.imaging_method,
        "match_quality": m.match_quality, "constituents": m.constituents, "review_status": m.review_status,
        "alt": m.alt_en if locale == "en" else m.alt_es,
        "specimen": m.specimen_en if locale == "en" else m.specimen_es, "family": m.family,
        "page_url": m.page_url, "thumbnail_url": m.thumbnail_url, "license_verified": m.license_verified,
        # Copia redimensionada servida por FERROLAB (evita depender del servidor de la fuente en cada visita).
        "display_url": f"/media/micrographs/{m.id}.jpg" if (MEDIA_DIR / f"{m.id}.jpg").exists() else None,
        "calibrated": m.scale_bar_um is not None or m.pixel_size_um is not None,
    }


def is_public(m: Micrograph, snap: DatasetSnapshot | None = None) -> bool:
    """Solo con licencia verificada. Publicada, o en borrador dentro de una release de desarrollo (que se muestra con
    el aviso de contenido no revisado); una release oficial nunca contiene borradores."""
    if not m.license_verified:
        return False
    if m.review_status == ReviewStatus.PUBLISHED:
        return True
    return snap is not None and snap.contains_unreviewed_content and m.review_status == ReviewStatus.DRAFT


# Constituyentes que la literatura asocia a cada tratamiento (para mostrar ejemplos aun sin cálculo).
EXPECTED_STEEL = {
    "quench": {"martensite": 1.0}, "martemper": {"martensite": 1.0},
    "temper": {"tempered_martensite": 1.0}, "quench_temper": {"tempered_martensite": 1.0}, "austemper": {"bainite": 1.0},
    "anneal": {"proeutectoid_ferrite": 0.5, "pearlite": 0.5}, "normalize": {"proeutectoid_ferrite": 0.5, "pearlite": 0.5},
}
GRAY_MATRIX_CONSTITUENT = {"martensite": "martensite", "tempered_martensite": "tempered_martensite",
                           "ausferrite": "ausferrite", "ferrite_pearlite": "proeutectoid_ferrite", "pearlite": "pearlite"}


def related(snap: DatasetSnapshot, family: str, weights: dict[str, float], limit: int = 6,
            other_families: bool = False) -> list[Micrograph]:
    """Ejemplos REALES de los constituyentes (otras muestras), ordenados por la fracción que representan.

    Nunca se presentan como la probeta del estudiante. Con `other_families` se aceptan muestras de otra familia
    (p. ej. matriz martensítica de un acero para una fundición templada) por detrás de las de la misma familia.
    """
    pool = [m for m in snap.micrographs if is_public(m, snap)
            and (other_families or (m.family or "steel") == family)]
    # Una cola por constituyente (de mayor a menor fracción); dentro de cada cola, misma familia y óptica primero.
    queues = []
    for c, _w in sorted(weights.items(), key=lambda kv: (-kv[1], kv[0])):
        q = sorted((m for m in pool if c in m.constituents),
                   key=lambda m: ((m.family or "steel") != family, m.imaging_method != "optical", m.id))
        if q:
            queues.append(q)
    out: list[Micrograph] = []
    seen: set[str] = set()
    while queues and len(out) < limit:  # turno rotatorio: todos los constituyentes quedan ilustrados
        for q in list(queues):
            while q and q[0].id in seen:
                q.pop(0)
            if not q:
                queues.remove(q)
                continue
            m = q.pop(0)
            seen.add(m.id)
            out.append(m)
            if len(out) >= limit:
                break
    return out


def weights_for(illustration: dict, treatment_id: str) -> tuple[str, dict[str, float]]:
    """Constituyentes a ilustrar: los calculados (fracciones ≥ 3 %) o, sin cálculo, los esperados del tratamiento."""
    family = illustration.get("family", "steel")
    if family == "gray_cast_iron":
        matrix = GRAY_MATRIX_CONSTITUENT.get(illustration.get("matrix") or "", "pearlite")
        w = {"graphite_flakes": 1.0, matrix: 0.8}
        if matrix == "proeutectoid_ferrite":
            w["pearlite"] = 0.6
        return family, w
    fr = illustration.get("fractions") or {}
    w = {("tempered_martensite" if k == "martensite" and illustration.get("tempered") else k): float(v)
         for k, v in fr.items() if v >= 0.03 and k != "retained_austenite"}
    for c, v in EXPECTED_STEEL.get(treatment_id, {}).items():  # lo que busca el tratamiento, aunque no se forme
        w[c] = max(w.get(c, 0.0), 0.35 * v)
    return family, w


def select(snap: DatasetSnapshot, material_id: str, treatment_id: str, ic_id: str | None) -> Micrograph | None:
    """Coincidencia exacta > comparable. Ilustrativas o sin coincidencia: no se asignan al experimento."""
    cands = [m for m in snap.micrographs if is_public(m, snap) and m.material_id == material_id
             and m.treatment_id == treatment_id and m.match_quality in (MatchQuality.EXACT, MatchQuality.COMPARABLE)
             and (m.initial_condition_id in (None, ic_id))]
    cands.sort(key=lambda m: (m.match_quality != MatchQuality.EXACT, m.id))
    return cands[0] if cands else None
