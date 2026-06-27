import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../routes/routes.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';

/// Controller for the forgot/reset password flow (OTP via email).
class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  final email = TextEditingController();
  final otp = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  final forgetPasswordFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  /// Step 1 — request a reset code, then go to the reset screen.
  sendPasswordResetEmail() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Processing your request...', TImages.ridingIllustration);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      if (!forgetPasswordFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final res = await AuthenticationRepository.instance
          .forgotPassword(email.text.trim());

      TFullScreenLoader.stopLoading();

      final devOtp = (res['devOtp'] ?? '').toString();
      TLoaders.successSnackBar(
        title: 'Code sent',
        message: devOtp.isNotEmpty
            ? 'Email not configured — your code is $devOtp'
            : 'A reset code was sent to your email.',
      );
      Get.toNamed(TRoutes.resetPassword, arguments: email.text.trim());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Step 2 — apply the new password using the emailed code.
  resetPassword() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Resetting your password...', TImages.ridingIllustration);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      if (!resetPasswordFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      if (newPassword.text.trim() != confirmPassword.text.trim()) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
            title: 'Mismatch', message: 'Passwords do not match.');
        return;
      }

      await AuthenticationRepository.instance.resetPassword(
        email.text.trim(),
        otp.text.trim(),
        newPassword.text.trim(),
      );

      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
          title: 'Done', message: 'Password reset. Please sign in.');
      Get.offAllNamed(TRoutes.login);
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Resend the reset code.
  resendPasswordResetEmail(String emailAddr) async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Processing your request...', TImages.ridingIllustration);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final res = await AuthenticationRepository.instance
          .forgotPassword(emailAddr.trim());

      TFullScreenLoader.stopLoading();
      final devOtp = (res['devOtp'] ?? '').toString();
      TLoaders.successSnackBar(
        title: 'Code sent',
        message: devOtp.isNotEmpty
            ? 'Email not configured — your code is $devOtp'
            : 'A new code was sent to your email.',
      );
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
