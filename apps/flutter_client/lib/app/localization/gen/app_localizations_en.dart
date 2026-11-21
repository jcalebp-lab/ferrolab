// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FERROLAB';

  @override
  String get appSubtitle => 'Virtual Heat Treatment Laboratory';

  @override
  String get welcomeHeadline => 'Understand how heat transforms metals.';

  @override
  String get welcomeBody =>
      'Explore heat treatments with educational simulations and find out what we really know about each result.';

  @override
  String get welcomeStart => 'Get started';

  @override
  String get welcomeSkip => 'Skip introduction';

  @override
  String get welcomeFree => 'Free · No account · No ads';

  @override
  String get onbStep1Title => '1. Choose material and treatment';

  @override
  String get onbStep1Body =>
      'Three real materials and six treatments. Not every combination is supported: FERROLAB tells you why.';

  @override
  String get onbStep2Title => '2. Configure and run';

  @override
  String get onbStep2Body =>
      'You control temperature and holding time. Cooling is set by the protocol.';

  @override
  String get onbStep3Title => '3. Interpret with evidence';

  @override
  String get onbStep3Body =>
      'Each result shows its source and evidence level. If there is no data, you will see it clearly.';

  @override
  String get next => 'Next';

  @override
  String get continueLabel => 'Continue';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get homeGreeting => 'What shall we explore today?';

  @override
  String get homeHero => 'Understand what heat changes in metals';

  @override
  String get homeLabTitle => 'Virtual laboratory';

  @override
  String get homeLabBody =>
      'Choose material and treatment, set the furnace and analyze the result.';

  @override
  String get homeStart => 'Start simulation';

  @override
  String get homeLearn => 'Learn';

  @override
  String get homeMicro => 'Explore microstructures';

  @override
  String get homePractice => 'Practice mode';

  @override
  String get homeHistory => 'My history';

  @override
  String get homeTeacher => 'Teachers';

  @override
  String get homeBanner =>
      'Educational tool. Properties depend on real data and conditions.';

  @override
  String get homeLastSession => 'Last simulation';

  @override
  String get settings => 'Settings';

  @override
  String stepOf(Object step, Object total) {
    return 'Step $step of $total';
  }

  @override
  String get materialTitle => 'Choose a material';

  @override
  String get materialSteel => 'Steel';

  @override
  String get materialCastIron => 'Gray cast iron';

  @override
  String get materialViewSheet => 'View sheet';

  @override
  String get materialNoComposition => 'No verified composition ranges loaded.';

  @override
  String get materialInitialCondition => 'Initial condition';

  @override
  String get materialLimitations => 'Limitations';

  @override
  String get materialSuggestedReading => 'Suggested reading (unverified)';

  @override
  String get treatmentTitle => 'Choose a heat treatment';

  @override
  String get treatmentWhyNot => 'Learn why';

  @override
  String get compat_supported => 'Supported by protocol';

  @override
  String get compat_conditional => 'Conditional';

  @override
  String get compat_educational_only => 'Learning only';

  @override
  String get compat_unsupported => 'Unsupported';

  @override
  String get treatmentPrerequisites => 'Prerequisites';

  @override
  String get treatmentStages => 'Process stages';

  @override
  String get paramsTitle => 'Configure your experiment';

  @override
  String get paramsYouControl => 'What you control';

  @override
  String get paramsHold => 'Holding time';

  @override
  String get paramsMinutes => 'minutes';

  @override
  String get paramsRangeUnpublished =>
      'Valid protocol range: not documented yet';

  @override
  String paramsPhysicalLimit(Object limit) {
    return 'Physical safety limit: $limit °C (melting)';
  }

  @override
  String get protocolMedium => 'Medium';

  @override
  String get paramsReview => 'Review configuration';

  @override
  String get paramsInvalidNumber => 'Enter a valid number';

  @override
  String get paramsOutOfUi => 'Outside the interface range';

  @override
  String get reviewTitle => 'Your experiment';

  @override
  String get reviewMaterial => 'Material';

  @override
  String get reviewTreatment => 'Treatment';

  @override
  String get reviewTemperature => 'Temperature';

  @override
  String get reviewTime => 'Time';

  @override
  String get reviewInitial => 'Initial state';

  @override
  String get reviewCooling => 'Cooling';

  @override
  String get reviewAutomatic => 'Automatic';

  @override
  String get reviewHeadsUp => 'Before you start';

  @override
  String get reviewExpectInsufficient =>
      'With current evidence there will be no hardness or phase numbers for this condition; you will see the cycle, the explanation and the sources.';

  @override
  String get reviewStart => 'Start laboratory';

  @override
  String get reviewEdit => 'Edit';

  @override
  String get reviewBlocked => 'Cannot run with these parameters';

  @override
  String get validating => 'Validating…';

  @override
  String get furnaceTitle => 'Laboratory';

  @override
  String get furnaceStage => 'Stage';

  @override
  String get furnaceTemp => 'Temperature';

  @override
  String get furnacePhysicalTime => 'Simulated process time';

  @override
  String get furnaceAnimTime => 'Animation time';

  @override
  String furnaceSpeed(Object factor) {
    return 'Playback: $factor×';
  }

  @override
  String get furnaceSchematicSpeed => 'Schematic playback (not to scale)';

  @override
  String get furnaceVisualDisclaimer => 'Workpiece color is illustrative';

  @override
  String get furnacePlay => 'Play';

  @override
  String get furnacePause => 'Pause';

  @override
  String get furnaceRestart => 'Replay';

  @override
  String get furnaceSkip => 'Skip to end';

  @override
  String get furnaceSeeResults => 'See results';

  @override
  String furnaceYourTarget(Object value) {
    return '$value °C (your target)';
  }

  @override
  String furnaceYourHold(Object value) {
    return '$value min (your value)';
  }

  @override
  String get furnaceAmbient => 'Room temperature';

  @override
  String get furnaceBath => 'Bath (temperature not published)';

  @override
  String get furnaceDurationUnpublished => 'Duration not published';

  @override
  String get furnaceReducedMotion =>
      'Reduced motion: stages shown without animation.';

  @override
  String get furnaceRunning => 'Computing with the scientific engine…';

  @override
  String get chartTitle => 'Temperature vs. time';

  @override
  String get chartSchematic => 'Cycle schematic: time axis not to scale';

  @override
  String get chartPhysical =>
      'Thermal history from the scientific engine (specimen center)';

  @override
  String get chartTimeAxis => 'time';

  @override
  String get resultsTitle => 'What the evidence supports';

  @override
  String get status_completed => 'Complete result';

  @override
  String get status_partial_result => 'Partial result';

  @override
  String get status_insufficient_evidence =>
      'Insufficient evidence for numbers';

  @override
  String get status_unsupported => 'Unsupported combination';

  @override
  String get status_invalid_input => 'Input outside domain';

  @override
  String get status_internal_error => 'Internal error';

  @override
  String get statusInsufficientBody =>
      'This combination can be studied, but not yet calculated rigorously.';

  @override
  String get resultsSummary => 'Treatment summary';

  @override
  String get resultsHistory => 'Thermal history';

  @override
  String get resultsTransformations => 'Transformation and phases';

  @override
  String get resultsTransformationsNote =>
      'Crystallographic phases and microconstituents are shown separately; they are never added together.';

  @override
  String get resultsProperties => 'Properties';

  @override
  String get resultsMicroscope => 'Microscope';

  @override
  String get resultsFoundation => 'Scientific foundation';

  @override
  String get resultsKeepLearning => 'Keep learning';

  @override
  String get q_phase_fractions => 'Phase fractions';

  @override
  String get q_microconstituent_fractions => 'Microconstituents';

  @override
  String get q_hardness => 'Final hardness';

  @override
  String get q_grain_size => 'Grain size';

  @override
  String get q_mechanical_properties => 'Mechanical properties';

  @override
  String get resultsUnavailable => 'Not estimable from current evidence';

  @override
  String get resultsWhatsMissing => 'What data is missing?';

  @override
  String get evidence_validated => 'Validated';

  @override
  String get evidence_bounded_estimate => 'Bounded estimate';

  @override
  String get evidence_qualitative => 'Qualitative';

  @override
  String get evidence_insufficient_evidence => 'Insufficient evidence';

  @override
  String get evidence_unsupported => 'Unsupported';

  @override
  String get kind_measured => 'Measured';

  @override
  String get kind_literature => 'Literature';

  @override
  String get kind_modeled => 'Modeled';

  @override
  String get kind_illustrative => 'Illustrative';

  @override
  String get kind_unavailable => 'Unavailable';

  @override
  String get resultsWarnings => 'Warnings and limitations';

  @override
  String get resultsAssumptions => 'Assumptions and origin of the figures';

  @override
  String get resultsSources => 'Sources';

  @override
  String get resultsVersions => 'Versions';

  @override
  String get resultsProtocol => 'Protocol';

  @override
  String get resultsSuggestedReading => 'Suggested reading';

  @override
  String get resultsSupportsValue => 'Supports a value';

  @override
  String get resultsSupportsLimit => 'Supports a limit';

  @override
  String get sourceUnverified => 'Reference not verified by the project';

  @override
  String get sourceVerified => 'Verified reference';

  @override
  String get resultsSave => 'Save to history';

  @override
  String get resultsSaved => 'Saved on this device';

  @override
  String get resultsWhatIf => 'What if…?';

  @override
  String get resultsWhatIfBody =>
      'Change one variable and compare with this result.';

  @override
  String get resultsCompare => 'Compare';

  @override
  String get resultsNewRun => 'New run';

  @override
  String get resultsCopy => 'Copy summary';

  @override
  String get resultsCopied => 'Summary copied';

  @override
  String get resultsEducationalBanner =>
      'Educational tool, not an industrial treatment.';

  @override
  String get tutorExplain => 'Why did this happen?';

  @override
  String get tutorTitle => 'Educational tutor';

  @override
  String get tutorEditorialMode => 'Editorial explanation (no AI)';

  @override
  String get tutorAiMode => 'AI-generated from reviewed context';

  @override
  String get tutorAskHint => 'Type a conceptual question';

  @override
  String get tutorAsk => 'Ask';

  @override
  String get tutorPrivacy =>
      'If the AI tutor is active, your question is sent to an external provider. Do not write personal data.';

  @override
  String get tutorQuick1 => 'What is the difference between TTT and CCT?';

  @override
  String get tutorQuick2 => 'Why does cooling rate matter?';

  @override
  String get tutorQuick3 => 'How do martempering and austempering differ?';

  @override
  String get tutorQuick4 => 'Does gray cast iron behave like steel?';

  @override
  String get tutorQuick5 => 'Why is there no hardness value?';

  @override
  String get microTitle => 'Microstructure';

  @override
  String get microNoMatch =>
      'We do not have a verified micrograph of this condition yet.';

  @override
  String get microNoMatchBody =>
      'To show a micrograph we require a verified license, author, technique, magnification and a match to the material and condition. We do not show images of other steels as if they were from this experiment.';

  @override
  String get microDigitalZoom => 'Digital zoom, not optical magnification';

  @override
  String get microZoomIn => 'Zoom in';

  @override
  String get microZoomOut => 'Zoom out';

  @override
  String microScaleCalibrated(Object value) {
    return 'Calibrated scale bar: $value µm';
  }

  @override
  String get microScaleMissing => 'No calibration: measuring is not allowed';

  @override
  String get microLibraryEmpty =>
      'The micrograph library is empty: there are no images with verified license and metadata yet.';

  @override
  String get microAttribution => 'Author / license';

  @override
  String get learnTitle => 'Learn';

  @override
  String get learnGlossary => 'Glossary';

  @override
  String get learnConcepts => 'Concepts';

  @override
  String get learnFaq => 'FAQ';

  @override
  String get learnTreatments => 'Treatments';

  @override
  String get learnDiagrams => 'Diagrams';

  @override
  String get learnDiagramsBody =>
      'The TTT and CCT diagrams of your practice are computed with the Li et al. (1998) model and appear in the results of every steel simulation. Here you will find the explanation of each diagram.';

  @override
  String get learnRelated => 'Related';

  @override
  String get learnSearch => 'Search';

  @override
  String get practiceTitle => 'Practice mode';

  @override
  String get practiceIntro =>
      'Conceptual questions with feedback. It is not an official grade and your progress stays on this device only.';

  @override
  String get practiceCorrect => 'Correct!';

  @override
  String get practiceIncorrect => 'Not quite';

  @override
  String practiceScore(Object correct, Object total) {
    return '$correct of $total correct';
  }

  @override
  String get practiceNext => 'Next question';

  @override
  String get practiceRestart => 'Start again';

  @override
  String get historyTitle => 'Local history';

  @override
  String get historyEmpty => 'You have not saved any simulations yet.';

  @override
  String get historyLocalNote =>
      'Stored only on this device/browser. If you clear data or switch devices, it is lost. There is no sync.';

  @override
  String get historyDelete => 'Delete local history';

  @override
  String get historyDeleteConfirm =>
      'Delete all history stored on this device?';

  @override
  String get historySelectTwo => 'Select two simulations to compare';

  @override
  String get compareTitle => 'Comparison';

  @override
  String get compareNote =>
      'Only quantities with the same unit and evidence are compared. Missing values are shown as —.';

  @override
  String get compareDifferent => 'Differences';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsSoundNote => 'No sounds in this version.';

  @override
  String get settingsAchievements => 'Achievements';

  @override
  String get settingsAchievementsNote =>
      'Local, optional achievements; never sent to any server.';

  @override
  String get settingsTutorial => 'Show the introduction again';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyBody =>
      'FERROLAB does not ask for an account, email or personal data. Your preferences, history, practice and achievements are stored only on this device. The server computes each simulation and does not store it.';

  @override
  String get settingsSources => 'Bibliography and sources';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAdmin => 'Administration panel';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsNote => 'Off. FERROLAB sends no reminders.';

  @override
  String get sourcesTitle => 'Bibliography and sources';

  @override
  String get sourcesNote =>
      'Citing a work does not prove access to its content. References marked \"unverified\" are suggested reading and support no numbers.';

  @override
  String get achFirstRun => 'First experiment';

  @override
  String get achAllMaterials => 'Explored all three materials';

  @override
  String get achAllTreatments => 'Tried all six treatments';

  @override
  String get achPractice => 'Five correct practice answers';

  @override
  String get achHonest => 'Found an evidence limit';

  @override
  String get teacherTitle => 'Teacher mode';

  @override
  String get teacherIntro =>
      'Create an activity code with a fixed configuration. Students enter it without an account or personal data. A code is not a password and authenticates no one.';

  @override
  String get teacherCreate => 'Create code from current configuration';

  @override
  String get teacherCode => 'Activity code';

  @override
  String get teacherEnter => 'Enter a code';

  @override
  String get teacherLoad => 'Load activity';

  @override
  String get teacherInvalid => 'Invalid code';

  @override
  String get teacherNoConfig =>
      'First configure a simulation (material and treatment).';

  @override
  String get networkError =>
      'No connection to the engine. Your configuration is still here.';

  @override
  String get networkRetry => 'Retry';

  @override
  String get internalError => 'We could not complete this request.';

  @override
  String supportCode(Object code) {
    return 'Support code: $code';
  }

  @override
  String get rateLimited => 'Too many requests; wait a moment and try again.';

  @override
  String get loading => 'Loading…';

  @override
  String get adminTitle => 'FERROLAB Admin';

  @override
  String get adminLogin => 'Sign in';

  @override
  String get adminEmail => 'Email';

  @override
  String get adminPassword => 'Password';

  @override
  String get adminDevToken => 'Development token';

  @override
  String get adminDevTokenHint =>
      'Local development only: paste the token created with scripts/dev_admin_token.py';

  @override
  String get adminNotConfigured =>
      'Administration is unavailable: the server has no database or authentication configured.';

  @override
  String get adminLogout => 'Sign out';

  @override
  String get adminRecords => 'Records';

  @override
  String get adminReleases => 'Releases';

  @override
  String get adminAudit => 'Audit';

  @override
  String adminRole(Object role) {
    return 'Role: $role';
  }

  @override
  String get adminReview => 'Mark as reviewed';

  @override
  String get adminToDraft => 'Back to draft';

  @override
  String get adminRetire => 'Retire';

  @override
  String get adminSave => 'Save draft';

  @override
  String get adminSaved => 'Saved as draft';

  @override
  String get adminNew => 'New record';

  @override
  String get adminPreview => 'Check release';

  @override
  String get adminPublish => 'Publish version';

  @override
  String get adminActivate => 'Activate (roll back to this)';

  @override
  String get adminVersion => 'Version (e.g. 1.0.0)';

  @override
  String get adminActive => 'Active';

  @override
  String get adminReport => 'Report';

  @override
  String get adminReviewWarning =>
      'Reviewing means a person with metallurgical training checked the source, locator, units and domain. Do not mark it if you did not.';

  @override
  String get settingsServer => 'FERROLAB server';

  @override
  String get settingsServerHint => 'e.g. http://192.168.1.20:8000';

  @override
  String get settingsServerSave => 'Save and test';

  @override
  String get settingsServerReset => 'Use default';

  @override
  String settingsServerOk(Object version) {
    return 'Connected: $version';
  }

  @override
  String get settingsServerInvalid =>
      'Enter an address starting with http:// or https://';

  @override
  String settingsServerCurrent(Object url) {
    return 'Current address: $url';
  }

  @override
  String get settingsServerNote =>
      'The app needs the FERROLAB server to compute. At home you can use your computer on the same Wi‑Fi (http://IP:8000). http:// addresses are not encrypted: use them only on your local network.';

  @override
  String get homeConfigureServer => 'Configure server';

  @override
  String get constFerrite => 'Proeutectoid ferrite';

  @override
  String get constPearlite => 'Pearlite';

  @override
  String get constBainite => 'Bainite';

  @override
  String get constMartensite => 'Martensite';

  @override
  String get constTemperedMartensite => 'Tempered martensite';

  @override
  String get constRetained => 'Retained austenite';

  @override
  String get constGraphite => 'Flake graphite (type A)';

  @override
  String get phaseFerrite => 'Ferrite (α)';

  @override
  String get phaseCementite => 'Cementite (Fe₃C)';

  @override
  String get phaseAustenite => 'Austenite (γ)';

  @override
  String get grayMatrixPearlite => 'Pearlitic matrix';

  @override
  String get grayMatrixFerritePearlite => 'Ferritic-pearlitic matrix';

  @override
  String get grayMatrixMartensite => 'Martensitic matrix';

  @override
  String get grayMatrixTempered => 'Tempered-martensite matrix';

  @override
  String get grayMatrixAusferrite => 'Ausferritic matrix';

  @override
  String get microGeneratedTitle => 'Generated microstructure';

  @override
  String get microGeneratedNote =>
      'Illustration GENERATED by FERROLAB from the model\'s computed fractions (specimen center). It is not a real micrograph: use it to recognize the constituents.';

  @override
  String get microGesture =>
      'Pinch or use the mouse wheel to zoom; drag to move across the sample.';

  @override
  String get microReset => 'Back to initial magnification';

  @override
  String get microRealTitle => 'Licensed real micrograph';

  @override
  String get microOpen => 'Open the microscope';

  @override
  String get diagTitle => 'TTT and CCT diagrams of your practice';

  @override
  String get diagTtt => 'TTT';

  @override
  String get diagCct => 'CCT';

  @override
  String get diagTttNote =>
      'TTT: time to start (1%) and finish (99%) each transformation at constant temperature. Your curve shows the actual cooling of the specimen center.';

  @override
  String get diagCctNote =>
      'CCT: start of each transformation under continuous cooling at constant rates. Where your curve crosses a region, that constituent forms.';

  @override
  String get diagYourPath => 'Your practice (center)';

  @override
  String diagAxes(String g) {
    return 'x axis: time from start of cooling (s, log scale). y axis: temperature (°C). Li et al. (1998) model, nominal composition, ASTM G $g (computed).';
  }

  @override
  String get diagTable => 'View diagram data';

  @override
  String get modelTitle => 'Estimate details';

  @override
  String get modelCritical => 'Critical temperatures (computed)';

  @override
  String get modelComposition => 'Nominal composition used (wt %)';

  @override
  String get modelSurface => 'Specimen surface';

  @override
  String get modelPrior =>
      'Hardened starting state (computed with the recommended hardening practice)';

  @override
  String get modelSpecimen =>
      'Reference specimen: 12.7 mm cylinder, results at the center.';

  @override
  String get factBand => 'Uncertainty band';

  @override
  String microMagnification(String x) {
    return '≈ $x× on screen';
  }

  @override
  String diagPoint(String time, String temp) {
    return 'Your practice: t = $time · $temp °C';
  }

  @override
  String diagNose(String time, String temp) {
    return 'nose: $time at $temp °C';
  }

  @override
  String modelCooling(String rate) {
    return 'Cooling rate at 700 °C: $rate °C/s';
  }

  @override
  String modelBath(String temp) {
    return 'Bath temperature (model): $temp °C';
  }

  @override
  String modelAustenite(String pct) {
    return 'Austenite formed during hold: $pct %';
  }

  @override
  String factBandValue(String lo, String hi) {
    return '$lo – $hi';
  }

  @override
  String get mediumWater => 'water';

  @override
  String get mediumOil => 'oil';

  @override
  String get mediumAir => 'still air';

  @override
  String get mediumFurnace => 'furnace';

  @override
  String get mediumSaltBath => 'salt bath';

  @override
  String get reviewExpectModel =>
      'Model ESTIMATES will be computed from published models: phases, constituents, hardness and TTT/CCT diagrams of your practice. They will be labeled as estimates (not measurements).';

  @override
  String get microLabelsToggle => 'Point out microconstituents';

  @override
  String get microLabelsZoomHint =>
      'Arrows are shown at base magnification: tap “Back to initial magnification”.';

  @override
  String get microLabelRetained => 'Retained austenite (white islands)';

  @override
  String get levelA => 'A · Computed with published models';

  @override
  String get levelB => 'B · Grounded qualitative interpretation';

  @override
  String get levelC => 'C · Illustrative educational demonstration';

  @override
  String get lpLimitations => 'Scientific basis and limitations';

  @override
  String get groupInput => 'Your parameters';

  @override
  String get groupDependency => 'Prior state';

  @override
  String get groupProtocol => 'Protocol';

  @override
  String get groupEvidence => 'Evidence';

  @override
  String get groupModel => 'Model';

  @override
  String get groupReview => 'Review';

  @override
  String get groupOther => 'Other';

  @override
  String get lpReference => 'Reference';

  @override
  String get lpVerified => 'Verified source';

  @override
  String get lpUnverified => 'Source not verified by FERROLAB';

  @override
  String get lpProtocols => 'Available protocols';

  @override
  String get lpUseProtocol => 'Use recommended protocol';

  @override
  String get lpParams => 'Protocol parameters';

  @override
  String get pFurnace => 'Furnace temperature';

  @override
  String get pHold => 'Holding time';

  @override
  String get pBath => 'Bath temperature';

  @override
  String get pBathTime => 'Bath time';

  @override
  String get pBathEqualize => 'Empty = until temperature equalizes (computed)';

  @override
  String get pOutside => 'Outside the documented interval for this protocol.';

  @override
  String get pMediumLocked => 'Cooling medium (set by the protocol)';

  @override
  String get lpSequence => 'Thermal sequence';

  @override
  String get lpSheet => 'Protocol scientific sheet';

  @override
  String get lpObjective => 'Objective';

  @override
  String get lpCondition => 'Material condition';

  @override
  String get lpExpected => 'Expected outcome';

  @override
  String get lpRestrictions => 'Conditions and restrictions';

  @override
  String get lpAssumptions => 'Assumptions';

  @override
  String get lpMissing => 'What still needs research';

  @override
  String get lpPublished =>
      'Published results of the case (measured, not predicted)';

  @override
  String get lpSources => 'Sources';

  @override
  String get lpPrior => 'Tempering starting state';

  @override
  String get priorReference => 'Reference hardened';

  @override
  String get priorHistory => 'From my history';

  @override
  String get priorTheory => 'Theory only';

  @override
  String get priorHistoryEmpty =>
      'No quenches of this material in your history yet (save them from Results).';

  @override
  String get seqAmbient => 'room temperature';

  @override
  String get seqUntilEqualized => 'until equalized';

  @override
  String get seqStart => 'Count starts';

  @override
  String get lpMaterialPanel => 'Material';

  @override
  String get lpComposition => 'Reference composition (wt%)';

  @override
  String get lpCompositionNone =>
      'The standard sets no composition: check your part\'s.';

  @override
  String get lpTreatmentPanel => 'Treatment';

  @override
  String get basisSource => 'Value from the source';

  @override
  String get basisRule => 'Published rule applied to the 12.7 mm specimen';

  @override
  String get basisModel => 'Computed with the model (not published)';

  @override
  String get basisPending => 'the source gives no number';

  @override
  String get basisComputed => 'Computed by the thermal model';

  @override
  String get goalReference => 'General';

  @override
  String get goalHardness => 'Hardness-oriented';

  @override
  String get goalToughness => 'Toughness-oriented';

  @override
  String get goalSoftening => 'Softening';

  @override
  String get goalStressRelief => 'Stress relief';

  @override
  String get goalExperimental => 'Experimental case';

  @override
  String get goalMachinability => 'Machinability';

  @override
  String get goalPending => 'Pending';

  @override
  String get mediumTinBath => 'tin bath';

  @override
  String lpLimitationsCount(String n) {
    return '$n notices grouped by cause';
  }

  @override
  String pRange(String range) {
    return 'Documented interval: $range';
  }

  @override
  String pRef(String v) {
    return 'Reference: $v';
  }

  @override
  String get lpProtocol => 'Protocol';

  @override
  String get microQualitativeNote =>
      'QUALITATIVE illustration: matrix and graphite as the source describes for this treatment. There are no computed fractions and it is not a real micrograph.';

  @override
  String get microReasonNoAustenitization =>
      'No austenitization: the starting microstructure does not change and no new one is drawn.';

  @override
  String get microReasonOutsideRange =>
      'Not drawn: the practice is outside the documented protocol, and exploration mode computes no fractions. Go back to the reference value to see the microstructure.';

  @override
  String get microReasonCarburized =>
      'Not drawn: the carburized case is not modeled, so there are no case fractions to represent.';

  @override
  String get microReasonNotModeled =>
      'Not drawn: FERROLAB has no model for this transformation (e.g. subcritical spheroidizing). See the expected outcome in the protocol sheet.';

  @override
  String get microReasonUnverified =>
      'Not drawn: the variant has an unverified source and no fractions are computed.';

  @override
  String get microReasonTheory =>
      'Not drawn: in theory-only mode there is no hardened starting state.';

  @override
  String get microReasonInvalid => 'Not drawn: correct the input to continue.';

  @override
  String get microReasonNotComputed =>
      'Not drawn: there are no computed fractions for this practice.';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsAppVersion => 'Installed app';

  @override
  String get settingsEngineVersion => 'Server engine';

  @override
  String get settingsDatasetVersion => 'Scientific catalog';

  @override
  String get microRelatedTitle => 'Real micrographs of these constituents';

  @override
  String get microRelatedNote =>
      'Real, freely licensed photographs of OTHER samples containing the same constituents the model computed. They are not your specimen: use them to compare with the illustration.';

  @override
  String get microLoadError =>
      'The image could not be loaded (check your connection).';

  @override
  String get microAuthor => 'Author';

  @override
  String get microLicense => 'License';

  @override
  String get microSourcePage => 'Source page';

  @override
  String get microMethod => 'Method';

  @override
  String get microMethodSem => 'Scanning electron microscope (SEM)';

  @override
  String get microMethodOptical => 'Optical microscope';

  @override
  String get microPreparation => 'Preparation';

  @override
  String get microMatch => 'Match with FERROLAB';

  @override
  String get microFilterAll => 'All';

  @override
  String get matchExact => 'Same condition';

  @override
  String get matchComparable => 'Comparable condition';

  @override
  String get matchIllustrative => 'Example of the constituent (another sample)';

  @override
  String get matchNone => 'No match';

  @override
  String microSpecimen(String s) {
    return 'Real photographed sample: $s';
  }

  @override
  String microOriginalMag(String x) {
    return 'Magnification stated by the source: $x× (original image)';
  }

  @override
  String microLibraryNote(String n) {
    return '$n real micrographs with verified free licenses (Wikimedia Commons). Each states the real sample; filter by constituent.';
  }

  @override
  String get constSpheroidite => 'Spheroidized cementite (spheroidite)';

  @override
  String get constNodules => 'Nodular (spheroidal) graphite';

  @override
  String get constAusferrite => 'Ausferrite';

  @override
  String get constProeutectoidCementite => 'Proeutectoid cementite';

  @override
  String get microMethodTem => 'Transmission electron microscope (TEM)';

  @override
  String get resultsMicrographRefs => 'Cited micrographs';

  @override
  String get mechYield => 'Yield strength';

  @override
  String get mechTensile => 'Tensile strength';

  @override
  String get mechTensileMin =>
      'Minimum tensile strength (standard, untreated casting)';

  @override
  String grainAstm(String g) {
    return 'ASTM G $g';
  }

  @override
  String grainAustenite(String d) {
    return 'Prior-austenite grain: $d µm (mean lineal intercept)';
  }

  @override
  String grainFerrite(String d, String g) {
    return 'Ferrite grain: $d µm · ASTM G $g';
  }

  @override
  String get grainExtrapolated =>
      'Computed by extrapolation: the Lee and Lee model was fitted between 850 and 1200 °C and up to 3 h.';

  @override
  String get grainMeasureToggle => 'Measure grain size';

  @override
  String get grainMeasureTitle => 'Lineal intercept measurement (ASTM E112)';

  @override
  String grainMeasureBody(String lines, String length, String n) {
    return '$lines test lines with a total length of $length µm are drawn on the image. $n grain-boundary crossings are counted.';
  }

  @override
  String grainMeasureResult(String l, String g) {
    return 'ℓ̄ = $l µm → measured G = $g';
  }

  @override
  String grainMeasureModel(String g, String kind) {
    return 'G computed by the model: $g ($kind)';
  }

  @override
  String get grainKindAustenite => 'prior-austenite grain';

  @override
  String get grainKindFerrite => 'ferrite grain';

  @override
  String get grainKindAssumed => 'assumed';

  @override
  String get grainMeasureNote =>
      'Each crossing of a line with a grain boundary is an intersection. ℓ̄ = total length ÷ intersections; G = −6.644·log10(ℓ̄ in mm) − 3.288. A small difference from the model is normal: the image is generated from the mean area and the standard notes that area and intercept do not give exactly the same G.';

  @override
  String get sourceModel => 'Reference for the model used in the computation';

  @override
  String get factOtherSpecimen => 'Published value from another specimen';

  @override
  String microRelatedCount(String n) {
    return '$n real micrographs of the constituents in your result, with author and license: open them in the microscope.';
  }

  @override
  String get learnResearch => 'Articles';

  @override
  String get learnResearchNote =>
      'Summaries of OPEN-ACCESS scientific articles and reports, with their full citation (authors, year, journal and DOI). Open the link to read the original text.';

  @override
  String get learnCitation => 'Citation';

  @override
  String get sourceStandard =>
      'ASTM standard (official text at ASTM International)';

  @override
  String get resultsArticles => 'Scientific articles supporting this result';

  @override
  String get resultsArticlesNote =>
      'Open-access articles on this material and treatment. Tap one to read the full entry.';

  @override
  String get learnTreatmentArticles => 'Articles on this treatment';
}
