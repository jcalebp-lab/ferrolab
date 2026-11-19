import 'package:ferrolab/features/results/results_screen.dart';
import 'package:ferrolab/features/simulation/wizard_screens.dart';
import 'package:ferrolab/shared/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

void main() {
  testWidgets('selector muestra los 3 materiales del catálogo', (tester) async {
    await tester.pumpWidget(await harness(const MaterialStepScreen()));
    await tester.pumpAndSettle();
    expect(find.text('AISI 1045'), findsOneWidget);
    expect(find.text('AISI 8620'), findsOneWidget);
    expect(find.text('GG25 (EN-GJL-250)'), findsOneWidget);
    expect(find.text('Fundición gris'), findsOneWidget);
  });

  testWidgets('sin red: mensaje de reintento, no limitación científica', (tester) async {
    await tester.pumpWidget(await harness(const MaterialStepScreen(), offline: true));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sin conexión al motor'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('resultado sin evidencia: «—» y «No estimable», nunca 0', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final r = SimulationResultDto.fromJson(fixture('sim_quench_850'));
    await tester.pumpWidget(await harness(Scaffold(body: ResultsBody(result: r))));
    await tester.pumpAndSettle();
    expect(find.text('—'), findsNWidgets(5));
    expect(find.text('No estimable con la evidencia actual'), findsNWidgets(5));
    expect(find.textContaining('HRC'), findsNothing);
    expect(find.textContaining('Aún no tenemos una micrografía verificada'), findsWidgets);
    expect(find.textContaining('Herramienta educativa'), findsWidgets);
  });

  testWidgets('localización EN en resultados', (tester) async {
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final r = SimulationResultDto.fromJson(fixture('sim_gjl250_austemper_en'));
    await tester.pumpWidget(await harness(Scaffold(body: ResultsBody(result: r)), locale: 'en'));
    await tester.pumpAndSettle();
    expect(find.text('Not estimable from current evidence'), findsNWidgets(5));
    expect(find.text('Learning only'), findsOneWidget);
  });

  testWidgets('dato publicado: se muestra con unidad, nivel y fuente', (tester) async {
    // Hecho SINTÉTICO de formato (no metalurgia) para comprobar el renderizado de la tarjeta.
    final q = QuantityResult(
      code: QuantityCode.hardness,
      single: ResultFact(value: 123, unit: 'HV', method: 'synthetic', evidenceKind: EvidenceKind.measured,
          evidenceLevel: EvidenceLevel.validated, sourceIds: const ['src_test']),
      level: EvidenceLevel.validated,
      reason: 'ok',
    );
    await tester.pumpWidget(await harness(Scaffold(body: ResultFactCard(q: q))));
    await tester.pumpAndSettle();
    expect(find.text('123 HV'), findsOneWidget);
    expect(find.text('Validado'), findsOneWidget);
    expect(find.textContaining('src_test'), findsOneWidget);
  });
}
