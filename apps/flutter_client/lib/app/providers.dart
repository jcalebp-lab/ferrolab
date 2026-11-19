import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/networking/api_client.dart';
import '../core/storage/local_store.dart';
import '../shared/models/models.dart';

final localStoreProvider = Provider<LocalStore>((ref) => throw UnimplementedError('se sobreescribe en main'));
final apiClientProvider = Provider<ApiClient>(
    (ref) => ApiClient(baseUrl: ref.watch(settingsProvider.select((s) => s.serverUrl))));
final repositoryProvider = Provider<FerrolabRepository>((ref) => FerrolabRepository(ref.watch(apiClientProvider)));

// ------------------------------------------------------------------ ajustes
@immutable
class AppSettings {
  const AppSettings({this.locale = 'es', this.themeMode = ThemeMode.system, this.reduceMotion = false,
      this.achievements = true, this.onboardingSeen = false, this.serverUrl});
  final String locale;
  /// Dirección del servidor elegida por el usuario (null = predeterminada de la compilación).
  final String? serverUrl;
  final ThemeMode themeMode;
  final bool reduceMotion, achievements, onboardingSeen;

  AppSettings copyWith({String? locale, ThemeMode? themeMode, bool? reduceMotion, bool? achievements,
          bool? onboardingSeen, String? serverUrl, bool clearServer = false}) =>
      AppSettings(
        locale: locale ?? this.locale,
        themeMode: themeMode ?? this.themeMode,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        achievements: achievements ?? this.achievements,
        onboardingSeen: onboardingSeen ?? this.onboardingSeen,
        serverUrl: clearServer ? null : (serverUrl ?? this.serverUrl),
      );

  Map<String, dynamic> toJson() => {
        'serverUrl': serverUrl,
        'locale': locale,
        'theme': themeMode.name,
        'reduceMotion': reduceMotion,
        'achievements': achievements,
        'onboardingSeen': onboardingSeen,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        locale: (j['locale'] as String?) == 'en' ? 'en' : 'es',
        themeMode: ThemeMode.values.firstWhere((m) => m.name == j['theme'], orElse: () => ThemeMode.system),
        reduceMotion: j['reduceMotion'] as bool? ?? false,
        achievements: j['achievements'] as bool? ?? true,
        onboardingSeen: j['onboardingSeen'] as bool? ?? false,
        serverUrl: j['serverUrl'] as String?,
      );
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => AppSettings.fromJson(ref.read(localStoreProvider).readSettings());

  void update(AppSettings Function(AppSettings) f) {
    state = f(state);
    ref.read(localStoreProvider).writeSettings(state.toJson());
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
final localeProvider = Provider<String>((ref) => ref.watch(settingsProvider.select((s) => s.locale)));

// ------------------------------------------------------------------ catálogo (sin ciencia local)
final healthProvider = FutureProvider<HealthDto>((ref) => ref.watch(repositoryProvider).health());
final materialsProvider =
    FutureProvider<List<MaterialDto>>((ref) => ref.watch(repositoryProvider).materials(ref.watch(localeProvider)));
final treatmentsProvider =
    FutureProvider<List<TreatmentDto>>((ref) => ref.watch(repositoryProvider).treatments(ref.watch(localeProvider)));
final pairsProvider = FutureProvider.family<PairsDto, String>(
    (ref, materialId) => ref.watch(repositoryProvider).pairs(materialId, ref.watch(localeProvider)));
final knowledgeProvider = FutureProvider<List<KnowledgeEntryDto>>(
    (ref) => ref.watch(repositoryProvider).knowledge(ref.watch(localeProvider)));
final practiceProvider = FutureProvider<List<PracticeQuestionDto>>(
    (ref) => ref.watch(repositoryProvider).practice(ref.watch(localeProvider)));
final sourcesProvider = FutureProvider<List<SourceRef>>((ref) => ref.watch(repositoryProvider).sources());
final micrographsProvider = FutureProvider<List<MicrographDto>>(
    (ref) => ref.watch(repositoryProvider).micrographs(ref.watch(localeProvider)));

// ------------------------------------------------------------------ simulación
enum SimPhase { editing, validating, ready, running, showingResults, networkError, apiError }

@immutable
class SimState {
  const SimState({this.materialId, this.treatmentId, this.initialConditionId, this.temperatureC = 20,
      this.holdMin = 0, this.protocolId, this.bathTemperatureC, this.bathTimeMin, this.priorMode = 'reference',
      this.priorProtocolId, this.priorTemperatureC, this.priorHoldMin, this.phase = SimPhase.editing, this.validation,
      this.result, this.error});
  final String? materialId, treatmentId, initialConditionId, protocolId, priorProtocolId;
  final double temperatureC, holdMin;
  final double? bathTemperatureC, bathTimeMin, priorTemperatureC, priorHoldMin;
  final String priorMode; // reference | history | theory (revenido)
  final SimPhase phase;
  final ValidationReportDto? validation;
  final SimulationResultDto? result;
  final Object? error;

  bool get configured => materialId != null && treatmentId != null;

  SimulationInput? get input => configured
      ? SimulationInput(
          materialId: materialId!,
          treatmentId: treatmentId!,
          initialConditionId: initialConditionId,
          targetTemperatureC: temperatureC,
          holdTimeMin: holdMin,
          protocolId: protocolId,
          bathTemperatureC: bathTemperatureC,
          bathTimeMin: bathTimeMin,
          priorMode: priorMode,
          priorProtocolId: priorProtocolId,
          priorTemperatureC: priorTemperatureC,
          priorHoldMin: priorHoldMin)
      : null;

  SimState copyWith({String? materialId, String? treatmentId, String? initialConditionId, double? temperatureC,
          double? holdMin, String? protocolId, double? bathTemperatureC, double? bathTimeMin, String? priorMode,
          String? priorProtocolId, double? priorTemperatureC, double? priorHoldMin, SimPhase? phase,
          ValidationReportDto? validation, SimulationResultDto? result, Object? error, bool clearTreatment = false,
          bool clearOutcome = false, bool clearBath = false, bool clearBathTime = false, bool clearPrior = false}) =>
      SimState(
        materialId: materialId ?? this.materialId,
        treatmentId: clearTreatment ? null : (treatmentId ?? this.treatmentId),
        initialConditionId: initialConditionId ?? this.initialConditionId,
        temperatureC: temperatureC ?? this.temperatureC,
        holdMin: holdMin ?? this.holdMin,
        protocolId: clearTreatment ? null : (protocolId ?? this.protocolId),
        bathTemperatureC: clearBath ? null : (bathTemperatureC ?? this.bathTemperatureC),
        bathTimeMin: clearBath || clearBathTime ? null : (bathTimeMin ?? this.bathTimeMin),
        priorMode: priorMode ?? this.priorMode,
        priorProtocolId: clearPrior ? null : (priorProtocolId ?? this.priorProtocolId),
        priorTemperatureC: clearPrior ? null : (priorTemperatureC ?? this.priorTemperatureC),
        priorHoldMin: clearPrior ? null : (priorHoldMin ?? this.priorHoldMin),
        phase: phase ?? this.phase,
        validation: clearOutcome ? null : (validation ?? this.validation),
        result: clearOutcome ? null : (result ?? this.result),
        error: clearOutcome ? null : (error ?? this.error),
      );
}

class SimulationController extends Notifier<SimState> {
  @override
  SimState build() => const SimState();

  void selectMaterial(String id) {
    if (id == state.materialId) return;
    // Cambiar material limpia el tratamiento (protocolo incompatible) y conserva solo lo seguro.
    state = SimState(materialId: id, temperatureC: state.temperatureC, holdMin: state.holdMin);
  }

  void selectTreatment(String id) => state = SimState(materialId: state.materialId, treatmentId: id,
      temperatureC: state.temperatureC, holdMin: state.holdMin);

  /// Carga un protocolo con sus valores de referencia («Usar protocolo recomendado»).
  void applyProtocol(ProtocolCard p) {
    double? ref(String k) => p.param(k)?.ref ?? p.param(k)?.value;
    final bt = p.param('bath_time');
    state = SimState(
      materialId: state.materialId,
      treatmentId: state.treatmentId,
      protocolId: p.id,
      temperatureC: ref('furnace_temperature') ?? p.param('furnace_temperature')?.max ?? state.temperatureC,
      holdMin: ref('hold_time') ?? 0,
      bathTemperatureC: ref('bath_temperature'),
      bathTimeMin: bt == null || bt.basis == 'computed' ? null : bt.ref,
      priorMode: state.priorMode,
      priorProtocolId: state.priorProtocolId,
      priorTemperatureC: state.priorTemperatureC,
      priorHoldMin: state.priorHoldMin,
    );
  }

  void setInitialCondition(String id) => state = state.copyWith(initialConditionId: id, clearOutcome: true);
  void setTemperature(double c) => state = state.copyWith(temperatureC: c, phase: SimPhase.editing, clearOutcome: true);
  void setHold(double m) => state = state.copyWith(holdMin: m, phase: SimPhase.editing, clearOutcome: true);
  void setBathTemperature(double c) =>
      state = state.copyWith(bathTemperatureC: c, phase: SimPhase.editing, clearOutcome: true);
  void setBathTime(double? m) => state = m == null
      ? state.copyWith(clearBathTime: true, phase: SimPhase.editing, clearOutcome: true)
      : state.copyWith(bathTimeMin: m, phase: SimPhase.editing, clearOutcome: true);

  /// Revenido: origen del estado templado (referencia, una práctica del historial o solo teoría).
  void setPrior(String mode, {SimulationInput? fromHistory}) => state = fromHistory == null
      ? state.copyWith(priorMode: mode, clearPrior: true, clearOutcome: true)
      : state.copyWith(priorMode: mode, priorProtocolId: fromHistory.protocolId,
          priorTemperatureC: fromHistory.targetTemperatureC, priorHoldMin: fromHistory.holdTimeMin, clearOutcome: true);

  void loadConfig(SimulationInput i) => state = SimState(
      materialId: i.materialId,
      treatmentId: i.treatmentId,
      initialConditionId: i.initialConditionId,
      temperatureC: i.targetTemperatureC,
      holdMin: i.holdTimeMin,
      protocolId: i.protocolId,
      bathTemperatureC: i.bathTemperatureC,
      bathTimeMin: i.bathTimeMin,
      priorMode: i.priorMode);

  Future<void> validate() async {
    final input = state.input;
    if (input == null) return;
    state = state.copyWith(phase: SimPhase.validating, clearOutcome: true);
    try {
      final v = await ref.read(repositoryProvider).validate(input, ref.read(localeProvider));
      state = state.copyWith(phase: SimPhase.ready, validation: v);
    } on NetworkException catch (e) {
      state = state.copyWith(phase: SimPhase.networkError, error: e);
    } on ApiException catch (e) {
      state = state.copyWith(phase: SimPhase.apiError, error: e);
    }
  }

  /// Ejecuta el FSE una sola vez; la animación luego solo reproduce el resultado.
  Future<SimulationResultDto?> run() async {
    final input = state.input;
    if (input == null) return null;
    state = state.copyWith(phase: SimPhase.running);
    try {
      final r = await ref.read(repositoryProvider).simulate(input, ref.read(localeProvider));
      state = state.copyWith(phase: SimPhase.showingResults, result: r);
      ref.read(achievementsProvider.notifier).onSimulation(r);
      return r;
    } on NetworkException catch (e) {
      state = state.copyWith(phase: SimPhase.networkError, error: e);
    } on ApiException catch (e) {
      state = state.copyWith(phase: SimPhase.apiError, error: e);
    }
    return null;
  }
}

final simulationProvider = NotifierProvider<SimulationController, SimState>(SimulationController.new);

// ------------------------------------------------------------------ historial local
class HistoryEntry {
  HistoryEntry(this.savedAt, this.result);
  final DateTime savedAt;
  final SimulationResultDto result;
}

class HistoryNotifier extends Notifier<List<HistoryEntry>> {
  @override
  List<HistoryEntry> build() {
    final raw = ref.read(localStoreProvider).readHistory();
    final out = <HistoryEntry>[];
    for (final e in raw) {
      try {
        out.add(HistoryEntry(DateTime.parse(e['saved_at'] as String), SimulationResultDto.fromJson(e['result'] as Json)));
      } on Object {
        // Entradas de versiones antiguas o corruptas se ignoran.
      }
    }
    return out;
  }

  void save(SimulationResultDto r) {
    state = [HistoryEntry(DateTime.now(), r), ...state.where((e) => e.result.requestId != r.requestId)]
        .take(LocalStore.maxHistory)
        .toList();
    _persist();
  }

  Future<void> clear() async {
    state = [];
    await ref.read(localStoreProvider).clearHistory();
  }

  void _persist() => ref.read(localStoreProvider).writeHistory(
      [for (final e in state) {'saved_at': e.savedAt.toIso8601String(), 'result': e.result.raw}]);
}

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryEntry>>(HistoryNotifier.new);

// ------------------------------------------------------------------ logros (P2, locales y desactivables)
enum Achievement { firstRun, allMaterials, allTreatments, practice, honest }

class AchievementsNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => ref.read(localStoreProvider).readAchievements();

  Set<Achievement> get unlocked =>
      {for (final a in Achievement.values) if (state['unlocked_${a.name}'] == true) a};

  Achievement? lastUnlocked;

  void _unlock(Achievement a) {
    if (!ref.read(settingsProvider).achievements || state['unlocked_${a.name}'] == true) return;
    lastUnlocked = a;
    state = {...state, 'unlocked_${a.name}': true};
  }

  void onSimulation(SimulationResultDto r) {
    final mats = {...(state['materials'] as List? ?? const []), r.input.materialId}.toList();
    final trts = {...(state['treatments'] as List? ?? const []), r.input.treatmentId}.toList();
    state = {...state, 'materials': mats, 'treatments': trts};
    _unlock(Achievement.firstRun);
    if (mats.length >= 3) _unlock(Achievement.allMaterials);
    if (trts.length >= 6) _unlock(Achievement.allTreatments);
    if (r.status == SimulationStatus.insufficientEvidence) _unlock(Achievement.honest);
    ref.read(localStoreProvider).writeAchievements(state);
  }

  void onPracticeCorrect() {
    final n = (state['practice_correct'] as int? ?? 0) + 1;
    state = {...state, 'practice_correct': n};
    if (n >= 5) _unlock(Achievement.practice);
    ref.read(localStoreProvider).writeAchievements(state);
  }
}

final achievementsProvider =
    NotifierProvider<AchievementsNotifier, Map<String, dynamic>>(AchievementsNotifier.new);

// ------------------------------------------------------------------ comparación
class CompareNotifier extends Notifier<(SimulationResultDto, SimulationResultDto)?> {
  @override
  (SimulationResultDto, SimulationResultDto)? build() => null;
  void set(SimulationResultDto a, SimulationResultDto b) => state = (a, b);
}

final compareProvider =
    NotifierProvider<CompareNotifier, (SimulationResultDto, SimulationResultDto)?>(CompareNotifier.new);
