/// Configuración de compilación. Solo valores PÚBLICOS: nunca claves privadas.
/// flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
  static const requestTimeout = Duration(seconds: 15);
}
