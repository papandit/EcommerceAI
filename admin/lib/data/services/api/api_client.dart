import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

import '../../../routes/routes.dart';
import 'api_config.dart';

/// Storage keys for the JWT session (GetStorage).
class ApiKeys {
  static const token = 'AUTH_TOKEN';
  static const refreshToken = 'AUTH_REFRESH_TOKEN';
  static const user = 'AUTH_USER';
}

/// Thrown for non-2xx responses; carries the server message + status code.
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, [this.statusCode = 0]);
  @override
  String toString() => message;
}

/// Thin REST client over `http`. Attaches the JWT, parses the standard
/// `{ success, message, data }` envelope and returns `data` (List or Map).
/// Used by every admin repository in place of Firestore.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final _storage = GetStorage();

  String? get token => _storage.read<String>(ApiKeys.token);

  Map<String, String> _headers({bool json = true}) {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    final t = token;
    if (t != null && t.isNotEmpty) h['Authorization'] = 'Bearer $t';
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

  /// Parse the envelope; throw [ApiException] on failure.
  dynamic _decode(http.Response res) {
    dynamic body;
    try {
      body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    } catch (_) {
      body = null;
    }
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    if (!ok) {
      // A 401 while we still hold a token means the session expired or was
      // revoked. Without this the middleware keeps letting the admin in (it only
      // checks that a token *exists*), every call fails, and screens look
      // "stuck" with no way back to login.
      if (res.statusCode == 401 && hasToken) _handleExpiredSession();
      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Request failed (${res.statusCode})';
      throw ApiException(msg, res.statusCode);
    }
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }

  // ---- Verbs --------------------------------------------------------------

  /// GET returning a List of maps (for list endpoints).
  Future<List<Map<String, dynamic>>> getList(String path,
      {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers(json: false));
    final data = _decode(res);
    if (data is List) return data.cast<Map<String, dynamic>>();
    // Some endpoints wrap as { items: [...] }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }

  /// GET returning a single map.
  Future<Map<String, dynamic>> getOne(String path,
      {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers(json: false));
    final data = _decode(res);
    return (data is Map) ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }

  /// Raw GET returning whatever `data` is (Map or List).
  Future<dynamic> getRaw(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers(json: false));
    return _decode(res);
  }

  /// Encode a body to JSON, converting values the default encoder can't handle
  /// (notably `DateTime`, since several model `toJson()`s emit raw DateTimes).
  String _encodeBody(Map<String, dynamic> body) {
    return jsonEncode(body, toEncodable: (v) {
      if (v is DateTime) return v.toIso8601String();
      return v.toString();
    });
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(_uri(path), headers: _headers(), body: _encodeBody(body));
    final data = _decode(res);
    return (data is Map) ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(_uri(path), headers: _headers(), body: _encodeBody(body));
    final data = _decode(res);
    return (data is Map) ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }

  Future<void> delete(String path) async {
    final res = await http.delete(_uri(path), headers: _headers());
    _decode(res);
  }

  /// Multipart image upload. Returns the absolute image URL.
  /// [type] = product|banner|category|profile|brand.
  Future<String> uploadImage({
    required String type,
    required Uint8List bytes,
    required String filename,
    String contentTypeField = 'file',
  }) async {
    final req = http.MultipartRequest('POST', _uri('/upload/$type'));
    final t = token;
    if (t != null && t.isNotEmpty) req.headers['Authorization'] = 'Bearer $t';
    req.files.add(http.MultipartFile.fromBytes(contentTypeField, bytes, filename: filename));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    final data = _decode(res);
    if (data is Map && data['url'] != null) return data['url'].toString();
    throw ApiException('Upload failed: no URL returned', res.statusCode);
  }

  // ---- Session helpers ----------------------------------------------------

  Future<void> saveSession(Map<String, dynamic> authData) async {
    if (authData['token'] != null) {
      await _storage.write(ApiKeys.token, authData['token']);
    }
    if (authData['refreshToken'] != null) {
      await _storage.write(ApiKeys.refreshToken, authData['refreshToken']);
    }
    if (authData['user'] != null) {
      await _storage.write(ApiKeys.user, jsonEncode(authData['user']));
    }
  }

  Map<String, dynamic>? get cachedUser {
    final raw = _storage.read<String>(ApiKeys.user);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  bool get hasToken => (token ?? '').isNotEmpty;

  /// Expired/revoked session: drop the stored token and bounce to login once.
  /// Guarded so a burst of parallel 401s can't stack multiple redirects.
  bool _redirectingToLogin = false;
  void _handleExpiredSession() {
    if (_redirectingToLogin) return;
    _redirectingToLogin = true;
    clearSession().whenComplete(() {
      _redirectingToLogin = false;
      if (Get.currentRoute != TRoutes.login) {
        Get.offAllNamed(TRoutes.login);
      }
    });
  }

  Future<void> clearSession() async {
    await _storage.remove(ApiKeys.token);
    await _storage.remove(ApiKeys.refreshToken);
    await _storage.remove(ApiKeys.user);
  }
}
