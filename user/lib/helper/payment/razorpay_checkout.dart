/// Cross-platform entry point for opening Razorpay Checkout.
///
/// On web it uses Razorpay's `checkout.js` (loaded in web/index.html) via JS
/// interop; off-web it is a safe no-op that reports "unsupported". The actual
/// implementation is selected at compile time by the conditional export below.
export 'razorpay_stub.dart' if (dart.library.html) 'razorpay_web.dart';
