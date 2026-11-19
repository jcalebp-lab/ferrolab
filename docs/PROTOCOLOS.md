# Biblioteca de protocolos térmicos — matriz de 18 combinaciones

Generado por `scripts/gen_protocol_matrix.py` a partir del catálogo (`database/seeds/catalog_seed.json`).
Probeta de referencia educativa: cilindro de 12,7 mm. «Modelo» = valor calculado por FERROLAB (no publicado).

## Matriz

| Tratamiento | AISI 1045 | AISI 8620 | GG25 (EN-GJL-250) |
|---|---|---|---|
| Temple | Compatible · A (modelo publicado) · 2 protocolo(s) | Compatible · A (modelo publicado) · 5 protocolo(s) | Condicional · B (cualitativo) · 1 protocolo(s) |
| Revenido | Condicional · A (modelo publicado) · 2 protocolo(s) | Condicional · A (modelo publicado) · 1 protocolo(s) | Condicional · B (cualitativo) · 1 protocolo(s) |
| Recocido | Compatible · A (modelo publicado) · 4 protocolo(s) | Compatible · A (modelo publicado) · 3 protocolo(s) | Compatible · B (cualitativo) · 4 protocolo(s) |
| Normalizado | Compatible · A (modelo publicado) · 2 protocolo(s) | Compatible · A (modelo publicado) · 2 protocolo(s) | Condicional · B (cualitativo) · 1 protocolo(s) |
| Austempering | Condicional · A (modelo publicado) · 2 protocolo(s) | Condicional · A (modelo publicado) · 3 protocolo(s) | Condicional · B (cualitativo) · 3 protocolo(s) |
| Martempering | Condicional · A (modelo publicado) · 1 protocolo(s) | Condicional · A (modelo publicado) · 2 protocolo(s) | Condicional · B (cualitativo) · 2 protocolo(s) |
| Bonificado | Compatible · A (modelo publicado) · 1 protocolo(s) | Compatible · A (modelo publicado) · 1 protocolo(s) | Condicional · B (cualitativo) · 1 protocolo(s) |

Nivel A: hay modelo publicado para el acero y el protocolo está documentado (cifras con banda, pendientes de validación por especialista). B: interpretación cualitativa (fundición gris, capas cementadas). C: demostración ilustrativa (fuente no verificada o revenido sin estado previo).

## Protocolos

### AISI 1045 — Temple: Temple en agua (AZoM) **[referencia]**

- Id: `prot_1045_quench_azom` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Endurecer el acero formando martensita.
- Horno: 820–850 °C · sostenimiento: 5–7.5 min
- Medio: Agua (o salmuera)
- Etapas: austenitize → soak → transfer → quench
- Resultados publicados del caso: ≥ 55 HRC (Compraco, aceite para espesores ≤ 6,35 mm)
- Fuentes: AISI 1045 Medium Carbon Steel (verificada); SAE/AISI 1045 — tratamiento térmico (verificada)

### AISI 1045 — Temple: Temple en agua (voestalpine)

- Id: `prot_1045_quench_voest` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Endurecer el acero formando martensita.
- Horno: 800–830 °C · sostenimiento: sin cifra en la fuente
- Medio: Agua
- Etapas: austenitize → soak → transfer → quench
- Resultados publicados del caso: 57 HRC superficie (media)
- Pendiente: Tiempo de sostenimiento: la ficha no lo indica.
- Fuentes: AISI 1045 — Technical data: heat treatment (verificada)

### AISI 1045 — Revenido: Revenido 400–650 °C (AZoM) **[referencia]**

- Id: `prot_1045_temper_azom` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Recuperar tenacidad sacrificando dureza.
- Horno: 400–650 °C · sostenimiento: 30 min
- Medio: Aire en calma
- Etapas: temper → soak → air_cool
- Fuentes: AISI 1045 Medium Carbon Steel (verificada); Prediction of tempered martensite hardness incorporating the composition-dependent tempering parameter in low alloy steels (verificada)

### AISI 1045 — Revenido: Revenido bajo 150–200 °C (voestalpine)

- Id: `prot_1045_temper_voest` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Aliviar tensiones del temple conservando la mayor dureza.
- Horno: 150–200 °C · sostenimiento: sin cifra en la fuente
- Medio: Aire
- Etapas: temper → soak → air_cool
- Pendiente: Tiempo de revenido: la ficha no lo indica.
- Fuentes: AISI 1045 — Technical data: heat treatment (verificada); Prediction of tempered martensite hardness incorporating the composition-dependent tempering parameter in low alloy steels (verificada)

### AISI 1045 — Recocido: Recocido completo (Compraco) **[referencia]**

- Id: `prot_1045_anneal_full` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Ablandar y homogeneizar: ferrita + perlita gruesa.
- Horno: 790–870 °C · sostenimiento: 60 min
- Medio: Horno a 28 °C/h hasta 650 °C, luego aire
- Etapas: austenitize → soak → furnace_cool → air_cool
- Resultados publicados del caso: 156–217 HBW
- Fuentes: SAE/AISI 1045 — tratamiento térmico (verificada); AISI 1045 — Technical data: heat treatment (verificada)

### AISI 1045 — Recocido: Recocido completo (AZoM)

- Id: `prot_1045_anneal_azom` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Ablandar: ferrita + perlita.
- Horno: 800–850 °C · sostenimiento: sin cifra en la fuente
- Medio: Horno
- Etapas: austenitize → soak → furnace_cool → air_cool
- Pendiente: Tiempo y velocidad de enfriamiento en horno: AZoM no los indica.
- Fuentes: AISI 1045 Medium Carbon Steel (verificada)

### AISI 1045 — Recocido: Recocido subcrítico (voestalpine)

- Id: `prot_1045_anneal_subcritical` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Ablandar por debajo de Ac1 sin reaustenizar.
- Horno: 680–710 °C · sostenimiento: sin cifra en la fuente
- Medio: Horno controlado, enfriamiento lento
- Etapas: subcritical → soak → furnace_cool → air_cool
- Resultados publicados del caso: 190 HB máx.
- Pendiente: Tiempo de sostenimiento y velocidad de enfriamiento: la ficha no los indica. Modelo de globulización: FERROLAB no lo tiene; no se calculan fracciones.
- Fuentes: AISI 1045 — Technical data: heat treatment (verificada)

### AISI 1045 — Recocido: Alivio de tensiones (AZoM)

- Id: `prot_1045_stress_relief` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Reducir tensiones residuales sin cambiar la microestructura.
- Horno: 550–660 °C · sostenimiento: 30 min
- Medio: Aire en calma
- Etapas: subcritical → soak → air_cool
- Fuentes: AISI 1045 Medium Carbon Steel (verificada); AISI 1045 — Technical data: heat treatment (verificada)

### AISI 1045 — Normalizado: Normalizado (AZoM) **[referencia]**

- Id: `prot_1045_normalize_azom` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Afinar y uniformar el grano: ferrita + perlita fina.
- Horno: 870–920 °C · sostenimiento: 10–15 min
- Medio: Aire en calma
- Etapas: austenitize → soak → air_cool
- Fuentes: AISI 1045 Medium Carbon Steel (verificada); SAE/AISI 1045 — tratamiento térmico (verificada)

### AISI 1045 — Normalizado: Normalizado 850 °C (voestalpine)

- Id: `prot_1045_normalize_voest` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Afinar el grano.
- Horno: 850 °C · sostenimiento: sin cifra en la fuente
- Medio: Aire
- Etapas: austenitize → soak → air_cool
- Pendiente: Tiempo de sostenimiento: la ficha no lo indica.
- Fuentes: AISI 1045 — Technical data: heat treatment (verificada)

### AISI 1045 — Austempering: Austemperizado: baño calculado entre Ms y Bs **[referencia]**

- Id: `prot_1045_austemper_model` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Obtener bainita sin martensita, con menos distorsión.
- Horno: 820–850 °C · sostenimiento: 5–7.5 min · baño: 339–576 °C (modelo) · tiempo de baño: calculado
- Medio: Baño de sales (isotérmico), luego aire
- Etapas: austenitize → soak → transfer → bath → air_cool
- Pendiente: Temperatura y tiempo de baño publicados específicamente para el 1045 (verificables).
- Fuentes: AISI 1045 Medium Carbon Steel (verificada); Austempering (verificada)

### AISI 1045 — Austempering: Austemperizado 260–370 °C (fuente no verificada)

- Id: `prot_1045_austemper_bodycote` · versión 1.0.0 · estado de evidencia: `source_unverified` · revisión: `draft`
- Objetivo: Bainita; dureza 38–52 HRC según el proveedor.
- Horno: 790–915 °C · sostenimiento: sin cifra en la fuente · baño: 260–370 °C · tiempo de baño: sin cifra en la fuente
- Medio: Baño de sales
- Etapas: austenitize → soak → transfer → bath → air_cool
- Pendiente: Fuente no consultada directamente: verificar el texto de Bodycote. Tiempo de baño no indicado.
- Fuentes: Austempering — Bodycote (NO verificada)

### AISI 1045 — Martempering: Martemperizado: baño justo sobre Ms **[referencia]**

- Id: `prot_1045_martemper_model` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Formar martensita con menos tensiones y distorsión.
- Horno: 820–850 °C · sostenimiento: 5–7.5 min · baño: 339–576 °C (modelo) · tiempo de baño: hasta igualar (modelo)
- Medio: Baño de sales hasta igualar, luego aire
- Etapas: austenitize → soak → transfer → equalize → air_cool
- Pendiente: Temperatura de baño publicada específicamente para el 1045.
- Fuentes: AISI 1045 Medium Carbon Steel (verificada); Martempering (verificada)

### AISI 8620 — Temple: Temple sin cementar en aceite (Vanguard) **[referencia]**

- Id: `prot_8620_quench_vanguard` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Endurecer el núcleo de bajo carbono.
- Condición del material: Sin cementar
- Horno: 815–855 °C · sostenimiento: 5–7.5 min
- Medio: Aceite (Vanguard admite aceite o agua)
- Etapas: austenitize → soak → transfer → quench
- Resultados publicados del caso: 43 HRC (barra 13 mm, aceite)
- Fuentes: Vanguard Steel Product Manual — AISI/SAE 8620 (verificada); AISI 8620 — tablas de tratamiento térmico (datos tipo ASM) (verificada); AISI 1045 Medium Carbon Steel (verificada)

### AISI 8620 — Temple: Temple directo 845 °C en aceite (Compraco)

- Id: `prot_8620_quench_compraco` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Endurecer el núcleo.
- Condición del material: Sin cementar
- Horno: 845 °C · sostenimiento: sin cifra en la fuente
- Medio: Aceite
- Etapas: austenitize → soak → transfer → quench
- Pendiente: Tiempo de sostenimiento no indicado.
- Fuentes: AISI 8620 — tablas de tratamiento térmico (datos tipo ASM) (verificada)

### AISI 8620 — Temple: Cementado: refinado simple (Vanguard)

- Id: `prot_8620_quench_single_refine` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Buena dureza de capa y propiedades del núcleo.
- Condición del material: Cementado previamente (capa de alto carbono)
- Horno: 829–842 °C · sostenimiento: sin cifra en la fuente
- Medio: Aceite
- Etapas: austenitize → soak → transfer → quench
- Pendiente: Composición y profundidad de la capa cementada.
- Fuentes: Vanguard Steel Product Manual — AISI/SAE 8620 (verificada)

### AISI 8620 — Temple: Cementado: doble refinado (Vanguard)

- Id: `prot_8620_quench_double_refine` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Combinación óptima de dureza de capa, resistencia y tenacidad del núcleo según el proveedor.
- Condición del material: Cementado previamente
- Horno: 829–842 °C · sostenimiento: sin cifra en la fuente
- Medio: Aceite (dos veces)
- Etapas: austenitize → soak → transfer → quench → austenitize_2 → transfer → quench
- Pendiente: FERROLAB todavía no simula el segundo temple a 760–787 °C como parámetro propio.
- Fuentes: Vanguard Steel Product Manual — AISI/SAE 8620 (verificada)

### AISI 8620 — Temple: Cementado 925 °C 8 h + temple 845 °C (fuente no verificada)

- Id: `prot_8620_quench_matweb` · versión 1.0.0 · estado de evidencia: `source_unverified` · revisión: `draft`
- Objetivo: Caso concreto de una ficha de datos.
- Condición del material: Cementado 925 °C, 8 h
- Horno: 845 °C · sostenimiento: sin cifra en la fuente
- Medio: Aceite agitado
- Etapas: austenitize → soak → transfer → quench
- Pendiente: Verificar la ficha MatWeb: no se pudo abrir desde el entorno.
- Fuentes: MatWeb — AISI 8620 carburized (matid 8298) (NO verificada)

### AISI 8620 — Revenido: Revenido 200–650 °C (Vanguard) **[referencia]**

- Id: `prot_8620_temper_vanguard` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Ajustar la resistencia según la aplicación.
- Horno: 200–650 °C · sostenimiento: 30–60 min
- Medio: Aire
- Etapas: temper → soak → air_cool
- Fuentes: Vanguard Steel Product Manual — AISI/SAE 8620 (verificada); Prediction of tempered martensite hardness incorporating the composition-dependent tempering parameter in low alloy steels (verificada)

### AISI 8620 — Recocido: Recocido convencional 870 °C (Compraco) **[referencia]**

- Id: `prot_8620_anneal_compraco` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Ablandar para mecanizado.
- Horno: 870 °C · sostenimiento: 45 min
- Medio: Horno
- Etapas: austenitize → soak → furnace_cool → air_cool
- Fuentes: AISI 8620 — tablas de tratamiento térmico (datos tipo ASM) (verificada)

### AISI 8620 — Recocido: Recocido 856–885 °C (Vanguard)

- Id: `prot_8620_anneal_vanguard` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Ablandar.
- Horno: 856–885 °C · sostenimiento: sin cifra en la fuente
- Medio: Horno
- Etapas: austenitize → soak → furnace_cool → air_cool
- Pendiente: Tiempo de sostenimiento y velocidad de enfriamiento no indicados.
- Fuentes: Vanguard Steel Product Manual — AISI/SAE 8620 (verificada)

### AISI 8620 — Recocido: Recocido isotérmico 885 → 660 °C (Compraco)

- Id: `prot_8620_anneal_isothermal` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Ferrita + perlita uniforme en menos tiempo de horno.
- Horno: 885 °C · sostenimiento: sin cifra en la fuente · baño: 660 °C · tiempo de baño: 240 min
- Medio: Horno a 660 °C
- Etapas: austenitize → soak → transfer → bath → air_cool
- Pendiente: Tiempo a 885 °C no indicado.
- Fuentes: AISI 8620 — tablas de tratamiento térmico (datos tipo ASM) (verificada)

### AISI 8620 — Normalizado: Normalizado 898–926 °C (Vanguard) **[referencia]**

- Id: `prot_8620_normalize_vanguard` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Afinar el grano antes de cementar o mecanizar.
- Horno: 898–926 °C · sostenimiento: 10–15 min
- Medio: Aire
- Etapas: austenitize → soak → air_cool
- Resultados publicados del caso: 197 HB (barra 13 mm, 915 °C)
- Fuentes: Vanguard Steel Product Manual — AISI/SAE 8620 (verificada); AISI 8620 — tablas de tratamiento térmico (datos tipo ASM) (verificada); AISI 1045 Medium Carbon Steel (verificada)

### AISI 8620 — Normalizado: Normalizado 870–930 °C (Compraco)

- Id: `prot_8620_normalize_compraco` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Afinar el grano.
- Horno: 870–930 °C · sostenimiento: sin cifra en la fuente
- Medio: Aire
- Etapas: austenitize → soak → air_cool
- Pendiente: Tiempo no indicado.
- Fuentes: AISI 8620 — tablas de tratamiento térmico (datos tipo ASM) (verificada)

### AISI 8620 — Austempering: Austemperizado del núcleo: baño calculado entre Ms y Bs **[referencia]**

- Id: `prot_8620_austemper_model` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Bainita en el acero sin cementar.
- Condición del material: Sin cementar
- Horno: 815–855 °C · sostenimiento: 5–7.5 min · baño: 428–551 °C (modelo) · tiempo de baño: calculado
- Medio: Baño de sales, luego aire
- Etapas: austenitize → soak → transfer → bath → air_cool
- Pendiente: Temperatura y tiempo de baño publicados para el 8620 sin cementar.
- Fuentes: Vanguard Steel Product Manual — AISI/SAE 8620 (verificada); Austempering (verificada)

### AISI 8620 — Austempering: Carbo-austemperizado 400 °C / 90 min (MRS 2024)

- Id: `prot_8620_carboaustemper_400` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Capa bainítica resistente y tenaz.
- Condición del material: Cementación sólida 900 °C, 4–6 h, enfriada al aire
- Horno: 850 °C · sostenimiento: sin cifra en la fuente · baño: 400 °C · tiempo de baño: 90 min
- Medio: Baño de estaño
- Etapas: austenitize → soak → transfer → bath → air_cool
- Resultados publicados del caso: Capa 63–50 HRC; capa efectiva < 0,1 mm
- Fuentes: Carbo-austempered process in two steps in a low carbon steel (AISI 8620) using eggshells in cementing mixture as an energizer (verificada)

### AISI 8620 — Austempering: Carbo-austemperizado 500 °C / 30 min (MRS 2024)

- Id: `prot_8620_carboaustemper_500` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Capa bainítica.
- Condición del material: Cementación sólida 900 °C, 4–6 h, enfriada al aire
- Horno: 850 °C · sostenimiento: sin cifra en la fuente · baño: 500 °C · tiempo de baño: 30 min
- Medio: Baño de estaño
- Etapas: austenitize → soak → transfer → bath → air_cool
- Resultados publicados del caso: Capa 58–47 HRC
- Fuentes: Carbo-austempered process in two steps in a low carbon steel (AISI 8620) using eggshells in cementing mixture as an energizer (verificada)

### AISI 8620 — Martempering: Martemperizado del núcleo: baño justo sobre Ms **[referencia]**

- Id: `prot_8620_martemper_model` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Martensita/bainita con menos distorsión.
- Condición del material: Sin cementar
- Horno: 815–855 °C · sostenimiento: 5–7.5 min · baño: 428–551 °C (modelo) · tiempo de baño: hasta igualar (modelo)
- Medio: Baño de sales hasta igualar, luego aire
- Etapas: austenitize → soak → transfer → equalize → air_cool
- Fuentes: Vanguard Steel Product Manual — AISI/SAE 8620 (verificada); Martempering (verificada)

### AISI 8620 — Martempering: Cementado: sal a 205 °C, ≥ 3 min (Compraco)

- Id: `prot_8620_martemper_carb_205` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Templar la capa cementada con menos distorsión.
- Condición del material: Cementado (Ms de la capa por debajo de 205 °C)
- Horno: sin cifra en la fuente · sostenimiento: sin cifra en la fuente · baño: 205 °C · tiempo de baño: 3 min
- Medio: Sales a 205 °C
- Etapas: austenitize → soak → transfer → equalize → air_cool
- Pendiente: Temperatura de austenización del caso citado.
- Fuentes: AISI 8620 — tablas de tratamiento térmico (datos tipo ASM) (verificada)

### AISI 1045 — Bonificado: Temple 845 °C en agua + revenido 550–650 °C (AZoM) **[referencia]**

- Id: `prot_1045_qt_azom` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Máxima tenacidad con resistencia alta en una sola secuencia.
- Horno: 550–650 °C · sostenimiento: 30 min
- Medio: Agua (temple) y aire (revenido)
- Etapas: austenitize → soak → transfer → quench → temper → soak → air_cool
- Fuentes: AISI 1045 Medium Carbon Steel (verificada); Material specification sheet Saarstahl — C45 (equivalente europeo del 1045) (NO verificada); Prediction of tempered martensite hardness incorporating the composition-dependent tempering parameter in low alloy steels (verificada)

### AISI 8620 — Bonificado: Temple 845 °C en aceite + revenido 550–650 °C (Vanguard) **[referencia]**

- Id: `prot_8620_qt_vanguard` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Núcleo tenaz y resistente sin cementar.
- Horno: 550–650 °C · sostenimiento: 30–60 min
- Medio: Aceite (temple) y aire (revenido)
- Etapas: austenitize → soak → transfer → quench → temper → soak → air_cool
- Fuentes: Vanguard Steel Product Manual — AISI/SAE 8620 (verificada); Material specification sheet Saarstahl — C45 (equivalente europeo del 1045) (NO verificada); Prediction of tempered martensite hardness incorporating the composition-dependent tempering parameter in low alloy steels (verificada)

### GG25 (EN-GJL-250) — Bonificado: Temple en aceite 870 °C + revenido ≤ 550 °C (Total Materia / Compraco) **[referencia]**

- Id: `prot_gjl250_qt_tm` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Matriz resistente y tenaz con grafito laminar.
- Horno: 550 °C · sostenimiento: 30 min
- Medio: Aceite (temple) y aire (revenido)
- Etapas: preheat → austenitize → soak → transfer → quench → temper → soak → air_cool
- Pendiente: Tiempo de austenización: la fuente lo hace depender del tamaño y la composición, sin cifra. Temperatura mínima del revenido: las fuentes solo dan el máximo.
- Fuentes: Heat Treating of Gray Irons: Part Two (verificada); Mastering Gray Cast Iron: Expert Guide to Heat Treatment (verificada)

### GG25 (EN-GJL-250) — Temple: Temple en aceite (Total Materia / Compraco) **[referencia]**

- Id: `prot_gjl250_quench_tm` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Endurecer la matriz para mejorar la resistencia al desgaste.
- Horno: 850–900 °C · sostenimiento: sin cifra en la fuente
- Medio: Aceite
- Etapas: preheat → austenitize → soak → transfer → quench
- Pendiente: Tiempo de austenización: la fuente lo hace depender del tamaño y la composición, sin cifra.
- Fuentes: Heat Treating of Gray Irons: Part Two (verificada); Mastering Gray Cast Iron: Expert Guide to Heat Treatment (verificada)

### GG25 (EN-GJL-250) — Revenido: Revenido (Total Materia) **[referencia]**

- Id: `prot_gjl250_temper_tm` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Reducir fragilidad de la matriz templada.
- Horno: 550 °C · sostenimiento: 30 min
- Medio: Aire
- Etapas: temper → soak → air_cool
- Pendiente: Temperatura mínima y valor de referencia: las fuentes solo dan el máximo.
- Fuentes: Heat Treating of Gray Irons: Part Two (verificada); Mastering Gray Cast Iron: Expert Guide to Heat Treatment (verificada)

### GG25 (EN-GJL-250) — Recocido: Recocido ferritizante (Total Materia) **[referencia]**

- Id: `prot_gjl250_anneal_ferritize` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Mejorar la maquinabilidad convirtiendo la perlita en ferrita + grafito.
- Horno: 700–760 °C · sostenimiento: sin cifra en la fuente
- Medio: Horno
- Etapas: subcritical → soak → furnace_cool → air_cool
- Pendiente: Tiempo de sostenimiento y velocidad de enfriamiento.
- Fuentes: Heat Treating of Gray Irons: Part One (verificada)

### GG25 (EN-GJL-250) — Recocido: Recocido medio/completo 790–900 °C (Total Materia)

- Id: `prot_gjl250_anneal_full` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Ablandar fundiciones aleadas cuando el ferritizante no basta.
- Horno: 790–900 °C · sostenimiento: sin cifra en la fuente
- Medio: Horno
- Etapas: austenitize → soak → furnace_cool → air_cool
- Pendiente: Velocidad de enfriamiento (solo «lento»).
- Fuentes: Heat Treating of Gray Irons: Part One (verificada)

### GG25 (EN-GJL-250) — Recocido: Recocido grafitizante 900–955 °C

- Id: `prot_gjl250_anneal_graphitize` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Descomponer carburos masivos.
- Horno: 900–955 °C · sostenimiento: sin cifra en la fuente
- Medio: Horno
- Etapas: austenitize → soak → furnace_cool → air_cool
- Pendiente: Tiempo y enfriamiento.
- Fuentes: Heat Treating of Gray Irons: Part One (verificada)

### GG25 (EN-GJL-250) — Recocido: Alivio de tensiones 550 °C (Compraco)

- Id: `prot_gjl250_stress_relief` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Reducir tensiones de colada sin cambiar la matriz.
- Horno: 550 °C · sostenimiento: sin cifra en la fuente
- Medio: Horno, luego aire
- Etapas: subcritical → soak → furnace_cool → air_cool
- Pendiente: Tiempo de sostenimiento (depende de la pieza).
- Fuentes: Mastering Gray Cast Iron: Expert Guide to Heat Treatment (verificada)

### GG25 (EN-GJL-250) — Normalizado: Normalizado 885–925 °C (Total Materia) **[referencia]**

- Id: `prot_gjl250_normalize_tm` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Aumentar dureza y resistencia con una matriz perlítica fina.
- Horno: 885–925 °C · sostenimiento: 30 min
- Medio: Aire en calma
- Etapas: austenitize → soak → air_cool
- Fuentes: Heat Treating of Gray Irons: Part One (verificada)

### GG25 (EN-GJL-250) — Austempering: Austemperizado 230–425 °C (Total Materia) **[referencia]**

- Id: `prot_gjl250_austemper_tm` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Matriz de ferrita acicular/bainítica con austenita retenida.
- Horno: 840–900 °C · sostenimiento: sin cifra en la fuente · baño: 230–425 °C · tiempo de baño: sin cifra en la fuente
- Medio: Sal, aceite o plomo
- Etapas: austenitize → soak → transfer → bath → air_cool
- Pendiente: Tiempo de austenización: la fuente lo hace depender del tamaño y la composición, sin cifra. Tiempo de baño: depende de la composición; sin cifra.
- Fuentes: Heat Treating of Gray Irons: Part Two (verificada)

### GG25 (EN-GJL-250) — Austempering: Austemperizado 230–290 °C (dureza)

- Id: `prot_gjl250_austemper_hard` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Máxima dureza y resistencia al desgaste.
- Horno: 840–900 °C · sostenimiento: sin cifra en la fuente · baño: 230–290 °C · tiempo de baño: sin cifra en la fuente
- Medio: Sal, aceite o plomo
- Etapas: austenitize → soak → transfer → bath → air_cool
- Pendiente: Tiempo de austenización: la fuente lo hace depender del tamaño y la composición, sin cifra. Tiempo de baño.
- Fuentes: Heat Treating of Gray Irons: Part Two (verificada)

### GG25 (EN-GJL-250) — Austempering: AGI experimental 870 °C 2 h → 360 °C 1 h (fuente no verificada)

- Id: `prot_gjl250_austemper_jmrt` · versión 1.0.0 · estado de evidencia: `source_unverified` · revisión: `draft`
- Objetivo: Caso experimental de fundición gris austemperizada.
- Horno: 870 °C · sostenimiento: 120 min · baño: 260–360 °C · tiempo de baño: 60–120 min
- Medio: Baño
- Etapas: austenitize → soak → transfer → bath → air_cool
- Pendiente: Verificar el artículo (no se pudo abrir desde el entorno).
- Fuentes: Wear resistance of austempered grey iron under dry and wet conditions (NO verificada)

### GG25 (EN-GJL-250) — Martempering: Martemperizado 200–260 °C (Total Materia) **[referencia]**

- Id: `prot_gjl250_martemper_tm` · versión 1.0.0 · estado de evidencia: `source_verified` · revisión: `draft`
- Objetivo: Martensita en la matriz con menos tensiones; revenir después.
- Horno: 840–900 °C · sostenimiento: sin cifra en la fuente · baño: 200–260 °C · tiempo de baño: hasta igualar (modelo)
- Medio: Sal, aceite o plomo hasta igualar, luego aire
- Etapas: austenitize → soak → transfer → equalize → air_cool
- Pendiente: Tiempo de austenización: la fuente lo hace depender del tamaño y la composición, sin cifra.
- Fuentes: Heat Treating of Gray Irons: Part Two (verificada)

### GG25 (EN-GJL-250) — Martempering: Camisas de cilindro 870 °C 1 h → 245 °C 1 min (fuente no verificada)

- Id: `prot_gjl250_martemper_asm` · versión 1.0.0 · estado de evidencia: `source_unverified` · revisión: `draft`
- Objetivo: Caso industrial citado por ASM.
- Horno: 870 °C · sostenimiento: 60 min · baño: 245 °C · tiempo de baño: 1 min
- Medio: Baño a 245 °C
- Etapas: austenitize → soak → transfer → equalize → air_cool
- Pendiente: Verificar el capítulo ASM (no se pudo abrir).
- Fuentes: ASM Handbook Vol. 4D — Heat Treating of Gray Irons (NO verificada)

