"""Genera docs/PROTOCOLOS.md: matriz de las 18 combinaciones y lista de protocolos con cifras y fuentes."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "packages" / "fse"))
from ferrolab_fse import DatasetSnapshot, ScientificEngine  # noqa: E402
from ferrolab_fse import protocol_runtime as PR  # noqa: E402
from ferrolab_fse.engine import SimulationRequest  # noqa: E402

snap = DatasetSnapshot.model_validate(json.loads((ROOT / "database/seeds/catalog_seed.json").read_text("utf-8")))
eng = ScientificEngine(snap)
MAT = {"aisi_1045": "AISI 1045", "aisi_8620": "AISI 8620", "en_gjl_250": "GG25 (EN-GJL-250)"}
TR = {"quench": "Temple", "temper": "Revenido", "anneal": "Recocido", "normalize": "Normalizado",
      "austemper": "Austempering", "martemper": "Martempering", "quench_temper": "Bonificado"}
COMPAT = {"supported": "Compatible", "conditional": "Condicional", "educational_only": "Educativo", "unsupported": "No"}
LEVEL = {"A": "A (modelo publicado)", "B": "B (cualitativo)", "C": "C (ilustrativo)"}


def fmt(v, unit):
    return "—" if v is None else f"{v:g} {unit}"


def rng(p):
    if p is None:
        return "—"
    if p.min is None and p.max is None:
        return {"pending": "sin cifra en la fuente", "computed": "hasta igualar (modelo)", "model": "calculado"}.get(p.basis, "—")
    lo = "" if p.min is None else f"{p.min:g}"
    hi = "" if p.max is None else f"{p.max:g}"
    s = lo if lo == hi else f"{lo}–{hi}".strip("–")
    return f"{s} {p.unit}" + (" (modelo)" if p.basis == "model" else "")


out = ["# Biblioteca de protocolos térmicos — matriz de 18 combinaciones",
       "",
       "Generado por `scripts/gen_protocol_matrix.py` a partir del catálogo (`database/seeds/catalog_seed.json`).",
       "Probeta de referencia educativa: cilindro de 12,7 mm. «Modelo» = valor calculado por FERROLAB (no publicado).",
       "",
       "## Matriz", "",
       "| Tratamiento | " + " | ".join(MAT.values()) + " |", "|---|---|---|---|"]
for t, tn in TR.items():
    cells = []
    for m in MAT:
        pair = snap.pair(m, t)
        ref = PR.choose(snap, m, t, None)
        r = PR.resolve(snap, ref, furnace_c=0, hold_s=0, use_reference=True)
        fu, ho = r.params.get("furnace_temperature"), r.params.get("hold_time")
        req = SimulationRequest(material_id=m, treatment_id=t, target_temperature_c=(fu.value if fu and fu.value else (fu.max if fu and fu.max else 500)),
                                hold_time_min=(ho.value if ho and ho.value else 30))
        res = eng.simulate(req)
        n = len(snap.protocols_for(m, t))
        cells.append(f"{COMPAT[pair.compatibility_status.value]} · {LEVEL[res.result_level]} · {n} protocolo(s)")
    out.append(f"| {tn} | " + " | ".join(cells) + " |")
out += ["", "Nivel A: hay modelo publicado para el acero y el protocolo está documentado (cifras con banda, pendientes de "
        "validación por especialista). B: interpretación cualitativa (fundición gris, capas cementadas). C: demostración "
        "ilustrativa (fuente no verificada o revenido sin estado previo).", "", "## Protocolos", ""]
for pr in snap.protocols:
    r = PR.resolve(snap, pr, furnace_c=0, hold_s=0, use_reference=True)
    srcs = "; ".join(f"{s.title} ({'verificada' if s.verification_status == 'verified' else 'NO verificada'})"
                     for s in (snap.source(x) for x in pr.source_ids))
    out.append(f"### {MAT[pr.material_id.value]} — {TR[pr.treatment_id.value]}: {pr.name_es}"
               + (" **[referencia]**" if pr.is_reference else ""))
    out.append("")
    out.append(f"- Id: `{pr.id}` · versión {pr.version} · estado de evidencia: `{pr.evidence_status}` · revisión: `{pr.review_status.value}`")
    out.append(f"- Objetivo: {pr.objective_es}")
    if pr.material_condition_es:
        out.append(f"- Condición del material: {pr.material_condition_es}")
    p = r.params
    out.append(f"- Horno: {rng(p.get('furnace_temperature'))} · sostenimiento: {rng(p.get('hold_time'))}"
               + (f" · baño: {rng(p.get('bath_temperature'))} · tiempo de baño: {rng(p.get('bath_time'))}" if "bath_temperature" in p else ""))
    out.append(f"- Medio: {pr.medium_es}")
    out.append("- Etapas: " + " → ".join(s.role or s.kind.value for s in pr.stages))
    if pr.published_results:
        out.append("- Resultados publicados del caso: " + "; ".join(x["text_es"] for x in pr.published_results))
    if pr.missing_es:
        out.append("- Pendiente: " + " ".join(pr.missing_es))
    out.append(f"- Fuentes: {srcs}")
    out.append("")
(ROOT / "docs" / "PROTOCOLOS.md").write_text("\n".join(out) + "\n", encoding="utf-8")
print("OK -> docs/PROTOCOLOS.md", len(snap.protocols), "protocolos")
