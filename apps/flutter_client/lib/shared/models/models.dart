// DTOs tipados del contrato /api/v1 (packages/contracts/openapi.json).
// Regla: un campo `null` del servidor permanece `null`; nunca se sustituye por 0.
import 'contract_enums.g.dart';

export 'contract_enums.g.dart';

typedef Json = Map<String, dynamic>;

double? _d(Object? v) => v == null ? null : (v as num).toDouble();
List<T> _l<T>(Object? v, T Function(Json) f) => (v as List? ?? const []).map((e) => f(e as Json)).toList();
List<String> _ls(Object? v) => (v as List? ?? const []).map((e) => e.toString()).toList();

class SourceRef {
  SourceRef({required this.id, required this.title, this.authors, this.year, this.kind, this.url, this.doi,
      required this.verificationStatus, this.usage, this.locator, this.edition});
  final String id, title, verificationStatus;
  final String? authors, kind, url, doi, usage, locator, edition;
  final int? year;

  bool get verified => verificationStatus == 'verified';

  factory SourceRef.fromJson(Json j) => SourceRef(
        id: (j['id'] ?? j['source_id']) as String,
        title: j['title'] as String,
        authors: j['authors'] as String?,
        year: j['year'] as int?,
        kind: j['kind'] as String?,
        url: j['url'] as String?,
        doi: j['doi'] as String?,
        edition: j['edition'] as String?,
        verificationStatus: (j['verification_status'] ?? 'unverified') as String,
        usage: j['usage'] as String?,
        locator: j['locator'] as String?,
      );
}

class InitialConditionDto {
  InitialConditionDto({required this.id, required this.name, required this.description, this.hardened,
      this.carburized, required this.reviewStatus});
  final String id, name, description, reviewStatus;
  final bool? hardened, carburized;

  factory InitialConditionDto.fromJson(Json j) => InitialConditionDto(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String,
        hardened: j['hardened'] as bool?,
        carburized: j['carburized'] as bool?,
        reviewStatus: j['review_status'] as String,
      );
}

class MaterialDto {
  MaterialDto({required this.id, required this.displayName, required this.family, required this.standardNote,
      required this.description, required this.limitations, required this.compositions,
      required this.initialConditions, required this.suggestedSources, required this.reviewStatus});
  final String id, displayName, standardNote, description, reviewStatus;
  final MaterialFamily family;
  final List<String> limitations;
  final List<Json> compositions;
  final List<InitialConditionDto> initialConditions;
  final List<SourceRef> suggestedSources;

  factory MaterialDto.fromJson(Json j) => MaterialDto(
        id: j['id'] as String,
        displayName: j['display_name'] as String,
        family: MaterialFamily.fromWire(j['family'] as String)!,
        standardNote: j['standard_note'] as String,
        description: j['description'] as String,
        limitations: _ls(j['limitations']),
        compositions: (j['compositions'] as List).cast<Json>(),
        initialConditions: _l(j['initial_conditions'], InitialConditionDto.fromJson),
        suggestedSources: _l(j['suggested_sources'], SourceRef.fromJson),
        reviewStatus: j['review_status'] as String,
      );
}

class StageOutline {
  StageOutline({required this.kind, required this.label, required this.userHold});
  final String kind, label;
  final bool userHold;
  factory StageOutline.fromJson(Json j) =>
      StageOutline(kind: j['kind'] as String, label: j['label'] as String, userHold: j['user_hold'] as bool);
}

class TreatmentDto {
  TreatmentDto({required this.id, required this.name, required this.purpose, required this.prerequisites,
      required this.qualitativeOutcome, required this.stages, required this.suggestedSources});
  final String id, name, purpose, prerequisites, qualitativeOutcome;
  final List<StageOutline> stages;
  final List<SourceRef> suggestedSources;

  factory TreatmentDto.fromJson(Json j) => TreatmentDto(
        id: j['id'] as String,
        name: j['name'] as String,
        purpose: j['purpose'] as String,
        prerequisites: j['prerequisites'] as String,
        qualitativeOutcome: j['qualitative_outcome'] as String,
        stages: _l(j['stage_outline'], StageOutline.fromJson),
        suggestedSources: _l(j['suggested_sources'], SourceRef.fromJson),
      );
}

class DomainDto {
  DomainDto({this.min, this.max, required this.unit, required this.published});
  final double? min, max;
  final String unit;
  final bool published;
  bool get usable => published && min != null && max != null;
  factory DomainDto.fromJson(Json j) =>
      DomainDto(min: _d(j['min']), max: _d(j['max']), unit: j['unit'] as String, published: j['published'] as bool);
}

class ProtocolSummary {
  ProtocolSummary({required this.id, required this.version, required this.reviewStatus, required this.medium,
      required this.mediumDocumented, required this.fullySpecified, required this.stages});
  final String id, version, reviewStatus, medium;
  final bool mediumDocumented, fullySpecified;
  final List<StageOutline> stages;
  factory ProtocolSummary.fromJson(Json j) => ProtocolSummary(
        id: j['id'] as String,
        version: j['version'] as String,
        reviewStatus: j['review_status'] as String,
        medium: j['medium'] as String,
        mediumDocumented: j['medium_documented'] as bool,
        fullySpecified: j['fully_specified'] as bool,
        stages: _l(j['stages'], StageOutline.fromJson),
      );
}

class PairDto {
  PairDto({required this.treatmentId, required this.name, required this.compatibility, this.reason,
      required this.quantitative, required this.temperatureDomain, required this.holdDomain, this.physicalLimitC,
      this.protocol});
  final String treatmentId, name;
  final CompatibilityStatus compatibility;
  final String? reason;
  final bool quantitative;
  final DomainDto temperatureDomain, holdDomain;
  final double? physicalLimitC;
  final ProtocolSummary? protocol;

  factory PairDto.fromJson(Json j) => PairDto(
        treatmentId: j['treatment_id'] as String,
        name: j['name'] as String,
        compatibility: CompatibilityStatus.fromWire(j['compatibility_status'] as String)!,
        reason: j['reason'] as String?,
        quantitative: j['quantitative_outputs_enabled'] as bool,
        temperatureDomain: DomainDto.fromJson(j['temperature_domain'] as Json),
        holdDomain: DomainDto.fromJson(j['hold_domain'] as Json),
        physicalLimitC: _d(j['physical_limit_c']),
        protocol: j['protocol'] == null ? null : ProtocolSummary.fromJson(j['protocol'] as Json),
      );
}

class InterfaceConventions {
  InterfaceConventions({required this.furnaceMinC, required this.furnaceMaxC, required this.holdMaxMin});
  final double furnaceMinC, furnaceMaxC, holdMaxMin;
  factory InterfaceConventions.fromJson(Json j) => InterfaceConventions(
        furnaceMinC: _d(j['furnace_ui_min_c'])!,
        furnaceMaxC: _d(j['furnace_ui_max_c'])!,
        holdMaxMin: _d(j['hold_ui_max_min'])!,
      );
}

class PairsDto {
  PairsDto({required this.items, required this.interface});
  final List<PairDto> items;
  final InterfaceConventions interface;
  PairDto? byTreatment(String id) => items.where((p) => p.treatmentId == id).firstOrNull;
  factory PairsDto.fromJson(Json j) =>
      PairsDto(items: _l(j['items'], PairDto.fromJson), interface: InterfaceConventions.fromJson(j['interface'] as Json));
}

class WarningDto {
  WarningDto({required this.code, required this.severity, required this.message, this.field});
  final String code, severity, message;
  final String? field;
  bool get blocking => severity == 'blocking';
  factory WarningDto.fromJson(Json j) => WarningDto(
        code: j['code'] as String,
        severity: j['severity'] as String,
        message: j['message'] as String,
        field: j['field'] as String?,
      );
}

class ValidationReportDto {
  ValidationReportDto({required this.canRun, required this.predictedStatus, required this.quantitativeEligible,
      required this.warnings});
  final bool canRun, quantitativeEligible;
  final SimulationStatus predictedStatus;
  final List<WarningDto> warnings;
  factory ValidationReportDto.fromJson(Json j) => ValidationReportDto(
        canRun: j['can_run'] as bool,
        predictedStatus: SimulationStatus.fromWire(j['predicted_status'] as String)!,
        quantitativeEligible: j['quantitative_eligible'] as bool,
        warnings: _l(j['warnings'], WarningDto.fromJson),
      );
}

class ResultFact {
  ResultFact({required this.value, required this.unit, this.scale, this.fractionBasis, required this.method,
      required this.evidenceKind, required this.evidenceLevel, required this.sourceIds, this.modelVersion,
      this.uncertainty, this.validity});
  final double value;
  final String unit, method;
  final String? scale, fractionBasis, modelVersion;
  final EvidenceKind evidenceKind;
  final EvidenceLevel evidenceLevel;
  final List<String> sourceIds;
  final Json? uncertainty, validity;

  factory ResultFact.fromJson(Json j) => ResultFact(
        value: _d(j['value'])!,
        unit: j['unit'] as String,
        scale: j['scale'] as String?,
        fractionBasis: j['fraction_basis'] as String?,
        method: j['method'] as String,
        evidenceKind: EvidenceKind.fromWire(j['evidence_kind'] as String)!,
        evidenceLevel: EvidenceLevel.fromWire(j['evidence_level'] as String)!,
        sourceIds: _ls(j['source_ids']),
        modelVersion: j['model_version'] as String?,
        uncertainty: j['uncertainty'] as Json?,
        validity: j['validity'] as Json?,
      );
}

/// Una magnitud de resultado: un hecho único, un grupo (fracciones) o nada.
class QuantityResult {
  QuantityResult({required this.code, this.single, this.group, required this.level, required this.reason});
  final QuantityCode code;
  final ResultFact? single;
  final Map<String, ResultFact>? group;
  final EvidenceLevel level;
  final String reason;
  bool get available => single != null || (group?.isNotEmpty ?? false);
}

class ThermalPoint {
  ThermalPoint(this.tS, this.temperatureC, this.stageIndex);
  final double tS, temperatureC;
  final int stageIndex;
  factory ThermalPoint.fromJson(Json j) =>
      ThermalPoint(_d(j['t_s'])!, _d(j['temperature_c'])!, j['stage_index'] as int);
}

class ThermalStageDto {
  ThermalStageDto({required this.index, required this.kind, required this.labelKey, required this.tStart,
      required this.tEnd, required this.startC, required this.endC});
  final int index;
  final String kind, labelKey;
  final double tStart, tEnd, startC, endC;
  factory ThermalStageDto.fromJson(Json j) => ThermalStageDto(
        index: j['index'] as int,
        kind: j['kind'] as String,
        labelKey: j['label_key'] as String,
        tStart: _d(j['t_start_s'])!,
        tEnd: _d(j['t_end_s'])!,
        startC: _d(j['start_temperature_c'])!,
        endC: _d(j['end_temperature_c'])!,
      );
}

class SchematicSegment {
  SchematicSegment({required this.index, required this.kind, required this.labelKey, required this.endLevel,
      this.endTemperatureC, this.durationS, required this.isUserHold});
  final int index;
  final String kind, labelKey;
  final SchematicLevel endLevel;
  final double? endTemperatureC, durationS;
  final bool isUserHold;
  factory SchematicSegment.fromJson(Json j) => SchematicSegment(
        index: j['index'] as int,
        kind: j['kind'] as String,
        labelKey: j['label_key'] as String,
        endLevel: SchematicLevel.fromWire(j['end_level'] as String)!,
        endTemperatureC: _d(j['end_temperature_c']),
        durationS: _d(j['duration_s']),
        isUserHold: j['is_user_hold'] as bool,
      );
}

class ProtocolStageOut {
  ProtocolStageOut({required this.ordinal, required this.kind, required this.labelKey, required this.label,
      this.endTemperatureC, required this.endTemperatureBasis, this.durationS, required this.durationBasis});
  final int ordinal;
  final String kind, labelKey, label, endTemperatureBasis, durationBasis;
  final double? endTemperatureC, durationS;
  factory ProtocolStageOut.fromJson(Json j) => ProtocolStageOut(
        ordinal: j['ordinal'] as int,
        kind: j['kind'] as String,
        labelKey: j['label_key'] as String,
        label: j['label'] as String,
        endTemperatureC: _d(j['end_temperature_c']),
        endTemperatureBasis: j['end_temperature_basis'] as String,
        durationS: _d(j['duration_s']),
        durationBasis: j['duration_basis'] as String,
      );
}

class ProtocolOut {
  ProtocolOut({required this.id, required this.version, required this.reviewStatus, required this.medium,
      required this.mediumDocumented, this.variant, required this.fullySpecified, this.userHoldStageLabel,
      required this.stages});
  final String id, version, reviewStatus, medium;
  final bool mediumDocumented, fullySpecified;
  final String? variant, userHoldStageLabel;
  final List<ProtocolStageOut> stages;
  String labelFor(String key) => stages.where((s) => s.labelKey == key).firstOrNull?.label ?? key;
  factory ProtocolOut.fromJson(Json j) => ProtocolOut(
        id: j['id'] as String,
        version: j['version'] as String,
        reviewStatus: j['review_status'] as String,
        medium: j['medium'] as String,
        mediumDocumented: j['medium_documented'] as bool,
        variant: j['variant'] as String?,
        fullySpecified: j['fully_specified'] as bool,
        userHoldStageLabel: j['user_hold_stage_label'] as String?,
        stages: _l(j['stages'], ProtocolStageOut.fromJson),
      );
}

class MicrographDto {
  MicrographDto({required this.id, required this.imageUrl, required this.author, required this.attribution,
      required this.licenseCode, required this.licenseUrl, this.magnificationX, this.scaleBarUm,
      required this.imagingMethod, required this.matchQuality, required this.alt, required this.calibrated});
  final String id, imageUrl, author, attribution, licenseCode, licenseUrl, imagingMethod, matchQuality, alt;
  final double? magnificationX, scaleBarUm;
  final bool calibrated;
  factory MicrographDto.fromJson(Json j) => MicrographDto(
        id: j['id'] as String,
        imageUrl: j['image_url'] as String,
        author: j['author'] as String,
        attribution: j['attribution'] as String,
        licenseCode: j['license_code'] as String,
        licenseUrl: j['license_url'] as String,
        magnificationX: _d(j['magnification_x']),
        scaleBarUm: _d(j['scale_bar_um']),
        imagingMethod: j['imaging_method'] as String,
        matchQuality: j['match_quality'] as String,
        alt: j['alt'] as String,
        calibrated: j['calibrated'] as bool,
      );
}

class ExplanationDto {
  ExplanationDto({required this.reviewStatus, required this.treatmentPurpose, required this.prerequisites,
      required this.qualitativeOutcome, required this.materialDescription, required this.materialLimitations,
      required this.compatibilityReason});
  final String reviewStatus, treatmentPurpose, prerequisites, qualitativeOutcome, materialDescription,
      compatibilityReason;
  final List<String> materialLimitations;
  factory ExplanationDto.fromJson(Json j) => ExplanationDto(
        reviewStatus: j['review_status'] as String,
        treatmentPurpose: j['treatment_purpose'] as String,
        prerequisites: j['prerequisites'] as String,
        qualitativeOutcome: j['qualitative_outcome'] as String,
        materialDescription: j['material_description'] as String,
        materialLimitations: _ls(j['material_limitations']),
        compatibilityReason: j['compatibility_reason'] as String,
      );
}

class SimulationInput {
  SimulationInput({required this.materialId, required this.treatmentId, this.initialConditionId,
      required this.targetTemperatureC, required this.holdTimeMin});
  final String materialId, treatmentId;
  final String? initialConditionId;
  final double targetTemperatureC, holdTimeMin;
  Json toJson(String locale) => {
        'material_id': materialId,
        'treatment_id': treatmentId,
        if (initialConditionId != null) 'initial_condition_id': initialConditionId,
        'target_temperature_c': targetTemperatureC,
        'hold_time_min': holdTimeMin,
        'locale': locale,
      };
  factory SimulationInput.fromJson(Json j) => SimulationInput(
        materialId: j['material_id'] as String,
        treatmentId: j['treatment_id'] as String,
        initialConditionId: j['initial_condition_id'] as String?,
        targetTemperatureC: _d(j['target_temperature_c'])!,
        holdTimeMin: _d(j['hold_time_min'])!,
      );
}

class SimulationResultDto {
  SimulationResultDto({required this.raw, required this.requestId, required this.requestHash, required this.status,
      required this.datasetVersion, required this.unreviewed, this.protocolVersion, required this.engineVersion,
      this.modelVersion, required this.input, this.compatibility, required this.materialName,
      this.initialCondition, this.protocol, required this.thermalHistory, required this.thermalStages,
      this.schematic, required this.quantities, this.micrograph, required this.warnings, required this.evidence,
      required this.assumptions, required this.explanation});

  final Json raw;
  final String? requestId, protocolVersion, modelVersion;
  final String requestHash, datasetVersion, engineVersion, materialName;
  final SimulationStatus status;
  final bool unreviewed;
  final SimulationInput input;
  final CompatibilityStatus? compatibility;
  final InitialConditionDto? initialCondition;
  final ProtocolOut? protocol;
  final List<ThermalPoint> thermalHistory;
  final List<ThermalStageDto> thermalStages;
  final List<SchematicSegment>? schematic;
  final List<QuantityResult> quantities;
  final MicrographDto? micrograph;
  final List<WarningDto> warnings;
  final List<SourceRef> evidence;
  final List<String> assumptions;
  final ExplanationDto explanation;

  bool get hasPhysicalHistory => thermalHistory.length >= 2;
  bool get playable => hasPhysicalHistory || (schematic?.isNotEmpty ?? false);

  factory SimulationResultDto.fromJson(Json j) {
    final results = j['results'] as Json;
    final status = j['result_status'] as Json;
    final quantities = QuantityCode.values.map((q) {
      final v = results[q.wire];
      final st = status[q.wire] as Json;
      ResultFact? single;
      Map<String, ResultFact>? group;
      if (v is Map<String, dynamic>) {
        if (v.containsKey('value')) {
          single = ResultFact.fromJson(v);
        } else {
          group = v.map((k, e) => MapEntry(k, ResultFact.fromJson(e as Json)));
        }
      }
      return QuantityResult(
        code: q,
        single: single,
        group: group,
        level: EvidenceLevel.fromWire(st['evidence_level'] as String)!,
        reason: st['reason'] as String,
      );
    }).toList();
    final schem = j['schematic_cycle'] as Json?;
    return SimulationResultDto(
      raw: j,
      requestId: j['request_id'] as String?,
      requestHash: j['request_hash'] as String,
      status: SimulationStatus.fromWire(j['simulation_status'] as String)!,
      datasetVersion: j['dataset_version'] as String,
      unreviewed: j['dataset_contains_unreviewed_content'] as bool,
      protocolVersion: j['protocol_version'] as String?,
      engineVersion: j['engine_version'] as String,
      modelVersion: j['model_version'] as String?,
      input: SimulationInput.fromJson(j['input'] as Json),
      compatibility: CompatibilityStatus.fromWire(j['compatibility_status'] as String?),
      materialName: (j['material'] as Json)['display_name'] as String,
      initialCondition:
          j['initial_condition'] == null ? null : InitialConditionDto.fromJson(j['initial_condition'] as Json),
      protocol: j['protocol'] == null ? null : ProtocolOut.fromJson(j['protocol'] as Json),
      thermalHistory: _l(j['thermal_history'], ThermalPoint.fromJson),
      thermalStages: _l(j['thermal_stages'], ThermalStageDto.fromJson),
      schematic: schem == null ? null : _l(schem['segments'], SchematicSegment.fromJson),
      quantities: quantities,
      micrograph: j['micrograph'] == null ? null : MicrographDto.fromJson(j['micrograph'] as Json),
      warnings: _l(j['warnings'], WarningDto.fromJson),
      evidence: _l(j['evidence'], SourceRef.fromJson),
      assumptions: (j['assumptions'] as List).map((a) => (a as Json)['text'] as String).toList(),
      explanation: ExplanationDto.fromJson(j['explanation'] as Json),
    );
  }
}

class KnowledgeEntryDto {
  KnowledgeEntryDto({required this.slug, required this.category, required this.title, required this.body,
      required this.related, required this.sources, required this.reviewStatus});
  final String slug, category, title, body, reviewStatus;
  final List<String> related;
  final List<SourceRef> sources;
  factory KnowledgeEntryDto.fromJson(Json j) => KnowledgeEntryDto(
        slug: j['slug'] as String,
        category: j['category'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        related: _ls(j['related_slugs']),
        sources: _l(j['suggested_sources'], SourceRef.fromJson),
        reviewStatus: j['review_status'] as String,
      );
}

class PracticeQuestionDto {
  PracticeQuestionDto({required this.id, required this.prompt, required this.options, required this.correctIndex,
      required this.feedback, this.relatedSlug});
  final String id, prompt, feedback;
  final List<String> options;
  final int correctIndex;
  final String? relatedSlug;
  factory PracticeQuestionDto.fromJson(Json j) => PracticeQuestionDto(
        id: j['id'] as String,
        prompt: j['prompt'] as String,
        options: _ls(j['options']),
        correctIndex: j['correct_index'] as int,
        feedback: j['feedback'] as String,
        relatedSlug: j['related_slug'] as String?,
      );
}

class TutorClaim {
  TutorClaim(this.claim, this.sourceIds);
  final String claim;
  final List<String> sourceIds;
}

class TutorResponseDto {
  TutorResponseDto({required this.mode, required this.summary, required this.explanations,
      required this.limitations, required this.related, this.notice});
  final String mode, summary;
  final List<TutorClaim> explanations;
  final List<String> limitations, related;
  final String? notice;
  bool get isAi => mode == 'ai';
  factory TutorResponseDto.fromJson(Json j) => TutorResponseDto(
        mode: j['mode'] as String,
        summary: j['summary'] as String,
        explanations: (j['explanations'] as List)
            .map((e) => TutorClaim((e as Json)['claim'] as String, _ls(e['source_ids'])))
            .toList(),
        limitations: _ls(j['limitations']),
        related: _ls(j['related_slugs']),
        notice: j['notice'] as String?,
      );
}

class HealthDto {
  HealthDto({required this.datasetVersion, required this.unreviewed, required this.aiEnabled,
      required this.adminAvailable, required this.adminDevLogin, this.supabaseUrl, this.supabaseAnonKey,
      required this.engineVersion});
  final String datasetVersion, engineVersion;
  final bool unreviewed, aiEnabled, adminAvailable, adminDevLogin;
  final String? supabaseUrl, supabaseAnonKey;
  factory HealthDto.fromJson(Json j) => HealthDto(
        datasetVersion: j['dataset_version'] as String,
        engineVersion: j['engine_version'] as String,
        unreviewed: j['dataset_contains_unreviewed_content'] as bool,
        aiEnabled: j['ai_enabled'] as bool,
        adminAvailable: j['admin_available'] as bool,
        adminDevLogin: j['admin_dev_login'] as bool,
        supabaseUrl: j['supabase_url'] as String?,
        supabaseAnonKey: j['supabase_anon_key'] as String?,
      );
}
