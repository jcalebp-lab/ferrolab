# Modelos metalúrgicos de FERROLAB: fuentes, supuestos y validación

Todo lo que calcula el motor (`packages/fse/ferrolab_fse/metallurgy/`) sale de modelos **publicados**.
Cada cifra indica su método y sus fuentes; el origen de las cifras y el estado de revisión se explican en «Supuestos y origen de las cifras» de cada resultado (decisiones D-26 y D-35).

## Cadena de cálculo
1. **Composición**: rango de norma (1045: AZoM/Compraco; 8620: ASTM A29 vía Compraco). Valor nominal = centro del rango; la banda de incertidumbre usa los extremos.
2. **Temperaturas críticas**: Andrews (1965) para Ac1, Ac3 y Ms; Grange (1961) para Ae1/Ae3 y Li et al. (1998) para Bs, como en la implementación abierta de Collins et al. (2023, MIT, Zenodo 10.5281/zenodo.7767620).
3. **Ciclo térmico**: conducción radial 1-D implícita en un cilindro de 12,7 mm. Medios por severidad de Grossmann (agua H = 1,0; aceite H = 0,25–1,0); aire = convección natural + radiación; recocido en horno a 28 °C/h hasta 650 °C (Compraco 1045).
4. **Austenización**: regla de la palanca con la línea Ae3 (intercrítico = temple incompleto).
5. **Descomposición de la austenita**: modelo de Li (1998) con regla de aditividad de Scheil y la lógica secuencial de Collins (ferrita → perlita → bainita), enriquecimiento de carbono de la austenita; martensita por Koistinen–Marburger (α = 0,011).
6. **Dureza**: Maynier, Jungmann y Dollet (1978) por constituyente con la velocidad de enfriamiento a 700 °C; HV → HRC con la conversión publicada por COMSOL.
7. **Revenido**: el estado de partida se SUPONE templado con la práctica recomendada (se calcula y se muestra). La martensita se revierte con el parámetro de revenido dependiente de la composición de Kang y Lee (2014, *Mater. Trans.* 55:1069; 1926 datos, R² = 0,941; tiempo en segundos, 145–716 °C). Supuestos: la bainita no se endurece al revenir (se toma la menor entre su dureza y la de la martensita revenida) y la ferrita-perlita no cambia. Comprobación: el código reproduce los ejemplos del artículo (C = 12,7 para AISI 1040 y 10,3 para AISI 4340).
8. **Tamaño de grano** (D-35): grano austenítico previo con Lee y Lee (2008, *Mater. Des.* 29:1840; 16 aceros de baja aleación, 850–1200 °C, hasta 3 h): d [µm] = 76671·exp(−(89098 + 3581·C + 1211·Ni + 1443·Cr + 4031·Mo)/(R·T))·t^0,211, con T en K y t en s; coeficientes según la reproducción del *Steel Forming and Heat Treating Handbook* de A. A. Gorni (el artículo original no se pudo abrir desde el entorno). El ciclo real por encima de Ae3 se integra con la regla de aditividad. Número ASTM por ASTM E112: G = −6,643856·log10(ℓ̄ [mm]) − 3,288, interpretando d como intercepto lineal medio. En recocido y normalizado con Ceq = C + Mn/6 < 0,35 (8620) se calcula además el grano ferrítico de Hodgson y Gibbs (1992, *ISIJ Int.* 32:1329): dα = (−0,4 + 6,37·Ceq) + (24,2 − 59·Ceq)·Ṫ^−0,5 + 22·(1 − exp(−0,015·dγ)) (desarrollado para aceros C–Mn: en el 8620 es una extrapolación). El G calculado alimenta la cinética de Li, los diagramas TTT/CCT y el dibujo del microscopio, donde el estudiante puede medirlo por intercepto lineal.
9. **Propiedades mecánicas**: límite de fluencia y resistencia a tracción desde la dureza HV con Pavlina y Van Tyne (2008, *J. Mater. Eng. Perform.* 17:888; >150 aceros hipoeutectoides no austeníticos): YS = −90,7 + 2,876·HV (129–632 HV) y TS = −99,8 + 3,734·HV (129–592 HV), en MPa. Fuera de esos rangos no se da la cifra. Fundición gris A48 clase 30: solo la resistencia mínima de la norma (30 ksi ≈ 207 MPa, barra colada aparte, sin tratamiento), como referencia.
10. **Diagramas**: TTT (1 % y 99 %) y CCT (inicio de transformación a velocidades constantes) del mismo modelo, con la curva real del centro de la probeta superpuesta.

## Supuestos declarados (no son datos)
Probeta de 12,7 mm, resultado en el centro; k = 30 W/m·K, ρ = 7850 kg/m³, cp = 600 J/kg·K, emisividad 0,8; traslado 5 s; tamaño de grano ASTM 7 solo si la austenización es intercrítica (si no, se calcula); baño de austemperizado = Ms + 40 °C; baño de martemperizado = Ms + 15 °C; la austenita retenida se excluye en la regla de mezclas de dureza.

## Validación contra datos publicados (probetas de 13 mm salvo indicación)

| Caso | Modelo (centro) | Banda | Referencia | Lectura |
|---|---|---|---|---|
| 8620 temple en aceite desde 845 °C (30 min) | 304 HV ≈ 30 HRC | 261–446 HV | 43 HRC (Compraco, tabla tipo ASM) | **Subestima**; la referencia cae dentro de la banda |
| 8620 normalizado 915 °C | 242 HV | 183–289 HV | 197 HB | Dentro de la banda (sobrestima) |
| 8620 recocido 870 °C | 156 HV | 139–215 HV | 149 HB | Coincide |
| 1045 recocido 830 °C | 183 HV | 170–195 HV | 156–217 HB | Coincide |
| 1045 temple en agua 845 °C (30 min), probeta 12,7 mm | 447 HV ≈ 45 HRC | 216–648 HV | ≥ 55 HRC en sección de 6,35 mm (Compraco) | **Subestima**: el modelo de Li forma perlita demasiado rápido en aceros al carbono |

Al acoplar el grano calculado (D-35) el temple sale entre 2 y 4 HRC más bajo que con el supuesto fijo G = 7 (el grano calculado a 845 °C es más fino, G ≈ 8–9, y acelera la transformación difusional); los recocidos y normalizados casi no cambian.

Conclusión honesta: las tendencias (qué constituyentes aparecen y cómo cambian con el medio y la temperatura) son correctas; las cifras absolutas pueden desviarse varios HRC, sobre todo en el 1045 templado. Por eso se muestran con banda y etiqueta de estimación.

## Lo que NO se calcula
- **Revenido fuera de 145–716 °C o de 30 s – 40 días**: fuera de los datos del modelo de Kang y Lee, no se estima.
- **Fundición gris ASTM A48**: sin modelo cinético validado; solo rangos recomendados e ilustración cualitativa.
- Alargamiento, tenacidad y fatiga (no hay correlación publicada fiable con la dureza).
- Grano ferrítico del 1045 (Ceq > 0,35: la rama de Hodgson y Gibbs da valores no físicos) y tamaño de grano de la fundición gris.

## Protocolos térmicos
Los protocolos (temperaturas, tiempos, medios, baños) y sus fuentes están en `docs/PROTOCOLOS.md`, generado desde el catálogo con `scripts/gen_protocol_matrix.py`. Fuentes consultadas: voestalpine (1045), Vanguard Steel (8620), AZoM, Compraco, Total Materia (fundición gris, partes 1 y 2), Wikipedia (austempering, martempering), MRS-México 2024 (carbo-austempering 8620). No consultables desde el entorno (variantes «no verificadas»): MatWeb 8620 cementado, ASM «Heat Treating of Gray Irons», J. Mater. Res. Technol. 2022 (fundición gris austemperizada), Bodycote.
