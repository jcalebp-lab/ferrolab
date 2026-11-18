# 12 — Bibliografía, fuentes, imágenes y derechos

**Versión:** 2.0 · **Estado:** mapa de fuentes y proceso de curaduría, no biblioteca digital adquirida.  
**Regla central:** **citar una obra no demuestra acceso a su contenido ni licencia para redistribuirlo**. Una fuente solo respalda un cálculo si existe un localizador específico (página, tabla, figura, ecuación o dataset), el dato se ha verificado y la utilización es lícita.

## 1. Jerarquía de evidencia

1. **Ensayo experimental comparable**: material/condición/protocolo documentados, unidades y medidas claras, límites y procedencia.
2. **Curva o correlación revisada por pares**: intervalo de validez y coeficientes confirmados, comparación con datos.
3. **Norma técnica aplicable**: alcance correcto; muchas normas son de **ensayo**, no predicción.
4. **Manual/libro metalúrgico**: descripción de fenómenos, condiciones generales y referencias secundarias, pero no valor exacto sin localizador.
5. **Ilustración conceptual**: útil pedagógicamente y marcada como tal; jamás clasificar como observación ni predicción.

Priorizar referencias primarias y datos abiertos que se correspondan con **AISI 1045**, **AISI 8620** o **ASTM A48 Clase 30**. Las micrografías UHCS (ultra-high carbon steel) no equivalen a esos materiales.

## 2. Libros y manuales de referencia del proyecto

| ID | Obra | Uso previsto | Precaución |
|---|---|---|---|
| B-01 | ASM Handbook, Vol. 4A, *Steel Heat Treating Fundamentals and Processes* | Fundamentos y procesos de aceros. | Publicación comercial; adquirir/acceder legalmente. |
| B-02 | ASM Handbook, Vol. 4D, *Heat Treating of Irons and Steels* | Prácticas y tratamientos específicos. | Verificar contenido/edición por tema. |
| B-03 | ASM Handbook, Vol. 9, *Metallography and Microstructures* | Micrografía, preparación y constituyentes. | No copiar imágenes sin derechos. |
| B-04 | ASM Handbook, Vol. 1, *Properties and Selection: Irons, Steels, and High-Performance Alloys* | Fichas y propiedades. | Condición y especificación importan. |
| B-05 | ASM Handbook, Vol. 15, *Casting* | Fundición gris, solidificación y microestructura. | No extrapolar de un proceso de fundición a otro. |
| B-06 | Vander Voort y colaboradores, atlas de curvas TTT/CCT | Familias de diagramas de transformación. | Confirmar título/edición, curva exacta, permiso de digitalización. |
| B-07 | Totten (ed.), *Steel Heat Treatment: Metallurgy and Technologies* | Procesos y severidad de enfriamiento. | Fuente general ≠ protocolo universal. |
| B-08 | Krauss, *Steels: Processing, Structure, and Performance* | Acero, martensita, revenido. | Verificar edición y localizador. |
| B-09 | Bhadeshia & Honeycombe, *Steels: Microstructure and Properties* | Cinética/microconstituyentes. | Verificar modelo aplicable. |
| B-10 | Callister & Rethwisch, *Materials Science and Engineering: An Introduction* | Fundamentos introductorios. | No producir predicciones nuevas del libro. |
| B-11 | Askeland & Wright, *The Science and Engineering of Materials* | Base didáctica. | Verificar título/edición exactos. |
| B-12 | Avner, *Introduction to Physical Metallurgy* | Teoría de transformaciones. | Referencia histórica; no sustituye datos de material. |
| B-13 | Angus, *Cast Iron: Physical and Engineering Properties* | Fundición y matriz/grafito. | Confirmar relevancia para la clase seleccionada. |

Los títulos de la lista son **fuentes candidatas, no contenido procesado**. El admin debe introducir ediciones y localizadores precisos al registrar evidencia. No incluir tablas ni gráficos protegidos en el repositorio por defecto.

## 3. Normas ASTM: alcance preciso

| Norma | Tema | Uso correcto | Uso prohibido |
|---|---|---|---|
| **ASTM A48/A48M** | Fundición gris y requisitos de resistencia | Identificar la clase y su alcance. | Convertir clase 30 en composición química o micrografía única. |
| **ASTM A255** | Determinación de templabilidad en acero por ensayo de extremos templados (*Jominy*). | Entender pruebas de templabilidad; introducir dato si hay ensayo aplicable. | Predecir dureza de cualquier geometría solo con el número de norma. |
| **ASTM E112** | Determinación del tamaño medio de grano. | Medir imagen/probeta apropiada y calibrada. | «Calcular» número ASTM a partir de temperatura sin modelo. |
| **ASTM E562** | Fracción volumétrica por conteo de puntos sistemático. | Evaluar micrografías representativas y procedimiento. | Afirmar 95 % martensita sin medición/datos. |
| **ASTM E140** | Tablas aproximadas de conversión de durezas. | Convertir dentro del dominio explícito de material/escala/rango. | Generar una dureza desde cero o asumir equivalencia exacta. |

Páginas oficiales para verificar **edición vigente y alcance**: [A48](https://store.astm.org/standards/a48), [A255](https://store.astm.org/standards/a255), [E112](https://store.astm.org/standards/e112), [E562](https://store.astm.org/standards/e562), [E140](https://store.astm.org/standards/e140). Los documentos completos pueden requerir compra o licencia de biblioteca.

## 4. Publicaciones científicas y fórmulas

- **Koistinen, D. P. & Marburger, R. E. (1959).** «A general equation prescribing the extent of the austenite-martensite transformation in pure iron-carbon alloys and plain carbon steels». *Acta Metallurgica*, 7(1), 59–60. DOI: [10.1016/0001-6160(59)90170-1](https://doi.org/10.1016/0001-6160(59)90170-1). **Aplicación:** relación empírica en dominio específico; no extrapolar a fundición ni asumir coeficiente universal.
- **Andrews, K. W. (1965).** «Empirical formulae for the calculation of some transformation temperatures». *Journal of the Iron and Steel Institute*, 203, 721–727. **Aplicación:** posibles estimaciones de temperaturas críticas/Ms bajo composición y rangos pertinentes; confirmar fórmula y edición antes de codificar.
- **Literatura sobre JMAK/Avrami y bainita:** seleccionar trabajos con parámetros explícitamente calibrados para la aleación y la transformación en cuestión; no activar modelos solo porque existe una ecuación famosa.

**Diferencia crítica:** Fe–C es diagrama de equilibrio (idealizado para sistemas específicos). TTT describe rutas isotérmicas y CCT enfriamiento continuo. Ninguno se reemplaza por un gráfico «parecido» generado visualmente.

## 5. Registro de datos abiertos y licencias — evaluación preliminar

> **Estado al 18-11-2026:** varios repositorios están localizados, pero la aceptación para FERROLAB es **por archivo y espécimen**, no una aprobación genérica del proyecto. Un dataset puede ser legalmente reutilizable y aun así **científicamente no representativo** del material elegido.

| Dataset | Enlace verificable | Indicio legal encontrado | Estado para FERROLAB |
|---|---|---|---|
| **UHCSDB / NIST Ultrahigh Carbon Steel Micrographs** | https://hdl.handle.net/11256/940 y https://github.com/bdecost/uhcsdb | Ficha original/mirrors informan licencia Attribution 3.0 US; verificar el archivo y su procedencia. | **Candidato educativo**, no evidencia directa para 1045/8620/A48. |
| **RODARE carbide SEM — record 4124** | https://rodare.hzdr.de/record/4124 | Registro declara **CC BY 4.0**; imágenes de aceros de recipiente a presión JFL y ANP-10. | **Candidato**, pero no usar como muestra de nuestros tres materiales. |
| **NIST UHCS Microconstituent Annotations** | Buscar registro y términos originales asociados a micrografías UHCS | Referencia previa a CC BY-SA 3.0 **pendiente de comprobación por recurso**. | **Hold** hasta localizar licencia concreta de imágenes y máscaras. |
| **Aachen-Heerlen Annotated Steel Microstructure Dataset** | https://doi.org/10.6084/m9.figshare.c.5185004 y https://www.nature.com/articles/s41597-021-00926-7 | Artículo con licencia Creative Commons; **confirmar licencia del dataset/archivo original y terceros**. | **Hold** para incorporación; útil como literatura sobre islas MA en acero bainítico. |
| **OD-MetalDAM / MetalDAM** | https://github.com/ari-dasci/OD-MetalDAM | Documentación pública de repositorios/espejos menciona MIT y en otros lugares **CC BY-NC-ND**; puede diferir entre código e imágenes. | **Hold** hasta resolver condiciones del archivo y derivadas. |

### 5.1 De la licencia a un activo publicado

Para cada imagen registrar:

```json
{
  "asset_id": "id-interno",
  "original_url": "https://example.org/original-record",
  "source_id": "fuente-revisada",
  "author_or_copyright_holder": "verificado",
  "license_id": "verificado-por-archivo",
  "license_url": "enlace-a-terminos",
  "license_verified_at": "fecha",
  "material_grade": "designacion-real-de-la-probeta",
  "composition": null,
  "thermal_treatment": "si-se-conoce",
  "initial_condition": "si-se-conoce",
  "imaging_method": "optical-or-SEM",
  "magnification_x": null,
  "scale_bar_um": null,
  "pixel_size_um": null,
  "preparation": "ataque/pulido-si-se-conoce",
  "match_to_simulation": "exact/comparable/illustrative/none",
  "review_status": "draft"
}
```

Valores en forma de texto ilustrativo y `null` no constituyen metadatos reales. Revisor confirma pertinencia del metal, tratamiento, técnica, escala y derecho de modificación/redistribución. **CC BY-ND / CC BY-NC-ND** requiere especial cautela ante recortes, alteraciones y usos; si el producto o caso no cumple condiciones, no incorporar el archivo. Licencias *share-alike* pueden imponer obligaciones sobre derivados; revisar antes de transformar.

### 5.2 Precisión de imágenes y medición

Zoom digital modifica visualización, no resolución física. Una anotación de perlita/martensita sobre SEM no verificado **no** puede convertirse en «segmentación validada». Para tamaño de grano ASTM E112 se exige preparación, interceptos/cuenta y calibración; para fracciones E562 se exige campo representativo y procedimiento. Una imagen **ilustrativa** no puede sustentar medidas FSE.

## 6. Protocolo de extracción responsable

1. Identificar tipo de fenómeno/propiedad que se quiere enseñar.
2. Buscar fuente primaria y comprobar acceso lícito.
3. Registrar designación, composición real, tratamiento previo, geometría/condiciones, ensayo, condiciones de medida.
4. Extraer solo datos autorizados y suficientes, con unidad, error, método y localizador.
5. Comprobar si el dominio coincide con material/protocolo FERROLAB; documentar diferencias.
6. Ejecutar validación doble: consistencia de datos y revisión metalúrgica por persona competente.
7. Publicar nueva versión de dataset; generar pruebas de regresión de esa versión.
8. Mostrar en la UI cita y limitación del caso.

**No descargar y «absorber» por IA todos los libros de referencia** si no hay permiso ni acceso. Una URL y un título no prueban contenido, vigencia o atribución.

## 7. Modelo de ficha de evidencia

```text
Evidence ID:
Tipo: measured | literature | modeled
Fuente y edición:
Localizador: página/figura/tabla/ecuación/DOI
Material y composición:
Condición inicial:
Tratamiento y trayectoria:
Medida / magnitud:
Valor y unidad:
Rango de validez:
Incertidumbre y cómo se obtuvo:
Condiciones y limitaciones:
Licencia y permiso de uso:
Archivo original y checksum:
Revisor, fecha y estado:
```

Un campo obligatorio vacío bloquea la publicación de **esa magnitud**. Las fuentes conceptuales pueden tener campos numéricos vacíos y respaldar contenido pedagógico sin activar cálculos.

## 8. Referencias de tecnología y seguridad

- Flutter (plataformas y guías): https://docs.flutter.dev/reference/supported-platforms
- FastAPI: https://fastapi.tiangolo.com/
- Supabase RLS y protección de claves: https://supabase.com/docs/guides/database/postgres/row-level-security
- Supabase Auth: https://supabase.com/docs/guides/auth
- Licencias Creative Commons: https://creativecommons.org/share-your-work/cclicenses/

Las versiones, licencias y planes de alojamiento cambian: verificar antes de desplegar. Esta bibliografía registra **candidatos y políticas**, no certifica retrospectivamente los datos que Claude Code encuentre.

## 9. Gate científico-legal

- [ ] El artículo/libro/norma fue consultado efectivamente y localizador verificado.
- [ ] La ecuación se transcribió sin error y con dominio.
- [ ] Material/estado/protocolo son comparables o diferencia revelada.
- [ ] Una micrografía tiene licencia, autor, condición, método y escala/calibración.
- [ ] La licencia permite el uso concreto previsto; atribución visible.
- [ ] El revisor aprobó publicación; test de regresión documentado.
- [ ] No se presentan imágenes, curvas ni durezas sintéticas como experimentos.
