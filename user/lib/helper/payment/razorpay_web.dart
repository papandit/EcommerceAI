// Web implementation of Razorpay Checkout using checkout.js (loaded in
// web/index.html) via JS interop.
import 'dart:js' as js;
import 'dart:js_util' as jsu;

class RazorpayCheckout {
  static bool get isSupported => jsu.hasProperty(js.context, 'Razorpay');

  /// Opens Razorpay Checkout. When [orderId] (a Razorpay order id created
  /// server-side) is supplied, the success callback receives the full set of
  /// fields needed for signature verification.
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
    if (!isSupported) {
      if (onFailure != null) onFailure('Razorpay checkout failed to load.');
      return;
    }

    final options = jsu.newObject();
    jsu.setProperty(options, 'key', key);
    jsu.setProperty(options, 'amount', amountPaise); // in paise
    jsu.setProperty(options, 'currency', 'INR');
    jsu.setProperty(options, 'name', name);
    jsu.setProperty(options, 'description', description);
    if (orderId.isNotEmpty) jsu.setProperty(options, 'order_id', orderId);

    final prefill = jsu.newObject();
    jsu.setProperty(prefill, 'email', email);
    jsu.setProperty(prefill, 'contact', contact);
    jsu.setProperty(options, 'prefill', prefill);

    final theme = jsu.newObject();
    jsu.setProperty(theme, 'color', '#C04A66');
    jsu.setProperty(options, 'theme', theme);

    jsu.setProperty(
      options,
      'handler',
      js.allowInterop((response) {
        String read(String k) =>
            jsu.getProperty(response, k)?.toString() ?? '';
        onSuccess({
          'razorpay_payment_id': read('razorpay_payment_id'),
          'razorpay_order_id': read('razorpay_order_id'),
          'razorpay_signature': read('razorpay_signature'),
        });
      }),
    );

    final modal = jsu.newObject();
    jsu.setProperty(
      modal,
      'ondismiss',
      js.allowInterop(() {
        if (onFailure != null) onFailure('cancelled');
      }),
    );
    jsu.setProperty(options, 'modal', modal);

    final ctor = jsu.getProperty(js.context, 'Razorpay');
    final rzp = jsu.callConstructor(ctor, [options]);
    jsu.callMethod(rzp, 'open', []);
  }
}
