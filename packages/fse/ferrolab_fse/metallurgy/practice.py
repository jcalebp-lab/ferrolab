"""Cadena completa de una práctica: ciclo térmico → austenización → descomposición → fases → dureza.

Todo es determinista. Las cifras resultantes son ESTIMACIONES DE MODELOS EMPÍRICOS publicados
(ver data.SOURCES); FERROLAB las etiqueta como `modeled` / `bounded_estimate` y nunca como medidas.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from . import grain as grain_model
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

MODEL_VERSION = "ferrolab_metallurgy@1.1.0"
MODEL_SOURCES = ("src_li_1998", "src_collins_2023", "src_km_1959", "src_maynier_1978", "src_andrews_1965",
                 "src_grange_1961", "src_grossmann", "src_kang_lee_2014")


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
    grain: dict | None = None  # tamaño de grano (Lee & Lee 2008, ASTM E112, Hodgson & Gibbs 1992)


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


@dataclass(frozen=True)
class Step:
    """Etapa física ya resuelta (con cifras) que el modelo térmico ejecuta."""

    kind: str  # preheat | heat | hold | transfer | quench | bath | furnace_cool | air
    label: str
    temperature_c: float | None = None
    duration_s: float | None = None
    medium: str | None = None
    equalize: bool = False
    rate_c_per_h: float | None = None
    until_c: float | None = None


# Etapas del revenido (Krauss, «Steels: Processing, Structure, and Performance»; Callister): la cementita sustituye a
# los carburos de transición y la austenita retenida se descompone hacia 250–350 °C. Desde 350 °C se usa la palanca.
TEMPER_CEMENTITE_C = 350.0

COOLING_KINDS = {"transfer", "quench", "bath", "furnace_cool", "air"}


def _execute(r: Runner, steps: list[Step], severity_h: float | None = None) -> tuple[int, float | None]:
    """Ejecuta las etapas. Devuelve (índice donde empieza el primer enfriamiento, temperatura de baño)."""
    i0: int | None = None
    bath_c = None
    air = medium("air")
    for st in steps:
        if st.kind in COOLING_KINDS and i0 is None:
            i0 = len(r.center) - 1
        if st.kind in ("heat", "preheat"):
            r.run("heat", st.label, Medium("furnace", float(st.temperature_c)), until_center_within=2.0, max_s=4 * 3600)
        elif st.kind == "hold":
            if st.duration_s and st.duration_s > 0:
                r.run("hold", st.label, Medium("furnace", float(st.temperature_c)), duration_s=st.duration_s)
        elif st.kind == "transfer":
            r.run("transfer", st.label, air, duration_s=st.duration_s or ASSUMPTIONS["transfer_s"])
        elif st.kind == "quench":
            m = medium(st.medium or "oil")
            if severity_h is not None and m.grossmann_h is not None:
                m = Medium(m.code, m.temperature_c, severity_h)
            r.run("cool", st.label, m, until_center_within=5.0, max_s=1800)
        elif st.kind == "bath":
            bath_c = float(st.temperature_c)
            code = st.medium if st.medium in ("furnace",) else "salt_bath"
            m = Medium("furnace", bath_c) if code == "furnace" else medium("salt_bath", bath_c)
            if st.duration_s is not None:
                r.run("isothermal_hold", st.label, m, duration_s=st.duration_s)
            else:
                r.run("isothermal_hold", st.label, m, until_center_within=3.0, max_s=1800)
        elif st.kind == "furnace_cool":
            r.furnace_cool(st.label, float(st.rate_c_per_h), float(st.until_c))
        elif st.kind == "air":
            r.run("cool", st.label, air, until_center_below=60.0, max_s=4 * 3600)
        else:
            raise ValueError(st.kind)
    return (len(r.center) - 1 if i0 is None else i0), bath_c


def _decompose(path, c, fa, ca, g=None):
    st = kin.integrate(path, c, ASSUMPTIONS["astm_grain_size"] if g is None else g, austenite0=fa, carbon0=ca)
    return kin.final_microstructure(st), st


def _medium_of(steps: list[Step]) -> str:
    for st in steps:
        if st.kind in ("quench", "bath"):
            return st.medium or "salt_bath"
        if st.kind == "furnace_cool":
            return "furnace"
    return "air"


def simulate_steps(material_id: str, treatment_id: str, steps: list[Step], *, model: bool = True,
                   diagrams: bool = True) -> Practice:
    """Ciclo térmico por etapas + (si hay modelo para el material) descomposición, fases y dureza."""
    comps = compositions(material_id)
    r = Runner(ASSUMPTIONS["ambient_c"])
    i0, bath = _execute(r, steps)
    run_ = r.result()
    c = comps["nominal"] if comps else {}
    p = Practice(material_id, treatment_id, c, _critical_dict(c) if comps else {}, run_.center, run_.surface,
                 run_.segments, run_.max_center_c, 0.0, i0, _medium_of(steps), bath)
    if comps is None:
        return p
    path_c = run_.center[i0:]
    path_s = run_.surface[i0:]
    t_max = max(t for _, t in run_.center[: i0 + 1])
    if not model:
        if diagrams:
            p.diagrams = _diagrams(c, t_max, path_c, run_.center[i0][0])
        return p
    fa, ca = _austenitize(c, t_max)
    p.austenite_fraction = fa
    tm = kin.li_temps(c)
    p.diagrams = _diagrams(c, t_max, path_c, run_.center[i0][0])
    if fa <= 0:
        p.notes.append("MODEL_NO_AUSTENITIZATION")
        return p
    if fa < 1:
        p.notes.append("MODEL_INTERCRITICAL")
    if t_max > tm.ae3 + 150:
        p.notes.append("MODEL_OVERHEATING")
    g = None
    if fa >= 1:
        p.grain = grain_model.estimate(comps, run_.center, {k: kin.li_temps(v).ae3 for k, v in comps.items()}, t_max)
        if p.grain is not None:
            g = p.grain["austenite_g"]
            p.notes.append("MODEL_GRAIN_LEE")
            if p.grain["extrapolation"]:
                p.notes.append("MODEL_GRAIN_EXTRAPOLATED")
    else:
        p.notes.append("MODEL_GRAIN_INTERCRITICAL")
    if g is not None:
        p.diagrams = _diagrams(c, t_max, path_c, run_.center[i0][0], g)
    micro, st = _decompose(path_c, c, fa, ca, g)
    p.fractions = micro
    p.phases = _phases(micro, c, st.carbon_austenite)
    p.surface_fractions, _ = _decompose(path_s, c, fa, ca, g)
    vr = rate_at(path_c, 700.0)
    fc = next((s for s in steps if s.kind == "furnace_cool"), None)
    if vr is None and fc is not None:
        vr = fc.rate_c_per_h / 3600
    if vr is None:  # p. ej. baño isotérmico por encima de 700 °C: se usa la velocidad media hasta el baño
        vr = rate_at(path_c, max(t for _, t in path_c) - 1.0)
    p.vr_700_k_s = vr
    if p.grain is not None and vr is not None and micro.get("proeutectoid_ferrite", 0) >= 0.05:
        da = grain_model.ferrite_grain_um(c, vr, p.grain["austenite_um"])
        if da is not None:
            p.grain["ferrite_um"] = da
            p.grain["ferrite_g"] = grain_model.astm_g_from_intercept_um(da)
            p.grain["ferrite_rate_k_s"] = vr
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
        mk, _ = _decompose(path_c, ck, fak, cak, g)
        for k, v in mk.items():
            ranges[k][0] = min(ranges[k][0], v)
            ranges[k][1] = max(ranges[k][1], v)
        if vr is not None:
            hvs.append(mixture_hv(mk, ck, vr * 3600))
    qm = next((s.medium for s in steps if s.kind == "quench"), None)
    if qm in GROSSMANN_H_RANGE:  # banda por severidad del aceite (sin agitar → agitado)
        r2 = Runner(ASSUMPTIONS["ambient_c"])
        j0, _ = _execute(r2, steps, severity_h=GROSSMANN_H_RANGE[qm][1])
        path2 = r2.center[j0:]
        m2, _ = _decompose(path2, c, fa, ca, g)
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
    return p


def simulate_temper(material_id: str, prior_steps: list[Step], prior_info: dict, steps: list[Step],
                    temper_c: float, hold_s: float, *, model: bool = True) -> Practice:
    """Revenido sobre un estado templado calculado (prior_steps). Dureza: Kang & Lee (2014)."""
    prior = simulate_steps(material_id, "quench", prior_steps, model=model)
    p = simulate_steps(material_id, "temper", steps, model=False, diagrams=False)
    comps = compositions(material_id)
    p.prior = {**prior_info, "medium": prior.medium_code, "fractions": prior.fractions,
               "hardness_hv": prior.hardness_hv, "hardness_range": prior.hardness_range}
    p.diagrams = prior.diagrams
    p.grain = prior.grain  # el revenido no cambia el grano austenítico previo
    if not model or comps is None:
        return p
    c = comps["nominal"]
    p.composition = c
    p.critical = _critical_dict(c)
    tm = kin.li_temps(c)
    if p.max_center_c >= tm.ae1:
        p.notes.append("MODEL_TEMPER_ABOVE_AE1")
        return p
    lo_t, hi_t = KANG_LEE_T_RANGE_C
    lo_h, hi_h = KANG_LEE_HOLD_RANGE_S
    if not (lo_t <= temper_c <= hi_t) or not (lo_h <= hold_s <= hi_h) or not prior.fractions or prior.vr_700_k_s is None:
        p.notes.append("MODEL_TEMPER_OUTSIDE_VALIDITY")
        return p
    f = dict(prior.fractions)
    f["tempered_martensite"] = f.pop("martensite", 0.0)
    if temper_c >= TEMPER_CEMENTITE_C:  # la austenita retenida se descompone en el revenido alto (2.ª etapa)
        f["tempered_martensite"] += f.pop("retained_austenite", 0.0)
    p.fractions = f
    if temper_c >= TEMPER_CEMENTITE_C:
        # Por encima de la 3.ª etapa del revenido el carbono de la martensita precipita como cementita y la austenita
        # retenida se ha descompuesto: fases = ferrita + cementita por la regla de la palanca (diagrama Fe–Fe3C).
        p.phases = _phases({"martensite": 0.0, "retained_austenite": 0.0}, c, 0.0)
    p.fractions_range = None if prior.fractions_range is None else {
        ("tempered_martensite" if k == "martensite" else k): v for k, v in prior.fractions_range.items()}
    vr_h = prior.vr_700_k_s * 3600
    p.hardness_hv = tempered_mixture_hv(prior.fractions, c, vr_h, temper_c, hold_s)
    hvs = [p.hardness_hv]
    t_aus = max(t for _, t in prior.runner_center[: prior.cooling_start_index + 1])
    for key in ("low", "high"):
        ck = comps[key]
        fak, cak = _austenitize(ck, t_aus)
        if fak <= 0:
            continue
        mk, _ = _decompose(prior.runner_center[prior.cooling_start_index:], ck, fak, cak,
                           None if prior.grain is None else prior.grain["austenite_g"])
        hvs.append(tempered_mixture_hv(mk, ck, vr_h, temper_c, hold_s))
    p.hardness_range = (min(hvs), max(hvs))
    p.vr_700_k_s = prior.vr_700_k_s
    p.notes.append("MODEL_TEMPER_KANG_LEE")
    return p


def simulate_quench_temper(material_id: str, quench_steps: list[Step], info: dict, temper_steps: list[Step],
                           temper_c: float, hold_s: float, *, model: bool = True) -> Practice:
    """Bonificado: temple + revenido alto en UNA secuencia. El cálculo es el de `simulate_temper` (Kang & Lee sobre el
    temple calculado); la curva térmica que ve el estudiante es la del ciclo completo."""
    p = simulate_temper(material_id, quench_steps, info, temper_steps, temper_c, hold_s, model=model)
    full = simulate_steps(material_id, "quench_temper", quench_steps + temper_steps, model=False, diagrams=False)
    p.runner_center, p.runner_surface, p.segments = full.runner_center, full.runner_surface, full.segments
    p.cooling_start_index = full.cooling_start_index
    p.medium_code = full.medium_code
    return p


def _critical_dict(c: dict[str, float]) -> dict[str, float]:
    if not c:
        return {}
    cr = critical_temperatures(c).as_dict()
    tm = kin.li_temps(c)
    cr.update({"ae1_li_c": round(tm.ae1, 1), "ae3_li_c": round(tm.ae3, 1), "bs_li_c": round(tm.bs, 1),
               "ms_model_c": round(tm.ms, 1)})
    return cr


def _diagrams(c, t_max, path_c, t_cool0, g=None) -> list[dict]:
    grain = ASSUMPTIONS["astm_grain_size"] if g is None else g
    user = [[round(max(t - t_cool0, 0.01), 3), round(temp, 1)] for t, temp in thin(path_c, 300)]
    ttt = kin.ttt_diagram(c, grain)
    ttt["user_path"] = user
    ttt["astm_grain_size"] = round(grain, 1)
    cct = kin.cct_diagram(c, grain, max(t_max, kin.li_temps(c).ae3 + 10))
    cct["user_path"] = user
    cct["astm_grain_size"] = round(grain, 1)
    return [ttt, cct]
