import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';
import 'data/repositories/authentication/authentication_repository.dart';

final navigatorKey = GlobalKey<NavigatorState>();

/// Entry point of the admin panel. Firebase has been removed — the panel runs
/// entirely on the Node/MongoDB backend (JWT auth, REST data, backend uploads).
Future<void> main() async {
  // Ensure that widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetX Local Storage (holds the JWT session)
  await GetStorage.init();

  // Remove the # sign from the URL
  setPathUrlStrategy();

  // Auth is JWT against our backend.
  Get.put(AuthenticationRepository());

  // Main App Starts here...
  runApp(const App());
}
