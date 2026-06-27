import 'package:flutter/foundation.dart';

/// Central API configuration for the storefront. Works on web + mobile.
///
///  - Web / iOS / desktop          -> http://localhost:4000
///  - Android emulator             -> http://10.0.2.2:4000
///  - Physical device / production -> set [overrideBaseUrl]
class ApiConfig {
  ApiConfig._();

  /// Set this to force a base URL everywhere (e.g. your Hostinger domain).
  static const String? overrideBaseUrl = null;

  static const int _port = 4000;

  static String get origin {
    if (overrideBaseUrl != null && overrideBaseUrl!.isNotEmpty) {
      return overrideBaseUrl!;
    }
    if (kIsWeb) return 'http://localhost:$_port';
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
