import 'package:get/get.dart';
import '../../../routes/routes.dart';
import '../../services/api/api_client.dart';

/// Authentication against the custom Node/MongoDB backend (JWT).
/// Firebase Auth is no longer used by the admin panel; Google Sign-In (the only
/// remaining Firebase feature) lives in the storefront.
class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _api = ApiClient.instance;

  /// True when a JWT is present in local storage.
  bool get isAuthenticated => _api.hasToken;

  /// The logged-in user's id (Mongo _id), from the cached session.
  String get currentUserId {
    final u = _api.cachedUser;
    return (u?['id'] ?? u?['_id'] ?? '').toString();
  }

  /// Cached user map (capitalized Firestore-style keys).
  Map<String, dynamic>? get currentUser => _api.cachedUser;

  @override
  void onReady() {
    // No-op: redirection is driven by the presence of a JWT.
  }

  /// Route to dashboard if authenticated, else to login.
  void screenRedirect() {
    if (isAuthenticated) {
      Get.offAllNamed(TRoutes.dashboard);
    } else {
      Get.offAllNamed(TRoutes.login);
    }
  }

  // LOGIN — returns the user map; throws a readable message on failure.
  Future<Map<String, dynamic>> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final data = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      });
      await _api.saveSession(data);
      return Map<String, dynamic>.from(data['user'] ?? {});
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // REGISTER — creates an account and stores the session.
  Future<Map<String, dynamic>> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final data = await _api.post('/auth/register', {
        'email': email,
        'password': password,
      });
      await _api.saveSession(data);
      return Map<String, dynamic>.from(data['user'] ?? {});
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // REGISTER USER BY ADMIN — does NOT replace the admin's own session.
  Future<Map<String, dynamic>> registerUserByAdmin(
      String email, String password,
      {String role = 'user'}) async {
    try {
      final data = await _api.post('/auth/register', {
        'email': email,
        'password': password,
        'role': role,
      });
      return Map<String, dynamic>.from(data['user'] ?? {});
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // -- Password reset (OTP via email) --

  /// Request a reset code. Returns the response data; in dev (no SMTP) it may
  /// include `devOtp` so the flow is testable.
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final data = await _api.post('/auth/forgot-password', {'email': email});
      return Map<String, dynamic>.from(data);
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Reset the password using the emailed code.
  Future<void> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      await _api.post('/auth/reset-password', {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Kept for existing callers — now backed by the real OTP flow.
  Future<void> sendPasswordResetEmail(String email) async {
    await forgotPassword(email);
  }

  // The backend has no email-verification / re-auth flow yet — no-ops so
  // existing callers compile.
  Future<void> sendEmailVerification() async {}
  Future<void> reAuthenticateWithEmailAndPassword(
      String email, String password) async {}
  Future<void> deleteAccount() async {}

  // Logout — clear the JWT session and return to login.
  Future<void> logout() async {
    await _api.clearSession();
    Get.offAllNamed(TRoutes.login);
  }
}
