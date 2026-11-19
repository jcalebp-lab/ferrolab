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


def related(snap: DatasetSnapshot, family: str, constituents: list[str], limit: int = 6) -> list[Micrograph]:
    """Ejemplos REALES de los constituyentes calculados (otras muestras). Nunca se presentan como la del estudiante."""
    want = set(constituents)
    scored = []
    for m in snap.micrographs:
        if not is_public(m, snap) or (m.family or "steel") != family:
            continue
        overlap = len(want & set(m.constituents))
        if overlap:
            scored.append((-overlap, m.imaging_method != "optical", m.id, m))
    return [x[-1] for x in sorted(scored)[:limit]]


def select(snap: DatasetSnapshot, material_id: str, treatment_id: str, ic_id: str | None) -> Micrograph | None:
    """Coincidencia exacta > comparable. Ilustrativas o sin coincidencia: no se asignan al experimento."""
    cands = [m for m in snap.micrographs if is_public(m, snap) and m.material_id == material_id
             and m.treatment_id == treatment_id and m.match_quality in (MatchQuality.EXACT, MatchQuality.COMPARABLE)
             and (m.initial_condition_id in (None, ic_id))]
    cands.sort(key=lambda m: (m.match_quality != MatchQuality.EXACT, m.id))
    return cands[0] if cands else None
