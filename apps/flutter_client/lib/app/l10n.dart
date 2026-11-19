import 'package:material_ui/material_ui.dart';

import '../shared/models/models.dart';
import 'localization/gen/app_localizations.dart';

export 'localization/gen/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this);
}

extension EnumLabels on AppLocalizations {
  String compat(CompatibilityStatus? s) => switch (s) {
        CompatibilityStatus.supported => compat_supported,
        CompatibilityStatus.conditional => compat_conditional,
        CompatibilityStatus.educationalOnly => compat_educational_only,
        CompatibilityStatus.unsupported || null => compat_unsupported,
      };

  String status(SimulationStatus s) => switch (s) {
        SimulationStatus.completed => status_completed,
        SimulationStatus.partialResult => status_partial_result,
        SimulationStatus.insufficientEvidence => status_insufficient_evidence,
        SimulationStatus.unsupported => status_unsupported,
        SimulationStatus.invalidInput => status_invalid_input,
        SimulationStatus.internalError => status_internal_error,
      };

  String level(EvidenceLevel l) => switch (l) {
        EvidenceLevel.validated => evidence_validated,
        EvidenceLevel.boundedEstimate => evidence_bounded_estimate,
        EvidenceLevel.qualitative => evidence_qualitative,
        EvidenceLevel.insufficientEvidence => evidence_insufficient_evidence,
        EvidenceLevel.unsupported => evidence_unsupported,
      };

  String kind(EvidenceKind k) => switch (k) {
        EvidenceKind.measured => kind_measured,
        EvidenceKind.literature => kind_literature,
        EvidenceKind.modeled => kind_modeled,
        EvidenceKind.illustrative => kind_illustrative,
        EvidenceKind.unavailable => kind_unavailable,
      };

  String quantity(QuantityCode q) => switch (q) {
        QuantityCode.phaseFractions => q_phase_fractions,
        QuantityCode.microconstituentFractions => q_microconstituent_fractions,
        QuantityCode.hardness => q_hardness,
        QuantityCode.grainSize => q_grain_size,
        QuantityCode.mechanicalProperties => q_mechanical_properties,
      };

  /// Nombre de constituyente o fase (claves del contrato del FSE).
  String constituent(String key) => switch (key) {
        'proeutectoid_ferrite' => constFerrite,
        'pearlite' => constPearlite,
        'bainite' => constBainite,
        'martensite' => constMartensite,
        'tempered_martensite' => constTemperedMartensite,
        'retained_austenite' => constRetained,
        'graphite_flakes' || 'graphite' => constGraphite,
        'spheroidized_cementite' => constSpheroidite,
        'graphite_nodules' => constNodules,
        'ausferrite' => constAusferrite,
        'proeutectoid_cementite' => constProeutectoidCementite,
        'ferrite' => phaseFerrite,
        'cementite' => phaseCementite,
        'austenite' => phaseAustenite,
        _ => key,
      };

  String grayMatrix(String key) => switch (key) {
        'ferrite_pearlite' => grayMatrixFerritePearlite,
        'martensite' => grayMatrixMartensite,
        'tempered_martensite' => grayMatrixTempered,
        'ausferrite' => grayMatrixAusferrite,
        _ => grayMatrixPearlite,
      };

  String medium(String code) => switch (code) {
        'water' => mediumWater,
        'oil' => mediumOil,
        'air' => mediumAir,
        'furnace' => mediumFurnace,
        'salt_bath' => mediumSaltBath,
        'tin_bath' => mediumTinBath,
        _ => code,
      };

  String goal(String g) => switch (g) {
        'hardness' => goalHardness,
        'toughness' => goalToughness,
        'softening' => goalSoftening,
        'stress_relief' => goalStressRelief,
        'experimental' => goalExperimental,
        'machinability' => goalMachinability,
        'pending' => goalPending,
        _ => goalReference,
      };

  String basis(String b) => switch (b) {
        'source' => basisSource,
        'rule' => basisRule,
        'model' => basisModel,
        'computed' => basisComputed,
        _ => basisPending,
      };

  String microReason(String r) => switch (r) {
        'no_austenitization' => microReasonNoAustenitization,
        'outside_range' => microReasonOutsideRange,
        'carburized_case' => microReasonCarburized,
        'not_modeled' => microReasonNotModeled,
        'unverified' => microReasonUnverified,
        'theory' => microReasonTheory,
        'invalid_input' => microReasonInvalid,
        _ => microReasonNotComputed,
      };

  String microMatchLabel(String m) => switch (m) {
        'exact' => matchExact,
        'comparable' => matchComparable,
        'illustrative' => matchIllustrative,
        _ => matchNone,
      };
}
