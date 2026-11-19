# Estado del proyecto FERROLAB

**Fecha:** 18-11-2026 · **Engine:** 0.1.0 · **Dataset activo en desarrollo:** `0.1.0-dev+unreviewed`

## 0. Publicado

- **App web pública:** https://ferrolab-ckzk.onrender.com (Render, plan gratuito, región Virginia; se duerme tras ~15 min sin visitas y tarda ~1 min en despertar).
- **Base de datos:** Supabase (proyecto `fkwxdzkstjsbffqpgdqj`, us-east-1), usuario propio `ferrolab_app` sin privilegios de superusuario; 27 tablas con RLS de denegación por defecto.
- **Modo:** `staging` (piloto público con contenido marcado «pendiente de revisión»; sin tokens de desarrollo).
- **APK Android:** `FERROLAB-0.2.0.apk` (solo HTTPS, servidor público preconfigurado, firma de pruebas).

## 1. Qué funciona (probado en este entorno)

| Área | Estado | Cómo se comprobó |
|---|---|---|
| Motor científico (FSE) | Validador de dominio, límite físico, reglas por material/tratamiento (revenido, 8620, A48, recocido, austempering/martempering), historial físico tipado, ciclo esquemático, búsqueda de evidencia experimental exacta, modelos KM/JMAK/Andrews/E140 **desactivados** hasta tener coeficientes verificados, determinismo y trazabilidad. | 47 pruebas científicas (`tests/scientific`) |
| Base de datos | 26 tablas, CHECK/FK/únicos, RLS de denegación por defecto, auditoría solo-inserción, releases inmutables, publicar y revertir. | 19 pruebas con PostgreSQL 16 real (`tests/integration`) |
| API FastAPI | Endpoints públicos y admin de doc 06, errores homogéneos con `request_id`, límites de tasa y tamaño, CORS explícito, cabeceras de seguridad, OpenAPI exportado. | Pruebas de API, seguridad, admin y tutor (`tests/api`, `tests/security`) |
| Tutor | Modo editorial sin IA; modo IA opcional con validación de citas/cifras y presupuesto. | AI-01…AI-10 con proveedor simulado (no se llamó a ninguna API de pago) |
| App Flutter Web | Bienvenida, inicio, asistente (material → tratamiento → parámetros → revisión), horno animado, gráfica, resultados con estados de evidencia, microscopio, aprender/glosario/diagramas conceptuales, práctica, historial local, comparación, «¿Qué pasaría si…?», modo docente, logros, ajustes ES/EN y claro/oscuro, movimiento reducido, panel admin. | `flutter analyze` sin problemas, 11 pruebas Flutter, `flutter build web` OK |
| Recorrido completo | Estudiante sin cuenta en escritorio (1280 px) y móvil (390 px); panel admin con token de desarrollo. | E2E en Chromium: 32/32 y 4/4 (`tests/e2e`) |

Totales de la última ejecución: **Python 145/145**, **Flutter 11/11**, **E2E 36/36**.

## 2. Qué NO está hecho o no está verificado

- **Ninguna cifra metalúrgica se muestra** porque no hay evidencia revisada: todas las combinaciones devuelven `insufficient_evidence` (o `invalid_input` a ≥ 1538 °C). Es el comportamiento correcto según el Bluebook.
- **Android, iOS, Windows, macOS y Linux: no compilados.** El entorno no tiene Android SDK, Xcode ni toolchain de Linux. El código es multiplataforma, pero no se promete hasta compilar y probar (NFR-10).
- **Supabase real: no probado.** No hay cuenta ni credenciales; todo se probó con PostgreSQL local. El login por correo/contraseña del panel está implementado pero sin probar contra Supabase.
- **Despliegue público: no hecho.** Requiere elegir un alojamiento para FastAPI (Supabase no aloja servidores Python).
- **Subida de imágenes al Storage**: el panel gestiona metadatos y licencia de micrografías; la subida del archivo se hace hoy desde el panel de Supabase.
- **Revenido encadenado** a un temple previo de la app, **editor de diagramas** con puntos digitalizados y **auditoría de accesibilidad con lector de pantalla real**: pendientes.
- **Límite de 1538 °C (D-07)**: está en borrador; una persona debe verificar la fuente y el localizador.

## 3. Bloqueos que requieren al propietario

1. **Revisión científica**: una persona con formación metalúrgica debe revisar textos, condiciones iniciales y protocolos en el panel, y registrar evidencia con fuente + localizador (página/tabla/figura).
2. **Fuentes con acceso legal**: para activar cifras se necesitan datos de libros/artículos a los que el proyecto tenga acceso.
3. **Licencias de micrografías**: confirmar licencia por archivo antes de publicar imágenes.
4. **Cuenta Supabase gratuita** (opcional, para producción) y un alojamiento para la API.
5. **Presupuesto de IA** (opcional): sin él el tutor sigue en modo editorial.

## 4. Próximo paso recomendado

Verificar el límite físico (D-07) y revisar el catálogo editorial en el panel para publicar la primera versión oficial `1.0.0` (sin cifras), y después elegir **un** caso (p. ej. AISI 1045 + temple) para buscar su primera evidencia experimental verificable.
