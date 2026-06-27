/// Non-web fallback. The native app uses the `razorpay_flutter` plugin
/// elsewhere; this facade is only meaningful on web, so off-web it reports
/// "unsupported" so the caller can fall back gracefully.
class RazorpayCheckout {
  static bool get isSupported => false;

  static void open({
    required String key,
    required int amountPaise,
    required String name,
    String orderId = '',
    String description = '',
    String email = '',
    String contact = '',
    required void Function(Map<String, String> result) onSuccess,
    void Function(String reason)? onFailure,
  }) {
    if (onFailure != null) {
      onFailure('Online payment checkout is only available on the web build.');
    }
  }
}
