import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();
  static const _tokenKey = 'token';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = AppConfig.apiBaseUrl.endsWith('/')
        ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
        : AppConfig.apiBaseUrl;
    final uri = Uri.parse('$base$path');
    if (query == null || query.isEmpty) return uri;
    final cleaned = <String, String>{};
    for (final entry in query.entries) {
      final value = entry.value;
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isEmpty) continue;
      cleaned[entry.key] = text;
    }
    return uri.replace(queryParameters: cleaned);
  }

  Future<String?> token() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  Future<void> setToken(String? value) async {
    final prefs = await _prefs;
    if (value == null || value.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, value);
    }
  }

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (auth) {
      final t = await token();
      if (t != null && t.isNotEmpty) {
        headers['Authorization'] = 'Bearer $t';
      }
    }
    return headers;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = false,
  }) async {
    final res = await http.get(
      _uri(path, query),
      headers: await _headers(auth: auth),
    );
    return _decode(res);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = false}) async {
    final res = await http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(res);
  }

  Future<dynamic> patch(String path, {Object? body, bool auth = false}) async {
    final res = await http.patch(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(res);
  }

  Future<dynamic> delete(String path, {bool auth = false}) async {
    final res = await http.delete(
      _uri(path),
      headers: await _headers(auth: auth),
    );
    return _decode(res);
  }

  dynamic _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    final decoded = text.isEmpty ? null : jsonDecode(text);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    final message = decoded is Map && decoded['message'] != null
        ? decoded['message'].toString()
        : 'Request failed (${response.statusCode})';
    throw ApiException(
      message,
      statusCode: response.statusCode,
      errors: decoded is Map && decoded['errors'] is Map<String, dynamic>
          ? decoded['errors'] as Map<String, dynamic>
          : null,
    );
  }
}
