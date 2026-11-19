import 'package:ferrolab/features/microscope/microstructure_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

/// Geometría del dibujo (no metalurgia): el intercepto medido sobre la imagen generada debe dar
/// aproximadamente el mismo número G con el que se dibujó (área media de ASTM E112).
void main() {
  for (final g in [6.0, 7.4, 9.0]) {
    testWidgets('medición de grano coherente con G = $g', (tester) async {
      tester.view.physicalSize = const Size(900, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final spec = {
        'kind': 'generated_illustration', 'seed': 42, 'family': 'steel', 'astm_grain_size': g,
        'grain_kind': 'prior_austenite', 'grain_computed': true, 'quantitative': true,
        'fractions': {'martensite': 1.0},
      };
      await tester.pumpWidget(await harness(Scaffold(body: SingleChildScrollView(child: GeneratedMicroscope(spec: spec, height: 400)))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('grainMeasureToggle')));
      await tester.pumpAndSettle();
      final txt = tester.widget<Text>(find.byKey(const Key('grainMeasured'))).data!;
      final measured = double.parse(RegExp(r'G medido = ([0-9.]+)').firstMatch(txt)!.group(1)!);
      expect((measured - g).abs(), lessThan(0.8), reason: txt);
    });
  }
}
