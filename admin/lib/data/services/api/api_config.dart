import 'package:flutter/foundation.dart';

/// Central API configuration. Works for BOTH Flutter web and the mobile app.
///
/// Base URL resolution:
///  - Web / Windows / iOS simulator / desktop  -> http://localhost:4000
///  - Android emulator                          -> http://10.0.2.2:4000
///  - Production (set [overrideBaseUrl])         -> your Hostinger domain
///
/// For a physical phone on the same Wi-Fi, set [overrideBaseUrl] to your PC's
/// LAN IP, e.g. 'http://192.168.1.20:4000'. In production set it to the deployed
/// API origin, e.g. 'https://api.yourdomain.com'.
class ApiConfig {
  ApiConfig._();

  /// Force a base URL everywhere (e.g. production). Provided at build time via
  ///   flutter build web --release --dart-define=API_BASE_URL=https://ecommai.onewebmart.cloud
  /// When empty (local dev), the platform defaults below are used (localhost).
  static const String overrideBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static const int _port = 4000;

  static String get origin {
    if (overrideBaseUrl.isNotEmpty) {
      return overrideBaseUrl;
    }
    if (kIsWeb) return 'http://localhost:$_port';
    // Non-web: distinguish Android emulator (needs 10.0.2.2) from others.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:$_port';
      default:
        return 'http://localhost:$_port';
    }
  }

  /// Base for all REST endpoints, e.g. http://localhost:4000/api
  static String get baseUrl => '$origin/api';
}
