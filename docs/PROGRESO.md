# Estado del proyecto FERROLAB

**Fecha:** 19-11-2026 · **Engine:** 0.4.0 (modelos `ferrolab_metallurgy@1.1.0`) · **App:** 0.5.0 · **Dataset:** `0.2.0-dev+unreviewed` · **Protocolos:** 41 (ver `docs/PROTOCOLOS.md`)

## 0. Publicado

- **App web pública:** https://ferrolab-ckzk.onrender.com (Render, plan gratuito; se duerme tras ~15 min sin visitas y tarda ~1 min en despertar).
- **Base de datos:** Supabase (us-east-1), usuario propio `ferrolab_app` sin privilegios de superusuario; 27 tablas con RLS de denegación por defecto. Se pausa tras una semana sin uso (plan gratuito).
- **Modo:** `staging` (piloto público con contenido marcado «pendiente de revisión»; sin tokens de desarrollo).
- **APK Android:** `dist/FERROLAB-0.5.0.apk` (solo HTTPS, servidor público preconfigurado, firma de pruebas; no se sube al repositorio).

## 1. Qué funciona (probado en este entorno)

| Área | Estado | Cómo se comprobó |
|---|---|---|
| Motor científico (FSE) | Validación de dominio, límite físico, reglas por material/tratamiento, trazabilidad y determinismo. **Estimaciones por modelos publicados** (D-26): ciclo térmico de una probeta de 12,7 mm, fases, microconstituyentes, dureza HV/HRC con banda de incertidumbre, **tamaño de grano ASTM** (Lee y Lee 2008, ASTM E112, Hodgson y Gibbs 1992), **límite de fluencia y resistencia a tracción** (Pavlina y Van Tyne 2008), diagramas TTT/CCT con la trayectoria del estudiante y dureza de revenido (Kang y Lee 2014, D-29). | Pruebas científicas + validación contra datos publicados (`docs/FUENTES_MODELOS.md`) |
| Biblioteca de protocolos | 18 combinaciones con protocolo de referencia y variantes (41), etapas con horno, baño e igualación propios, fuentes y lo que falta investigar; selección automática, «Usar protocolo recomendado», niveles A/B/C y avisos agrupados (D-30 a D-33). | Auditoría automática de las 18 combinaciones (`tests/scientific/test_protocol_audit.py`) y E2E |
| Base de datos | Tablas, CHECK/FK/únicos, RLS, auditoría solo-inserción, releases inmutables, publicar y revertir. | Pruebas con PostgreSQL 16 real |
| API FastAPI | Endpoints públicos y admin, errores homogéneos, límites de tasa y tamaño, CORS, cabeceras de seguridad, OpenAPI exportado. | Pruebas de API, seguridad, admin y tutor |
| App Flutter | Asistente, horno animado, resultados, **microscopio con microestructura generada, zoom ≈ 560×–3700×, barra de escala y medición de grano por intercepto** (D-28, D-35), **diagramas TTT/CCT interactivos**, aprender, práctica, historial, comparación, modo docente, ES/EN, claro/oscuro, panel admin. Web y Android. | `flutter analyze` sin problemas, pruebas Flutter, `flutter build web` y `flutter build apk` OK |
| Recorrido completo | Estudiante en escritorio y móvil, local y contra la URL pública; panel admin con token de desarrollo. | E2E en Chromium: 40/40 y 4/4 |

Totales de la última ejecución: **Python 216/216**, **Flutter 14/14**, **E2E 40/40 + 4/4**.

## 2. Limitaciones conocidas

- Las cifras son **estimaciones de modelo no revisadas por un especialista**. El 8620 templado en aceite y el 1045 templado salen por debajo de los valores publicados (ver tabla de validación).
- **Fundición gris A48**: sin modelo cinético; protocolos documentados (nivel B) e ilustración cualitativa; la norma no fija composición.
- **Revenido**: parte de la muestra templada de referencia, de una del historial o solo teoría; fuera de 145–716 °C no se estima.
- **Variantes no verificadas** (MatWeb, ASM, J. Mater. Res. Technol. 2022, Bodycote): se muestran como demostración (nivel C) hasta que alguien consulte el texto original.
- **Micrografías reales**: 25 de Wikimedia Commons con licencia libre (D-34), citadas en «Fuentes»; las 18 combinaciones muestran ejemplos de sus constituyentes, pero solo una coincide en material y tratamiento (martensita en SAE 1045). Faltan micrografías propias de AISI 8620 y ASTM A48 clase 30, y hay pocas de bainita y martensita revenida.
- **Ecuaciones de grano y resistencia**: tomadas de reproducciones secundarias (los artículos originales no se pudieron abrir); deben verificarse con el texto original (D-35).
- **iOS**: requiere cuenta de Apple Developer y una Mac; mientras tanto, uso desde el navegador.
- **Límite de 1538 °C (D-07)**: en borrador; una persona debe verificar la fuente y el localizador.

## 3. Lo que requiere al propietario

1. **Revisión científica** de rangos, textos y de la tabla de validación (panel admin).
2. **Micrografías con licencia** (propias del laboratorio o de repositorios abiertos).
3. **Cuenta Apple Developer** (opcional) para publicar en iPhone.
4. **Presupuesto de IA** (opcional): sin él el tutor sigue en modo editorial.
