import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'FERROLAB'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Laboratorio virtual de tratamientos térmicos'**
  String get appSubtitle;

  /// No description provided for @welcomeHeadline.
  ///
  /// In es, this message translates to:
  /// **'Entiende cómo el calor transforma los metales.'**
  String get welcomeHeadline;

  /// No description provided for @welcomeBody.
  ///
  /// In es, this message translates to:
  /// **'Explora tratamientos térmicos con simulaciones educativas y descubre qué sabemos realmente sobre cada resultado.'**
  String get welcomeBody;

  /// No description provided for @welcomeStart.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get welcomeStart;

  /// No description provided for @welcomeSkip.
  ///
  /// In es, this message translates to:
  /// **'Omitir introducción'**
  String get welcomeSkip;

  /// No description provided for @welcomeFree.
  ///
  /// In es, this message translates to:
  /// **'Gratis · Sin cuenta · Sin anuncios'**
  String get welcomeFree;

  /// No description provided for @onbStep1Title.
  ///
  /// In es, this message translates to:
  /// **'1. Elige material y tratamiento'**
  String get onbStep1Title;

  /// No description provided for @onbStep1Body.
  ///
  /// In es, this message translates to:
  /// **'Tres materiales reales y seis tratamientos. No todas las combinaciones están respaldadas: FERROLAB te dice por qué.'**
  String get onbStep1Body;

  /// No description provided for @onbStep2Title.
  ///
  /// In es, this message translates to:
  /// **'2. Configura y ejecuta'**
  String get onbStep2Title;

  /// No description provided for @onbStep2Body.
  ///
  /// In es, this message translates to:
  /// **'Tú controlas temperatura y tiempo de mantenimiento. El enfriamiento lo fija el protocolo.'**
  String get onbStep2Body;

  /// No description provided for @onbStep3Title.
  ///
  /// In es, this message translates to:
  /// **'3. Interpreta con evidencia'**
  String get onbStep3Title;

  /// No description provided for @onbStep3Body.
  ///
  /// In es, this message translates to:
  /// **'Cada resultado indica su fuente y su nivel de evidencia. Si no hay datos, lo verás claramente.'**
  String get onbStep3Body;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get back;

  /// No description provided for @continueLabel.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @homeGreeting.
  ///
  /// In es, this message translates to:
  /// **'¿Qué exploramos hoy?'**
  String get homeGreeting;

  /// No description provided for @homeHero.
  ///
  /// In es, this message translates to:
  /// **'Comprende lo que el calor cambia en los metales'**
  String get homeHero;

  /// No description provided for @homeLabTitle.
  ///
  /// In es, this message translates to:
  /// **'Laboratorio virtual'**
  String get homeLabTitle;

  /// No description provided for @homeLabBody.
  ///
  /// In es, this message translates to:
  /// **'Elige material y tratamiento, configura el horno y analiza el resultado.'**
  String get homeLabBody;

  /// No description provided for @homeStart.
  ///
  /// In es, this message translates to:
  /// **'Iniciar simulación'**
  String get homeStart;

  /// No description provided for @homeLearn.
  ///
  /// In es, this message translates to:
  /// **'Aprender'**
  String get homeLearn;

  /// No description provided for @homeMicro.
  ///
  /// In es, this message translates to:
  /// **'Explorar microestructuras'**
  String get homeMicro;

  /// No description provided for @homePractice.
  ///
  /// In es, this message translates to:
  /// **'Modo práctica'**
  String get homePractice;

  /// No description provided for @homeHistory.
  ///
  /// In es, this message translates to:
  /// **'Mi historial'**
  String get homeHistory;

  /// No description provided for @homeTeacher.
  ///
  /// In es, this message translates to:
  /// **'Docentes'**
  String get homeTeacher;

  /// No description provided for @homeBanner.
  ///
  /// In es, this message translates to:
  /// **'Herramienta educativa. Las propiedades dependen de datos y condiciones reales.'**
  String get homeBanner;

  /// No description provided for @homeLastSession.
  ///
  /// In es, this message translates to:
  /// **'Última simulación'**
  String get homeLastSession;

  /// No description provided for @unreviewedBanner.
  ///
  /// In es, this message translates to:
  /// **'Contenido editorial pendiente de revisión por un especialista.'**
  String get unreviewedBanner;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @stepOf.
  ///
  /// In es, this message translates to:
  /// **'Paso {step} de {total}'**
  String stepOf(Object step, Object total);

  /// No description provided for @materialTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige un material'**
  String get materialTitle;

  /// No description provided for @materialSteel.
  ///
  /// In es, this message translates to:
  /// **'Acero'**
  String get materialSteel;

  /// No description provided for @materialCastIron.
  ///
  /// In es, this message translates to:
  /// **'Fundición gris'**
  String get materialCastIron;

  /// No description provided for @materialViewSheet.
  ///
  /// In es, this message translates to:
  /// **'Ver ficha'**
  String get materialViewSheet;

  /// No description provided for @materialNoComposition.
  ///
  /// In es, this message translates to:
  /// **'Sin rangos de composición verificados cargados.'**
  String get materialNoComposition;

  /// No description provided for @materialInitialCondition.
  ///
  /// In es, this message translates to:
  /// **'Condición inicial'**
  String get materialInitialCondition;

  /// No description provided for @materialLimitations.
  ///
  /// In es, this message translates to:
  /// **'Limitaciones'**
  String get materialLimitations;

  /// No description provided for @materialSuggestedReading.
  ///
  /// In es, this message translates to:
  /// **'Lectura sugerida (no verificada)'**
  String get materialSuggestedReading;

  /// No description provided for @treatmentTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige un tratamiento'**
  String get treatmentTitle;

  /// No description provided for @treatmentWhyNot.
  ///
  /// In es, this message translates to:
  /// **'Conoce por qué'**
  String get treatmentWhyNot;

  /// No description provided for @compat_supported.
  ///
  /// In es, this message translates to:
  /// **'Compatible con protocolo'**
  String get compat_supported;

  /// No description provided for @compat_conditional.
  ///
  /// In es, this message translates to:
  /// **'Condicional'**
  String get compat_conditional;

  /// No description provided for @compat_educational_only.
  ///
  /// In es, this message translates to:
  /// **'Solo aprendizaje'**
  String get compat_educational_only;

  /// No description provided for @compat_unsupported.
  ///
  /// In es, this message translates to:
  /// **'No soportado'**
  String get compat_unsupported;

  /// No description provided for @treatmentPrerequisites.
  ///
  /// In es, this message translates to:
  /// **'Requisitos'**
  String get treatmentPrerequisites;

  /// No description provided for @treatmentStages.
  ///
  /// In es, this message translates to:
  /// **'Etapas del proceso'**
  String get treatmentStages;

  /// No description provided for @paramsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configura tu experimento'**
  String get paramsTitle;

  /// No description provided for @paramsYouControl.
  ///
  /// In es, this message translates to:
  /// **'Lo que tú controlas'**
  String get paramsYouControl;

  /// No description provided for @paramsProtocolDefines.
  ///
  /// In es, this message translates to:
  /// **'Lo que define el protocolo'**
  String get paramsProtocolDefines;

  /// No description provided for @paramsTemperature.
  ///
  /// In es, this message translates to:
  /// **'Temperatura objetivo'**
  String get paramsTemperature;

  /// No description provided for @paramsHold.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de mantenimiento'**
  String get paramsHold;

  /// No description provided for @paramsMinutes.
  ///
  /// In es, this message translates to:
  /// **'minutos'**
  String get paramsMinutes;

  /// No description provided for @paramsHoldStage.
  ///
  /// In es, this message translates to:
  /// **'Se aplica a: {stage}'**
  String paramsHoldStage(Object stage);

  /// No description provided for @paramsFurnaceRange.
  ///
  /// In es, this message translates to:
  /// **'Rango del horno (interfaz): {min}–{max} °C'**
  String paramsFurnaceRange(Object min, Object max);

  /// No description provided for @paramsThermalLimit.
  ///
  /// In es, this message translates to:
  /// **'Rango válido del protocolo'**
  String get paramsThermalLimit;

  /// No description provided for @paramsRangeUnpublished.
  ///
  /// In es, this message translates to:
  /// **'Rango válido del protocolo: aún no documentado'**
  String get paramsRangeUnpublished;

  /// No description provided for @paramsRangeTooltip.
  ///
  /// In es, this message translates to:
  /// **'El rango válido depende del material y del tratamiento; el máximo del horno es solo la capacidad visual del instrumento.'**
  String get paramsRangeTooltip;

  /// No description provided for @paramsPhysicalLimit.
  ///
  /// In es, this message translates to:
  /// **'Límite físico de seguridad: {limit} °C (fusión)'**
  String paramsPhysicalLimit(Object limit);

  /// No description provided for @protocolLocked.
  ///
  /// In es, this message translates to:
  /// **'Enfriamiento definido por protocolo'**
  String get protocolLocked;

  /// No description provided for @protocolLockedWhy.
  ///
  /// In es, this message translates to:
  /// **'Se selecciona automáticamente según el protocolo revisado por material y tratamiento; no es configurable para mantener la simulación trazable.'**
  String get protocolLockedWhy;

  /// No description provided for @protocolPending.
  ///
  /// In es, this message translates to:
  /// **'Protocolo pendiente de revisión'**
  String get protocolPending;

  /// No description provided for @protocolMedium.
  ///
  /// In es, this message translates to:
  /// **'Medio'**
  String get protocolMedium;

  /// No description provided for @paramsReview.
  ///
  /// In es, this message translates to:
  /// **'Revisar configuración'**
  String get paramsReview;

  /// No description provided for @paramsInvalidNumber.
  ///
  /// In es, this message translates to:
  /// **'Introduce un número válido'**
  String get paramsInvalidNumber;

  /// No description provided for @paramsOutOfUi.
  ///
  /// In es, this message translates to:
  /// **'Fuera del rango de la interfaz'**
  String get paramsOutOfUi;

  /// No description provided for @runReview.
  ///
  /// In es, this message translates to:
  /// **'Revisar experimento'**
  String get runReview;

  /// No description provided for @reviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu experimento'**
  String get reviewTitle;

  /// No description provided for @reviewMaterial.
  ///
  /// In es, this message translates to:
  /// **'Material'**
  String get reviewMaterial;

  /// No description provided for @reviewTreatment.
  ///
  /// In es, this message translates to:
  /// **'Tratamiento'**
  String get reviewTreatment;

  /// No description provided for @reviewTemperature.
  ///
  /// In es, this message translates to:
  /// **'Temperatura'**
  String get reviewTemperature;

  /// No description provided for @reviewTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo'**
  String get reviewTime;

  /// No description provided for @reviewInitial.
  ///
  /// In es, this message translates to:
  /// **'Estado inicial'**
  String get reviewInitial;

  /// No description provided for @reviewCooling.
  ///
  /// In es, this message translates to:
  /// **'Enfriamiento'**
  String get reviewCooling;

  /// No description provided for @reviewAutomatic.
  ///
  /// In es, this message translates to:
  /// **'Automático'**
  String get reviewAutomatic;

  /// No description provided for @reviewHeadsUp.
  ///
  /// In es, this message translates to:
  /// **'Antes de empezar'**
  String get reviewHeadsUp;

  /// No description provided for @reviewExpectInsufficient.
  ///
  /// In es, this message translates to:
  /// **'Con la evidencia actual no habrá cifras de dureza ni de fases para esta condición; verás el ciclo, la explicación y las fuentes.'**
  String get reviewExpectInsufficient;

  /// No description provided for @reviewStart.
  ///
  /// In es, this message translates to:
  /// **'Iniciar laboratorio'**
  String get reviewStart;

  /// No description provided for @reviewEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get reviewEdit;

  /// No description provided for @reviewBlocked.
  ///
  /// In es, this message translates to:
  /// **'No se puede ejecutar con estos parámetros'**
  String get reviewBlocked;

  /// No description provided for @validating.
  ///
  /// In es, this message translates to:
  /// **'Validando…'**
  String get validating;

  /// No description provided for @furnaceTitle.
  ///
  /// In es, this message translates to:
  /// **'Laboratorio'**
  String get furnaceTitle;

  /// No description provided for @furnaceStage.
  ///
  /// In es, this message translates to:
  /// **'Etapa'**
  String get furnaceStage;

  /// No description provided for @furnaceTemp.
  ///
  /// In es, this message translates to:
  /// **'Temperatura'**
  String get furnaceTemp;

  /// No description provided for @furnacePhysicalTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de proceso simulado'**
  String get furnacePhysicalTime;

  /// No description provided for @furnaceAnimTime.
  ///
  /// In es, this message translates to:
  /// **'Duración de animación'**
  String get furnaceAnimTime;

  /// No description provided for @furnaceSpeed.
  ///
  /// In es, this message translates to:
  /// **'Reproducción: {factor}×'**
  String furnaceSpeed(Object factor);

  /// No description provided for @furnaceSchematicSpeed.
  ///
  /// In es, this message translates to:
  /// **'Reproducción esquemática (no a escala)'**
  String get furnaceSchematicSpeed;

  /// No description provided for @furnaceVisualDisclaimer.
  ///
  /// In es, this message translates to:
  /// **'El color de la pieza es ilustrativo'**
  String get furnaceVisualDisclaimer;

  /// No description provided for @furnacePlay.
  ///
  /// In es, this message translates to:
  /// **'Reproducir'**
  String get furnacePlay;

  /// No description provided for @furnacePause.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get furnacePause;

  /// No description provided for @furnaceRestart.
  ///
  /// In es, this message translates to:
  /// **'Repetir'**
  String get furnaceRestart;

  /// No description provided for @furnaceSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar al final'**
  String get furnaceSkip;

  /// No description provided for @furnaceSeeResults.
  ///
  /// In es, this message translates to:
  /// **'Ver resultados'**
  String get furnaceSeeResults;

  /// No description provided for @furnaceYourTarget.
  ///
  /// In es, this message translates to:
  /// **'{value} °C (tu objetivo)'**
  String furnaceYourTarget(Object value);

  /// No description provided for @furnaceYourHold.
  ///
  /// In es, this message translates to:
  /// **'{value} min (tu valor)'**
  String furnaceYourHold(Object value);

  /// No description provided for @furnaceAmbient.
  ///
  /// In es, this message translates to:
  /// **'Temperatura ambiente'**
  String get furnaceAmbient;

  /// No description provided for @furnaceBath.
  ///
  /// In es, this message translates to:
  /// **'Baño (temperatura no publicada)'**
  String get furnaceBath;

  /// No description provided for @furnaceDurationUnpublished.
  ///
  /// In es, this message translates to:
  /// **'Duración no publicada'**
  String get furnaceDurationUnpublished;

  /// No description provided for @furnaceReducedMotion.
  ///
  /// In es, this message translates to:
  /// **'Movimiento reducido: se muestran las etapas sin animación.'**
  String get furnaceReducedMotion;

  /// No description provided for @furnaceRunning.
  ///
  /// In es, this message translates to:
  /// **'Calculando con el motor científico…'**
  String get furnaceRunning;

  /// No description provided for @chartTitle.
  ///
  /// In es, this message translates to:
  /// **'Temperatura vs. tiempo'**
  String get chartTitle;

  /// No description provided for @chartSchematic.
  ///
  /// In es, this message translates to:
  /// **'Esquema del ciclo: eje de tiempo no a escala'**
  String get chartSchematic;

  /// No description provided for @chartPhysical.
  ///
  /// In es, this message translates to:
  /// **'Historial térmico del motor científico (centro de la probeta)'**
  String get chartPhysical;

  /// No description provided for @chartTimeAxis.
  ///
  /// In es, this message translates to:
  /// **'tiempo'**
  String get chartTimeAxis;

  /// No description provided for @chartNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin trayectoria para mostrar'**
  String get chartNoData;

  /// No description provided for @resultsTitle.
  ///
  /// In es, this message translates to:
  /// **'Esto podemos concluir'**
  String get resultsTitle;

  /// No description provided for @status_completed.
  ///
  /// In es, this message translates to:
  /// **'Resultado completo respaldado'**
  String get status_completed;

  /// No description provided for @status_partial_result.
  ///
  /// In es, this message translates to:
  /// **'Resultado parcial'**
  String get status_partial_result;

  /// No description provided for @status_insufficient_evidence.
  ///
  /// In es, this message translates to:
  /// **'Evidencia insuficiente para cifras'**
  String get status_insufficient_evidence;

  /// No description provided for @status_unsupported.
  ///
  /// In es, this message translates to:
  /// **'Combinación no soportada'**
  String get status_unsupported;

  /// No description provided for @status_invalid_input.
  ///
  /// In es, this message translates to:
  /// **'Entrada fuera de dominio'**
  String get status_invalid_input;

  /// No description provided for @status_internal_error.
  ///
  /// In es, this message translates to:
  /// **'Error interno'**
  String get status_internal_error;

  /// No description provided for @statusInsufficientBody.
  ///
  /// In es, this message translates to:
  /// **'Esta combinación se puede estudiar, pero no calcular con rigor todavía.'**
  String get statusInsufficientBody;

  /// No description provided for @resultsSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen del tratamiento'**
  String get resultsSummary;

  /// No description provided for @resultsHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial térmico'**
  String get resultsHistory;

  /// No description provided for @resultsTransformations.
  ///
  /// In es, this message translates to:
  /// **'Transformación y fases'**
  String get resultsTransformations;

  /// No description provided for @resultsTransformationsNote.
  ///
  /// In es, this message translates to:
  /// **'Fases cristalográficas y microconstituyentes se muestran por separado; nunca se suman entre sí.'**
  String get resultsTransformationsNote;

  /// No description provided for @resultsProperties.
  ///
  /// In es, this message translates to:
  /// **'Propiedades'**
  String get resultsProperties;

  /// No description provided for @resultsMicroscope.
  ///
  /// In es, this message translates to:
  /// **'Microscopio'**
  String get resultsMicroscope;

  /// No description provided for @resultsFoundation.
  ///
  /// In es, this message translates to:
  /// **'Fundamento científico'**
  String get resultsFoundation;

  /// No description provided for @resultsKeepLearning.
  ///
  /// In es, this message translates to:
  /// **'Seguir aprendiendo'**
  String get resultsKeepLearning;

  /// No description provided for @q_phase_fractions.
  ///
  /// In es, this message translates to:
  /// **'Fracciones de fases'**
  String get q_phase_fractions;

  /// No description provided for @q_microconstituent_fractions.
  ///
  /// In es, this message translates to:
  /// **'Microconstituyentes'**
  String get q_microconstituent_fractions;

  /// No description provided for @q_hardness.
  ///
  /// In es, this message translates to:
  /// **'Dureza final'**
  String get q_hardness;

  /// No description provided for @q_grain_size.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de grano'**
  String get q_grain_size;

  /// No description provided for @q_mechanical_properties.
  ///
  /// In es, this message translates to:
  /// **'Propiedades mecánicas'**
  String get q_mechanical_properties;

  /// No description provided for @resultsUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No estimable con la evidencia actual'**
  String get resultsUnavailable;

  /// No description provided for @resultsViewSource.
  ///
  /// In es, this message translates to:
  /// **'Ver fuente y límites'**
  String get resultsViewSource;

  /// No description provided for @resultsWhatsMissing.
  ///
  /// In es, this message translates to:
  /// **'¿Qué datos faltan?'**
  String get resultsWhatsMissing;

  /// No description provided for @resultsWhatsMissingBody.
  ///
  /// In es, this message translates to:
  /// **'Para mostrar una cifra, FERROLAB necesita un dato experimental o un modelo validado para esta condición exacta (material, estado inicial, protocolo publicado, temperatura y tiempo), con fuente, localizador y rango de validez, revisado por una persona con formación metalúrgica.'**
  String get resultsWhatsMissingBody;

  /// No description provided for @evidence_validated.
  ///
  /// In es, this message translates to:
  /// **'Validado'**
  String get evidence_validated;

  /// No description provided for @evidence_bounded_estimate.
  ///
  /// In es, this message translates to:
  /// **'Estimación acotada'**
  String get evidence_bounded_estimate;

  /// No description provided for @evidence_qualitative.
  ///
  /// In es, this message translates to:
  /// **'Cualitativo'**
  String get evidence_qualitative;

  /// No description provided for @evidence_insufficient_evidence.
  ///
  /// In es, this message translates to:
  /// **'Evidencia insuficiente'**
  String get evidence_insufficient_evidence;

  /// No description provided for @evidence_unsupported.
  ///
  /// In es, this message translates to:
  /// **'No soportado'**
  String get evidence_unsupported;

  /// No description provided for @kind_measured.
  ///
  /// In es, this message translates to:
  /// **'Medido'**
  String get kind_measured;

  /// No description provided for @kind_literature.
  ///
  /// In es, this message translates to:
  /// **'Bibliográfico'**
  String get kind_literature;

  /// No description provided for @kind_modeled.
  ///
  /// In es, this message translates to:
  /// **'Modelado'**
  String get kind_modeled;

  /// No description provided for @kind_illustrative.
  ///
  /// In es, this message translates to:
  /// **'Ilustrativo'**
  String get kind_illustrative;

  /// No description provided for @kind_unavailable.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get kind_unavailable;

  /// No description provided for @resultsWarnings.
  ///
  /// In es, this message translates to:
  /// **'Advertencias y limitaciones'**
  String get resultsWarnings;

  /// No description provided for @resultsAssumptions.
  ///
  /// In es, this message translates to:
  /// **'Supuestos'**
  String get resultsAssumptions;

  /// No description provided for @resultsSources.
  ///
  /// In es, this message translates to:
  /// **'Fuentes'**
  String get resultsSources;

  /// No description provided for @resultsVersions.
  ///
  /// In es, this message translates to:
  /// **'Versiones'**
  String get resultsVersions;

  /// No description provided for @resultsProtocol.
  ///
  /// In es, this message translates to:
  /// **'Protocolo'**
  String get resultsProtocol;

  /// No description provided for @resultsSuggestedReading.
  ///
  /// In es, this message translates to:
  /// **'Lectura sugerida'**
  String get resultsSuggestedReading;

  /// No description provided for @resultsSupportsValue.
  ///
  /// In es, this message translates to:
  /// **'Respalda una cifra'**
  String get resultsSupportsValue;

  /// No description provided for @resultsSupportsLimit.
  ///
  /// In es, this message translates to:
  /// **'Respalda un límite'**
  String get resultsSupportsLimit;

  /// No description provided for @sourceUnverified.
  ///
  /// In es, this message translates to:
  /// **'Referencia no verificada por el proyecto'**
  String get sourceUnverified;

  /// No description provided for @sourceVerified.
  ///
  /// In es, this message translates to:
  /// **'Referencia verificada'**
  String get sourceVerified;

  /// No description provided for @resultsSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar en historial'**
  String get resultsSave;

  /// No description provided for @resultsSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardado en este dispositivo'**
  String get resultsSaved;

  /// No description provided for @resultsWhatIf.
  ///
  /// In es, this message translates to:
  /// **'¿Qué pasaría si…?'**
  String get resultsWhatIf;

  /// No description provided for @resultsWhatIfBody.
  ///
  /// In es, this message translates to:
  /// **'Cambia una variable y compara con este resultado.'**
  String get resultsWhatIfBody;

  /// No description provided for @resultsCompare.
  ///
  /// In es, this message translates to:
  /// **'Comparar'**
  String get resultsCompare;

  /// No description provided for @resultsNewRun.
  ///
  /// In es, this message translates to:
  /// **'Nueva prueba'**
  String get resultsNewRun;

  /// No description provided for @resultsCopy.
  ///
  /// In es, this message translates to:
  /// **'Copiar resumen'**
  String get resultsCopy;

  /// No description provided for @resultsCopied.
  ///
  /// In es, this message translates to:
  /// **'Resumen copiado'**
  String get resultsCopied;

  /// No description provided for @resultsEducationalBanner.
  ///
  /// In es, this message translates to:
  /// **'Herramienta educativa, no tratamiento industrial.'**
  String get resultsEducationalBanner;

  /// No description provided for @tutorExplain.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué ocurrió esto?'**
  String get tutorExplain;

  /// No description provided for @tutorTitle.
  ///
  /// In es, this message translates to:
  /// **'Tutor educativo'**
  String get tutorTitle;

  /// No description provided for @tutorEditorialMode.
  ///
  /// In es, this message translates to:
  /// **'Explicación editorial (sin IA)'**
  String get tutorEditorialMode;

  /// No description provided for @tutorAiMode.
  ///
  /// In es, this message translates to:
  /// **'Generado por IA a partir de contexto revisado'**
  String get tutorAiMode;

  /// No description provided for @tutorAskHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe una pregunta conceptual'**
  String get tutorAskHint;

  /// No description provided for @tutorAsk.
  ///
  /// In es, this message translates to:
  /// **'Preguntar'**
  String get tutorAsk;

  /// No description provided for @tutorPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Si el tutor IA está activo, tu pregunta se envía a un proveedor externo. No escribas datos personales.'**
  String get tutorPrivacy;

  /// No description provided for @tutorQuick1.
  ///
  /// In es, this message translates to:
  /// **'¿Qué diferencia hay entre TTT y CCT?'**
  String get tutorQuick1;

  /// No description provided for @tutorQuick2.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué importa la velocidad de enfriamiento?'**
  String get tutorQuick2;

  /// No description provided for @tutorQuick3.
  ///
  /// In es, this message translates to:
  /// **'¿En qué se diferencian martempering y austempering?'**
  String get tutorQuick3;

  /// No description provided for @tutorQuick4.
  ///
  /// In es, this message translates to:
  /// **'¿La fundición gris se comporta como el acero?'**
  String get tutorQuick4;

  /// No description provided for @tutorQuick5.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué no aparece un valor de dureza?'**
  String get tutorQuick5;

  /// No description provided for @microTitle.
  ///
  /// In es, this message translates to:
  /// **'Microestructura'**
  String get microTitle;

  /// No description provided for @microNoMatch.
  ///
  /// In es, this message translates to:
  /// **'Aún no tenemos una micrografía verificada de esta condición.'**
  String get microNoMatch;

  /// No description provided for @microNoMatchBody.
  ///
  /// In es, this message translates to:
  /// **'Para mostrar una micrografía exigimos licencia comprobada, autor, técnica, aumento y que corresponda al material y la condición. No mostramos imágenes de otros aceros como si fueran de este experimento.'**
  String get microNoMatchBody;

  /// No description provided for @microDigitalZoom.
  ///
  /// In es, this message translates to:
  /// **'Zoom digital, no aumento óptico'**
  String get microDigitalZoom;

  /// No description provided for @microZoomIn.
  ///
  /// In es, this message translates to:
  /// **'Acercar'**
  String get microZoomIn;

  /// No description provided for @microZoomOut.
  ///
  /// In es, this message translates to:
  /// **'Alejar'**
  String get microZoomOut;

  /// No description provided for @microScaleCalibrated.
  ///
  /// In es, this message translates to:
  /// **'Barra de escala calibrada: {value} µm'**
  String microScaleCalibrated(Object value);

  /// No description provided for @microScaleMissing.
  ///
  /// In es, this message translates to:
  /// **'Sin calibración: no se permite medir'**
  String get microScaleMissing;

  /// No description provided for @microLibraryEmpty.
  ///
  /// In es, this message translates to:
  /// **'La biblioteca de micrografías está vacía: aún no hay imágenes con licencia y metadatos verificados.'**
  String get microLibraryEmpty;

  /// No description provided for @microAttribution.
  ///
  /// In es, this message translates to:
  /// **'Autor / licencia'**
  String get microAttribution;

  /// No description provided for @learnTitle.
  ///
  /// In es, this message translates to:
  /// **'Aprender'**
  String get learnTitle;

  /// No description provided for @learnGlossary.
  ///
  /// In es, this message translates to:
  /// **'Glosario'**
  String get learnGlossary;

  /// No description provided for @learnConcepts.
  ///
  /// In es, this message translates to:
  /// **'Conceptos'**
  String get learnConcepts;

  /// No description provided for @learnFaq.
  ///
  /// In es, this message translates to:
  /// **'Preguntas frecuentes'**
  String get learnFaq;

  /// No description provided for @learnTreatments.
  ///
  /// In es, this message translates to:
  /// **'Tratamientos'**
  String get learnTreatments;

  /// No description provided for @learnDiagrams.
  ///
  /// In es, this message translates to:
  /// **'Diagramas'**
  String get learnDiagrams;

  /// No description provided for @learnDiagramsBody.
  ///
  /// In es, this message translates to:
  /// **'FERROLAB solo dibuja curvas TTT, CCT o Fe–C a partir de datos digitalizados con fuente y permiso. Todavía no hay ninguno publicado, así que aquí encontrarás la explicación conceptual sin líneas ficticias.'**
  String get learnDiagramsBody;

  /// No description provided for @learnRelated.
  ///
  /// In es, this message translates to:
  /// **'Relacionado'**
  String get learnRelated;

  /// No description provided for @learnSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get learnSearch;

  /// No description provided for @practiceTitle.
  ///
  /// In es, this message translates to:
  /// **'Modo práctica'**
  String get practiceTitle;

  /// No description provided for @practiceIntro.
  ///
  /// In es, this message translates to:
  /// **'Preguntas conceptuales con retroalimentación. No es una calificación oficial y tu progreso queda solo en este dispositivo.'**
  String get practiceIntro;

  /// No description provided for @practiceCorrect.
  ///
  /// In es, this message translates to:
  /// **'¡Correcto!'**
  String get practiceCorrect;

  /// No description provided for @practiceIncorrect.
  ///
  /// In es, this message translates to:
  /// **'No exactamente'**
  String get practiceIncorrect;

  /// No description provided for @practiceScore.
  ///
  /// In es, this message translates to:
  /// **'{correct} de {total} correctas'**
  String practiceScore(Object correct, Object total);

  /// No description provided for @practiceNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente pregunta'**
  String get practiceNext;

  /// No description provided for @practiceRestart.
  ///
  /// In es, this message translates to:
  /// **'Empezar de nuevo'**
  String get practiceRestart;

  /// No description provided for @practiceHypothesis.
  ///
  /// In es, this message translates to:
  /// **'Antes de simular: ¿qué esperas que ocurra?'**
  String get practiceHypothesis;

  /// No description provided for @historyTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial local'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no has guardado simulaciones.'**
  String get historyEmpty;

  /// No description provided for @historyLocalNote.
  ///
  /// In es, this message translates to:
  /// **'Se guarda solo en este dispositivo/navegador. Si borras los datos o cambias de dispositivo, se pierde. No hay sincronización.'**
  String get historyLocalNote;

  /// No description provided for @historyDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar historial local'**
  String get historyDelete;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar todo el historial guardado en este dispositivo?'**
  String get historyDeleteConfirm;

  /// No description provided for @historySelectTwo.
  ///
  /// In es, this message translates to:
  /// **'Selecciona dos simulaciones para comparar'**
  String get historySelectTwo;

  /// No description provided for @compareTitle.
  ///
  /// In es, this message translates to:
  /// **'Comparación'**
  String get compareTitle;

  /// No description provided for @compareNote.
  ///
  /// In es, this message translates to:
  /// **'Solo se comparan magnitudes con la misma unidad y evidencia. Las ausencias se muestran como —.'**
  String get compareNote;

  /// No description provided for @compareDifferent.
  ///
  /// In es, this message translates to:
  /// **'Diferencias'**
  String get compareDifferent;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In es, this message translates to:
  /// **'Reducir movimiento'**
  String get settingsReduceMotion;

  /// No description provided for @settingsSound.
  ///
  /// In es, this message translates to:
  /// **'Sonido'**
  String get settingsSound;

  /// No description provided for @settingsSoundNote.
  ///
  /// In es, this message translates to:
  /// **'Sin sonidos en esta versión.'**
  String get settingsSoundNote;

  /// No description provided for @settingsAchievements.
  ///
  /// In es, this message translates to:
  /// **'Logros'**
  String get settingsAchievements;

  /// No description provided for @settingsAchievementsNote.
  ///
  /// In es, this message translates to:
  /// **'Logros locales y desactivables; no se envían a ningún servidor.'**
  String get settingsAchievementsNote;

  /// No description provided for @settingsTutorial.
  ///
  /// In es, this message translates to:
  /// **'Ver la introducción otra vez'**
  String get settingsTutorial;

  /// No description provided for @settingsPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In es, this message translates to:
  /// **'FERROLAB no te pide cuenta, correo ni datos personales. Tus preferencias, historial, práctica y logros se guardan solo en este dispositivo. El servidor calcula cada simulación y no la almacena.'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsSources.
  ///
  /// In es, this message translates to:
  /// **'Bibliografía y fuentes'**
  String get settingsSources;

  /// No description provided for @settingsAbout.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get settingsAbout;

  /// No description provided for @settingsAdmin.
  ///
  /// In es, this message translates to:
  /// **'Panel de administración'**
  String get settingsAdmin;

  /// No description provided for @settingsNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsNote.
  ///
  /// In es, this message translates to:
  /// **'Desactivadas. FERROLAB no envía recordatorios.'**
  String get settingsNotificationsNote;

  /// No description provided for @sourcesTitle.
  ///
  /// In es, this message translates to:
  /// **'Bibliografía y fuentes'**
  String get sourcesTitle;

  /// No description provided for @sourcesNote.
  ///
  /// In es, this message translates to:
  /// **'Citar una obra no demuestra acceso a su contenido. Las referencias marcadas «no verificada» son lecturas sugeridas y no respaldan ninguna cifra.'**
  String get sourcesNote;

  /// No description provided for @achFirstRun.
  ///
  /// In es, this message translates to:
  /// **'Primer experimento'**
  String get achFirstRun;

  /// No description provided for @achAllMaterials.
  ///
  /// In es, this message translates to:
  /// **'Exploraste los tres materiales'**
  String get achAllMaterials;

  /// No description provided for @achAllTreatments.
  ///
  /// In es, this message translates to:
  /// **'Probaste los seis tratamientos'**
  String get achAllTreatments;

  /// No description provided for @achPractice.
  ///
  /// In es, this message translates to:
  /// **'Cinco respuestas correctas en práctica'**
  String get achPractice;

  /// No description provided for @achHonest.
  ///
  /// In es, this message translates to:
  /// **'Encontraste un límite de la evidencia'**
  String get achHonest;

  /// No description provided for @achUnlocked.
  ///
  /// In es, this message translates to:
  /// **'Logro desbloqueado: {name}'**
  String achUnlocked(Object name);

  /// No description provided for @teacherTitle.
  ///
  /// In es, this message translates to:
  /// **'Modo docente'**
  String get teacherTitle;

  /// No description provided for @teacherIntro.
  ///
  /// In es, this message translates to:
  /// **'Crea un código de actividad con una configuración fija. Los estudiantes lo introducen sin cuenta ni datos personales. Un código no es una contraseña ni autentica a nadie.'**
  String get teacherIntro;

  /// No description provided for @teacherCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear código con la configuración actual'**
  String get teacherCreate;

  /// No description provided for @teacherCode.
  ///
  /// In es, this message translates to:
  /// **'Código de actividad'**
  String get teacherCode;

  /// No description provided for @teacherEnter.
  ///
  /// In es, this message translates to:
  /// **'Introducir un código'**
  String get teacherEnter;

  /// No description provided for @teacherLoad.
  ///
  /// In es, this message translates to:
  /// **'Cargar actividad'**
  String get teacherLoad;

  /// No description provided for @teacherInvalid.
  ///
  /// In es, this message translates to:
  /// **'Código no válido'**
  String get teacherInvalid;

  /// No description provided for @teacherNoConfig.
  ///
  /// In es, this message translates to:
  /// **'Primero configura una simulación (material y tratamiento).'**
  String get teacherNoConfig;

  /// No description provided for @teacherPresentation.
  ///
  /// In es, this message translates to:
  /// **'Modo presentación'**
  String get teacherPresentation;

  /// No description provided for @networkError.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión al motor. Tu configuración sigue aquí.'**
  String get networkError;

  /// No description provided for @networkRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get networkRetry;

  /// No description provided for @internalError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar esta solicitud.'**
  String get internalError;

  /// No description provided for @supportCode.
  ///
  /// In es, this message translates to:
  /// **'Código de soporte: {code}'**
  String supportCode(Object code);

  /// No description provided for @rateLimited.
  ///
  /// In es, this message translates to:
  /// **'Demasiadas solicitudes; espera un momento e inténtalo de nuevo.'**
  String get rateLimited;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get loading;

  /// No description provided for @adminTitle.
  ///
  /// In es, this message translates to:
  /// **'FERROLAB Admin'**
  String get adminTitle;

  /// No description provided for @adminLogin.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get adminLogin;

  /// No description provided for @adminEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get adminEmail;

  /// No description provided for @adminPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get adminPassword;

  /// No description provided for @adminDevToken.
  ///
  /// In es, this message translates to:
  /// **'Token de desarrollo'**
  String get adminDevToken;

  /// No description provided for @adminDevTokenHint.
  ///
  /// In es, this message translates to:
  /// **'Solo en desarrollo local: pega el token generado con scripts/dev_admin_token.py'**
  String get adminDevTokenHint;

  /// No description provided for @adminNotConfigured.
  ///
  /// In es, this message translates to:
  /// **'La administración no está disponible: el servidor no tiene base de datos o autenticación configurada.'**
  String get adminNotConfigured;

  /// No description provided for @adminLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get adminLogout;

  /// No description provided for @adminRecords.
  ///
  /// In es, this message translates to:
  /// **'Registros'**
  String get adminRecords;

  /// No description provided for @adminReleases.
  ///
  /// In es, this message translates to:
  /// **'Publicaciones'**
  String get adminReleases;

  /// No description provided for @adminAudit.
  ///
  /// In es, this message translates to:
  /// **'Auditoría'**
  String get adminAudit;

  /// No description provided for @adminRole.
  ///
  /// In es, this message translates to:
  /// **'Rol: {role}'**
  String adminRole(Object role);

  /// No description provided for @adminReview.
  ///
  /// In es, this message translates to:
  /// **'Marcar como revisado'**
  String get adminReview;

  /// No description provided for @adminToDraft.
  ///
  /// In es, this message translates to:
  /// **'Volver a borrador'**
  String get adminToDraft;

  /// No description provided for @adminRetire.
  ///
  /// In es, this message translates to:
  /// **'Retirar'**
  String get adminRetire;

  /// No description provided for @adminSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar borrador'**
  String get adminSave;

  /// No description provided for @adminSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardado como borrador'**
  String get adminSaved;

  /// No description provided for @adminNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo registro'**
  String get adminNew;

  /// No description provided for @adminPreview.
  ///
  /// In es, this message translates to:
  /// **'Comprobar publicación'**
  String get adminPreview;

  /// No description provided for @adminPublish.
  ///
  /// In es, this message translates to:
  /// **'Publicar versión'**
  String get adminPublish;

  /// No description provided for @adminActivate.
  ///
  /// In es, this message translates to:
  /// **'Activar (revertir a esta)'**
  String get adminActivate;

  /// No description provided for @adminVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión (p. ej. 1.0.0)'**
  String get adminVersion;

  /// No description provided for @adminActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get adminActive;

  /// No description provided for @adminProblems.
  ///
  /// In es, this message translates to:
  /// **'Problemas que bloquean la publicación'**
  String get adminProblems;

  /// No description provided for @adminReport.
  ///
  /// In es, this message translates to:
  /// **'Informe'**
  String get adminReport;

  /// No description provided for @adminReviewWarning.
  ///
  /// In es, this message translates to:
  /// **'Revisar significa que una persona con formación metalúrgica comprobó la fuente, el localizador, las unidades y el dominio. No lo marques si no lo hiciste.'**
  String get adminReviewWarning;

  /// No description provided for @adminJsonField.
  ///
  /// In es, this message translates to:
  /// **'(JSON)'**
  String get adminJsonField;

  /// No description provided for @settingsServer.
  ///
  /// In es, this message translates to:
  /// **'Servidor de FERROLAB'**
  String get settingsServer;

  /// No description provided for @settingsServerHint.
  ///
  /// In es, this message translates to:
  /// **'p. ej. http://192.168.1.20:8000'**
  String get settingsServerHint;

  /// No description provided for @settingsServerSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar y probar'**
  String get settingsServerSave;

  /// No description provided for @settingsServerReset.
  ///
  /// In es, this message translates to:
  /// **'Usar el predeterminado'**
  String get settingsServerReset;

  /// No description provided for @settingsServerOk.
  ///
  /// In es, this message translates to:
  /// **'Conectado: {version}'**
  String settingsServerOk(Object version);

  /// No description provided for @settingsServerInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe una dirección que empiece por http:// o https://'**
  String get settingsServerInvalid;

  /// No description provided for @settingsServerCurrent.
  ///
  /// In es, this message translates to:
  /// **'Dirección actual: {url}'**
  String settingsServerCurrent(Object url);

  /// No description provided for @settingsServerNote.
  ///
  /// In es, this message translates to:
  /// **'La app necesita el servidor de FERROLAB para calcular. En tu casa puedes usar tu computadora en la misma Wi‑Fi (http://IP:8000). Las direcciones http:// no van cifradas: úsalas solo en tu red local.'**
  String get settingsServerNote;

  /// No description provided for @homeConfigureServer.
  ///
  /// In es, this message translates to:
  /// **'Configurar servidor'**
  String get homeConfigureServer;

  /// No description provided for @recTitle.
  ///
  /// In es, this message translates to:
  /// **'Práctica recomendada'**
  String get recTitle;

  /// No description provided for @recUse.
  ///
  /// In es, this message translates to:
  /// **'Usar valores recomendados'**
  String get recUse;

  /// No description provided for @recOutsideTemp.
  ///
  /// In es, this message translates to:
  /// **'Esta temperatura está fuera de lo recomendado por la literatura: es una mala práctica. Puedes simularla para ver qué pasa, pero el resultado lo advertirá.'**
  String get recOutsideTemp;

  /// No description provided for @recOutsideHold.
  ///
  /// In es, this message translates to:
  /// **'Este tiempo está fuera de lo recomendado.'**
  String get recOutsideHold;

  /// No description provided for @recNoNumber.
  ///
  /// In es, this message translates to:
  /// **'la fuente no da cifra'**
  String get recNoNumber;

  /// No description provided for @recBath.
  ///
  /// In es, this message translates to:
  /// **'Baño'**
  String get recBath;

  /// No description provided for @constFerrite.
  ///
  /// In es, this message translates to:
  /// **'Ferrita proeutectoide'**
  String get constFerrite;

  /// No description provided for @constPearlite.
  ///
  /// In es, this message translates to:
  /// **'Perlita'**
  String get constPearlite;

  /// No description provided for @constBainite.
  ///
  /// In es, this message translates to:
  /// **'Bainita'**
  String get constBainite;

  /// No description provided for @constMartensite.
  ///
  /// In es, this message translates to:
  /// **'Martensita'**
  String get constMartensite;

  /// No description provided for @constTemperedMartensite.
  ///
  /// In es, this message translates to:
  /// **'Martensita revenida'**
  String get constTemperedMartensite;

  /// No description provided for @constRetained.
  ///
  /// In es, this message translates to:
  /// **'Austenita retenida'**
  String get constRetained;

  /// No description provided for @constGraphite.
  ///
  /// In es, this message translates to:
  /// **'Grafito en láminas (tipo A)'**
  String get constGraphite;

  /// No description provided for @phaseFerrite.
  ///
  /// In es, this message translates to:
  /// **'Ferrita (α)'**
  String get phaseFerrite;

  /// No description provided for @phaseCementite.
  ///
  /// In es, this message translates to:
  /// **'Cementita (Fe₃C)'**
  String get phaseCementite;

  /// No description provided for @phaseAustenite.
  ///
  /// In es, this message translates to:
  /// **'Austenita (γ)'**
  String get phaseAustenite;

  /// No description provided for @grayMatrixPearlite.
  ///
  /// In es, this message translates to:
  /// **'Matriz perlítica'**
  String get grayMatrixPearlite;

  /// No description provided for @grayMatrixFerritePearlite.
  ///
  /// In es, this message translates to:
  /// **'Matriz ferrito-perlítica'**
  String get grayMatrixFerritePearlite;

  /// No description provided for @grayMatrixMartensite.
  ///
  /// In es, this message translates to:
  /// **'Matriz martensítica'**
  String get grayMatrixMartensite;

  /// No description provided for @grayMatrixTempered.
  ///
  /// In es, this message translates to:
  /// **'Matriz de martensita revenida'**
  String get grayMatrixTempered;

  /// No description provided for @grayMatrixAusferrite.
  ///
  /// In es, this message translates to:
  /// **'Matriz ausferrítica'**
  String get grayMatrixAusferrite;

  /// No description provided for @microGeneratedTitle.
  ///
  /// In es, this message translates to:
  /// **'Microestructura generada'**
  String get microGeneratedTitle;

  /// No description provided for @microGeneratedNote.
  ///
  /// In es, this message translates to:
  /// **'Ilustración GENERADA por FERROLAB a partir de las fracciones calculadas por el modelo (centro de la probeta). No es una micrografía real: sirve para reconocer los constituyentes.'**
  String get microGeneratedNote;

  /// No description provided for @microGesture.
  ///
  /// In es, this message translates to:
  /// **'Pellizca o usa la rueda del ratón para acercar; arrastra para recorrer la muestra.'**
  String get microGesture;

  /// No description provided for @microReset.
  ///
  /// In es, this message translates to:
  /// **'Volver al aumento inicial'**
  String get microReset;

  /// No description provided for @microRealTitle.
  ///
  /// In es, this message translates to:
  /// **'Micrografía real con licencia'**
  String get microRealTitle;

  /// No description provided for @microQualitative.
  ///
  /// In es, this message translates to:
  /// **'Fundición gris: matriz y grafito cualitativos (sin fracciones calculadas).'**
  String get microQualitative;

  /// No description provided for @microUnchanged.
  ///
  /// In es, this message translates to:
  /// **'No hubo austenización: la microestructura de partida no cambia y no se dibuja una nueva.'**
  String get microUnchanged;

  /// No description provided for @microOpen.
  ///
  /// In es, this message translates to:
  /// **'Abrir el microscopio'**
  String get microOpen;

  /// No description provided for @diagTitle.
  ///
  /// In es, this message translates to:
  /// **'Diagramas TTT y CCT de tu práctica'**
  String get diagTitle;

  /// No description provided for @diagTtt.
  ///
  /// In es, this message translates to:
  /// **'TTT'**
  String get diagTtt;

  /// No description provided for @diagCct.
  ///
  /// In es, this message translates to:
  /// **'CCT'**
  String get diagCct;

  /// No description provided for @diagTttNote.
  ///
  /// In es, this message translates to:
  /// **'TTT: tiempo para empezar (1 %) y terminar (99 %) cada transformación si la temperatura se mantiene constante. Tu curva muestra el enfriamiento real del centro de la probeta.'**
  String get diagTttNote;

  /// No description provided for @diagCctNote.
  ///
  /// In es, this message translates to:
  /// **'CCT: inicio de cada transformación en enfriamiento continuo a velocidades constantes. Donde tu curva cruza una zona, se forma ese constituyente.'**
  String get diagCctNote;

  /// No description provided for @diagYourPath.
  ///
  /// In es, this message translates to:
  /// **'Tu práctica (centro)'**
  String get diagYourPath;

  /// No description provided for @diagAxes.
  ///
  /// In es, this message translates to:
  /// **'Eje x: tiempo desde el inicio del enfriamiento (s, escala logarítmica). Eje y: temperatura (°C). Modelo de Li et al. (1998), composición nominal, G ASTM 7.'**
  String get diagAxes;

  /// No description provided for @diagTable.
  ///
  /// In es, this message translates to:
  /// **'Ver datos del diagrama'**
  String get diagTable;

  /// No description provided for @modelTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalles de la estimación'**
  String get modelTitle;

  /// No description provided for @modelLabel.
  ///
  /// In es, this message translates to:
  /// **'Estimación por modelos empíricos publicados; no revisada por un especialista.'**
  String get modelLabel;

  /// No description provided for @modelCritical.
  ///
  /// In es, this message translates to:
  /// **'Temperaturas críticas (calculadas)'**
  String get modelCritical;

  /// No description provided for @modelComposition.
  ///
  /// In es, this message translates to:
  /// **'Composición nominal usada (% en masa)'**
  String get modelComposition;

  /// No description provided for @modelSurface.
  ///
  /// In es, this message translates to:
  /// **'Superficie de la probeta'**
  String get modelSurface;

  /// No description provided for @modelPrior.
  ///
  /// In es, this message translates to:
  /// **'Estado templado de partida (calculado con la práctica recomendada de temple)'**
  String get modelPrior;

  /// No description provided for @modelSpecimen.
  ///
  /// In es, this message translates to:
  /// **'Probeta de referencia: cilindro de 12,7 mm, resultados en el centro.'**
  String get modelSpecimen;

  /// No description provided for @factBand.
  ///
  /// In es, this message translates to:
  /// **'Banda de incertidumbre'**
  String get factBand;

  /// No description provided for @recTemperature.
  ///
  /// In es, this message translates to:
  /// **'Temperatura: {range}'**
  String recTemperature(String range);

  /// No description provided for @recHold.
  ///
  /// In es, this message translates to:
  /// **'Mantenimiento: {range}'**
  String recHold(String range);

  /// No description provided for @recMedium.
  ///
  /// In es, this message translates to:
  /// **'Medio de enfriamiento: {medium}'**
  String recMedium(String medium);

  /// No description provided for @recSources.
  ///
  /// In es, this message translates to:
  /// **'Fuentes: {sources}'**
  String recSources(String sources);

  /// No description provided for @microMagnification.
  ///
  /// In es, this message translates to:
  /// **'≈ {x}× en pantalla'**
  String microMagnification(String x);

  /// No description provided for @diagPoint.
  ///
  /// In es, this message translates to:
  /// **'Tu práctica: t = {time} · {temp} °C'**
  String diagPoint(String time, String temp);

  /// No description provided for @diagNose.
  ///
  /// In es, this message translates to:
  /// **'nariz: {time} a {temp} °C'**
  String diagNose(String time, String temp);

  /// No description provided for @modelCooling.
  ///
  /// In es, this message translates to:
  /// **'Velocidad de enfriamiento a 700 °C: {rate} °C/s'**
  String modelCooling(String rate);

  /// No description provided for @modelBath.
  ///
  /// In es, this message translates to:
  /// **'Temperatura del baño (modelo): {temp} °C'**
  String modelBath(String temp);

  /// No description provided for @modelAustenite.
  ///
  /// In es, this message translates to:
  /// **'Austenita formada en el mantenimiento: {pct} %'**
  String modelAustenite(String pct);

  /// No description provided for @factBandValue.
  ///
  /// In es, this message translates to:
  /// **'{lo} – {hi}'**
  String factBandValue(String lo, String hi);

  /// No description provided for @mediumWater.
  ///
  /// In es, this message translates to:
  /// **'agua'**
  String get mediumWater;

  /// No description provided for @mediumOil.
  ///
  /// In es, this message translates to:
  /// **'aceite'**
  String get mediumOil;

  /// No description provided for @mediumAir.
  ///
  /// In es, this message translates to:
  /// **'aire en calma'**
  String get mediumAir;

  /// No description provided for @mediumFurnace.
  ///
  /// In es, this message translates to:
  /// **'horno'**
  String get mediumFurnace;

  /// No description provided for @mediumSaltBath.
  ///
  /// In es, this message translates to:
  /// **'baño de sales'**
  String get mediumSaltBath;

  /// No description provided for @reviewExpectModel.
  ///
  /// In es, this message translates to:
  /// **'Se calcularán ESTIMACIONES de modelos publicados: fases, constituyentes, dureza y diagramas TTT/CCT de tu práctica. Irán etiquetadas como estimaciones (no mediciones).'**
  String get reviewExpectModel;

  /// No description provided for @microLabelsToggle.
  ///
  /// In es, this message translates to:
  /// **'Señalar microconstituyentes'**
  String get microLabelsToggle;

  /// No description provided for @microLabelsZoomHint.
  ///
  /// In es, this message translates to:
  /// **'Las flechas se muestran en el aumento base: pulsa «Volver al aumento inicial».'**
  String get microLabelsZoomHint;

  /// No description provided for @microLabelRetained.
  ///
  /// In es, this message translates to:
  /// **'Austenita retenida (islas blancas)'**
  String get microLabelRetained;

  /// No description provided for @levelA.
  ///
  /// In es, this message translates to:
  /// **'A · Cálculo con modelos publicados (pendiente de validación por especialista)'**
  String get levelA;

  /// No description provided for @levelB.
  ///
  /// In es, this message translates to:
  /// **'B · Interpretación cualitativa fundamentada'**
  String get levelB;

  /// No description provided for @levelC.
  ///
  /// In es, this message translates to:
  /// **'C · Demostración educativa ilustrativa'**
  String get levelC;

  /// No description provided for @lpLimitations.
  ///
  /// In es, this message translates to:
  /// **'Fundamento científico y limitaciones'**
  String get lpLimitations;

  /// No description provided for @groupInput.
  ///
  /// In es, this message translates to:
  /// **'Tus parámetros'**
  String get groupInput;

  /// No description provided for @groupDependency.
  ///
  /// In es, this message translates to:
  /// **'Estado previo'**
  String get groupDependency;

  /// No description provided for @groupProtocol.
  ///
  /// In es, this message translates to:
  /// **'Protocolo'**
  String get groupProtocol;

  /// No description provided for @groupEvidence.
  ///
  /// In es, this message translates to:
  /// **'Evidencia'**
  String get groupEvidence;

  /// No description provided for @groupModel.
  ///
  /// In es, this message translates to:
  /// **'Modelo'**
  String get groupModel;

  /// No description provided for @groupReview.
  ///
  /// In es, this message translates to:
  /// **'Revisión'**
  String get groupReview;

  /// No description provided for @groupOther.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get groupOther;

  /// No description provided for @lpReference.
  ///
  /// In es, this message translates to:
  /// **'Referencia'**
  String get lpReference;

  /// No description provided for @lpVerified.
  ///
  /// In es, this message translates to:
  /// **'Fuente verificada'**
  String get lpVerified;

  /// No description provided for @lpUnverified.
  ///
  /// In es, this message translates to:
  /// **'Fuente no verificada por FERROLAB'**
  String get lpUnverified;

  /// No description provided for @lpProtocols.
  ///
  /// In es, this message translates to:
  /// **'Protocolos disponibles'**
  String get lpProtocols;

  /// No description provided for @lpUseProtocol.
  ///
  /// In es, this message translates to:
  /// **'Usar protocolo recomendado'**
  String get lpUseProtocol;

  /// No description provided for @lpParams.
  ///
  /// In es, this message translates to:
  /// **'Parámetros del protocolo'**
  String get lpParams;

  /// No description provided for @pFurnace.
  ///
  /// In es, this message translates to:
  /// **'Temperatura del horno'**
  String get pFurnace;

  /// No description provided for @pHold.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de sostenimiento'**
  String get pHold;

  /// No description provided for @pBath.
  ///
  /// In es, this message translates to:
  /// **'Temperatura del baño'**
  String get pBath;

  /// No description provided for @pBathTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo en el baño'**
  String get pBathTime;

  /// No description provided for @pBathEqualize.
  ///
  /// In es, this message translates to:
  /// **'Vacío = hasta igualar la temperatura (calculado)'**
  String get pBathEqualize;

  /// No description provided for @pOutside.
  ///
  /// In es, this message translates to:
  /// **'Fuera del intervalo documentado para este protocolo.'**
  String get pOutside;

  /// No description provided for @pMediumLocked.
  ///
  /// In es, this message translates to:
  /// **'Medio de enfriamiento (fijado por el protocolo)'**
  String get pMediumLocked;

  /// No description provided for @lpSequence.
  ///
  /// In es, this message translates to:
  /// **'Secuencia térmica'**
  String get lpSequence;

  /// No description provided for @lpSheet.
  ///
  /// In es, this message translates to:
  /// **'Ficha científica del protocolo'**
  String get lpSheet;

  /// No description provided for @lpObjective.
  ///
  /// In es, this message translates to:
  /// **'Objetivo'**
  String get lpObjective;

  /// No description provided for @lpCondition.
  ///
  /// In es, this message translates to:
  /// **'Condición del material'**
  String get lpCondition;

  /// No description provided for @lpExpected.
  ///
  /// In es, this message translates to:
  /// **'Resultado esperado'**
  String get lpExpected;

  /// No description provided for @lpRestrictions.
  ///
  /// In es, this message translates to:
  /// **'Condiciones y restricciones'**
  String get lpRestrictions;

  /// No description provided for @lpAssumptions.
  ///
  /// In es, this message translates to:
  /// **'Supuestos'**
  String get lpAssumptions;

  /// No description provided for @lpMissing.
  ///
  /// In es, this message translates to:
  /// **'Lo que falta investigar'**
  String get lpMissing;

  /// No description provided for @lpPublished.
  ///
  /// In es, this message translates to:
  /// **'Resultados publicados del caso (medidos, no predichos)'**
  String get lpPublished;

  /// No description provided for @lpSources.
  ///
  /// In es, this message translates to:
  /// **'Fuentes'**
  String get lpSources;

  /// No description provided for @lpPrior.
  ///
  /// In es, this message translates to:
  /// **'Estado de partida del revenido'**
  String get lpPrior;

  /// No description provided for @priorReference.
  ///
  /// In es, this message translates to:
  /// **'Templada de referencia'**
  String get priorReference;

  /// No description provided for @priorHistory.
  ///
  /// In es, this message translates to:
  /// **'De mi historial'**
  String get priorHistory;

  /// No description provided for @priorTheory.
  ///
  /// In es, this message translates to:
  /// **'Solo teoría'**
  String get priorTheory;

  /// No description provided for @priorHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay temples de este material en tu historial (guárdalos desde Resultados).'**
  String get priorHistoryEmpty;

  /// No description provided for @seqAmbient.
  ///
  /// In es, this message translates to:
  /// **'ambiente'**
  String get seqAmbient;

  /// No description provided for @seqUntilEqualized.
  ///
  /// In es, this message translates to:
  /// **'hasta igualar'**
  String get seqUntilEqualized;

  /// No description provided for @seqStart.
  ///
  /// In es, this message translates to:
  /// **'Inicio del conteo'**
  String get seqStart;

  /// No description provided for @lpMaterialPanel.
  ///
  /// In es, this message translates to:
  /// **'Material'**
  String get lpMaterialPanel;

  /// No description provided for @lpComposition.
  ///
  /// In es, this message translates to:
  /// **'Composición de referencia (% en masa)'**
  String get lpComposition;

  /// No description provided for @lpCompositionNone.
  ///
  /// In es, this message translates to:
  /// **'La norma no fija composición: comprueba la de tu pieza.'**
  String get lpCompositionNone;

  /// No description provided for @lpTreatmentPanel.
  ///
  /// In es, this message translates to:
  /// **'Tratamiento'**
  String get lpTreatmentPanel;

  /// No description provided for @basisSource.
  ///
  /// In es, this message translates to:
  /// **'Dato de la fuente'**
  String get basisSource;

  /// No description provided for @basisRule.
  ///
  /// In es, this message translates to:
  /// **'Regla publicada aplicada a la probeta de 12,7 mm'**
  String get basisRule;

  /// No description provided for @basisModel.
  ///
  /// In es, this message translates to:
  /// **'Calculado con el modelo (no publicado)'**
  String get basisModel;

  /// No description provided for @basisPending.
  ///
  /// In es, this message translates to:
  /// **'la fuente no da cifra'**
  String get basisPending;

  /// No description provided for @basisComputed.
  ///
  /// In es, this message translates to:
  /// **'Calculado por el modelo térmico'**
  String get basisComputed;

  /// No description provided for @goalReference.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get goalReference;

  /// No description provided for @goalHardness.
  ///
  /// In es, this message translates to:
  /// **'Orientado a dureza'**
  String get goalHardness;

  /// No description provided for @goalToughness.
  ///
  /// In es, this message translates to:
  /// **'Orientado a tenacidad'**
  String get goalToughness;

  /// No description provided for @goalSoftening.
  ///
  /// In es, this message translates to:
  /// **'Ablandamiento'**
  String get goalSoftening;

  /// No description provided for @goalStressRelief.
  ///
  /// In es, this message translates to:
  /// **'Alivio de tensiones'**
  String get goalStressRelief;

  /// No description provided for @goalExperimental.
  ///
  /// In es, this message translates to:
  /// **'Caso experimental'**
  String get goalExperimental;

  /// No description provided for @goalMachinability.
  ///
  /// In es, this message translates to:
  /// **'Maquinabilidad'**
  String get goalMachinability;

  /// No description provided for @goalPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get goalPending;

  /// No description provided for @mediumTinBath.
  ///
  /// In es, this message translates to:
  /// **'baño de estaño'**
  String get mediumTinBath;

  /// No description provided for @furnaceBathScene.
  ///
  /// In es, this message translates to:
  /// **'Baño isotérmico'**
  String get furnaceBathScene;

  /// No description provided for @lpLimitationsCount.
  ///
  /// In es, this message translates to:
  /// **'{n} avisos agrupados por causa'**
  String lpLimitationsCount(String n);

  /// No description provided for @pRange.
  ///
  /// In es, this message translates to:
  /// **'Intervalo documentado: {range}'**
  String pRange(String range);

  /// No description provided for @pRef.
  ///
  /// In es, this message translates to:
  /// **'Referencia: {v}'**
  String pRef(String v);

  /// No description provided for @lpProtocol.
  ///
  /// In es, this message translates to:
  /// **'Protocolo'**
  String get lpProtocol;

  /// No description provided for @microQualitativeNote.
  ///
  /// In es, this message translates to:
  /// **'Ilustración CUALITATIVA: matriz y grafito según lo que describe la fuente para este tratamiento. No hay fracciones calculadas ni es una micrografía real.'**
  String get microQualitativeNote;

  /// No description provided for @microReasonNoAustenitization.
  ///
  /// In es, this message translates to:
  /// **'No hubo austenización: la microestructura de partida no cambia y no se dibuja una nueva.'**
  String get microReasonNoAustenitization;

  /// No description provided for @microReasonOutsideRange.
  ///
  /// In es, this message translates to:
  /// **'No se dibuja: la práctica está fuera del protocolo documentado y en modo exploración no se calculan fracciones. Vuelve al valor de referencia para ver la microestructura.'**
  String get microReasonOutsideRange;

  /// No description provided for @microReasonCarburized.
  ///
  /// In es, this message translates to:
  /// **'No se dibuja: la capa cementada no se modela, así que no hay fracciones de la capa que representar.'**
  String get microReasonCarburized;

  /// No description provided for @microReasonNotModeled.
  ///
  /// In es, this message translates to:
  /// **'No se dibuja: FERROLAB no tiene un modelo para esta transformación (p. ej. globulización subcrítica). Consulta el resultado esperado en la ficha del protocolo.'**
  String get microReasonNotModeled;

  /// No description provided for @microReasonUnverified.
  ///
  /// In es, this message translates to:
  /// **'No se dibuja: la variante tiene una fuente no verificada y no se calculan fracciones.'**
  String get microReasonUnverified;

  /// No description provided for @microReasonTheory.
  ///
  /// In es, this message translates to:
  /// **'No se dibuja: en modo «solo teoría» no hay estado templado de partida.'**
  String get microReasonTheory;

  /// No description provided for @microReasonInvalid.
  ///
  /// In es, this message translates to:
  /// **'No se dibuja: corrige la entrada para continuar.'**
  String get microReasonInvalid;

  /// No description provided for @microReasonNotComputed.
  ///
  /// In es, this message translates to:
  /// **'No se dibuja: no hay fracciones calculadas para esta práctica.'**
  String get microReasonNotComputed;

  /// No description provided for @settingsVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get settingsVersion;

  /// No description provided for @settingsAppVersion.
  ///
  /// In es, this message translates to:
  /// **'App instalada'**
  String get settingsAppVersion;

  /// No description provided for @settingsEngineVersion.
  ///
  /// In es, this message translates to:
  /// **'Motor del servidor'**
  String get settingsEngineVersion;

  /// No description provided for @settingsDatasetVersion.
  ///
  /// In es, this message translates to:
  /// **'Catálogo científico'**
  String get settingsDatasetVersion;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
