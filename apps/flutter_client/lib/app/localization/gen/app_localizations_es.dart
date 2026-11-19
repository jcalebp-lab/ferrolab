// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FERROLAB';

  @override
  String get appSubtitle => 'Laboratorio virtual de tratamientos térmicos';

  @override
  String get welcomeHeadline =>
      'Entiende cómo el calor transforma los metales.';

  @override
  String get welcomeBody =>
      'Explora tratamientos térmicos con simulaciones educativas y descubre qué sabemos realmente sobre cada resultado.';

  @override
  String get welcomeStart => 'Comenzar';

  @override
  String get welcomeSkip => 'Omitir introducción';

  @override
  String get welcomeFree => 'Gratis · Sin cuenta · Sin anuncios';

  @override
  String get onbStep1Title => '1. Elige material y tratamiento';

  @override
  String get onbStep1Body =>
      'Tres materiales reales y seis tratamientos. No todas las combinaciones están respaldadas: FERROLAB te dice por qué.';

  @override
  String get onbStep2Title => '2. Configura y ejecuta';

  @override
  String get onbStep2Body =>
      'Tú controlas temperatura y tiempo de mantenimiento. El enfriamiento lo fija el protocolo.';

  @override
  String get onbStep3Title => '3. Interpreta con evidencia';

  @override
  String get onbStep3Body =>
      'Cada resultado indica su fuente y su nivel de evidencia. Si no hay datos, lo verás claramente.';

  @override
  String get next => 'Siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get close => 'Cerrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get homeGreeting => '¿Qué exploramos hoy?';

  @override
  String get homeHero => 'Comprende lo que el calor cambia en los metales';

  @override
  String get homeLabTitle => 'Laboratorio virtual';

  @override
  String get homeLabBody =>
      'Elige material y tratamiento, configura el horno y analiza el resultado.';

  @override
  String get homeStart => 'Iniciar simulación';

  @override
  String get homeLearn => 'Aprender';

  @override
  String get homeMicro => 'Explorar microestructuras';

  @override
  String get homePractice => 'Modo práctica';

  @override
  String get homeHistory => 'Mi historial';

  @override
  String get homeTeacher => 'Docentes';

  @override
  String get homeBanner =>
      'Herramienta educativa. Las propiedades dependen de datos y condiciones reales.';

  @override
  String get homeLastSession => 'Última simulación';

  @override
  String get unreviewedBanner =>
      'Contenido editorial pendiente de revisión por un especialista.';

  @override
  String get settings => 'Ajustes';

  @override
  String stepOf(Object step, Object total) {
    return 'Paso $step de $total';
  }

  @override
  String get materialTitle => 'Elige un material';

  @override
  String get materialSteel => 'Acero';

  @override
  String get materialCastIron => 'Fundición gris';

  @override
  String get materialViewSheet => 'Ver ficha';

  @override
  String get materialNoComposition =>
      'Sin rangos de composición verificados cargados.';

  @override
  String get materialInitialCondition => 'Condición inicial';

  @override
  String get materialLimitations => 'Limitaciones';

  @override
  String get materialSuggestedReading => 'Lectura sugerida (no verificada)';

  @override
  String get treatmentTitle => 'Elige un tratamiento';

  @override
  String get treatmentWhyNot => 'Conoce por qué';

  @override
  String get compat_supported => 'Compatible con protocolo';

  @override
  String get compat_conditional => 'Condicional';

  @override
  String get compat_educational_only => 'Solo aprendizaje';

  @override
  String get compat_unsupported => 'No soportado';

  @override
  String get treatmentPrerequisites => 'Requisitos';

  @override
  String get treatmentStages => 'Etapas del proceso';

  @override
  String get paramsTitle => 'Configura tu experimento';

  @override
  String get paramsYouControl => 'Lo que tú controlas';

  @override
  String get paramsProtocolDefines => 'Lo que define el protocolo';

  @override
  String get paramsTemperature => 'Temperatura objetivo';

  @override
  String get paramsHold => 'Tiempo de mantenimiento';

  @override
  String get paramsMinutes => 'minutos';

  @override
  String paramsHoldStage(Object stage) {
    return 'Se aplica a: $stage';
  }

  @override
  String paramsFurnaceRange(Object min, Object max) {
    return 'Rango del horno (interfaz): $min–$max °C';
  }

  @override
  String get paramsThermalLimit => 'Rango válido del protocolo';

  @override
  String get paramsRangeUnpublished =>
      'Rango válido del protocolo: aún no documentado';

  @override
  String get paramsRangeTooltip =>
      'El rango válido depende del material y del tratamiento; el máximo del horno es solo la capacidad visual del instrumento.';

  @override
  String paramsPhysicalLimit(Object limit) {
    return 'Límite físico de seguridad: $limit °C (fusión)';
  }

  @override
  String get protocolLocked => 'Enfriamiento definido por protocolo';

  @override
  String get protocolLockedWhy =>
      'Se selecciona automáticamente según el protocolo revisado por material y tratamiento; no es configurable para mantener la simulación trazable.';

  @override
  String get protocolPending => 'Protocolo pendiente de revisión';

  @override
  String get protocolMedium => 'Medio';

  @override
  String get paramsReview => 'Revisar configuración';

  @override
  String get paramsInvalidNumber => 'Introduce un número válido';

  @override
  String get paramsOutOfUi => 'Fuera del rango de la interfaz';

  @override
  String get runReview => 'Revisar experimento';

  @override
  String get reviewTitle => 'Tu experimento';

  @override
  String get reviewMaterial => 'Material';

  @override
  String get reviewTreatment => 'Tratamiento';

  @override
  String get reviewTemperature => 'Temperatura';

  @override
  String get reviewTime => 'Tiempo';

  @override
  String get reviewInitial => 'Estado inicial';

  @override
  String get reviewCooling => 'Enfriamiento';

  @override
  String get reviewAutomatic => 'Automático';

  @override
  String get reviewHeadsUp => 'Antes de empezar';

  @override
  String get reviewExpectInsufficient =>
      'Con la evidencia actual no habrá cifras de dureza ni de fases para esta condición; verás el ciclo, la explicación y las fuentes.';

  @override
  String get reviewStart => 'Iniciar laboratorio';

  @override
  String get reviewEdit => 'Editar';

  @override
  String get reviewBlocked => 'No se puede ejecutar con estos parámetros';

  @override
  String get validating => 'Validando…';

  @override
  String get furnaceTitle => 'Laboratorio';

  @override
  String get furnaceStage => 'Etapa';

  @override
  String get furnaceTemp => 'Temperatura';

  @override
  String get furnacePhysicalTime => 'Tiempo de proceso simulado';

  @override
  String get furnaceAnimTime => 'Duración de animación';

  @override
  String furnaceSpeed(Object factor) {
    return 'Reproducción: $factor×';
  }

  @override
  String get furnaceSchematicSpeed => 'Reproducción esquemática (no a escala)';

  @override
  String get furnaceVisualDisclaimer => 'El color de la pieza es ilustrativo';

  @override
  String get furnacePlay => 'Reproducir';

  @override
  String get furnacePause => 'Pausar';

  @override
  String get furnaceRestart => 'Repetir';

  @override
  String get furnaceSkip => 'Saltar al final';

  @override
  String get furnaceSeeResults => 'Ver resultados';

  @override
  String furnaceYourTarget(Object value) {
    return '$value °C (tu objetivo)';
  }

  @override
  String furnaceYourHold(Object value) {
    return '$value min (tu valor)';
  }

  @override
  String get furnaceAmbient => 'Temperatura ambiente';

  @override
  String get furnaceBath => 'Baño (temperatura no publicada)';

  @override
  String get furnaceDurationUnpublished => 'Duración no publicada';

  @override
  String get furnaceReducedMotion =>
      'Movimiento reducido: se muestran las etapas sin animación.';

  @override
  String get furnaceRunning => 'Calculando con el motor científico…';

  @override
  String get chartTitle => 'Temperatura vs. tiempo';

  @override
  String get chartSchematic => 'Esquema del ciclo: eje de tiempo no a escala';

  @override
  String get chartPhysical =>
      'Historial térmico del motor científico (centro de la probeta)';

  @override
  String get chartTimeAxis => 'tiempo';

  @override
  String get chartNoData => 'Sin trayectoria para mostrar';

  @override
  String get resultsTitle => 'Esto podemos concluir';

  @override
  String get status_completed => 'Resultado completo respaldado';

  @override
  String get status_partial_result => 'Resultado parcial';

  @override
  String get status_insufficient_evidence =>
      'Evidencia insuficiente para cifras';

  @override
  String get status_unsupported => 'Combinación no soportada';

  @override
  String get status_invalid_input => 'Entrada fuera de dominio';

  @override
  String get status_internal_error => 'Error interno';

  @override
  String get statusInsufficientBody =>
      'Esta combinación se puede estudiar, pero no calcular con rigor todavía.';

  @override
  String get resultsSummary => 'Resumen del tratamiento';

  @override
  String get resultsHistory => 'Historial térmico';

  @override
  String get resultsTransformations => 'Transformación y fases';

  @override
  String get resultsTransformationsNote =>
      'Fases cristalográficas y microconstituyentes se muestran por separado; nunca se suman entre sí.';

  @override
  String get resultsProperties => 'Propiedades';

  @override
  String get resultsMicroscope => 'Microscopio';

  @override
  String get resultsFoundation => 'Fundamento científico';

  @override
  String get resultsKeepLearning => 'Seguir aprendiendo';

  @override
  String get q_phase_fractions => 'Fracciones de fases';

  @override
  String get q_microconstituent_fractions => 'Microconstituyentes';

  @override
  String get q_hardness => 'Dureza final';

  @override
  String get q_grain_size => 'Tamaño de grano';

  @override
  String get q_mechanical_properties => 'Propiedades mecánicas';

  @override
  String get resultsUnavailable => 'No estimable con la evidencia actual';

  @override
  String get resultsViewSource => 'Ver fuente y límites';

  @override
  String get resultsWhatsMissing => '¿Qué datos faltan?';

  @override
  String get resultsWhatsMissingBody =>
      'Para mostrar una cifra, FERROLAB necesita un dato experimental o un modelo validado para esta condición exacta (material, estado inicial, protocolo publicado, temperatura y tiempo), con fuente, localizador y rango de validez, revisado por una persona con formación metalúrgica.';

  @override
  String get evidence_validated => 'Validado';

  @override
  String get evidence_bounded_estimate => 'Estimación acotada';

  @override
  String get evidence_qualitative => 'Cualitativo';

  @override
  String get evidence_insufficient_evidence => 'Evidencia insuficiente';

  @override
  String get evidence_unsupported => 'No soportado';

  @override
  String get kind_measured => 'Medido';

  @override
  String get kind_literature => 'Bibliográfico';

  @override
  String get kind_modeled => 'Modelado';

  @override
  String get kind_illustrative => 'Ilustrativo';

  @override
  String get kind_unavailable => 'No disponible';

  @override
  String get resultsWarnings => 'Advertencias y limitaciones';

  @override
  String get resultsAssumptions => 'Supuestos';

  @override
  String get resultsSources => 'Fuentes';

  @override
  String get resultsVersions => 'Versiones';

  @override
  String get resultsProtocol => 'Protocolo';

  @override
  String get resultsSuggestedReading => 'Lectura sugerida';

  @override
  String get resultsSupportsValue => 'Respalda una cifra';

  @override
  String get resultsSupportsLimit => 'Respalda un límite';

  @override
  String get sourceUnverified => 'Referencia no verificada por el proyecto';

  @override
  String get sourceVerified => 'Referencia verificada';

  @override
  String get resultsSave => 'Guardar en historial';

  @override
  String get resultsSaved => 'Guardado en este dispositivo';

  @override
  String get resultsWhatIf => '¿Qué pasaría si…?';

  @override
  String get resultsWhatIfBody =>
      'Cambia una variable y compara con este resultado.';

  @override
  String get resultsCompare => 'Comparar';

  @override
  String get resultsNewRun => 'Nueva prueba';

  @override
  String get resultsCopy => 'Copiar resumen';

  @override
  String get resultsCopied => 'Resumen copiado';

  @override
  String get resultsEducationalBanner =>
      'Herramienta educativa, no tratamiento industrial.';

  @override
  String get tutorExplain => '¿Por qué ocurrió esto?';

  @override
  String get tutorTitle => 'Tutor educativo';

  @override
  String get tutorEditorialMode => 'Explicación editorial (sin IA)';

  @override
  String get tutorAiMode => 'Generado por IA a partir de contexto revisado';

  @override
  String get tutorAskHint => 'Escribe una pregunta conceptual';

  @override
  String get tutorAsk => 'Preguntar';

  @override
  String get tutorPrivacy =>
      'Si el tutor IA está activo, tu pregunta se envía a un proveedor externo. No escribas datos personales.';

  @override
  String get tutorQuick1 => '¿Qué diferencia hay entre TTT y CCT?';

  @override
  String get tutorQuick2 => '¿Por qué importa la velocidad de enfriamiento?';

  @override
  String get tutorQuick3 =>
      '¿En qué se diferencian martempering y austempering?';

  @override
  String get tutorQuick4 => '¿La fundición gris se comporta como el acero?';

  @override
  String get tutorQuick5 => '¿Por qué no aparece un valor de dureza?';

  @override
  String get microTitle => 'Microestructura';

  @override
  String get microNoMatch =>
      'Aún no tenemos una micrografía verificada de esta condición.';

  @override
  String get microNoMatchBody =>
      'Para mostrar una micrografía exigimos licencia comprobada, autor, técnica, aumento y que corresponda al material y la condición. No mostramos imágenes de otros aceros como si fueran de este experimento.';

  @override
  String get microDigitalZoom => 'Zoom digital, no aumento óptico';

  @override
  String get microZoomIn => 'Acercar';

  @override
  String get microZoomOut => 'Alejar';

  @override
  String microScaleCalibrated(Object value) {
    return 'Barra de escala calibrada: $value µm';
  }

  @override
  String get microScaleMissing => 'Sin calibración: no se permite medir';

  @override
  String get microLibraryEmpty =>
      'La biblioteca de micrografías está vacía: aún no hay imágenes con licencia y metadatos verificados.';

  @override
  String get microAttribution => 'Autor / licencia';

  @override
  String get learnTitle => 'Aprender';

  @override
  String get learnGlossary => 'Glosario';

  @override
  String get learnConcepts => 'Conceptos';

  @override
  String get learnFaq => 'Preguntas frecuentes';

  @override
  String get learnTreatments => 'Tratamientos';

  @override
  String get learnDiagrams => 'Diagramas';

  @override
  String get learnDiagramsBody =>
      'FERROLAB solo dibuja curvas TTT, CCT o Fe–C a partir de datos digitalizados con fuente y permiso. Todavía no hay ninguno publicado, así que aquí encontrarás la explicación conceptual sin líneas ficticias.';

  @override
  String get learnRelated => 'Relacionado';

  @override
  String get learnSearch => 'Buscar';

  @override
  String get practiceTitle => 'Modo práctica';

  @override
  String get practiceIntro =>
      'Preguntas conceptuales con retroalimentación. No es una calificación oficial y tu progreso queda solo en este dispositivo.';

  @override
  String get practiceCorrect => '¡Correcto!';

  @override
  String get practiceIncorrect => 'No exactamente';

  @override
  String practiceScore(Object correct, Object total) {
    return '$correct de $total correctas';
  }

  @override
  String get practiceNext => 'Siguiente pregunta';

  @override
  String get practiceRestart => 'Empezar de nuevo';

  @override
  String get practiceHypothesis => 'Antes de simular: ¿qué esperas que ocurra?';

  @override
  String get historyTitle => 'Historial local';

  @override
  String get historyEmpty => 'Aún no has guardado simulaciones.';

  @override
  String get historyLocalNote =>
      'Se guarda solo en este dispositivo/navegador. Si borras los datos o cambias de dispositivo, se pierde. No hay sincronización.';

  @override
  String get historyDelete => 'Eliminar historial local';

  @override
  String get historyDeleteConfirm =>
      '¿Eliminar todo el historial guardado en este dispositivo?';

  @override
  String get historySelectTwo => 'Selecciona dos simulaciones para comparar';

  @override
  String get compareTitle => 'Comparación';

  @override
  String get compareNote =>
      'Solo se comparan magnitudes con la misma unidad y evidencia. Las ausencias se muestran como —.';

  @override
  String get compareDifferent => 'Diferencias';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsReduceMotion => 'Reducir movimiento';

  @override
  String get settingsSound => 'Sonido';

  @override
  String get settingsSoundNote => 'Sin sonidos en esta versión.';

  @override
  String get settingsAchievements => 'Logros';

  @override
  String get settingsAchievementsNote =>
      'Logros locales y desactivables; no se envían a ningún servidor.';

  @override
  String get settingsTutorial => 'Ver la introducción otra vez';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsPrivacyBody =>
      'FERROLAB no te pide cuenta, correo ni datos personales. Tus preferencias, historial, práctica y logros se guardan solo en este dispositivo. El servidor calcula cada simulación y no la almacena.';

  @override
  String get settingsSources => 'Bibliografía y fuentes';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAdmin => 'Panel de administración';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotificationsNote =>
      'Desactivadas. FERROLAB no envía recordatorios.';

  @override
  String get sourcesTitle => 'Bibliografía y fuentes';

  @override
  String get sourcesNote =>
      'Citar una obra no demuestra acceso a su contenido. Las referencias marcadas «no verificada» son lecturas sugeridas y no respaldan ninguna cifra.';

  @override
  String get achFirstRun => 'Primer experimento';

  @override
  String get achAllMaterials => 'Exploraste los tres materiales';

  @override
  String get achAllTreatments => 'Probaste los seis tratamientos';

  @override
  String get achPractice => 'Cinco respuestas correctas en práctica';

  @override
  String get achHonest => 'Encontraste un límite de la evidencia';

  @override
  String achUnlocked(Object name) {
    return 'Logro desbloqueado: $name';
  }

  @override
  String get teacherTitle => 'Modo docente';

  @override
  String get teacherIntro =>
      'Crea un código de actividad con una configuración fija. Los estudiantes lo introducen sin cuenta ni datos personales. Un código no es una contraseña ni autentica a nadie.';

  @override
  String get teacherCreate => 'Crear código con la configuración actual';

  @override
  String get teacherCode => 'Código de actividad';

  @override
  String get teacherEnter => 'Introducir un código';

  @override
  String get teacherLoad => 'Cargar actividad';

  @override
  String get teacherInvalid => 'Código no válido';

  @override
  String get teacherNoConfig =>
      'Primero configura una simulación (material y tratamiento).';

  @override
  String get teacherPresentation => 'Modo presentación';

  @override
  String get networkError =>
      'Sin conexión al motor. Tu configuración sigue aquí.';

  @override
  String get networkRetry => 'Reintentar';

  @override
  String get internalError => 'No pudimos completar esta solicitud.';

  @override
  String supportCode(Object code) {
    return 'Código de soporte: $code';
  }

  @override
  String get rateLimited =>
      'Demasiadas solicitudes; espera un momento e inténtalo de nuevo.';

  @override
  String get loading => 'Cargando…';

  @override
  String get adminTitle => 'FERROLAB Admin';

  @override
  String get adminLogin => 'Iniciar sesión';

  @override
  String get adminEmail => 'Correo';

  @override
  String get adminPassword => 'Contraseña';

  @override
  String get adminDevToken => 'Token de desarrollo';

  @override
  String get adminDevTokenHint =>
      'Solo en desarrollo local: pega el token generado con scripts/dev_admin_token.py';

  @override
  String get adminNotConfigured =>
      'La administración no está disponible: el servidor no tiene base de datos o autenticación configurada.';

  @override
  String get adminLogout => 'Cerrar sesión';

  @override
  String get adminRecords => 'Registros';

  @override
  String get adminReleases => 'Publicaciones';

  @override
  String get adminAudit => 'Auditoría';

  @override
  String adminRole(Object role) {
    return 'Rol: $role';
  }

  @override
  String get adminReview => 'Marcar como revisado';

  @override
  String get adminToDraft => 'Volver a borrador';

  @override
  String get adminRetire => 'Retirar';

  @override
  String get adminSave => 'Guardar borrador';

  @override
  String get adminSaved => 'Guardado como borrador';

  @override
  String get adminNew => 'Nuevo registro';

  @override
  String get adminPreview => 'Comprobar publicación';

  @override
  String get adminPublish => 'Publicar versión';

  @override
  String get adminActivate => 'Activar (revertir a esta)';

  @override
  String get adminVersion => 'Versión (p. ej. 1.0.0)';

  @override
  String get adminActive => 'Activa';

  @override
  String get adminProblems => 'Problemas que bloquean la publicación';

  @override
  String get adminReport => 'Informe';

  @override
  String get adminReviewWarning =>
      'Revisar significa que una persona con formación metalúrgica comprobó la fuente, el localizador, las unidades y el dominio. No lo marques si no lo hiciste.';

  @override
  String get adminJsonField => '(JSON)';

  @override
  String get settingsServer => 'Servidor de FERROLAB';

  @override
  String get settingsServerHint => 'p. ej. http://192.168.1.20:8000';

  @override
  String get settingsServerSave => 'Guardar y probar';

  @override
  String get settingsServerReset => 'Usar el predeterminado';

  @override
  String settingsServerOk(Object version) {
    return 'Conectado: $version';
  }

  @override
  String get settingsServerInvalid =>
      'Escribe una dirección que empiece por http:// o https://';

  @override
  String settingsServerCurrent(Object url) {
    return 'Dirección actual: $url';
  }

  @override
  String get settingsServerNote =>
      'La app necesita el servidor de FERROLAB para calcular. En tu casa puedes usar tu computadora en la misma Wi‑Fi (http://IP:8000). Las direcciones http:// no van cifradas: úsalas solo en tu red local.';

  @override
  String get homeConfigureServer => 'Configurar servidor';

  @override
  String get recTitle => 'Práctica recomendada';

  @override
  String get recUse => 'Usar valores recomendados';

  @override
  String get recOutsideTemp =>
      'Esta temperatura está fuera de lo recomendado por la literatura: es una mala práctica. Puedes simularla para ver qué pasa, pero el resultado lo advertirá.';

  @override
  String get recOutsideHold => 'Este tiempo está fuera de lo recomendado.';

  @override
  String get recNoNumber => 'la fuente no da cifra';

  @override
  String get recBath => 'Baño';

  @override
  String get constFerrite => 'Ferrita proeutectoide';

  @override
  String get constPearlite => 'Perlita';

  @override
  String get constBainite => 'Bainita';

  @override
  String get constMartensite => 'Martensita';

  @override
  String get constTemperedMartensite => 'Martensita revenida';

  @override
  String get constRetained => 'Austenita retenida';

  @override
  String get constGraphite => 'Grafito en láminas (tipo A)';

  @override
  String get phaseFerrite => 'Ferrita (α)';

  @override
  String get phaseCementite => 'Cementita (Fe₃C)';

  @override
  String get phaseAustenite => 'Austenita (γ)';

  @override
  String get grayMatrixPearlite => 'Matriz perlítica';

  @override
  String get grayMatrixFerritePearlite => 'Matriz ferrito-perlítica';

  @override
  String get grayMatrixMartensite => 'Matriz martensítica';

  @override
  String get grayMatrixTempered => 'Matriz de martensita revenida';

  @override
  String get grayMatrixAusferrite => 'Matriz ausferrítica';

  @override
  String get microGeneratedTitle => 'Microestructura generada';

  @override
  String get microGeneratedNote =>
      'Ilustración GENERADA por FERROLAB a partir de las fracciones calculadas por el modelo (centro de la probeta). No es una micrografía real: sirve para reconocer los constituyentes.';

  @override
  String get microGesture =>
      'Pellizca o usa la rueda del ratón para acercar; arrastra para recorrer la muestra.';

  @override
  String get microReset => 'Volver al aumento inicial';

  @override
  String get microRealTitle => 'Micrografía real con licencia';

  @override
  String get microQualitative =>
      'Fundición gris: matriz y grafito cualitativos (sin fracciones calculadas).';

  @override
  String get microUnchanged =>
      'No hubo austenización: la microestructura de partida no cambia y no se dibuja una nueva.';

  @override
  String get microOpen => 'Abrir el microscopio';

  @override
  String get diagTitle => 'Diagramas TTT y CCT de tu práctica';

  @override
  String get diagTtt => 'TTT';

  @override
  String get diagCct => 'CCT';

  @override
  String get diagTttNote =>
      'TTT: tiempo para empezar (1 %) y terminar (99 %) cada transformación si la temperatura se mantiene constante. Tu curva muestra el enfriamiento real del centro de la probeta.';

  @override
  String get diagCctNote =>
      'CCT: inicio de cada transformación en enfriamiento continuo a velocidades constantes. Donde tu curva cruza una zona, se forma ese constituyente.';

  @override
  String get diagYourPath => 'Tu práctica (centro)';

  @override
  String get diagAxes =>
      'Eje x: tiempo desde el inicio del enfriamiento (s, escala logarítmica). Eje y: temperatura (°C). Modelo de Li et al. (1998), composición nominal, G ASTM 7.';

  @override
  String get diagTable => 'Ver datos del diagrama';

  @override
  String get modelTitle => 'Detalles de la estimación';

  @override
  String get modelLabel =>
      'Estimación por modelos empíricos publicados; no revisada por un especialista.';

  @override
  String get modelCritical => 'Temperaturas críticas (calculadas)';

  @override
  String get modelComposition => 'Composición nominal usada (% en masa)';

  @override
  String get modelSurface => 'Superficie de la probeta';

  @override
  String get modelPrior =>
      'Estado templado de partida (calculado con la práctica recomendada de temple)';

  @override
  String get modelSpecimen =>
      'Probeta de referencia: cilindro de 12,7 mm, resultados en el centro.';

  @override
  String get factBand => 'Banda de incertidumbre';

  @override
  String recTemperature(String range) {
    return 'Temperatura: $range';
  }

  @override
  String recHold(String range) {
    return 'Mantenimiento: $range';
  }

  @override
  String recMedium(String medium) {
    return 'Medio de enfriamiento: $medium';
  }

  @override
  String recSources(String sources) {
    return 'Fuentes: $sources';
  }

  @override
  String microMagnification(String x) {
    return '≈ $x× en pantalla';
  }

  @override
  String diagPoint(String time, String temp) {
    return 'Tu práctica: t = $time · $temp °C';
  }

  @override
  String diagNose(String time, String temp) {
    return 'nariz: $time a $temp °C';
  }

  @override
  String modelCooling(String rate) {
    return 'Velocidad de enfriamiento a 700 °C: $rate °C/s';
  }

  @override
  String modelBath(String temp) {
    return 'Temperatura del baño (modelo): $temp °C';
  }

  @override
  String modelAustenite(String pct) {
    return 'Austenita formada en el mantenimiento: $pct %';
  }

  @override
  String factBandValue(String lo, String hi) {
    return '$lo – $hi';
  }

  @override
  String get mediumWater => 'agua';

  @override
  String get mediumOil => 'aceite';

  @override
  String get mediumAir => 'aire en calma';

  @override
  String get mediumFurnace => 'horno';

  @override
  String get mediumSaltBath => 'baño de sales';

  @override
  String get reviewExpectModel =>
      'Se calcularán ESTIMACIONES de modelos publicados: fases, constituyentes, dureza y diagramas TTT/CCT de tu práctica. Irán etiquetadas como estimaciones (no mediciones).';

  @override
  String get microLabelsToggle => 'Señalar microconstituyentes';

  @override
  String get microLabelsZoomHint =>
      'Las flechas se muestran en el aumento base: pulsa «Volver al aumento inicial».';

  @override
  String get microLabelRetained => 'Austenita retenida (islas blancas)';

  @override
  String get levelA =>
      'A · Cálculo con modelos publicados (pendiente de validación por especialista)';

  @override
  String get levelB => 'B · Interpretación cualitativa fundamentada';

  @override
  String get levelC => 'C · Demostración educativa ilustrativa';

  @override
  String get lpLimitations => 'Fundamento científico y limitaciones';

  @override
  String get groupInput => 'Tus parámetros';

  @override
  String get groupDependency => 'Estado previo';

  @override
  String get groupProtocol => 'Protocolo';

  @override
  String get groupEvidence => 'Evidencia';

  @override
  String get groupModel => 'Modelo';

  @override
  String get groupReview => 'Revisión';

  @override
  String get groupOther => 'Otros';

  @override
  String get lpReference => 'Referencia';

  @override
  String get lpVerified => 'Fuente verificada';

  @override
  String get lpUnverified => 'Fuente no verificada por FERROLAB';

  @override
  String get lpProtocols => 'Protocolos disponibles';

  @override
  String get lpUseProtocol => 'Usar protocolo recomendado';

  @override
  String get lpParams => 'Parámetros del protocolo';

  @override
  String get pFurnace => 'Temperatura del horno';

  @override
  String get pHold => 'Tiempo de sostenimiento';

  @override
  String get pBath => 'Temperatura del baño';

  @override
  String get pBathTime => 'Tiempo en el baño';

  @override
  String get pBathEqualize =>
      'Vacío = hasta igualar la temperatura (calculado)';

  @override
  String get pOutside => 'Fuera del intervalo documentado para este protocolo.';

  @override
  String get pMediumLocked => 'Medio de enfriamiento (fijado por el protocolo)';

  @override
  String get lpSequence => 'Secuencia térmica';

  @override
  String get lpSheet => 'Ficha científica del protocolo';

  @override
  String get lpObjective => 'Objetivo';

  @override
  String get lpCondition => 'Condición del material';

  @override
  String get lpExpected => 'Resultado esperado';

  @override
  String get lpRestrictions => 'Condiciones y restricciones';

  @override
  String get lpAssumptions => 'Supuestos';

  @override
  String get lpMissing => 'Lo que falta investigar';

  @override
  String get lpPublished =>
      'Resultados publicados del caso (medidos, no predichos)';

  @override
  String get lpSources => 'Fuentes';

  @override
  String get lpPrior => 'Estado de partida del revenido';

  @override
  String get priorReference => 'Templada de referencia';

  @override
  String get priorHistory => 'De mi historial';

  @override
  String get priorTheory => 'Solo teoría';

  @override
  String get priorHistoryEmpty =>
      'Aún no hay temples de este material en tu historial (guárdalos desde Resultados).';

  @override
  String get seqAmbient => 'ambiente';

  @override
  String get seqUntilEqualized => 'hasta igualar';

  @override
  String get seqStart => 'Inicio del conteo';

  @override
  String get lpMaterialPanel => 'Material';

  @override
  String get lpComposition => 'Composición de referencia (% en masa)';

  @override
  String get lpCompositionNone =>
      'La norma no fija composición: comprueba la de tu pieza.';

  @override
  String get lpTreatmentPanel => 'Tratamiento';

  @override
  String get basisSource => 'Dato de la fuente';

  @override
  String get basisRule => 'Regla publicada aplicada a la probeta de 12,7 mm';

  @override
  String get basisModel => 'Calculado con el modelo (no publicado)';

  @override
  String get basisPending => 'la fuente no da cifra';

  @override
  String get basisComputed => 'Calculado por el modelo térmico';

  @override
  String get goalReference => 'General';

  @override
  String get goalHardness => 'Orientado a dureza';

  @override
  String get goalToughness => 'Orientado a tenacidad';

  @override
  String get goalSoftening => 'Ablandamiento';

  @override
  String get goalStressRelief => 'Alivio de tensiones';

  @override
  String get goalExperimental => 'Caso experimental';

  @override
  String get goalMachinability => 'Maquinabilidad';

  @override
  String get goalPending => 'Pendiente';

  @override
  String get mediumTinBath => 'baño de estaño';

  @override
  String get furnaceBathScene => 'Baño isotérmico';

  @override
  String lpLimitationsCount(String n) {
    return '$n avisos agrupados por causa';
  }

  @override
  String pRange(String range) {
    return 'Intervalo documentado: $range';
  }

  @override
  String pRef(String v) {
    return 'Referencia: $v';
  }

  @override
  String get lpProtocol => 'Protocolo';
}
