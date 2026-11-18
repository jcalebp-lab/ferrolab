# 13 — Plan maestro de pruebas y validación FERROLAB

**Versión:** 2.0 · **Estado:** criterios de salida verificables.  
**Objetivo:** impedir que una demostración bonita se confunda con una herramienta científicamente confiable. La cobertura automatizada es necesaria **pero no reemplaza** revisión de experto para modelos científicos.

## 1. Estrategia por capas

```text
                    Evaluación docente/metalúrgica
                  Tests E2E web y accesibilidad
               Integración Flutter ⇄ FastAPI ⇄ DB
            Contratos de API y autorización/seguridad
         Unitarios de dominio, datos, modelos y widgets
            Golden cases científicos con evidencia
```

**Herramientas sugeridas:** `pytest`, `pytest-cov`, `hypothesis` para invariantes de dominio, `httpx.AsyncClient` para API, tests de DB/RLS, `flutter test`, `integration_test`, auditoría manual WCAG. No inventar fixtures con números científicos esperados; sí usar números sintéticos explícitamente en pruebas de **parsing, formato y algebra**, nunca de metalurgia aplicada.

## 2. Matriz de trazabilidad

| Requisito | Caso de prueba | Prioridad | Criterio |
|---|---|---|---|
| FR-01 sin cuenta | UX-01 | P0 | Acceso hasta resultados sin registro. |
| FR-02 bilingüe | UX-02 | P0 | ES/EN completos y correctos. |
| FR-03 catálogo | DB-01 | P0 | Exactamente tres fichas v1, sin propiedades inventadas. |
| FR-04 compatibilidad | SCI-01 | P0 | Cada pareja tiene estado y razón, ninguna habilitada por defecto. |
| FR-05 límite térmico | SCI-02 | P0 | UI llega a 1600 °C visual; dominio rechaza extremos incompatibles. |
| FR-06 tiempo | API-01 | P0 | Valores negativos/NaN/Inf rechazados; etapa identificada. |
| FR-07 medio fijo | SEC-01 | P0 | Cliente no lo selecciona ni manipula en API. |
| FR-08 simulación | API-02 | P0 | `simulation_status` y versiones presentes. |
| FR-09 horno | UI-01 | P0 | Animación sigue historia; speed cambia playback, no física. |
| FR-10 gráfica térmica | UI-02 | P0 | Ejes, unidades y tramos sin distorsión. |
| FR-11 resultados | SCI-03 | P0 | Magnitudes no disponibles `null` y texto «no estimable». |
| FR-12 explicación | AI-01 | P0 | Fallback editorial sin LLM. |
| FR-13 fuentes | DATA-01 | P0 | Cifra con fuente/localizador y versión; sin evidencia no se publica. |
| FR-14 imagen | MEDIA-01 | P1 | Licencia y coincidencia; ausencia informada. |
| FR-15 TTT/CCT | SCI-04 | P1 | Rechazar tipo de curva incorrecta y fuente dudosa. |
| FR-16 comparador | UI-03 | P1 | Misma unidad y evidencias comparables. |
| FR-17 historial | PRIV-01 | P1 | Local y borrable; sin sincronización fingida. |
| FR-19 tutor | AI-02 | P1 | Ninguna cifra o fuente inventada, cuota y fallback. |
| FR-23 admin | SEC-02 | P0 | 401/403 por defecto y revisión obligatoria. |

## 3. Casos científicos esenciales

### SCI-01 — Compatibilidad material×tratamiento

Generar matriz de 3×6 = **18** registros de compatibilidad. Al iniciar sin fuentes aprobadas, ninguna pareja declara `supported` ni emite magnitudes. Las seis opciones siguen enseñándose. Cada combinación contiene explicación y protocolo definido **solo cuando existan datos aprobados**.

### SCI-02 — Dominio térmico

Una temperatura del horno dentro de 0–1600 °C no es automáticamente válida para la aleación/tratamiento. Los límites del protocolo, región metalúrgica, condición inicial y etapas se comprueban en backend. Un caso fuera del dominio devuelve `invalid_input`/`unsupported` según naturaleza; no extrapola ecuaciones.

### SCI-03 — Insuficiencia y balance

Sin correlación de dureza, el resultado tiene `hardness=null` y `evidence_level=insufficient_evidence`. Nunca convertir ausencia en `0`. Si existen fracciones validadas, comprobar cada `0≤f≤1`, base de fracción, sumas cuando corresponda y **no sumar perlita como fase adicional a ferrita y cementita**.

### SCI-04 — Diagramas

TTT no sustituye a CCT. Si dataset no coincide con material/estado/protocolo, retornar «no disponible»; no dibujar curvas sintéticas. Fe–C se presenta como equilibrio general con fuente, sin promesa de predicción de dureza.

### SCI-05 — Revenido

Un estado inicial sin martensita/estado endurecido documentado **no habilita cuantificación por revenido**. La selección conserva la explicación teórica. No asumir un ciclo de temple previo implícito.

### SCI-06 — AISI 8620

Verificar que no se reportan valores de dureza de capa cementada cuando el material no está marcado y documentado como cementado. La designación del acero no autoriza profundidad de capa, dureza superficial ni %C de una región específica.

### SCI-07 — ASTM A48 Clase 30

Material identificado como `gray_cast_iron`, sin composición única derivada del número de clase. Ningún modelo de transformación de acero se aplica por defecto. La morfología del grafito y tipo de matriz permanecen condicionados a evidencia.

### SCI-08 — Determinismo

Para iguales entradas canónicas, `engine_version`, `dataset_version`, `model_version`, `protocol_version`, el contenido científico serializado debe ser idéntico. Excluir de la comparación `request_id` y fecha de respuesta. Pruebas con hashing de snapshot científico inmutable.

### SCI-09 — Modelos/coeficientes

No permitir activar Andrews/KM/JMAK si faltan coeficientes, unidades, dominio o golden-case de referencia. Una ecuación simbólica en documentación no equivale a licencia de cálculo. Las conversiones E140 se rechazan fuera de su rango.

### SCI-10 — Historial térmico

Etapas ordenadas con tiempos estrictamente crecientes, temperatura en °C y duraciones positivas. Austempering y martempering deben tener trayectorias explícitas de baño/igualación si se habilitan. El factor visual de velocidad no cambia el historial físico.

## 4. Golden cases: cómo crearlos correctamente

Cada golden case **metálico** se prepara solo después de obtener dato experimental/comparación verificada:

```yaml
case_id: scientific-reference-001
material_id: <grado concreto>
initial_condition_id: <condición aprobada>
treatment_id: <tratamiento>
protocol_version: <versión>
dataset_version: <versión>
source_id: <fuente revisada>
source_locator: <tabla/figura/página>
measured_or_reference_quantity: <magnitud>
reference_value: <valor real desde fuente>
unit: <unidad>
uncertainty: <si la fuente la informa>
comparison_tolerance: <justificación metrológica>
reviewed_by: <revisor>
```

Los marcadores entre `<...>` son **campos pendientes**, no una fixture ejecutable. Las tolerancias se fijan por incertidumbre y dominio; no aceptar `assert abs(prediction-reference)<5` sin justificación física. Es aceptable que al comienzo haya **cero golden cases cuantitativos** y que la app no muestre números.

## 5. Seguridad y privacidad

| ID | Prueba | Esperado |
|---|---|---|
| SEC-01 | Payload público con `cooling_profile_id` malicioso | 422 o rechazo, nunca cambia perfil. |
| SEC-02 | `POST /api/v1/admin/...` sin token | 401 y cero mutaciones. |
| SEC-03 | Token de usuario no-admin intenta publicar | 403. |
| SEC-04 | Rol admin intenta publicar sin evidencia aprobada | Bloqueo de dominio/auditoría. |
| SEC-05 | RLS como `anon` intenta SELECT/UPDATE de drafts | Denegado. |
| SEC-06 | Buscar `service_role`, claves LLM, DSN en Flutter/bundle | Ninguna coincidencia de secretos reales. |
| SEC-07 | Prompt injection en tutor | No cambia hechos ni expone instrucciones. |
| SEC-08 | Límite de solicitudes y payloads excesivos | 429/413/422 según caso y configuración. |
| SEC-09 | Revocar imagen de licencia dudosa | No accesible desde catálogo público. |
| PRIV-01 | Eliminar historial local | Datos borrados, sin identidad oculta en servidor. |

**No guardar direcciones IP completas indefinidamente** como «ID anónimo» si no hay base legal o necesidad clara. Redactar secretos y datos sensibles en logs.

## 6. Medios, accesibilidad y UX

- Accesibilidad web: foco, navegación por teclado, orden de lectura, textos escalados, contraste, sin dependencia de gestos o color; pruebas con lector de pantalla.
- Horno: modo reducir movimiento y opción «saltar animación».
- Microscopio: imagen sin licencia no se publica; zoom digital rotulado; escala real solo si calibrada.
- Web responsive: probar 360 px lógicos, tablet y desktop con estados largos/ES/EN.
- Diagramas: comprobar ejes, escalas lineales/log, leyendas y tabla textual alternativa.
- Fallos de red: reintentos sin duplicar simulaciones, sin perder entrada.
- Tutor apagado: UI muestra explicación editorial útil.

## 7. Integración, CI y quality gates

**Pipeline de Pull Request** (orden):

1. Linters y type checking (`ruff`, `mypy` gradual, `dart analyze`).
2. Tests unitarios FSE y backend.
3. Pruebas de modelos de datos, migraciones y permisos RLS.
4. Tests de contrato API/Flutter a través de schemas y payloads.
5. Tests de widgets e integración web.
6. Validación de `source_id` y licencias de todos los assets publicados.
7. Escaneo de secretos/dependencias y revisión de diff.

**Bloqueantes absolutos para deploy:** credencial privada en cliente/repo; endpoint admin sin autorización; dato cuantitativo sin evidencia; imagen sin permiso; test científico golden-case fallido; incompatibilidad sin aviso. El umbral de cobertura de código se establece después de la línea base y no sustituye estos gates.

## 8. Pruebas manuales de aceptación con estudiantes

Con 3–5 participantes iniciales y un docente/revisor (muestra de usabilidad, **no** estudio estadísticamente representativo): solicitar explicar qué es el medio fijo, por qué la geometría no está modelada, qué significa «estimación acotada», por qué 8620 no implica capa cementada, y cómo distinguir TTT/CCT. Observar errores y mejorar microcopy antes de abrir piloto.

## 9. Checklist prepublicación

- [ ] `flutter build web` y endpoints salud/lectura/simulación ejecutan.
- [ ] La app inicia sin claves de IA ni cuentas de alumnos.
- [ ] Se completó una ruta E2E hasta resultado honesto.
- [ ] No hay cifras/dibujos científicos sin fuentes o etiquetas.
- [ ] Los resultados conservan versiones de datos y motor.
- [ ] El administrador no se puede usar anónimamente.
- [ ] Las licencias de imágenes publicadas están aprobadas.
- [ ] No existen errores de accesibilidad bloqueantes en flujo P0.
- [ ] Costos, límites y rollback documentados.
- [ ] Una persona revisó los contenidos científicos expuestos al público.
