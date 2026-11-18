"""Selector de micrografías autorizadas (doc 04 §5.7). Nunca inventa correspondencias."""

from __future__ import annotations

from typing import Any

from ferrolab_fse.enums import MatchQuality, ReviewStatus
from ferrolab_fse.snapshot import DatasetSnapshot, Micrograph


def public_micrograph(m: Micrograph, locale: str) -> dict[str, Any]:
    return {
        "id": m.id, "image_url": m.image_url, "material_id": m.material_id, "treatment_id": m.treatment_id,
        "author": m.author, "attribution": m.attribution, "license_code": m.license_code, "license_url": m.license_url,
        "source_id": m.source_id, "magnification_x": m.magnification_x, "scale_bar_um": m.scale_bar_um,
        "pixel_size_um": m.pixel_size_um, "preparation": m.preparation, "imaging_method": m.imaging_method,
        "match_quality": m.match_quality, "constituents": m.constituents, "review_status": m.review_status,
        "alt": m.alt_en if locale == "en" else m.alt_es,
        "calibrated": m.scale_bar_um is not None or m.pixel_size_um is not None,
    }


def is_public(m: Micrograph) -> bool:
    return m.review_status == ReviewStatus.PUBLISHED and m.license_verified


def select(snap: DatasetSnapshot, material_id: str, treatment_id: str, ic_id: str | None) -> Micrograph | None:
    """Coincidencia exacta > comparable. Ilustrativas o sin coincidencia: no se asignan al experimento."""
    cands = [m for m in snap.micrographs if is_public(m) and m.material_id == material_id
             and m.treatment_id == treatment_id and m.match_quality in (MatchQuality.EXACT, MatchQuality.COMPARABLE)
             and (m.initial_condition_id in (None, ic_id))]
    cands.sort(key=lambda m: (m.match_quality != MatchQuality.EXACT, m.id))
    return cands[0] if cands else None
