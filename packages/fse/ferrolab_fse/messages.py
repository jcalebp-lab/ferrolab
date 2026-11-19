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
        "tratamiento térmico no tiene sentido.",
        "The selected temperature ({temperature_c} °C) reaches or exceeds the recorded physical "
        "limit for this material family ({limit_c} °C): the material would no longer be solid, so a "
        "heat treatment makes no sense.",
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
        "La GG25 (EN-GJL-250) es una fundición gris, no un acero: no se aplican curvas ni modelos de "
        "acero. La norma EN 1561 fija la resistencia, no una composición ni una matriz únicas.",
        "GG25 (EN-GJL-250) is a gray cast iron, not a steel: steel curves and models are not applied. "
        "EN 1561 sets the strength, not a unique composition or matrix.",
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
    # --- motor metalúrgico (D-26) -----------------------------------------------
    "OUTSIDE_RECOMMENDED_TEMPERATURE": (
        "La temperatura elegida ({temperature_c} °C) está fuera del rango recomendado por la literatura para "
        "este material y tratamiento ({min_c}–{max_c} °C). Es una mala práctica: revisa la sugerencia.",
        "The selected temperature ({temperature_c} °C) is outside the literature-recommended range for this "
        "material and treatment ({min_c}–{max_c} °C). This is poor practice: check the suggestion.",
    ),
    "OUTSIDE_RECOMMENDED_HOLD": (
        "El tiempo de mantenimiento ({hold_min} min) está fuera de lo recomendado ({min_min}–{max_min} min).",
        "The holding time ({hold_min} min) is outside the recommendation ({min_min}–{max_min} min).",
    ),
    "MODEL_ESTIMATE_NOT_REVIEWED": (
        "Fases, constituyentes, dureza y diagramas son estimaciones de modelos empíricos publicados "
        "(Li 1998, Koistinen–Marburger, Maynier 1978) para una probeta de 12.7 mm, en el centro. "
        "No son mediciones y no han sido revisadas por un especialista.",
        "Phases, constituents, hardness and diagrams are estimates from published empirical models "
        "(Li 1998, Koistinen–Marburger, Maynier 1978) for a 12.7 mm specimen, at the center. "
        "They are not measurements and have not been reviewed by a specialist.",
    ),
    "WHY_GRAY_IRON": (
        "En la fundición gris no hay un modelo publicado de transformación: FERROLAB muestra el resultado esperado del "
        "protocolo, la matriz y el grafito en el microscopio y micrografías reales de la matriz.",
        "There is no published transformation model for gray iron: FERROLAB shows the protocol's expected result, the "
        "matrix and graphite in the microscope and real micrographs of the matrix.",
    ),
    "WHY_GRAY_IRON_GRAIN": (
        "No aplica: en la fundición gris se clasifica el grafito (forma, distribución y tamaño según ASTM A247; aquí "
        "grafito laminar tipo A), no el tamaño de grano de la matriz.",
        "Not applicable: in gray iron the graphite is classified (form, distribution and size per ASTM A247; here "
        "type A flake graphite), not the matrix grain size.",
    ),
    "WHY_THEORY": (
        "El revenido necesita una muestra templada de partida: elige «Muestra de referencia» o una del historial.",
        "Tempering needs a quenched starting sample: choose «Reference sample» or one from the history.",
    ),
    "WHY_UNVERIFIED": (
        "Variante de demostración: su fuente no se pudo consultar. Elige el protocolo de referencia para obtener cifras.",
        "Demonstration variant: its source could not be consulted. Choose the reference protocol to get figures.",
    ),
    "WHY_OUTSIDE_RANGE": (
        "Tu práctica está fuera del rango documentado del protocolo: pulsa «Usar protocolo recomendado» para obtener "
        "cifras.",
        "Your practice is outside the protocol's documented range: press «Use recommended protocol» to get figures.",
    ),
    "WHY_CARBURIZED": (
        "Este protocolo es para piezas cementadas y la capa rica en carbono no se calcula: elige el protocolo de "
        "referencia (sin cementar) para obtener cifras del acero base.",
        "This protocol is for carburized parts and the carbon-rich case is not computed: choose the reference "
        "(non-carburized) protocol to get figures for the base steel.",
    ),
    "WHY_NOT_MODELED": (
        "Este protocolo (subcrítico o de alivio de tensiones) no transforma la austenita: conserva el estado de partida. "
        "Consulta el resultado esperado en la ficha del protocolo.",
        "This protocol (subcritical or stress relief) does not transform austenite: it keeps the starting state. See "
        "the expected result in the protocol sheet.",
    ),
    "WHY_NO_AUSTENITIZATION": (
        "La probeta no llegó a austenizarse (no superó Ae1): sube la temperatura o usa el protocolo recomendado.",
        "The specimen did not austenitize (it did not exceed Ae1): raise the temperature or use the recommended "
        "protocol.",
    ),
    "WHY_INTERCRITICAL": (
        "Austenización incompleta (intercrítica): el tamaño de grano no se estima. Sube la temperatura por encima de Ac3.",
        "Incomplete (intercritical) austenitization: grain size is not estimated. Raise the temperature above Ac3.",
    ),
    "WHY_GENERIC": (
        "Para esta condición no hay un modelo o dato publicado aplicable. Usa el protocolo recomendado.",
        "No applicable published model or data for this condition. Use the recommended protocol.",
    ),
    "MODEL_GRAIN_EXTRAPOLATED": (
        "El modelo de grano de Lee y Lee se ajustó entre 850 y 1200 °C y hasta 3 h; esta práctica queda fuera de "
        "ese dominio y el tamaño de grano es una extrapolación.",
        "The Lee and Lee grain model was fitted between 850 and 1200 °C and up to 3 h; this practice is outside "
        "that domain and the grain size is an extrapolation.",
    ),
    "MODEL_GRAIN_INTERCRITICAL": (
        "Austenización incompleta (intercrítica): no se estima el tamaño de grano y la cinética usa G ASTM 7 "
        "(supuesto).",
        "Incomplete (intercritical) austenitization: grain size is not estimated and the kinetics use ASTM G 7 "
        "(assumption).",
    ),
    "MODEL_THERMAL_HISTORY": (
        "La curva térmica se calculó con un modelo de conducción de calor (supuestos declarados).",
        "The thermal curve was computed with a heat-conduction model (declared assumptions).",
    ),
    "MODEL_NO_AUSTENITIZATION": (
        "La pieza no superó Ae1: no se forma austenita y el temple/normalizado no cambia la microestructura.",
        "The part did not exceed Ae1: no austenite forms and the treatment does not change the microstructure.",
    ),
    "MODEL_INTERCRITICAL": (
        "Temperatura intercrítica (entre Ae1 y Ae3): queda ferrita sin transformar; el temple será incompleto.",
        "Intercritical temperature (between Ae1 and Ae3): untransformed ferrite remains; hardening is incomplete.",
    ),
    "MODEL_OVERHEATING": (
        "La temperatura supera ampliamente Ae3: riesgo de crecimiento de grano y descarburación (no modelados).",
        "The temperature is far above Ae3: risk of grain growth and decarburization (not modeled).",
    ),
    "MODEL_TEMPER_ABOVE_AE1": (
        "Un revenido por encima de Ae1 vuelve a formar austenita: ya no es un revenido.",
        "Tempering above Ae1 re-forms austenite: it is no longer tempering.",
    ),
    "MODEL_TEMPER_HARDNESS_NOT_MODELED": (
        "Se muestra el estado templado de partida calculado. La dureza tras el revenido no se estima: FERROLAB "
        "no tiene aún un modelo de revenido verificado (cualitativamente, la dureza baja al subir la temperatura).",
        "The computed as-quenched starting state is shown. Hardness after tempering is not estimated: FERROLAB "
        "does not yet have a verified tempering model (qualitatively, hardness drops as temperature rises).",
    ),
    "MODEL_TEMPER_KANG_LEE": (
        "Dureza tras el revenido estimada con el parámetro de revenido dependiente de la composición de "
        "Kang y Lee (2014), aplicado a la martensita del estado templado calculado. La bainita no se endurece "
        "y la ferrita-perlita no cambia (supuestos).",
        "Hardness after tempering estimated with the composition-dependent tempering parameter of Kang and Lee "
        "(2014), applied to the martensite of the computed as-quenched state. Bainite does not harden and "
        "ferrite-pearlite does not change (assumptions).",
    ),
    "MODEL_TEMPER_ASSUMED_PRIOR_QUENCH": (
        "Para estimar el revenido, el modelo SUPONE que la pieza se templó antes con la práctica recomendada "
        "({quench_c} °C, {medium}); ese estado de partida se calcula y se muestra. Si tu pieza tuvo otro temple, "
        "el resultado no aplica.",
        "To estimate tempering, the model ASSUMES the part was previously hardened with the recommended practice "
        "({quench_c} °C, {medium}); that starting state is computed and shown. If your part had a different "
        "hardening, the result does not apply.",
    ),
    "MODEL_TEMPER_OUTSIDE_VALIDITY": (
        "La temperatura o el tiempo de revenido están fuera del rango de datos del modelo de Kang y Lee "
        "(145–716 °C; 30 s – 40 días): no se estima la dureza.",
        "Tempering temperature or time is outside the data range of the Kang and Lee model "
        "(145–716 °C; 30 s – 40 days): hardness is not estimated.",
    ),
    "MODEL_MEDIUM_SEVERITY_RANGE": (
        "La banda de incertidumbre incluye el rango de severidad del aceite (Grossmann H 0.25–1.0).",
        "The uncertainty band includes the oil severity range (Grossmann H 0.25–1.0).",
    ),
    "CAST_IRON_ILLUSTRATION_ONLY": (
        "Fundición gris: no hay modelo cinético validado; la microestructura se muestra como ilustración cualitativa.",
        "Gray cast iron: no validated kinetic model; the microstructure is shown as a qualitative illustration.",
    ),
    # --- biblioteca de protocolos y avisos agrupados (D-30) ------------------------------
    "REVIEW_PENDING": (
        "Contenido pendiente de revisión por una persona con formación metalúrgica. Las cifras vienen de las fuentes "
        "citadas o de modelos publicados.",
        "Content pending review by a person with metallurgical training. Figures come from the cited sources or from "
        "published models.",
    ),
    "NO_PROTOCOL": (
        "Esta combinación todavía no tiene un protocolo en la biblioteca: solo se muestra el esquema del ciclo.",
        "This combination has no protocol in the library yet: only the cycle outline is shown.",
    ),
    "OUTSIDE_PROTOCOL_RANGE": (
        "{param_name} ({value} {unit}) está fuera del intervalo documentado para este protocolo ({min}–{max} {unit}). "
        "Puedes volver al valor de referencia ({ref} {unit}) o continuar en modo exploración cualitativa.",
        "{param_name} ({value} {unit}) is outside the documented interval for this protocol ({min}–{max} {unit}). "
        "You can go back to the reference value ({ref} {unit}) or continue in qualitative exploration mode.",
    ),
    "PARAM_UNDOCUMENTED": (
        "{param_name}: la fuente de este protocolo no da una cifra. {extra}",
        "{param_name}: this protocol's source gives no number. {extra}",
    ),
    "PARAM_UNDOCUMENTED_STEEL_HOLD": (
        "El tiempo cuenta desde que el centro alcanza la temperatura; el modelo cinético supone austenización "
        "completa, así que este tiempo no cambia las fracciones calculadas.",
        "Time counts from when the center reaches temperature; the kinetic model assumes complete austenitization, "
        "so this time does not change the computed fractions.",
    ),
    "PARAM_UNDOCUMENTED_DRAW": (
        "Se usa el valor que elijas solo para dibujar el ciclo; no se predice su efecto.",
        "The value you choose is only used to draw the cycle; its effect is not predicted.",
    ),
    "BATH_TIME_UNDOCUMENTED": (
        "La fuente no fija el tiempo en el baño (depende de la composición): el ciclo se dibuja hasta igualar la "
        "temperatura, salvo que indiques un tiempo.",
        "The source does not set the bath time (it depends on composition): the cycle is drawn until temperature "
        "equalizes, unless you give a time.",
    ),
    "PROTOCOL_SOURCE_UNVERIFIED": (
        "Variante con fuente NO verificada por FERROLAB (no se pudo consultar el texto): el ciclo es ilustrativo y no "
        "se calculan cifras.",
        "Variant with a source NOT verified by FERROLAB (the text could not be consulted): the cycle is illustrative "
        "and no figures are computed.",
    ),
    "DEPENDENCY_REFERENCE": (
        "El revenido requiere una microestructura inicial apropiada. Se utiliza una muestra previamente templada de "
        "referencia ({prior}), calculada y mostrada en los resultados.",
        "Tempering requires an appropriate initial microstructure. A previously hardened reference sample ({prior}) is "
        "used, computed and shown in the results.",
    ),
    "DEPENDENCY_HISTORY": (
        "El revenido parte de una muestra templada de tu historial (austenizada a {temperature_c} °C).",
        "Tempering starts from a hardened sample from your history (austenitized at {temperature_c} °C).",
    ),
    "DEPENDENCY_THEORY": (
        "Demostración teórica: sin estado templado de partida no se predicen dureza ni fracciones.",
        "Theoretical demonstration: without a hardened starting state, hardness and fractions are not predicted.",
    ),
    "CARBURIZED_CASE_NOT_MODELED": (
        "Pieza cementada: la capa de alto carbono no se modela; no se atribuyen al núcleo las propiedades de la capa "
        "ni al revés.",
        "Carburized part: the high-carbon case is not modeled; case properties are not attributed to the core or "
        "vice versa.",
    ),
    "MARTEMPER_EXCESSIVE_HOLD": (
        "Sostenimiento excesivo en el baño ({time_min} min): según el modelo TTT la bainita empieza a los {limit_min} min. "
        "En el martemperizado la pieza debe salir al igualar la temperatura.",
        "Excessive bath hold ({time_min} min): per the TTT model bainite starts at {limit_min} min. In martempering the "
        "part must leave once its temperature equalizes.",
    ),
    "MARTEMPER_BAINITE_FORMED": (
        "El modelo indica {pct} % de bainita: este acero no alcanza a igualarse en el baño sin transformarse. "
        "El resultado ya no es un martemperizado puro.",
        "The model indicates {pct}% bainite: this steel cannot equalize in the bath without transforming. The result is "
        "no longer pure martempering.",
    ),
    "AUSTEMPER_INCOMPLETE_BAINITE": (
        "Con {time_min} min en el baño la bainita no se completa (el modelo TTT necesita ~{needed_min} min); la "
        "austenita restante puede formar martensita al enfriar.",
        "With {time_min} min in the bath, bainite is not completed (the TTT model needs ~{needed_min} min); remaining "
        "austenite may form martensite on cooling.",
    ),
    "THERMAL_CURVE_ILLUSTRATIVE": (
        "Curva térmica ilustrativa (propiedades térmicas del acero): no predice la temperatura real del núcleo.",
        "Illustrative thermal curve (steel thermal properties): it does not predict the real core temperature.",
    ),
    "EXPLORATION_NO_NUMBERS": (
        "Modo exploración: fuera del protocolo documentado se muestra la curva y los diagramas, sin cifras de "
        "dureza ni fracciones.",
        "Exploration mode: outside the documented protocol, the curve and diagrams are shown without hardness or "
        "fraction figures.",
    ),
    "HEADLINE_VALID": (
        "Protocolo de referencia cargado. Puedes iniciar la simulación. Consulta las condiciones de aplicación y las "
        "fuentes científicas.",
        "Reference protocol loaded. You can start the simulation. Check the application conditions and scientific "
        "sources.",
    ),
    "HEADLINE_VALID_VARIANT": (
        "Protocolo «{name}» cargado. Puedes iniciar la simulación. Consulta sus condiciones y fuentes.",
        "Protocol «{name}» loaded. You can start the simulation. Check its conditions and sources.",
    ),
    "HEADLINE_OUT_OF_RANGE": (
        "{param_name} está fuera del intervalo documentado para este protocolo. Puedes volver al valor de referencia o "
        "continuar en modo exploración cualitativa.",
        "{param_name} is outside the documented interval for this protocol. You can go back to the reference value or "
        "continue in qualitative exploration mode.",
    ),
    "HEADLINE_OUT_OF_RANGE_SOFT": (
        "{param_name} está fuera del intervalo documentado. El modelo sigue siendo aplicable, pero tu práctica no "
        "coincide con la fuente: revisa el valor de referencia.",
        "{param_name} is outside the documented interval. The model still applies, but your practice does not match "
        "the source: check the reference value.",
    ),
    "HEADLINE_PARTIAL": (
        "Este tratamiento puede estudiarse de forma educativa. Sin embargo, todavía no hay datos suficientes para "
        "calcular su dureza o fracciones microestructurales con rigor.",
        "This treatment can be studied educationally. However, there is not yet enough data to compute its hardness or "
        "microstructural fractions rigorously.",
    ),
    "HEADLINE_DEPENDENCY": (
        "El revenido requiere una microestructura inicial apropiada. Se utilizará una muestra previamente templada de "
        "referencia.",
        "Tempering requires an appropriate initial microstructure. A previously hardened reference sample will be used.",
    ),
    "HEADLINE_UNVERIFIED": (
        "Variante con fuente no verificada: el ciclo se muestra como demostración ilustrativa, sin predicciones.",
        "Variant with an unverified source: the cycle is shown as an illustrative demonstration, without predictions.",
    ),
    "HEADLINE_ILLUSTRATIVE": (
        "Demostración educativa ilustrativa: no se trata de una predicción experimental.",
        "Illustrative educational demonstration: this is not an experimental prediction.",
    ),
}

ASSUMPTIONS: dict[str, tuple[str, str]] = {
    "MODEL_ESTIMATES": (
        "Origen de las cifras: fases, constituyentes, dureza y diagramas se calculan con modelos publicados "
        "(Li 1998, Koistinen–Marburger 1959, Maynier 1978, Kang y Lee 2014) para una probeta de 12,7 mm, en el "
        "centro. Son estimaciones de modelo, no mediciones de laboratorio; la banda indica la incertidumbre.",
        "Origin of the figures: phases, constituents, hardness and diagrams are computed with published models "
        "(Li 1998, Koistinen–Marburger 1959, Maynier 1978, Kang and Lee 2014) for a 12.7 mm specimen, at the "
        "center. They are model estimates, not laboratory measurements; the band shows the uncertainty.",
    ),
    "GRAIN_MODEL": (
        "Tamaño de grano: grano austenítico previo con el modelo de Lee y Lee (2008) a partir de la temperatura y "
        "el tiempo reales por encima de Ae3 (regla de aditividad); número ASTM por la relación de intercepto de "
        "ASTM E112. En recocido y normalizado del 8620 se añade el grano ferrítico de Hodgson y Gibbs (1992). "
        "Ese tamaño de grano alimenta también la cinética de transformación y el dibujo del microscopio. "
        "Entre 830 y 850 °C el modelo se aplica como extrapolación corta (los datos de ajuste empiezan en 850 °C).",
        "Grain size: prior-austenite grain from the Lee and Lee (2008) model using the actual temperature and time "
        "above Ae3 (additivity rule); ASTM number from the ASTM E112 intercept relation. For 8620 annealing and "
        "normalizing the ferrite grain of Hodgson and Gibbs (1992) is added. This grain size also feeds the "
        "transformation kinetics and the microscope drawing. Between 830 and 850 °C the model is applied as a short "
        "extrapolation (the fitting data start at 850 °C).",
    ),
    "STRENGTH_FROM_HARDNESS": (
        "Resistencia a tracción y límite de fluencia calculados desde la dureza HV con las correlaciones de Pavlina "
        "y Van Tyne (2008) para aceros hipoeutectoides no austeníticos (válidas entre 129 y 632 HV para fluencia y "
        "129–592 HV para tracción). La banda solo refleja la de la dureza, no la dispersión de la correlación.",
        "Tensile and yield strength computed from HV hardness with the Pavlina and Van Tyne (2008) correlations "
        "for non-austenitic hypoeutectoid steels (valid 129–632 HV for yield and 129–592 HV for tensile). The band "
        "only reflects the hardness band, not the scatter of the correlation.",
    ),
    "GJL250_CLASS_REFERENCE": (
        "Fundición gris GG25 (EN-GJL-250): la norma EN 1561 define el grado por la resistencia mínima a tracción "
        "(250 MPa) en barra de ensayo de 30 mm, sin tratamiento térmico (equivale a ASTM A48 clase 35). Se muestra "
        "como referencia; FERROLAB no calcula cómo la cambia el tratamiento.",
        "GG25 (EN-GJL-250) gray iron: EN 1561 defines the grade by its minimum tensile strength (250 MPa) on a "
        "30 mm test bar, without heat treatment (equivalent to ASTM A48 class 35). It is shown as a reference; "
        "FERROLAB does not compute how the treatment changes it.",
    ),
    "GRAY_HARDNESS_LITERATURE": (
        "Dureza de la fundición gris: valor PUBLICADO de otra muestra en una condición parecida (se indica cuál), no "
        "un cálculo de tu probeta. Temple: 400–500 HB en superficie templada a la llama de una fundición sin alear "
        "(3 % C, 1,7 % Si; Total Materia). Austemperizado: 247,6 HBW tras austenizar a 930 °C frente a 187,6 HBW en "
        "bruto de colada (Applied Sciences 2026, 16:1828).",
        "Gray iron hardness: PUBLISHED value from another specimen in a similar condition (stated), not a "
        "computation for your specimen. Quench: 400–500 HB on a flame-hardened surface of an unalloyed iron (3% C, "
        "1.7% Si; Total Materia). Austempering: 247.6 HBW after austenitizing at 930 °C versus 187.6 HBW as cast "
        "(Applied Sciences 2026, 16:1828).",
    ),
    "REVIEW_STATUS": (
        "Estado de revisión: el catálogo y los textos aún no han sido revisados por una persona con formación "
        "metalúrgica; cada cifra indica su fuente y su método.",
        "Review status: the catalog and texts have not yet been reviewed by a person with metallurgical "
        "training; each figure states its source and method.",
    ),
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
    "preheat": ("Precalentamiento lento", "Slow preheating"),
    "heat_to_austenitizing_model": ("Calentamiento en horno", "Furnace heating"),
}


def localize(table: dict[str, tuple[str, str]], code: str, locale: str, **params: object) -> str:
    es, en = table.get(code, (code, code))
    text = en if locale == "en" else es
    try:
        return text.format(**params)
    except (KeyError, IndexError):
        return text
