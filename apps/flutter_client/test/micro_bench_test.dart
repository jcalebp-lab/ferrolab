import 'package:ferrolab/features/microscope/microstructure_view.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tiempo de construcción y dibujo de la microestructura generada (referencia de rendimiento).
void main() {
  test('benchmark microestructura', () {
    for (final g in [7.0, 9.0, 10.5]) {
      final spec = {
        'seed': 7, 'family': 'steel', 'astm_grain_size': g, 'quantitative': true,
        'fractions': {'proeutectoid_ferrite': .2, 'pearlite': .4, 'bainite': .1, 'martensite': .285, 'retained_austenite': .015},
      };
      final sw = Stopwatch()..start();
      final stats = debugBuildAndPaint(spec, 600);
      // ignore: avoid_print
      print('G=$g celdas=${stats.cells} construir=${stats.buildMs} ms dibujar=${stats.paintMs} ms total=${sw.elapsedMilliseconds} ms dibujo=${(stats.bytes / 1024).round()} KB');
    }
  });
}
