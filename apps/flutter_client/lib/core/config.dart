import 'package:flutter/foundation.dart';

/// Configuración de compilación. Solo valores PÚBLICOS: nunca claves privadas.
/// Sin API_BASE_URL, en web se usa la misma dirección desde la que se cargó la app
/// (la API sirve la app con SERVE_WEB_APP=true); fuera de web, localhost:8000.
/// flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
abstract final class AppConfig {
  static const _configured = String.fromEnvironment('API_BASE_URL');
  static String get apiBaseUrl =>
      _configured.isNotEmpty ? _configured : (kIsWeb ? Uri.base.origin : 'http://localhost:8000');
  static const requestTimeout = Duration(seconds: 15);
  /// Versión visible de la app (igual a `version` de pubspec.yaml); permite comprobar qué APK está instalado.
  static const appVersion = '0.6.1';
}
