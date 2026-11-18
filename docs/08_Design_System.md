# 08 — Design System FERROLAB

**Versión:** 2.0 · **Estado:** sistema visual propuesto, implementable y accesible.  
**Responsable de adopción:** Flutter. **Relación:** `07_Frontend_Flutter.md`, `09_UX_UI.md`, `10_Wireframes_y_Flujos.md`.

## 1. Dirección de arte

FERROLAB debe sentirse **claro, científico, humano y contemporáneo**, con una estética minimalista inspirada en la legibilidad de aplicaciones de bienestar/educación de alta calidad. **No** copiar pantallas, iconos o animaciones de Apple Health. El metal y el horno aportan dramatismo visual; la interfaz circundante debe reducir ruido, no parecer un videojuego industrial.

**Concepto:** «laboratorio luminoso»: superficies blancas suaves, bordes discretos, números grandes, trazos finos y toques controlados de amarillo sulfuro, rojo melocotón y verdes. La visualización científica jamás depende únicamente del color.

## 2. Paleta y tokens

El usuario eligió las **familias cromáticas** Sulphur Yellow, Peach Red, Yellow Green y Light Green, pero no se definieron HEX oficiales. Los siguientes son **valores de diseño propuestos para FERROLAB**, no equivalencias normativas con nombres comerciales o Pantone. Pueden ajustarse durante pruebas de marca/contraste sin cambiar las familias.

| Token | HEX propuesto | Función | Texto permitido sobre ese fondo |
|---|---|---|---|
| `brand.sulphurYellow` | `#E9E74A` | Acción primaria y destacados del horno. | `#17241D` (≈12.2:1). |
| `brand.peachRed` | `#FF725E` | Alertas educativas y calor visual. | `#17241D` (≈6.0:1). |
| `brand.yellowGreen` | `#A9C84B` | Completado/avance; no prueba de exactitud. | `#17241D` (≈8.5:1). |
| `brand.lightGreen` | `#BDECC1` | Fondos didácticos, tarjetas secundarias. | `#17241D` (≈12.2:1). |
| `ink.primary` | `#17241D` | Títulos/texto modo claro. | Fondo claro. |
| `ink.secondary` | `#54635B` | Metadatos en modo claro. | Sobre `#FAFBF7` ≈6.1:1. |
| `surface.base` | `#FAFBF7` | Fondo modo claro. | Texto oscuro. |
| `surface.card` | `#FFFFFF` | Tarjetas y formularios. | Texto oscuro. |
| `surface.dark` | `#141C19` | Fondo modo oscuro. | `#F5FAF7`. |
| `ink.onDark` | `#F5FAF7` | Texto modo oscuro. | Fondo oscuro. |

Los ratios anteriores son aproximaciones de contraste **de color sólido** y no sustituyen pruebas del widget completo. **No poner blanco sobre Peach Red**, pues su contraste es insuficiente para texto normal. En modo oscuro usar colores de acento con texto oscuro si el fondo es suficientemente claro; tokens adaptativos para bordes, dividers y superficies.

### 2.1 Colores semánticos (distintos de paleta de marca)

- `semantic.info`: descripción neutra + icono de información.
- `semantic.warning`: advertencia + texto «Rango no validado», no solo rojo.
- `semantic.error`: fallo de red/formulario; nunca confundir con falta de evidencia científica.
- `semantic.evidenceValidated`: estado verificado **con etiqueta y fuente**, nunca un badge verde absoluto.
- `semantic.evidenceLimited`: estimación, conclusión cualitativa o evidencia insuficiente con texto explícito.

Usar escalas semánticas revisadas por WCAG. **No** codificar «la martensita es siempre roja» o «la austenita es verde» como convención científica universal; leyendas y convenciones por diagrama.

## 3. Tipografía

En iOS/macOS usar fuente del **sistema** (San Francisco cuando el sistema la provea). En Android, web y Windows usar tipografía predeterminada de sistema con fallback legible; no añadir paquetes ni distribuir archivos SF Pro sin permiso conforme a sus condiciones. Preferir pesos regulares y semibold, sin texto ultrafino.

| Estilo | Tamaño móvil orientativo | Peso | Uso |
|---|---:|---:|---|
| `display` | 34–40 sp | 700 | Pantalla de bienvenida y resultado principal. |
| `headline` | 26–30 sp | 700 | Títulos de pantalla. |
| `title` | 20–22 sp | 600 | Tarjetas/paneles. |
| `body` | 16 sp | 400 | Explicaciones. |
| `label` | 14 sp | 600 | Botones, inputs, metadata. |
| `caption` | 12–13 sp | 400 | Fuente/licencia; elevar si falla accesibilidad. |
| `numeric` | 28 sp | 600 | °C, minutos, cifras con `tabularFigures`. |

No bloquear `textScaleFactor`; respetar aumento de fuente y evitar truncar mensajes de seguridad. Fórmulas y notación: soporte para subíndices, `°C`, `µm`, `HV`, `HRC`, `HBW`, símbolos `α`, `γ` con alternativas accesibles.

## 4. Espaciado, forma y grid

- Escala de espaciado: `4 / 8 / 12 / 16 / 24 / 32 / 48` px lógicos.
- Radio: `8` en chips, `14` en inputs, `20` en tarjetas, `28` en paneles grandes.
- Altura interactiva mínima: **48 px lógicos como objetivo** para controles principales; verificar requisitos de plataforma.
- Ancho de contenido máximo web: 1100–1200 px; lectura en columnas hasta ~70–80 caracteres por línea.
- Grid móvil: márgenes 16–20 px; 1 columna; tablet: 2 columnas cuando la jerarquía lo permita; web: barra lateral opcional y panel dividido.
- Elevación ligera, bordes discretos y separación por espacio en blanco; evitar sombras pesadas/vidrio translúcido que comprometa contraste.

## 5. Componentes normativos

### 5.1 Botones

- **Primario:** acción única destacada «Iniciar simulación», fondo Sulphur Yellow, texto Ink Primary, estado loading/deshabilitado/feedback. No permitir start si `invalid_input`.
- **Secundario:** relleno suave o contorno, «Ver fundamentos», «Comparar».
- **Terciario:** texto + icono, «¿Por qué ocurrió esto?», «Ver fuente».
- **Destructivo:** «Eliminar historial», requiere confirmación y accesibilidad.

### 5.2 Selector de material

Card con: designación técnica, familia «acero»/«fundición gris», breve descripción, chips de evidencia y acción «Ver ficha». Materiales con datos insuficientes siguen visibles en modo educativo; no ocultar incertidumbre.

### 5.3 Slider de temperatura

Mostrar `valor °C` y campo de entrada numérica; marcas mín./máx. del **protocolo** y marca `1600 °C` solo en contexto de la capacidad visual del horno. El usuario debe distinguir el límite instrumental del límite científico. `Tooltip`: «El rango válido depende del material y tratamiento».

### 5.4 Tarjeta de protocolo fijo

Pictograma simple de enfriamiento, descripción de etapas y medio. Icono de candado + texto: «Se selecciona automáticamente según protocolo revisado». No usar candado sin explicación de por qué no es configurable.

### 5.5 Tarjeta de resultado científico

```text
┌──────────────────────────────────────────────┐
│ DUREZA FINAL                         [ ? ]  │
│ —  No estimable con datos disponibles        │
│ La trayectoria térmica no tiene ...          │
│ Ver limitación  ·  Fuente / método           │
└──────────────────────────────────────────────┘
```

La ausencia de magnitud usa guion largo y texto; nunca color rojo puro de «error» por falta de datos. Si hay valor, incluir unidades, incertidumbre si está validada, naturaleza medida/modelada y enlace a fuente.

### 5.6 Gráficos, leyendas, microscopio

Gráfica térmica: eje horizontal tiempo físico, eje vertical °C; segmentación de etapas y cursor con valor textual. TTT usa tiempo logarítmico cuando lo exige el dataset y explica qué significa; CCT no es TTT. Fe–C se identifica como diagrama general de equilibrio y **no** predice por sí solo la dureza final de un tratamiento. Microscopio: barra de escala visible solo con calibración; deslizador de zoom digital etiquetado.

## 6. Animaciones y sonido

- Duración de microinteracción 150–250 ms orientativos, `reduceMotion` respeta configuración de accesibilidad.
- Horno animado acelerado: usar historial térmico del FSE, temperatura textual y leyenda «color ilustrativo».
- La secuencia cromática gris → rojo oscuro → rojo → naranja → amarillo → blanco es un **lenguaje visual**, no una conversión de temperatura óptica fiable.
- Sonidos apagados por defecto; permitir activar/desactivar. No usar sonidos que imiten alarmas de seguridad de un horno real de forma engañosa.

## 7. Iconografía, imagen y tono

Iconos lineales originales o librerías con licencias adecuadas: horno, termómetro, reloj, curva, libro, microscopio, información. Evitar emoji como iconografía principal en interfaz técnica. Ilustraciones: vectores originales con textura mínima. Fotografías y micrografías: solo si licencia/atribución y exactitud de espécimen se aprobaron. Títulos cortos; no jerga innecesaria; lenguaje científico riguroso.

## 8. Componentes Flutter y tokens de tema

```dart
// Propuesta de constantes iniciales; revisar con pruebas de accesibilidad.
const Color flSulphurYellow = Color(0xFFE9E74A);
const Color flPeachRed      = Color(0xFFFF725E);
const Color flYellowGreen   = Color(0xFFA9C84B);
const Color flLightGreen    = Color(0xFFBDECC1);
const Color flInk           = Color(0xFF17241D);
const Color flSurface       = Color(0xFFFAFBF7);
```

Implementar `ThemeData` para light/dark, `ColorScheme`, tipografía y extensiones `FerrolabTokens`. Nada de HEX duplicados en widgets; no depender de `platform == iOS` para toda la apariencia. `Semantics`, focus visibles, `MediaQuery.disableAnimations` y soporte de Dynamic Type.

## 9. Checklist de revisión visual

- [ ] Botones primarios reconocibles en claro/oscuro.
- [ ] Texto en fondos de marca cumple contraste; Peach Red **nunca con blanco normal**.
- [ ] Toda incertidumbre y advertencia tiene texto, no solo color.
- [ ] °C/minutos y ejes de gráficos permanecen legibles al escalar fuente.
- [ ] Zoom digital no se confunde con aumento óptico del microscopio.
- [ ] Layout sin scroll horizontal involuntario a 320–360 px lógicos.
- [ ] No se distribuyeron fuentes ni ilustraciones propietarias sin permiso.
- [ ] El flujo funciona con lector de pantalla y `reduceMotion`.

## 10. Definición de terminado

Diseño consistente y documentado en Flutter; todos los componentes tienen estados enabled/disabled/loading/error/empty y pruebas visuales/semánticas; los colores y animaciones ayudan a aprender pero nunca alteran ni reemplazan la evidencia científica.
