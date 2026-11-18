# 01 — Visión del proyecto FERROLAB

**Edición:** Bluebook 2.0 · **Tipo:** definición estratégica · **Relación:** `README.md`, `02_PRD.md`.

## 1. Identidad

**FERROLAB — Virtual Heat Treatment Laboratory.** Un laboratorio educativo de metalurgia donde el estudiante experimenta visualmente con ciclos térmicos sin depender de un horno físico, pero entiende cuándo la evidencia permite concluir y cuándo no. La promesa no es «predecir exactamente cualquier acero», sino **hacer visible el razonamiento metalúrgico sin traicionar la ciencia**.

**Misión:** democratizar el aprendizaje de tratamientos térmicos mediante simulaciones reproducibles, gráficos interpretables, micrografías lícitas y explicaciones accesibles. **Visión:** una herramienta de referencia para ejercicios introductorios y revisión de fundamentos, útil en clase y de manera autónoma. **Tono:** claro, moderno, curioso, respetuoso y sin falsa certeza.

## 2. Personas y necesidades

| Persona | Necesidad concreta | Criterio de diseño |
|---|---|---|
| Estudiante de ingeniería (16–25) | Comprender por qué cambia la microestructura con el tratamiento. | Selección guiada, simulación visual y «¿por qué ocurrió?» con fuente. |
| Estudiante sin base metalúrgica | Entender ferrita, perlita, martensita, bainita, grafito. | Definiciones progresivas, glosario y no exigir conocimientos previos. |
| Docente | Mostrar un proceso y plantear comparaciones o tareas. | Modo presentación, referencias y códigos de actividad **sin** cuentas de estudiantes. |
| Usuario con conexión lenta | No consumir datos ni esperar innecesariamente. | Imágenes adaptativas, caché segura de contenido público, carga progresiva. |
| Administrador/editor científico | Publicar evidencia fiable sin tocar código. | Panel web privado, flujo de revisión y trazabilidad por registro. |

## 3. Resultado pedagógico esperado

Después de una sesión breve el estudiante debe poder: (1) explicar la diferencia entre calentamiento, austenitización, mantenimiento y enfriamiento; (2) distinguir TTT de CCT; (3) comparar temple vs. revenido y austempering vs. martempering; (4) reconocer que la geometría, el historial previo y la composición importan; (5) interpretar una micrografía sin confundir escala real con zoom digital; (6) justificar una conclusión con una fuente y una limitación.

**Lo que FERROLAB no promete:** certificación metalográfica, diseño de procesos industriales, selección de parámetros para piezas reales, sustitución de ensayos, cálculo universal de dureza ni acceso automático a libros comerciales.

## 4. Experiencia ideal

1. Abre FERROLAB en español, sin registrarse; puede cambiar a inglés en ajustes.
2. Escoge `AISI 1045` y lee la condición inicial documentada.
3. Selecciona un tratamiento y observa un estado de compatibilidad razonado.
4. Ajusta temperatura con slider y entrada precisa (rango visual del horno hasta 1600 °C) y duración de mantenimiento.
5. Ve el **protocolo automático** de calentamiento/enfriamiento y su medio fijo; no puede editarlo.
6. Inicia la animación del horno de estética sobria inspirada en uno de laboratorio, con pieza que evoluciona de gris a rojo/naranja/amarillo/blanco **solo como indicación visual**, no termómetro óptico exacto.
7. Sigue historial de temperatura y, cuando existan datos apropiados, TTT/CCT y Fe–C con origen explícito.
8. Obtiene resultados por propiedad: `validado`, `estimación acotada`, `cualitativo`, `evidencia insuficiente` o `no soportado`.
9. Inspecciona una micrografía con autor, condición experimental, escala y permiso de uso. Si no hay coincidencia, lee por qué.
10. Compara y guarda en su dispositivo; accede a explicación preescrita o tutor opcional.

## 5. Principios de producto

### 5.1 Honestidad científica

Cada material tiene variabilidad. `ASTM A48 Clase 30` clasifica fundición gris por prestación mecánica, **no proporciona por sí misma composición ni matriz única**. `AISI 8620` puede requerir cementación para las propiedades clásicas de capa, que no debe presumirse. Un supuesto de «sin geometría» no convierte un perfil de enfriamiento en universal. El producto admite explícitamente estados «no disponible».

### 5.2 Herramienta gratuita y sin fricción

La experiencia del estudiante no necesita login, no contiene publicidad y no incluye suscripción. Su historial y favoritos se guardan localmente; borrar datos o cambiar de dispositivo puede perderlos. El panel editorial se protege con autenticación independiente. Presupuesto deseado de operación: **cero**; la ingeniería debe minimizar coste y proporcionar degradación sin IA, pero no afirmar viabilidad gratuita indefinida para ~500 usuarios.

### 5.3 Diseño propio, comprensible y accesible

Inspiración en claridad de productos Apple, no clonación. Sistema visual sobre cuatro familias cromáticas solicitadas: **Sulphur Yellow**, **Peach Red**, **Yellow Green**, **Light Green**, con valores candidatos documentados en `08_Design_System.md`. Tipografía de sistema, jerarquía clara, compatibilidad con lector de pantalla, movimiento reducido y modo claro/oscuro.

### 5.4 Gradualidad y escalabilidad

El **MVP primero en web** permite validar ciencias/UX antes de empaquetar iOS/Android/desktop. La misma base Flutter se conserva. Priorizar amplitud educativa honesta antes que «18 combinaciones calculadas» sin datos.

## 6. Alcance inicial y no-alcance

**Incluido en el proyecto:** 3 materiales, 6 tratamientos en catálogo, temperatura/tiempo, compatibilidad, ciclos térmicos, horno animado, resultados cualitativos y cuantitativos **cuando se validen**, biblioteca visual licenciada, comparador, glosario, modo práctica, tutor opcional, historia local, panel admin web y versiones de datos.

**Excluido en versión inicial:** simulación por elementos finitos; geometría 3D térmica; tensiones residuales reales; deformación; cementación como séptimo proceso; predicción exacta por tamaño de sección; fase de validación industrial; entrada arbitraria de aleaciones; calificación oficial de estudiantes; cuentas estudiantiles; IA generativa con cuotas ilimitadas.

## 7. Indicadores de éxito (medir solo si existe consentimiento y sin invadir privacidad)

| Indicador | Método | Umbral de aceptación inicial |
|---|---|---|
| Recorrido completo | Prueba manual + test E2E | Se ejecuta de inicio a resultados en web. |
| Alfabetización de límites | Prueba con 5 estudiantes | Pueden distinguir simulación vs. dato experimental. |
| Errores científicos graves | Revisión experta de casos publicados | **Cero** valores sin procedencia. |
| Autenticación admin | Pruebas de acceso | **Cero** endpoints de escritura pública. |
| Accesibilidad crítica | Auditoría manual + automatizada | Sin bloqueantes en flujo esencial. |
| Costo | Observabilidad de cuotas | Se conoce el coste y el plan de apagado del tutor. |

No inventar cifras de retención, conversión o precisión antes de pruebas reales.

## 8. Riesgos y respuesta

1. **Datos insuficientes** → habilitar explicación cualitativa y catalogar brechas, no fabricar números.
2. **Licencias de micrografías inciertas** → bloquear publicación del activo; utilizar texto/esquemas originales etiquetados.
3. **Costo cloud/IA** → caché, límites y tutor opcional deshabilitado por defecto si no existe presupuesto.
4. **Plazo corto** → recortar alcance P1/P2, nunca validación científica ni seguridad.
5. **Confusión docente** → mostrar banner «Herramienta educativa, no tratamiento industrial» en resultados.
6. **Multiplataforma** → verificar y publicar primero web; builds nativos posteriores.

## 9. Decisiones humanas que se deben solicitar en el futuro

Para publicar predicciones cuantitativas: aprobación de bibliografía y datos por persona con formación metalúrgica; condiciones iniciales y protocolos validados; validación de licencias; límites del hosting gratuito y permisos de despliegue. Claude Code puede construir la infraestructura sin esas decisiones, pero **no aprobarlas en nombre del usuario**.

## 10. Definición de visión cumplida

FERROLAB cumple su propósito cuando ayuda a entender **por qué** cambia un material y **qué sabemos realmente sobre ese cambio**. Si una respuesta es «No hay evidencia suficiente para estimar dureza», acompañada de un ciclo térmico correcto, concepto, fuentes y explicación de la limitación, es una respuesta educativa valiosa.
