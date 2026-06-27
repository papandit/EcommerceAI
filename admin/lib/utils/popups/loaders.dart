import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../constants/colors.dart';
import '../helpers/helper_functions.dart';

class TLoaders {
  /// Emit a snackbar without ever throwing. `Get.snackbar` needs a live Overlay,
  /// which can be momentarily unavailable right after an async API call
  /// completes ("No Overlay widget found") — that uncaught error used to abort
  /// create/save flows. We defer to the next frame, try Get.snackbar, and fall
  /// back to ScaffoldMessenger; any remaining failure is swallowed.
  static void _emit({
    required String title,
    required String message,
    required Color bg,
    required IconData icon,
    int duration = 3,
  }) {
    // Use ScaffoldMessenger (synchronous + try/catch-able) instead of
    // Get.snackbar, whose overlay work runs in an async queue and throws an
    // UNCAUGHT "No Overlay widget found" right after API calls — which aborted
    // create/save flows even though the data was already saved.
    void show() {
      final ctx = Get.context;
      if (ctx == null) return;
      final messenger = ScaffoldMessenger.maybeOf(ctx);
      if (messenger == null) return;
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: duration),
          content: Row(children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message.isNotEmpty ? '$title — $message' : title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ]),
        ),
      );
    }

    try {
      show();
    } catch (_) {
      try {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            show();
          } catch (_) {/* give up silently */}
        });
      } catch (_) {}
    }
  }

  static hideSnackBar() {
    try {
      ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
    } catch (_) {}
  }

  static customToast({required message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        width: 500,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: THelperFunctions.isDarkMode(Get.context!)
                ? TColors.darkerGrey.withValues(alpha: 0.9)
                : TColors.grey.withValues(alpha: 0.9),
          ),
          child: Center(
              child: Text(message,
                  style: Theme.of(Get.context!).textTheme.labelLarge)),
        ),
      ),
    );
  }

  static successSnackBar({required title, message = '', duration = 3}) {
    _emit(
      title: title.toString(),
      message: message.toString(),
      bg: TColors.primary,
      icon: Iconsax.check,
      duration: duration is int ? duration : 3,
    );
  }

  static warningSnackBar({required title, message = ''}) {
    _emit(
      title: title.toString(),
      message: message.toString(),
      bg: Colors.orange,
      icon: Iconsax.warning_2,
    );
  }

  static errorSnackBar({required title, message = ''}) {
    _emit(
      title: title.toString(),
      message: message.toString(),
      bg: Colors.red.shade600,
      icon: Iconsax.warning_2,
    );
  }
}
