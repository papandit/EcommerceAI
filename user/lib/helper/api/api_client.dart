import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

/// SharedPreferences keys for the JWT session.
class ApiKeys {
  static const token = 'AUTH_TOKEN';
  static const refreshToken = 'AUTH_REFRESH_TOKEN';
  static const user = 'AUTH_USER';
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, [this.statusCode = 0]);
  @override
  String toString() => message;
}

/// Thin REST client over `http` for the storefront. Parses the standard
/// `{ success, message, data }` envelope and returns `data`. Replaces Firestore.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _token;

  /// Hydrate the cached JWT from storage. Call once at app start.
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(ApiKeys.token);
  }

  String? get token => _token;
  bool get hasToken => (_token ?? '').isNotEmpty;

  Map<String, String> _headers({bool json = true}) {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    if (hasToken) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final p = path.startsWith('/') ? path : '/$path';
    Map<String, String>? cleaned;
    if (query != null) {
      cleaned = <String, String>{};
      query.forEach((k, v) {
        if (v != null) cleaned![k] = v.toString();
      });
    }
    return Uri.parse('${ApiConfig.baseUrl}$p').replace(queryParameters: cleaned);
  }

  dynamic _decode(http.Response res) {
    dynamic body;
    try {
      body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    } catch (_) {
      body = null;
    }
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    if (!ok) {
      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Request failed (${res.statusCode})';
      throw ApiException(msg, res.statusCode);
    }
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }

  String _encodeBody(Map<String, dynamic> body) =>
      jsonEncode(body, toEncodable: (v) {
        if (v is DateTime) return v.toIso8601String();
        return v.toString();
      });

  Future<List<Map<String, dynamic>>> getList(String path,
      {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers(json: false));
    final data = _decode(res);
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> getOne(String path,
      {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers(json: false));
    final data = _decode(res);
    return (data is Map) ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res =
        await http.post(_uri(path), headers: _headers(), body: _encodeBody(body));
    final data = _decode(res);
    return (data is Map) ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res =
        await http.put(_uri(path), headers: _headers(), body: _encodeBody(body));
    final data = _decode(res);
    return (data is Map) ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }

  Future<void> delete(String path) async {
    final res = await http.delete(_uri(path), headers: _headers());
    _decode(res);
  }

  /// Multipart image upload (profile pics, review images). Returns the URL.
  Future<String> uploadImage({
    required String type,
    required Uint8List bytes,
    required String filename,
  }) async {
    final req = http.MultipartRequest('POST', _uri('/upload/$type'));
    if (hasToken) req.headers['Authorization'] = 'Bearer $_token';
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    final data = _decode(res);
    if (data is Map && data['url'] != null) return data['url'].toString();
    throw ApiException('Upload failed', res.statusCode);
  }

  // ---- Session ----
  Future<void> saveSession(Map<String, dynamic> authData) async {
    final prefs = await SharedPreferences.getInstance();
    if (authData['token'] != null) {
      _token = authData['token'].toString();
      await prefs.setString(ApiKeys.token, _token!);
    }
    if (authData['refreshToken'] != null) {
      await prefs.setString(
          ApiKeys.refreshToken, authData['refreshToken'].toString());
    }
    if (authData['user'] != null) {
      await prefs.setString(ApiKeys.user, jsonEncode(authData['user']));
    }
  }

  Future<Map<String, dynamic>?> cachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(ApiKeys.user);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = null;
    await prefs.remove(ApiKeys.token);
    await prefs.remove(ApiKeys.refreshToken);
    await prefs.remove(ApiKeys.user);
  }
}
