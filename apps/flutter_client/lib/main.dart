import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/storage/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Árbol de semántica siempre activo: lectores de pantalla y pruebas E2E en web.
  SemanticsBinding.instance.ensureSemantics();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [localStoreProvider.overrideWithValue(LocalStore(prefs))],
    child: const FerrolabApp(),
  ));
}
