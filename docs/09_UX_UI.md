# 09 — UX/UI: experiencia pedagógica FERROLAB

**Versión:** 2.0 · **Estado:** especificación de experiencia · **Vinculado:** `02_PRD.md`, `08_Design_System.md`, `10_Wireframes_y_Flujos.md`.

## 1. Principio rector

Un estudiante debe poder completar la experiencia sin explicar qué es un backend ni conocer el ciclo térmico de memoria; al terminar, **sí** debe identificar qué se sabe, qué se estima y qué no está cubierto. La interfaz no enseña «arrastrar un slider para obtener 58 HRC»; enseña relaciones metalúrgicas y sus limitaciones.

**Tono en español:** cercano, claro y técnico cuando corresponde. En la UI no usar jerga regional que dificulte la traducción o un aula internacional. **Inglés:** equivalencia conceptual, no traducciones literales engañosas. `Temple` en español debe aparecer como `Quenching`, `Revenido` como `Tempering`, `Recocido` como `Annealing`, `Normalizado` como `Normalizing`, `Austempering` y `Martempering` explicados con términos precisos.

## 2. Arquitectura de información

Navegación principal ideal: **Inicio**, **Laboratorio**, **Aprender**, **Mi progreso**. La pestaña de progreso puede omitirse en P0 si historial/práctica aún no existen. Dentro del laboratorio: seleccionar → configurar → revisar → simular → analizar. Desde un resultado: microscopio, fundamento científico, comparación, pregunta al tutor y volver a parámetros. Ajustes accesibles desde perfil **sin fingir que hay cuenta**; usar icono de configuración, no avatar de usuario.

### Home

- Hero «Comprende lo que el calor cambia en los metales».
- Acción primaria «Iniciar una simulación».
- Acciones secundarias: «Explorar microestructuras» (P1) y «Aprender tratamientos».
- Última sesión **solo si historial local activado**.
- Banner breve: «Herramienta educativa. Las propiedades dependen de datos y condiciones reales».

### Material

Lista de AISI 1045, AISI 8620, ASTM A48 Clase 30. Fichas muestran **estado conocido** y variabilidad. No describir A48 como si fuera un acero. Al seleccionar 8620, una nota aclara que los resultados de capa cementada requieren un estado inicial realmente cementado. Al seleccionar A48, explica que la clase de resistencia no fija una composición única.

### Tratamiento

Seis tarjetas con explicación introductoria y estado contextual: `compatible con protocolo`, `condicional`, `solo aprendizaje` o `no soportado`. Una combinación no disponible no desaparece: conserva opción «Conoce por qué». La app no afirma que los 18 pares tienen resultados calculados.

### Parámetros

Diseño en dos bloques: **lo que tú controlas** (temperatura y duración de la etapa identificada) y **lo que define el protocolo** (medio/perfil, etapas extra, condición inicial). Un candado no implica regla científica universal: tooltip explica que se fija por simplicidad pedagógica y evidencia revisada. Los valores fuera de rango se informan antes de iniciar.

### Revisión

Tarjeta «Tu experimento» con material/estado inicial/tratamiento/°C/minutos/protocolo/advertencias y botón de confirmar. Indicar cuándo un diagrama o dureza **no** estará disponible, evitando decepciones postanimación.

### Horno

Visual central inspirado en un horno de laboratorio sencillo, no copia de producto registrado. Termómetro, línea de tiempo, etapa activa, duración física vs velocidad de reproducción. Controles reproducir/pausa/saltar animación. El color del metal es *ilustrativo*. A un costado o debajo: gráfica temperatura-tiempo ligada al FSE.

### Resultado

Encabezado «Esto podemos concluir» con secciones:

1. **Resumen del tratamiento** (descriptivo y fuente).
2. **Historial térmico** con ejes y etapas.
3. **Transformación y fases** (distinguir fases cristalográficas/microconstituyentes).
4. **Propiedades** con estados por propiedad.
5. **Microscopio** con licencia y pertinencia.
6. **Fundamento** (supuestos, datos, incertidumbre y referencias).
7. **Seguir aprendiendo** con comparación, glosario o práctica.

No forzar un porcentaje visual tipo pie chart cuando hay fases no observadas o categorías superpuestas. No usar el color verde «muy alta confianza» como resultado automático.

## 3. Manejo de los vacíos como oportunidad pedagógica

| Situación real | UI indicada | Acción siguiente |
|---|---|---|
| Protocolo no revisado | «Esta combinación se puede estudiar, pero no calcular con rigor todavía». | Ver fundamento. |
| `target_temperature_c` fuera de dominio | «Esta temperatura queda fuera del intervalo documentado para este tratamiento». | Corregir temperatura. |
| Dureza ausente | «No es posible estimar la dureza con los datos disponibles». | Ver qué datos faltan. |
| CCT faltante | «Aún no hay una curva CCT validada para esta condición». | Ver conceptos CCT/TTT sin líneas ficticias. |
| Micrografía no comparable | «No encontramos una micrografía verificada de esta condición». | Explorar ejemplos didácticos **claramente no equivalentes**. |
| IA indisponible | «El tutor no está disponible; aquí tienes una explicación revisada». | Leer explicación editorial. |
| Red desconectada | «Sin conexión al motor. Tu configuración sigue aquí». | Reintentar; no calcular offline. |
| Error interno | «No pudimos completar esta solicitud». | Reintentar; mostrar código de soporte. |

## 4. Microcopy ES/EN listo para localización

| Clave | Español | English |
|---|---|---|
| `home.start` | Iniciar simulación | Start simulation |
| `material.title` | Elige un material | Choose a material |
| `treatment.title` | Elige un tratamiento | Choose a heat treatment |
| `params.thermalLimit` | Rango válido del protocolo | Valid protocol range |
| `protocol.locked` | Enfriamiento definido por protocolo | Cooling set by protocol |
| `run.review` | Revisar experimento | Review experiment |
| `furnace.visualDisclaimer` | El color de la pieza es ilustrativo | Workpiece color is illustrative |
| `results.title` | Esto podemos concluir | What the evidence supports |
| `results.unavailable` | No estimable con la evidencia actual | Not estimable from current evidence |
| `results.viewSource` | Ver fuente y límites | View source and limitations |
| `microscope.digitalZoom` | Zoom digital, no aumento óptico | Digital zoom, not optical magnification |
| `tutor.explain` | ¿Por qué ocurrió esto? | Why did this happen? |
| `network.retry` | Reintentar | Retry |
| `history.delete` | Eliminar historial local | Delete local history |

## 5. Errores pedagógicos a evitar

**Error 1:** comunicar «850 °C crea 85 % martensita» sin composición y modelo. **Corrección:** declarar el caso en evidencia insuficiente. **Error 2:** usar curva TTT para representar una trayectoria de enfriamiento continuo sin modelo válido. **Corrección:** ocultar curva o mostrar diagrama genérico con etiqueta inequívoca. **Error 3:** confundir 1000× digital con micrografía de 1000×. **Corrección:** separar «zoom» y «magnificación experimental». **Error 4:** usar referencia de aceros ultralto carbono para una micrografía supuestamente de AISI 1045. **Corrección:** exigir coincidencia, o rotular como muestra de otro material.

## 6. Tutor y preguntas de descubrimiento

Propuesta de preguntas fijas con respuesta editorial fundamentada: «¿Qué diferencia hay entre TTT y CCT?», «¿Por qué la velocidad de enfriamiento importa?», «¿Cuál es la diferencia entre martempering y austempering?», «¿La fundición gris se comporta como el acero?», «¿Por qué no aparece un valor de dureza?». Cuando el tutor IA esté encendido, incluir siempre un enlace a los fundamentos y no permitir que sustituya campos FSE.

## 7. Inclusión y accesibilidad

- Evitar depender de gestos únicos: todo pinch/zoom debe tener botones de zoom y teclado.
- Textos alternativos de microscopía describen lo visible y la incertidumbre, no «martensita al 95 %» sin anotación.
- Diagramas con tablas alternativas para valores; leyendas claras en formas, patrones o texto, no solo color.
- Videos/animaciones con pausar, saltar y reducir movimiento; sonido voluntario.
- Explicaciones en capas: una frase simple, detalles expandibles y fuente final.
- No solicitar datos personales de menores; códigos docentes no registran nombres ni notas oficiales.

## 8. Modo práctica y profesor (P1/P2)

**Práctica:** preguntas tipo opción múltiple y casos «¿Qué falta para poder calcular?», con retroalimentación sustentada. Guardar avance local y borrable. No generar respuestas correctas dinámicas sin revisión. **Profesor:** crear actividad con identificador corto, fecha de vigencia y conjunto fijo de casos; acceso mediante código, sin identidad del estudiante; resultados agregados solo si se implementa un mecanismo de privacidad aceptable y consentimiento. No afirmar que un código constituye autenticación fuerte.

## 9. Medición de experiencia

Probar con usuarios reales: ¿encuentran «Iniciar»? ¿entienden el candado del enfriamiento? ¿interpretan diferencia entre dato medido y estimación? ¿distinguen error de red de insuficiencia científica? Recolectar feedback voluntario y sin identificadores obligatorios. **La métrica crítica es comprensión, no número de clics ni cantidad de cifras mostradas.**

## 10. Criterios de aceptación UX

- [ ] Se completa simulación en web sin login.
- [ ] Se entienden claramente rangos del horno vs rangos científicos.
- [ ] Toda ausencia de dato tiene explicación útil.
- [ ] Se puede consultar fuente y limitación desde cada dato.
- [ ] Las etiquetas Fe–C/TTT/CCT y micrografía no inducen equivalencias erróneas.
- [ ] El flujo funciona con teclado, texto ampliado y movimiento reducido.
- [ ] Un tutor apagado o un recurso visual ausente no rompe el producto.
