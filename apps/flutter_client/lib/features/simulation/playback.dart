// Reproductor del ciclo térmico. Solo REPRODUCE el historial devuelto por el FSE:
// t_display = t_physical / speed (doc 04 §13.3). No modifica tiempos ni resultados.
import 'dart:math' as math;

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
  String? medium;
  bool get inFurnace => kind == 'heat' || kind == 'hold' || medium == 'furnace';
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
  Playback._(this.segments, this.totalDisplay, this.speedFactor, this.physical, [this.points = const []]);
  final List<ThermalPoint> points;
  final List<PlaybackSegment> segments;
  final double totalDisplay;
  final double? speedFactor;
  final bool physical;

  static Playback? from(SimulationResultDto r, {double ambientVisual = 20}) {
    if (r.hasPhysicalHistory && r.thermalStages.isNotEmpty) {
      // Cada etapa ocupa un tiempo de pantalla según el logaritmo de su duración: así un recocido de horas no
      // oculta un temple de segundos. Las lecturas (tiempo físico y temperatura) son siempre las del FSE.
      double disp(double dur) => (0.8 + 1.1 * (dur <= 0 ? 0 : _log10(1 + dur / 10))).clamp(0.8, 4.0);
      var acc = 0.0;
      final segs = <PlaybackSegment>[];
      for (final s in r.thermalStages) {
        final d = disp(s.tEnd - s.tStart);
        segs.add(PlaybackSegment(
          kind: s.kind,
          labelKey: s.labelKey,
          displayStart: acc,
          displayEnd: acc + d,
          visualStart: s.startC,
          visualEnd: s.endC,
          physStart: s.tStart,
          physEnd: s.tEnd,
          tempStart: s.startC,
          tempEnd: s.endC,
        )..medium = s.medium);
        acc += d;
      }
      final total = r.thermalStages.last.tEnd;
      return Playback._(segs, acc, total / acc, true, r.thermalHistory);
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
      phys = s.physStart! + (s.physEnd! - s.physStart!) * f;
      temp = _tempAt(phys) ?? s.tempStart! + (s.tempEnd! - s.tempStart!) * f;
    }
    final vis = physical && temp != null ? temp : visual;
    return PlaybackFrame(segment: s, index: i, visualTemp: vis, temperatureC: temp, physicalTimeS: phys,
        displayTimeS: t);
  }

  /// Temperatura del historial del FSE interpolada entre sus puntos.
  double? _tempAt(double t) {
    if (points.length < 2) return null;
    for (var k = 1; k < points.length; k++) {
      final a = points[k - 1], b = points[k];
      if (t <= b.tS) {
        final span = b.tS - a.tS;
        return span <= 0 ? b.temperatureC : a.temperatureC + (b.temperatureC - a.temperatureC) * ((t - a.tS) / span);
      }
    }
    return points.last.temperatureC;
  }
}

double _log10(double x) => x <= 0 ? 0 : math.log(x) / math.ln10;
