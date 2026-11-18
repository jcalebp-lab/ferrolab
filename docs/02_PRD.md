# 02 — PRD: requisitos de producto FERROLAB

**Versión:** 2.0 · **Owner:** fundador del proyecto · **Estado:** línea base de implementación.  
**Referencias:** `README.md`, `01_Vision_del_Proyecto.md`, `04_Motor_Cientifico_FSE.md`, `13_Pruebas_y_Validacion.md`.

## 1. Problema, propuesta, criterio de aceptación

**Problema:** el aprendizaje de tratamientos térmicos depende a menudo de dibujos estáticos, equipos costosos o software profesional inaccesible. **Propuesta:** un laboratorio virtual que conecte las decisiones del usuario con un historial térmico visual, materiales reales, evidencia y explicaciones. **Éxito mínimo:** en web, un estudiante sin cuenta completa una simulación demostrativa con resultados científicamente honestos y referencias accesibles.

## 2. Scope y prioridad

- **P0 — MVP (~7 días, sujeto a capacidad técnica):** onboarding saltable; inicio; selector de tres materiales y seis procesos; compatibilidad; temperatura/tiempo; revisión de protocolo automático; horno animado; gráfica temperatura-tiempo; resultados cualitativos sustentados o vacíos explícitos; fichas/fuentes; español/inglés básico; modo claro/oscuro; sin login estudiantil; panel admin básico seguro; pruebas.
- **P1 — versión educativa ampliada:** curvas TTT/CCT **solo verificadas**, micrografías coincidentes licenciadas, comparaciones, historial/favoritos locales, glosario y ejercicios, tutor IA optativo con cuotas, fichas por material.
- **P2 — investigación pedagógica:** Fe–C interactivo contextualizado, superposición de fases anotadas, aumento metalográfico real si hay imágenes calibradas, códigos de actividad docente, logros, recordatorios locales opt-in, sonido/efectos opcionales y modo presentación.

P0 debe ser funcional y seguro sin P1/P2. El catálogo de seis tratamientos existe desde P0 aunque algunos devuelvan `unsupported` o `insufficient_evidence`.

## 3. Historias de usuario y aceptación

| ID | Historia / comportamiento | P | Aceptación verificable |
|---|---|---|---|
| FR-01 | Abrir sin cuenta | P0 | No solicitar email, teléfono ni contraseña a estudiantes. |
| FR-02 | Cambiar idioma | P0 | ES/EN en etiquetas, advertencias y resultados; no traducir unidades ni IDs. |
| FR-03 | Elegir material | P0 | Tres designaciones correctas, descripción y condición inicial. |
| FR-04 | Elegir tratamiento | P0 | Seis nombres correctos; incompatibilidad explicada, no simulada. |
| FR-05 | Ajustar horno | P0 | Slider hasta 1600 °C; entradas fuera del dominio del protocolo se bloquean con motivo. |
| FR-06 | Definir mantenimiento | P0 | Minutos editables, validación estricta de límites específicos. |
| FR-07 | Ver enfriamiento predefinido | P0 | Perfil/medio resueltos por servidor; control solo lectura, incluidas etapas especiales. |
| FR-08 | Lanzar ciclo | P0 | Entrada canónica, idempotencia de solicitud y estado visible. |
| FR-09 | Ver horno y pieza | P0 | Animación acelerada y pausable, con reloj físico/visual distinguidos. |
| FR-10 | Ver gráfica térmica | P0 | Mismos puntos que el historial del FSE; °C y tiempo indicados. |
| FR-11 | Ver resultados | P0 | Magnitudes no disponibles como `—`, nunca `0`; etiquetas de procedencia. |
| FR-12 | Aprender el porqué | P0 | Explicación editorial con fuentes incluso sin IA. |
| FR-13 | Consultar bibliografía | P0 | Fuente con título, edición, sección/enlace, tipo de evidencia y fecha de revisión. |
| FR-14 | Explorar microestructura | P1 | Micrografía con autor, licencia, escala y condiciones; o estado sin evidencia. |
| FR-15 | Inspeccionar TTT/CCT | P1 | Solo dataset pertinente y con unidades; no inventar curvas. |
| FR-16 | Comparar dos casos | P1 | Diferencias e incertidumbre visibles; no comparar escalas incompatibles. |
| FR-17 | Guardar historial/favoritos | P1 | Local, borrable y declarado sin sincronización entre dispositivos. |
| FR-18 | Practicar | P1 | Preguntas revisadas, retroalimentación y fuente; no calificación oficial. |
| FR-19 | Consultar tutor | P1 | Opt-in/acción explícita, respuesta ligada a evidencia y fallback sin coste. |
| FR-20 | Pantalla de profesor | P2 | Código de actividad sin datos de menores ni identificadores obligatorios. |
| FR-21 | Microscopio ampliado | P2 | Zoom/pan sin aumentar la resolución científica; magnificaciones reales verificadas. |
| FR-22 | Logros y avisos | P2 | Desactivables; recordatorios locales solo con consentimiento. |
| FR-23 | Administrar contenidos | P0 | Admin autenticado y autorizado; borradores y publicación revisada. |
| FR-24 | Exportar resultado | P1 | Archivo local con identificadores de versiones, advertencias y fuentes. |

## 4. Flujos y reglas por dominio

**Entrada de simulación (usuario):** `material_id`, `treatment_id`, `target_temperature_c`, `hold_time_min`, `initial_condition_id` si hay más de una opción permitida. **No** aceptar elección de medio de enfriamiento. Los parámetros técnicos adicionales salen de `protocol_version` aprobado: calentamiento, transferencia, mesetas, enfriamiento, condición del material y supuestos.

El horno visual llega a 1600 °C como instrumento, pero el control rechaza cualquier temperatura que supere el rango físico/modelado del proceso elegido o represente fusión. No existe una receta universal de 1600 °C para los materiales de catálogo.

**Secuencias:** el revenido exige microestructura inicial adecuada o un ciclo previo rastreable. Austempering y martempering exigen protocolos escalonados, no una simple etiqueta del medio de enfriamiento. AISI 8620 no presupone capa cementada. Fundición gris A48 Clase 30 no hereda las curvas del acero.

**Estados de compatibilidad por pareja:** `supported`, `conditional`, `educational_only`, `unsupported` con fuente y justificación. **Regla de publicación:** sin dataset revisado, el caso puede enseñar el proceso, pero no emitir cifras.

## 5. Requisitos de la pantalla de resultados

Para cada magnitud o componente:

```text
Nombre · valor y unidad SI EXISTE · estado de evidencia
Fuente concreta y versión · rango de validez · incertidumbre SI EXISTE
Supuestos · advertencias · método · fecha de revisión
```

Secciones: resumen del proceso, historial térmico, transformaciones posibles, microconstituyentes vs fases (separados), dureza (HRC/HV/HBW según aplique), propiedades mecánicas si respaldadas, micrografía, aplicaciones cualitativas, referencias y comparación. No mostrar una magnitud porque «queda bonita». `ASTM E140` permite conversiones aproximadas dentro de su dominio, no determina dureza; `E112` y `E562` describen mediciones, no pronósticos automáticos.

## 6. Requisitos no funcionales

| ID | Categoría | Requisito |
|---|---|---|
| NFR-01 | Reproducibilidad | Igual entrada/versiones ⇒ igual resultado científico (salvo ID/fecha de request). |
| NFR-02 | Seguridad | HTTPS, RLS, administración privada, secretos servidor; ningún acceso de escritura público. |
| NFR-03 | Privacidad | Sin perfil de estudiante; analítica mínima, agregada y desactivable por entorno. |
| NFR-04 | Rendimiento | Definir presupuestos y medir p95; no hacer que animaciones dependan de la latencia del cálculo. |
| NFR-05 | Escalabilidad | Diseñar para piloto ~500 usuarios sin prometer concurrencia de 500 ni coste cero. |
| NFR-06 | Accesibilidad | Navegación teclado, lector, contraste WCAG AA en texto y reducir movimiento. |
| NFR-07 | Internacionalización | ES/EN con claves semánticas y plurales/unidades correctas. |
| NFR-08 | Resiliencia | Sin IA o cuota agotada ⇒ explicación editorial; sin datos ⇒ respuesta honesta. |
| NFR-09 | Observabilidad | Errores y latencias agregadas, sin registrar prompts sensibles innecesarios. |
| NFR-10 | Compatibilidad | Flutter soporta móvil/web/escritorio; builds certificados por plataforma, web P0. |
| NFR-11 | Trazabilidad | Identificadores de dataset/modelo/protocolo/engine en toda simulación. |
| NFR-12 | Licencias | No publicar recursos con permisos ambiguos; atribuciones visibles. |

## 7. Errores y casos vacíos obligatorios

- Tratamiento incompatible: «Esta combinación no tiene un protocolo respaldado; puedes revisar el fundamento teórico».
- Temperatura no válida: «La temperatura excede el rango documentado para este protocolo».
- Faltan datos de dureza: «Dureza: no estimable con la evidencia disponible», **no** `0 HRC`.
- Micrografía sin coincidencia: «Aún no tenemos una micrografía verificada de esta condición».
- Error red: opción de reintentar sin perder entrada.
- IA deshabilitada/cuota: explicación científica editorial y fuentes.
- Gráfico no validado: **no** trazar líneas TTT/CCT de apariencia experimental.

## 8. Dependencias y criterios de entrega

**Para iniciar construcción:** SDK Flutter, Python/FastAPI, repositorio Git, esquema PostgreSQL, catálogo editorial base, políticas de acceso. **Para publicar números:** evidencia concreta, aprobación de revisor, modelo verificable, pruebas golden-case. **Para publicar imagen:** permiso y metadatos suficientes. **Para anunciar «multiplataforma listo»:** compilación y test exitoso por plataforma, no solo código compartido.

El documento `13_Pruebas_y_Validacion.md` define las pruebas para FR y NFR. El `14_Roadmap_Desarrollo.md` define alcance real por día. No aceptar pantallas de prueba estáticas como entrega funcional.
