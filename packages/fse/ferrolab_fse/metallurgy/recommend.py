"""Rangos de práctica RECOMENDADOS por material y tratamiento, cada uno con su fuente.

Tiempos para la probeta de referencia (12.7 mm). Cuando la fuente da una regla «por 25 mm de
sección» se indica y se aplica tal cual (es conservadora para una probeta más delgada).
Si la fuente no da cifra, el campo queda en None y se dice explícitamente.
"""

from __future__ import annotations

from dataclasses import asdict, dataclass, field


@dataclass(frozen=True)
class Recommendation:
    temperature_min_c: float | None
    temperature_max_c: float | None
    temperature_typical_c: float | None
    hold_min_min: float | None
    hold_max_min: float | None
    hold_typical_min: float | None
    medium: str
    source_ids: tuple[str, ...]
    note_es: str
    note_en: str
    bath_rule_es: str | None = None
    bath_rule_en: str | None = None
    extra: dict = field(default_factory=dict)

    def as_dict(self, locale: str = "es") -> dict:
        d = asdict(self)
        d["note"] = self.note_en if locale == "en" else self.note_es
        d["bath_rule"] = self.bath_rule_en if locale == "en" else self.bath_rule_es
        d["source_ids"] = list(self.source_ids)
        for k in ("note_es", "note_en", "bath_rule_es", "bath_rule_en"):
            d.pop(k)
        return d


_AUSTEMPER_BATH_ES = ("Baño isotérmico por encima de Ms (Wikipedia «Austempering»). FERROLAB usa Ms del modelo + 40 °C "
                      "(supuesto didáctico: bainita inferior) y mantiene hasta completar la bainita según el modelo.")
_AUSTEMPER_BATH_EN = ("Isothermal bath above Ms (Wikipedia 'Austempering'). FERROLAB uses model Ms + 40 °C "
                      "(teaching assumption: lower bainite) and holds until the model completes bainite.")
_MARTEMPER_BATH_ES = ("Baño caliente por encima de Ms hasta igualar la temperatura de la sección (Wikipedia «Martempering»). "
                      "FERROLAB usa Ms del modelo + 15 °C (supuesto) y luego aire.")
_MARTEMPER_BATH_EN = ("Hot bath above Ms until the section temperature equalizes (Wikipedia 'Martempering'). "
                      "FERROLAB uses model Ms + 15 °C (assumption), then air.")

HOLD_RULE_ES = "AZoM: 10–15 min por cada 25 mm de sección, una vez uniforme la temperatura."
HOLD_RULE_EN = "AZoM: 10–15 min per 25 mm of section once the temperature is uniform."

RECOMMENDATIONS: dict[tuple[str, str], Recommendation] = {
    # ------------------------------------------------------------ AISI 1045
    ("aisi_1045", "quench"): Recommendation(
        820, 850, 845, 10, 15, 15, "water", ("src_azom_1045", "src_compraco_1045"),
        "Austenizar 820–850 °C (AZoM; Compraco: 845 °C) y templar en agua o salmuera. " + HOLD_RULE_ES,
        "Austenitize at 820–850 °C (AZoM; Compraco: 845 °C) and quench in water or brine. " + HOLD_RULE_EN),
    ("aisi_1045", "normalize"): Recommendation(
        870, 920, 870, 10, 15, 15, "air", ("src_azom_1045", "src_compraco_1045"),
        "Calentar a 870–920 °C, mantener 10–15 min y enfriar en aire en calma (AZoM). Compraco indica 830–900 °C, típico 860 °C.",
        "Heat to 870–920 °C, soak 10–15 min and cool in still air (AZoM). Compraco gives 830–900 °C, typical 860 °C."),
    ("aisi_1045", "anneal"): Recommendation(
        800, 850, 830, 60, None, 60, "furnace", ("src_azom_1045", "src_compraco_1045"),
        "Recocido completo 800–850 °C (AZoM; Compraco 790–870 °C), al menos 1 h para secciones ≤ 25 mm, "
        "enfriar en horno de 790 a 650 °C a 28 °C/h (Compraco).",
        "Full anneal at 800–850 °C (AZoM; Compraco 790–870 °C), at least 1 h for sections ≤ 25 mm, "
        "furnace cool from 790 to 650 °C at 28 °C/h (Compraco)."),
    ("aisi_1045", "temper"): Recommendation(
        400, 650, None, 30, 60, 60, "air", ("src_azom_1045",),
        "Revenir a 400–650 °C según la dureza buscada, 1 h por cada 25 mm de sección, enfriar al aire (AZoM). "
        "Requiere partir de un estado templado.",
        "Temper at 400–650 °C depending on the target hardness, 1 h per 25 mm of section, air cool (AZoM). "
        "Requires a hardened starting state."),
    ("aisi_1045", "austemper"): Recommendation(
        820, 850, 845, 10, 15, 15, "salt_bath", ("src_azom_1045", "src_wiki_austempering"),
        "Austenizar como en el temple (820–850 °C) y llevar a un baño isotérmico. " + HOLD_RULE_ES,
        "Austenitize as for hardening (820–850 °C) and transfer to an isothermal bath. " + HOLD_RULE_EN,
        _AUSTEMPER_BATH_ES, _AUSTEMPER_BATH_EN),
    ("aisi_1045", "martemper"): Recommendation(
        820, 850, 845, 10, 15, 15, "salt_bath", ("src_azom_1045", "src_wiki_martempering"),
        "Austenizar como en el temple (820–850 °C) y llevar a un baño caliente. " + HOLD_RULE_ES,
        "Austenitize as for hardening (820–850 °C) and transfer to a hot bath. " + HOLD_RULE_EN,
        _MARTEMPER_BATH_ES, _MARTEMPER_BATH_EN),
    # ------------------------------------------------------------ AISI 8620 (sin carburizar)
    ("aisi_8620", "quench"): Recommendation(
        830, 845, 845, 10, 15, 15, "oil", ("src_compraco_8620", "src_azom_1045"),
        "Temple directo: 845 °C en aceite (o 830 °C si se templa en agua) (Compraco, tablas tipo ASM). "
        "Mantenimiento: regla general de AZoM (10–15 min por 25 mm).",
        "Direct hardening: 845 °C oil quench (or 830 °C for water) (Compraco, ASM-type tables). "
        "Hold: AZoM general rule (10–15 min per 25 mm)."),
    ("aisi_8620", "normalize"): Recommendation(
        870, 930, 915, 10, 15, 15, "air", ("src_compraco_8620", "src_azom_1045"),
        "Normalizar a 870–930 °C (Compraco; tabla de dureza normalizada a 915 °C) y enfriar al aire.",
        "Normalize at 870–930 °C (Compraco; normalized hardness table at 915 °C) and air cool."),
    ("aisi_8620", "anneal"): Recommendation(
        870, 885, 870, 45, 60, 45, "furnace", ("src_compraco_8620",),
        "Recocido completo a 870 °C, mantener 45 min y enfriar en horno (Compraco; isotérmico 885 → 660 °C, 4 h).",
        "Full anneal at 870 °C, hold 45 min and furnace cool (Compraco; isothermal 885 → 660 °C, 4 h)."),
    ("aisi_8620", "temper"): Recommendation(
        200, 650, None, 30, 60, 60, "air", ("src_compraco_8620", "src_azom_1045"),
        "Revenir a 200–650 °C (Compraco), 1 h por 25 mm de sección (regla AZoM). Requiere estado templado.",
        "Temper at 200–650 °C (Compraco), 1 h per 25 mm of section (AZoM rule). Requires a hardened state."),
    ("aisi_8620", "austemper"): Recommendation(
        830, 845, 845, 10, 15, 15, "salt_bath", ("src_compraco_8620", "src_wiki_austempering"),
        "Austenizar como en el temple directo (830–845 °C) y llevar a un baño isotérmico.",
        "Austenitize as for direct hardening (830–845 °C) and transfer to an isothermal bath.",
        _AUSTEMPER_BATH_ES, _AUSTEMPER_BATH_EN),
    ("aisi_8620", "martemper"): Recommendation(
        830, 845, 845, 10, 15, 15, "salt_bath", ("src_compraco_8620", "src_wiki_martempering"),
        "Austenizar como en el temple directo (830–845 °C). En la industria el martemple del 8620 se aplica "
        "a piezas carburizadas (baño de sales a 205 °C, Compraco).",
        "Austenitize as for direct hardening (830–845 °C). Industrially, 8620 martempering is applied to "
        "carburized parts (salt bath at 205 °C, Compraco).",
        _MARTEMPER_BATH_ES, _MARTEMPER_BATH_EN),
    # ------------------------------------------------------------ ASTM A48 clase 30 (fundición gris)
    ("astm_a48_class_30", "quench"): Recommendation(
        850, 900, None, None, None, None, "oil", ("src_compraco_gray",),
        "Calentar al límite superior de Ac1 + 30–50 °C, típicamente 850–900 °C, mantener para disolver carbono "
        "en la austenita y templar en aceite (Compraco). La fuente no da un tiempo numérico.",
        "Heat to the upper Ac1 limit + 30–50 °C, typically 850–900 °C, hold to dissolve carbon into austenite "
        "and oil quench (Compraco). The source gives no numeric time."),
    ("astm_a48_class_30", "normalize"): Recommendation(
        850, 900, None, None, None, None, "air", ("src_compraco_gray",),
        "Límite superior de Ac1 + 30–50 °C y enfriar al aire (Compraco; misma regla que el temple, 850–900 °C).",
        "Upper Ac1 limit + 30–50 °C and air cool (Compraco; same rule as hardening, 850–900 °C)."),
    ("astm_a48_class_30", "anneal"): Recommendation(
        550, 570, 550, None, None, None, "furnace", ("src_compraco_gray",),
        "Recocido de alivio de tensiones a 550 °C (fundición gris común), enfriamiento lento 20–40 °C/h "
        "hasta 150–200 °C (Compraco).",
        "Stress-relief anneal at 550 °C (common gray iron), slow cooling at 20–40 °C/h down to 150–200 °C (Compraco)."),
    ("astm_a48_class_30", "temper"): Recommendation(
        None, 550, None, 90, 90, 90, "air", ("src_compraco_gray",),
        "Revenir por debajo de 550 °C para evitar la grafitización; tiempo = espesor/25 + 1 h "
        "(1.5 h para 12.7 mm) (Compraco).",
        "Temper below 550 °C to avoid graphitization; time = thickness/25 + 1 h (1.5 h for 12.7 mm) (Compraco)."),
    ("astm_a48_class_30", "austemper"): Recommendation(
        850, 900, None, None, None, None, "salt_bath", ("src_compraco_gray", "src_wiki_austempering"),
        "Austenizar como en el temple (850–900 °C); en fundición la austenización tarda más porque el carbono "
        "debe difundir desde el grafito (Wikipedia).",
        "Austenitize as for hardening (850–900 °C); in cast irons austenitizing takes longer because carbon must "
        "diffuse out of the graphite (Wikipedia)."),
    ("astm_a48_class_30", "martemper"): Recommendation(
        850, 900, None, None, None, None, "salt_bath", ("src_compraco_gray", "src_wiki_martempering"),
        "Austenizar como en el temple (850–900 °C) y llevar a un baño caliente por encima de Ms.",
        "Austenitize as for hardening (850–900 °C) and transfer to a hot bath above Ms."),
}


def recommendation(material_id: str, treatment_id: str) -> Recommendation | None:
    return RECOMMENDATIONS.get((material_id, treatment_id))


def check(material_id: str, treatment_id: str, temperature_c: float, hold_min: float) -> list[tuple[str, dict]]:
    """Avisos (código, parámetros) cuando la práctica se sale de lo recomendado."""
    rec = recommendation(material_id, treatment_id)
    out: list[tuple[str, dict]] = []
    if rec is None:
        return out
    lo, hi = rec.temperature_min_c, rec.temperature_max_c
    if (lo is not None and temperature_c < lo) or (hi is not None and temperature_c > hi):
        out.append(("OUTSIDE_RECOMMENDED_TEMPERATURE", {
            "min_c": "—" if lo is None else f"{lo:g}", "max_c": "—" if hi is None else f"{hi:g}",
            "temperature_c": f"{temperature_c:g}"}))
    hlo, hhi = rec.hold_min_min, rec.hold_max_min
    if (hlo is not None and hold_min < hlo) or (hhi is not None and hold_min > hhi):
        out.append(("OUTSIDE_RECOMMENDED_HOLD", {
            "min_min": "—" if hlo is None else f"{hlo:g}", "max_min": "—" if hhi is None else f"{hhi:g}",
            "hold_min": f"{hold_min:g}"}))
    return out
