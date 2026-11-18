import 'dart:convert';
import 'dart:io';

import 'package:ferrolab/app/l10n.dart';
import 'package:ferrolab/app/providers.dart';
import 'package:ferrolab/core/design_system/theme.dart';
import 'package:ferrolab/core/networking/api_client.dart';
import 'package:ferrolab/core/storage/local_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Respuestas REALES capturadas de la API local (test/fixtures), no datos inventados.
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync()) as Map<String, dynamic>;

http.Client fakeApi({bool offline = false}) => MockClient((req) async {
      if (offline) throw http.ClientException('offline');
      final p = req.url.path;
      String? name;
      if (p.endsWith('/health/ready')) name = 'health';
      if (p.endsWith('/materials')) name = 'materials';
      if (p.endsWith('/treatments') && !p.contains('materials')) name = 'treatments';
      if (p.contains('/materials/aisi_1045/treatments')) name = 'pairs_1045';
      if (p.endsWith('/simulations')) {
        final b = jsonDecode(req.body) as Map;
        name = (b['target_temperature_c'] as num) >= 1538 ? 'sim_1600' : 'sim_quench_850';
      }
      if (name == null) return http.Response('{"items":[]}', 200);
      return http.Response(File('test/fixtures/$name.json').readAsStringSync(), 200,
          headers: {'content-type': 'application/json; charset=utf-8'});
    });

Future<Widget> harness(Widget child, {bool offline = false, String locale = 'es'}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      localStoreProvider.overrideWithValue(LocalStore(prefs)),
      apiClientProvider.overrideWithValue(ApiClient(client: fakeApi(offline: offline), baseUrl: 'http://test')),
    ],
    child: MaterialApp(
      theme: buildTheme(Brightness.light),
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      home: child,
    ),
  );
}
