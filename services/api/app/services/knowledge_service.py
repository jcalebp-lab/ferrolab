"""Artículos científicos como fuente de conocimiento (D-40).

Cada ficha de la categoría `research` declara su ámbito (materiales, tratamientos, constituyentes y palabras clave).
Con él se eligen los artículos que respaldan un resultado de simulación o una pregunta al tutor. Solo se usan fichas
cuyas fuentes son artículos de acceso libre verificados.
"""

from __future__ import annotations

import re
import unicodedata
from typing import Any

from ferrolab_fse.snapshot import DatasetSnapshot, KnowledgeEntry


def norm(s: str) -> str:
    s = unicodedata.normalize("NFKD", s.lower())
    return "".join(c for c in s if not unicodedata.combining(c))


def _has_keyword(words: str, kw: str) -> bool:
    """Palabra clave como palabra o prefijo de palabra («austeniz» casa con «austenizar»), nunca dentro de otra
    («li» no casa con «aplica» ni con «límite»)."""
    k = norm(kw)
    if not k or not words:
        return False
    tail = "" if len(k) >= 5 else r"\b"  # las claves cortas deben ser palabra completa
    return re.search(rf"\b{re.escape(k)}{tail}", words) is not None


def articles(snap: DatasetSnapshot) -> list[KnowledgeEntry]:
    out = []
    for k in snap.knowledge:
        if k.category != "research":
            continue
        srcs = [snap.source(s) for s in k.suggested_source_ids]
        if any(s is not None and s.kind == "article" and s.verification_status == "verified" for s in srcs):
            out.append(k)
    return out


def _score(k: KnowledgeEntry, material_id: str | None, treatment_id: str | None, constituents: set[str],
           words: str) -> int:
    score = 0
    if material_id is not None:
        if k.materials and material_id not in k.materials:
            return 0  # artículo de otro material: no respalda este resultado
        score += 2 if material_id in k.materials else 0
    if treatment_id is not None and treatment_id in k.treatments:
        score += 3 + (2 if len(k.treatments) <= 3 else 0)  # un artículo centrado en el tratamiento pesa más
    score += len(constituents & set(k.constituents))
    if words:
        score += 2 * sum(1 for kw in k.keywords if _has_keyword(words, kw))
    return score


def related(snap: DatasetSnapshot, *, material_id: str | None = None, treatment_id: str | None = None,
            constituents: set[str] | None = None, text: str | None = None, limit: int = 4) -> list[KnowledgeEntry]:
    """Artículos ordenados por pertinencia; exige coincidir en tratamiento o en palabras de la pregunta."""
    words = norm(text or "")
    cons = constituents or set()
    scored = []
    for k in articles(snap):
        sc = _score(k, material_id, treatment_id, cons, words)
        relevant = (treatment_id is not None and treatment_id in k.treatments) or (
            words and any(_has_keyword(words, kw) for kw in k.keywords))
        if sc > 0 and relevant:
            scored.append((-sc, k.slug, k))
    return [k for *_, k in sorted(scored)[:limit]]


# Fin de oración: punto, ! o ? seguido de espacio, salvo abreviaturas («et al.», «p. ej.», «e.g.», «i.e.», «aprox.»).
_SENTENCE = re.compile(r"(?<!\bal\.)(?<!\bej\.)(?<!\be\.g\.)(?<!\bi\.e\.)(?<!\baprox\.)(?<!\bp\.)(?<=[.!?])\s+(?=[A-ZÁÉÍÓÚÑ(«])")


def summary(text: str, max_chars: int = 260) -> str:
    """Primera(s) oración(es) del resumen, sin cortar palabras."""
    out = ""
    for sent in _SENTENCE.split(text.strip()):
        if out and len(out) + len(sent) + 1 > max_chars:
            break
        out = f"{out} {sent}".strip()
    return out if len(out) <= max_chars else out[: max_chars - 1].rsplit(" ", 1)[0] + "…"


def source_dict(snap: DatasetSnapshot, sid: str) -> dict[str, Any] | None:
    s = snap.source(sid)
    return None if s is None else {"id": s.id, "title": s.title, "authors": s.authors, "year": s.year, "kind": s.kind,
                                   "url": s.url, "doi": s.doi, "edition": s.edition,
                                   "verification_status": s.verification_status}


def public_article(snap: DatasetSnapshot, k: KnowledgeEntry, locale: str) -> dict[str, Any]:
    body = k.body_en if locale == "en" else k.body_es
    return {"slug": k.slug, "title": k.title_en if locale == "en" else k.title_es, "summary": summary(body),
            "sources": [x for x in (source_dict(snap, s) for s in k.suggested_source_ids) if x]}
