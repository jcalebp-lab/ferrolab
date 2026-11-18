"""Mensajes ES/EN de advertencias y supuestos del FSE.

Las claves (`code`) son estables; el texto puede mejorarse sin cambiar el contrato.
Los mensajes nunca contienen cifras metalúrgicas propias: solo repiten valores
introducidos por el estudiante o tomados de evidencia citada (`{param}`).
"""

from __future__ import annotations

MESSAGES: dict[str, tuple[str, str]] = {
    # --- bloqueantes -------------------------------------------------------
    "TEMPERATURE_ABOVE_PHYSICAL_LIMIT": (
        "La temperatura elegida ({temperature_c} °C) alcanza o supera el límite físico registrado "
        "para esta familia de materiales ({limit_c} °C): el material ya no sería un sólido y un "
        "tratamiento térmico no tiene sentido. Estado del límite: {guard_review}.",
        "The selected temperature ({temperature_c} °C) reaches or exceeds the recorded physical "
        "limit for this material family ({limit_c} °C): the material would no longer be solid, so a "
        "heat treatment makes no sense. Limit status: {guard_review}.",
    ),
    "TEMPERATURE_OUTSIDE_PROTOCOL_RANGE": (
        "La temperatura excede el rango documentado para este protocolo ({min_c}–{max_c} °C).",
        "The temperature is outside the documented range for this protocol ({min_c}–{max_c} °C).",
    ),
    "HOLD_OUTSIDE_PROTOCOL_RANGE": (
        "El tiempo de mantenimiento está fuera del rango documentado para este protocolo "
        "({min_min}–{max_min} min).",
        "The holding time is outside the documented range for this protocol ({min_min}–{max_min} min).",
    ),
    "COMBINATION_UNSUPPORTED": (
        "Esta combinación no tiene un protocolo respaldado; puedes revisar el fundamento teórico.",
        "This combination has no supported protocol; you can review the theoretical background.",
    ),
    # --- limitaciones científicas -------------------------------------------
    "MISSING_VALIDATED_PROTOCOL": (
        "Esta combinación se puede estudiar, pero no calcular con rigor todavía: no hay un "
        "protocolo térmico revisado y publicado.",
        "This combination can be studied but not yet calculated rigorously: there is no reviewed, "
        "published thermal protocol.",
    ),
    "PAIR_NOT_QUANTITATIVE": (
        "La revisión científica de esta pareja material–tratamiento no habilita resultados numéricos.",
        "The scientific review of this material–treatment pair does not enable numerical results.",
    ),
    "TEMPERATURE_DOMAIN_UNPUBLISHED": (
        "Aún no hay un rango de temperatura documentado para este protocolo; no podemos confirmar "
        "si tu temperatura es adecuada.",
        "There is no documented temperature range for this protocol yet; we cannot confirm whether "
        "your temperature is appropriate.",
    ),
    "HOLD_DOMAIN_UNPUBLISHED": (
        "Aún no hay límites documentados para el tiempo de mantenimiento de este protocolo.",
        "There are no documented limits for this protocol's holding time yet.",
    ),
    "TEMPER_REQUIRES_HARDENED_STATE": (
        "El revenido requiere un estado inicial endurecido (templado) documentado. La condición "
        "inicial disponible no lo está, así que no se asume un temple previo.",
        "Tempering requires a documented hardened (quenched) initial state. The available initial "
        "condition is not documented as hardened, so no prior quench is assumed.",
    ),
    "REQUIRED_INITIAL_STATE_NOT_MET": (
        "La condición inicial no cumple el requisito documentado del protocolo ({requirement}).",
        "The initial condition does not meet the protocol's documented requirement ({requirement}).",
    ),
    "CARBURIZED_CASE_NOT_ASSUMED": (
        "AISI 8620 se usa a menudo cementado, pero esta condición inicial no está documentada como "
        "cementada: no se atribuyen propiedades de capa cementada.",
        "AISI 8620 is often used carburized, but this initial condition is not documented as "
        "carburized: no case-hardened properties are attributed.",
    ),
    "CAST_IRON_NO_STEEL_MODELS": (
        "ASTM A48 Clase 30 es una fundición gris, no un acero: no se aplican curvas ni modelos de "
        "acero. La clase de resistencia no fija una composición ni una matriz únicas.",
        "ASTM A48 Class 30 is a gray cast iron, not a steel: steel curves and models are not applied. "
        "The strength class does not define a unique composition or matrix.",
    ),
    "ANNEAL_VARIANT_REQUIRED": (
        "«Recocido» agrupa variantes distintas (completo, subcrítico, etc.); el protocolo debe "
        "especificar la variante antes de cualquier cálculo.",
        "\"Annealing\" covers different variants (full, subcritical, etc.); the protocol must specify "
        "the variant before any calculation.",
    ),
    "STAGED_PROTOCOL_PENDING": (
        "Este tratamiento exige etapas de baño/igualación definidas por un protocolo revisado. "
        "La temperatura y duración del baño no están publicadas, así que se muestran sin cifra.",
        "This treatment requires bath/equalization stages defined by a reviewed protocol. The bath "
        "temperature and duration are not published, so they are shown without numbers.",
    ),
    "HOLD_REFERS_TO_STAGE": (
        "Tu tiempo de mantenimiento se aplica a la etapa: {stage}.",
        "Your holding time applies to the stage: {stage}.",
    ),
    "HOLD_ZERO": (
        "Tiempo de mantenimiento 0 min: la meseta se omite del ciclo.",
        "Holding time 0 min: the hold stage is omitted from the cycle.",
    ),
    "DATASET_CONTAINS_UNREVIEWED_CONTENT": (
        "Contenido editorial pendiente de revisión por una persona con formación metalúrgica. "
        "Úsalo como material de estudio, no como referencia.",
        "Editorial content pending review by a person with metallurgical training. Use it as study "
        "material, not as a reference.",
    ),
    "NO_QUANTITATIVE_EVIDENCE": (
        "No hay datos experimentales ni modelos validados publicados para esta condición exacta.",
        "There are no published experimental data or validated models for this exact condition.",
    ),
    "NO_SUITABLE_MICROGRAPH": (
        "Aún no tenemos una micrografía verificada de esta condición.",
        "We do not have a verified micrograph of this condition yet.",
    ),
    "SCHEMATIC_CYCLE_ONLY": (
        "El ciclo se muestra de forma esquemática: las duraciones de calentamiento y enfriamiento no "
        "están publicadas y el eje de tiempo no está a escala.",
        "The cycle is shown schematically: heating and cooling durations are not published and the "
        "time axis is not to scale.",
    ),
    "PHYSICAL_LIMIT_UNREVIEWED": (
        "El límite físico de temperatura usado como protección está pendiente de verificación humana.",
        "The physical temperature limit used as a safeguard is pending human verification.",
    ),
    "MODEL_NOT_ACTIVATED": (
        "El modelo {model} existe en el código pero está desactivado: faltan coeficientes "
        "verificados, dominio o un caso de referencia revisado.",
        "Model {model} exists in code but is disabled: verified coefficients, domain or a reviewed "
        "reference case are missing.",
    ),
}

ASSUMPTIONS: dict[str, tuple[str, str]] = {
    "GEOMETRY_OMITTED": (
        "Geometría omitida: simplificación educativa. No se predicen gradientes internos ni piezas reales.",
        "Geometry omitted: educational simplification. Internal gradients and real parts are not predicted.",
    ),
    "COOLING_FIXED_BY_PROTOCOL": (
        "El medio y el perfil de enfriamiento los fija el protocolo; no los elige el estudiante.",
        "The cooling medium and profile are fixed by the protocol; the student does not choose them.",
    ),
    "EDUCATIONAL_NOT_INDUSTRIAL": (
        "Herramienta educativa, no tratamiento industrial.",
        "Educational tool, not an industrial treatment.",
    ),
    "LINEAR_SEGMENTS_ILLUSTRATIVE": (
        "Los tramos entre puntos son líneas rectas: representación didáctica, no cinética medida.",
        "Segments between points are straight lines: a teaching representation, not measured kinetics.",
    ),
}

STAGE_LABELS: dict[str, tuple[str, str]] = {
    "heat_to_austenitizing": ("Calentamiento hasta la temperatura objetivo", "Heating to target temperature"),
    "heat_to_temper": ("Calentamiento hasta la temperatura de revenido", "Heating to tempering temperature"),
    "heat_to_target": ("Calentamiento hasta la temperatura objetivo", "Heating to target temperature"),
    "hold_austenitizing": ("Mantenimiento a temperatura objetivo", "Holding at target temperature"),
    "hold_temper": ("Mantenimiento de revenido", "Tempering hold"),
    "hold_target": ("Mantenimiento a temperatura objetivo", "Holding at target temperature"),
    "transfer_to_medium": ("Traslado al medio de enfriamiento", "Transfer to cooling medium"),
    "transfer_to_bath": ("Traslado al baño", "Transfer to bath"),
    "quench_cool": ("Enfriamiento de temple", "Quench cooling"),
    "controlled_cool": ("Enfriamiento posterior", "Subsequent cooling"),
    "anneal_cool": ("Enfriamiento de recocido (según variante)", "Annealing cooling (variant-dependent)"),
    "air_cool": ("Enfriamiento al aire", "Air cooling"),
    "cool_to_bath": ("Enfriamiento hasta el baño", "Cooling to bath"),
    "isothermal_bath_hold": ("Mantenimiento isotérmico en el baño", "Isothermal bath hold"),
    "equalization_hold": ("Igualación en el baño (cerca de Ms)", "Equalization in bath (near Ms)"),
    "final_cool": ("Enfriamiento final", "Final cooling"),
}


def localize(table: dict[str, tuple[str, str]], code: str, locale: str, **params: object) -> str:
    es, en = table.get(code, (code, code))
    text = en if locale == "en" else es
    try:
        return text.format(**params)
    except (KeyError, IndexError):
        return text
