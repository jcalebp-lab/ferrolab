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
  String get back => 'Back';

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
  String get unreviewedBanner => 'Editorial content pending specialist review.';

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
  String get paramsProtocolDefines => 'What the protocol defines';

  @override
  String get paramsTemperature => 'Target temperature';

  @override
  String get paramsHold => 'Holding time';

  @override
  String get paramsMinutes => 'minutes';

  @override
  String paramsHoldStage(Object stage) {
    return 'Applies to: $stage';
  }

  @override
  String paramsFurnaceRange(Object min, Object max) {
    return 'Furnace range (interface): $min–$max °C';
  }

  @override
  String get paramsThermalLimit => 'Valid protocol range';

  @override
  String get paramsRangeUnpublished =>
      'Valid protocol range: not documented yet';

  @override
  String get paramsRangeTooltip =>
      'The valid range depends on material and treatment; the furnace maximum is only the instrument\'s visual capacity.';

  @override
  String paramsPhysicalLimit(Object limit) {
    return 'Physical safety limit: $limit °C (melting)';
  }

  @override
  String get protocolLocked => 'Cooling set by protocol';

  @override
  String get protocolLockedWhy =>
      'It is selected automatically from the reviewed protocol for the material and treatment; it is not configurable so the simulation stays traceable.';

  @override
  String get protocolPending => 'Protocol pending review';

  @override
  String get protocolMedium => 'Medium';

  @override
  String get paramsReview => 'Review configuration';

  @override
  String get paramsInvalidNumber => 'Enter a valid number';

  @override
  String get paramsOutOfUi => 'Outside the interface range';

  @override
  String get runReview => 'Review experiment';

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
      'Scientific engine history (teaching linear segments)';

  @override
  String get chartTimeAxis => 'time';

  @override
  String get chartNoData => 'No trajectory to show';

  @override
  String get resultsTitle => 'What the evidence supports';

  @override
  String get status_completed => 'Complete supported result';

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
  String get resultsViewSource => 'View source and limitations';

  @override
  String get resultsWhatsMissing => 'What data is missing?';

  @override
  String get resultsWhatsMissingBody =>
      'To show a number, FERROLAB needs experimental data or a validated model for this exact condition (material, initial state, published protocol, temperature and time), with a source, locator and validity range, reviewed by a person with metallurgical training.';

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
  String get resultsAssumptions => 'Assumptions';

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
      'FERROLAB only draws TTT, CCT or Fe–C curves from digitized data with a source and permission. None is published yet, so here you will find the conceptual explanation without fictitious lines.';

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
  String get practiceHypothesis =>
      'Before simulating: what do you expect to happen?';

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
  String achUnlocked(Object name) {
    return 'Achievement unlocked: $name';
  }

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
  String get teacherPresentation => 'Presentation mode';

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
  String get adminProblems => 'Problems blocking the release';

  @override
  String get adminReport => 'Report';

  @override
  String get adminReviewWarning =>
      'Reviewing means a person with metallurgical training checked the source, locator, units and domain. Do not mark it if you did not.';

  @override
  String get adminJsonField => '(JSON)';

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
}
