"""Biblioteca de protocolos térmicos de referencia de FERROLAB (decisión D-30).

Cada cifra procede de una fuente consultada por el proyecto y lleva su localizador. Las fuentes que no se
pudieron abrir desde el entorno de trabajo se registran como `unverified` y sus protocolos quedan como
variantes «fuente no verificada»: se pueden estudiar, pero nunca se cargan como referencia.

Probeta de referencia educativa: cilindro de 12,7 mm (½ in). Cuando una fuente da una regla «por 25 mm de
sección» o «por pulgada», la regla se aplica a esa probeta y el texto lo dice; no se inventa un valor universal.
Todas las duraciones están en segundos y todas las temperaturas en °C.
"""

from __future__ import annotations

PROBE_NOTE_ES = "Aplicado a la probeta de referencia educativa de 12,7 mm."
PROBE_NOTE_EN = "Applied to the 12.7 mm educational reference specimen."
MIN = 60.0
HOUR = 3600.0


# ------------------------------------------------------------------------------------------- fuentes
def _src(id, kind, title, *, verified: bool, **kw):
    return {"id": id, "kind": kind, "title": title, "verification_status": "verified" if verified else "unverified",
            **kw}


SOURCES = [
    _src("src_voestalpine_1045", "web", "AISI 1045 — Technical data: heat treatment", verified=True,
         authors="voestalpine High Performance Metals (Australia)",
         url="https://www.voestalpine.com/highperformancemetals/australia/en-au/products/aisi-1045/",
         notes="Tabla «Heat Treatment» de la ficha web (consultada 19-11-2026)."),
    _src("src_vanguard_8620", "web", "Vanguard Steel Product Manual — AISI/SAE 8620", verified=True,
         authors="Vanguard Steel Ltd.",
         url="https://www.vanguardsteelvancouver.com/Publish/Images/Cat/Vanguard_Steel_Product_Manual_Full/Vanguard_Steel_Product_Manual.pdf",
         notes="Sección 1, páginas 13–14 (consultado 19-11-2026)."),
    _src("src_azom_1045", "web", "AISI 1045 Medium Carbon Steel", verified=True, authors="AZoM",
         url="https://www.azom.com/article.aspx?ArticleID=6130", notes="Apartado «Heat Treatment»."),
    _src("src_compraco_1045", "web", "SAE/AISI 1045 — tratamiento térmico", verified=True, authors="Compraco",
         url="https://compraco.com.br/", notes="Apartados «Normalizing», «Complete Annealing» y «Hardening»."),
    _src("src_compraco_8620", "web", "AISI 8620 — tablas de tratamiento térmico (datos tipo ASM)", verified=True,
         authors="Compraco / AZoM ArticleID=6752", url="https://www.azom.com/article.aspx?ArticleID=6752"),
    _src("src_compraco_gray", "web", "Mastering Gray Cast Iron: Expert Guide to Heat Treatment", verified=True,
         authors="Compraco",
         url="https://compraco.com.br/en/blogs/industria/dominio-do-ferro-fundido-cinza-guia-especializado-em-tratamento-termico"),
    _src("src_totalmateria_gray_1", "web", "Heat Treating of Gray Irons: Part One", verified=True,
         authors="Total Materia", url="https://www.totalmateria.com/en-us/articles/heat-treating-of-gray-irons-1",
         notes="Apartados «Ferritizing / Medium / Graphitizing Annealing» y «Normalizing of Gray Iron»."),
    _src("src_totalmateria_gray_2", "web", "Heat Treating of Gray Irons: Part Two", verified=True,
         authors="Total Materia", url="https://www.totalmateria.com/en-us/articles/heat-treating-of-gray-irons-2",
         notes="Apartados «Hardening and Tempering», «Austempering» y «Martempering»."),
    _src("src_wiki_austempering", "web", "Austempering", verified=True, authors="Wikipedia",
         url="https://en.wikipedia.org/wiki/Austempering"),
    _src("src_wiki_martempering", "web", "Martempering", verified=True, authors="Wikipedia",
         url="https://en.wikipedia.org/wiki/Martempering"),
    _src("src_mrs_2024_8620", "article",
         "Carbo-austempered process in two steps in a low carbon steel (AISI 8620) using eggshells in cementing mixture as an energizer",
         verified=True, authors="Y. G. Torres Hernández, E. Ordoñez-Camarena, A. Altamirano-Torres", year=2024,
         url="https://mrs-mexico.org.mx/imrc2024/abstracts-read.php?id=00031&r=00678",
         notes="Resumen IMRC 2024 (MRS-México), simposio F5."),
    _src("src_kang_lee_2014", "article",
         "Prediction of tempered martensite hardness incorporating the composition-dependent tempering parameter in low alloy steels",
         verified=True, authors="S. Kang, S.-J. Lee", year=2014, doi="10.2320/matertrans.M2014004",
         url="https://www.jstage.jst.go.jp/article/matertrans/55/7/55_M2014004/_article"),
    # --- no se pudieron abrir (bloqueo anti-robots o de red): NO respaldan protocolos de referencia.
    _src("src_matweb_8620_carb", "dataset", "MatWeb — AISI 8620 carburized (matid 8298)", verified=False,
         url="https://www.matweb.com/search/datasheettext.aspx?matid=8298",
         notes="Cifras aportadas por el propietario; FERROLAB no pudo abrir la página."),
    _src("src_asm_gray_ht", "book", "ASM Handbook Vol. 4D — Heat Treating of Gray Irons", verified=False,
         publisher="ASM International",
         url="https://dl.asminternational.org/handbooks/edited-volume/9/chapter-abstract/108841/Heat-Treating-of-Gray-Irons-1",
         notes="Caso de camisas de cilindro aportado por el propietario; texto no consultado por FERROLAB."),
    _src("src_jmrt_2022_agi", "article", "Wear resistance of austempered grey iron under dry and wet conditions",
         verified=False, year=2022, doi="10.1016/j.jmrt.2022.11.025",
         url="https://www.sciencedirect.com/science/article/pii/S2238785422017331",
         notes="J. Mater. Res. Technol. Acceso abierto, pero el texto no se pudo abrir desde el entorno; "
               "condiciones aportadas por el propietario."),
    _src("src_saarstahl_c45", "web", "Material specification sheet Saarstahl — C45 (equivalente europeo del 1045)",
         verified=False, authors="Saarstahl AG",
         url="https://en.saarstahl.com/app/uploads/2024/03/20160401102929-0503_C45.pdf",
         notes="Leído como extracto de un buscador: temple 820–860 °C agua/aceite y revenido 550–660 °C (bonificado). "
               "Solo se usa para justificar el límite inferior del revenido de bonificado."),
    _src("src_bodycote_austempering", "web", "Austempering — Bodycote", verified=False, authors="Bodycote",
         url="https://www.bodycote.com/services/heat-treatment/hardening-and-tempering/austempering/",
         notes="Leído solo como extracto de un buscador; la página bloquea la descarga automática."),
]


# ------------------------------------------------------------------------------------------- evidencia
def _ev(id, source, locator, es, en):
    return {"id": id, "source_id": source, "locator": locator, "claim_es": es, "claim_en": en,
            "evidence_kind": "literature", "evidence_level": "bounded_estimate", "method": "protocol_parameter",
            "review_status": "draft"}


EVIDENCE = [
    # bonificado (temple + revenido alto)
    _ev("ev_sa_c45_qt", "src_saarstahl_c45", "Heat treatment: hardening / tempering (extracto)",
        "C45: temple 820–860 °C en agua o aceite; revenido de bonificado 550–660 °C.",
        "C45: hardening 820–860 °C in water or oil; quench-and-temper tempering 550–660 °C."),
    # voestalpine 1045
    _ev("ev_vo_1045_normalize", "src_voestalpine_1045", "Heat Treatment: Normalize",
        "Normalizar a 850 °C, enfriar al aire.", "Normalize at 850 °C, air cool."),
    _ev("ev_vo_1045_anneal", "src_voestalpine_1045", "Heat Treatment: Anneal",
        "Recocido a 680–710 °C; enfriar lentamente en horno controlado.", "Anneal at 680–710 °C; cool slowly in a controlled furnace."),
    _ev("ev_vo_1045_stress", "src_voestalpine_1045", "Heat Treatment: Stress Relieve",
        "Alivio de tensiones a 600–650 °C; enfriar en horno o al aire.", "Stress relieve at 600–650 °C; furnace or air cool."),
    _ev("ev_vo_1045_harden", "src_voestalpine_1045", "Heat Treatment: Harden",
        "Templar desde 800–830 °C en agua; dureza superficial media 57 HRC.", "Harden from 800–830 °C, water quench; average surface hardness 57 HRC."),
    _ev("ev_vo_1045_temper", "src_voestalpine_1045", "Heat Treatment: Temper",
        "Revenir a 150–200 °C, enfriar al aire.", "Temper at 150–200 °C, air cool."),
    _ev("ev_vo_1045_anneal_hb", "src_voestalpine_1045", "Heat Treatment: Anneal Hardness",
        "Dureza de recocido: 190 HB máx.", "Annealed hardness: 190 HB max."),
    # AZoM 1045
    _ev("ev_az_1045_comp", "src_azom_1045", "Chemical Composition", "C 0.43–0.50, Mn 0.60–0.90 % en masa.",
        "C 0.43–0.50, Mn 0.60–0.90 wt%."),
    _ev("ev_az_1045_harden", "src_azom_1045", "Heat Treatment: Hardening",
        "Calentar a 820–850 °C, mantener hasta temperatura uniforme y 10–15 min por cada 25 mm; temple en agua o salmuera.",
        "Heat to 820–850 °C, hold until uniform, soak 10–15 min per 25 mm; quench in water or brine."),
    _ev("ev_az_1045_harden_soak", "src_azom_1045", "Heat Treatment: Hardening (soak)",
        "Sostenimiento: 10–15 min por cada 25 mm de sección, contado desde que la temperatura es uniforme.",
        "Soak: 10–15 min per 25 mm of section, counted once the temperature is uniform."),
    _ev("ev_az_1045_normalize", "src_azom_1045", "Heat Treatment: Normalizing",
        "Calentar a 870–920 °C, mantener hasta temperatura uniforme, 10–15 min; enfriar en aire en calma.",
        "Heat to 870–920 °C, hold until uniform, soak 10–15 min; cool in still air."),
    _ev("ev_az_1045_normalize_soak", "src_azom_1045", "Heat Treatment: Normalizing (soak)",
        "Sostenimiento de normalizado: 10–15 min.", "Normalizing soak: 10–15 min."),
    _ev("ev_az_1045_anneal", "src_azom_1045", "Heat Treatment: Annealing",
        "Calentar a 800–850 °C, mantener hasta temperatura uniforme; enfriar en horno.",
        "Heat to 800–850 °C, hold until uniform; furnace cool."),
    _ev("ev_az_1045_temper", "src_azom_1045", "Heat Treatment: Tempering",
        "Recalentar a 400–650 °C según se requiera; 1 h por cada 25 mm; enfriar en aire en calma.",
        "Reheat to 400–650 °C as required; 1 h per 25 mm; cool in still air."),
    _ev("ev_az_1045_temper_soak", "src_azom_1045", "Heat Treatment: Tempering (soak)",
        "Sostenimiento de revenido: 1 h por cada 25 mm de sección.", "Tempering soak: 1 h per 25 mm of section."),
    _ev("ev_az_1045_stress", "src_azom_1045", "Heat Treatment: Stress-Relieving",
        "Calentar a 550–660 °C; 1 h por cada 25 mm; enfriar en aire en calma.",
        "Heat to 550–660 °C; 1 h per 25 mm; cool in still air."),
    _ev("ev_az_1045_stress_soak", "src_azom_1045", "Heat Treatment: Stress-Relieving (soak)",
        "Sostenimiento de alivio de tensiones: 1 h por cada 25 mm.", "Stress-relief soak: 1 h per 25 mm."),
    # Compraco 1045
    _ev("ev_cp_1045_normalize", "src_compraco_1045", "1045 Steel Heat Treatment: Normalizing",
        "Rango de normalizado 830–900 °C; típico 860 °C.", "Normalizing range 830–900 °C; typical 860 °C."),
    _ev("ev_cp_1045_anneal", "src_compraco_1045", "Complete Annealing",
        "Recocido completo a 790–870 °C; enfriamiento en horno de 790 a 650 °C a 28 °C/h; 156–217 HBW.",
        "Full anneal at 790–870 °C; furnace cool from 790 to 650 °C at 28 °C/h; 156–217 HBW."),
    _ev("ev_cp_1045_anneal_soak", "src_compraco_1045", "Complete Annealing (time)",
        "Secciones de hasta 25 mm: al menos 1 h; +0,5 h por cada 25 mm adicionales.",
        "Sections up to 25 mm: at least 1 h; +0.5 h per additional 25 mm."),
    _ev("ev_cp_1045_anneal_rate", "src_compraco_1045", "Complete Annealing (cooling)",
        "Enfriamiento en horno de 790 a 650 °C a 28 °C/h.", "Furnace cooling from 790 to 650 °C at 28 °C/h."),
    _ev("ev_cp_1045_harden", "src_compraco_1045", "Hardening",
        "Austenizar a 845 °C; medio agua o salmuera (aceite para espesores ≤ 6,35 mm); dureza ≥ 55 HRC.",
        "Austenitize at 845 °C; water or brine (oil for walls ≤ 6.35 mm); hardness ≥ 55 HRC."),
    # Vanguard 8620
    _ev("ev_vg_8620_comp", "src_vanguard_8620", "Sección 1, pág. 13: Typical analysis",
        "C .18/.23, Mn .70/.90, Si .15/.35, Cr .40/.60, Ni .40/.70, Mo .15/.25 % en masa.",
        "C .18/.23, Mn .70/.90, Si .15/.35, Cr .40/.60, Ni .40/.70, Mo .15/.25 wt%."),
    _ev("ev_vg_8620_anneal", "src_vanguard_8620", "Sección 1, pág. 14: Annealing",
        "Recocido 856/885 °C, enfriar en horno.", "Annealing 856/885 °C, cool in furnace."),
    _ev("ev_vg_8620_normalize", "src_vanguard_8620", "Sección 1, pág. 14: Normalizing",
        "Normalizado 898/926 °C, enfriar al aire.", "Normalizing 898/926 °C, air cool."),
    _ev("ev_vg_8620_harden", "src_vanguard_8620", "Sección 1, pág. 14: Hardening & tempering (uncarburized)",
        "Sin cementar: 815/855 °C, temple en aceite o agua; revenir a 200–650 °C según la resistencia requerida.",
        "Uncarburized: 815/855 °C, oil or water quench; temper at 200–650 °C according to strength required."),
    _ev("ev_vg_8620_draw", "src_vanguard_8620", "Sección 1, pág. 14: Carburizing (draw)",
        "Revenir (draw) al menos 1–2 h por pulgada de sección.", "Draw for at least 1–2 h per inch of section."),
    _ev("ev_vg_8620_single", "src_vanguard_8620", "Sección 1, pág. 14: Carburizing 2 (single refine)",
        "Enfriar en caja o al aire desde la cementación; recalentar a 829/842 °C; temple en aceite; revenir ≥ 1–2 h por pulgada.",
        "Box cool or air cool from carburizing; reheat to 829/842 °C; oil quench; draw ≥ 1–2 h per inch."),
    _ev("ev_vg_8620_double", "src_vanguard_8620", "Sección 1, pág. 14: Carburizing 3 (double refine)",
        "Recalentar a 829/842 °C, aceite; recalentar a 760/787 °C, aceite; revenir ≥ 1–2 h por pulgada.",
        "Reheat to 829/842 °C, oil; reheat to 760/787 °C, oil; draw ≥ 1–2 h per inch."),
    _ev("ev_vg_8620_direct", "src_vanguard_8620", "Sección 1, pág. 14: Carburizing 1 (direct)",
        "Temple directo en aceite desde la temperatura de cementación; revenir ≥ 1–2 h por pulgada.",
        "Direct oil quench from carburizing temperature; draw ≥ 1–2 h per inch."),
    # Compraco 8620
    _ev("ev_cp_8620_harden", "src_compraco_8620", "Austenitizing temperatures for direct hardening",
        "845 °C en aceite, o 830 °C para temple en agua; revenido 200–650 °C.",
        "845 °C oil, or 830 °C for water quenching; temper 200–650 °C."),
    _ev("ev_cp_8620_anneal", "src_compraco_8620", "Complete annealing cycles: conventional",
        "Recocido convencional a 870 °C, mantener 45 min, enfriar en horno.", "Conventional anneal at 870 °C, hold 45 min, furnace cool."),
    _ev("ev_cp_8620_iso", "src_compraco_8620", "Complete annealing cycles: isothermal",
        "Recocido isotérmico: 885 °C, luego 660 °C durante 4 h.", "Isothermal anneal: 885 °C, then 660 °C for 4 h."),
    _ev("ev_cp_8620_normalize", "src_compraco_8620", "Carburizing parameters: Normalizing",
        "Normalizado 870–930 °C; dureza normalizada a 915 °C: 197 HB (barra 13 mm).",
        "Normalizing 870–930 °C; normalized at 915 °C: 197 HB (13 mm bar)."),
    _ev("ev_cp_8620_mass", "src_compraco_8620", "Effect of mass on oil-quenched hardness",
        "Templado en aceite, barra de 13 mm: 43 HRC en superficie, medio radio y centro.",
        "Oil quenched, 13 mm bar: 43 HRC at surface, half-radius and center."),
    _ev("ev_cp_8620_crit", "src_compraco_8620", "Approximate transformation temperatures",
        "Ac1 730 °C, Ac3 830 °C, Ar3 770 °C, Ar1 660 °C, Ms 395 °C (calentando/enfriando a 28 °C/h).",
        "Ac1 730 °C, Ac3 830 °C, Ar3 770 °C, Ar1 660 °C, Ms 395 °C (heating/cooling at 28 °C/h)."),
    _ev("ev_cp_8620_martemper", "src_compraco_8620", "Typical applications of 8620 martempered parts in salt",
        "Husillo de 8620 cementado (sección 10,2 mm): sal a 205 °C, tiempo mínimo en sal 3 min.",
        "Carburized 8620 screw machine spindle (10.2 mm section): salt at 205 °C, minimum 3 min in salt."),
    _ev("ev_cp_8620_carb", "src_compraco_8620", "Carburization (common method)",
        "Cementar a 925 °C (potencial 0,9 % C) ~4 h para 1,3 mm; bajar a 845 °C, 1 h de difusión, temple en aceite, revenir a 150 °C.",
        "Carburize at 925 °C (0.9% C potential) ~4 h for 1.3 mm; lower to 845 °C, 1 h diffusion, oil quench, temper at 150 °C."),
    # MRS 2024 — carbo-austempering 8620
    _ev("ev_mrs_8620", "src_mrs_2024_8620", "Resumen",
        "Cementación sólida 900 °C 4 y 6 h, aire; austenizado 850 °C; austempering en baño de estaño 500 °C/30 min y 400 °C/90 min; "
        "capa 63–50 HRC (400 °C) y 58–47 HRC (500 °C); capa efectiva < 0,1 mm.",
        "Pack carburizing 900 °C 4 and 6 h, air; austenitize 850 °C; austempering in tin bath 500 °C/30 min and 400 °C/90 min; "
        "case 63–50 HRC (400 °C) and 58–47 HRC (500 °C); effective case < 0.1 mm."),
    # Wikipedia
    _ev("ev_wk_austemper", "src_wiki_austempering", "Process: austenitizing / quenching",
        "Austenización típica 790–915 °C; temple a un baño por encima de Ms y mantenimiento; en aceros basta con pocos minutos "
        "una vez que toda la sección alcanzó la temperatura.",
        "Typical austenitizing 790–915 °C; quench to a bath above Ms and hold; in steels a few minutes once the whole section "
        "reached temperature."),
    _ev("ev_wk_martemper", "src_wiki_martempering", "Process",
        "Baño a 150–300 °C, por encima de Ms, hasta igualar la temperatura de la sección; luego enfriar.",
        "Bath at 150–300 °C, above Ms, until the section temperature is uniform; then cool."),
    # Total Materia — gris
    _ev("ev_tm_gray_ferritize", "src_totalmateria_gray_1", "Ferritizing Annealing",
        "Recocido ferritizante entre 700 y 760 °C.", "Ferritizing anneal between 700 and 760 °C."),
    _ev("ev_tm_gray_full", "src_totalmateria_gray_1", "Medium (Full) Annealing",
        "Recocido medio/completo 790–900 °C; enfriar lentamente de 790 a 675 °C.",
        "Medium/full anneal 790–900 °C; cool slowly from 790 to 675 °C."),
    _ev("ev_tm_gray_graphitize", "src_totalmateria_gray_1", "Graphitizing Annealing",
        "Al menos 870 °C; práctica habitual 900–955 °C.", "At least 870 °C; standard practice 900–955 °C."),
    _ev("ev_tm_gray_normalize", "src_totalmateria_gray_1", "Normalizing of Gray Iron",
        "885–925 °C, ~1 h por pulgada de sección máxima, aire en calma.", "885–925 °C, ~1 h per inch of maximum section, still air."),
    _ev("ev_tm_gray_harden", "src_totalmateria_gray_2", "Hardening and Tempering",
        "Calentar lentamente hasta ~650 °C (por encima del rango de alivio 595–650 °C se puede calentar rápido); "
        "A (°C) ≈ 730 + 28,0 Si − 25,0 Mn para fundición no aleada; sal fundida o aceite; revenido ~1 h por pulgada.",
        "Heat slowly to ~650 °C (above the 595–650 °C stress-relief range heating can be fast); A (°C) ≈ 730 + 28.0 Si − 25.0 Mn "
        "for unalloyed iron; molten salt or oil; temper ~1 h per inch."),
    _ev("ev_tm_gray_austenitize", "src_totalmateria_gray_2", "Austempering",
        "Austenizar a 840–900 °C (tiempo según tamaño y composición).", "Austenitize at 840–900 °C (time depends on size and composition)."),
    _ev("ev_tm_gray_austemper", "src_totalmateria_gray_2", "Austempering",
        "Baño de sal, aceite o plomo a 230–425 °C; 230–290 °C para máxima dureza y resistencia al desgaste.",
        "Salt, oil or lead bath at 230–425 °C; 230–290 °C for maximum hardness and wear resistance."),
    _ev("ev_tm_gray_martemper", "src_totalmateria_gray_2", "Martempering",
        "Baño ligeramente por encima de Ms, típicamente 200–260 °C para fundiciones no aleadas; solo hasta el equilibrio "
        "térmico; luego revenir casi siempre.",
        "Bath slightly above Ms, typically 200–260 °C for unalloyed irons; only until thermal equilibrium; tempering almost always."),
    _ev("ev_tm_gray_temper", "src_totalmateria_gray_2", "Hardening and Tempering",
        "Revenido muy por debajo del rango de transformación, ~1 h por pulgada de la sección más gruesa.",
        "Temper well below the transformation range, ~1 h per inch of the thickest section."),
    # Compraco — gris
    _ev("ev_cp_gray_quench", "src_compraco_gray", "Quenching and tempering",
        "Temple: límite superior de Ac1 + 30–50 °C, típicamente 850–900 °C; temple en aceite.",
        "Hardening: upper Ac1 + 30–50 °C, typically 850–900 °C; oil quench."),
    _ev("ev_cp_gray_stress", "src_compraco_gray", "Stress relief annealing",
        "Alivio de tensiones a 550 °C (fundición común); calentamiento 60–120 °C/h; enfriamiento 20–40 °C/h hasta 150–200 °C.",
        "Stress relief at 550 °C (common iron); heating 60–120 °C/h; cooling 20–40 °C/h down to 150–200 °C."),
    _ev("ev_cp_gray_temper", "src_compraco_gray", "Tempering",
        "Revenido por debajo de 550 °C; tiempo = espesor/25 + 1 h.", "Temper below 550 °C; time = thickness/25 + 1 h."),
    # No verificadas (aportadas por el propietario)
    _ev("ev_mw_8620_carb", "src_matweb_8620_carb", "Datasheet (no consultado)",
        "Cementado a 925 °C 8 h, enfriado, reaustenizado a 845 °C, aceite agitado, revenido a 230 °C.",
        "Carburized at 925 °C 8 h, cooled, reheated to 845 °C, agitated oil, tempered at 230 °C."),
    _ev("ev_asm_gray_liner", "src_asm_gray_ht", "Martempering example (no consultado)",
        "Camisas de cilindro: 870 °C 1 h, baño a 245 °C 1 min, enfriamiento, revenido 200 °C 2 h.",
        "Cylinder liners: 870 °C 1 h, bath at 245 °C 1 min, cooling, temper 200 °C 2 h."),
    _ev("ev_jmrt_agi", "src_jmrt_2022_agi", "Experimental (no consultado)",
        "Austenizado 870 °C 2 h; baños a 360 °C 1 h o 260 °C 2 h.", "Austenitized 870 °C 2 h; baths at 360 °C 1 h or 260 °C 2 h."),
    _ev("ev_bc_austemper", "src_bodycote_austempering", "Extracto de buscador (no consultado)",
        "Austenizar 790–915 °C; baño de sal 260–370 °C; aceros 1045–1095; 38–52 HRC.",
        "Austenitize 790–915 °C; salt bath 260–370 °C; 1045–1095 steels; 38–52 HRC."),
]


# ------------------------------------------------------------------------------------------- etapas
def _st(kind, label, level, temp_mode, dur_mode, **kw):
    return {"kind": kind, "label_key": label, "end_level": level, "end_temperature_mode": temp_mode,
            "duration_mode": dur_mode, **kw}


def heat(role="austenitize", label="heat_to_austenitizing", t=None, ev=None, purpose=None, **kw):
    lo, hi, ref = t or (None, None, None)
    p_es, p_en = purpose or (
        "La pieza se calienta en el horno; al superar Ac1 empieza a formarse austenita y por encima de Ac3 es toda austenita.",
        "The part heats in the furnace; above Ac1 austenite starts forming and above Ac3 it is fully austenitic.")
    return _st("heat", label, "target", "user_target", "rate" if kw.get("rate_c_per_s") else "unpublished",
               role=role, medium="furnace", temperature_min_c=lo, temperature_max_c=hi, temperature_ref_c=ref,
               end_temperature_evidence_id=ev, purpose_es=p_es, purpose_en=p_en, **kw)


def preheat(t, ev, purpose):
    return _st("heat", "preheat", "target", "value", "unpublished", role="preheat", medium="furnace",
               end_temperature_c=t, end_temperature_evidence_id=ev, purpose_es=purpose[0], purpose_en=purpose[1])


def soak(d=None, ev=None, rule=None, label="hold_austenitizing", purpose=None):
    lo, hi, ref = d or (None, None, None)
    r_es, r_en = rule or (None, None)
    p_es, p_en = purpose or (
        "Sostenimiento: el carbono se disuelve y la austenita se homogeneiza en toda la sección.",
        "Holding: carbon dissolves and austenite homogenizes across the section.")
    return _st("hold", label, "target", "user_target", "user_hold", role="soak", medium="furnace",
               duration_min_s=lo, duration_max_s=hi, duration_ref_s=ref, duration_evidence_id=ev,
               rule_es=r_es, rule_en=r_en,
               start_condition_es="El tiempo cuenta desde que el centro de la probeta alcanza la temperatura del horno "
                                  "(no desde que el horno la alcanza).",
               start_condition_en="Time counts from when the specimen center reaches the furnace temperature "
                                  "(not when the furnace reaches it).",
               purpose_es=p_es, purpose_en=p_en)


def transfer(to="medium"):
    return _st("transfer", "transfer_to_medium" if to == "medium" else "transfer_to_bath", "target", "unpublished",
               "unpublished", role="transfer", medium="air",
               purpose_es="Traslado del horno al medio: la superficie empieza a enfriarse en el aire.",
               purpose_en="Transfer from furnace to medium: the surface starts cooling in air.")


def quench(medium, ev, note=None):
    n_es, n_en = note or (None, None)
    return _st("cool", "quench_cool", "ambient", "ambient", "until_ambient", role="quench", medium=medium,
               end_temperature_evidence_id=None, duration_evidence_id=None, medium_note_es=n_es, medium_note_en=n_en,
               purpose_es="Enfriamiento rápido: si se cruza Ms sin transformaciones previas, la austenita se convierte en "
                          "martensita (dura y frágil).",
               purpose_en="Rapid cooling: if Ms is crossed without prior transformations, austenite turns into martensite "
                          "(hard and brittle).")


def air_cool(label="air_cool", purpose=None):
    p_es, p_en = purpose or ("Enfriamiento en aire en calma hasta temperatura ambiente.",
                             "Cooling in still air down to room temperature.")
    return _st("cool", label, "ambient", "ambient", "until_ambient", role="air_cool", medium="air",
               purpose_es=p_es, purpose_en=p_en)


def furnace_cool(rate_c_per_h, until_c, ev, purpose=None, illustrative=False):
    p_es, p_en = purpose or ("Enfriamiento lento dentro del horno: la austenita se transforma en ferrita y perlita gruesa.",
                             "Slow cooling inside the furnace: austenite transforms into ferrite and coarse pearlite.")
    st = _st("cool", "anneal_cool", "ambient", "value", "rate", role="furnace_cool", medium="furnace",
             end_temperature_c=until_c, end_temperature_evidence_id=ev, rate_c_per_s=rate_c_per_h / 3600,
             duration_evidence_id=ev, until_c=until_c, purpose_es=p_es, purpose_en=p_en)
    if illustrative:
        st["rule_es"] = ("La fuente indica «enfriar en horno» sin velocidad. Para dibujar la curva se usa 28 °C/h "
                         "(Compraco, recocido del 1045): es un supuesto ilustrativo.")
        st["rule_en"] = ("The source says «furnace cool» without a rate. 28 °C/h (Compraco, 1045 anneal) is used to draw "
                         "the curve: an illustrative assumption.")
    return st


def bath(mode, t=None, ev=None, d=None, d_ev=None, medium="salt_bath", label="isothermal_bath_hold", role="bath",
         dur_mode="user_bath_time", purpose=None, rule=None):
    lo, hi, ref = t or (None, None, None)
    dlo, dhi, dref = d or (None, None, None)
    p_es, p_en = purpose
    r_es, r_en = rule or (None, None)
    return _st("isothermal_hold", label, "bath", mode, dur_mode, role=role, medium=medium,
               temperature_min_c=lo, temperature_max_c=hi, temperature_ref_c=ref, end_temperature_evidence_id=ev,
               duration_min_s=dlo, duration_max_s=dhi, duration_ref_s=dref, duration_evidence_id=d_ev,
               purpose_es=p_es, purpose_en=p_en, rule_es=r_es, rule_en=r_en)


def temper_heat(t, ev):
    lo, hi, ref = t
    return heat(role="temper", label="heat_to_temper", t=(lo, hi, ref), ev=ev,
                purpose=("Calentamiento por debajo de Ac1: no se forma austenita nueva.",
                         "Heating below Ac1: no new austenite forms."))


def temper_soak(d, ev, rule):
    return soak(d, ev, rule, label="hold_temper",
                purpose=("La martensita se revierte: precipitan carburos, baja la dureza y sube la tenacidad.",
                         "Martensite tempers: carbides precipitate, hardness drops and toughness rises."))


def aust_heat_fixed(t, ev, purpose=None):
    """Austenización con cifra fija del protocolo (el estudiante edita el revenido, no el temple)."""
    st = heat(t=t, ev=ev, purpose=purpose)
    st["end_temperature_mode"] = "value"
    st["end_temperature_c"] = t[2]
    return st


def aust_soak_fixed(d, ev, rule, purpose=None, *, t, t_ev):
    """Sostenimiento de austenización con cifras fijas: a la temperatura de la etapa anterior (misma evidencia)."""
    st = soak(d, ev, rule, purpose=purpose)
    st["duration_mode"] = "value" if d and d[2] is not None else "unpublished"
    st["duration_s"] = d[2] if d else None
    st["end_temperature_mode"] = "value"
    st["end_temperature_c"] = t
    st["end_temperature_evidence_id"] = t_ev
    return st


QT_RULE = ("Bonificado = temple + revenido ALTO. El límite inferior de 550 °C es el del bonificado del C45 (Saarstahl, "
           "equivalente europeo del 1045); el superior es el máximo publicado para este material.",
           "Quench and temper (bonificado) = hardening + HIGH tempering. The 550 °C lower limit is that of C45 quench and "
           "temper (Saarstahl, European equivalent of 1045); the upper one is the maximum published for this material.")
QT_EXPECTED = ("Martensita revenida (sorbita): menos dureza que el templado y mucha más tenacidad; la combinación de "
               "resistencia y tenacidad propia de ejes y piezas de maquinaria.",
               "Tempered martensite (sorbite): less hardness than as-quenched and much higher toughness; the strength-"
               "toughness combination typical of shafts and machine parts.")


def _ordered(stages):
    return [dict(s, ordinal=i) for i, s in enumerate(stages, start=1)]


AUSTEMPER_BATH_PURPOSE = (
    "Baño isotérmico entre Ms y Bs: la austenita se transforma en bainita sin formar martensita, con menos distorsión.",
    "Isothermal bath between Ms and Bs: austenite transforms into bainite without martensite, with less distortion.")
MARTEMPER_BATH_PURPOSE = (
    "Baño justo por encima de Ms solo hasta igualar la temperatura de superficie y centro; NO se espera a que forme bainita.",
    "Bath just above Ms only until surface and center temperatures equalize; it does NOT wait for bainite to form.")
FINAL_MARTENSITE = ("Enfriamiento final al aire: la pieza atraviesa la región martensítica de forma más uniforme.",
                    "Final air cooling: the part crosses the martensite region more uniformly.")
FINAL_AFTER_BAINITE = ("Enfriamiento final al aire; la austenita que no se transformó en el baño puede formar martensita.",
                       "Final air cooling; austenite not transformed in the bath may form martensite.")
MODEL_WINDOW_RULE_AUS = (
    "Regla de la fuente: baño por encima de Ms. FERROLAB acota el baño entre el Ms más alto y el Bs más bajo del rango de "
    "composición de la norma (modelos de Andrews y Li) y propone la temperatura donde el modelo completa antes la bainita; "
    "el tiempo propuesto es el que el modelo TTT necesita para el 99 %. Es un valor calculado, no publicado.",
    "Source rule: bath above Ms. FERROLAB bounds the bath between the highest Ms and the lowest Bs over the standard "
    "composition range (Andrews and Li models) and proposes the temperature at which the model completes bainite fastest; "
    "the proposed time is what the TTT model needs for 99%. It is a computed value, not a published one.")
MODEL_WINDOW_RULE_MAR = (
    "Regla de la fuente: baño por encima de Ms hasta igualar la temperatura. FERROLAB propone el Ms más alto del rango de "
    "composición de la norma (redondeado hacia arriba) y calcula la igualación con el modelo térmico; avisa si el tiempo "
    "en el baño supera el inicio de bainita del modelo TTT.",
    "Source rule: bath above Ms until temperature equalizes. FERROLAB proposes the highest Ms over the standard composition "
    "range (rounded up) and computes equalization with the thermal model; it warns if the bath time exceeds the bainite "
    "start of the TTT model.")


def proto(id, material, treatment, variant_code, name, objective, stages, *, sources, status, goal="reference",
          reference=False, medium=("—", "—"), condition=None, required=None, default_ic=None, prior=None,
          expected=None, restrictions=None, assumptions=None, missing=None, results=None, model=False, validity=None):
    c_es, c_en = condition or (None, None)
    return {
        "id": id, "version": "1.0.0", "material_id": material, "treatment_id": treatment,
        "variant_code": variant_code, "variant_es": name[0], "variant_en": name[1], "name_es": name[0], "name_en": name[1],
        "objective_es": objective[0], "objective_en": objective[1], "goal": goal, "is_reference": reference,
        "medium_es": medium[0], "medium_en": medium[1], "material_condition_es": c_es, "material_condition_en": c_en,
        "required_initial_state": required or {}, "default_initial_condition_id": default_ic,
        "prior_protocol_id": prior, "evidence_status": status, "source_ids": list(sources),
        "validity": validity or {"specimen": "probeta de referencia educativa, cilindro de 12,7 mm"},
        "expected_es": (expected or (None, None))[0], "expected_en": (expected or (None, None))[1],
        "restrictions_es": [r[0] for r in restrictions or []], "restrictions_en": [r[1] for r in restrictions or []],
        "assumptions_es": [a[0] for a in assumptions or []], "assumptions_en": [a[1] for a in assumptions or []],
        "missing_es": [m[0] for m in missing or []], "missing_en": [m[1] for m in missing or []],
        "published_results": results or [], "model_applicable": model, "published_on": "2026-11-19",
        "stages": _ordered(stages), "review_status": "draft",
    }


# Sostenimiento de temple según AZoM (10–15 min por 25 mm) aplicado a 12,7 mm => 5–7,5 min.
AZ_HARDEN_SOAK = ((5 * MIN, 7.5 * MIN, 7.5 * MIN), "ev_az_1045_harden_soak",
                  ("AZoM: 10–15 min por cada 25 mm, desde que la temperatura es uniforme. " + PROBE_NOTE_ES + " → 5–7,5 min.",
                   "AZoM: 10–15 min per 25 mm, once the temperature is uniform. " + PROBE_NOTE_EN + " → 5–7.5 min."))
AZ_HARDEN_SOAK_8620 = (AZ_HARDEN_SOAK[0], AZ_HARDEN_SOAK[1],
                       ("Vanguard no indica tiempo. Se aplica la regla general de AZoM para temple (10–15 min por 25 mm), "
                        "publicada para el 1045: es un supuesto declarado. " + PROBE_NOTE_ES + " → 5–7,5 min.",
                        "Vanguard gives no time. AZoM's general hardening rule (10–15 min per 25 mm), published for 1045, "
                        "is applied as a declared assumption. " + PROBE_NOTE_EN + " → 5–7.5 min."))
SLOW_REF = ("La cinética del modelo supone austenización completa por encima de Ae3: el tiempo de sostenimiento no cambia "
            "las fracciones calculadas.",
            "The kinetic model assumes complete austenitization above Ae3: holding time does not change the computed fractions.")
NO_CASE = ("No se modela la capa cementada: el modelo cinético describe el núcleo con la composición base.",
           "The carburized case is not modeled: the kinetic model describes the core with the base composition.")
GRAY_NO_MODEL = ("La fundición gris no tiene modelo cinético validado en FERROLAB: se describe la transformación de la "
                 "matriz de forma cualitativa y la curva térmica es ilustrativa.",
                 "Gray iron has no validated kinetic model in FERROLAB: matrix transformation is described qualitatively and "
                 "the thermal curve is illustrative.")
GRAY_COMP = ("La GG25 (EN-GJL-250) fija una resistencia, no una composición: comprueba C, Si, Mn y la matriz de colada antes "
             "de aplicar el protocolo.",
             "GG25 (EN-GJL-250) sets a strength, not a composition: check C, Si, Mn and the as-cast matrix before applying "
             "the protocol.")
GRAY_TIME_PENDING = ("Tiempo de austenización: la fuente lo hace depender del tamaño y la composición, sin cifra.",
                     "Austenitizing time: the source makes it depend on size and composition, without a number.")

PROTOCOLS = [
    # ===================================================================== AISI 1045
    proto("prot_1045_quench_azom", "aisi_1045", "quench", "azom_water", ("Temple en agua (AZoM)", "Water hardening (AZoM)"),
          ("Endurecer el acero formando martensita.", "Harden the steel by forming martensite."),
          [heat(t=(820, 850, 845), ev="ev_az_1045_harden"), soak(*AZ_HARDEN_SOAK), transfer(),
           quench("water", "ev_az_1045_harden")],
          sources=["src_azom_1045", "src_compraco_1045"], status="source_verified", reference=True,
          medium=("Agua (o salmuera)", "Water (or brine)"),
          expected=("Martensita con posible perlita si la sección es gruesa; dureza alta. Compraco: ≥ 55 HRC en secciones "
                    "delgadas.", "Martensite with possible pearlite if the section is thick; high hardness. Compraco: "
                    "≥ 55 HRC in thin sections."),
          restrictions=[("El 1045 tiene templabilidad baja: el centro de secciones gruesas puede no templar.",
                         "1045 has low hardenability: the center of thick sections may not harden."),
                        ("Riesgo de fisuras y distorsión con temple en agua; revenir después.",
                         "Risk of cracking and distortion with water quench; temper afterwards.")],
          assumptions=[SLOW_REF], results=[{"evidence_id": "ev_cp_1045_harden", "quantity": "hardness",
                                           "text_es": "≥ 55 HRC (Compraco, aceite para espesores ≤ 6,35 mm)",
                                           "text_en": "≥ 55 HRC (Compraco, oil for walls ≤ 6.35 mm)"}], model=True),
    proto("prot_1045_quench_voest", "aisi_1045", "quench", "voestalpine_water",
          ("Temple en agua (voestalpine)", "Water hardening (voestalpine)"),
          ("Endurecer el acero formando martensita.", "Harden the steel by forming martensite."),
          [heat(t=(800, 830, 815), ev="ev_vo_1045_harden"), soak(), transfer(), quench("water", "ev_vo_1045_harden")],
          sources=["src_voestalpine_1045"], status="source_verified", medium=("Agua", "Water"),
          expected=("Martensita; voestalpine informa dureza superficial media de 57 HRC.",
                    "Martensite; voestalpine reports an average surface hardness of 57 HRC."),
          missing=[("Tiempo de sostenimiento: la ficha no lo indica.", "Holding time: the datasheet does not state it.")],
          assumptions=[SLOW_REF], results=[{"evidence_id": "ev_vo_1045_harden", "quantity": "hardness",
                                           "text_es": "57 HRC superficie (media)", "text_en": "57 HRC surface (average)"}],
          model=True),
    proto("prot_1045_temper_azom", "aisi_1045", "temper", "azom_tough", ("Revenido 400–650 °C (AZoM)", "Tempering 400–650 °C (AZoM)"),
          ("Recuperar tenacidad sacrificando dureza.", "Recover toughness at the expense of hardness."),
          [temper_heat((400, 650, 550), "ev_az_1045_temper"),
           temper_soak((30 * MIN, None, 30 * MIN), "ev_az_1045_temper_soak",
                       ("AZoM: 1 h por cada 25 mm. " + PROBE_NOTE_ES + " → 30 min como mínimo.",
                        "AZoM: 1 h per 25 mm. " + PROBE_NOTE_EN + " → at least 30 min.")),
           air_cool()],
          sources=["src_azom_1045", "src_kang_lee_2014"], status="source_verified", reference=True, goal="toughness",
          medium=("Aire en calma", "Still air"), required={"hardened": True}, default_ic="ic_aisi_1045_as_quenched_ref",
          prior="prot_1045_quench_azom",
          expected=("Martensita revenida: menor dureza, mayor tenacidad.", "Tempered martensite: lower hardness, higher toughness."),
          restrictions=[("Requiere una pieza templada; la temperatura debe quedar por debajo de Ac1.",
                         "Requires a hardened part; temperature must stay below Ac1.")], model=True),
    proto("prot_1045_temper_voest", "aisi_1045", "temper", "voestalpine_low", ("Revenido bajo 150–200 °C (voestalpine)",
                                                                             "Low tempering 150–200 °C (voestalpine)"),
          ("Aliviar tensiones del temple conservando la mayor dureza.", "Relieve quench stresses keeping most of the hardness."),
          [temper_heat((150, 200, 180), "ev_vo_1045_temper"), temper_soak(None, None, None), air_cool()],
          sources=["src_voestalpine_1045", "src_kang_lee_2014"], status="source_verified", goal="hardness",
          medium=("Aire", "Air"), required={"hardened": True}, default_ic="ic_aisi_1045_as_quenched_ref",
          prior="prot_1045_quench_voest",
          missing=[("Tiempo de revenido: la ficha no lo indica.", "Tempering time: the datasheet does not state it.")],
          model=True),
    proto("prot_1045_anneal_full", "aisi_1045", "anneal", "full_compraco", ("Recocido completo (Compraco)", "Full anneal (Compraco)"),
          ("Ablandar y homogeneizar: ferrita + perlita gruesa.", "Soften and homogenize: ferrite + coarse pearlite."),
          [heat(t=(790, 870, 830), ev="ev_cp_1045_anneal"),
           soak((60 * MIN, None, 60 * MIN), "ev_cp_1045_anneal_soak",
                ("Compraco: al menos 1 h para secciones de hasta 25 mm.", "Compraco: at least 1 h for sections up to 25 mm.")),
           furnace_cool(28.0, 650.0, "ev_cp_1045_anneal_rate"), air_cool()],
          sources=["src_compraco_1045", "src_voestalpine_1045"], status="source_verified", reference=True, goal="softening",
          medium=("Horno a 28 °C/h hasta 650 °C, luego aire", "Furnace at 28 °C/h to 650 °C, then air"),
          expected=("Ferrita proeutectoide + perlita gruesa; Compraco: 156–217 HBW.",
                    "Proeutectoid ferrite + coarse pearlite; Compraco: 156–217 HBW."),
          results=[{"evidence_id": "ev_cp_1045_anneal", "quantity": "hardness", "text_es": "156–217 HBW",
                    "text_en": "156–217 HBW"}], model=True),
    proto("prot_1045_anneal_azom", "aisi_1045", "anneal", "full_azom", ("Recocido completo (AZoM)", "Full anneal (AZoM)"),
          ("Ablandar: ferrita + perlita.", "Soften: ferrite + pearlite."),
          [heat(t=(800, 850, 825), ev="ev_az_1045_anneal"), soak(),
           furnace_cool(28.0, 650.0, "ev_cp_1045_anneal_rate", illustrative=True), air_cool()],
          sources=["src_azom_1045"], status="source_verified", goal="softening", medium=("Horno", "Furnace"),
          missing=[("Tiempo y velocidad de enfriamiento en horno: AZoM no los indica.",
                    "Hold time and furnace cooling rate: AZoM does not state them.")], model=True),
    proto("prot_1045_anneal_subcritical", "aisi_1045", "anneal", "subcritical_voest",
          ("Recocido subcrítico (voestalpine)", "Subcritical anneal (voestalpine)"),
          ("Ablandar por debajo de Ac1 sin reaustenizar.", "Soften below Ac1 without re-austenitizing."),
          [heat(role="subcritical", label="heat_to_target", t=(680, 710, 695), ev="ev_vo_1045_anneal",
                purpose=("Calentamiento por debajo de Ac1: no se forma austenita.", "Heating below Ac1: no austenite forms.")),
           soak(label="hold_target", purpose=("La cementita tiende a globulizarse y el acero se ablanda.",
                                              "Cementite tends to spheroidize and the steel softens.")),
           furnace_cool(28.0, 400.0, "ev_cp_1045_anneal_rate", illustrative=True,
                        purpose=("Enfriamiento lento controlado; sin transformación de fase.",
                                 "Slow controlled cooling; no phase transformation.")), air_cool()],
          sources=["src_voestalpine_1045"], status="source_verified", goal="softening",
          medium=("Horno controlado, enfriamiento lento", "Controlled furnace, slow cooling"),
          expected=("Ablandamiento por globulización parcial de la cementita; voestalpine: 190 HB máx. en estado recocido.",
                    "Softening by partial spheroidization of cementite; voestalpine: 190 HB max. annealed."),
          missing=[("Tiempo de sostenimiento y velocidad de enfriamiento: la ficha no los indica.",
                    "Holding time and cooling rate: the datasheet does not state them."),
                   ("Modelo de globulización: FERROLAB no lo tiene; no se calculan fracciones.",
                    "Spheroidization model: FERROLAB has none; fractions are not computed.")],
          results=[{"evidence_id": "ev_vo_1045_anneal_hb", "quantity": "hardness", "text_es": "190 HB máx.", "text_en": "190 HB max."}]),
    proto("prot_1045_stress_relief", "aisi_1045", "anneal", "stress_relief_azom", ("Alivio de tensiones (AZoM)", "Stress relief (AZoM)"),
          ("Reducir tensiones residuales sin cambiar la microestructura.", "Reduce residual stresses without changing the microstructure."),
          [heat(role="subcritical", label="heat_to_target", t=(550, 660, 600), ev="ev_az_1045_stress",
                purpose=("Calentamiento subcrítico.", "Subcritical heating.")),
           soak((30 * MIN, None, 30 * MIN), "ev_az_1045_stress_soak",
                ("AZoM: 1 h por cada 25 mm. " + PROBE_NOTE_ES + " → 30 min.", "AZoM: 1 h per 25 mm. " + PROBE_NOTE_EN + " → 30 min."),
                label="hold_target", purpose=("Relajación de tensiones por fluencia a alta temperatura.",
                                              "Stress relaxation by creep at high temperature.")), air_cool()],
          sources=["src_azom_1045", "src_voestalpine_1045"], status="source_verified", goal="stress_relief",
          medium=("Aire en calma", "Still air"),
          expected=("Microestructura prácticamente sin cambios; menos tensiones residuales.",
                    "Microstructure practically unchanged; lower residual stresses.")),
    proto("prot_1045_normalize_azom", "aisi_1045", "normalize", "azom", ("Normalizado (AZoM)", "Normalizing (AZoM)"),
          ("Afinar y uniformar el grano: ferrita + perlita fina.", "Refine and even out grain: ferrite + fine pearlite."),
          [heat(t=(870, 920, 870), ev="ev_az_1045_normalize"),
           soak((10 * MIN, 15 * MIN, 15 * MIN), "ev_az_1045_normalize_soak", ("AZoM: 10–15 min.", "AZoM: 10–15 min.")),
           air_cool()],
          sources=["src_azom_1045", "src_compraco_1045"], status="source_verified", reference=True,
          medium=("Aire en calma", "Still air"),
          expected=("Ferrita + perlita más fina que en el recocido.", "Ferrite + pearlite finer than after annealing."),
          assumptions=[SLOW_REF], model=True),
    proto("prot_1045_normalize_voest", "aisi_1045", "normalize", "voestalpine", ("Normalizado 850 °C (voestalpine)",
                                                                                 "Normalizing 850 °C (voestalpine)"),
          ("Afinar el grano.", "Refine the grain."),
          [heat(t=(850, 850, 850), ev="ev_vo_1045_normalize"), soak(), air_cool()],
          sources=["src_voestalpine_1045"], status="source_verified", medium=("Aire", "Air"),
          missing=[("Tiempo de sostenimiento: la ficha no lo indica.", "Holding time: the datasheet does not state it.")],
          model=True),
    proto("prot_1045_austemper_model", "aisi_1045", "austemper", "model_window",
          ("Austemperizado: baño calculado entre Ms y Bs", "Austempering: bath computed between Ms and Bs"),
          ("Obtener bainita sin martensita, con menos distorsión.", "Obtain bainite without martensite, with less distortion."),
          [heat(t=(820, 850, 845), ev="ev_az_1045_harden"), soak(*AZ_HARDEN_SOAK), transfer("bath"),
           bath("model_window", ev="ev_wk_austemper", purpose=AUSTEMPER_BATH_PURPOSE, rule=MODEL_WINDOW_RULE_AUS),
           air_cool("final_cool", FINAL_AFTER_BAINITE)],
          sources=["src_azom_1045", "src_wiki_austempering"], status="source_verified", reference=True,
          medium=("Baño de sales (isotérmico), luego aire", "Salt bath (isothermal), then air"),
          expected=("Bainita si la pieza llega al baño sin formar perlita; en el 1045 la perlita se forma muy rápido.",
                    "Bainite if the part reaches the bath without forming pearlite; in 1045 pearlite forms very fast."),
          restrictions=[("Condicionado por la templabilidad: el 1045 solo se austemperiza bien en secciones delgadas.",
                         "Limited by hardenability: 1045 austempers well only in thin sections.")],
          missing=[("Temperatura y tiempo de baño publicados específicamente para el 1045 (verificables).",
                    "Bath temperature and time published specifically for 1045 (verifiable).")],
          assumptions=[("El baño se modela con la severidad de un aceite sin agitar (Grossmann H = 0,25).",
                        "The bath is modeled with the severity of unagitated oil (Grossmann H = 0.25).")], model=True),
    proto("prot_1045_austemper_bodycote", "aisi_1045", "austemper", "bodycote_unverified",
          ("Austemperizado 260–370 °C (fuente no verificada)", "Austempering 260–370 °C (unverified source)"),
          ("Bainita; dureza 38–52 HRC según el proveedor.", "Bainite; 38–52 HRC according to the supplier."),
          [heat(t=(790, 915, 845), ev="ev_bc_austemper"), soak(), transfer("bath"),
           bath("user_bath", t=(260, 370, 315), ev="ev_bc_austemper", purpose=AUSTEMPER_BATH_PURPOSE),
           air_cool("final_cool", FINAL_AFTER_BAINITE)],
          sources=["src_bodycote_austempering"], status="source_unverified", goal="experimental",
          medium=("Baño de sales", "Salt bath"),
          missing=[("Fuente no consultada directamente: verificar el texto de Bodycote.",
                    "Source not consulted directly: verify Bodycote's text."),
                   ("Tiempo de baño no indicado.", "Bath time not stated.")], model=True),
    proto("prot_1045_martemper_model", "aisi_1045", "martemper", "model_window",
          ("Martemperizado: baño justo sobre Ms", "Martempering: bath just above Ms"),
          ("Formar martensita con menos tensiones y distorsión.", "Form martensite with fewer stresses and less distortion."),
          [heat(t=(820, 850, 845), ev="ev_az_1045_harden"), soak(*AZ_HARDEN_SOAK), transfer("bath"),
           bath("model_window", ev="ev_wk_martemper", label="equalization_hold", role="equalize", dur_mode="until_equalized",
                purpose=MARTEMPER_BATH_PURPOSE, rule=MODEL_WINDOW_RULE_MAR),
           air_cool("final_cool", FINAL_MARTENSITE)],
          sources=["src_azom_1045", "src_wiki_martempering"], status="source_verified", reference=True,
          medium=("Baño de sales hasta igualar, luego aire", "Salt bath until equalized, then air"),
          expected=("Martensita (más perlita si la pieza no alcanzó el baño a tiempo); revenir después.",
                    "Martensite (plus pearlite if the part did not reach the bath in time); temper afterwards."),
          restrictions=[("El rango 150–300 °C de la fuente general queda por debajo del Ms del 1045: aquí no aplica.",
                         "The general 150–300 °C range lies below the Ms of 1045: it does not apply here."),
                        ("Si la pieza permanece demasiado en el baño se forma bainita.",
                         "If the part stays too long in the bath, bainite forms.")],
          missing=[("Temperatura de baño publicada específicamente para el 1045.", "Bath temperature published specifically for 1045.")],
          model=True),
    # ===================================================================== AISI 8620
    proto("prot_8620_quench_vanguard", "aisi_8620", "quench", "uncarburized_oil",
          ("Temple sin cementar en aceite (Vanguard)", "Uncarburized oil hardening (Vanguard)"),
          ("Endurecer el núcleo de bajo carbono.", "Harden the low-carbon core."),
          [heat(t=(815, 855, 845), ev="ev_vg_8620_harden"), soak(*AZ_HARDEN_SOAK_8620), transfer(),
           quench("oil", "ev_vg_8620_harden")],
          sources=["src_vanguard_8620", "src_compraco_8620", "src_azom_1045"], status="source_verified", reference=True,
          medium=("Aceite (Vanguard admite aceite o agua)", "Oil (Vanguard allows oil or water)"),
          condition=("Sin cementar", "Not carburized"), default_ic="ic_aisi_8620_not_carburized",
          expected=("Martensita de bajo carbono y bainita en el núcleo; dureza moderada.",
                    "Low-carbon martensite and bainite in the core; moderate hardness."),
          results=[{"evidence_id": "ev_cp_8620_mass", "quantity": "hardness", "text_es": "43 HRC (barra 13 mm, aceite)",
                    "text_en": "43 HRC (13 mm bar, oil)"}], assumptions=[SLOW_REF], model=True),
    proto("prot_8620_quench_compraco", "aisi_8620", "quench", "uncarburized_845",
          ("Temple directo 845 °C en aceite (Compraco)", "Direct hardening 845 °C oil (Compraco)"),
          ("Endurecer el núcleo.", "Harden the core."),
          [heat(t=(845, 845, 845), ev="ev_cp_8620_harden"), soak(), transfer(), quench("oil", "ev_cp_8620_harden")],
          sources=["src_compraco_8620"], status="source_verified", medium=("Aceite", "Oil"),
          condition=("Sin cementar", "Not carburized"), default_ic="ic_aisi_8620_not_carburized",
          missing=[("Tiempo de sostenimiento no indicado.", "Holding time not stated.")], model=True),
    proto("prot_8620_quench_single_refine", "aisi_8620", "quench", "carburized_single_refine",
          ("Cementado: refinado simple (Vanguard)", "Carburized: single refine (Vanguard)"),
          ("Buena dureza de capa y propiedades del núcleo.", "Good case hardness and core properties."),
          [heat(t=(829, 842, 835), ev="ev_vg_8620_single"), soak(), transfer(), quench("oil", "ev_vg_8620_single")],
          sources=["src_vanguard_8620"], status="source_verified", goal="hardness", medium=("Aceite", "Oil"),
          condition=("Cementado previamente (capa de alto carbono)", "Previously carburized (high-carbon case)"),
          required={"carburized": True}, default_ic="ic_aisi_8620_carburized_ref",
          expected=("Capa martensítica dura sobre un núcleo tenaz; revenir después.",
                    "Hard martensitic case over a tough core; temper afterwards."),
          restrictions=[NO_CASE], missing=[("Composición y profundidad de la capa cementada.", "Case composition and depth.")]),
    proto("prot_8620_quench_double_refine", "aisi_8620", "quench", "carburized_double_refine",
          ("Cementado: doble refinado (Vanguard)", "Carburized: double refine (Vanguard)"),
          ("Combinación óptima de dureza de capa, resistencia y tenacidad del núcleo según el proveedor.",
           "Optimum combination of case hardness, core strength and toughness according to the supplier."),
          [heat(t=(829, 842, 835), ev="ev_vg_8620_double"), soak(), transfer(), quench("oil", "ev_vg_8620_double"),
           heat(role="austenitize_2", label="heat_to_target", t=None, ev="ev_vg_8620_double",
                purpose=("Segundo calentamiento a 760–787 °C para afinar la capa.", "Second heating to 760–787 °C to refine the case.")),
           transfer(), quench("oil", "ev_vg_8620_double")],
          sources=["src_vanguard_8620"], status="source_verified", goal="toughness", medium=("Aceite (dos veces)", "Oil (twice)"),
          condition=("Cementado previamente", "Previously carburized"), required={"carburized": True},
          default_ic="ic_aisi_8620_carburized_ref", restrictions=[NO_CASE],
          missing=[("FERROLAB todavía no simula el segundo temple a 760–787 °C como parámetro propio.",
                    "FERROLAB does not yet simulate the second quench at 760–787 °C as its own parameter.")]),
    proto("prot_8620_quench_matweb", "aisi_8620", "quench", "carburized_matweb_unverified",
          ("Cementado 925 °C 8 h + temple 845 °C (fuente no verificada)", "Carburized 925 °C 8 h + 845 °C quench (unverified source)"),
          ("Caso concreto de una ficha de datos.", "Specific datasheet case."),
          [heat(t=(845, 845, 845), ev="ev_mw_8620_carb"), soak(), transfer(),
           quench("oil", "ev_mw_8620_carb", ("Aceite agitado", "Agitated oil"))],
          sources=["src_matweb_8620_carb"], status="source_unverified", goal="experimental", medium=("Aceite agitado", "Agitated oil"),
          condition=("Cementado 925 °C, 8 h", "Carburized 925 °C, 8 h"), required={"carburized": True},
          default_ic="ic_aisi_8620_carburized_ref", restrictions=[NO_CASE],
          missing=[("Verificar la ficha MatWeb: no se pudo abrir desde el entorno.", "Verify the MatWeb sheet: could not be opened.")]),
    proto("prot_8620_temper_vanguard", "aisi_8620", "temper", "vanguard", ("Revenido 200–650 °C (Vanguard)",
                                                                           "Tempering 200–650 °C (Vanguard)"),
          ("Ajustar la resistencia según la aplicación.", "Adjust strength to the application."),
          [temper_heat((200, 650, 425), "ev_vg_8620_harden"),
           temper_soak((30 * MIN, 60 * MIN, 30 * MIN), "ev_vg_8620_draw",
                       ("Vanguard: al menos 1–2 h por pulgada. " + PROBE_NOTE_ES + " → 30–60 min.",
                        "Vanguard: at least 1–2 h per inch. " + PROBE_NOTE_EN + " → 30–60 min.")), air_cool()],
          sources=["src_vanguard_8620", "src_kang_lee_2014"], status="source_verified", reference=True,
          medium=("Aire", "Air"), required={"hardened": True}, default_ic="ic_aisi_8620_as_quenched_ref",
          prior="prot_8620_quench_vanguard", model=True,
          restrictions=[("Requiere una pieza templada; por debajo de Ac1.", "Requires a hardened part; below Ac1.")]),
    proto("prot_8620_anneal_compraco", "aisi_8620", "anneal", "conventional", ("Recocido convencional 870 °C (Compraco)",
                                                                               "Conventional anneal 870 °C (Compraco)"),
          ("Ablandar para mecanizado.", "Soften for machining."),
          [heat(t=(870, 870, 870), ev="ev_cp_8620_anneal"),
           soak((45 * MIN, 45 * MIN, 45 * MIN), "ev_cp_8620_anneal", ("Compraco: 45 min.", "Compraco: 45 min.")),
           furnace_cool(28.0, 650.0, "ev_cp_1045_anneal_rate", illustrative=True), air_cool()],
          sources=["src_compraco_8620"], status="source_verified", reference=True, goal="softening", medium=("Horno", "Furnace"),
          default_ic="ic_aisi_8620_not_carburized",
          expected=("Ferrita + perlita; Compraco: 149 HB recocido a 870 °C.", "Ferrite + pearlite; Compraco: 149 HB annealed at 870 °C."),
          model=True),
    proto("prot_8620_anneal_vanguard", "aisi_8620", "anneal", "vanguard", ("Recocido 856–885 °C (Vanguard)", "Anneal 856–885 °C (Vanguard)"),
          ("Ablandar.", "Soften."),
          [heat(t=(856, 885, 870), ev="ev_vg_8620_anneal"), soak(),
           furnace_cool(28.0, 650.0, "ev_cp_1045_anneal_rate", illustrative=True), air_cool()],
          sources=["src_vanguard_8620"], status="source_verified", goal="softening", medium=("Horno", "Furnace"),
          default_ic="ic_aisi_8620_not_carburized",
          missing=[("Tiempo de sostenimiento y velocidad de enfriamiento no indicados.", "Holding time and cooling rate not stated.")],
          model=True),
    proto("prot_8620_anneal_isothermal", "aisi_8620", "anneal", "isothermal", ("Recocido isotérmico 885 → 660 °C (Compraco)",
                                                                               "Isothermal anneal 885 → 660 °C (Compraco)"),
          ("Ferrita + perlita uniforme en menos tiempo de horno.", "Uniform ferrite + pearlite with less furnace time."),
          [heat(t=(885, 885, 885), ev="ev_cp_8620_iso"), soak(), transfer("bath"),
           bath("value", ev="ev_cp_8620_iso", d=(4 * HOUR, 4 * HOUR, 4 * HOUR), d_ev="ev_cp_8620_iso", medium="furnace",
                dur_mode="value", purpose=("Mantenimiento a 660 °C: la austenita se transforma isotérmicamente en ferrita "
                                           "y perlita.", "Hold at 660 °C: austenite transforms isothermally into ferrite "
                                           "and pearlite.")) | {"end_temperature_c": 660.0, "duration_s": 4 * HOUR},
           air_cool()],
          sources=["src_compraco_8620"], status="source_verified", goal="softening", medium=("Horno a 660 °C", "Furnace at 660 °C"),
          default_ic="ic_aisi_8620_not_carburized",
          missing=[("Tiempo a 885 °C no indicado.", "Time at 885 °C not stated.")], model=True),
    proto("prot_8620_normalize_vanguard", "aisi_8620", "normalize", "vanguard", ("Normalizado 898–926 °C (Vanguard)",
                                                                                 "Normalizing 898–926 °C (Vanguard)"),
          ("Afinar el grano antes de cementar o mecanizar.", "Refine grain before carburizing or machining."),
          [heat(t=(898, 926, 915), ev="ev_vg_8620_normalize"),
           soak((10 * MIN, 15 * MIN, 15 * MIN), "ev_az_1045_normalize_soak",
                ("Vanguard no indica tiempo; se aplica el sostenimiento de normalizado de AZoM (10–15 min), publicado "
                 "para el 1045, como supuesto declarado.",
                 "Vanguard gives no time; AZoM's normalizing soak (10–15 min), published for 1045, is applied as a declared "
                 "assumption.")), air_cool()],
          sources=["src_vanguard_8620", "src_compraco_8620", "src_azom_1045"], status="source_verified", reference=True,
          medium=("Aire", "Air"), default_ic="ic_aisi_8620_not_carburized",
          expected=("Ferrita + perlita fina y algo de bainita; Compraco: 197 HB (13 mm, 915 °C).",
                    "Ferrite + fine pearlite and some bainite; Compraco: 197 HB (13 mm, 915 °C)."),
          results=[{"evidence_id": "ev_cp_8620_normalize", "quantity": "hardness", "text_es": "197 HB (barra 13 mm, 915 °C)",
                    "text_en": "197 HB (13 mm bar, 915 °C)"}], model=True),
    proto("prot_8620_normalize_compraco", "aisi_8620", "normalize", "compraco", ("Normalizado 870–930 °C (Compraco)",
                                                                                 "Normalizing 870–930 °C (Compraco)"),
          ("Afinar el grano.", "Refine grain."), [heat(t=(870, 930, 915), ev="ev_cp_8620_normalize"), soak(), air_cool()],
          sources=["src_compraco_8620"], status="source_verified", medium=("Aire", "Air"),
          default_ic="ic_aisi_8620_not_carburized", missing=[("Tiempo no indicado.", "Time not stated.")], model=True),
    proto("prot_8620_austemper_model", "aisi_8620", "austemper", "model_window",
          ("Austemperizado del núcleo: baño calculado entre Ms y Bs", "Core austempering: bath computed between Ms and Bs"),
          ("Bainita en el acero sin cementar.", "Bainite in the uncarburized steel."),
          [heat(t=(815, 855, 845), ev="ev_vg_8620_harden"), soak(*AZ_HARDEN_SOAK_8620), transfer("bath"),
           bath("model_window", ev="ev_wk_austemper", purpose=AUSTEMPER_BATH_PURPOSE, rule=MODEL_WINDOW_RULE_AUS),
           air_cool("final_cool", FINAL_AFTER_BAINITE)],
          sources=["src_vanguard_8620", "src_wiki_austempering"], status="source_verified", reference=True,
          medium=("Baño de sales, luego aire", "Salt bath, then air"), condition=("Sin cementar", "Not carburized"),
          default_ic="ic_aisi_8620_not_carburized",
          missing=[("Temperatura y tiempo de baño publicados para el 8620 sin cementar.",
                    "Bath temperature and time published for uncarburized 8620.")], model=True),
    proto("prot_8620_carboaustemper_400", "aisi_8620", "austemper", "carbo_austemper_400",
          ("Carbo-austemperizado 400 °C / 90 min (MRS 2024)", "Carbo-austempering 400 °C / 90 min (MRS 2024)"),
          ("Capa bainítica resistente y tenaz.", "Strong and tough bainitic case."),
          [heat(t=(850, 850, 850), ev="ev_mrs_8620"), soak(), transfer("bath"),
           bath("user_bath", t=(400, 400, 400), ev="ev_mrs_8620", d=(90 * MIN, 90 * MIN, 90 * MIN), d_ev="ev_mrs_8620",
                medium="tin_bath", purpose=AUSTEMPER_BATH_PURPOSE), air_cool("final_cool", FINAL_AFTER_BAINITE)],
          sources=["src_mrs_2024_8620"], status="source_verified", goal="experimental", medium=("Baño de estaño", "Tin bath"),
          condition=("Cementación sólida 900 °C, 4–6 h, enfriada al aire", "Pack carburized 900 °C, 4–6 h, air cooled"),
          required={"carburized": True}, default_ic="ic_aisi_8620_carburized_ref",
          expected=("Bainita, martensita y placas de ferrita de Widmanstätten en la capa.",
                    "Bainite, martensite and Widmanstätten ferrite plates in the case."),
          results=[{"evidence_id": "ev_mrs_8620", "quantity": "hardness", "text_es": "Capa 63–50 HRC; capa efectiva < 0,1 mm",
                    "text_en": "Case 63–50 HRC; effective case < 0.1 mm"}],
          restrictions=[NO_CASE, ("Caso experimental de un resumen de congreso; no generalizar.",
                                  "Experimental case from a conference abstract; do not generalize.")]),
    proto("prot_8620_carboaustemper_500", "aisi_8620", "austemper", "carbo_austemper_500",
          ("Carbo-austemperizado 500 °C / 30 min (MRS 2024)", "Carbo-austempering 500 °C / 30 min (MRS 2024)"),
          ("Capa bainítica.", "Bainitic case."),
          [heat(t=(850, 850, 850), ev="ev_mrs_8620"), soak(), transfer("bath"),
           bath("user_bath", t=(500, 500, 500), ev="ev_mrs_8620", d=(30 * MIN, 30 * MIN, 30 * MIN), d_ev="ev_mrs_8620",
                medium="tin_bath", purpose=AUSTEMPER_BATH_PURPOSE), air_cool("final_cool", FINAL_AFTER_BAINITE)],
          sources=["src_mrs_2024_8620"], status="source_verified", goal="experimental", medium=("Baño de estaño", "Tin bath"),
          condition=("Cementación sólida 900 °C, 4–6 h, enfriada al aire", "Pack carburized 900 °C, 4–6 h, air cooled"),
          required={"carburized": True}, default_ic="ic_aisi_8620_carburized_ref",
          results=[{"evidence_id": "ev_mrs_8620", "quantity": "hardness", "text_es": "Capa 58–47 HRC",
                    "text_en": "Case 58–47 HRC"}],
          restrictions=[NO_CASE, ("Caso experimental de un resumen de congreso; no generalizar.",
                                  "Experimental case from a conference abstract; do not generalize.")]),
    proto("prot_8620_martemper_model", "aisi_8620", "martemper", "model_window",
          ("Martemperizado del núcleo: baño justo sobre Ms", "Core martempering: bath just above Ms"),
          ("Martensita/bainita con menos distorsión.", "Martensite/bainite with less distortion."),
          [heat(t=(815, 855, 845), ev="ev_vg_8620_harden"), soak(*AZ_HARDEN_SOAK_8620), transfer("bath"),
           bath("model_window", ev="ev_wk_martemper", label="equalization_hold", role="equalize", dur_mode="until_equalized",
                purpose=MARTEMPER_BATH_PURPOSE, rule=MODEL_WINDOW_RULE_MAR),
           air_cool("final_cool", FINAL_MARTENSITE)],
          sources=["src_vanguard_8620", "src_wiki_martempering"], status="source_verified", reference=True,
          medium=("Baño de sales hasta igualar, luego aire", "Salt bath until equalized, then air"),
          condition=("Sin cementar", "Not carburized"), default_ic="ic_aisi_8620_not_carburized",
          restrictions=[("En la industria el martemperizado del 8620 se aplica a piezas cementadas (Compraco).",
                         "Industrially, 8620 martempering is applied to carburized parts (Compraco).")], model=True),
    proto("prot_8620_martemper_carb_205", "aisi_8620", "martemper", "carburized_salt_205",
          ("Cementado: sal a 205 °C, ≥ 3 min (Compraco)", "Carburized: salt at 205 °C, ≥ 3 min (Compraco)"),
          ("Templar la capa cementada con menos distorsión.", "Harden the carburized case with less distortion."),
          [heat(), soak(), transfer("bath"),
           bath("user_bath", t=(205, 205, 205), ev="ev_cp_8620_martemper", d=(3 * MIN, None, 3 * MIN),
                d_ev="ev_cp_8620_martemper", label="equalization_hold", role="equalize", purpose=MARTEMPER_BATH_PURPOSE),
           air_cool("final_cool", FINAL_MARTENSITE)],
          sources=["src_compraco_8620"], status="source_verified", goal="experimental", medium=("Sales a 205 °C", "Salt at 205 °C"),
          condition=("Cementado (Ms de la capa por debajo de 205 °C)", "Carburized (case Ms below 205 °C)"),
          required={"carburized": True}, default_ic="ic_aisi_8620_carburized_ref",
          missing=[("Temperatura de austenización del caso citado.", "Austenitizing temperature of the cited case.")],
          restrictions=[NO_CASE, ("205 °C está por debajo del Ms del núcleo: el núcleo se templa durante el baño.",
                                  "205 °C is below the core Ms: the core hardens during the bath.")]),
    # ===================================================================== bonificado (temple + revenido alto)
    proto("prot_1045_qt_azom", "aisi_1045", "quench_temper", "azom_qt",
          ("Temple 845 °C en agua + revenido 550–650 °C (AZoM)",
           "845 °C water quench + 550–650 °C temper (AZoM)"),
          ("Máxima tenacidad con resistencia alta en una sola secuencia.", "Highest toughness with high strength in one sequence."),
          [aust_heat_fixed((820, 850, 845), "ev_az_1045_harden"),
           aust_soak_fixed(*AZ_HARDEN_SOAK, t=845, t_ev="ev_az_1045_harden"), transfer(),
           quench("water", "ev_az_1045_harden"),
           dict(temper_heat((550, 650, 600), "ev_az_1045_temper"), rule_es=QT_RULE[0], rule_en=QT_RULE[1]),
           temper_soak((30 * MIN, None, 30 * MIN), "ev_az_1045_temper_soak",
                       ("AZoM: 1 h por cada 25 mm. " + PROBE_NOTE_ES + " → 30 min como mínimo.",
                        "AZoM: 1 h per 25 mm. " + PROBE_NOTE_EN + " → at least 30 min.")),
           air_cool()],
          sources=["src_azom_1045", "src_saarstahl_c45", "src_kang_lee_2014"], status="source_verified", reference=True,
          goal="toughness", medium=("Agua (temple) y aire (revenido)", "Water (quench) and air (temper)"),
          default_ic="ic_aisi_1045_unspecified", expected=QT_EXPECTED,
          restrictions=[("El revenido debe quedar por debajo de Ac1 (≈ 725 °C).", "Tempering must stay below Ac1 (≈ 725 °C).")],
          model=True),
    proto("prot_8620_qt_vanguard", "aisi_8620", "quench_temper", "vanguard_qt",
          ("Temple 845 °C en aceite + revenido 550–650 °C (Vanguard)",
           "845 °C oil quench + 550–650 °C temper (Vanguard)"),
          ("Núcleo tenaz y resistente sin cementar.", "Tough and strong core without carburizing."),
          [aust_heat_fixed((815, 855, 845), "ev_vg_8620_harden"),
           aust_soak_fixed(*AZ_HARDEN_SOAK_8620, t=845, t_ev="ev_vg_8620_harden"), transfer(),
           quench("oil", "ev_vg_8620_harden"),
           dict(temper_heat((550, 650, 600), "ev_vg_8620_harden"), rule_es=QT_RULE[0], rule_en=QT_RULE[1]),
           temper_soak((30 * MIN, 60 * MIN, 30 * MIN), "ev_vg_8620_draw",
                       ("Vanguard: al menos 1–2 h por pulgada. " + PROBE_NOTE_ES + " → 30–60 min.",
                        "Vanguard: at least 1–2 h per inch. " + PROBE_NOTE_EN + " → 30–60 min.")),
           air_cool()],
          sources=["src_vanguard_8620", "src_saarstahl_c45", "src_kang_lee_2014"], status="source_verified", reference=True,
          goal="toughness", medium=("Aceite (temple) y aire (revenido)", "Oil (quench) and air (temper)"),
          default_ic="ic_aisi_8620_not_carburized", expected=QT_EXPECTED,
          restrictions=[NO_CASE, ("El revenido debe quedar por debajo de Ac1.", "Tempering must stay below Ac1.")], model=True),
    proto("prot_gjl250_qt_tm", "en_gjl_250", "quench_temper", "tm_qt",
          ("Temple en aceite 870 °C + revenido ≤ 550 °C (Total Materia / Compraco)",
           "870 °C oil quench + temper ≤ 550 °C (Total Materia / Compraco)"),
          ("Matriz resistente y tenaz con grafito laminar.", "Strong and tough matrix with flake graphite."),
          [preheat(650.0, "ev_tm_gray_harden", ("Calentamiento lento hasta ~650 °C para evitar fisuras.",
                                                "Slow heating to ~650 °C to avoid cracking.")),
           aust_heat_fixed((850, 900, 870), "ev_cp_gray_quench",
                           purpose=("La matriz se austeniza; el grafito no cambia de forma.",
                                    "The matrix austenitizes; graphite keeps its shape.")),
           aust_soak_fixed(None, None, None, purpose=("El carbono del grafito se disuelve en la austenita.",
                                                     "Carbon from graphite dissolves into austenite."),
                           t=870, t_ev="ev_cp_gray_quench"),
           transfer(), quench("oil", "ev_cp_gray_quench"),
           temper_heat((None, 550, None), "ev_cp_gray_temper"),
           temper_soak((30 * MIN, None, 30 * MIN), "ev_tm_gray_temper",
                       ("Total Materia: ~1 h por pulgada. " + PROBE_NOTE_ES + " → 30 min.",
                        "Total Materia: ~1 h per inch. " + PROBE_NOTE_EN + " → 30 min.")),
           air_cool()],
          sources=["src_totalmateria_gray_2", "src_compraco_gray"], status="source_verified", reference=True,
          goal="toughness", medium=("Aceite (temple) y aire (revenido)", "Oil (quench) and air (temper)"),
          default_ic="ic_gjl250_as_cast_unspecified",
          expected=("Martensita revenida en la matriz con grafito laminar sin cambios: más tenacidad que el templado.",
                    "Tempered martensite matrix with unchanged flake graphite: tougher than as-quenched."),
          restrictions=[GRAY_COMP, ("Revenir por debajo de 550 °C para evitar la grafitización (Compraco).",
                                    "Temper below 550 °C to avoid graphitization (Compraco).")],
          missing=[GRAY_TIME_PENDING, ("Temperatura mínima del revenido: las fuentes solo dan el máximo.",
                                       "Minimum tempering temperature: sources only give the maximum.")],
          assumptions=[GRAY_NO_MODEL]),
    # ===================================================================== GG25 (EN-GJL-250)
    proto("prot_gjl250_quench_tm", "en_gjl_250", "quench", "oil_tm", ("Temple en aceite (Total Materia / Compraco)",
                                                                          "Oil hardening (Total Materia / Compraco)"),
          ("Endurecer la matriz para mejorar la resistencia al desgaste.", "Harden the matrix to improve wear resistance."),
          [preheat(650.0, "ev_tm_gray_harden", ("Calentamiento lento hasta ~650 °C para evitar fisuras.",
                                                "Slow heating to ~650 °C to avoid cracking.")),
           heat(t=(850, 900, 870), ev="ev_cp_gray_quench",
                purpose=("La matriz se austeniza; el grafito no cambia de forma.", "The matrix austenitizes; graphite keeps its shape.")),
           soak(purpose=("El carbono del grafito se disuelve en la austenita.", "Carbon from graphite dissolves into austenite.")),
           transfer(), quench("oil", "ev_cp_gray_quench")],
          sources=["src_totalmateria_gray_2", "src_compraco_gray"], status="source_verified", reference=True,
          medium=("Aceite", "Oil"), default_ic="ic_gjl250_as_cast_unspecified",
          expected=("Matriz martensítica con grafito laminar sin cambios; revenir siempre.",
                    "Martensitic matrix with unchanged flake graphite; always temper."),
          restrictions=[GRAY_COMP, ("La fundición gris no aleada puede necesitar Mn suficiente para templar en el centro.",
                                    "Unalloyed gray iron may need enough Mn to harden at the center.")],
          missing=[GRAY_TIME_PENDING], assumptions=[GRAY_NO_MODEL]),
    proto("prot_gjl250_temper_tm", "en_gjl_250", "temper", "tm", ("Revenido (Total Materia)", "Tempering (Total Materia)"),
          ("Reducir fragilidad de la matriz templada.", "Reduce brittleness of the hardened matrix."),
          [temper_heat((None, 550, None), "ev_cp_gray_temper"),
           temper_soak((30 * MIN, None, 30 * MIN), "ev_tm_gray_temper",
                       ("Total Materia: ~1 h por pulgada. " + PROBE_NOTE_ES + " → 30 min. Compraco propone espesor/25 + 1 h.",
                        "Total Materia: ~1 h per inch. " + PROBE_NOTE_EN + " → 30 min. Compraco gives thickness/25 + 1 h.")),
           air_cool()],
          sources=["src_totalmateria_gray_2", "src_compraco_gray"], status="source_verified", reference=True,
          medium=("Aire", "Air"), required={"hardened": True}, default_ic="ic_gjl250_hardened_ref", prior="prot_gjl250_quench_tm",
          expected=("Martensita revenida en la matriz; grafito sin cambios.", "Tempered martensite in the matrix; unchanged graphite."),
          restrictions=[("Por debajo de 550 °C para evitar la grafitización (Compraco).",
                         "Below 550 °C to avoid graphitization (Compraco).")],
          missing=[("Temperatura mínima y valor de referencia: las fuentes solo dan el máximo.",
                    "Minimum and reference temperature: sources only give the maximum.")], assumptions=[GRAY_NO_MODEL]),
    proto("prot_gjl250_anneal_ferritize", "en_gjl_250", "anneal", "ferritizing", ("Recocido ferritizante (Total Materia)",
                                                                                      "Ferritizing anneal (Total Materia)"),
          ("Mejorar la maquinabilidad convirtiendo la perlita en ferrita + grafito.",
           "Improve machinability by turning pearlite into ferrite + graphite."),
          [heat(role="subcritical", label="heat_to_target", t=(700, 760, 730), ev="ev_tm_gray_ferritize",
                purpose=("Calentamiento por debajo del rango de transformación.", "Heating below the transformation range.")),
           soak(label="hold_target", purpose=("La cementita perlítica se descompone en ferrita y grafito.",
                                              "Pearlitic cementite decomposes into ferrite and graphite.")),
           furnace_cool(28.0, 400.0, "ev_cp_1045_anneal_rate", illustrative=True,
                        purpose=("Enfriamiento lento.", "Slow cooling.")), air_cool()],
          sources=["src_totalmateria_gray_1"], status="source_verified", reference=True, goal="machinability",
          medium=("Horno", "Furnace"), default_ic="ic_gjl250_as_cast_unspecified",
          expected=("Matriz más ferrítica, menor dureza y resistencia (≈ una clase menos).",
                    "More ferritic matrix, lower hardness and strength (≈ one grade lower)."),
          restrictions=[GRAY_COMP], missing=[("Tiempo de sostenimiento y velocidad de enfriamiento.", "Holding time and cooling rate.")],
          assumptions=[GRAY_NO_MODEL]),
    proto("prot_gjl250_anneal_full", "en_gjl_250", "anneal", "full", ("Recocido medio/completo 790–900 °C (Total Materia)",
                                                                          "Medium/full anneal 790–900 °C (Total Materia)"),
          ("Ablandar fundiciones aleadas cuando el ferritizante no basta.", "Soften alloyed irons when ferritizing is not enough."),
          [heat(t=(790, 900, 845), ev="ev_tm_gray_full"), soak(),
           furnace_cool(28.0, 675.0, "ev_cp_1045_anneal_rate", illustrative=True,
                        purpose=("Enfriamiento lento de 790 a 675 °C a través del rango de transformación.",
                                 "Slow cooling from 790 to 675 °C through the transformation range.")), air_cool()],
          sources=["src_totalmateria_gray_1"], status="source_verified", goal="softening", medium=("Horno", "Furnace"),
          default_ic="ic_gjl250_as_cast_unspecified", restrictions=[GRAY_COMP],
          missing=[("Velocidad de enfriamiento (solo «lento»).", "Cooling rate (only «slow»).")], assumptions=[GRAY_NO_MODEL]),
    proto("prot_gjl250_anneal_graphitize", "en_gjl_250", "anneal", "graphitizing", ("Recocido grafitizante 900–955 °C",
                                                                                        "Graphitizing anneal 900–955 °C"),
          ("Descomponer carburos masivos.", "Break down massive carbides."),
          [heat(t=(900, 955, 925), ev="ev_tm_gray_graphitize"), soak(),
           furnace_cool(28.0, 675.0, "ev_cp_1045_anneal_rate", illustrative=True), air_cool()],
          sources=["src_totalmateria_gray_1"], status="source_verified", goal="softening", medium=("Horno", "Furnace"),
          default_ic="ic_gjl250_as_cast_unspecified",
          restrictions=[("Solo si hay carburos masivos (fundición moteada o mal inoculada).",
                         "Only if there are massive carbides (mottled or poorly inoculated iron).")],
          missing=[("Tiempo y enfriamiento.", "Time and cooling.")], assumptions=[GRAY_NO_MODEL]),
    proto("prot_gjl250_stress_relief", "en_gjl_250", "anneal", "stress_relief", ("Alivio de tensiones 550 °C (Compraco)",
                                                                                     "Stress relief 550 °C (Compraco)"),
          ("Reducir tensiones de colada sin cambiar la matriz.", "Reduce casting stresses without changing the matrix."),
          [heat(role="subcritical", label="heat_to_target", t=(550, 550, 550), ev="ev_cp_gray_stress",
                purpose=("Calentamiento lento (60–120 °C/h según la fuente).", "Slow heating (60–120 °C/h per the source).")),
           soak(label="hold_target", purpose=("Relajación de tensiones.", "Stress relaxation.")),
           furnace_cool(30.0, 175.0, "ev_cp_gray_stress",
                        purpose=("Enfriamiento lento (20–40 °C/h) hasta 150–200 °C para no crear nuevas tensiones.",
                                 "Slow cooling (20–40 °C/h) down to 150–200 °C to avoid new stresses.")), air_cool()],
          sources=["src_compraco_gray"], status="source_verified", goal="stress_relief", medium=("Horno, luego aire", "Furnace, then air"),
          default_ic="ic_gjl250_as_cast_unspecified",
          missing=[("Tiempo de sostenimiento (depende de la pieza).", "Holding time (part-dependent).")],
          assumptions=[("Velocidad de enfriamiento: centro del intervalo publicado (30 °C/h) y fin a 175 °C (centro de 150–200).",
                        "Cooling rate: middle of the published interval (30 °C/h), ending at 175 °C (middle of 150–200).")]),
    proto("prot_gjl250_normalize_tm", "en_gjl_250", "normalize", "tm", ("Normalizado 885–925 °C (Total Materia)",
                                                                            "Normalizing 885–925 °C (Total Materia)"),
          ("Aumentar dureza y resistencia con una matriz perlítica fina.", "Increase hardness and strength with a fine pearlitic matrix."),
          [heat(t=(885, 925, 900), ev="ev_tm_gray_normalize"),
           soak((30 * MIN, None, 30 * MIN), "ev_tm_gray_normalize",
                ("Total Materia: ~1 h por pulgada de sección máxima. " + PROBE_NOTE_ES + " → 30 min.",
                 "Total Materia: ~1 h per inch of maximum section. " + PROBE_NOTE_EN + " → 30 min.")), air_cool()],
          sources=["src_totalmateria_gray_1"], status="source_verified", reference=True, medium=("Aire en calma", "Still air"),
          default_ic="ic_gjl250_as_cast_unspecified",
          expected=("Matriz perlítica más fina; la dureza depende del carbono combinado y del espaciado perlítico.",
                    "Finer pearlitic matrix; hardness depends on combined carbon and pearlite spacing."),
          restrictions=[GRAY_COMP], assumptions=[GRAY_NO_MODEL]),
    proto("prot_gjl250_austemper_tm", "en_gjl_250", "austemper", "tm_general", ("Austemperizado 230–425 °C (Total Materia)",
                                                                                    "Austempering 230–425 °C (Total Materia)"),
          ("Matriz de ferrita acicular/bainítica con austenita retenida.", "Acicular/bainitic ferrite matrix with retained austenite."),
          [heat(t=(840, 900, 870), ev="ev_tm_gray_austenitize"), soak(), transfer("bath"),
           bath("user_bath", t=(230, 425, 330), ev="ev_tm_gray_austemper", purpose=AUSTEMPER_BATH_PURPOSE),
           air_cool("final_cool", FINAL_AFTER_BAINITE)],
          sources=["src_totalmateria_gray_2"], status="source_verified", reference=True,
          medium=("Sal, aceite o plomo", "Salt, oil or lead"), default_ic="ic_gjl250_as_cast_unspecified",
          expected=("Matriz ausferrítica; no confundir con ADI (fundición nodular austemperizada).",
                    "Ausferritic matrix; do not confuse with ADI (austempered ductile iron)."),
          restrictions=[GRAY_COMP], missing=[GRAY_TIME_PENDING, ("Tiempo de baño: depende de la composición; sin cifra.",
                                                                 "Bath time: composition-dependent; no number.")],
          assumptions=[GRAY_NO_MODEL]),
    proto("prot_gjl250_austemper_hard", "en_gjl_250", "austemper", "tm_hardness", ("Austemperizado 230–290 °C (dureza)",
                                                                                       "Austempering 230–290 °C (hardness)"),
          ("Máxima dureza y resistencia al desgaste.", "Maximum hardness and wear resistance."),
          [heat(t=(840, 900, 870), ev="ev_tm_gray_austenitize"), soak(), transfer("bath"),
           bath("user_bath", t=(230, 290, 260), ev="ev_tm_gray_austemper", purpose=AUSTEMPER_BATH_PURPOSE),
           air_cool("final_cool", FINAL_AFTER_BAINITE)],
          sources=["src_totalmateria_gray_2"], status="source_verified", goal="hardness",
          medium=("Sal, aceite o plomo", "Salt, oil or lead"), default_ic="ic_gjl250_as_cast_unspecified",
          restrictions=[GRAY_COMP], missing=[GRAY_TIME_PENDING, ("Tiempo de baño.", "Bath time.")], assumptions=[GRAY_NO_MODEL]),
    proto("prot_gjl250_austemper_jmrt", "en_gjl_250", "austemper", "jmrt_2022_unverified",
          ("AGI experimental 870 °C 2 h → 360 °C 1 h (fuente no verificada)", "Experimental AGI 870 °C 2 h → 360 °C 1 h (unverified)"),
          ("Caso experimental de fundición gris austemperizada.", "Experimental austempered gray iron case."),
          [heat(t=(870, 870, 870), ev="ev_jmrt_agi"), soak((2 * HOUR, 2 * HOUR, 2 * HOUR), "ev_jmrt_agi",
                                                          ("Caso experimental: 2 h.", "Experimental case: 2 h.")),
           transfer("bath"), bath("user_bath", t=(260, 360, 360), ev="ev_jmrt_agi", d=(1 * HOUR, 2 * HOUR, 1 * HOUR),
                                  d_ev="ev_jmrt_agi", purpose=AUSTEMPER_BATH_PURPOSE),
           air_cool("final_cool", FINAL_AFTER_BAINITE)],
          sources=["src_jmrt_2022_agi"], status="source_unverified", goal="experimental", medium=("Baño", "Bath"),
          default_ic="ic_gjl250_as_cast_unspecified",
          restrictions=[GRAY_COMP, ("Condiciones de un estudio concreto (360 °C 1 h o 260 °C 2 h); no se asignan a cualquier "
                                    "GG25.", "Conditions of a specific study (360 °C 1 h or 260 °C 2 h); not assigned "
                                    "to every GG25.")],
          missing=[("Verificar el artículo (no se pudo abrir desde el entorno).", "Verify the paper (could not be opened).")],
          assumptions=[GRAY_NO_MODEL]),
    proto("prot_gjl250_martemper_tm", "en_gjl_250", "martemper", "tm", ("Martemperizado 200–260 °C (Total Materia)",
                                                                            "Martempering 200–260 °C (Total Materia)"),
          ("Martensita en la matriz con menos tensiones; revenir después.", "Martensitic matrix with fewer stresses; temper afterwards."),
          [heat(t=(840, 900, 870), ev="ev_tm_gray_austenitize"), soak(), transfer("bath"),
           bath("user_bath", t=(200, 260, 230), ev="ev_tm_gray_martemper", label="equalization_hold", role="equalize",
                dur_mode="until_equalized", purpose=MARTEMPER_BATH_PURPOSE),
           air_cool("final_cool", FINAL_MARTENSITE)],
          sources=["src_totalmateria_gray_2"], status="source_verified", reference=True,
          medium=("Sal, aceite o plomo hasta igualar, luego aire", "Salt, oil or lead until equalized, then air"),
          default_ic="ic_gjl250_as_cast_unspecified",
          expected=("Matriz martensítica frágil: revenir casi siempre.", "Brittle martensitic matrix: tempering almost always needed."),
          restrictions=[GRAY_COMP], missing=[GRAY_TIME_PENDING], assumptions=[GRAY_NO_MODEL]),
    proto("prot_gjl250_martemper_asm", "en_gjl_250", "martemper", "asm_liners_unverified",
          ("Camisas de cilindro 870 °C 1 h → 245 °C 1 min (fuente no verificada)", "Cylinder liners 870 °C 1 h → 245 °C 1 min (unverified)"),
          ("Caso industrial citado por ASM.", "Industrial case cited by ASM."),
          [heat(t=(870, 870, 870), ev="ev_asm_gray_liner"),
           soak((1 * HOUR, 1 * HOUR, 1 * HOUR), "ev_asm_gray_liner", ("Caso citado: 1 h.", "Cited case: 1 h.")), transfer("bath"),
           bath("user_bath", t=(245, 245, 245), ev="ev_asm_gray_liner", d=(1 * MIN, 1 * MIN, 1 * MIN), d_ev="ev_asm_gray_liner",
                label="equalization_hold", role="equalize", purpose=MARTEMPER_BATH_PURPOSE),
           air_cool("final_cool", FINAL_MARTENSITE)],
          sources=["src_asm_gray_ht"], status="source_unverified", goal="experimental", medium=("Baño a 245 °C", "Bath at 245 °C"),
          default_ic="ic_gjl250_as_cast_unspecified",
          restrictions=[GRAY_COMP, ("Revenido posterior del caso: 200 °C, 2 h.", "Subsequent temper of the case: 200 °C, 2 h.")],
          missing=[("Verificar el capítulo ASM (no se pudo abrir).", "Verify the ASM chapter (could not be opened).")],
          assumptions=[GRAY_NO_MODEL]),
]


# ------------------------------------------------------------------------------------------- matriz 21
def _pair(m, t, status, es, en):
    return {"material_id": m, "treatment_id": t, "compatibility_status": status, "reason_es": es, "reason_en": en,
            "quantitative_outputs_enabled": False, "required_initial_state": {"hardened": True} if t == "temper" else {},
            "review_status": "draft"}


PAIRS = [
    _pair("aisi_1045", "quench", "supported", "Temple convencional documentado (AZoM, voestalpine, Compraco).",
          "Conventional hardening documented (AZoM, voestalpine, Compraco)."),
    _pair("aisi_1045", "temper", "conditional", "Requiere un estado templado: se usa la muestra templada de referencia o una de tu historial.",
          "Requires a hardened state: the reference hardened sample or one from your history is used."),
    _pair("aisi_1045", "anneal", "supported", "Recocido completo, subcrítico y alivio de tensiones documentados como variantes separadas.",
          "Full, subcritical and stress-relief annealing documented as separate variants."),
    _pair("aisi_1045", "normalize", "supported", "Normalizado documentado (AZoM, voestalpine).", "Normalizing documented (AZoM, voestalpine)."),
    _pair("aisi_1045", "austemper", "conditional", "Condicionado por la templabilidad y la cinética: el baño se acota con el modelo TTT.",
          "Limited by hardenability and kinetics: the bath is bounded with the TTT model."),
    _pair("aisi_1045", "martemper", "conditional", "Condicionado: el baño debe quedar sobre el Ms del 1045 y retirarse antes de la bainita.",
          "Conditional: the bath must stay above 1045's Ms and be left before bainite."),
    _pair("aisi_1045", "quench_temper", "supported", "Bonificado documentado: temple en agua (AZoM) y revenido alto 550–650 °C.",
          "Quench and temper documented: water hardening (AZoM) and high temper 550–650 °C."),
    _pair("aisi_8620", "quench", "supported", "Temple documentado sin cementar (Vanguard); las variantes cementadas son aparte.",
          "Hardening documented uncarburized (Vanguard); carburized variants are separate."),
    _pair("aisi_8620", "temper", "conditional", "Requiere un estado templado (Vanguard: 200–650 °C).", "Requires a hardened state (Vanguard: 200–650 °C)."),
    _pair("aisi_8620", "anneal", "supported", "Recocido documentado (Vanguard, Compraco).", "Annealing documented (Vanguard, Compraco)."),
    _pair("aisi_8620", "normalize", "supported", "Normalizado documentado (Vanguard, Compraco).", "Normalizing documented (Vanguard, Compraco)."),
    _pair("aisi_8620", "austemper", "conditional", "Condicionado; incluye variantes de carbo-austemperizado (MRS 2024) para estado cementado.",
          "Conditional; includes carbo-austempering variants (MRS 2024) for the carburized state."),
    _pair("aisi_8620", "martemper", "conditional", "Condicionado; industrialmente se aplica a piezas cementadas.",
          "Conditional; industrially applied to carburized parts."),
    _pair("aisi_8620", "quench_temper", "supported", "Bonificado del acero sin cementar: temple en aceite (Vanguard) y revenido alto.",
          "Quench and temper of the uncarburized steel: oil hardening (Vanguard) and high temper."),
    _pair("en_gjl_250", "quench", "conditional", "Posible si la composición y la matriz lo permiten (Total Materia, Compraco).",
          "Possible if composition and matrix allow it (Total Materia, Compraco)."),
    _pair("en_gjl_250", "temper", "conditional", "Requiere una matriz previamente endurecida.", "Requires a previously hardened matrix."),
    _pair("en_gjl_250", "anneal", "supported", "Recocido ferritizante, completo, grafitizante y alivio de tensiones documentados.",
          "Ferritizing, full, graphitizing and stress-relief annealing documented."),
    _pair("en_gjl_250", "normalize", "conditional", "Aplicable según la fundición (Total Materia: 885–925 °C).",
          "Applicable depending on the iron (Total Materia: 885–925 °C)."),
    _pair("en_gjl_250", "austemper", "conditional", "Documentado para ciertas fundiciones grises; no se asume para cualquier GG25.",
          "Documented for certain gray irons; not assumed for every GG25."),
    _pair("en_gjl_250", "quench_temper", "conditional", "Temple en aceite y revenido por debajo de 550 °C (Total Materia, Compraco).",
          "Oil hardening and tempering below 550 °C (Total Materia, Compraco)."),
    _pair("en_gjl_250", "martemper", "conditional", "Documentado para fundiciones no aleadas (200–260 °C); revenir después.",
          "Documented for unalloyed irons (200–260 °C); temper afterwards."),
]
_REF = {(p["material_id"], p["treatment_id"]): p["id"] for p in PROTOCOLS if p["is_reference"]}
for _p in PAIRS:
    _p["protocol_id"] = _REF[(_p["material_id"], _p["treatment_id"])]


# ------------------------------------------------------------------------------------------- materiales
COMPOSITIONS = {
    "aisi_1045": [{"element": "C", "min_wt_pct": 0.43, "max_wt_pct": 0.50, "evidence_id": "ev_az_1045_comp"},
                  {"element": "Mn", "min_wt_pct": 0.60, "max_wt_pct": 0.90, "evidence_id": "ev_az_1045_comp"}],
    "aisi_8620": [{"element": e, "min_wt_pct": a, "max_wt_pct": b, "evidence_id": "ev_vg_8620_comp"}
                  for e, a, b in (("C", .18, .23), ("Mn", .70, .90), ("Si", .15, .35), ("Cr", .40, .60), ("Ni", .40, .70),
                                  ("Mo", .15, .25))],
}

INITIAL_CONDITIONS = [
    {"id": "ic_aisi_1045_as_quenched_ref", "material_id": "aisi_1045", "name_es": "Templado de referencia (calculado)",
     "name_en": "Reference hardened (computed)",
     "description_es": "Estado de partida calculado por FERROLAB con el protocolo de temple de referencia (AZoM, 845 °C, agua).",
     "description_en": "Starting state computed by FERROLAB with the reference hardening protocol (AZoM, 845 °C, water).",
     "hardened": True, "carburized": None, "review_status": "draft"},
    {"id": "ic_aisi_8620_as_quenched_ref", "material_id": "aisi_8620", "name_es": "Templado de referencia sin cementar (calculado)",
     "name_en": "Reference hardened, uncarburized (computed)",
     "description_es": "Estado de partida calculado con el temple de referencia (Vanguard, 845 °C, aceite).",
     "description_en": "Starting state computed with the reference hardening (Vanguard, 845 °C, oil).",
     "hardened": True, "carburized": False, "review_status": "draft"},
    {"id": "ic_aisi_8620_carburized_ref", "material_id": "aisi_8620", "name_es": "Cementado (capa de alto carbono, no modelada)",
     "name_en": "Carburized (high-carbon case, not modeled)",
     "description_es": "Pieza cementada previamente. FERROLAB no conoce la composición ni la profundidad de la capa.",
     "description_en": "Previously carburized part. FERROLAB does not know the case composition or depth.",
     "hardened": None, "carburized": True, "review_status": "draft"},
    {"id": "ic_gjl250_hardened_ref", "material_id": "en_gjl_250", "name_es": "Matriz templada de referencia",
     "name_en": "Reference hardened matrix",
     "description_es": "Fundición gris templada con el protocolo de referencia (aceite). Matriz martensítica supuesta, "
                       "composición no documentada.",
     "description_en": "Gray iron hardened with the reference protocol (oil). Assumed martensitic matrix, composition "
                       "undocumented.",
     "hardened": True, "carburized": None, "matrix": "martensite", "graphite_morphology": "flake", "review_status": "draft"},
]
