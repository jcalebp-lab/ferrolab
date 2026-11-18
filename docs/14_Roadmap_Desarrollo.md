# 14 — Roadmap de desarrollo FERROLAB

**Versión:** 2.0 · **Horizonte aspiracional:** ~7 días para un **MVP web honesto**, no siete días para la totalidad de 16 documentos implementados con validación experimental.  
**Premisa:** un fundador sin experiencia programando dirige a Claude Code y valida entregables. Los builds nativos, la investigación científica y los permisos pueden tomar más tiempo.

## 1. Qué significa «terminar en una semana»

**Definición responsable de MVP web:** catálogo de tres materiales + seis tratamientos; flujo sin cuenta; compatibilidad; temperatura/tiempo; protocolo fijo por combinación cuando exista; historial térmico educativo verificable; horno animado; resultados cualitativos/estado insuficiente con fuentes; panel admin básico seguro; ES/EN básico; pruebas de seguridad y accesibilidad esenciales. **No prometer:** 18 cálculos cuantitativos, curvas CCT verificadas para todos los materiales, micrografías exactas para cada condición, IA ilimitada ni apps iOS/App Store distribuidas en siete días.

Si el desarrollo va más lento, recortar animaciones sofisticadas y P1/P2; **no** recortar trazabilidad científica ni control de acceso.

## 2. Plan de siete jornadas de trabajo

| Día | Entrega técnica concreta | Cómo verificar |
|---|---|---|
| **1 — Fundamentos** | Inicializar repo; leer Bluebook; crear proyecto FastAPI+Flutter Web; enums, contratos, CI y tests vacíos. | Ejecuta healthcheck, `flutter run -d chrome`, tests básicos; documentación de comandos. |
| **2 — Datos y acceso** | Esquema mínimo, migraciones, 3 materiales y 6 tratamientos **sin cifras inventadas**; RLS/admin autenticado; seeds conceptuales. | Tablas correctas; prueba de denegación pública; sin secretos en código. |
| **3 — Motor FSE** | Validador de dominio, resolución de protocolo, historial térmico tipado, estados de insuficiencia, determinismo y tests. | No acepta perfiles del cliente, estados correctos, 18 pares catalogados, ninguna dureza sintética. |
| **4 — API** | GET catálogos, validación/simulación, manejo de errores, evidencia, OpenAPI; fallback editorial. | Integration tests, payload canónico, docs API y 401/403 de admin. |
| **5 — Flutter funcional** | Onboarding, home, wizard, slider + tiempo, tarjeta de medio bloqueado, revisión y resultados con estados. | Completar recorrido en web sin cuenta. |
| **6 — Animación + UX** | Horno 2D, gráfica térmica, fundamentos/citas, i18n, pantallas adaptables y estados vacíos. | Demo visible, reduceMotion, sin datos falsos. |
| **7 — Calidad y demo** | Tests E2E, contraste, seguridad, documentación de despliegue, build web y sesión de prueba. | Gates P0 superados, README de ejecución; no afirmar producción si falla algún gate. |

**Cada día** termina con: código ejecutable, tests, captura de resultado, pendientes, decisiones y comando de continuación en español. Si surge una dependencia paga, documentar alternativa y no introducir facturación sin autorización.

## 3. Milestones posteriores

### Fase 1 — Ampliación científica (sin fecha rígida)

Buscar, licenciar y revisar protocolos específicos por material; definir condiciones iniciales y composiciones; introducir modelos validados uno por uno; añadir golden cases experimentales; habilitar resultados cuantitativos solo para dominio exacto. Priorizar un **caso bien respaldado** sobre 18 casos de datos sintéticos.

### Fase 2 — Biblioteca visual y comparación

Ingesta de micrografías autorizadas con metadatos; zoom y pan; TTT/CCT donde la evidencia permita; comparador con procedencia; historial local/favoritos y glosario mejorado. No usar UHCS/MetalDAM como si fueran muestras equivalentes a los materiales iniciales.

### Fase 3 — IA y práctica

Tutor opcional al confirmar coste, privacidad y presupuesto; más preguntas editoriales; modo práctica con respuestas revisadas; profesor con códigos de actividad sin exigir identificación del alumnado. Gamificación y notificaciones opt-in.

### Fase 4 — Multiplataforma

Prueba y empaquetado para Android, iOS, Windows/macOS/Linux según recursos disponibles, compatibilidad SDK, cuentas de distribución y hardware. Flutter permite un núcleo compartido, no elimina pruebas ni requisitos de publicación nativa.

## 4. Dependencias bloqueantes y matriz de decisión

| Dependencia | Necesaria para | Alternativa segura si falta |
|---|---|---|
| Fuente primaria de dureza/material | Cifras de dureza. | Campo `null`, explicación cualitativa con fuente. |
| CCT/TTT autorizado | Curva específica. | No dibujar curva; enseñar TTT/CCT de manera conceptual. |
| Micrografía con licencia/condición | Microscopio de caso. | Mensaje claro, ilustración vectorial conceptual original. |
| Presupuesto/API de IA | Tutor generativo. | Explicaciones editoriales revisadas. |
| Alojamiento FastAPI estable | Demo pública persistente. | Demo local reproducible, despliegue después de verificar costos. |
| Revisor científico | Publicación cuantitativa. | Catálogo y experiencias cualitativas limitadas. |
| Entorno macOS/iOS adecuado | Build iOS. | Web/Android primero; no prometer App Store. |

## 5. Riesgos de coste para ~500 usuarios

Separar usuarios registrados (no hay) de visitantes y de solicitudes concurrentes. Estimar el presupuesto usando número de simulaciones/día, tráfico de imágenes y preguntas al tutor **después** de medir. Los planes gratuitos de Supabase y alojamiento no garantizan 500 personas simultáneas; pueden suspender servicios, variar cuotas o cobrar excedentes. Monitorizar uso de BD, Storage, tráfico y API. Implementar mecanismo de apagado de IA **antes** de conectarla. No habilitar pagos ni anuncios.

## 6. Checklist de despliegue por entorno

**Local:** `.env.example` sin secretos; Postgres de desarrollo; migraciones; seed de catálogos; `uvicorn` + Flutter web; pruebas. **Staging:** base aislada con datos no sensibles; HTTPS; CORS restringido; admin test y rate limits; activos autorizados. **Producción:** backups, rotación de secretos, revisión RLS, políticas de retención, observabilidad agregada, rollback de dataset/servicio, dominios/TLS, aviso de uso educativo.

No poner cuentas ni claves en el prompt de Claude Code. Usar el gestor de secretos del proveedor. Si el proyecto se publica y depende de proveedor gratuito, documentar un procedimiento de recuperación y de exportación de datos propios.

## 7. Registro de decisiones y deuda técnica

Al final de cada jornada, actualizar una tabla en el reporte de progreso:

```text
Fecha / commit / módulo terminado / evidencia de prueba
Decisión adoptada / razón / riesgo / reversible (sí/no)
Pendiente P0/P1/P2 / bloqueo humano / próximo paso
Costo real o cuota de proveedor verificada
```

Mantener consistentes los 16 documentos con cualquier decisión relevante y evitar ramas divergentes de API o de nombres de campos. No alterar especificaciones silenciosamente: documentar la decisión antes de cambiar un contrato.

## 8. Aceptación final del MVP

Se obtiene si: compila Flutter Web, API responde, catálogo correcto, estudiante sin login completa un recorrido, FSE es determinista, cada cifra está sustentada (o no se muestra), las imágenes cumplen permisos, el admin tiene seguridad y se puede ejecutar/desplegar el proyecto mediante comandos documentados. Un prototipo de Figma, pantallas sin backend o promesas de «IA muy precisa» **no** cumplen esta definición.

---

## 9. Registro de implementación (añadido por Claude Code, 18-11-2026)

Las decisiones, contradicciones resueltas y bloqueos se registran en `docs/DECISIONS.md` y el estado real en `docs/PROGRESO.md`. Instrucciones de ejecución: `COMO_EJECUTAR.md`.
