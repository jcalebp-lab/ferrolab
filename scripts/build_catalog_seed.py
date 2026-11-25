"""Genera `database/seeds/catalog_seed.json`: catálogo inicial SIN cifras inventadas.

Contenido: metadatos y textos cualitativos en borrador (`draft`). La única cifra
física incluida es el punto de fusión del hierro puro, usada exclusivamente
como límite de BLOQUEO, marcada como pendiente de verificación humana
(ver docs/DECISIONS.md, D-07).

Uso:  uv run python scripts/build_catalog_seed.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "database" / "seeds" / "catalog_seed.json"
sys.path.insert(0, str(Path(__file__).resolve().parent))
import protocol_library as LIB  # noqa: E402  (biblioteca de protocolos de referencia, D-30)


def src(id, kind, title, **kw):
    return {"id": id, "kind": kind, "title": title, "verification_status": "unverified", **kw}


SOURCES = [
    src("src_callister", "book", "Materials Science and Engineering: An Introduction",
        authors="W. D. Callister Jr., D. G. Rethwisch", notes="Edición y localizadores pendientes de registrar."),
    src("src_asm_4a", "book", "ASM Handbook, Vol. 4A: Steel Heat Treating Fundamentals and Processes",
        publisher="ASM International"),
    src("src_asm_4d", "book", "ASM Handbook, Vol. 4D: Heat Treating of Irons and Steels", publisher="ASM International"),
    src("src_asm_9", "book", "ASM Handbook, Vol. 9: Metallography and Microstructures", publisher="ASM International"),
    src("src_asm_1", "book", "ASM Handbook, Vol. 1: Properties and Selection: Irons, Steels, and High-Performance Alloys",
        publisher="ASM International"),
    src("src_asm_15", "book", "ASM Handbook, Vol. 15: Casting", publisher="ASM International"),
    src("src_krauss", "book", "Steels: Processing, Structure, and Performance", authors="G. Krauss"),
    src("src_bhadeshia", "book", "Steels: Microstructure and Properties", authors="H. K. D. H. Bhadeshia, R. W. K. Honeycombe"),
    src("src_totten", "book", "Steel Heat Treatment: Metallurgy and Technologies", authors="G. E. Totten (ed.)"),
    src("src_angus", "book", "Cast Iron: Physical and Engineering Properties", authors="H. T. Angus"),
    src("src_astm_a48", "standard", "ASTM A48/A48M — Standard Specification for Gray Iron Castings",
        url="https://store.astm.org/standards/a48"),
    src("src_astm_a247", "standard", "ASTM A247 — Standard Test Method for Evaluating the Microstructure of Graphite in Iron Castings",
        url="https://store.astm.org/a0247-19.html"),
    src("src_astm_a29", "standard", "ASTM A29/A29M — Standard Specification for General Requirements for Steel Bars, Carbon and Alloy, Hot-Wrought (composición de los grados AISI/SAE)",
        url="https://store.astm.org/a0029_a0029m-23.html"),
    src("src_astm_e3", "standard", "ASTM E3 — Standard Guide for Preparation of Metallographic Specimens",
        url="https://store.astm.org/e0003-11r17.html"),
    src("src_astm_e407", "standard", "ASTM E407 — Standard Practice for Microetching Metals and Alloys",
        url="https://store.astm.org/e0407-23.html"),
    src("src_astm_e18", "standard", "ASTM E18 — Standard Test Methods for Rockwell Hardness of Metallic Materials",
        url="https://store.astm.org/e0018-22.html"),
    src("src_astm_e10", "standard", "ASTM E10 — Standard Test Method for Brinell Hardness of Metallic Materials",
        url="https://store.astm.org/e0010-18.html"),
    src("src_astm_e92", "standard", "ASTM E92 — Standard Test Methods for Vickers Hardness and Knoop Hardness of Metallic Materials",
        url="https://store.astm.org/e0092-23.html"),
    src("src_astm_e8", "standard", "ASTM E8/E8M — Standard Test Methods for Tension Testing of Metallic Materials",
        url="https://store.astm.org/e0008_e0008m-24.html"),
    src("src_astm_e23", "standard", "ASTM E23 — Standard Test Methods for Notched Bar Impact Testing of Metallic Materials (Charpy)",
        url="https://store.astm.org/e0023-24.html"),
    src("src_astm_a255", "standard", "ASTM A255 — Determining Hardenability of Steel (Jominy)",
        url="https://store.astm.org/standards/a255"),
    src("src_astm_e112", "standard", "ASTM E112 — Determining Average Grain Size", url="https://store.astm.org/standards/e112"),
    src("src_astm_e562", "standard", "ASTM E562 — Volume Fraction by Systematic Manual Point Count",
        url="https://store.astm.org/standards/e562"),
    src("src_astm_e140", "standard", "ASTM E140 — Hardness Conversion Tables for Metals", url="https://store.astm.org/standards/e140"),
    src("src_km_1959", "article",
        "A general equation prescribing the extent of the austenite-martensite transformation in pure iron-carbon alloys and plain carbon steels",
        authors="D. P. Koistinen, R. E. Marburger", year=1959, doi="10.1016/0001-6160(59)90170-1",
        url="https://doi.org/10.1016/0001-6160(59)90170-1", notes="Acta Metallurgica 7(1), 59–60."),
    src("src_andrews_1965", "article", "Empirical formulae for the calculation of some transformation temperatures",
        authors="K. W. Andrews", year=1965, notes="Journal of the Iron and Steel Institute 203, 721–727."),
]

EVIDENCE = [
    {
        "id": "ev_fe_melting_point",
        "source_id": "src_callister",
        "locator": None,
        "claim_es": "Punto de fusión del hierro puro (diagrama Fe–Fe3C). Usado solo como límite de bloqueo.",
        "claim_en": "Melting point of pure iron (Fe–Fe3C diagram). Used only as a blocking limit.",
        "evidence_kind": "literature",
        "evidence_level": "qualitative",
        "method": "physical_constant_guard",
        "value": 1538.0,
        "unit": "°C",
        "review_status": "draft",
    }
]

GUARD_REASON_ES = (
    "Punto de fusión del hierro puro. Los aceros y fundiciones de este catálogo empiezan a fundir por debajo "
    "de él (su temperatura de sólido real no está publicada aquí), así que a esta temperatura o más no existe "
    "un tratamiento en estado sólido."
)
GUARD_REASON_EN = (
    "Melting point of pure iron. The steels and cast irons in this catalog start melting below it (their actual "
    "solidus is not published here), so at or above this temperature no solid-state treatment exists."
)
GUARDS = [
    {"id": f"guard_{fam}", "applies_to_family": fam, "max_temperature_c": 1538.0, "reason_es": GUARD_REASON_ES,
     "reason_en": GUARD_REASON_EN, "evidence_id": "ev_fe_melting_point", "review_status": "draft"}
    for fam in ("steel", "gray_cast_iron")
]

MATERIALS = [
    {
        "id": "aisi_1045",
        "family": "steel",
        "display_name": "AISI 1045",
        "standard_note_es": "Designación AISI/SAE de la serie 10xx (aceros al carbono simples).",
        "standard_note_en": "AISI/SAE 10xx series designation (plain carbon steels).",
        "description_es": (
            "Acero al carbono de contenido medio. En la serie 10xx los dos últimos dígitos indican el carbono "
            "nominal en centésimas de por ciento en masa. Se usa en ejes, pernos y piezas de maquinaria."
        ),
        "description_en": (
            "Medium-carbon steel. In the 10xx series the last two digits give the nominal carbon in hundredths "
            "of a percent by mass. Used for shafts, bolts and machine parts."
        ),
        "limitations_es": [
            "La composición real varía entre lotes; se usa el rango de la norma (AZoM) y su incertidumbre.",
            "La condición de suministro (laminado, normalizado, etc.) no está documentada.",
        ],
        "limitations_en": [
            "Actual composition varies between heats; the standard range (AZoM) and its uncertainty are used.",
            "The as-supplied condition (rolled, normalized, etc.) is not documented.",
        ],
        "compositions": [],
        "suggested_source_ids": ["src_asm_1", "src_callister"],
        "review_status": "draft",
    },
    {
        "id": "aisi_8620",
        "family": "steel",
        "display_name": "AISI 8620",
        "standard_note_es": "Designación AISI/SAE de la serie 86xx (aceros aleados al níquel-cromo-molibdeno).",
        "standard_note_en": "AISI/SAE 86xx series designation (nickel-chromium-molybdenum alloy steels).",
        "description_es": (
            "Acero aleado de bajo carbono con níquel, cromo y molibdeno. Se emplea con frecuencia cementado "
            "(engranajes, piñones), pero la cementación es un proceso distinto que aquí no se asume."
        ),
        "description_en": (
            "Low-carbon alloy steel with nickel, chromium and molybdenum. It is often used carburized (gears, "
            "pinions), but carburizing is a separate process that is not assumed here."
        ),
        "limitations_es": [
            "Sin estado cementado documentado no se atribuyen propiedades de capa (dureza superficial, profundidad).",
            "Rango composicional de la norma según Vanguard (sección 1, pág. 13).",
        ],
        "limitations_en": [
            "Without a documented carburized state, no case properties (surface hardness, depth) are attributed.",
            "Standard composition range per Vanguard (section 1, p. 13).",
        ],
        "compositions": [],
        "suggested_source_ids": ["src_asm_1", "src_krauss"],
        "review_status": "draft",
    },
    {
        "id": "astm_a48_class_35",
        "family": "gray_cast_iron",
        "display_name": "ASTM A48 Clase 35",
        "standard_note_es": (
            "ASTM A48/A48M clasifica la fundición gris por su resistencia mínima a la tracción en ksi: la clase 35 exige "
            "35 ksi (≈ 241 MPa) en una barra de ensayo colada aparte (letras A, B o C según el diámetro de la barra). "
            "La estructura del grafito se describe con ASTM A247."
        ),
        "standard_note_en": (
            "ASTM A48/A48M classifies gray iron by its minimum tensile strength in ksi: class 35 requires 35 ksi "
            "(≈ 241 MPa) on a separately cast test bar (letters A, B or C by bar diameter). Graphite structure is "
            "described with ASTM A247."
        ),
        "description_es": (
            "Fundición gris de grafito laminar y matriz principalmente perlítica. No es un acero. Se usa en bancadas, "
            "carcasas, bloques de motor y discos de freno por su colabilidad, maquinabilidad y amortiguación."
        ),
        "description_en": (
            "Flake-graphite gray iron with a mainly pearlitic matrix. It is not a steel. Used for machine beds, "
            "housings, engine blocks and brake discs for its castability, machinability and damping."
        ),
        "limitations_es": [
            "ASTM A48 no fija la composición química ni la dureza: solo la resistencia mínima en la barra de ensayo.",
            "La resistencia real de una pieza baja con el espesor de la sección; la barra de ensayo no representa toda la pieza.",
            "La matriz y la morfología del grafito dependen del proceso de fundición y del espesor de la pieza.",
            "No se usan curvas ni modelos del acero para esta fundición.",
        ],
        "limitations_en": [
            "ASTM A48 does not fix chemical composition or hardness: only the minimum strength on the test bar.",
            "The actual strength of a part falls with section thickness; the test bar does not represent the whole part.",
            "The matrix and graphite morphology depend on the casting process and section thickness.",
            "Steel curves and models are not used for this cast iron.",
        ],
        "compositions": [],
        "suggested_source_ids": ["src_astm_a48", "src_astm_a247", "src_angus", "src_asm_15"],
        "review_status": "draft",
    },
]

INITIAL_CONDITIONS = [
    {
        "id": "ic_aisi_1045_unspecified",
        "material_id": "aisi_1045",
        "name_es": "Condición de suministro no documentada",
        "name_en": "Undocumented as-supplied condition",
        "description_es": "No se conoce el tratamiento previo. No se asume que esté templado.",
        "description_en": "Prior treatment unknown. It is not assumed to be hardened.",
        "hardened": None,
        "carburized": None,
        "review_status": "draft",
    },
    {
        "id": "ic_aisi_8620_not_carburized",
        "material_id": "aisi_8620",
        "name_es": "No cementado, condición previa no documentada",
        "name_en": "Not carburized, prior condition undocumented",
        "description_es": "Se modela explícitamente como NO cementado. Tratamiento previo desconocido.",
        "description_en": "Explicitly modeled as NOT carburized. Prior treatment unknown.",
        "hardened": None,
        "carburized": False,
        "review_status": "draft",
    },
    {
        "id": "ic_a48c35_as_cast_unspecified",
        "material_id": "astm_a48_class_35",
        "name_es": "Bruto de colada, matriz no documentada",
        "name_en": "As-cast, matrix undocumented",
        "description_es": (
            "Grafito laminar (propio de la fundición gris); tipo y tamaño de láminas y composición de la matriz "
            "no documentados."
        ),
        "description_en": (
            "Flake graphite (characteristic of gray iron); flake type and size and matrix constitution "
            "undocumented."
        ),
        "hardened": None,
        "carburized": None,
        "matrix": None,
        "graphite_morphology": "flake",
        "review_status": "draft",
    },
]


def tpl(kind, label, level, user_hold=False):
    return {"kind": kind, "label_key": label, "end_level": level, "user_hold": user_hold}


OUTLINES = {
    "quench": [tpl("heat", "heat_to_austenitizing", "target"), tpl("hold", "hold_austenitizing", "target", True),
               tpl("transfer", "transfer_to_medium", "target"), tpl("cool", "quench_cool", "ambient")],
    "temper": [tpl("heat", "heat_to_temper", "target"), tpl("hold", "hold_temper", "target", True),
               tpl("cool", "controlled_cool", "ambient")],
    "anneal": [tpl("heat", "heat_to_target", "target"), tpl("hold", "hold_target", "target", True),
               tpl("cool", "anneal_cool", "ambient")],
    "normalize": [tpl("heat", "heat_to_austenitizing", "target"), tpl("hold", "hold_austenitizing", "target", True),
                  tpl("cool", "air_cool", "ambient")],
    "austemper": [tpl("heat", "heat_to_austenitizing", "target"), tpl("hold", "hold_austenitizing", "target", True),
                  tpl("transfer", "transfer_to_bath", "target"), tpl("cool", "cool_to_bath", "bath"),
                  tpl("isothermal_hold", "isothermal_bath_hold", "bath"), tpl("cool", "final_cool", "ambient")],
    "quench_temper": [tpl("heat", "heat_to_austenitizing", "target"), tpl("hold", "hold_austenitizing", "target"),
                      tpl("transfer", "transfer_to_medium", "target"), tpl("cool", "quench_cool", "ambient"),
                      tpl("heat", "heat_to_temper", "target"), tpl("hold", "hold_temper", "target", True),
                      tpl("cool", "controlled_cool", "ambient")],
    "martemper": [tpl("heat", "heat_to_austenitizing", "target"), tpl("hold", "hold_austenitizing", "target", True),
                  tpl("transfer", "transfer_to_bath", "target"), tpl("cool", "cool_to_bath", "bath"),
                  tpl("isothermal_hold", "equalization_hold", "bath"), tpl("cool", "final_cool", "ambient")],
}

TREATMENTS = [
    {
        "id": "quench", "name_es": "Temple", "name_en": "Quenching",
        "purpose_es": "Endurecer el acero: se austeniza y luego se enfría con rapidez para que la austenita se transforme en martensita.",
        "purpose_en": "Harden steel: it is austenitized and then cooled rapidly so that austenite transforms into martensite.",
        "prerequisites_es": "Austenitización adecuada para la composición del acero y un medio cuya severidad sea compatible con su templabilidad.",
        "prerequisites_en": "Austenitizing suited to the steel's composition and a medium whose severity matches its hardenability.",
        "qualitative_outcome_es": (
            "Si el enfriamiento es lo bastante rápido para la templabilidad del acero, puede formarse martensita: "
            "dureza alta, fragilidad y tensiones residuales. Si no lo es, aparecen constituyentes difusionales "
            "(perlita, bainita). Normalmente se reviene después. La cantidad y dureza dependen de composición, "
            "tamaño de pieza y trayectoria real, que aquí no se calculan."
        ),
        "qualitative_outcome_en": (
            "If cooling is fast enough for the steel's hardenability, martensite can form: high hardness, "
            "brittleness and residual stress. Otherwise diffusional constituents (pearlite, bainite) appear. It is "
            "usually tempered afterwards. Amounts and hardness depend on composition, part size and the real "
            "path, which are not calculated here."
        ),
        "suggested_source_ids": ["src_asm_4a", "src_krauss", "src_callister"],
    },
    {
        "id": "temper", "name_es": "Revenido", "name_en": "Tempering",
        "purpose_es": "Reducir la fragilidad y las tensiones de un acero templado calentándolo por debajo de la temperatura crítica inferior.",
        "purpose_en": "Reduce the brittleness and stresses of a quenched steel by heating it below the lower critical temperature.",
        "prerequisites_es": "Un estado inicial endurecido (templado) documentado. Sin él, el revenido no tiene un punto de partida definido.",
        "prerequisites_en": "A documented hardened (quenched) initial state. Without it, tempering has no defined starting point.",
        "qualitative_outcome_es": (
            "En general la martensita revenida pierde dureza y gana tenacidad a medida que aumentan temperatura y "
            "tiempo; la magnitud depende del acero y requiere correlaciones validadas."
        ),
        "qualitative_outcome_en": (
            "In general tempered martensite loses hardness and gains toughness as temperature and time increase; "
            "the magnitude depends on the steel and requires validated correlations."
        ),
        "suggested_source_ids": ["src_krauss", "src_asm_4a"],
    },
    {
        "id": "anneal", "name_es": "Recocido", "name_en": "Annealing",
        "purpose_es": "Ablandar, homogeneizar o aliviar tensiones. Agrupa variantes distintas: completo, subcrítico, de esferoidización, de alivio de tensiones.",
        "purpose_en": "Soften, homogenize or relieve stresses. It groups distinct variants: full, subcritical, spheroidizing, stress relief.",
        "prerequisites_es": "Definir la variante; cada una tiene temperatura y enfriamiento propios.",
        "prerequisites_en": "Define the variant; each one has its own temperature and cooling.",
        "qualitative_outcome_es": (
            "En un recocido completo de un acero hipoeutectoide, el enfriamiento lento favorece ferrita y perlita "
            "gruesa y baja dureza. En la fundición gris, ciertos recocidos buscan una matriz más ferrítica. Sin la "
            "variante y el protocolo no se puede concluir más."
        ),
        "qualitative_outcome_en": (
            "In a full anneal of a hypoeutectoid steel, slow cooling favors ferrite and coarse pearlite and low "
            "hardness. In gray iron, some anneals aim for a more ferritic matrix. Without the variant and protocol "
            "nothing more can be concluded."
        ),
        "suggested_source_ids": ["src_asm_4a", "src_callister"],
    },
    {
        "id": "normalize", "name_es": "Normalizado", "name_en": "Normalizing",
        "purpose_es": "Afinar y homogeneizar la estructura: se austeniza por completo y se enfría al aire en calma.",
        "purpose_en": "Refine and homogenize the structure: fully austenitize and cool in still air.",
        "prerequisites_es": "Calentamiento a la región austenítica adecuada para la composición.",
        "prerequisites_en": "Heating into the austenite region appropriate for the composition.",
        "qualitative_outcome_es": (
            "En aceros hipoeutectoides suele dar ferrita y perlita más finas que un recocido completo, con algo más "
            "de resistencia. El enfriamiento al aire depende del tamaño de la pieza, que aquí no se modela."
        ),
        "qualitative_outcome_en": (
            "In hypoeutectoid steels it usually gives finer ferrite and pearlite than a full anneal, with somewhat "
            "higher strength. Air cooling depends on part size, which is not modeled here."
        ),
        "suggested_source_ids": ["src_asm_4a", "src_callister"],
    },
    {
        "id": "austemper", "name_es": "Austempering", "name_en": "Austempering",
        "purpose_es": "Obtener bainita: se austeniza, se enfría a un baño por encima de Ms y se mantiene isotérmicamente hasta transformar.",
        "purpose_en": "Obtain bainite: austenitize, cool into a bath above Ms and hold isothermally until transformation.",
        "prerequisites_es": "Templabilidad suficiente para llegar al baño sin transformación previa y un protocolo de baño revisado (temperatura y tiempo).",
        "prerequisites_en": "Enough hardenability to reach the bath without prior transformation and a reviewed bath protocol (temperature and time).",
        "qualitative_outcome_es": (
            "Busca bainita con buena tenacidad y menos distorsión que un temple convencional; no suele requerir "
            "revenido. Requiere datos isotérmicos (TTT) del material concreto."
        ),
        "qualitative_outcome_en": (
            "It aims for bainite with good toughness and less distortion than conventional quenching; it usually "
            "does not require tempering. It requires isothermal (TTT) data for the specific material."
        ),
        "suggested_source_ids": ["src_asm_4a", "src_bhadeshia"],
    },
    {
        "id": "martemper", "name_es": "Martempering", "name_en": "Martempering (marquenching)",
        "purpose_es": "Templar con menos distorsión: se enfría a un baño ligeramente por encima de Ms, se iguala la temperatura y después se enfría a través de la transformación martensítica.",
        "purpose_en": "Quench with less distortion: cool into a bath slightly above Ms, equalize temperature, then cool through the martensitic transformation.",
        "prerequisites_es": "Protocolo de baño e igualación revisado, para que no se forme bainita durante la espera.",
        "prerequisites_en": "Reviewed bath and equalization protocol, so that no bainite forms during the wait.",
        "qualitative_outcome_es": (
            "El objetivo es martensita con menores gradientes térmicos y tensiones que en un temple directo; "
            "después normalmente se reviene. No es lo mismo que austempering, cuyo objetivo es bainita."
        ),
        "qualitative_outcome_en": (
            "The goal is martensite with lower thermal gradients and stresses than direct quenching; it is usually "
            "tempered afterwards. It is not the same as austempering, whose goal is bainite."
        ),
        "suggested_source_ids": ["src_asm_4a", "src_totten"],
    },
    {
        "id": "quench_temper", "name_es": "Bonificado", "name_en": "Quench and temper",
        "purpose_es": "Temple seguido de un revenido a alta temperatura (≈ 550–650 °C en aceros): busca la mejor "
                      "combinación de resistencia y tenacidad.",
        "purpose_en": "Hardening followed by a high-temperature temper (≈ 550–650 °C in steels): it seeks the best "
                      "combination of strength and toughness.",
        "prerequisites_es": "Templabilidad suficiente para formar martensita en la sección y un revenido por debajo de Ac1.",
        "prerequisites_en": "Enough hardenability to form martensite across the section and a temper below Ac1.",
        "qualitative_outcome_es": (
            "Martensita revenida a alta temperatura (sorbita): menos dureza que el temple, mucha más tenacidad y "
            "resistencia a la fatiga. Es el tratamiento habitual de ejes, bielas y engranajes no cementados."
        ),
        "qualitative_outcome_en": (
            "Martensite tempered at high temperature (sorbite): lower hardness than as-quenched, much higher "
            "toughness and fatigue strength. It is the usual treatment for shafts, connecting rods and "
            "non-carburized gears."
        ),
        "suggested_source_ids": ["src_krauss", "src_asm_4a"],
    },
]
_ORDER = ["quench", "temper", "quench_temper", "anneal", "normalize", "austemper", "martemper"]
TREATMENTS.sort(key=lambda t: _ORDER.index(t["id"]))
for t in TREATMENTS:
    t["stage_outline"] = OUTLINES[t["id"]]
    t["review_status"] = "draft"

MEDIUM = {
    "quench": ("Medio de temple pendiente de protocolo revisado", "Quench medium pending reviewed protocol"),
    "temper": ("Enfriamiento posterior pendiente de protocolo", "Subsequent cooling pending protocol"),
    "anneal": ("Pendiente: depende de la variante de recocido", "Pending: depends on the annealing variant"),
    "normalize": ("Aire en calma (definición del proceso)", "Still air (process definition)"),
    "austemper": ("Baño isotérmico: tipo y temperatura pendientes", "Isothermal bath: type and temperature pending"),
    "martemper": ("Baño cercano a Ms: tipo y temperatura pendientes", "Bath near Ms: type and temperature pending"),
    "quench_temper": ("Medio de temple y revenido según el protocolo", "Quench and temper media per protocol"),
}

# ---------------------------------------------------------------------- artículos de acceso libre (D-39)
# Solo artículos e informes de ACCESO LIBRE cuya existencia, autores, revista, DOI y conclusiones se comprobaron en su
# resumen o ficha pública (MDPI, PubMed Central, Scientific Reports, J-STAGE, NIST, revistas colombianas en OJS).
def art(id, title, authors, year, journal, *, doi=None, url, notes):
    return {"id": id, "kind": "article", "title": title, "authors": authors, "year": year, "edition": journal,
            "doi": doi, "url": url, "verification_status": "verified", "license_code": "open_access", "notes": notes}


ARTICLES = [
    art("src_art_collins_2023", "A Rapid, Open-Source CCT Predictor for Low-Alloy Steels, and Its Application to Compositionally Heterogeneous Material",
        "J. Collins, M. Piemonte, M. Taylor, J. Fellowes, E. Pickering", 2023, "Metals 13(7):1168",
        doi="10.3390/met13071168", url="https://www.mdpi.com/2075-4701/13/7/1168", notes="MDPI, acceso abierto (CC BY)."),
    art("src_art_razali_2023", "Practical Approach for Determining Material Parameters When Predicting Austenite Grain Growth under Isothermal Heat Treatment",
        "M. K. Razali, A. A. Abd Ghawi, M. Irani, S. H. Chung, J. M. Choi, M. S. Joun", 2023, "Materials 16(19):6583",
        doi="10.3390/ma16196583", url="https://www.mdpi.com/1996-1944/16/19/6583", notes="MDPI y PubMed Central (PMC10574047)."),
    art("src_art_kang_lee_2014", "Prediction of Tempered Martensite Hardness Incorporating the Composition-Dependent Tempering Parameter in Low Alloy Steels",
        "S. Kang, S.-J. Lee", 2014, "Materials Transactions 55(7):1069", doi="10.2320/matertrans.M2014004",
        url="https://www.jstage.jst.go.jp/article/matertrans/55/7/55_M2014004/_article", notes="J-STAGE, lectura libre."),
    art("src_art_nist_2025", "Using \u201cOff-the-Shelf\u201d AISI 4340 Steel for the Production of NIST Reference Charpy Specimens",
        "E. Lucon, A. Eckhardt, R. Santoyo", 2025, "NIST Interagency Report 8556", doi="10.6028/NIST.IR.8556",
        url="https://nvlpubs.nist.gov/nistpubs/ir/2025/NIST.IR.8556.pdf", notes="Informe gratuito del NIST."),
    art("src_art_vieira_2021", "Evaluation of the characteristics of an AISI 1045 steel quenched in different concentration of polymer solutions of polyvinylpyrrolidone",
        "E. da Rosa Vieira, L. V. Biehl, J. L. B. Medeiros, V. M. Costa, R. J. Macedo", 2021, "Scientific Reports 11 (2021)",
        doi="10.1038/s41598-020-79060-0", url="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7809479/",
        notes="Scientific Reports y PubMed Central, acceso abierto."),
    art("src_art_mazuera_2011", "Evaluación de los parámetros de temple y revenido para el acero AISI/SAE 1045 a escala industrial",
        "D. Mazuera, A. Ortiz", 2011, "Scientia et Technica 16(49):25–29 (Universidad Tecnológica de Pereira)",
        url="https://ojs2.utp.edu.co/index.php/revistaciencia/article/view/1461", notes="Revista colombiana de acceso abierto."),
    art("src_art_garzon_2016", "Influencia en las propiedades mecánicas del acero AISI-SAE 1045 tratado térmicamente con temple a temperatura intercrítica y revenido",
        "J. R. Garzón Torres, C. A. Bohórquez Ávila, M. E. Hernández, H. F. Rojas Molano", 2016,
        "Avances: Investigación en Ingeniería 13(1) (Universidad Libre)", doi="10.18041/1794-4953/avances.2.257",
        url="https://revistas.unilibre.edu.co/index.php/avances/article/view/257", notes="Revista colombiana de acceso abierto."),
    art("src_art_castillo_2018", "Caracterización microestructural y mecánica de aceros de fase dual (ferrita-martensita), obtenidos mediante procesos térmicos y termomecánicos",
        "D. E. Castillo-Gutiérrez, I. I. Angarita-Moncaleano, R. Rodríguez-Baracaldo", 2018,
        "Ingeniare. Revista chilena de ingeniería 26(3):430–439", doi="10.4067/s0718-33052018000300430",
        url="https://scielo.conicyt.cl/pdf/ingeniare/v26n3/0718-3305-ingeniare-26-03-00430.pdf", notes="SciELO, acceso abierto."),
    art("src_art_wang_2019", "Wear Behavior of Austempered and Quenched and Tempered Gray Cast Irons under Similar Hardness",
        "B. Wang, X. Han, G. Barber, Y. Pan", 2019, "Metals 9(12):1329", doi="10.3390/met9121329",
        url="https://www.mdpi.com/2075-4701/9/12/1329", notes="MDPI, acceso abierto (CC BY)."),
    art("src_art_zhu_2026", "Effect of Different Austenitizing Temperatures on the Microstructure and Mechanical Properties of Austempering Gray Cast Iron",
        "S. Zhu, H. Zhang, F. Han, Y. Hao, X. Liu, et al.", 2026, "Applied Sciences 16(4):1828", doi="10.3390/app16041828",
        url="https://www.mdpi.com/2076-3417/16/4/1828", notes="MDPI, acceso abierto (CC BY)."),
]
SOURCES += ARTICLES


def protocol_stages(tid):
    stages = []
    for i, t in enumerate(OUTLINES[tid], start=1):
        stages.append({
            "ordinal": i, "kind": t["kind"], "label_key": t["label_key"], "end_level": t["end_level"],
            "end_temperature_mode": "user_target" if t["end_level"] == "target" and t["kind"] != "transfer" else (
                "unpublished" if t["end_level"] != "ambient" else "ambient"),
            "duration_mode": "user_hold" if t["user_hold"] else "unpublished",
        })
    return stages


R = {  # (estado, razón ES, razón EN)
    "steel_quench": ("conditional", "Pendiente de un protocolo de austenitización y temple revisado para esta condición.",
                     "Pending a reviewed austenitizing and quenching protocol for this condition."),
    "steel_temper": ("educational_only", "No hay un estado inicial templado documentado; el revenido no se cuantifica ni se asume un temple previo.",
                     "There is no documented quenched initial state; tempering is not quantified and no prior quench is assumed."),
    "steel_anneal": ("conditional", "Pendiente de definir la variante de recocido y su protocolo revisado.",
                     "Pending definition of the annealing variant and its reviewed protocol."),
    "steel_normalize": ("conditional", "Pendiente de un protocolo de normalizado revisado para esta condición.",
                        "Pending a reviewed normalizing protocol for this condition."),
    "steel_austemper": ("educational_only", "Pendiente de un protocolo isotérmico revisado y datos TTT de este acero.",
                        "Pending a reviewed isothermal protocol and TTT data for this steel."),
    "steel_martemper": ("educational_only", "Pendiente de un protocolo de baño e igualación revisado para este acero.",
                        "Pending a reviewed bath and equalization protocol for this steel."),
    "ci": ("educational_only", "Fundición gris: requiere bibliografía específica; no se extrapolan modelos ni curvas del acero.",
           "Gray cast iron: requires specific literature; steel models and curves are not extrapolated."),
}

PAIRS, PROTOCOLS = LIB.PAIRS, LIB.PROTOCOLS
# Micrografías REALES con licencia libre verificada (Wikimedia Commons): database/seeds/micrographs_curated.json.
_CUR = ROOT / "database" / "seeds" / "micrographs_curated.json"
MICROGRAPHS = json.loads(_CUR.read_text(encoding="utf-8"))["micrographs"] if _CUR.exists() else []
SOURCES.append({"id": "src_wikimedia_commons", "kind": "dataset", "title": "Wikimedia Commons — micrografías con licencia libre",
                "verification_status": "verified", "url": "https://commons.wikimedia.org/",
                "notes": "Licencia, autor y descripción leídos de los metadatos oficiales de cada archivo (API de Commons)."})
SOURCES += LIB.SOURCES
EVIDENCE += LIB.EVIDENCE
INITIAL_CONDITIONS += LIB.INITIAL_CONDITIONS
for _m in MATERIALS:
    _m["compositions"] = LIB.COMPOSITIONS.get(_m["id"], [])


def k(slug, cat, tes, ten, bes, ben, related=(), srcs=("src_callister",)):
    return {"slug": slug, "category": cat, "title_es": tes, "title_en": ten, "body_es": bes, "body_en": ben,
            "related_slugs": list(related), "suggested_source_ids": list(srcs), "review_status": "draft"}


STEELS = ("aisi_1045", "aisi_8620")
AUSTENITIZING = ("quench", "quench_temper", "normalize", "anneal", "austemper", "martemper")
# Ámbito de cada artículo (D-40): materiales, tratamientos, constituyentes y palabras clave con los que se usa como
# fuente en los resultados, el tutor, el glosario y las fichas de tratamiento.
ARTICLE_SCOPE = {
    "art-cct-abierto": (STEELS, ("quench", "normalize", "anneal", "austemper", "martemper", "quench_temper"),
                        ("proeutectoid_ferrite", "pearlite", "bainite", "martensite"),
                        ("cct", "ttt", "diagrama", "diagram", "templabilidad", "hardenability")),
    "art-crecimiento-grano": (STEELS, AUSTENITIZING, (), ("grano", "grain", "astm", "e112", "austeniz")),
    "art-dureza-revenido": (STEELS, ("temper", "quench_temper"), ("tempered_martensite",),
                            ("revenido", "tempering", "temper", "dureza", "hardness", "kang")),
    "art-tenacidad-revenido": (STEELS, ("temper", "quench_temper"), ("tempered_martensite",),
                               ("tenacidad", "toughness", "charpy", "impacto", "impact", "bonificado", "fragil")),
    "art-temple-polimero-1045": (("aisi_1045",), ("quench",), ("martensite",),
                                 ("medio", "medium", "polimero", "polymer", "agua", "water", "aceite", "oil", "severidad")),
    "art-1045-industrial": (("aisi_1045",), ("quench", "temper", "quench_temper"), ("martensite", "tempered_martensite"),
                            ("industrial", "barra", "bar", "austeniz")),
    "art-1045-intercritico": (("aisi_1045",), ("quench", "temper"), ("proeutectoid_ferrite", "martensite", "tempered_martensite"),
                              ("intercritic", "intercrit", "ac1", "ac3")),
    "art-8620-fase-dual": (("aisi_8620",), ("quench", "normalize"), ("proeutectoid_ferrite", "martensite"),
                           ("fase dual", "dual", "grano", "grain", "ferrita", "ferrite")),
    "art-fundicion-austemperizada": (("astm_a48_class_35",), ("austemper", "quench", "temper", "quench_temper"),
                                     ("graphite_flakes", "ausferrite", "bainite", "tempered_martensite"),
                                     ("fundicion", "cast iron", "desgaste", "wear", "ausferrit", "austemper")),
    "art-fundicion-austenizacion": (("astm_a48_class_35",), ("austemper",), ("graphite_flakes", "ausferrite"),
                                    ("fundicion", "cast iron", "ausferrit", "austeniz", "austemper")),
}
# Fichas del glosario que se apoyan en artículos: enlaces y fuentes adicionales.
CONCEPT_ARTICLES = {
    "martensita": ("art-dureza-revenido", "art-temple-polimero-1045"),
    "bainita": ("art-fundicion-austemperizada",),
    "grafito-laminar": ("art-fundicion-austemperizada", "art-fundicion-austenizacion"),
    "ttt": ("art-cct-abierto",), "cct": ("art-cct-abierto",),
    "templabilidad": ("art-temple-polimero-1045", "art-cct-abierto"),
    "faq-velocidad-enfriamiento": ("art-temple-polimero-1045",),
    "faq-martemper-austemper": ("art-fundicion-austemperizada",),
    "faq-fundicion-acero": ("art-fundicion-austemperizada",),
}
# Artículos que se citan como lectura sugerida de cada tratamiento.
TREATMENT_ARTICLES = {
    "quench": ("src_art_vieira_2021", "src_art_mazuera_2011", "src_art_collins_2023"),
    "temper": ("src_art_kang_lee_2014", "src_art_nist_2025"),
    "quench_temper": ("src_art_nist_2025", "src_art_mazuera_2011", "src_art_kang_lee_2014"),
    "normalize": ("src_art_collins_2023", "src_art_razali_2023"),
    "anneal": ("src_art_collins_2023",),
    "austemper": ("src_art_wang_2019", "src_art_zhu_2026"),
    "martemper": ("src_art_collins_2023",),
}


KNOWLEDGE = [
    # ------------------------------------------------------------------ artículos científicos (D-39)
    k("art-cct-abierto", "research", "Un predictor CCT abierto para aceros de baja aleación (Collins et al., 2023)",
      "An open CCT predictor for low-alloy steels (Collins et al., 2023)",
      "Collins y colaboradores implementaron en código abierto el modelo cinético de Li et al. (1998) para predecir diagramas de enfriamiento continuo (CCT) de aceros de baja aleación en menos de 10 segundos (10 velocidades de enfriamiento). Mejoraron las predicciones de varios aceros y ampliaron el modelo para calcular las fracciones finales de constituyentes y la segregación química medida. FERROLAB usa esta misma lógica (ferrita → perlita → bainita y martensita de Koistinen–Marburger) para sus diagramas TTT/CCT.",
      "Collins and co-workers implemented the Li et al. (1998) kinetic model as open-source code to predict continuous cooling transformation (CCT) diagrams of low-alloy steels in under 10 seconds (10 cooling rates). They improved predictions for several steels and extended the model to compute final constituent fractions and measured chemical segregation. FERROLAB uses the same logic (ferrite → pearlite → bainite, and Koistinen–Marburger martensite) for its TTT/CCT diagrams.",
      ["cct", "ttt"], ("src_art_collins_2023",)),
    k("art-crecimiento-grano", "research", "Crecimiento del grano austenítico durante la austenización (Razali et al., 2023)",
      "Austenite grain growth during austenitizing (Razali et al., 2023)",
      "El estudio analiza cómo el tiempo, la temperatura y el tamaño de grano inicial controlan el crecimiento del grano austenítico de un acero de baja aleación durante un tratamiento isotérmico, y ajusta los parámetros del modelo por optimización. Con los parámetros óptimos, el tamaño de grano predicho coincide con el medido. Es el fundamento de que en FERROLAB austenizar más caliente o más tiempo dé un grano más grueso (y un G ASTM E112 menor).",
      "The study analyzes how time, temperature and initial grain size control austenite grain growth of a low-alloy steel during isothermal treatment, fitting the model parameters by optimization. With the optimal parameters, the predicted grain size matches the measured one. It is why in FERROLAB austenitizing hotter or longer gives a coarser grain (and a lower ASTM E112 G).",
      ["templabilidad"], ("src_art_razali_2023", "src_astm_e112")),
    k("art-dureza-revenido", "research", "Dureza de la martensita revenida según la composición (Kang y Lee, 2014)",
      "Hardness of tempered martensite as a function of composition (Kang and Lee, 2014)",
      "Kang y Lee propusieron un parámetro de revenido que depende de la composición del acero (C, Mn, Si, Ni, Cr, Mo) para predecir la dureza de la martensita revenida a partir de la temperatura y el tiempo. FERROLAB lo usa para el revenido y el bonificado de los aceros AISI 1045 y 8620, dentro del rango de validez del artículo (145–716 °C).",
      "Kang and Lee proposed a composition-dependent tempering parameter (C, Mn, Si, Ni, Cr, Mo) to predict tempered martensite hardness from temperature and time. FERROLAB uses it for tempering and quench-and-temper of AISI 1045 and 8620, within the paper's validity range (145–716 °C).",
      ["martensita"], ("src_art_kang_lee_2014",)),
    k("art-tenacidad-revenido", "research", "La temperatura de revenido decide la tenacidad Charpy (NIST, 2025)",
      "Tempering temperature decides Charpy toughness (NIST, 2025)",
      "En el AISI 4340 templado, la energía absorbida en el ensayo Charpy (ASTM E23) depende sobre todo de la temperatura final de revenido: revenir entre 300 y 400 °C da baja energía, mientras que revenir cerca de 600 °C da alta energía, siempre con martensita totalmente revenida. Por eso el bonificado reviene alto: busca tenacidad, no la máxima dureza.",
      "In quenched AISI 4340, the energy absorbed in the Charpy test (ASTM E23) depends mainly on the final tempering temperature: tempering between 300 and 400 °C gives low energy, whereas tempering near 600 °C gives high energy, always with fully tempered martensite. That is why quench-and-temper uses a high temper: it seeks toughness, not maximum hardness.",
      ["martensita"], ("src_art_nist_2025", "src_astm_e23")),
    k("art-temple-polimero-1045", "research", "Temple del AISI 1045 en soluciones de polímero (Vieira et al., 2021)",
      "Quenching AISI 1045 in polymer solutions (Vieira et al., 2021)",
      "Los autores templaron AISI 1045 en soluciones de polivinilpirrolidona (PVP) al 10, 15, 20 y 25 %. La martensita disminuyó al aumentar la concentración (el medio enfría más despacio), la difracción de rayos X no mostró austenita retenida y la dureza bajó desde la superficie hacia el núcleo. Ilustra cómo la severidad del medio cambia la microestructura, igual que en FERROLAB al pasar de agua a aceite.",
      "The authors quenched AISI 1045 in polyvinylpyrrolidone (PVP) solutions at 10, 15, 20 and 25%. Martensite decreased as concentration rose (the medium cools more slowly), X-ray diffraction showed no retained austenite and hardness fell from the surface toward the core. It illustrates how quench severity changes the microstructure, as in FERROLAB when moving from water to oil.",
      ["faq-velocidad-enfriamiento", "martensita"], ("src_art_vieira_2021",)),
    k("art-1045-industrial", "research", "Temple y revenido del AISI 1045 a escala industrial (Mazuera y Ortiz, 2011)",
      "Quench and temper of AISI 1045 at industrial scale (Mazuera and Ortiz, 2011)",
      "En barras industriales de AISI/SAE 1045 de 1,5 pulgadas se compararon combinaciones de temperatura y tiempo de temple y revenido mediante microestructura y dureza (revenidos a 400 y 630 °C). Los autores recomiendan austenizar a 870 °C en condiciones industriales, por encima del rango de laboratorio, porque las barras gruesas tardan más en austenizarse.",
      "In 1.5-inch industrial AISI/SAE 1045 bars, combinations of quench and temper temperature and time were compared by microstructure and hardness (tempers at 400 and 630 °C). The authors recommend austenitizing at 870 °C under industrial conditions, above the laboratory range, because thick bars take longer to austenitize.",
      ["templabilidad"], ("src_art_mazuera_2011",)),
    k("art-1045-intercritico", "research", "Temple intercrítico y revenido del AISI 1045 (Garzón Torres et al., 2016)",
      "Intercritical quenching and tempering of AISI 1045 (Garzón Torres et al., 2016)",
      "Templar el AISI 1045 desde 760 °C (entre Ac1 y Ac3, 30 min) y revenir produjo martensita revenida junto a ferrita, con mayor dureza y resistencia a la tensión que el estado de entrega y menor fragilidad. En FERROLAB, una austenización entre Ac1 y Ac3 aparece como «intercrítica»: solo parte de la pieza se transforma en austenita.",
      "Quenching AISI 1045 from 760 °C (between Ac1 and Ac3, 30 min) and tempering produced tempered martensite alongside ferrite, with higher hardness and tensile strength than the as-supplied state and less brittleness. In FERROLAB, austenitizing between Ac1 and Ac3 appears as «intercritical»: only part of the piece transforms into austenite.",
      ["ferrita", "martensita"], ("src_art_garzon_2016",)),
    k("art-8620-fase-dual", "research", "Acero de fase dual a partir del AISI 8620 (Castillo-Gutiérrez et al., 2018)",
      "Dual-phase steel from AISI 8620 (Castillo-Gutiérrez et al., 2018)",
      "Con tratamientos térmicos y termomecánicos se obtuvo un acero de fase dual (ferrita + martensita) a partir del AISI/SAE 8620. La microdureza subió de unas 369 HV a 443–486 HV y el tamaño de grano bajó de 23,7 µm a 9,5–11,4 µm. Muestra la relación entre grano más fino y mayor dureza que FERROLAB calcula con ASTM E112.",
      "Thermal and thermomechanical treatments produced a dual-phase steel (ferrite + martensite) from AISI/SAE 8620. Microhardness rose from about 369 HV to 443–486 HV and grain size fell from 23.7 µm to 9.5–11.4 µm. It shows the relation between finer grain and higher hardness that FERROLAB computes with ASTM E112.",
      ["ferrita", "martensita"], ("src_art_castillo_2018", "src_astm_e112")),
    k("art-fundicion-austemperizada", "research", "Fundición gris austemperizada frente a templada y revenida (Wang et al., 2019)",
      "Austempered versus quenched-and-tempered gray iron (Wang et al., 2019)",
      "A igual dureza, la fundición gris austemperizada resistió mejor el desgaste que la templada y revenida: ligeramente mejor con baños de 232 a 316 °C y claramente mejor a 343 y 371 °C. La dureza bajó al subir la temperatura del baño porque queda menos martensita en la matriz. La matriz ausferrítica (ferrita acicular + austenita estable) explica la mejora.",
      "At equal hardness, austempered gray iron resisted wear better than quenched-and-tempered iron: slightly better with baths at 232–316 °C and clearly better at 343 and 371 °C. Hardness fell as the bath temperature rose because less martensite remains in the matrix. The ausferritic matrix (acicular ferrite + stable austenite) explains the improvement.",
      ["grafito-laminar", "bainita"], ("src_art_wang_2019",)),
    k("art-fundicion-austenizacion", "research", "Temperatura de austenización en la fundición gris austemperizada (Zhu et al., 2026)",
      "Austenitizing temperature in austempered gray iron (Zhu et al., 2026)",
      "Austenizando entre 890 y 950 °C antes del austemperizado, la matriz pasó de ferrita + perlita a ausferrita, con más ausferrita a mayor temperatura. La dureza máxima fue 247,6 HBW a 930 °C (187,6 HBW en bruto de colada) y la resistencia a tracción e impacto máximas, 219 MPa y 9,59 J, a 910 °C. Ese valor de dureza es la referencia publicada que FERROLAB muestra para el austemperizado de la fundición.",
      "Austenitizing between 890 and 950 °C before austempering changed the matrix from ferrite + pearlite to ausferrite, with more ausferrite at higher temperature. Maximum hardness was 247.6 HBW at 930 °C (187.6 HBW as cast) and maximum tensile and impact strength, 219 MPa and 9.59 J, at 910 °C. That hardness is the published reference FERROLAB shows for austempering the iron.",
      ["grafito-laminar"], ("src_art_zhu_2026", "src_astm_a247")),
    k("austenita", "glossary", "Austenita (γ)", "Austenite (γ)",
      "Fase del hierro con estructura cúbica centrada en las caras (FCC). En los aceros es estable a alta temperatura y disuelve mucho más carbono que la ferrita. Es el punto de partida del temple, el normalizado, el austempering y el martempering.",
      "Iron phase with a face-centered cubic (FCC) structure. In steels it is stable at high temperature and dissolves much more carbon than ferrite. It is the starting point of quenching, normalizing, austempering and martempering.",
      ["ferrita", "martensita"]),
    k("ferrita", "glossary", "Ferrita (α)", "Ferrite (α)",
      "Fase del hierro con estructura cúbica centrada en el cuerpo (BCC), estable a baja temperatura y con muy baja solubilidad de carbono. Es blanda y dúctil.",
      "Iron phase with a body-centered cubic (BCC) structure, stable at low temperature and with very low carbon solubility. It is soft and ductile.",
      ["perlita"]),
    k("cementita", "glossary", "Cementita (Fe₃C)", "Cementite (Fe₃C)",
      "Carburo de hierro, duro y frágil. Forma parte de la perlita y de la bainita.",
      "Iron carbide, hard and brittle. It is part of pearlite and bainite.", ["perlita"]),
    k("perlita", "glossary", "Perlita", "Pearlite",
      "Microconstituyente formado por láminas alternas de ferrita y cementita, producto de la transformación eutectoide de la austenita. No es una fase: no se suma como tercera fase junto a la ferrita y la cementita.",
      "Microconstituent made of alternating lamellae of ferrite and cementite, produced by the eutectoid transformation of austenite. It is not a phase: it is not added as a third phase alongside ferrite and cementite.",
      ["fase-vs-microconstituyente", "ferrita", "cementita"]),
    k("martensita", "glossary", "Martensita", "Martensite",
      "Fase metaestable que se forma sin difusión cuando la austenita se enfría con suficiente rapidez por debajo de Ms. En aceros con carbono es muy dura y, sin revenido, frágil. Su cantidad y dureza dependen de la composición y de la trayectoria térmica.",
      "Metastable phase formed without diffusion when austenite is cooled fast enough below Ms. In carbon-bearing steels it is very hard and, untempered, brittle. Its amount and hardness depend on composition and thermal path.",
      ["ms", "austenita"]),
    k("bainita", "glossary", "Bainita", "Bainite",
      "Microconstituyente de ferrita y carburos que se forma a temperaturas intermedias, por debajo del intervalo perlítico y por encima de Ms. El austempering busca obtenerla de forma isotérmica.",
      "Microconstituent of ferrite and carbides formed at intermediate temperatures, below the pearlite range and above Ms. Austempering aims to obtain it isothermally.",
      ["ttt"], ("src_bhadeshia",)),
    k("grafito-laminar", "glossary", "Grafito laminar", "Flake graphite",
      "En la fundición gris gran parte del carbono aparece como láminas de grafito. Le dan una fractura gris, buena amortiguación de vibraciones y maquinabilidad, pero poca ductilidad. Forma, tamaño y matriz dependen del proceso de colada.",
      "In gray cast iron much of the carbon appears as graphite flakes. They give a gray fracture, good vibration damping and machinability, but little ductility. Shape, size and matrix depend on the casting process.",
      [], ("src_angus", "src_asm_15")),
    k("ms", "glossary", "Ms (inicio de martensita)", "Ms (martensite start)",
      "Temperatura a la que comienza la transformación martensítica durante el enfriamiento. Depende de la composición; existen fórmulas empíricas (p. ej., Andrews, 1965), pero FERROLAB solo las usa con coeficientes verificados y dentro de su dominio.",
      "Temperature at which the martensitic transformation starts on cooling. It depends on composition; empirical formulas exist (e.g., Andrews, 1965), but FERROLAB only uses them with verified coefficients and within their domain.",
      ["martensita"], ("src_andrews_1965",)),
    k("ttt", "concept", "Diagrama TTT", "TTT diagram",
      "Tiempo–Temperatura–Transformación: describe cómo se transforma la austenita cuando se mantiene a temperatura constante (isotérmica). Es específico de cada acero y condición de austenitización.",
      "Time–Temperature–Transformation: describes how austenite transforms when held at constant (isothermal) temperature. It is specific to each steel and austenitizing condition.",
      ["cct"]),
    k("cct", "concept", "Diagrama CCT", "CCT diagram",
      "Enfriamiento Continuo–Transformación: describe la transformación durante un enfriamiento continuo. No es intercambiable con un TTT; superponer una curva de enfriamiento sobre un TTT no es un método válido.",
      "Continuous Cooling Transformation: describes transformation during continuous cooling. It is not interchangeable with a TTT; overlaying a cooling curve on a TTT is not a valid method.",
      ["ttt"]),
    k("diagrama-fe-c", "concept", "Diagrama hierro–carbono", "Iron–carbon diagram",
      "Diagrama de equilibrio: indica qué fases son estables a cada temperatura y contenido de carbono si se da tiempo suficiente. No considera la velocidad de enfriamiento, así que por sí solo no predice la martensita ni la dureza tras un temple. FERROLAB no lo dibuja hasta tener puntos digitalizados con fuente y permiso.",
      "Equilibrium diagram: it shows which phases are stable at each temperature and carbon content given enough time. It ignores cooling rate, so on its own it does not predict martensite or hardness after quenching. FERROLAB does not draw it until digitized points with a source and permission are available.",
      ["ttt", "cct"]),
    k("templabilidad", "concept", "Templabilidad", "Hardenability",
      "Capacidad de un acero para formar martensita hasta cierta profundidad al templarlo. Se mide, por ejemplo, con el ensayo Jominy (ASTM A255). No es lo mismo que dureza.",
      "Ability of a steel to form martensite to a certain depth when quenched. It is measured, for example, with the Jominy test (ASTM A255). It is not the same as hardness.",
      [], ("src_astm_a255",)),
    k("fase-vs-microconstituyente", "concept", "Fase vs. microconstituyente", "Phase vs. microconstituent",
      "Una fase tiene estructura cristalina y composición propias (ferrita, austenita, cementita). Un microconstituyente es una mezcla reconocible al microscopio (perlita = ferrita + cementita). FERROLAB nunca mezcla ambos en una misma suma de porcentajes.",
      "A phase has its own crystal structure and composition (ferrite, austenite, cementite). A microconstituent is a mixture recognizable under the microscope (pearlite = ferrite + cementite). FERROLAB never mixes both in the same percentage sum.",
      ["perlita"]),
    k("zoom-digital", "concept", "Zoom digital vs. aumento óptico", "Digital zoom vs. optical magnification",
      "Ampliar una imagen en pantalla no revela detalle nuevo. Un aumento óptico real (100×, 500×…) exige una micrografía tomada a ese aumento y una escala calibrada.",
      "Enlarging an image on screen reveals no new detail. A real optical magnification (100×, 500×…) requires a micrograph taken at that magnification and a calibrated scale.",
      [], ("src_asm_9",)),
    k("niveles-de-evidencia", "concept", "Niveles de evidencia en FERROLAB", "Evidence levels in FERROLAB",
      "Validado: contrastado con datos experimentales del dominio. Estimación acotada: modelo validado dentro de su rango. Cualitativo: tendencia sin cifra. Evidencia insuficiente: no se puede concluir. No soportado: fuera de alcance. Además se distingue el origen: medido, bibliográfico, modelado, ilustrativo o no disponible.",
      "Validated: checked against experimental data in the domain. Bounded estimate: validated model within its range. Qualitative: trend without a number. Insufficient evidence: no conclusion possible. Unsupported: out of scope. The origin is also distinguished: measured, literature, modeled, illustrative or unavailable.",
      [], ()),
    k("faq-ttt-cct", "faq", "¿Qué diferencia hay entre TTT y CCT?", "What is the difference between TTT and CCT?",
      "El TTT describe transformaciones a temperatura constante; el CCT, durante un enfriamiento continuo. Un temple o un normalizado son enfriamientos continuos; un austempering incluye una etapa isotérmica. Por eso no se usa un diagrama en lugar del otro.",
      "TTT describes transformations at constant temperature; CCT, during continuous cooling. Quenching or normalizing are continuous cooling; austempering includes an isothermal stage. That is why one diagram is not used in place of the other.",
      ["ttt", "cct"]),
    k("faq-velocidad-enfriamiento", "faq", "¿Por qué importa la velocidad de enfriamiento?", "Why does cooling rate matter?",
      "La austenita necesita tiempo para transformarse por difusión en ferrita y perlita. Si el enfriamiento es suficientemente rápido para la templabilidad del acero, no hay tiempo y se forma martensita. La velocidad real depende del medio, de la agitación y del tamaño de la pieza.",
      "Austenite needs time to transform by diffusion into ferrite and pearlite. If cooling is fast enough for the steel's hardenability, there is no time and martensite forms. The real rate depends on the medium, agitation and part size.",
      ["templabilidad", "cct"]),
    k("faq-martemper-austemper", "faq", "¿En qué se diferencian martempering y austempering?", "How do martempering and austempering differ?",
      "Ambos usan un baño. En el martempering el baño está cerca de Ms, solo se iguala la temperatura y luego se forma martensita al enfriar. En el austempering se mantiene el baño por encima de Ms el tiempo necesario para que la austenita se transforme en bainita.",
      "Both use a bath. In martempering the bath is near Ms, temperature is only equalized and martensite forms on subsequent cooling. In austempering the bath above Ms is held long enough for austenite to transform into bainite.",
      ["bainita", "martensita", "ms"]),
    k("faq-fundicion-acero", "faq", "¿La fundición gris se comporta como el acero?", "Does gray cast iron behave like steel?",
      "No. Tiene mucho más carbono, gran parte en forma de grafito laminar, y su respuesta a los tratamientos depende de la matriz y del grafito. FERROLAB no le aplica curvas ni modelos de acero.",
      "No. It has much more carbon, much of it as flake graphite, and its response to treatments depends on the matrix and graphite. FERROLAB does not apply steel curves or models to it.",
      ["grafito-laminar"], ("src_angus",)),
    k("faq-sin-dureza", "faq", "¿Por qué no aparece un valor de dureza?", "Why is there no hardness value?",
      "Porque FERROLAB solo muestra una dureza si existe un dato experimental o un modelo validado para esa condición exacta (material, estado inicial, protocolo, temperatura y tiempo), con fuente y rango de validez. Si no existe, decirlo es la respuesta científicamente correcta.",
      "Because FERROLAB only shows hardness if there is experimental data or a validated model for that exact condition (material, initial state, protocol, temperature and time), with a source and validity range. If none exists, saying so is the scientifically correct answer.",
      ["niveles-de-evidencia"], ("src_astm_e140",)),
]


def q(id, pes, pen, oes, oen, c, fes, fen, slug):
    return {"id": id, "prompt_es": pes, "prompt_en": pen, "options_es": oes, "options_en": oen, "correct_index": c,
            "feedback_es": fes, "feedback_en": fen, "related_slug": slug, "review_status": "draft"}


PRACTICE = [
    q("pq_perlita", "¿La perlita es una fase?", "Is pearlite a phase?",
      ["Sí, como la ferrita", "No, es un microconstituyente de ferrita y cementita", "Sí, es austenita enfriada"],
      ["Yes, like ferrite", "No, it is a microconstituent of ferrite and cementite", "Yes, it is cooled austenite"], 1,
      "La perlita es una mezcla laminar de dos fases (ferrita y cementita).", "Pearlite is a lamellar mixture of two phases (ferrite and cementite).", "perlita"),
    q("pq_ttt_cct", "Un temple en aceite es un enfriamiento…", "An oil quench is a…",
      ["Isotérmico: se interpreta con TTT", "Continuo: se interpreta con CCT", "De equilibrio: basta el diagrama Fe–C"],
      ["Isothermal cooling: read with TTT", "Continuous cooling: read with CCT", "Equilibrium cooling: the Fe–C diagram suffices"], 1,
      "Durante el temple la temperatura cambia continuamente; el diagrama adecuado es el CCT del acero concreto.",
      "During quenching temperature changes continuously; the appropriate diagram is the CCT of the specific steel.", "cct"),
    q("pq_revenido", "¿Qué necesita el revenido para tener sentido?", "What does tempering need to make sense?",
      ["Un estado inicial endurecido (templado)", "Una temperatura superior a la de austenización", "Nada: sirve para cualquier estado"],
      ["A hardened (quenched) initial state", "A temperature above austenitizing", "Nothing: it works for any state"], 0,
      "El revenido modifica una estructura templada; sin ella no hay punto de partida definido.",
      "Tempering modifies a quenched structure; without it there is no defined starting point.", None),
    q("pq_8620", "Si eliges AISI 8620 sin cementar, ¿qué no debes suponer?", "If you choose non-carburized AISI 8620, what must you not assume?",
      ["Que es un acero", "Que tiene una capa superficial cementada", "Que contiene hierro"],
      ["That it is a steel", "That it has a carburized surface case", "That it contains iron"], 1,
      "La cementación es un proceso aparte; sin él no hay capa de alto carbono.",
      "Carburizing is a separate process; without it there is no high-carbon case.", None),
    q("pq_a48c35", "ASTM A48 Clase 35 define…", "ASTM A48 Class 35 defines…",
      ["Una composición química única", "Una clase de fundición gris por requisito de resistencia", "Un acero al carbono"],
      ["A unique chemical composition", "A gray iron class by strength requirement", "A carbon steel"], 1,
      "La clase se refiere a un requisito de resistencia; la composición y la matriz pueden variar.",
      "The class refers to a strength requirement; composition and matrix can vary.", "faq-fundicion-acero"),
    q("pq_falta", "FERROLAB no muestra dureza para tu ensayo. ¿Qué falta?", "FERROLAB shows no hardness for your run. What is missing?",
      ["Un dato experimental o modelo validado para esa condición exacta", "Más velocidad de animación", "Elegir una temperatura más alta"],
      ["Experimental data or a validated model for that exact condition", "Faster animation", "A higher temperature"], 0,
      "Sin evidencia para la condición exacta, la respuesta honesta es «no estimable».",
      "Without evidence for the exact condition, the honest answer is \"not estimable\".", "faq-sin-dureza"),
]


def _apply_article_scope() -> None:
    by_slug = {e["slug"]: e for e in KNOWLEDGE}
    for slug, (mats, trts, cons, kws) in ARTICLE_SCOPE.items():
        e = by_slug[slug]
        e.update(materials=list(mats), treatments=list(trts), constituents=list(cons), keywords=list(kws))
    for slug, arts in CONCEPT_ARTICLES.items():
        e = by_slug[slug]
        for a in arts:
            if a not in e["related_slugs"]:
                e["related_slugs"].append(a)
            for sid in by_slug[a]["suggested_source_ids"]:
                if sid not in e["suggested_source_ids"] and sid.startswith("src_art_"):
                    e["suggested_source_ids"].append(sid)
    for t in TREATMENTS:
        for sid in TREATMENT_ARTICLES.get(t["id"], ()):
            if sid not in t["suggested_source_ids"]:
                t["suggested_source_ids"].append(sid)


_apply_article_scope()


def build() -> dict:
    return {
        "dataset_version": "0.2.0-dev+unreviewed",
        "contains_unreviewed_content": True,
        "interface": {"furnace_ui_min_c": 20.0, "furnace_ui_max_c": 1600.0, "hold_ui_max_min": 1440.0,
                      "ambient_reference_c": 20.0},
        "sources": SOURCES,
        "evidence": EVIDENCE,
        "materials": MATERIALS,
        "initial_conditions": INITIAL_CONDITIONS,
        "treatments": TREATMENTS,
        "material_treatments": PAIRS,
        "protocols": PROTOCOLS,
        "physical_guards": GUARDS,
        "model_versions": [],
        "micrographs": MICROGRAPHS,
        "knowledge": KNOWLEDGE,
        "practice_questions": PRACTICE,
    }


if __name__ == "__main__":
    data = build()
    sys.path.insert(0, str(ROOT / "packages" / "fse"))
    from ferrolab_fse.snapshot import DatasetSnapshot

    DatasetSnapshot.model_validate(data)  # falla si algo es incoherente
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"OK -> {OUT.relative_to(ROOT)}  ({len(PAIRS)} parejas, {len(KNOWLEDGE)} entradas)")
