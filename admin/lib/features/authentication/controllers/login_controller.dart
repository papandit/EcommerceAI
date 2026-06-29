import 'package:cwt_ecommerce_admin_panel/features/personalization/controllers/settings_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/text_strings.dart';
import '../../personalization/controllers/user_controller.dart';
import '../../personalization/models/user_model.dart';

/// Controller for handling login functionality
class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// Whether the password should be hidden
  final hidePassword = true.obs;

  /// Whether the user has selected "Remember Me"
  final rememberMe = false.obs;

  /// Local storage instance for remembering email and password
  final localStorage = GetStorage();

  /// Text editing controller for the email field
  final email = TextEditingController();

  /// Text editing controller for the password field
  final password = TextEditingController();

  /// Form key for the login form
  final loginFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    // Retrieve stored email and password if "Remember Me" is selected
    email.text = localStorage.read('REMEMBER_ME_EMAIL') ?? '';
    password.text = localStorage.read('REMEMBER_ME_PASSWORD') ?? '';
    super.onInit();
  }

  /// Handles email and password sign-in process
  Future<void> emailAndPasswordSignIn({required String deviceToken}) async {
    print(":::222");
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
          'Logging you in...', TImages.ridingIllustration);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Save Data if Remember Me is selected
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      }
      print(":::333");

      // Login user using Email & Password Authentication
      await AuthenticationRepository.instance.loginWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );
      print(":::device token login== $deviceToken");
      print(":::444");

      // User Information
      final user = await fetchUserInformation();
      print(":::555");
      // Settings Information
      await fetchSettingsInformation();
      print(":::666");
      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Admin -> admin panel. Any other (customer) account -> the main store site.
      if (user.role != AppRole.admin) {
        // Clear the admin-app session, then send them to the storefront
        // (works on both web and mobile).
        await AuthenticationRepository.instance.logout();
        await _redirectToStorefront();
      } else {
        // Redirect to the admin dashboard.
        AuthenticationRepository.instance.screenRedirect();
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Sends a non-admin (customer) account to the main storefront site.
  /// On web this replaces the current tab; on mobile it opens the store URL
  /// in the external browser.
  Future<void> _redirectToStorefront() async {
    final uri = Uri.parse(TTexts.mainSiteUrl);
    try {
      if (kIsWeb) {
        await launchUrl(uri, webOnlyWindowName: '_self');
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      TLoaders.warningSnackBar(
          title: 'Customer Account',
          message: 'This is a customer account. Please shop at ${TTexts.mainSiteUrl}');
    }
  }

  /// Handles registration of admin user
  Future<void> registerAdmin({required String deviceToken}) async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
          'Registering Admin Account...', TImages.ridingIllustration);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Register account on the backend (creates the user record + JWT session).
      // Note: the seeded admin (npm run seed) is the canonical admin; this dev
      // helper just registers an account and signs in.
      await AuthenticationRepository.instance.registerWithEmailAndPassword(
          TTexts.adminEmail, TTexts.adminPassword);

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<UserModel> fetchUserInformation() async {
    // Fetch user details and assign to UserController
    final controller = UserController.instance;
    UserModel user;
    if (controller.user.value.id == null || controller.user.value.id!.isEmpty) {
      user = await UserController.instance.fetchUserDetails();
      print('----------------------------- INSTANCE NOT CREATED');
    } else {
      user = controller.user.value;
      print('----------------------------- INSTANCE ALREADY CREATED');
    }

    return user;
  }

  fetchSettingsInformation() async {
    final controller = SettingsController.instance;
    if (controller.settings.value.id == null ||
        controller.settings.value.id!.isEmpty) {
      await SettingsController.instance.fetchSettingDetails();
      print('----------------------------- SETTING INSTANCE NOT CREATED');
    }
  }
}
