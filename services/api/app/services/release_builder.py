"""Construye un `DatasetSnapshot` publicable a partir de filas editoriales.

* Release oficial: solo filas `reviewed`/`published`. Las referencias a registros
  no revisados se eliminan del snapshot (y se informan); nunca se rellenan.
* Release de desarrollo: incluye borradores y queda marcada
  `contains_unreviewed_content=true` (la API la rechaza en producción).
"""

from __future__ import annotations

import copy
from typing import Any

from ferrolab_fse import DatasetSnapshot
from ferrolab_fse.enums import MaterialId, TreatmentId
from pydantic import ValidationError

OFFICIAL = {"reviewed", "published"}
DEV = {"draft", "reviewed", "published"}


class ReleaseBuildError(ValueError):
    def __init__(self, problems: list[str]) -> None:
        super().__init__("; ".join(problems))
        self.problems = problems


def build_snapshot(rows: dict[str, list[dict[str, Any]]], *, version: str, include_drafts: bool,
                   interface: dict | None = None) -> tuple[DatasetSnapshot, list[str]]:
    d = copy.deepcopy(rows)
    report: list[str] = []
    problems: list[str] = []
    src_ids = {s["id"] for s in d.get("sources", [])}
    kept_ev = []
    for e in d.get("evidence", []):
        if e["source_id"] in src_ids:
            kept_ev.append(e)
        else:
            report.append(f"evidencia {e['id']} omitida: fuente no revisada")
    d["evidence"] = kept_ev
    ev_ids = {e["id"] for e in kept_ev}

    mats = {m["id"] for m in d.get("materials", [])}
    trts = {t["id"] for t in d.get("treatments", [])}
    if len(mats) != len(MaterialId):
        problems.append(f"Los {len(MaterialId)} materiales deben estar revisados antes de publicar")
    if len(trts) != len(TreatmentId):
        problems.append(f"Los {len(TreatmentId)} tratamientos deben estar revisados antes de publicar")

    for m in d.get("materials", []):
        keep = [c for c in m.get("compositions", []) if c["evidence_id"] in ev_ids]
        if len(keep) != len(m.get("compositions", [])):
            report.append(f"{m['id']}: composiciones sin evidencia revisada omitidas")
        m["compositions"] = keep
        m["suggested_source_ids"] = [s for s in m.get("suggested_source_ids", []) if s in src_ids]
    for t in d.get("treatments", []):
        t["suggested_source_ids"] = [s for s in t.get("suggested_source_ids", []) if s in src_ids]
    for k in d.get("knowledge", []):
        k["suggested_source_ids"] = [s for s in k.get("suggested_source_ids", []) if s in src_ids]

    d["initial_conditions"] = [c for c in d.get("initial_conditions", []) if c["material_id"] in mats]
    for c in d["initial_conditions"]:
        if c.get("source_id") and c["source_id"] not in src_ids:
            c["source_id"] = None

    prots = []
    for p in d.get("protocols", []):
        bad = [s for s in p["stages"] for e in (s.get("end_temperature_evidence_id"), s.get("duration_evidence_id"))
               if e and e not in ev_ids]
        if bad or p["material_id"] not in mats or p["treatment_id"] not in trts:
            report.append(f"protocolo {p['id']} omitido: depende de evidencia o catálogo no revisado")
            continue
        if p.get("medium_evidence_id") and p["medium_evidence_id"] not in ev_ids:
            p["medium_evidence_id"] = None
        prots.append(p)
    d["protocols"] = prots
    prot_ids = {p["id"] for p in prots}

    pairs = []
    for mt in d.get("material_treatments", []):
        if mt["material_id"] not in mats or mt["treatment_id"] not in trts:
            continue
        if mt.get("protocol_id") and mt["protocol_id"] not in prot_ids:
            report.append(f"{mt['material_id']}/{mt['treatment_id']}: protocolo no revisado, se publica sin protocolo")
            mt["protocol_id"] = None
        for lo, hi, ev in (("temperature_min_c", "temperature_max_c", "temperature_evidence_id"),
                           ("hold_min_s", "hold_max_s", "hold_evidence_id")):
            if mt.get(ev) and mt[ev] not in ev_ids:
                report.append(f"{mt['material_id']}/{mt['treatment_id']}: rango sin evidencia revisada omitido")
                mt[lo] = mt[hi] = mt[ev] = None
        if mt.get("quantitative_outputs_enabled") and mt.get("protocol_id") is None:
            mt["quantitative_outputs_enabled"] = False
            report.append(f"{mt['material_id']}/{mt['treatment_id']}: salidas numéricas desactivadas (sin protocolo)")
        pairs.append(mt)
    d["material_treatments"] = pairs
    n_pairs = len(MaterialId) * len(TreatmentId)
    if len(pairs) != n_pairs and not problems:
        problems.append(f"Se esperaban {n_pairs} parejas revisadas, hay {len(pairs)}")

    guards = [g for g in d.get("physical_guards", []) if g["evidence_id"] in ev_ids]
    families = {g["applies_to_family"] for g in guards}
    if families != {"steel", "gray_cast_iron"}:
        problems.append("Los límites físicos de seguridad (y su evidencia) deben revisarse antes de publicar")
    d["physical_guards"] = guards

    mvs = []
    for mv in d.get("model_versions", []):
        if any(e not in ev_ids for e in mv.get("parameter_evidence_ids", {}).values()):
            report.append(f"modelo {mv['id']} omitido: parámetros sin evidencia revisada")
            continue
        mvs.append(mv)
    d["model_versions"] = mvs
    d["micrographs"] = [m for m in d.get("micrographs", []) if m["source_id"] in src_ids
                        and m["material_id"] in mats and (include_drafts or m.get("license_verified"))]
    if problems:
        raise ReleaseBuildError(problems)

    d["dataset_version"] = version
    d["contains_unreviewed_content"] = include_drafts and _has_drafts(rows)
    if interface:
        d["interface"] = interface
    for coll in d.values():
        if isinstance(coll, list):
            for item in coll:
                if isinstance(item, dict):
                    item.pop("_meta", None)
                    # En una release oficial todo lo incluido queda publicado por esta misma release.
                    if not include_drafts and item.get("review_status") == "reviewed":
                        item["review_status"] = "published"
    try:
        return DatasetSnapshot.model_validate(d), report
    except ValidationError as exc:
        raise ReleaseBuildError([f"{'.'.join(map(str, e['loc']))}: {e['msg']}" for e in exc.errors()]) from exc


def _has_drafts(rows: dict[str, list[dict]]) -> bool:
    return any(item.get("review_status") == "draft" for coll in rows.values() for item in coll)
