import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';

/// Colores categóricos validados (orden fijo: ferrita, perlita, bainita). Claro / oscuro.
const _seriesLight = {'ferrite': Color(0xFF2A78D6), 'pearlite': Color(0xFFEB6834), 'bainite': Color(0xFF1BAF7A)};
const _seriesDark = {'ferrite': Color(0xFF3987E5), 'pearlite': Color(0xFFD95926), 'bainite': Color(0xFF199E70)};

/// Diagramas TTT y CCT calculados para el material, con la trayectoria de la práctica del estudiante.
class TransformationDiagrams extends StatefulWidget {
  const TransformationDiagrams({super.key, required this.diagrams});
  final List<DiagramDto> diagrams;
  @override
  State<TransformationDiagrams> createState() => _TransformationDiagramsState();
}

class _TransformationDiagramsState extends State<TransformationDiagrams> {
  String _kind = 'CCT';
  int? _hover; // índice del punto de la trayectoria bajo el cursor

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final d = widget.diagrams.where((x) => x.kind == _kind).firstOrNull ?? widget.diagrams.first;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final series = dark ? _seriesDark : _seriesLight;
    final ink = context.text.bodySmall?.color ?? Colors.grey;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SegmentedButton<String>(
        segments: [
          ButtonSegment(value: 'CCT', label: Text(t.diagCct)),
          ButtonSegment(value: 'TTT', label: Text(t.diagTtt)),
        ],
        selected: {_kind},
        onSelectionChanged: (s) => setState(() {
          _kind = s.first;
          _hover = null;
        }),
      ),
      const Gap(FlSpace.s),
      Text(_kind == 'CCT' ? t.diagCctNote : t.diagTttNote, style: context.text.bodySmall),
      const Gap(FlSpace.s),
      // Leyenda (identidad nunca solo por color: las curvas llevan etiqueta directa).
      Wrap(spacing: FlSpace.m, runSpacing: FlSpace.xs, children: [
        for (final r in const ['ferrite', 'pearlite', 'bainite'])
          if (d.curves.any((c) => c.reaction == r && c.points.isNotEmpty))
            _LegendItem(color: series[r]!, label: t.constituent(r == 'ferrite' ? 'proeutectoid_ferrite' : r)),
        _LegendItem(color: context.text.bodyLarge?.color ?? Colors.black, label: t.diagYourPath, thick: true),
      ]),
      const Gap(FlSpace.s),
      LayoutBuilder(builder: (context, c) {
        final size = Size(c.maxWidth, math.min(360, c.maxWidth * .75));
        final painter = _DiagramPainter(d: d, series: series, ink: ink,
            text: context.text.labelSmall ?? const TextStyle(fontSize: 11),
            pathColor: context.text.bodyLarge?.color ?? Colors.black, hover: _hover, surface: context.fl.surface);
        return MouseRegion(
          onExit: (_) => setState(() => _hover = null),
          onHover: (e) => setState(() => _hover = painter.nearestPathIndex(e.localPosition, size)),
          child: GestureDetector(
            onTapDown: (e) => setState(() => _hover = painter.nearestPathIndex(e.localPosition, size)),
            child: Semantics(
              label: '${_kind == 'CCT' ? t.diagCct : t.diagTtt}. ${t.diagYourPath}',
              child: CustomPaint(size: size, painter: painter),
            ),
          ),
        );
      }),
      if (_hover != null && _hover! < d.userPath.length)
        Text(t.diagPoint(_fmtTime(d.userPath[_hover!].$1), fmtNum(d.userPath[_hover!].$2.roundToDouble())),
            style: context.text.bodyMedium),
      const Gap(FlSpace.xs),
      Text(t.diagAxes, style: context.text.bodySmall),
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(t.diagTable),
        children: [
          for (final e in d.lines.entries) KeyValue(e.key, '${fmtNum(e.value)} °C'),
          for (final cu in d.curves.where((c) => c.points.isNotEmpty))
            KeyValue(cu.name, t.diagNose(_fmtTime(cu.points.reduce((a, b) => a.$1 <= b.$1 ? a : b).$1),
                fmtNum(cu.points.reduce((a, b) => a.$1 <= b.$1 ? a : b).$2))),
        ],
      ),
    ]);
  }
}

String _fmtTime(double s) => s < 1 ? '${s.toStringAsFixed(2)} s' : (s < 120 ? '${s.toStringAsFixed(1)} s'
    : (s < 7200 ? '${(s / 60).toStringAsFixed(1)} min' : '${(s / 3600).toStringAsFixed(1)} h'));

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, this.thick = false});
  final Color color;
  final String label;
  final bool thick;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 18, height: thick ? 4 : 2, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label, style: context.text.bodySmall),
      ]);
}

class _DiagramPainter extends CustomPainter {
  _DiagramPainter({required this.d, required this.series, required this.ink, required this.text,
      required this.pathColor, required this.hover, required this.surface});
  final DiagramDto d;
  final Map<String, Color> series;
  final Color ink, pathColor, surface;
  final TextStyle text;
  final int? hover;

  static const _left = 44.0, _bottom = 28.0, _top = 8.0, _right = 34.0;
  static const _xMinLog = -2.0, _xMaxLog = 6.0;

  double get _yMax => ((d.lines.values.fold<double>(0, math.max) + 60) / 50).ceil() * 50.0;

  Offset _map(double tS, double tempC, Size s) {
    final w = s.width - _left - _right, h = s.height - _top - _bottom;
    final lx = (math.log(math.max(tS, 1e-2)) / math.ln10).clamp(_xMinLog, _xMaxLog);
    return Offset(_left + (lx - _xMinLog) / (_xMaxLog - _xMinLog) * w, _top + (1 - tempC / _yMax) * h);
  }

  int? nearestPathIndex(Offset p, Size s) {
    if (d.userPath.isEmpty) return null;
    var best = 0;
    var bd = double.infinity;
    for (var i = 0; i < d.userPath.length; i++) {
      final q = _map(d.userPath[i].$1, d.userPath[i].$2, s);
      final dd = (q.dx - p.dx).abs();
      if (dd < bd) {
        bd = dd;
        best = i;
      }
    }
    return bd < 24 ? best : null;
  }

  void _label(Canvas c, String s, Offset at, {Color? color, bool right = false, bool center = false}) {
    final tp = TextPainter(text: TextSpan(text: s, style: text.copyWith(color: color ?? ink)), textDirection: TextDirection.ltr)
      ..layout();
    final dx = right ? at.dx - tp.width : (center ? at.dx - tp.width / 2 : at.dx);
    tp.paint(c, Offset(dx, at.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = ink.withValues(alpha: .18)
      ..strokeWidth = 1;
    final plot = Rect.fromLTRB(_left, _top, size.width - _right, size.height - _bottom);
    // Rejilla recesiva: décadas de tiempo y cada 100 °C.
    for (var e = _xMinLog.toInt(); e <= _xMaxLog.toInt(); e++) {
      final x = _map(math.pow(10, e).toDouble(), 0, size).dx;
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), grid);
      if (e % 2 == 0) _label(canvas, e == 0 ? '1' : '10${_sup(e)}', Offset(x, plot.bottom + 12), center: true);
    }
    for (var y = 0.0; y <= _yMax; y += 100) {
      final py = _map(1, y, size).dy;
      canvas.drawLine(Offset(plot.left, py), Offset(plot.right, py), grid);
      _label(canvas, y.toStringAsFixed(0), Offset(plot.left - 6, py), right: true);
    }
    // Líneas de referencia (Ae3, Ae1, Bs, Ms): discontinuas, etiqueta directa.
    final ref = Paint()
      ..color = ink.withValues(alpha: .6)
      ..strokeWidth = 1;
    for (final e in d.lines.entries) {
      final y = _map(1, e.value, size).dy;
      for (var x = plot.left; x < plot.right; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + 4, plot.right), y), ref);
      }
      _label(canvas, e.key, Offset(plot.right + 3, y));
    }
    canvas.save();
    canvas.clipRect(plot);
    // Curvas de transformación: 2 px, color por reacción; las de fin, más tenues.
    for (final cu in d.curves) {
      if (cu.points.length < 2) continue;
      final col = series[cu.reaction] ?? ink;
      final finish = cu.name.endsWith('f');
      final paint = Paint()
        ..color = finish ? col.withValues(alpha: .55) : col
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      final pts = [...cu.points]..sort((a, b) => d.kind == 'TTT' ? b.$2.compareTo(a.$2) : a.$1.compareTo(b.$1));
      final path = Path()..moveTo(_map(pts.first.$1, pts.first.$2, size).dx, _map(pts.first.$1, pts.first.$2, size).dy);
      for (final p in pts.skip(1)) {
        final o = _map(p.$1, p.$2, size);
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, paint);
      final nose = pts.reduce((a, b) => a.$1 <= b.$1 ? a : b);
      final o = _map(nose.$1, nose.$2, size);
      _label(canvas, cu.name, o + const Offset(-4, -9), right: true);
    }
    // Trayectoria de la práctica (centro de la probeta): trazo principal de 3 px.
    if (d.userPath.length >= 2) {
      final up = Path();
      for (final (i, p) in d.userPath.indexed) {
        final o = _map(p.$1, p.$2, size);
        i == 0 ? up.moveTo(o.dx, o.dy) : up.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(up, Paint()
        ..color = surface
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke);
      canvas.drawPath(up, Paint()
        ..color = pathColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round);
      if (hover != null && hover! < d.userPath.length) {
        final o = _map(d.userPath[hover!].$1, d.userPath[hover!].$2, size);
        canvas.drawLine(Offset(o.dx, plot.top), Offset(o.dx, plot.bottom), Paint()
          ..color = ink.withValues(alpha: .5)
          ..strokeWidth = 1);
        canvas.drawCircle(o, 6, Paint()..color = surface);
        canvas.drawCircle(o, 4, Paint()..color = pathColor);
      }
    }
    canvas.restore();
    canvas.drawRect(plot, Paint()
      ..color = ink.withValues(alpha: .35)
      ..style = PaintingStyle.stroke);
  }

  static String _sup(int e) {
    const m = {'-': '⁻', '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴', '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹'};
    return e.toString().split('').map((ch) => m[ch] ?? ch).join();
  }

  @override
  bool shouldRepaint(covariant _DiagramPainter old) => old.d != d || old.hover != hover || old.series != series;
}
