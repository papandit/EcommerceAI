import 'package:cwt_ecommerce_admin_panel/features/personalization/controllers/settings_controller.dart';
import 'package:get/get.dart';
import '../features/personalization/controllers/user_controller.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    /// -- Core
    Get.lazyPut(() => NetworkManager(), fenix: true);

    /// App-wide controllers feeding the persistent chrome (sidebar logo/name,
    /// header profile). With `fenix` these were disposed and rebuilt during
    /// navigation, re-running onInit() — so every section change re-fetched
    /// settings and blanked the sidebar, which looked like a page reload.
    /// `permanent` keeps one instance alive for the whole session.
    Get.put(UserController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
  }
}
