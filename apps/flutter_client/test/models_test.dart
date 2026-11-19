import 'package:ferrolab/features/simulation/playback.dart';
import 'package:ferrolab/features/teacher/teacher_screen.dart';
import 'package:ferrolab/shared/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('contrato: resultado insuficiente conserva null (nunca 0)', () {
    final r = SimulationResultDto.fromJson(fixture('sim_quench_850'));
    expect(r.status, SimulationStatus.insufficientEvidence);
    expect(r.quantities, hasLength(5));
    for (final q in r.quantities) {
      expect(q.available, isFalse);
      expect(q.single, isNull);
      expect(q.level, EvidenceLevel.insufficientEvidence);
    }
    expect(r.hasPhysicalHistory, isFalse);
    expect(r.schematic, isNotEmpty);
    expect(r.protocol!.reviewStatus, 'draft');
  });

  test('1600 °C: entrada inválida sin ciclo que reproducir', () {
    final r = SimulationResultDto.fromJson(fixture('sim_1600'));
    expect(r.status, SimulationStatus.invalidInput);
    expect(r.warnings.any((w) => w.code == 'TEMPERATURE_ABOVE_PHYSICAL_LIMIT' && w.blocking), isTrue);
    expect(Playback.from(r), isNull);
  });

  test('A48 austempering (EN): baño sin cifra en el esquema', () {
    final r = SimulationResultDto.fromJson(fixture('sim_a48_austemper_en'));
    final bath = r.schematic!.where((s) => s.endLevel == SchematicLevel.bath);
    expect(bath, isNotEmpty);
    expect(bath.every((s) => s.endTemperatureC == null && s.durationS == null), isTrue);
    expect(r.warnings.any((w) => w.code == 'CAST_IRON_NO_STEEL_MODELS'), isTrue);
  });

  test('reproductor esquemático: solo cifras del estudiante, sin tiempo físico', () {
    final r = SimulationResultDto.fromJson(fixture('sim_quench_850'));
    final pb = Playback.from(r)!;
    expect(pb.physical, isFalse);
    expect(pb.speedFactor, isNull);
    for (var t = 0.0; t <= pb.totalDisplay; t += .5) {
      final f = pb.frameAt(t);
      expect(f.temperatureC, isNull); // no se inventa una lectura intermedia
      expect(f.physicalTimeS, isNull);
    }
  });

  test('reproductor físico: la velocidad cambia la animación, no la física', () {
    // Historial sintético de ÁLGEBRA (no metalurgia): forma del contrato thermal_stages.
    final j = fixture('sim_quench_850');
    j['thermal_history'] = [
      {'t_s': 0, 'temperature_c': 20, 'stage_index': 0},
      {'t_s': 100, 'temperature_c': 120, 'stage_index': 0},
      {'t_s': 160, 'temperature_c': 120, 'stage_index': 1},
    ];
    j['thermal_stages'] = [
      {'index': 0, 'kind': 'heat', 'label_key': 'a', 't_start_s': 0, 't_end_s': 100, 'start_temperature_c': 20,
        'end_temperature_c': 120, 'profile_kind': 'x', 'evidence_ids': []},
      {'index': 1, 'kind': 'hold', 'label_key': 'b', 't_start_s': 100, 't_end_s': 160, 'start_temperature_c': 120,
        'end_temperature_c': 120, 'profile_kind': 'x', 'evidence_ids': []},
    ];
    final pb = Playback.from(SimulationResultDto.fromJson(j))!;
    expect(pb.physical, isTrue);
    // Ritmo por etapa (logarítmico): el factor medio es tiempo físico / tiempo de pantalla.
    expect(pb.speedFactor, closeTo(160 / pb.totalDisplay, 1e-9));
    final end = pb.frameAt(pb.totalDisplay);
    expect(end.physicalTimeS, 160);
    expect(end.temperatureC, 120);
    final mid = pb.frameAt(pb.segments.first.displayEnd / 2);
    expect(mid.physicalTimeS, closeTo(50, 1e-6));
    expect(mid.temperatureC, closeTo(70, 1e-6)); // interpolado sobre los puntos del historial del FSE
  });

  test('código de actividad: ida y vuelta y rechazo de basura', () {
    final i = SimulationInput(materialId: 'aisi_8620', treatmentId: 'normalize', targetTemperatureC: 900, holdTimeMin: 20);
    final back = ActivityCode.decode(ActivityCode.encode(i))!;
    expect((back.materialId, back.treatmentId, back.targetTemperatureC, back.holdTimeMin),
        ('aisi_8620', 'normalize', 900.0, 20.0));
    expect(ActivityCode.decode('FL-hola'), isNull);
    expect(ActivityCode.decode(''), isNull);
  });
}
