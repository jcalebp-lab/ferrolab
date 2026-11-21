import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../app/l10n.dart';
import '../../core/design_system/tokens.dart';
import '../../shared/widgets/widgets.dart';

/// Campo observado (µm). Con G ASTM 7 caben ~90 granos austeníticos previos.
const double kFieldUm = 300;
const double _maxZoom = 10;

/// Colores de la ilustración (aspecto de ataque con nital, luz reflejada). No son datos.
const _cFerrite = Color(0xFFECE6D8);
const _cPearliteBase = Color(0xFF9A8A78);
const _cLamella = Color(0xFF3A2E26);
const _cBainiteBase = Color(0xFFB9A88F);
const _cBainiteNeedle = Color(0xFF4F4032);
const _cMartBase = Color(0xFFCDBB9E);
const _cMartBaseTempered = Color(0xFF9C8873);
const _cBoundary = Color(0xFF2B231D);
const _cGraphite = Color(0xFF15120F);

/// Colores de leyenda por constituyente (mismo tono que en la ilustración).
const constituentSwatch = {
  'proeutectoid_ferrite': _cFerrite,
  'pearlite': _cPearliteBase,
  'bainite': _cBainiteBase,
  'martensite': _cMartBase,
  'retained_austenite': Color(0xFFFFFFFF),
};

/// Microscopio virtual sobre una microestructura GENERADA a partir de las fracciones calculadas.
class GeneratedMicroscope extends StatefulWidget {
  const GeneratedMicroscope({super.key, required this.spec, this.height});
  final Map<String, dynamic> spec;
  final double? height;
  @override
  State<GeneratedMicroscope> createState() => _GeneratedMicroscopeState();
}

class _GeneratedMicroscopeState extends State<GeneratedMicroscope> {
  final _tc = TransformationController();
  double _zoom = 1;
  bool _labels = false;
  bool _measure = false;
  late _Micro _micro = _Micro.build(widget.spec);

  @override
  void didUpdateWidget(covariant GeneratedMicroscope old) {
    super.didUpdateWidget(old);
    if (old.spec['seed'] != widget.spec['seed'] || old.spec['fractions'] != widget.spec['fractions']) {
      _micro.picture?.dispose();
      _micro = _Micro.build(widget.spec);
      _tc.value = Matrix4.identity();
      _zoom = 1;
    }
  }

  void _setZoom(double z, Size viewport) {
    final nz = z.clamp(1.0, _maxZoom);
    // Acerca/aleja respecto al centro de la vista actual (como girar el revólver del microscopio).
    final center = _tc.toScene(Offset(viewport.width / 2, viewport.height / 2));
    final m = Matrix4.identity()
      ..translateByDouble(viewport.width / 2, viewport.height / 2, 0, 1)
      ..scaleByDouble(nz, nz, 1, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
    setState(() {
      _zoom = nz;
      _tc.value = m;
    });
  }

  @override
  void dispose() {
    _micro.picture?.dispose();
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return LayoutBuilder(builder: (context, c) {
      final side = math.min(c.maxWidth, widget.height ?? 520);
      final viewport = Size(side, side);
      final pxPerUm = side / kFieldUm * _zoom;
      // Aumento aproximado en pantalla: 1 px lógico ≈ 0.2646 mm (96 ppp).
      final mag = pxPerUm * 264.6;
      final bar = _niceBar(110 / pxPerUm);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(
          child: SizedBox(
            width: side,
            height: side,
            child: ClipOval(
              clipBehavior: Clip.antiAlias,
              child: Stack(children: [
                InteractiveViewer(
                  key: const Key('microscopeViewer'),
                  transformationController: _tc,
                  minScale: 1,
                  maxScale: _maxZoom,
                  onInteractionUpdate: (_) => setState(() => _zoom = _tc.value.getMaxScaleOnAxis()),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: viewport,
                      painter: _MicroPainter(_micro),
                      foregroundPainter: _measure ? _MeasurePainter(_micro.intercepts) : null,
                      isComplex: true,
                      willChange: false,
                    ),
                  ),
                ),
                if (_labels && _zoom < 1.05)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        key: const Key('microLabels'),
                        painter: _LabelPainter(_micro.annotations(_labelText(context)), side / kFieldUm),
                      ),
                    ),
                  ),
                // Barra de escala (se recalcula con el aumento).
                Positioned(
                  left: side * .24,
                  bottom: side * .14,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      color: Colors.black.withValues(alpha: .55),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        Container(width: bar * pxPerUm, height: 3, color: Colors.white),
                        const SizedBox(height: 2),
                        Text('${fmtNum(bar)} µm', style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
        const Gap(FlSpace.s),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(key: const Key('microZoomOut'), tooltip: t.microZoomOut,
              onPressed: () => _setZoom(_zoom / 1.6, viewport), icon: const Icon(Icons.zoom_out)),
          Text(t.microMagnification(mag.round().toString()), key: const Key('microMag')),
          IconButton(key: const Key('microZoomIn'), tooltip: t.microZoomIn,
              onPressed: () => _setZoom(_zoom * 1.6, viewport), icon: const Icon(Icons.zoom_in)),
          IconButton(tooltip: t.microReset, onPressed: () => _setZoom(1, viewport), icon: const Icon(Icons.center_focus_strong)),
        ]),
        Center(
          child: FilterChip(
            key: const Key('microLabelsToggle'),
            avatar: const Icon(Icons.north_east, size: 18),
            label: Text(t.microLabelsToggle),
            selected: _labels,
            onSelected: (v) {
              setState(() => _labels = v);
              if (v && _zoom >= 1.05) _setZoom(1, viewport); // las etiquetas se muestran en el aumento base
            },
          ),
        ),
        if (_labels && _zoom >= 1.05)
          Text(t.microLabelsZoomHint, textAlign: TextAlign.center, style: context.text.bodySmall),
        if (widget.spec['family'] != 'gray_cast_iron') ...[
          const Gap(FlSpace.xs),
          Center(
            child: FilterChip(
              key: const Key('grainMeasureToggle'),
              avatar: const Icon(Icons.straighten, size: 18),
              label: Text(t.grainMeasureToggle),
              selected: _measure,
              onSelected: (v) => setState(() => _measure = v),
            ),
          ),
          if (_measure) ...[const Gap(FlSpace.s), _MeasurePanel(m: _micro)],
        ],
        const Gap(FlSpace.xs),
        Text(t.microGesture, textAlign: TextAlign.center, style: context.text.bodySmall),
      ]);
    });
  }

  /// Nombre visible de cada clave señalada.
  Map<String, String> _labelText(BuildContext context) {
    final t = context.t;
    final tempered = widget.spec['tempered'] == true;
    return {
      'proeutectoid_ferrite': t.constFerrite,
      'pearlite': t.constPearlite,
      'bainite': t.constBainite,
      'martensite': tempered ? t.constTemperedMartensite : t.constMartensite,
      'retained_austenite': t.microLabelRetained,
      'graphite': t.constGraphite,
      'matrix': t.grayMatrix(widget.spec['matrix'] as String? ?? 'pearlite'),
    };
  }

  static double _niceBar(double um) {
    const nice = [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0];
    return nice.lastWhere((n) => n <= um, orElse: () => 1);
  }
}

// ----------------------------------------------------------------- geometría
class _Cell {
  _Cell(this.poly, this.site);
  final List<Offset> poly;
  final Offset site;
  String kind = 'proeutectoid_ferrite';
  double get area {
    var a = 0.0;
    for (var i = 0; i < poly.length; i++) {
      final p = poly[i], q = poly[(i + 1) % poly.length];
      a += p.dx * q.dy - q.dx * p.dy;
    }
    return a.abs() / 2;
  }

  Rect get bounds {
    var l = double.infinity, tp = double.infinity, r = -double.infinity, b = -double.infinity;
    for (final p in poly) {
      l = math.min(l, p.dx);
      tp = math.min(tp, p.dy);
      r = math.max(r, p.dx);
      b = math.max(b, p.dy);
    }
    return Rect.fromLTRB(l, tp, r, b);
  }
}

/// Recorta el polígono con el semiplano más cercano a `a` que a `b` (bisectriz).
List<Offset> _clip(List<Offset> poly, Offset a, Offset b) {
  final m = (a + b) / 2, n = b - a;
  double side(Offset p) => (p - m).dx * n.dx + (p - m).dy * n.dy;
  final out = <Offset>[];
  for (var i = 0; i < poly.length; i++) {
    final p = poly[i], q = poly[(i + 1) % poly.length];
    final sp = side(p), sq = side(q);
    if (sp <= 0) out.add(p);
    if ((sp < 0 && sq > 0) || (sp > 0 && sq < 0)) {
      final tt = sp / (sp - sq);
      out.add(p + (q - p) * tt);
    }
  }
  return out;
}

class _Micro {
  _Micro(this.cells, this.spec, this.flakes, this.tempered, this.spacing, this.ra, this.dGrain);
  final double dGrain; // lado del grano de área media (µm)
  _Intercepts? _intercepts;
  _Intercepts get intercepts => _intercepts ??= _Intercepts.measure(this);
  ui.Picture? picture; // caché del dibujo (ver _MicroPainter.paint)
  double? pictureWidth;
  final List<_Cell> cells;
  final Map<String, dynamic> spec;
  final List<List<Offset>> flakes;
  final bool tempered;
  final double spacing; // separación interlaminar ilustrativa (µm)
  final double ra; // fracción de austenita retenida

  static _Micro build(Map<String, dynamic> spec) {
    final rnd = math.Random((spec['seed'] as num?)?.toInt() ?? 1);
    final g = (spec['astm_grain_size'] as num?)?.toDouble() ?? 7;
    // ASTM E112: granos por mm² a 1× = 2^(G−1)·15.5 → área media del grano.
    final grainArea = 1e6 / (math.pow(2, g - 1) * 15.5);
    final n = (kFieldUm * kFieldUm / grainArea).round().clamp(12, 700);
    final dGrain = math.sqrt(grainArea);
    // Sitios casi uniformes (Poisson con distancia mínima) para granos equiaxiales.
    final sites = <Offset>[];
    var guard = 0;
    while (sites.length < n && guard++ < n * 60) {
      final p = Offset(rnd.nextDouble() * kFieldUm, rnd.nextDouble() * kFieldUm);
      if (sites.every((s) => (s - p).distance > dGrain * .55)) sites.add(p);
    }
    final square = [const Offset(0, 0), const Offset(kFieldUm, 0), const Offset(kFieldUm, kFieldUm), const Offset(0, kFieldUm)];
    final cells = <_Cell>[];
    for (final s in sites) {
      var poly = square;
      for (final o in sites) {
        if (identical(o, s) || (o - s).distance > dGrain * 3.2) continue;
        poly = _clip(poly, s, o);
        if (poly.isEmpty) break;
      }
      if (poly.length >= 3) cells.add(_Cell(poly, s));
    }
    final family = spec['family'] as String? ?? 'steel';
    final fractions = <String, double>{};
    if (family == 'gray_cast_iron') {
      switch (spec['matrix'] as String? ?? 'pearlite') {
        case 'ferrite_pearlite':
          fractions.addAll({'proeutectoid_ferrite': .5, 'pearlite': .5});
        case 'martensite' || 'tempered_martensite':
          fractions['martensite'] = 1;
        case 'ausferrite':
          fractions['bainite'] = 1;
        default:
          fractions['pearlite'] = 1;
      }
    } else {
      final f = (spec['fractions'] as Map?)?.cast<String, num>() ?? const {'proeutectoid_ferrite': .5, 'pearlite': .5};
      for (final e in f.entries) {
        if (e.key != 'retained_austenite' && e.value > 0) fractions[e.key] = e.value.toDouble();
      }
      if (fractions.isEmpty) fractions['pearlite'] = 1;
    }
    // Asignación por área: cada grano al constituyente con mayor déficit (orden aleatorio reproducible).
    final total = cells.fold<double>(0, (a, c) => a + c.area);
    final fsum = fractions.values.fold<double>(0, (a, b) => a + b);
    final assigned = {for (final k in fractions.keys) k: 0.0};
    final order = [...cells]..shuffle(rnd);
    for (final c in order) {
      String best = fractions.keys.first;
      var deficit = -double.infinity;
      for (final k in fractions.keys) {
        final d = fractions[k]! / fsum * total - assigned[k]!;
        if (d > deficit) {
          deficit = d;
          best = k;
        }
      }
      c.kind = best;
      assigned[best] = assigned[best]! + c.area;
    }
    final flakes = <List<Offset>>[];
    if (family == 'gray_cast_iron') {
      // Grafito tipo A: láminas curvas de orientación aleatoria (ASTM A247).
      for (var i = 0; i < 70; i++) {
        final p0 = Offset(rnd.nextDouble() * kFieldUm, rnd.nextDouble() * kFieldUm);
        final len = 25 + rnd.nextDouble() * 90;
        var ang = rnd.nextDouble() * math.pi;
        final pts = [p0];
        for (var k = 0; k < 6; k++) {
          ang += (rnd.nextDouble() - .5) * .6;
          pts.add(pts.last + Offset(math.cos(ang), math.sin(ang)) * (len / 6));
        }
        flakes.add(pts);
      }
    }
    final ra = ((spec['fractions'] as Map?)?['retained_austenite'] as num?)?.toDouble() ?? 0;
    return _Micro(cells, spec, flakes, spec['tempered'] == true || spec['matrix'] == 'tempered_martensite',
        spec['pearlite_spacing'] == 'coarse' ? 1.6 : 0.9, ra, dGrain);
  }
}

/// Medición del tamaño de grano por intercepto lineal (ASTM E112) sobre la imagen GENERADA.
/// Tres líneas horizontales y tres verticales dentro del campo circular; cada cambio de grano a lo largo de una
/// línea es una intersección con un límite de grano. ℓ̄ = L / N y G = −6.643856·log10(ℓ̄ mm) − 3.288.
class _Intercepts {
  _Intercepts(this.lines, this.points, this.totalUm);
  final List<(Offset, Offset)> lines;
  final List<Offset> points;
  final double totalUm;
  int get count => points.length;
  double? get meanUm => count == 0 ? null : totalUm / count;
  double? get g => meanUm == null ? null : -6.643856 * math.log(meanUm! / 1000) / math.ln10 - 3.288;

  static _Intercepts measure(_Micro m) {
    const half = kFieldUm * .31, c = kFieldUm / 2;
    final lines = <(Offset, Offset)>[
      for (final f in const [-.5, 0.0, .5]) ...[
        (Offset(c - half, c + f * half), Offset(c + half, c + f * half)),
        (Offset(c + f * half, c - half), Offset(c + f * half, c + half)),
      ],
    ];
    final sites = [for (final cell in m.cells) cell.site];
    // Rejilla espacial: el grano más cercano se busca por anillos de celdas vecinas (exacto, sin recorrer todos).
    final size = m.dGrain;
    final cols = (kFieldUm / size).ceil() + 1;
    final grid = <int, List<int>>{};
    for (var i = 0; i < sites.length; i++) {
      final key = (sites[i].dy ~/ size) * cols + (sites[i].dx ~/ size);
      (grid[key] ??= <int>[]).add(i);
    }
    int nearest(Offset p) {
      final cx = (p.dx ~/ size), cy = (p.dy ~/ size);
      var best = -1;
      var bd = double.infinity;
      for (var r = 0; r <= cols; r++) {
        for (var y = cy - r; y <= cy + r; y++) {
          for (var x = cx - r; x <= cx + r; x++) {
            if ((y - cy).abs() != r && (x - cx).abs() != r) continue; // solo el borde del anillo
            if (x < 0 || y < 0 || x >= cols || y >= cols) continue;
            for (final i in grid[y * cols + x] ?? const <int>[]) {
              final d = (sites[i] - p).distanceSquared;
              if (d < bd) {
                bd = d;
                best = i;
              }
            }
          }
        }
        // ya no puede haber nada más cerca fuera del anillo r
        if (best >= 0 && bd <= (r * size) * (r * size)) break;
      }
      return best;
    }

    final pts = <Offset>[];
    var total = 0.0;
    final step = m.dGrain / 40;
    for (final (a, b) in lines) {
      final len = (b - a).distance;
      total += len;
      final n = (len / step).ceil();
      var prev = nearest(a);
      var prevP = a;
      for (var k = 1; k <= n; k++) {
        final p = Offset.lerp(a, b, k / n)!;
        final cur = nearest(p);
        if (cur != prev) pts.add((prevP + p) / 2);
        prev = cur;
        prevP = p;
      }
    }
    return _Intercepts(lines, pts, total);
  }
}

class _MeasurePainter extends CustomPainter {
  _MeasurePainter(this.m);
  final _Intercepts m;
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / kFieldUm;
    final line = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 1.6;
    for (final (a, b) in m.lines) {
      canvas.drawLine(a * s, b * s, line);
    }
    final dot = Paint()..color = const Color(0xFFFF1744);
    for (final p in m.points) {
      canvas.drawCircle(p * s, 2.6, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _MeasurePainter old) => old.m != m;
}

class _MeasurePanel extends StatelessWidget {
  const _MeasurePanel({required this.m});
  final _Micro m;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final i = m.intercepts;
    final spec = m.spec;
    final g = (spec['astm_grain_size'] as num?)?.toDouble();
    final kind = spec['grain_computed'] != true
        ? t.grainKindAssumed
        : (spec['grain_kind'] == 'ferrite' ? t.grainKindFerrite : t.grainKindAustenite);
    return Container(
      key: const Key('grainMeasurePanel'),
      padding: const EdgeInsets.all(FlSpace.m),
      decoration: BoxDecoration(
        color: context.fl.surface,
        borderRadius: BorderRadius.circular(FlRadius.input),
        border: Border.all(color: context.fl.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.grainMeasureTitle, style: context.text.titleSmall),
        const Gap(FlSpace.xs),
        Text(t.grainMeasureBody(i.lines.length.toString(), i.totalUm.round().toString(), i.count.toString())),
        if (i.meanUm != null)
          Text(t.grainMeasureResult(i.meanUm!.toStringAsFixed(1), i.g!.toStringAsFixed(1)),
              key: const Key('grainMeasured'), style: context.text.titleMedium),
        if (g != null) Text(t.grainMeasureModel(g.toStringAsFixed(1), kind)),
        const Gap(FlSpace.xs),
        Text(t.grainMeasureNote, style: context.text.bodySmall),
      ]),
    );
  }
}

/// Punto señalado (coordenadas del campo, µm) y su nombre.
class _Annotation {
  _Annotation(this.target, this.label);
  final Offset target;
  final String label;
}

extension on _Micro {
  /// Un ejemplo de cada constituyente presente, bien separados entre sí y lejos del borde del campo circular.
  List<_Annotation> annotations(Map<String, String> names) {
    const center = Offset(kFieldUm / 2, kFieldUm / 2);
    Offset centroid(_Cell c) => c.poly.reduce((a, b) => a + b) / c.poly.length.toDouble();
    final usable = cells.where((c) => (centroid(c) - center).distance < kFieldUm * .33).toList();
    final chosen = <Offset>[];
    final out = <_Annotation>[];
    Offset? pick(Iterable<Offset> candidates) {
      Offset? best;
      var bestD = -1.0;
      for (final p in candidates) {
        final d = chosen.isEmpty ? (kFieldUm - (p - center).distance) : chosen.map((q) => (q - p).distance).reduce(math.min);
        if (d > bestD) {
          bestD = d;
          best = p;
        }
      }
      if (best != null) chosen.add(best);
      return best;
    }

    final family = spec['family'] as String? ?? 'steel';
    if (family == 'gray_cast_iron') {
      final flake = pick(flakes.map((f) => f[f.length ~/ 2]).where((p) => (p - center).distance < kFieldUm * .33));
      if (flake != null) out.add(_Annotation(flake, names['graphite']!));
      final m = pick(usable.map(centroid));
      if (m != null) out.add(_Annotation(m, names['matrix']!));
      return out;
    }
    final present = <String>{for (final c in cells) c.kind};
    // Orden estable: del constituyente más abundante al menos abundante.
    final order = present.toList()
      ..sort((a, b) => cells.where((c) => c.kind == b).length.compareTo(cells.where((c) => c.kind == a).length));
    for (final k in order) {
      final p = pick(usable.where((c) => c.kind == k).map(centroid));
      if (p != null) out.add(_Annotation(p, names[k] ?? k));
    }
    if (ra >= .005 && present.contains('martensite')) {
      final p = pick(usable.where((c) => c.kind == 'martensite').map(centroid));
      if (p != null) out.add(_Annotation(p, names['retained_austenite']!));
    }
    return out;
  }
}

/// Flechas con rótulo, dibujadas sobre el campo en el aumento base.
class _LabelPainter extends CustomPainter {
  _LabelPainter(this.items, this.scale);
  final List<_Annotation> items;
  final double scale; // px por µm

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final boxes = <Rect>[];
    for (final a in items) {
      final tip = a.target * scale;
      var dir = tip - c;
      dir = dir.distance < 1 ? const Offset(1, -1) / math.sqrt2 : dir / dir.distance;
      final tp = TextPainter(
        text: TextSpan(text: a.label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width * .45);
      // Rótulo hacia afuera del punto (o hacia adentro si choca con el borde), dentro del círculo,
      // sin solaparse con otros y siempre a distancia visible del objetivo.
      Rect place(Offset d) {
        var anchor = tip + d * (r * .3);
        Rect box() => Rect.fromCenter(center: anchor, width: tp.width + 14, height: tp.height + 8);
        for (var k = 0; k < 8 && boxes.any((b) => b.overlaps(box().inflate(4))); k++) {
          anchor += Offset(-d.dy, d.dx) * (tp.height + 12);
        }
        var rect = box();
        final maxD = r * .92;
        for (final corner in [rect.topLeft, rect.topRight, rect.bottomLeft, rect.bottomRight]) {
          final dd = (corner - c).distance;
          if (dd > maxD) {
            anchor -= (corner - c) / dd * (dd - maxD);
            rect = box();
          }
        }
        return rect;
      }

      double gap(Rect b) => b.inflate(6).contains(tip) ? 0 : (_edgePoint(b, tip, b.center) - tip).distance;
      double score(Rect b) => math.min(gap(b), 60) - (boxes.any((o) => o.overlaps(b.inflate(4))) ? 1000 : 0);
      var rect = place(dir);
      if (score(rect) < 36) {
        for (var k = 0; k < 8; k++) {
          final a = math.atan2(dir.dy, dir.dx) + k * math.pi / 4;
          final cand = place(Offset(math.cos(a), math.sin(a)));
          if (score(cand) > score(rect)) rect = cand;
          if (score(rect) >= 50) break;
        }
      }
      boxes.add(rect);
      // Línea con halo para que se vea sobre fondos claros y oscuros.
      final start = Offset(rect.center.dx.clamp(rect.left, rect.right), rect.center.dy);
      final from = _edgePoint(rect, tip, start);
      final halo = Paint()
        ..color = Colors.black.withValues(alpha: .7)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;
      final line = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(from, tip, halo);
      canvas.drawLine(from, tip, line);
      final v = tip - from;
      if (v.distance > 1) {
        final u = v / v.distance;
        final n = Offset(-u.dy, u.dx);
        final head = Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo((tip - u * 11 + n * 6).dx, (tip - u * 11 + n * 6).dy)
          ..lineTo((tip - u * 11 - n * 6).dx, (tip - u * 11 - n * 6).dy)
          ..close();
        canvas.drawPath(head, Paint()
          ..color = Colors.black.withValues(alpha: .7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
        canvas.drawPath(head, Paint()..color = Colors.white);
      }
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()..color = Colors.black.withValues(alpha: .72));
      tp.paint(canvas, rect.topLeft + const Offset(7, 4));
    }
  }

  /// Punto del borde del rótulo en la dirección del objetivo.
  static Offset _edgePoint(Rect r, Offset target, Offset fallback) {
    final cx = target.dx.clamp(r.left, r.right).toDouble();
    final cy = target.dy.clamp(r.top, r.bottom).toDouble();
    final p = Offset(cx, cy);
    return p == target ? fallback : p;
  }

  @override
  bool shouldRepaint(covariant _LabelPainter old) => old.items != items || old.scale != scale;
}

// ----------------------------------------------------------------- dibujo
class _MicroPainter extends CustomPainter {
  _MicroPainter(this.m);
  final _Micro m;

  @override
  void paint(Canvas canvas, Size size) {
    // El campo se dibuja UNA vez (miles de trazos) y se guarda como Picture: el zoom y el arrastre solo la
    // reproducen, así el microscopio va fluido también en celulares.
    if (m.picture == null || m.pictureWidth != size.width) {
      final rec = ui.PictureRecorder();
      _draw(Canvas(rec), size);
      m.picture?.dispose();
      m.picture = rec.endRecording();
      m.pictureWidth = size.width;
    }
    canvas.drawPicture(m.picture!);
  }

  void _draw(Canvas canvas, Size size) {
    final s = size.width / kFieldUm;
    canvas.save();
    canvas.scale(s, s);
    canvas.drawRect(const Rect.fromLTWH(0, 0, kFieldUm, kFieldUm), Paint()..color = _cFerrite);
    for (final (i, c) in m.cells.indexed) {
      final path = Path()..addPolygon(c.poly, true);
      final rnd = math.Random(((m.spec['seed'] as num?)?.toInt() ?? 1) * 31 + i);
      canvas.save();
      canvas.clipPath(path);
      switch (c.kind) {
        case 'pearlite':
          _pearlite(canvas, c, rnd);
        case 'bainite':
          _bainite(canvas, c, rnd);
        case 'martensite':
          _martensite(canvas, c, rnd);
        default:
          canvas.drawPath(path, Paint()..color = Color.lerp(_cFerrite, Colors.white, rnd.nextDouble() * .3)!);
      }
      canvas.restore();
      // Límites de grano: marcados en ferrita/perlita; tenues en martensita/bainita (austenita previa).
      final strong = c.kind == 'proeutectoid_ferrite' || c.kind == 'pearlite';
      canvas.drawPath(path, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strong ? .45 : .25
        ..color = _cBoundary.withValues(alpha: strong ? .9 : .45));
    }
    for (final f in m.flakes) {
      final p = Path()..moveTo(f.first.dx, f.first.dy);
      for (var k = 1; k < f.length; k++) {
        p.lineTo(f[k].dx, f[k].dy);
      }
      canvas.drawPath(p, Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 2.2
        ..color = _cGraphite);
    }
    canvas.restore();
  }

  void _pearlite(Canvas canvas, _Cell c, math.Random rnd) {
    final b = c.bounds;
    canvas.drawRect(b, Paint()..color = _cPearliteBase);
    // Colonias: 1–3 orientaciones por grano; láminas de cementita oscuras sobre ferrita clara.
    final colonies = 1 + rnd.nextInt(3);
    final light = Paint()..color = const Color(0xFFC9BDAC);
    final dark = Paint()
      ..color = _cLamella
      ..strokeWidth = m.spacing * .5;
    for (var k = 0; k < colonies; k++) {
      final ang = rnd.nextDouble() * math.pi;
      final center = Offset(b.left + rnd.nextDouble() * b.width, b.top + rnd.nextDouble() * b.height);
      final r = b.longestSide;
      canvas.save();
      if (colonies > 1 && k > 0) canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: r * (.35 + rnd.nextDouble() * .2))));
      canvas.translate(center.dx, center.dy);
      canvas.rotate(ang);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: r * 3, height: r * 3), light);
      for (var y = -r * 1.5; y < r * 1.5; y += m.spacing) {
        final wobble = (rnd.nextDouble() - .5) * .25;
        canvas.drawLine(Offset(-r * 1.5, y + wobble), Offset(r * 1.5, y - wobble), dark);
      }
      canvas.restore();
    }
  }

  void _bainite(Canvas canvas, _Cell c, math.Random rnd) {
    final b = c.bounds;
    canvas.drawRect(b, Paint()..color = _cBainiteBase);
    final needle = Paint()
      ..color = _cBainiteNeedle
      ..strokeCap = StrokeCap.round;
    final dot = Paint()..color = const Color(0xFF2A211A);
    final sheaves = (b.width * b.height / 60).round().clamp(6, 80);
    for (var k = 0; k < sheaves; k++) {
      // Haces de agujas paralelas que nacen en un punto (aspecto «plumoso»).
      final o = Offset(b.left + rnd.nextDouble() * b.width, b.top + rnd.nextDouble() * b.height);
      final ang = rnd.nextDouble() * math.pi * 2;
      final dir = Offset(math.cos(ang), math.sin(ang));
      final perp = Offset(-dir.dy, dir.dx);
      final len = 6 + rnd.nextDouble() * 10;
      for (var j = -3; j <= 3; j++) {
        final start = o + perp * (j * .9);
        final l = len * (1 - j.abs() * .12);
        needle.strokeWidth = .45 + rnd.nextDouble() * .25;
        canvas.drawLine(start, start + dir * l, needle);
        for (var q = 1; q < 4; q++) {
          canvas.drawCircle(start + dir * (l * q / 4) + perp * .45, .12, dot);
        }
      }
    }
  }

  void _martensite(Canvas canvas, _Cell c, math.Random rnd) {
    final b = c.bounds;
    final base = m.tempered ? _cMartBaseTempered : _cMartBase;
    canvas.drawRect(b, Paint()..color = base);
    // Paquetes de listones en 3 orientaciones dentro del grano austenítico previo.
    final angs = List.generate(3, (_) => rnd.nextDouble() * math.pi);
    final laths = (b.width * b.height / 4).round().clamp(30, 900);
    final p = Paint()..strokeCap = StrokeCap.round;
    for (var k = 0; k < laths; k++) {
      final o = Offset(b.left + rnd.nextDouble() * b.width, b.top + rnd.nextDouble() * b.height);
      final ang = angs[rnd.nextInt(3)] + (rnd.nextDouble() - .5) * .15;
      final len = 3 + rnd.nextDouble() * 10;
      final d = Offset(math.cos(ang), math.sin(ang)) * (len / 2);
      final shade = rnd.nextDouble();
      p
        ..strokeWidth = .3 + rnd.nextDouble() * .5
        ..color = Color.lerp(m.tempered ? const Color(0xFF4A3A2E) : const Color(0xFF6E5C49),
            m.tempered ? const Color(0xFF7A6654) : const Color(0xFFE7DCC6), shade)!;
      canvas.drawLine(o - d, o + d, p);
    }
    if (m.tempered) {
      final carb = Paint()..color = const Color(0xFF1E1813);
      for (var k = 0; k < laths; k++) {
        canvas.drawCircle(Offset(b.left + rnd.nextDouble() * b.width, b.top + rnd.nextDouble() * b.height), .15, carb);
      }
    }
    if (m.ra > 0) {
      // Austenita retenida: pequeñas islas blancas entre listones.
      final white = Paint()..color = Colors.white;
      final islands = (b.width * b.height * m.ra / 2.5).round();
      for (var k = 0; k < islands; k++) {
        final o = Offset(b.left + rnd.nextDouble() * b.width, b.top + rnd.nextDouble() * b.height);
        canvas.drawRect(Rect.fromCenter(center: o, width: .4 + rnd.nextDouble() * .5, height: .3 + rnd.nextDouble() * .3), white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MicroPainter old) => !identical(old.m, m);
}

/// Leyenda de constituyentes con porcentajes del modelo.
class MicroLegend extends StatelessWidget {
  const MicroLegend({super.key, required this.spec});
  final Map<String, dynamic> spec;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final f = (spec['fractions'] as Map?)?.cast<String, num>();
    final items = <Widget>[];
    if (spec['family'] == 'gray_cast_iron') {
      items.add(_swatch(context, _cGraphite, t.constituent('graphite_flakes')));
      items.add(_swatch(context, _cPearliteBase, t.grayMatrix(spec['matrix'] as String? ?? 'pearlite')));
    } else if (f != null) {
      for (final e in f.entries.where((e) => e.value >= .005)) {
        final label = e.key == 'martensite' && spec['tempered'] == true ? t.constituent('tempered_martensite') : t.constituent(e.key);
        items.add(_swatch(context, e.key == 'martensite' && spec['tempered'] == true ? _cMartBaseTempered
            : constituentSwatch[e.key] ?? Colors.grey, '$label · ${(e.value * 100).toStringAsFixed(1)} %'));
      }
    }
    return Wrap(spacing: FlSpace.m, runSpacing: FlSpace.xs, children: items);
  }

  Widget _swatch(BuildContext context, Color c, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: c, border: Border.all(color: context.fl.border),
            borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: context.text.bodySmall),
      ]);
}
