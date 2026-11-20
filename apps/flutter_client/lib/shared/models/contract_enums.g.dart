// GENERADO por scripts/gen_contracts.py — no editar a mano.
// ignore_for_file: constant_identifier_names

enum MaterialId {
  aisi1045('aisi_1045'),
  aisi8620('aisi_8620'),
  astmA48Class35('astm_a48_class_35');

  const MaterialId(this.wire);
  final String wire;

  static MaterialId? fromWire(String? w) {
    for (final v in MaterialId.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}

enum TreatmentId {
  quench('quench'),
  temper('temper'),
  anneal('anneal'),
  normalize('normalize'),
  austemper('austemper'),
  martemper('martemper'),
  quenchTemper('quench_temper');

  const TreatmentId(this.wire);
  final String wire;

  static TreatmentId? fromWire(String? w) {
    for (final v in TreatmentId.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}

enum MaterialFamily {
  steel('steel'),
  grayCastIron('gray_cast_iron');

  const MaterialFamily(this.wire);
  final String wire;

  static MaterialFamily? fromWire(String? w) {
    for (final v in MaterialFamily.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}

enum CompatibilityStatus {
  supported('supported'),
  conditional('conditional'),
  educationalOnly('educational_only'),
  unsupported('unsupported');

  const CompatibilityStatus(this.wire);
  final String wire;

  static CompatibilityStatus? fromWire(String? w) {
    for (final v in CompatibilityStatus.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}

enum SimulationStatus {
  completed('completed'),
  partialResult('partial_result'),
  insufficientEvidence('insufficient_evidence'),
  unsupported('unsupported'),
  invalidInput('invalid_input'),
  internalError('internal_error');

  const SimulationStatus(this.wire);
  final String wire;

  static SimulationStatus? fromWire(String? w) {
    for (final v in SimulationStatus.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}

enum EvidenceKind {
  measured('measured'),
  literature('literature'),
  modeled('modeled'),
  illustrative('illustrative'),
  unavailable('unavailable');

  const EvidenceKind(this.wire);
  final String wire;

  static EvidenceKind? fromWire(String? w) {
    for (final v in EvidenceKind.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}

enum EvidenceLevel {
  validated('validated'),
  boundedEstimate('bounded_estimate'),
  qualitative('qualitative'),
  insufficientEvidence('insufficient_evidence'),
  unsupported('unsupported');

  const EvidenceLevel(this.wire);
  final String wire;

  static EvidenceLevel? fromWire(String? w) {
    for (final v in EvidenceLevel.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}

enum ReviewStatus {
  draft('draft'),
  reviewed('reviewed'),
  published('published'),
  retired('retired');

  const ReviewStatus(this.wire);
  final String wire;

  static ReviewStatus? fromWire(String? w) {
    for (final v in ReviewStatus.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}

enum StageKind {
  heat('heat'),
  hold('hold'),
  transfer('transfer'),
  cool('cool'),
  isothermalHold('isothermal_hold');

  const StageKind(this.wire);
  final String wire;

  static StageKind? fromWire(String? w) {
    for (final v in StageKind.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}

enum SchematicLevel {
  ambient('ambient'),
  target('target'),
  bath('bath');

  const SchematicLevel(this.wire);
  final String wire;

  static SchematicLevel? fromWire(String? w) {
    for (final v in SchematicLevel.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}

enum QuantityCode {
  phaseFractions('phase_fractions'),
  microconstituentFractions('microconstituent_fractions'),
  hardness('hardness'),
  grainSize('grain_size'),
  mechanicalProperties('mechanical_properties');

  const QuantityCode(this.wire);
  final String wire;

  static QuantityCode? fromWire(String? w) {
    for (final v in QuantityCode.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}

enum MatchQuality {
  exact('exact'),
  comparable('comparable'),
  illustrative('illustrative'),
  noneValue('none');

  const MatchQuality(this.wire);
  final String wire;

  static MatchQuality? fromWire(String? w) {
    for (final v in MatchQuality.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}

enum AdminRole {
  editor('editor'),
  reviewer('reviewer'),
  admin('admin');

  const AdminRole(this.wire);
  final String wire;

  static AdminRole? fromWire(String? w) {
    for (final v in AdminRole.values) {
      if (v.wire == w) return v;
    }
    return null;
  }
}
