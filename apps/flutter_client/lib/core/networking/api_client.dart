import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/models/models.dart';
import '../config.dart';

/// Error de la API (contrato homogéneo de doc 06 §10).
class ApiException implements Exception {
  ApiException(this.status, this.code, this.message, {this.requestId, this.details = const {}});
  final int status;
  final String code, message;
  final String? requestId;
  final Json details;
  @override
  String toString() => 'ApiException($status $code: $message)';
}

/// Fallo de red: distinto de una limitación científica (doc 07 §13.1).
class NetworkException implements Exception {
  NetworkException(this.cause);
  final Object cause;
  @override
  String toString() => 'NetworkException($cause)';
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _http = client ?? http.Client(),
        _base = ((baseUrl == null || baseUrl.isEmpty) ? AppConfig.apiBaseUrl : baseUrl).replaceAll(RegExp(r'/$'), '');
  final http.Client _http;
  final String _base;
  String get baseUrl => _base;

  Uri _u(String path, [Map<String, String>? q]) => Uri.parse('$_base$path').replace(queryParameters: q);

  Future<Json> get(String path, {Map<String, String>? query, String? bearer}) =>
      _send(() => _http.get(_u(path, query), headers: _headers(bearer)));

  Future<Json> post(String path, Object body, {String? bearer}) =>
      _send(() => _http.post(_u(path), headers: _headers(bearer, json: true), body: jsonEncode(body)));

  Future<Json> patch(String path, Object body, {String? bearer}) =>
      _send(() => _http.patch(_u(path), headers: _headers(bearer, json: true), body: jsonEncode(body)));

  /// POST a un servicio externo (p. ej. Supabase Auth del panel admin).
  Future<Json> postAbsolute(Uri uri, Object body, Map<String, String> headers) =>
      _send(() => _http.post(uri, headers: {'Content-Type': 'application/json', ...headers}, body: jsonEncode(body)));

  Map<String, String> _headers(String? bearer, {bool json = false}) => {
        'Accept': 'application/json',
        if (json) 'Content-Type': 'application/json',
        if (bearer != null) 'Authorization': 'Bearer $bearer',
      };

  Future<Json> _send(Future<http.Response> Function() call) async {
    http.Response r;
    try {
      r = await call().timeout(AppConfig.requestTimeout);
    } on TimeoutException catch (e) {
      throw NetworkException(e);
    } on http.ClientException catch (e) {
      throw NetworkException(e);
    }
    Json body;
    try {
      body = r.body.isEmpty ? <String, dynamic>{} : jsonDecode(utf8.decode(r.bodyBytes)) as Json;
    } on FormatException {
      throw ApiException(r.statusCode, 'invalid_response', 'Respuesta no válida');
    }
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    final err = (body['error'] as Json?) ?? {};
    throw ApiException(
      r.statusCode,
      (err['code'] ?? body['error_description'] ?? 'http_${r.statusCode}').toString(),
      (err['message'] ?? body['msg'] ?? body['error_description'] ?? 'Error').toString(),
      requestId: err['request_id'] as String?,
      details: (err['details'] as Json?) ?? const {},
    );
  }
}

/// Repositorio público tipado (sin lógica científica: solo transporte).
class FerrolabRepository {
  FerrolabRepository(this.api);
  final ApiClient api;

  Future<HealthDto> health() async => HealthDto.fromJson(await api.get('/api/v1/health/ready'));

  Future<List<MaterialDto>> materials(String locale) async {
    final j = await api.get('/api/v1/materials', query: {'locale': locale});
    return (j['items'] as List).map((e) => MaterialDto.fromJson(e as Json)).toList();
  }

  Future<List<TreatmentDto>> treatments(String locale) async {
    final j = await api.get('/api/v1/treatments', query: {'locale': locale});
    return (j['items'] as List).map((e) => TreatmentDto.fromJson(e as Json)).toList();
  }

  Future<PairsDto> pairs(String materialId, String locale) async =>
      PairsDto.fromJson(await api.get('/api/v1/materials/$materialId/treatments', query: {'locale': locale}));

  Future<ValidationReportDto> validate(SimulationInput input, String locale) async =>
      ValidationReportDto.fromJson(await api.post('/api/v1/simulations/validate', input.toJson(locale)));

  Future<SimulationResultDto> simulate(SimulationInput input, String locale) async =>
      SimulationResultDto.fromJson(await api.post('/api/v1/simulations', input.toJson(locale)));

  Future<List<KnowledgeEntryDto>> knowledge(String locale) async {
    final j = await api.get('/api/v1/knowledge', query: {'locale': locale});
    return (j['items'] as List).map((e) => KnowledgeEntryDto.fromJson(e as Json)).toList();
  }

  Future<List<PracticeQuestionDto>> practice(String locale) async {
    final j = await api.get('/api/v1/practice', query: {'locale': locale});
    return (j['items'] as List).map((e) => PracticeQuestionDto.fromJson(e as Json)).toList();
  }

  Future<List<SourceRef>> sources() async {
    final j = await api.get('/api/v1/sources');
    return (j['items'] as List).map((e) => SourceRef.fromJson(e as Json)).toList();
  }

  Future<List<MicrographDto>> micrographs(String locale) async {
    final j = await api.get('/api/v1/micrographs', query: {'locale': locale});
    return (j['items'] as List).map((e) => MicrographDto.fromJson(e as Json)).toList();
  }

  Future<TutorResponseDto> tutorExplain(SimulationInput input, String locale) async => TutorResponseDto.fromJson(
      await api.post('/api/v1/tutor/explain', {'simulation': input.toJson(locale), 'locale': locale}));

  Future<TutorResponseDto> tutorAsk(String question, SimulationInput? input, String locale) async =>
      TutorResponseDto.fromJson(await api.post('/api/v1/tutor/ask', {
        'question': question,
        if (input != null) 'simulation': input.toJson(locale),
        'locale': locale,
      }));
}
