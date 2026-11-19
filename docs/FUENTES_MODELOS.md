# Modelos metalúrgicos de FERROLAB: fuentes, supuestos y validación

Todo lo que calcula el motor (`packages/fse/ferrolab_fse/metallurgy/`) sale de modelos **publicados**.
Las cifras se muestran como **estimación por modelo, no revisada por un especialista** (decisión D-26).

## Cadena de cálculo
1. **Composición**: rango de norma (1045: AZoM/Compraco; 8620: ASTM A29 vía Compraco). Valor nominal = centro del rango; la banda de incertidumbre usa los extremos.
2. **Temperaturas críticas**: Andrews (1965) para Ac1, Ac3 y Ms; Grange (1961) para Ae1/Ae3 y Li et al. (1998) para Bs, como en la implementación abierta de Collins et al. (2023, MIT, Zenodo 10.5281/zenodo.7767620).
3. **Ciclo térmico**: conducción radial 1-D implícita en un cilindro de 12,7 mm. Medios por severidad de Grossmann (agua H = 1,0; aceite H = 0,25–1,0); aire = convección natural + radiación; recocido en horno a 28 °C/h hasta 650 °C (Compraco 1045).
4. **Austenización**: regla de la palanca con la línea Ae3 (intercrítico = temple incompleto).
5. **Descomposición de la austenita**: modelo de Li (1998) con regla de aditividad de Scheil y la lógica secuencial de Collins (ferrita → perlita → bainita), enriquecimiento de carbono de la austenita; martensita por Koistinen–Marburger (α = 0,011).
6. **Dureza**: Maynier, Jungmann y Dollet (1978) por constituyente con la velocidad de enfriamiento a 700 °C; HV → HRC con la conversión publicada por COMSOL.
7. **Revenido**: el estado de partida se SUPONE templado con la práctica recomendada (se calcula y se muestra). La martensita se revierte con el parámetro de revenido dependiente de la composición de Kang y Lee (2014, *Mater. Trans.* 55:1069; 1926 datos, R² = 0,941; tiempo en segundos, 145–716 °C). Supuestos: la bainita no se endurece al revenir (se toma la menor entre su dureza y la de la martensita revenida) y la ferrita-perlita no cambia. Comprobación: el código reproduce los ejemplos del artículo (C = 12,7 para AISI 1040 y 10,3 para AISI 4340).
8. **Diagramas**: TTT (1 % y 99 %) y CCT (inicio de transformación a velocidades constantes) del mismo modelo, con la curva real del centro de la probeta superpuesta.

## Supuestos declarados (no son datos)
Probeta de 12,7 mm, resultado en el centro; k = 30 W/m·K, ρ = 7850 kg/m³, cp = 600 J/kg·K, emisividad 0,8; traslado 5 s; tamaño de grano ASTM 7; baño de austemperizado = Ms + 40 °C; baño de martemperizado = Ms + 15 °C; la austenita retenida se excluye en la regla de mezclas de dureza.

## Validación contra datos publicados (probetas de 13 mm salvo indicación)

| Caso | Modelo (centro) | Banda | Referencia | Lectura |
|---|---|---|---|---|
| 8620 temple en aceite desde 845 °C | 334 HV ≈ 34 HRC | 24–45 HRC | 43 HRC (Compraco, tabla tipo ASM) | Subestima; la referencia cae dentro de la banda |
| 8620 normalizado 915 °C | 240 HV | 179–288 HV | 197 HB | Dentro de la banda |
| 8620 recocido 870 °C | 156 HV | 139–215 HV | 149 HB | Coincide |
| 1045 recocido 830 °C | 183 HV | 170–195 HV | 156–217 HB | Coincide |
| 1045 temple en aceite, sección 6,35 mm | ≈ 34 HRC | — | ≥ 55 HRC (Compraco) | **Subestima**: el modelo de Li forma perlita demasiado rápido en aceros al carbono |

Conclusión honesta: las tendencias (qué constituyentes aparecen y cómo cambian con el medio y la temperatura) son correctas; las cifras absolutas pueden desviarse varios HRC, sobre todo en el 1045 templado. Por eso se muestran con banda y etiqueta de estimación.

## Lo que NO se calcula
- **Revenido fuera de 145–716 °C o de 30 s – 40 días**: fuera de los datos del modelo de Kang y Lee, no se estima.
- **Fundición gris ASTM A48**: sin modelo cinético validado; solo rangos recomendados e ilustración cualitativa.
- Tamaño de grano final y propiedades de tracción.

## Fuentes de los rangos recomendados
AZoM «AISI 1045» (ArticleID 6130); Compraco (fichas 1045, 8620 y guía de fundición gris, datos tipo ASM); Wikipedia «Austempering» y «Martempering».
