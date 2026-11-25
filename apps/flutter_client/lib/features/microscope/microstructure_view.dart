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
  bool _count = false;
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
                      foregroundPainter: _measure
                          ? _MeasurePainter(_micro.intercepts)
                          : (_count ? _PointPainter(_micro.pointCount) : null),
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
              onSelected: (v) => setState(() {
                _measure = v;
                if (v) _count = false;
              }),
            ),
          ),
          if (widget.spec['fractions'] != null) ...[
            const Gap(FlSpace.xs),
            Center(
              child: FilterChip(
                key: const Key('pointCountToggle'),
                avatar: const Icon(Icons.grid_on, size: 18),
                label: Text(t.pointCountToggle),
                selected: _count,
                onSelected: (v) => setState(() {
                  _count = v;
                  if (v) _measure = false;
                }),
              ),
            ),
          ],
          if (_measure) ...[const Gap(FlSpace.s), _MeasurePanel(m: _micro)],
          if (_count) ...[const Gap(FlSpace.s), _CountPanel(m: _micro, labels: _labelText(context))],
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

/// Rejilla espacial de puntos: vecinos y punto más cercano sin recorrer todos (exacto).
class _SiteGrid {
  _SiteGrid(this.sites, this.size) : cols = (kFieldUm / size).ceil() + 1 {
    for (var i = 0; i < sites.length; i++) {
      (_cells[_key(sites[i])] ??= <int>[]).add(i);
    }
  }
  final List<Offset> sites;
  final double size;
  final int cols;
  final _cells = <int, List<int>>{};
  int _key(Offset p) => _clampI(p.dy ~/ size) * cols + _clampI(p.dx ~/ size);
  int _clampI(int v) => v < 0 ? 0 : (v >= cols ? cols - 1 : v);

  /// Índices de los puntos a menos de `radius` de `p`.
  Iterable<int> within(Offset p, double radius) sync* {
    final r = (radius / size).ceil();
    final cx = p.dx ~/ size, cy = p.dy ~/ size, r2 = radius * radius;
    for (var y = cy - r; y <= cy + r; y++) {
      if (y < 0 || y >= cols) continue;
      for (var x = cx - r; x <= cx + r; x++) {
        if (x < 0 || x >= cols) continue;
        for (final i in _cells[y * cols + x] ?? const <int>[]) {
          if ((sites[i] - p).distanceSquared <= r2) yield i;
        }
      }
    }
  }

  /// Punto más cercano (búsqueda por anillos; se detiene cuando nada fuera puede estar más cerca).
  int nearest(Offset p) {
    final cx = p.dx ~/ size, cy = p.dy ~/ size;
    var best = -1;
    var bd = double.infinity;
    for (var r = 0; r <= cols; r++) {
      for (var y = cy - r; y <= cy + r; y++) {
        for (var x = cx - r; x <= cx + r; x++) {
          if ((y - cy).abs() != r && (x - cx).abs() != r) continue;
          if (x < 0 || y < 0 || x >= cols || y >= cols) continue;
          for (final i in _cells[y * cols + x] ?? const <int>[]) {
            final d = (sites[i] - p).distanceSquared;
            if (d < bd) {
              bd = d;
              best = i;
            }
          }
        }
      }
      if (best >= 0 && bd <= (r * size) * (r * size)) break;
    }
    return best;
  }
}

/// Lado de las islas de austenita retenida (µm). Tamaño fijo: así su área total es exactamente la calculada.
const _raW = .6, _raH = .45;

class _Micro {
  _Micro(this.cells, this.spec, this.flakes, this.tempered, this.spacing, this.ra, this.dGrain, this.grid,
      this.islands);
  final double dGrain; // lado del grano de área media (µm)
  final _SiteGrid grid; // granos (Voronoi): la celda de un punto es la de su sitio más cercano
  final List<Offset> islands; // centros de las islas de austenita retenida
  _Intercepts? _intercepts;
  _Intercepts get intercepts => _intercepts ??= _Intercepts.measure(this);
  _PointCount? _points;
  _PointCount get pointCount => _points ??= _PointCount.measure(this);
  ui.Picture? picture; // caché del dibujo (ver _MicroPainter.paint)
  double? pictureWidth;
  final List<_Cell> cells;
  final Map<String, dynamic> spec;
  final List<List<Offset>> flakes;
  final bool tempered;
  final double spacing; // separación interlaminar ilustrativa (µm)
  final double ra; // fracción de austenita retenida

  /// Constituyente en un punto del campo (lo que «ve» el estudiante): isla de austenita o el grano que lo contiene.
  String kindAt(Offset p) {
    for (final c in islands) {
      if ((p.dx - c.dx).abs() <= _raW / 2 && (p.dy - c.dy).abs() <= _raH / 2) return 'retained_austenite';
    }
    return cells[grid.nearest(p)].kind;
  }

  /// Fracción de área DIBUJADA de cada constituyente (exacta: áreas de polígonos e islas).
  Map<String, double> drawnFractions() {
    final total = cells.fold<double>(0, (a, c) => a + c.area);
    final out = <String, double>{};
    for (final c in cells) {
      out[c.kind] = (out[c.kind] ?? 0) + c.area / total;
    }
    if (islands.isNotEmpty) {
      final raArea = islands.length * _raW * _raH / total;
      final host = _raHost(out.keys);
      out[host] = (out[host] ?? 0) - raArea;
      out['retained_austenite'] = raArea;
    }
    return out;
  }

  /// La austenita retenida queda entre los listones de martensita (o de bainita si no hay martensita).
  static String _raHost(Iterable<String> kinds) =>
      kinds.contains('martensite') ? 'martensite' : (kinds.contains('bainite') ? 'bainite' : kinds.first);

  static _Micro build(Map<String, dynamic> spec) {
    final rnd = math.Random((spec['seed'] as num?)?.toInt() ?? 1);
    final g = (spec['astm_grain_size'] as num?)?.toDouble() ?? 7;
    // ASTM E112: granos por mm² a 1× = 2^(G−1)·15.5 → área media del grano.
    final grainArea = 1e6 / (math.pow(2, g - 1) * 15.5);
    final n = (kFieldUm * kFieldUm / grainArea).round().clamp(12, 700);
    final dGrain = math.sqrt(grainArea);
    // Sitios casi uniformes (Poisson con distancia mínima) para granos equiaxiales; rejilla para no comparar con todos.
    final minD = dGrain * .55;
    final sites = <Offset>[];
    final cellSize = minD / math.sqrt2; // a lo sumo un sitio por celda
    final cols = (kFieldUm / cellSize).ceil() + 1;
    final occ = <int, int>{};
    var guard = 0;
    while (sites.length < n && guard++ < n * 60) {
      final p = Offset(rnd.nextDouble() * kFieldUm, rnd.nextDouble() * kFieldUm);
      final cx = p.dx ~/ cellSize, cy = p.dy ~/ cellSize;
      var ok = true;
      for (var y = cy - 2; y <= cy + 2 && ok; y++) {
        for (var x = cx - 2; x <= cx + 2 && ok; x++) {
          final o = occ[y * cols + x];
          if (o != null && (sites[o] - p).distance <= minD) ok = false;
        }
      }
      if (ok) {
        occ[cy * cols + cx] = sites.length;
        sites.add(p);
      }
    }
    final grid = _SiteGrid(sites, dGrain);
    final square = [const Offset(0, 0), const Offset(kFieldUm, 0), const Offset(kFieldUm, kFieldUm), const Offset(0, kFieldUm)];
    final cells = <_Cell>[];
    final keep = <int>[];
    for (var i = 0; i < sites.length; i++) {
      var poly = square;
      for (final o in grid.within(sites[i], dGrain * 3.2)) {
        if (o == i) continue;
        poly = _clip(poly, sites[i], sites[o]);
        if (poly.isEmpty) break;
      }
      if (poly.length >= 3) {
        cells.add(_Cell(poly, sites[i]));
        keep.add(i);
      }
    }
    final cellGrid = keep.length == sites.length ? grid : _SiteGrid([for (final c in cells) c.site], dGrain);
    final family = spec['family'] as String? ?? 'steel';
    final fractions = <String, double>{};
    var ra = 0.0;
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
        if (e.value <= 0) continue;
        if (e.key == 'retained_austenite') {
          ra = e.value.toDouble();
        } else {
          fractions[e.key] = e.value.toDouble();
        }
      }
      if (fractions.isEmpty) fractions['pearlite'] = 1;
    }
    // La austenita retenida se dibuja como islas DENTRO de su constituyente anfitrión: el anfitrión recibe también
    // esa área para que, al restar las islas, cada constituyente ocupe exactamente su fracción.
    final fsum = fractions.values.fold<double>(0, (a, b) => a + b) + ra;
    final target = {for (final e in fractions.entries) e.key: e.value / fsum};
    final raFrac = ra / fsum;
    if (raFrac > 0) {
      final host = _raHost(target.keys);
      target[host] = target[host]! + raFrac;
    }
    _assign(cells, target, rnd);
    // Islas de austenita retenida: número exacto para su fracción de área, repartidas en las celdas anfitrionas.
    final islands = <Offset>[];
    final total = cells.fold<double>(0, (a, c) => a + c.area);
    if (raFrac > 0) {
      final host = _raHost(target.keys);
      final hostIdx = [for (var i = 0; i < cells.length; i++) if (cells[i].kind == host) i];
      var hostArea = hostIdx.fold<double>(0, (a, i) => a + cells[i].area);
      var remaining = (raFrac * total / (_raW * _raH)).round();
      for (final i in hostIdx) {
        final c = cells[i];
        final want = hostArea <= 0 ? 0 : (remaining * c.area / hostArea).round();
        final b = c.bounds;
        var placed = 0, tries = 0;
        while (placed < want && tries++ < want * 40 + 40) {
          final o = Offset(b.left + rnd.nextDouble() * b.width, b.top + rnd.nextDouble() * b.height);
          if (cellGrid.nearest(o) != i) continue; // la isla debe caer dentro de su grano
          islands.add(o);
          placed++;
        }
        remaining -= placed;
        hostArea -= c.area;
      }
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
    return _Micro(cells, spec, flakes, spec['tempered'] == true || spec['matrix'] == 'tempered_martensite',
        spec['pearlite_spacing'] == 'coarse' ? 1.6 : 0.9, raFrac, dGrain, cellGrid, islands);
  }

  /// Asigna cada grano a un constituyente para que las áreas se acerquen al objetivo: reparto por mayor déficit
  /// (orden aleatorio reproducible) y después mejora local moviendo granos sueltos mientras reduzca el error.
  static void _assign(List<_Cell> cells, Map<String, double> target, math.Random rnd) {
    final total = cells.fold<double>(0, (a, c) => a + c.area);
    final assigned = {for (final k in target.keys) k: 0.0};
    final order = [...cells]..shuffle(rnd);
    for (final c in order) {
      var best = target.keys.first;
      var deficit = -double.infinity;
      for (final k in target.keys) {
        final d = target[k]! * total - assigned[k]!;
        if (d > deficit) {
          deficit = d;
          best = k;
        }
      }
      c.kind = best;
      assigned[best] = assigned[best]! + c.area;
    }
    double err(Map<String, double> a) => target.keys.fold(0.0, (s, k) => s + (a[k]! - target[k]! * total).abs());
    for (var pass = 0; pass < 4; pass++) {
      var improved = false;
      for (final c in order) {
        final from = c.kind;
        for (final to in target.keys) {
          if (to == from) continue;
          final before = err(assigned);
          assigned[from] = assigned[from]! - c.area;
          assigned[to] = assigned[to]! + c.area;
          if (err(assigned) < before - 1e-9) {
            c.kind = to;
            improved = true;
            break;
          }
          assigned[from] = assigned[from]! + c.area;
          assigned[to] = assigned[to]! - c.area;
        }
      }
      if (!improved) break;
    }
  }
}

/// Conteo sistemático de puntos (ASTM E562) sobre la imagen GENERADA: una cuadrícula regular cubre todo el campo
/// circular visible; la fracción de puntos sobre cada constituyente estima su fracción de volumen (P_P ≈ V_V).
/// Los puntos que caen en un mismo grano no son independientes, así que el intervalo del 95 % se calcula con el
/// número de granos distintos que toca la cuadrícula: 1,96·√(p(1−p)/granos).
class _PointCount {
  _PointCount(this.points, this.kinds, this.grains);
  final List<Offset> points;
  final List<String> kinds; // constituyente bajo cada punto
  final int grains; // granos distintos bajo la cuadrícula (tamaño efectivo de la muestra)
  static const across = 28; // puntos a lo ancho del campo
  int get n => points.length;

  /// Fracción medida y semiamplitud del intervalo del 95 %.
  Map<String, (double, double)> fractions() {
    final counts = <String, int>{};
    for (final k in kinds) {
      counts[k] = (counts[k] ?? 0) + 1;
    }
    return {
      for (final e in counts.entries)
        e.key: (e.value / n, 1.96 * math.sqrt((e.value / n) * (1 - e.value / n) / math.max(grains, 1))),
    };
  }

  static _PointCount measure(_Micro m) {
    const c = kFieldUm / 2, radius = kFieldUm * .46; // dentro del campo circular visible
    const step = 2 * radius / across;
    final pts = <Offset>[];
    for (var y = 0; y < across; y++) {
      for (var x = 0; x < across; x++) {
        final p = Offset(c - radius + (x + .5) * step, c - radius + (y + .5) * step);
        if ((p - const Offset(c, c)).distance <= radius) pts.add(p);
      }
    }
    final grains = {for (final p in pts) m.grid.nearest(p)}.length;
    return _PointCount(pts, [for (final p in pts) m.kindAt(p)], grains);
  }
}

class _PointPainter extends CustomPainter {
  _PointPainter(this.pc);
  final _PointCount pc;
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / kFieldUm;
    final cross = Path();
    for (final p in pc.points) {
      final q = p * s;
      cross
        ..moveTo(q.dx - 3, q.dy)
        ..lineTo(q.dx + 3, q.dy)
        ..moveTo(q.dx, q.dy - 3)
        ..lineTo(q.dx, q.dy + 3);
    }
    canvas.drawPath(cross, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..color = Colors.black.withValues(alpha: .6));
    canvas.drawPath(cross, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFFFEA00));
  }

  @override
  bool shouldRepaint(covariant _PointPainter old) => old.pc != pc;
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
    int nearest(Offset p) => m.grid.nearest(p);

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

class _CountPanel extends StatelessWidget {
  const _CountPanel({required this.m, required this.labels});
  final _Micro m;
  final Map<String, String> labels;
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final pc = m.pointCount;
    final measured = pc.fractions();
    final model = ((m.spec['fractions'] as Map?) ?? const {}).cast<String, num>();
    final keys = {...model.keys.where((k) => (model[k] ?? 0) >= .0005), ...measured.keys}.toList()
      ..sort((a, b) => (model[b] ?? 0).compareTo(model[a] ?? 0));
    String pct(num v) => '${(v * 100).toStringAsFixed(1)} %';
    return Container(
      key: const Key('pointCountPanel'),
      padding: const EdgeInsets.all(FlSpace.m),
      decoration: BoxDecoration(
        color: context.fl.surface,
        borderRadius: BorderRadius.circular(FlRadius.input),
        border: Border.all(color: context.fl.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.pointCountTitle, style: context.text.titleSmall),
        const Gap(FlSpace.xs),
        Text(t.pointCountBody(pc.n.toString(), pc.grains.toString())),
        const Gap(FlSpace.xs),
        for (final k in keys)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              t.pointCountRow(labels[k] ?? t.constituent(k), pct(measured[k]?.$1 ?? 0), pct(measured[k]?.$2 ?? 0),
                  pct(model[k] ?? 0)),
              key: Key('pc_$k'),
            ),
          ),
        const Gap(FlSpace.xs),
        Text(t.pointCountNote, style: context.text.bodySmall),
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
    if (m.islands.isNotEmpty) {
      // Austenita retenida: islas blancas de tamaño fijo; su número da exactamente la fracción calculada.
      final isl = Path();
      for (final o in m.islands) {
        isl.addRect(Rect.fromCenter(center: o, width: _raW, height: _raH));
      }
      canvas.drawPath(isl, Paint()..color = Colors.white);
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

  // Los trazos de cada grano se agrupan en pocas trayectorias (Path) en lugar de miles de drawLine: el dibujo pesa
  // menos y se rasteriza más rápido en celulares.
  void _pearlite(Canvas canvas, _Cell c, math.Random rnd) {
    final b = c.bounds;
    canvas.drawRect(b, Paint()..color = _cPearliteBase);
    // Colonias: 1–3 orientaciones por grano; láminas de cementita oscuras sobre ferrita clara.
    final colonies = 1 + rnd.nextInt(3);
    final light = Paint()..color = const Color(0xFFC9BDAC);
    final dark = Paint()
      ..color = _cLamella
      ..style = PaintingStyle.stroke
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
      final lamellae = Path();
      for (var y = -r * 1.5; y < r * 1.5; y += m.spacing) {
        final wobble = (rnd.nextDouble() - .5) * .25;
        lamellae
          ..moveTo(-r * 1.5, y + wobble)
          ..lineTo(r * 1.5, y - wobble);
      }
      canvas.drawPath(lamellae, dark);
      canvas.restore();
    }
  }

  void _bainite(Canvas canvas, _Cell c, math.Random rnd) {
    final b = c.bounds;
    canvas.drawRect(b, Paint()..color = _cBainiteBase);
    final needles = [Path(), Path()]; // dos grosores
    final dots = Path();
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
        final end = start + dir * l;
        needles[rnd.nextBool() ? 1 : 0]
          ..moveTo(start.dx, start.dy)
          ..lineTo(end.dx, end.dy);
        for (var q = 1; q < 4; q++) {
          dots.addOval(Rect.fromCircle(center: start + dir * (l * q / 4) + perp * .45, radius: .12));
        }
      }
    }
    for (final (w, path) in [(.5, needles[0]), (.65, needles[1])]) {
      canvas.drawPath(path, Paint()
        ..color = _cBainiteNeedle
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w);
    }
    canvas.drawPath(dots, Paint()..color = const Color(0xFF2A211A));
  }

  void _martensite(Canvas canvas, _Cell c, math.Random rnd) {
    final b = c.bounds;
    final base = m.tempered ? _cMartBaseTempered : _cMartBase;
    canvas.drawRect(b, Paint()..color = base);
    // Paquetes de listones en 3 orientaciones dentro del grano austenítico previo; 4 tonos × 2 grosores.
    final angs = List.generate(3, (_) => rnd.nextDouble() * math.pi);
    final laths = (b.width * b.height / 4).round().clamp(30, 900);
    final groups = List.generate(8, (_) => Path());
    for (var k = 0; k < laths; k++) {
      final o = Offset(b.left + rnd.nextDouble() * b.width, b.top + rnd.nextDouble() * b.height);
      final ang = angs[rnd.nextInt(3)] + (rnd.nextDouble() - .5) * .15;
      final len = 3 + rnd.nextDouble() * 10;
      final d = Offset(math.cos(ang), math.sin(ang)) * (len / 2);
      final g = (rnd.nextDouble() * 4).floor().clamp(0, 3) * 2 + (rnd.nextDouble() < .5 ? 0 : 1);
      groups[g]
        ..moveTo((o - d).dx, (o - d).dy)
        ..lineTo((o + d).dx, (o + d).dy);
    }
    final lo = m.tempered ? const Color(0xFF4A3A2E) : const Color(0xFF6E5C49);
    final hi = m.tempered ? const Color(0xFF7A6654) : const Color(0xFFE7DCC6);
    for (var g = 0; g < 8; g++) {
      canvas.drawPath(groups[g], Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = g.isEven ? .4 : .7
        ..color = Color.lerp(lo, hi, (g ~/ 2 + .5) / 4)!);
    }
    if (m.tempered) {
      final carb = Path();
      for (var k = 0; k < laths; k++) {
        carb.addOval(Rect.fromCircle(center: Offset(b.left + rnd.nextDouble() * b.width, b.top + rnd.nextDouble() * b.height), radius: .15));
      }
      canvas.drawPath(carb, Paint()..color = const Color(0xFF1E1813));
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

/// Solo para pruebas y medidas de rendimiento: construye y graba el dibujo de una microestructura.
@visibleForTesting
({int cells, int buildMs, int paintMs, int bytes}) debugBuildAndPaint(Map<String, dynamic> spec, double side) {
  final sw = Stopwatch()..start();
  final m = _Micro.build(spec);
  final b = sw.elapsedMilliseconds;
  final rec = ui.PictureRecorder();
  _MicroPainter(m)._draw(Canvas(rec), Size(side, side));
  final pic = rec.endRecording();
  final bytes = pic.approximateBytesUsed;
  pic.dispose();
  return (cells: m.cells.length, buildMs: b, paintMs: sw.elapsedMilliseconds - b, bytes: bytes);
}

/// Solo para pruebas: fracciones de área dibujadas, conteo de puntos ASTM E562 y número de granos.
@visibleForTesting
({Map<String, double> drawn, Map<String, (double, double)> counted, int cells}) debugFractions(Map<String, dynamic> spec) {
  final m = _Micro.build(spec);
  return (drawn: m.drawnFractions(), counted: m.pointCount.fractions(), cells: m.cells.length);
}
