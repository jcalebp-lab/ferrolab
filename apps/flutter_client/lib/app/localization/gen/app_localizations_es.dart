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
      'Historial del motor científico (tramos lineales didácticos)';

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
}
