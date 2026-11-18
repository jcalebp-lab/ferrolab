import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import 'playback.dart';

/// Gráfica temperatura–tiempo con los MISMOS puntos del FSE (FR-10), sin suavizado.
class ThermalChart extends StatelessWidget {
  const ThermalChart({super.key, required this.result, required this.playback, this.cursorDisplayT, this.height = 220});
  final SimulationResultDto result;
  final Playback playback;
  final double? cursorDisplayT;
  final double height;

  String _label(BuildContext context, String key) => result.protocol?.labelFor(key) ?? key;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final semantics = playback.physical
        ? result.thermalStages
            .map((s) => '${_label(context, s.labelKey)}: ${fmtNum(s.startC)}→${fmtNum(s.endC)} °C, ${fmtDuration(s.tEnd - s.tStart)}')
            .join('; ')
        : playback.segments.map((s) => _label(context, s.labelKey)).join(' → ');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(playback.physical ? t.chartPhysical : t.chartSchematic, style: context.text.bodySmall),
      const Gap(FlSpace.s),
      Semantics(
        label: '${t.chartTitle}. $semantics',
        image: true,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _ChartPainter(
              playback: playback,
              cursor: cursorDisplayT,
              target: result.input.targetTemperatureC,
              tokens: context.fl,
              text: context.text,
              ambientLabel: t.furnaceAmbient,
              bathLabel: t.furnaceBath,
              timeLabel: t.chartTimeAxis,
            ),
          ),
        ),
      ),
      const Gap(FlSpace.s),
      // Tabla textual alternativa (accesibilidad, doc 09 §7).
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(t.treatmentStages, style: context.text.labelLarge),
        children: [
          for (final (i, s) in playback.segments.indexed)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(radius: 12, backgroundColor: context.fl.accentSoft,
                  child: Text('${i + 1}', style: context.text.labelLarge?.copyWith(fontSize: 12))),
              title: Text(_label(context, s.labelKey)),
              subtitle: Text(_stageDetail(context, s)),
            ),
        ],
      ),
    ]);
  }

  String _stageDetail(BuildContext context, PlaybackSegment s) {
    final t = context.t;
    if (playback.physical) {
      return '${fmtNum(s.tempStart!)} → ${fmtNum(s.tempEnd!)} °C · ${fmtDuration(s.physEnd! - s.physStart!)}';
    }
    final sc = s.schematic!;
    final temp = switch (sc.endLevel) {
      SchematicLevel.target => t.furnaceYourTarget(fmtNum(sc.endTemperatureC!)),
      SchematicLevel.ambient => t.furnaceAmbient,
      SchematicLevel.bath => t.furnaceBath,
    };
    final dur = sc.durationS != null ? t.furnaceYourHold(fmtNum(sc.durationS! / 60)) : t.furnaceDurationUnpublished;
    return '$temp · $dur';
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.playback, required this.cursor, required this.target, required this.tokens,
      required this.text, required this.ambientLabel, required this.bathLabel, required this.timeLabel});
  final Playback playback;
  final double? cursor;
  final double target;
  final FerrolabTokens tokens;
  final TextTheme text;
  final String ambientLabel, bathLabel, timeLabel;

  void _text(Canvas c, String s, Offset o, {TextAlign align = TextAlign.left, double size = 11}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(color: tokens.textSecondary, fontSize: size)),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: 90);
    final dx = align == TextAlign.right ? o.dx - tp.width : (align == TextAlign.center ? o.dx - tp.width / 2 : o.dx);
    tp.paint(c, Offset(dx, o.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final padL = playback.physical ? 56.0 : 96.0;
    const padR = 12.0, padT = 12.0, padB = 28.0;
    final plot = Rect.fromLTRB(padL, padT, size.width - padR, size.height - padB);
    final axis = Paint()
      ..color = tokens.border
      ..strokeWidth = 1;
    canvas.drawLine(plot.bottomLeft, plot.bottomRight, axis);
    canvas.drawLine(plot.bottomLeft, plot.topLeft, axis);
    final line = Paint()
      ..color = FlColors.peachRed
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    if (playback.physical) {
      final segs = playback.segments;
      final total = segs.last.physEnd!;
      final maxT = segs.map((s) => math.max(s.tempStart!, s.tempEnd!)).reduce(math.max);
      final yMax = (maxT * 1.1 / 100).ceil() * 100.0;
      double x(double ts) => plot.left + plot.width * ts / total;
      double y(double c) => plot.bottom - plot.height * c / yMax;
      for (var i = 0; i <= 4; i++) {
        final c = yMax * i / 4;
        canvas.drawLine(Offset(plot.left, y(c)), Offset(plot.right, y(c)), axis..color = tokens.border.withValues(alpha: .5));
        _text(canvas, '${c.round()} °C', Offset(plot.left - 6, y(c)), align: TextAlign.right);
      }
      final useMin = total > 180;
      for (var i = 0; i <= 4; i++) {
        final ts = total * i / 4;
        _text(canvas, useMin ? '${(ts / 60).toStringAsFixed(ts < 600 ? 1 : 0)} min' : '${ts.round()} s',
            Offset(x(ts), plot.bottom + 14), align: TextAlign.center);
      }
      final path = Path()..moveTo(x(segs.first.physStart!), y(segs.first.tempStart!));
      for (final s in segs) {
        path.lineTo(x(s.physEnd!), y(s.tempEnd!));
      }
      canvas.drawPath(path, line);
      if (cursor != null) {
        final f = playback.frameAt(cursor!);
        final p = Offset(x(f.physicalTimeS!), y(f.temperatureC!));
        canvas.drawLine(Offset(p.dx, plot.top), Offset(p.dx, plot.bottom), axis..color = tokens.textSecondary);
        canvas.drawCircle(p, 5, Paint()..color = FlColors.sulphurYellow);
        canvas.drawCircle(p, 5, Paint()
          ..color = tokens.textPrimary
          ..style = PaintingStyle.stroke);
      }
      return;
    }

    // Modo esquemático: niveles cualitativos, solo se rotula la cifra del estudiante.
    final yAmb = plot.bottom - plot.height * .1;
    final yTarget = plot.top + plot.height * .1;
    final yBath = yAmb - (yAmb - yTarget) * .45;
    double yFor(SchematicLevel l) => switch (l) {
          SchematicLevel.ambient => yAmb,
          SchematicLevel.target => yTarget,
          SchematicLevel.bath => yBath,
        };
    final total = playback.totalDisplay;
    double x(double d) => plot.left + plot.width * d / total;
    final dash = Paint()
      ..color = tokens.border
      ..strokeWidth = 1;
    for (final (yy, label) in [(yAmb, ambientLabel), (yTarget, '${target.round()} °C')]) {
      for (var xx = plot.left; xx < plot.right; xx += 8) {
        canvas.drawLine(Offset(xx, yy), Offset(xx + 4, yy), dash);
      }
      _text(canvas, label, Offset(plot.left - 6, yy), align: TextAlign.right, size: 10);
    }
    final hasBath = playback.segments.any((s) => s.schematic!.endLevel == SchematicLevel.bath);
    if (hasBath) _text(canvas, '?', Offset(plot.left - 6, yBath), align: TextAlign.right);
    final path = Path()..moveTo(plot.left, yAmb);
    for (final s in playback.segments) {
      path.lineTo(x(s.displayEnd), yFor(s.schematic!.endLevel));
    }
    canvas.drawPath(path, line..color = FlColors.peachRed.withValues(alpha: .85));
    _text(canvas, '$timeLabel →', Offset(plot.right, plot.bottom + 14), align: TextAlign.right);
    if (hasBath) {
      final b = playback.segments.firstWhere((s) => s.schematic!.endLevel == SchematicLevel.bath);
      _text(canvas, bathLabel, Offset(x(b.displayEnd), yBath - 12), align: TextAlign.center, size: 10);
    }
    if (cursor != null) {
      final f = playback.frameAt(cursor!);
      final s = f.segment;
      final frac = ((f.displayTimeS - s.displayStart) / (s.displayEnd - s.displayStart)).clamp(0.0, 1.0);
      final startY = f.index == 0 ? yAmb : yFor(playback.segments[f.index - 1].schematic!.endLevel);
      final p = Offset(x(f.displayTimeS), startY + (yFor(s.schematic!.endLevel) - startY) * frac);
      canvas.drawCircle(p, 5, Paint()..color = FlColors.sulphurYellow);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.cursor != cursor || old.playback != playback || old.tokens != tokens;
}
