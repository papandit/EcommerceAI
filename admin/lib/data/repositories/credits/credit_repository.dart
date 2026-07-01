import 'package:get/get.dart';

import '../../services/api/api_client.dart';
import 'credit_ledger_model.dart';

/// Repository for try-on credit management (admin only). Talks to the
/// `/admin/credits/*` backend endpoints.
class CreditRepository extends GetxController {
  static CreditRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  /// Costing summary: purchased / consumed / remaining + estimated cost.
  Future<Map<String, dynamic>> getCostingSummary() async {
    return _api.getOne('/admin/credits/summary');
  }

  /// A single user's credit history (newest first).
  Future<List<CreditLedgerModel>> getUserLedger(String userId) async {
    final rows = await _api.getList('/admin/credits/users/$userId/ledger');
    return rows.map((e) => CreditLedgerModel.fromJson(e)).toList();
  }

  /// Adjust a user's balance. [op] = 'set' | 'add' | 'deduct'.
  /// Returns the user's new balance.
  Future<int> adjustUserCredits(
    String userId, {
    required String op,
    required int amount,
    String reason = '',
  }) async {
    final data = await _api.post('/admin/credits/users/$userId/adjust', {
      'op': op,
      'amount': amount,
      'reason': reason,
    });
    return (num.tryParse((data['tryonCredits'] ?? 0).toString()) ?? 0).toInt();
  }

  /// Record a purchase of pool credits (bumps Settings.purchasedCredits).
  Future<int> purchaseCredits({required int amount, String reason = ''}) async {
    final data = await _api.post('/admin/credits/purchase', {
      'amount': amount,
      'reason': reason,
    });
    return (num.tryParse((data['purchasedCredits'] ?? 0).toString()) ?? 0).toInt();
  }
}
