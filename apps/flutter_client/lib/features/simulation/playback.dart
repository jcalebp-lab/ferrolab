// Reproductor del ciclo térmico. Solo REPRODUCE el historial devuelto por el FSE:
// t_display = t_physical / speed (doc 04 §13.3). No modifica tiempos ni resultados.
import '../../shared/models/models.dart';

const _schematicDisplay = {'heat': 3.0, 'hold': 2.5, 'transfer': 1.0, 'cool': 3.0, 'isothermal_hold': 2.5};
const physicalDisplayTotalS = 12.0;

class PlaybackSegment {
  PlaybackSegment({required this.kind, required this.labelKey, required this.displayStart, required this.displayEnd,
      required this.visualStart, required this.visualEnd, this.physStart, this.physEnd, this.tempStart, this.tempEnd,
      this.schematic});
  final String kind, labelKey;
  final double displayStart, displayEnd, visualStart, visualEnd;
  final double? physStart, physEnd, tempStart, tempEnd; // null en modo esquemático
  final SchematicSegment? schematic;
  bool get inFurnace => kind == 'heat' || kind == 'hold';
}

class PlaybackFrame {
  PlaybackFrame({required this.segment, required this.index, required this.visualTemp, this.temperatureC,
      this.physicalTimeS, required this.displayTimeS});
  final PlaybackSegment segment;
  final int index;
  final double visualTemp, displayTimeS;
  final double? temperatureC, physicalTimeS; // lectura numérica SOLO si viene del historial físico
}

class Playback {
  Playback._(this.segments, this.totalDisplay, this.speedFactor, this.physical);
  final List<PlaybackSegment> segments;
  final double totalDisplay;
  final double? speedFactor;
  final bool physical;

  static Playback? from(SimulationResultDto r, {double ambientVisual = 20}) {
    if (r.hasPhysicalHistory && r.thermalStages.isNotEmpty) {
      final total = r.thermalStages.last.tEnd;
      final speed = total / physicalDisplayTotalS;
      final segs = [
        for (final s in r.thermalStages)
          PlaybackSegment(
            kind: s.kind,
            labelKey: s.labelKey,
            displayStart: s.tStart / speed,
            displayEnd: s.tEnd / speed,
            visualStart: s.startC,
            visualEnd: s.endC,
            physStart: s.tStart,
            physEnd: s.tEnd,
            tempStart: s.startC,
            tempEnd: s.endC,
          ),
      ];
      return Playback._(segs, physicalDisplayTotalS, speed, true);
    }
    final sch = r.schematic;
    if (sch == null || sch.isEmpty) return null;
    final target = r.input.targetTemperatureC;
    // Nivel visual del baño: punto medio ILUSTRATIVO para el color; nunca se muestra como cifra.
    double level(SchematicLevel l) => switch (l) {
          SchematicLevel.ambient => ambientVisual,
          SchematicLevel.target => target,
          SchematicLevel.bath => ambientVisual + (target - ambientVisual) * .45,
        };
    var t = 0.0;
    var prev = ambientVisual;
    final segs = <PlaybackSegment>[];
    for (final s in sch) {
      final d = _schematicDisplay[s.kind] ?? 2.0;
      final end = level(s.endLevel);
      segs.add(PlaybackSegment(kind: s.kind, labelKey: s.labelKey, displayStart: t, displayEnd: t + d,
          visualStart: prev, visualEnd: end, schematic: s));
      t += d;
      prev = end;
    }
    return Playback._(segs, t, null, false);
  }

  PlaybackFrame frameAt(double displayT) {
    final t = displayT.clamp(0, totalDisplay).toDouble();
    var i = segments.indexWhere((s) => t <= s.displayEnd);
    if (i < 0) i = segments.length - 1;
    final s = segments[i];
    final span = s.displayEnd - s.displayStart;
    final f = span <= 0 ? 1.0 : ((t - s.displayStart) / span).clamp(0.0, 1.0);
    final visual = s.visualStart + (s.visualEnd - s.visualStart) * f;
    double? temp, phys;
    if (physical) {
      temp = s.tempStart! + (s.tempEnd! - s.tempStart!) * f; // mismos tramos lineales del FSE
      phys = s.physStart! + (s.physEnd! - s.physStart!) * f;
    }
    return PlaybackFrame(segment: s, index: i, visualTemp: visual, temperatureC: temp, physicalTimeS: phys,
        displayTimeS: t);
  }
}
