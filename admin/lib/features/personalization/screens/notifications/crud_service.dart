/// FCM token persistence is disabled — application data lives in MongoDB now
/// and device tokens are no longer stored. Kept as a no-op so existing callers
/// (push_notification.dart) keep compiling.
class CRUDService {
  // save fcm token (no-op — Firestore removed)
  static Future<void> saveUserToken(String token) async {
    // Intentionally empty.
  }
}
