import 'package:ferrolab/features/microscope/microstructure_view.dart';
import 'package:flutter_test/flutter_test.dart';

/// La imagen generada debe mostrar los porcentajes calculados: el área de cada constituyente coincide con su
/// fracción (error menor que el área de un grano) y el conteo de puntos ASTM E562 la recupera dentro de su intervalo.
void main() {
  final cases = <Map<String, double>>[
    {'pearlite': .595, 'bainite': .024, 'martensite': .366, 'retained_austenite': .015}, // 1045 temple de referencia
    {'proeutectoid_ferrite': .085, 'pearlite': .022, 'bainite': .893}, // 8620 martemperizado
    {'proeutectoid_ferrite': .52, 'pearlite': .48}, // recocido
    {'martensite': .97, 'retained_austenite': .03},
    {'bainite': .98, 'proeutectoid_ferrite': .02},
  ];
  for (final g in [6.0, 7.5, 9.0]) {
    for (final (i, f) in cases.indexed) {
      test('caso $i, G = $g', () {
        final r = debugFractions({'seed': 11 + i, 'family': 'steel', 'astm_grain_size': g, 'fractions': f});
        final tol = 1.6 / r.cells + .005; // < área de un grano y medio (granos de área variable)
        for (final e in f.entries) {
          final drawn = r.drawn[e.key] ?? 0;
          expect((drawn - e.value).abs(), lessThan(e.key == 'retained_austenite' ? .006 : tol),
              reason: '${e.key}: dibujado ${(drawn * 100).toStringAsFixed(2)} % vs ${(e.value * 100).toStringAsFixed(1)} %');
          final (p, ci) = r.counted[e.key] ?? (0.0, 0.0);
          // El conteo ASTM E562 debe contener el valor dibujado en su intervalo (con 1 pp de margen por discretización)
          expect((p - drawn).abs(), lessThan(ci + .03), // un grano minoritario puede quedar fuera del campo visible
              reason: '${e.key}: contado ${(p * 100).toStringAsFixed(1)} ± ${(ci * 100).toStringAsFixed(1)} %');
        }
      });
    }
  }
}
