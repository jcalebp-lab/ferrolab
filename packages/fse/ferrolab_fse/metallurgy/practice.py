"""Cadena completa de una práctica: ciclo térmico → austenización → descomposición → fases → dureza.

Todo es determinista. Las cifras resultantes son ESTIMACIONES DE MODELOS EMPÍRICOS publicados
(ver data.SOURCES); FERROLAB las etiqueta como `modeled` / `bounded_estimate` y nunca como medidas.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from . import kinetics as kin
from .cooling import Medium, Runner, medium, rate_at, thin
from .critical import critical_temperatures
from .data import (
    ASSUMPTIONS,
    C_CEMENTITE,
    COMPOSITION_RANGES,
    GROSSMANN_H_RANGE,
    KANG_LEE_HOLD_RANGE_S,
    KANG_LEE_T_RANGE_C,
)
from .hardness import mixture_hv, tempered_mixture_hv
from .recommend import recommendation

MODEL_VERSION = "ferrolab_metallurgy@1.0.0"
MODEL_SOURCES = ("src_li_1998", "src_collins_2023", "src_km_1959", "src_maynier_1978", "src_andrews_1965",
                 "src_grange_1961", "src_grossmann", "src_kang_lee_2014")
DEFAULT_MEDIUM = {"aisi_1045": "water", "aisi_8620": "oil"}


def compositions(material_id: str) -> dict[str, dict[str, float]] | None:
    rng = COMPOSITION_RANGES.get(material_id)
    if rng is None:
        return None
    return {
        "nominal": {k: (a + b) / 2 for k, (a, b) in rng.items()},
        "low": {k: a for k, (a, _b) in rng.items()},
        "high": {k: b for k, (_a, b) in rng.items()},
    }


@dataclass
class Practice:
    material_id: str
    treatment_id: str
    composition: dict[str, float]
    critical: dict[str, float]
    runner_center: list[tuple[float, float]]
    runner_surface: list[tuple[float, float]]
    segments: list
    max_center_c: float
    austenite_fraction: float
    cooling_start_index: int
    medium_code: str
    bath_c: float | None = None
    fractions: dict[str, float] | None = None
    fractions_range: dict[str, tuple[float, float]] | None = None
    surface_fractions: dict[str, float] | None = None
    phases: dict[str, float] | None = None
    hardness_hv: float | None = None
    hardness_range: tuple[float, float] | None = None
    hardness_surface_hv: float | None = None
    vr_700_k_s: float | None = None
    diagrams: list[dict] = field(default_factory=list)
    notes: list[str] = field(default_factory=list)  # códigos de aviso del modelo
    prior: dict | None = None  # estado de partida (revenido)


def _austenitize(c: dict[str, float], t_max: float) -> tuple[float, float]:
    tm = kin.li_temps(c)
    carbon = c["C"]
    if t_max >= tm.ae3:
        return 1.0, carbon
    if t_max <= tm.ae1:
        return 0.0, carbon
    ca = kin.ae3_carbon_at(c, t_max)
    fa = (carbon - kin.FERRITE_CARBON) / (ca - kin.FERRITE_CARBON)
    return max(0.0, min(1.0, fa)), ca


def _phases(micro: dict[str, float], c: dict[str, float], carbon_austenite: float) -> dict[str, float]:
    """Balance de masa de C: el C que no está en martensita/austenita va a cementita."""
    m = micro["martensite"]
    ra = micro["retained_austenite"]
    rest = 1 - m - ra
    cem = max(0.0, (c["C"] - (m + ra) * carbon_austenite - rest * kin.FERRITE_CARBON) / (C_CEMENTITE - kin.FERRITE_CARBON))
    cem = min(cem, rest)
    return {"ferrite": rest - cem, "cementite": cem, "martensite": m, "austenite": ra}


def _heat_and_hold(r: Runner, target_c: float, hold_s: float, heat_label: str, hold_label: str) -> None:
    furnace = Medium("furnace", target_c)
    r.run("heat", heat_label, furnace, until_center_within=2.0, max_s=2 * 3600)
    if hold_s > 0:
        r.run("hold", hold_label, furnace, duration_s=hold_s)


def _cool(r: Runner, treatment_id: str, medium_code: str, c: dict[str, float], severity_h: float | None = None) -> float | None:
    """Etapas posteriores al mantenimiento. Devuelve la temperatura del baño si existe."""
    air = medium("air")
    transfer = ASSUMPTIONS["transfer_s"]
    stop_c = 60.0
    if treatment_id == "quench":
        r.run("transfer", "transfer_to_medium", air, duration_s=transfer)
        m = medium(medium_code)
        if severity_h is not None:
            m = Medium(m.code, m.temperature_c, severity_h)
        r.run("cool", "quench_cool", m, until_center_within=5.0, max_s=1800)
        return None
    if treatment_id == "normalize":
        r.run("cool", "air_cool", air, until_center_below=stop_c, max_s=4 * 3600)
        return None
    if treatment_id == "anneal":
        r.furnace_cool("anneal_cool", ASSUMPTIONS["furnace_cool_c_per_h"], ASSUMPTIONS["furnace_cool_until_c"])
        r.run("cool", "air_cool", air, until_center_below=stop_c, max_s=4 * 3600)
        return None
    tm = kin.li_temps(c)
    if treatment_id == "austemper":
        bath = round(tm.ms + 40.0)
        r.run("transfer", "transfer_to_bath", air, duration_s=transfer)
        t99 = kin.tau("bainite", 0.99, bath, c, tm, ASSUMPTIONS["astm_grain_size"]) or 3600.0
        r.run("isothermal_hold", "isothermal_bath_hold", medium("salt_bath", bath),
              duration_s=min(max(1.2 * t99, 300.0), 2 * 3600.0))
        r.run("cool", "final_cool", air, until_center_below=stop_c, max_s=4 * 3600)
        return bath
    if treatment_id == "martemper":
        bath = round(tm.ms + 15.0)
        r.run("transfer", "transfer_to_bath", air, duration_s=transfer)
        r.run("isothermal_hold", "equalization_hold", medium("salt_bath", bath), until_center_within=3.0, max_s=1800)
        r.run("cool", "final_cool", air, until_center_below=stop_c, max_s=4 * 3600)
        return bath
    if treatment_id == "temper":
        r.run("cool", "air_cool", air, until_center_below=stop_c, max_s=4 * 3600)
        return None
    raise ValueError(treatment_id)


def _decompose(path, c, fa, ca):
    st = kin.integrate(path, c, ASSUMPTIONS["astm_grain_size"], austenite0=fa, carbon0=ca)
    return kin.final_microstructure(st), st


def run(material_id: str, treatment_id: str, target_c: float, hold_s: float, medium_code: str | None = None) -> Practice:
    comps = compositions(material_id)
    if comps is None:
        raise LookupError(material_id)
    c = comps["nominal"]
    if treatment_id == "temper":
        return _temper(material_id, target_c, hold_s, comps)
    medium_code = medium_code or DEFAULT_MEDIUM.get(material_id, "oil")
    r = Runner(ASSUMPTIONS["ambient_c"])
    heat_lbl = "heat_to_austenitizing"
    _heat_and_hold(r, target_c, hold_s, heat_lbl, "hold_austenitizing")
    i0 = len(r.center) - 1
    bath = _cool(r, treatment_id, medium_code, c)
    run_ = r.result()
    p = Practice(material_id, treatment_id, c, _critical_dict(c), run_.center, run_.surface, run_.segments,
                 run_.max_center_c, 0.0, i0, medium_code if treatment_id == "quench" else
                 {"normalize": "air", "anneal": "furnace"}.get(treatment_id, "salt_bath"), bath)
    path_c = run_.center[i0:]
    path_s = run_.surface[i0:]
    t_max = run_.max_center_c
    fa, ca = _austenitize(c, t_max)
    p.austenite_fraction = fa
    tm = kin.li_temps(c)
    if fa <= 0:
        p.notes.append("MODEL_NO_AUSTENITIZATION")
        p.diagrams = _diagrams(c, t_max, path_c, run_.center[i0][0])
        return p
    if fa < 1:
        p.notes.append("MODEL_INTERCRITICAL")
    if t_max > tm.ae3 + 150:
        p.notes.append("MODEL_OVERHEATING")
    micro, st = _decompose(path_c, c, fa, ca)
    p.fractions = micro
    p.phases = _phases(micro, c, st.carbon_austenite)
    p.surface_fractions, _ = _decompose(path_s, c, fa, ca)
    vr = rate_at(path_c, 700.0)
    if vr is None and treatment_id == "anneal":
        vr = ASSUMPTIONS["furnace_cool_c_per_h"] / 3600
    p.vr_700_k_s = vr
    ranges: dict[str, list[float]] = {k: [v, v] for k, v in micro.items()}
    hvs: list[float] = []
    if vr is not None:
        p.hardness_hv = mixture_hv(micro, c, vr * 3600)
        hvs.append(p.hardness_hv)
        vs = rate_at(path_s, 700.0) or vr
        p.hardness_surface_hv = mixture_hv(p.surface_fractions, c, vs * 3600)
    for key in ("low", "high"):
        ck = comps[key]
        fak, cak = _austenitize(ck, t_max)
        if fak <= 0:
            continue
        mk, _ = _decompose(path_c, ck, fak, cak)
        for k, v in mk.items():
            ranges[k][0] = min(ranges[k][0], v)
            ranges[k][1] = max(ranges[k][1], v)
        if vr is not None:
            hvs.append(mixture_hv(mk, ck, vr * 3600))
    # Banda por severidad del medio (aceite sin agitar → agitado), composición nominal.
    if treatment_id == "quench" and medium_code in GROSSMANN_H_RANGE:
        r2 = Runner(ASSUMPTIONS["ambient_c"])
        _heat_and_hold(r2, target_c, hold_s, heat_lbl, "hold_austenitizing")
        j0 = len(r2.center) - 1
        _cool(r2, treatment_id, medium_code, c, severity_h=GROSSMANN_H_RANGE[medium_code][1])
        path2 = r2.center[j0:]
        m2, _ = _decompose(path2, c, fa, ca)
        for k, v in m2.items():
            ranges[k][0] = min(ranges[k][0], v)
            ranges[k][1] = max(ranges[k][1], v)
        v2 = rate_at(path2, 700.0)
        if v2 is not None:
            hvs.append(mixture_hv(m2, c, v2 * 3600))
        p.notes.append("MODEL_MEDIUM_SEVERITY_RANGE")
    p.fractions_range = {k: (a, b) for k, (a, b) in ranges.items()}
    if hvs:
        p.hardness_range = (min(hvs), max(hvs))
    p.diagrams = _diagrams(c, t_max, path_c, run_.center[i0][0])
    return p


def _temper(material_id: str, target_c: float, hold_s: float, comps) -> Practice:
    """Revenido: estado templado de partida (práctica recomendada de temple, calculado) + ciclo de revenido.
    Dureza revenida: Kang & Lee (2014) sobre la fracción de martensita (ver hardness.tempered_mixture_hv)."""
    c = comps["nominal"]
    rec = recommendation(material_id, "quench")
    prior = run(material_id, "quench", rec.temperature_typical_c, rec.hold_typical_min * 60)
    r = Runner(ASSUMPTIONS["ambient_c"])
    _heat_and_hold(r, target_c, hold_s, "heat_to_temper", "hold_temper")
    i0 = len(r.center) - 1
    _cool(r, "temper", "air", c)
    run_ = r.result()
    p = Practice(material_id, "temper", c, _critical_dict(c), run_.center, run_.surface, run_.segments,
                 run_.max_center_c, 0.0, i0, "air")
    p.prior = {"quench_temperature_c": rec.temperature_typical_c, "quench_hold_min": rec.hold_typical_min,
               "medium": prior.medium_code, "fractions": prior.fractions, "hardness_hv": prior.hardness_hv,
               "hardness_range": prior.hardness_range}
    p.diagrams = prior.diagrams
    tm = kin.li_temps(c)
    if run_.max_center_c >= tm.ae1:
        p.notes.append("MODEL_TEMPER_ABOVE_AE1")
        return p
    lo_t, hi_t = KANG_LEE_T_RANGE_C
    lo_h, hi_h = KANG_LEE_HOLD_RANGE_S
    if not (lo_t <= target_c <= hi_t) or not (lo_h <= hold_s <= hi_h) or not prior.fractions or prior.vr_700_k_s is None:
        p.notes.append("MODEL_TEMPER_OUTSIDE_VALIDITY")
        return p
    f = {k: v for k, v in prior.fractions.items()}
    f["tempered_martensite"] = f.pop("martensite", 0.0)
    p.fractions = f
    p.fractions_range = None if prior.fractions_range is None else {
        ("tempered_martensite" if k == "martensite" else k): v for k, v in prior.fractions_range.items()}
    vr_h = prior.vr_700_k_s * 3600
    p.hardness_hv = tempered_mixture_hv(prior.fractions, c, vr_h, target_c, hold_s)
    hvs = [p.hardness_hv]
    for key in ("low", "high"):
        ck = comps[key]
        fak, cak = _austenitize(ck, prior.max_center_c)
        if fak <= 0:
            continue
        mk, _ = _decompose(prior.runner_center[prior.cooling_start_index:], ck, fak, cak)
        hvs.append(tempered_mixture_hv(mk, ck, vr_h, target_c, hold_s))
    p.hardness_range = (min(hvs), max(hvs))
    p.vr_700_k_s = prior.vr_700_k_s
    p.notes.append("MODEL_TEMPER_KANG_LEE")
    return p


def _critical_dict(c: dict[str, float]) -> dict[str, float]:
    cr = critical_temperatures(c).as_dict()
    tm = kin.li_temps(c)
    cr.update({"ae1_li_c": round(tm.ae1, 1), "ae3_li_c": round(tm.ae3, 1), "bs_li_c": round(tm.bs, 1),
               "ms_model_c": round(tm.ms, 1)})
    return cr


def _diagrams(c, t_max, path_c, t_cool0) -> list[dict]:
    grain = ASSUMPTIONS["astm_grain_size"]
    user = [[round(max(t - t_cool0, 0.01), 3), round(temp, 1)] for t, temp in thin(path_c, 300)]
    ttt = kin.ttt_diagram(c, grain)
    ttt["user_path"] = user
    cct = kin.cct_diagram(c, grain, max(t_max, kin.li_temps(c).ae3 + 10))
    cct["user_path"] = user
    return [ttt, cct]
