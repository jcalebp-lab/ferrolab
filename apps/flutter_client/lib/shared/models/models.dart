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

/// Parámetro editable de un protocolo, con su rango y el fundamento de cada cifra.
class ProtocolParam {
  ProtocolParam({required this.key, required this.unit, this.value, this.min, this.max, this.ref, required this.basis,
      this.rule, required this.editable, required this.outside});
  final String key, unit, basis; // basis: source | rule | model | pending | computed
  final double? value, min, max, ref;
  final String? rule;
  final bool editable, outside;
  bool inRange(double v) => (min == null || v >= min! - 1e-6) && (max == null || v <= max! + 1e-6);
  factory ProtocolParam.fromJson(Json j) => ProtocolParam(
        key: j['key'] as String,
        unit: j['unit'] as String,
        value: _d(j['value']),
        min: _d(j['min']),
        max: _d(j['max']),
        ref: _d(j['ref']),
        basis: j['basis'] as String,
        rule: j['rule'] as String?,
        editable: j['editable'] as bool? ?? true,
        outside: j['outside'] as bool? ?? false,
      );
}

class ProtocolStageCard {
  ProtocolStageCard({required this.ordinal, required this.kind, this.role, required this.label, this.medium,
      this.mediumNote, this.temperatureC, this.tMin, this.tMax, this.tRef, this.durationS, this.dMin, this.dMax,
      this.dRef, this.rateCPerH, this.untilC, this.param, this.timeParam, this.rule, this.startCondition, this.purpose,
      required this.temperatureMode, required this.durationMode});
  final int ordinal;
  final String kind, label, temperatureMode, durationMode;
  final String? role, medium, mediumNote, param, timeParam, rule, startCondition, purpose;
  final double? temperatureC, tMin, tMax, tRef, durationS, dMin, dMax, dRef, rateCPerH, untilC;
  bool get isBath => kind == 'isothermal_hold';
  factory ProtocolStageCard.fromJson(Json j) => ProtocolStageCard(
        ordinal: j['ordinal'] as int,
        kind: j['kind'] as String,
        role: j['role'] as String?,
        label: j['label'] as String? ?? j['label_key'] as String,
        medium: j['medium'] as String?,
        mediumNote: j['medium_note'] as String?,
        temperatureC: _d(j['temperature_c']),
        tMin: _d(j['temperature_min_c']),
        tMax: _d(j['temperature_max_c']),
        tRef: _d(j['temperature_ref_c']),
        durationS: _d(j['duration_s']),
        dMin: _d(j['duration_min_s']),
        dMax: _d(j['duration_max_s']),
        dRef: _d(j['duration_ref_s']),
        rateCPerH: _d(j['rate_c_per_h']),
        untilC: _d(j['until_c']),
        param: j['param'] as String?,
        timeParam: j['time_param'] as String?,
        rule: j['rule'] as String?,
        startCondition: j['start_condition'] as String?,
        purpose: j['purpose'] as String?,
        temperatureMode: j['temperature_mode'] as String? ?? '',
        durationMode: j['duration_mode'] as String? ?? '',
      );
}

class ProtocolSourceCard {
  ProtocolSourceCard({required this.id, required this.title, this.authors, this.year, this.url, required this.verified});
  final String id, title;
  final String? authors, url;
  final int? year;
  final bool verified;
  factory ProtocolSourceCard.fromJson(Json j) => ProtocolSourceCard(
        id: j['id'] as String,
        title: j['title'] as String,
        authors: j['authors'] as String?,
        year: j['year'] as int?,
        url: j['url'] as String?,
        verified: j['verification_status'] == 'verified',
      );
}

/// Ficha científica de un protocolo de la biblioteca (D-30).
class ProtocolCard {
  ProtocolCard({required this.id, required this.name, this.objective, required this.goal, required this.isReference,
      required this.evidenceStatus, required this.medium, this.materialCondition, this.expected,
      required this.restrictions, required this.assumptions, required this.missing, required this.publishedResults,
      required this.stages, required this.sources, required this.params, required this.modelApplicable,
      this.priorProtocolId, this.modelWindow});
  final String id, name, goal, evidenceStatus, medium;
  final String? objective, materialCondition, expected, priorProtocolId;
  final bool isReference, modelApplicable;
  final List<String> restrictions, assumptions, missing, publishedResults;
  final List<ProtocolStageCard> stages;
  final List<ProtocolSourceCard> sources;
  final Map<String, ProtocolParam> params;
  final Json? modelWindow;
  bool get verified => evidenceStatus == 'source_verified';
  ProtocolParam? param(String k) => params[k];
  factory ProtocolCard.fromJson(Json j) => ProtocolCard(
        id: j['id'] as String,
        name: j['name'] as String? ?? j['id'] as String,
        objective: j['objective'] as String?,
        goal: j['goal'] as String? ?? 'reference',
        isReference: j['is_reference'] as bool? ?? false,
        evidenceStatus: j['evidence_status'] as String? ?? 'pending_research',
        medium: j['medium'] as String? ?? '—',
        materialCondition: j['material_condition'] as String?,
        expected: j['expected'] as String?,
        restrictions: _ls(j['restrictions']),
        assumptions: _ls(j['assumptions']),
        missing: _ls(j['missing']),
        publishedResults: ((j['published_results'] as List?) ?? const []).map((e) => (e as Json)['text'].toString()).toList(),
        stages: _l(j['stages'], ProtocolStageCard.fromJson),
        sources: _l(j['sources'], ProtocolSourceCard.fromJson),
        params: ((j['params'] as Json?) ?? const {}).map((k, v) => MapEntry(k, ProtocolParam.fromJson(v as Json))),
        modelApplicable: j['model_applicable'] as bool? ?? false,
        priorProtocolId: j['prior_protocol_id'] as String?,
        modelWindow: j['model_window'] as Json?,
      );
}

class Headline {
  Headline({required this.code, required this.kind, required this.message});
  final String code, kind, message;
  factory Headline.fromJson(Json j) =>
      Headline(code: j['code'] as String, kind: j['kind'] as String, message: j['message'] as String);
}

class PairDto {
  PairDto({required this.treatmentId, required this.name, required this.compatibility, this.reason,
      required this.quantitative, required this.temperatureDomain, required this.holdDomain, this.physicalLimitC,
      this.protocol, this.referenceProtocol, this.protocols = const [], this.resultLevel, this.headline});
  final String treatmentId, name;
  final CompatibilityStatus compatibility;
  final String? reason;
  final bool quantitative;
  final DomainDto temperatureDomain, holdDomain;
  final double? physicalLimitC;
  final ProtocolSummary? protocol;
  final ProtocolCard? referenceProtocol;
  final List<ProtocolCard> protocols;
  final String? resultLevel;
  final Headline? headline;
  ProtocolCard? protocolById(String? id) => protocols.where((p) => p.id == id).firstOrNull ?? referenceProtocol;

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
        referenceProtocol:
            j['reference_protocol'] == null ? null : ProtocolCard.fromJson(j['reference_protocol'] as Json),
        protocols: _l(j['protocols'], ProtocolCard.fromJson),
        resultLevel: j['result_level'] as String?,
        headline: j['headline'] == null ? null : Headline.fromJson(j['headline'] as Json),
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
  WarningDto({required this.code, required this.severity, required this.message, this.field, this.group});
  final String code, severity, message;
  final String? field, group;
  bool get blocking => severity == 'blocking';
  factory WarningDto.fromJson(Json j) => WarningDto(
        code: j['code'] as String,
        severity: j['severity'] as String,
        message: j['message'] as String,
        field: j['field'] as String?,
        group: j['group'] as String?,
      );
}

class ValidationReportDto {
  ValidationReportDto({required this.canRun, required this.predictedStatus, required this.quantitativeEligible,
      required this.warnings, this.resultLevel, this.headline, this.protocol, this.initialConditionId});
  final bool canRun, quantitativeEligible;
  final SimulationStatus predictedStatus;
  final List<WarningDto> warnings;
  final String? resultLevel, initialConditionId;
  final Headline? headline;
  final ProtocolCard? protocol;
  factory ValidationReportDto.fromJson(Json j) => ValidationReportDto(
        canRun: j['can_run'] as bool,
        predictedStatus: SimulationStatus.fromWire(j['predicted_status'] as String)!,
        quantitativeEligible: j['quantitative_eligible'] as bool,
        warnings: _l(j['warnings'], WarningDto.fromJson),
        resultLevel: j['result_level'] as String?,
        headline: j['headline'] == null ? null : Headline.fromJson(j['headline'] as Json),
        protocol: j['protocol'] == null ? null : ProtocolCard.fromJson(j['protocol'] as Json),
        initialConditionId: j['initial_condition_id'] as String?,
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
      required this.tEnd, required this.startC, required this.endC, this.medium});
  final int index;
  final String kind, labelKey;
  final String? medium;
  final double tStart, tEnd, startC, endC;
  factory ThermalStageDto.fromJson(Json j) => ThermalStageDto(
        index: j['index'] as int,
        kind: j['kind'] as String,
        labelKey: j['label_key'] as String,
        tStart: _d(j['t_start_s'])!,
        tEnd: _d(j['t_end_s'])!,
        startC: _d(j['start_temperature_c'])!,
        endC: _d(j['end_temperature_c'])!,
        medium: j['medium'] as String?,
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
      required this.imagingMethod, required this.matchQuality, required this.alt, required this.calibrated,
      this.specimen, this.pageUrl, this.thumbnailUrl, this.family, this.constituents = const [], this.preparation,
      this.localUrl});
  final String id, imageUrl, author, attribution, licenseCode, licenseUrl, imagingMethod, matchQuality, alt;
  final String? specimen, pageUrl, thumbnailUrl, family, preparation, localUrl;
  final List<String> constituents;
  final double? magnificationX, scaleBarUm;
  final bool calibrated;
  /// Imagen para pantalla: la copia servida por FERROLAB (ruta relativa al servidor) o, si no existe, la miniatura.
  String displayUrl(String serverBase) => localUrl != null ? '$serverBase$localUrl' : (thumbnailUrl ?? imageUrl);
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
        specimen: j['specimen'] as String?,
        pageUrl: j['page_url'] as String?,
        thumbnailUrl: j['thumbnail_url'] as String?,
        family: j['family'] as String?,
        constituents: _ls(j['constituents']),
        preparation: j['preparation'] as String?,
        localUrl: j['display_url'] as String?,
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
      required this.targetTemperatureC, required this.holdTimeMin, this.protocolId, this.bathTemperatureC,
      this.bathTimeMin, this.priorMode = 'reference', this.priorProtocolId, this.priorTemperatureC, this.priorHoldMin});
  final String materialId, treatmentId, priorMode;
  final String? initialConditionId, protocolId, priorProtocolId;
  final double targetTemperatureC, holdTimeMin;
  final double? bathTemperatureC, bathTimeMin, priorTemperatureC, priorHoldMin;
  Json toJson(String locale) => {
        'material_id': materialId,
        'treatment_id': treatmentId,
        if (initialConditionId != null) 'initial_condition_id': initialConditionId,
        'target_temperature_c': targetTemperatureC,
        'hold_time_min': holdTimeMin,
        if (protocolId != null) 'protocol_id': protocolId,
        if (bathTemperatureC != null) 'bath_temperature_c': bathTemperatureC,
        if (bathTimeMin != null) 'bath_time_min': bathTimeMin,
        if (treatmentId == 'temper') 'prior_mode': priorMode,
        if (treatmentId == 'temper' && priorProtocolId != null) 'prior_protocol_id': priorProtocolId,
        if (treatmentId == 'temper' && priorTemperatureC != null) 'prior_temperature_c': priorTemperatureC,
        if (treatmentId == 'temper' && priorHoldMin != null) 'prior_hold_min': priorHoldMin,
        'locale': locale,
      };
  factory SimulationInput.fromJson(Json j) => SimulationInput(
        materialId: j['material_id'] as String,
        treatmentId: j['treatment_id'] as String,
        initialConditionId: j['initial_condition_id'] as String?,
        targetTemperatureC: _d(j['target_temperature_c'])!,
        holdTimeMin: _d(j['hold_time_min'])!,
        protocolId: j['protocol_id'] as String?,
        bathTemperatureC: _d(j['bath_temperature_c']),
        bathTimeMin: _d(j['bath_time_min']),
        priorMode: j['prior_mode'] as String? ?? 'reference',
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

  /// Diagramas TTT/CCT calculados para el material, con la trayectoria de la práctica.
  List<DiagramDto> get diagrams => ((raw['diagrams'] as List?) ?? const []).map((d) => DiagramDto.fromJson(d as Json)).toList();
  Json? get illustration => raw['microstructure_illustration'] as Json?;
  List<MicrographDto> get relatedMicrographs =>
      ((raw['related_micrographs'] as List?) ?? const []).map((e) => MicrographDto.fromJson(e as Json)).toList();
  Json? get modelEstimate => raw['model_estimate'] as Json?;
  ProtocolCard? get protocolCard => raw['protocol_card'] == null ? null : ProtocolCard.fromJson(raw['protocol_card'] as Json);
  String? get resultLevel => raw['result_level'] as String?;
  Headline? get headline => raw['headline'] == null ? null : Headline.fromJson(raw['headline'] as Json);
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


class DiagramCurve {
  DiagramCurve({required this.name, required this.reaction, required this.points});
  final String name, reaction;
  final List<(double, double)> points; // (t_s, °C)
  factory DiagramCurve.fromJson(Json j) => DiagramCurve(
        name: j['name'] as String,
        reaction: j['reaction'] as String,
        points: (j['points'] as List).map((p) => (_d((p as List)[0])!, _d(p[1])!)).toList(),
      );
}

class DiagramDto {
  DiagramDto({required this.kind, required this.curves, required this.lines, required this.userPath, required this.runs});
  final String kind; // TTT | CCT
  final List<DiagramCurve> curves;
  final Map<String, double> lines;
  final List<(double, double)> userPath;
  final List<Json> runs;
  factory DiagramDto.fromJson(Json j) => DiagramDto(
        kind: j['kind'] as String,
        curves: _l(j['curves'], DiagramCurve.fromJson),
        lines: ((j['lines'] as Json?) ?? const {}).map((k, v) => MapEntry(k, _d(v)!)),
        userPath: ((j['user_path'] as List?) ?? const []).map((p) => (_d((p as List)[0])!, _d(p[1])!)).toList(),
        runs: ((j['runs'] as List?) ?? const []).cast<Json>(),
      );
}
