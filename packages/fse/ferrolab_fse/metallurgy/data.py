"""Datos y coeficientes PUBLICADOS usados por los modelos metalúrgicos.

Cada constante indica su fuente (ver SOURCES al final y docs/FUENTES_MODELOS.md).
Nada aquí es un valor inventado: si una cifra es un SUPUESTO del modelo (no un dato
de la literatura) se declara en ASSUMPTIONS y se muestra al estudiante.
"""

from __future__ import annotations

# ---------------------------------------------------------------- composiciones
# Rangos de norma (wt %). 1045: AZoM ArticleID=6130 y Compraco (SAE/AISI 1045, UNS G10450).
# 8620: ASTM A29/A322 reproducido por Compraco (UNS G86200).
# El valor nominal es el punto medio del rango; la incertidumbre se calcula evaluando
# los modelos en los extremos del rango de carbono y aleantes.
COMPOSITION_RANGES: dict[str, dict[str, tuple[float, float]]] = {
    "aisi_1045": {"C": (0.43, 0.50), "Mn": (0.60, 0.90)},
    "aisi_8620": {
        "C": (0.18, 0.23), "Mn": (0.70, 0.90), "Si": (0.15, 0.35),
        "Ni": (0.40, 0.70), "Cr": (0.40, 0.60), "Mo": (0.15, 0.25),
    },
}
ELEMENTS = ("C", "Mn", "Si", "Ni", "Cr", "Mo", "V", "W", "Cu", "P", "Al", "As", "Ti", "Co")

# Carbono eutectoide del sistema Fe-C (Wikipedia «Pearlite»: 0.76 wt%) y solubilidad
# máxima en ferrita (diagrama Fe-Fe3C, Callister: 0.022 wt%). Cementita: 6.70 wt% C.
C_EUTECTOID = 0.76
C_FERRITE_MAX = 0.022
C_CEMENTITE = 6.70

# ---------------------------------------------------------------- modelos
# Li, Niebuhr, Meekisho, Atteridge (1998) Metall. Mater. Trans. B 29B:661: los coeficientes del modelo cinético
# están en kinetics.py, contrastados con la implementación abierta de Collins et al. (2023, Metals 13:1168).

# Koistinen & Marburger (1959): f = 1 - exp(-0.011 (Ms - T)); Cambridge MAP mart2-b.
KM_ALPHA = 0.011

# Maynier, Jungmann, Dollet (1978) en «Hardenability concepts with applications to steels»,
# AIME, 518-545. Coeficientes según COMSOL Metal Processing «Hardness» y Cambridge MAP
# hardp-b.f. Discrepancias documentadas: MAP omite +53Si en ferrita-perlita y añade
# +16Mo en martensita; se usa la forma de COMSOL. Vr en K/h a 700 °C, log base 10.
MAYNIER = {
    "martensite": ((127, {"C": 949, "Si": 27, "Mn": 11, "Ni": 8, "Cr": 16}), (21, {})),
    "bainite": ((-323, {"C": 185, "Si": 330, "Mn": 153, "Ni": 65, "Cr": 144, "Mo": 191}),
                (89, {"C": 53, "Si": -55, "Mn": -22, "Ni": -10, "Cr": -20, "Mo": -33})),
    "ferrite_pearlite": ((42, {"C": 223, "Si": 53, "Mn": 30, "Ni": 12.6, "Cr": 7, "Mo": 19}),
                         (10, {"Si": -19, "Ni": 4, "Cr": 8, "V": 130})),
}
# Kang & Lee (2014) Mater. Trans. 55:1069, ecs. (4)-(5) y tabla 2: parámetro de revenido dependiente de la
# composición TP = T·(log10 t + k0 + Σ ki·Xi) y TMH = (1542.97 − 25.31/C)·exp(−1.23e-4·TP) [HV].
# T en K. El tiempo se toma en SEGUNDOS: así lo indican la tabla 1 (30 s – 3.5e6 s) y el eje de la fig. 4,
# y reproduce el ejemplo del artículo (C(1040) = 12.7). Validez: C 0.12–1.15, Mn ≤ 1.75, Si ≤ 0.90,
# Ni ≤ 3.5, Cr ≤ 2.0, Mo ≤ 0.5 (wt %); revenido 145–716 °C.
KANG_LEE_K0 = 17.396
KANG_LEE_K = {"C": -6.661, "Mn": -1.604, "Si": -3.412, "Ni": -0.248, "Cr": -1.112, "Mo": -4.355}
KANG_LEE_A, KANG_LEE_B, KANG_LEE_EXP = 1542.97, 25.31, 1.23e-4
KANG_LEE_T_RANGE_C = (145.0, 716.0)
KANG_LEE_HOLD_RANGE_S = (30.0, 3.5e6)

# HV -> HRC para aceros no austeníticos (COMSOL «Hardness», ref. 17).
HRC_COEFFS = (31.49, 7.96683e-2, -3.55432e-5, -6.72816e3)

# Severidad de temple de Grossmann H (1/pulgada), h = 2 k H (NPTEL Heat treatment VI-3):
# agua sin agitar = 1.0; aceite sin agitar = 0.25 (límite inferior del rango 0.25–1.0).
GROSSMANN_H = {"water": 1.0, "oil": 0.25}
# Rango publicado para aceite (sin agitar → agitado): 0.25–1.0. Se usa para la banda de incertidumbre.
GROSSMANN_H_RANGE = {"oil": (0.25, 1.0)}

# ---------------------------------------------------------------- supuestos (no son datos)
ASSUMPTIONS = {
    "reference_diameter_m": 0.0127,   # probeta cilíndrica de referencia de 1/2" (como tablas ASM de 13 mm)
    "report_point": "center",
    "k_w_mk": 30.0,                    # conductividad media del acero a alta temperatura
    "rho_kg_m3": 7850.0,
    "cp_j_kgk": 600.0,
    "emissivity": 0.8,
    "h_air_conv_w_m2k": 10.0,          # convección natural en aire en calma
    "transfer_s": 5.0,                 # traslado horno -> medio
    "astm_grain_size": 7.0,            # tamaño de grano austenítico previo (G ASTM)
    "furnace_cool_c_per_h": 28.0,      # recocido: 790->650 °C a 28 °C/h (Compraco 1045, «Complete annealing»)
    "furnace_cool_until_c": 650.0,
    "ambient_c": 20.0,
    "ae_equals_ac": True,              # se usan Ac1/Ac3 de Andrews como Ae1/Ae3 del modelo de Li
}

SOURCES = {
    "src_andrews_1965": "Andrews (1965) J. Iron Steel Inst. 203:721 — Ac1, Ac3, Ms (texto: metallai.com; Ms: Cambridge MAP)",
    "src_steven_haynes_1956": "Steven & Haynes (1956) J. Iron Steel Inst. 183:349 — Bs",
    "src_li_1998": "Li et al. (1998) Metall. Mater. Trans. B 29B:661 — cinética TTT (coeficientes según Collins et al. 2023)",
    "src_km_1959": "Koistinen & Marburger (1959) Acta Metall. 7:59 — martensita",
    "src_maynier_1978": "Maynier, Jungmann, Dollet (1978) — dureza por constituyente (COMSOL / Cambridge MAP)",
    "src_grossmann": "Grossmann — severidad de temple H (NPTEL)",
    "src_collins_2023": "Collins et al. (2023) Metals 13:1168 — implementación abierta del modelo de Li (Zenodo 10.5281/zenodo.7767620, MIT)",
    "src_kang_lee_2014": "Kang & Lee (2014) Mater. Trans. 55:1069 — dureza de martensita revenida (doi:10.2320/matertrans.M2014004)",
    "src_grange_1961": "Grange (1961) Metal Progress 79:73 — Ae1/Ae3 empíricas usadas por el modelo de Li",
    "src_azom_1045": "AZoM ArticleID=6130 — AISI 1045: composición y tratamientos",
    "src_compraco_1045": "Compraco — SAE/AISI 1045: tratamiento térmico (datos tipo ASM)",
    "src_compraco_8620": "Compraco — AISI 8620: composición ASTM A29 y tablas tipo ASM (temple, normalizado, críticas medidas)",
    "src_compraco_gray": "Compraco — fundición gris: guía de tratamientos térmicos",
    "src_wiki_martempering": "Wikipedia «Martempering»: baño 150–300 °C por encima de Ms",
    "src_wiki_austempering": "Wikipedia «Austempering»: austenización 790–915 °C; baño por encima de Ms",
}
