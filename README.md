> **FERROLAB** — app para aprender tratamientos térmicos. Cómo ejecutarla: [`COMO_EJECUTAR.md`](COMO_EJECUTAR.md) · Publicarla: [`docs/PUBLICAR_EN_INTERNET.md`](docs/PUBLICAR_EN_INTERNET.md) · Estado: [`docs/PROGRESO.md`](docs/PROGRESO.md)

# FERROLAB — Bluebook de producto e ingeniería

> **Versión:** 2.0.0 · **Fecha de revisión:** 18 de noviembre de 2026 · **Estado:** especificación de construcción, **no** software implementado ni datos metalúrgicos certificados.  
> **Nombre comercial:** FERROLAB · **Subtítulo:** *Virtual Heat Treatment Laboratory*.  
> **Lectura recomendada:** primero este archivo, luego `docs/01` → `docs/15`.

## 1. Qué vamos a construir

**FERROLAB** es un laboratorio virtual educativo de tratamientos térmicos, gratuito y bilingüe (español/inglés), con una experiencia visual sencilla y cuidada. El estudiante selecciona material, tratamiento, temperatura y tiempo, observa una simulación térmica animada y explora una explicación científicamente sustentada de las transformaciones y propiedades **que la evidencia permita inferir**. Un tutor de IA, cuando está disponible, **explica**; nunca sustituye al motor científico.

**Público:** estudiantes de ingeniería (principalmente 16–25 años), docentes y personas que estudian metalurgia. **Materiales iniciales:** AISI 1045, AISI 8620 y fundición gris ASTM A48 Clase 30. **Tratamientos considerados:** temple, revenido, recocido, normalizado, austempering y martempering. No todas las 18 combinaciones son científicamente equivalentes ni necesariamente modelables.

**Plataformas objetivo:** Android, iOS, web y escritorio (Windows/macOS/Linux) mediante Flutter, con despliegue incremental: **web primero**. **Arquitectura:** Flutter → FastAPI → FSE (motor determinista) + Supabase; tutor IA opcional y separado. **Operación:** sin cuentas para estudiantes, sin anuncios, sin pagos; acceso administrativo privado.

## 2. Cinco contratos que no se negocian

1. **Ciencia antes que apariencia.** Está prohibido inventar composiciones, curvas, durezas, fracciones de fase, valores de propiedades, imágenes experimentales o referencias. La ausencia de evidencia se comunica con claridad.
2. **El FSE es la autoridad científica.** La IA generativa no modifica ni calcula valores metalúrgicos; el frontend no ejecuta ecuaciones científicas.
3. **Cada afirmación numérica necesita procedencia.** Fuente concreta, versión, unidades, supuestos, aplicabilidad e incertidumbre cuando exista. No presentar una cifra sintética como dato medido.
4. **Seguridad y licencias desde el inicio.** Estudiantes sin login; administradores autenticados y autorizados. Claves privadas solo en servidor; micrografías con licencia y metadatos verificados.
5. **Experiencia útil incluso sin modelo cuantitativo.** Un caso no soportado explica el motivo y ofrece conceptos, diagramas genéricos claramente rotulados o fuentes, sin fingir resultados.

## 3. Decisiones registradas

| ID | Decisión | Consecuencia de implementación |
|---|---|---|
| ADR-001 | Flutter como cliente único | Diseño adaptable y accesible; construir web antes de empaquetar móvil/escritorio. |
| ADR-002 | FastAPI como backend modular | Una API pública documentada; sin microservicios prematuros. |
| ADR-003 | FSE determinista, aislado de IA | Tests científicos y datos versionados; misma entrada y versión ⇒ misma salida. |
| ADR-004 | Supabase PostgreSQL + Storage | RLS; publicación científica revisada; secretos solo servidor. |
| ADR-005 | Estudiantes anónimos | Historial local, no prometer sincronización entre dispositivos. |
| ADR-006 | Medio/perfil de enfriamiento fijo | El protocolo lo resuelve el servidor por material + tratamiento + versión; no editable. |
| ADR-007 | Geometría fuera del alcance inicial | No predecir gradientes internos ni propiedades de piezas reales. |
| ADR-008 | Termómetro de horno hasta 1600 °C | Rango **de interfaz**, no autorización científica para cada proceso; bloquear fuera de dominio. |
| ADR-009 | Diseño limpio inspirado en usabilidad Apple | Identidad original; no copiar interfaces ni distribuir SF Pro fuera de sus términos. |
| ADR-010 | IA optativa con modo sin IA | Plantillas educativas verificadas si no hay proveedor/cuota/presupuesto. |
| ADR-011 | Objetivo inicial ~500 personas, presupuesto operativo ideal 0 | No garantizar gratuidad ilimitada; cuotas, alojamiento y servicios pueden exigir gasto. |
| ADR-012 | Prioridad: MVP demostrable en ~7 días | El MVP puede ser cualitativo; ninguna fecha justifica ciencia inventada. |

## 4. Vocabulario común para los 16 archivos

- **Estado de compatibilidad** (`compatibility_status`): `supported`, `conditional`, `educational_only`, `unsupported`. **No** asumir `supported` sin evidencia aprobada.
- **Estado del cálculo** (`simulation_status`): `completed`, `partial_result`, `insufficient_evidence`, `unsupported`, `invalid_input`, `internal_error`.
- **Origen de un dato** (`evidence_kind`): `measured`, `literature`, `modeled`, `illustrative`, `unavailable`.
- **Solidez de un resultado individual** (`evidence_level`): `validated`, `bounded_estimate`, `qualitative`, `insufficient_evidence`, `unsupported`.
- **Flujo de publicación** (`review_status`): `draft` → `reviewed` → `published` → (`retired`, cuando corresponda). La revisión no se automatiza con IA.
- **Identificadores de materiales**: `aisi_1045`, `aisi_8620`, `astm_a48_class_30`.
- **Identificadores de tratamientos**: `quench`, `temper`, `anneal`, `normalize`, `austemper`, `martemper`.
- **Unidad interna de temperatura**: °C; de tiempo físico: segundos (`s`); entrada de mantenimiento: minutos; dureza según escala explícita (`HRC`, `HV`, `HBW`).
- **Versión publicada del paquete científico**: `dataset_version` + `model_version` + `protocol_version` + `engine_version`. Todo resultado conserva estos campos.

## 5. Índice completo — exactamente 16 documentos Markdown

1. `README.md` — contrato global, decisiones, inicio y control de coherencia.
2. `docs/01_Vision_del_Proyecto.md` — propósito, audiencia, restricciones y éxito.
3. `docs/02_PRD.md` — requisitos funcionales/no funcionales y prioridades.
4. `docs/03_Arquitectura_Software.md` — módulos, topología, seguridad y despliegue.
5. `docs/04_Motor_Cientifico_FSE.md` — dominio científico, límites, métodos y trazabilidad.
6. `docs/05_Modelo_de_Datos.md` — PostgreSQL/Supabase, relaciones, RLS y versiones.
7. `docs/06_Backend_FastAPI.md` — endpoints, contratos, validaciones y errores.
8. `docs/07_Frontend_Flutter.md` — capas Flutter, estado, pantallas y gráficos.
9. `docs/08_Design_System.md` — paleta, tipografía, componentes, accesibilidad.
10. `docs/09_UX_UI.md` — microcopy, pedagogía, interacción y estados.
11. `docs/10_Wireframes_y_Flujos.md` — wireframes textuales y recorridos de usuario.
12. `docs/11_Inteligencia_Artificial.md` — tutor con contexto verificado, privacidad y fallback.
13. `docs/12_Bibliografia_y_Fuentes.md` — fuentes, licencias y adquisición responsable.
14. `docs/13_Pruebas_y_Validacion.md` — criterios de aceptación y gates científicos.
15. `docs/14_Roadmap_Desarrollo.md` — siete días realistas, fases y publicación.
16. `docs/15_Prompt_Maestro_Claude_Code.md` — instrucción de ejecución y orden de trabajo.

## 6. Orden de precedencia en caso de discrepancia

**Seguridad, ley y licencia > evidencia científica revisada > este README/decisiones globales > PRD > arquitectura y contratos de datos > UX/estética > ejemplos.** En vez de escoger silenciosamente una opción contradictoria, Claude Code debe registrar el conflicto, preferir la alternativa segura y dejarlo en `docs/14_Roadmap_Desarrollo.md` como bloqueo o deuda técnica.

## 7. Cómo iniciar en Claude Code (para una persona que no programa)

1. Descomprimir el ZIP y abrir **la carpeta raíz `FERROLAB`**, no los archivos por separado.
2. Copiar su contenido al repositorio de trabajo `FERROLAB/` (no reemplazar las versiones sin respaldo).
3. Abrir Claude Code en esa carpeta y pegar **todo el texto** de `docs/15_Prompt_Maestro_Claude_Code.md`.
4. Exigir primero el inventario de requisitos y la implementación del **MVP web**; solicitar un resumen de cada paso en español y comandos para ejecutarlo.
5. No publicar ni introducir claves de producción hasta completar controles del documento de pruebas.

**Requisitos locales:** Flutter SDK, Python compatible, Git y, para producción, cuentas de proveedor/hosting. La disponibilidad y precios de las cuotas gratuitas requieren verificación vigente. Compilar para iOS exige entorno y herramientas Apple adecuados; **comprar ChatGPT Pro no cubre** alojamiento, cuentas de desarrollador ni API externas.

## 8. Criterios de terminación del proyecto (no del Bluebook)

- El usuario completa un flujo end-to-end en web sin cuenta.
- Cada caso publicado presenta advertencias, fuentes y dominios de validez, o informa con honestidad que faltan datos.
- El historial térmico y la animación coinciden; la simulación no altera la física al acelerar el tiempo visual.
- Las micrografías tienen trazabilidad y licencia comprobada, o se muestran alternativas claramente ilustrativas.
- La administración está protegida; las pruebas de autorización, regresión científica, UX y accesibilidad pasan.
- La IA se puede desactivar sin romper la experiencia principal.

## 9. Referencias externas de implementación

- Flutter: https://docs.flutter.dev/
- FastAPI: https://fastapi.tiangolo.com/
- Supabase RLS: https://supabase.com/docs/guides/database/postgres/row-level-security
- ASTM A48/A48M (consulta de alcance, no texto de norma reproducido): https://store.astm.org/standards/a48
- ASTM E140 (conversión de dureza, no predicción): https://store.astm.org/standards/e140

> **Nota esencial:** Bluebook ≠ programa terminado. Este paquete es una especificación coherente para construirlo y una lista explícita de lo que necesita evidencia antes de mostrar resultados cuantitativos.
