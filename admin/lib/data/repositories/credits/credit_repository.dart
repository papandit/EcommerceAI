import 'package:get/get.dart';

import '../../services/api/api_client.dart';
import 'credit_ledger_model.dart';
import 'credit_request_model.dart';
import 'credit_user_model.dart';

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

  /// Every user with their credit balance (for the distribution table).
  Future<List<CreditUserModel>> getUsers({String search = ''}) async {
    final rows = await _api.getList('/admin/credits/users',
        query: search.isEmpty ? null : {'search': search});
    return rows.map((e) => CreditUserModel.fromJson(e)).toList();
  }

  /// Shopper credit requests. [status] = pending | approved | rejected | all.
  Future<({List<CreditRequestModel> items, int pendingCount})> getRequests({
    String status = 'all',
  }) async {
    final data =
        await _api.getOne('/admin/credits/requests', query: {'status': status});
    final list = (data['items'] as List?) ?? const [];
    return (
      items: list
          .map((e) => CreditRequestModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pendingCount:
          (num.tryParse((data['pendingCount'] ?? 0).toString()) ?? 0).toInt(),
    );
  }

  /// Approve (grants credits) or reject a request.
  Future<void> handleRequest(
    String id, {
    required String action, // 'approve' | 'reject'
    int? amount,
    String note = '',
  }) async {
    await _api.post('/admin/credits/requests/$id', {
      'action': action,
      if (amount != null) 'amount': amount,
      'note': note,
    });
  }

  Future<void> deleteRequest(String id) =>
      _api.delete('/admin/credits/requests/$id');

  /// Bulk-distribute credits. [onlyUngranted] tops up only users who never
  /// received any; otherwise every user gets [amount] added.
  Future<int> grantAll({
    required int amount,
    bool onlyUngranted = false,
    String reason = '',
  }) async {
    final data = await _api.post('/admin/credits/grant-all', {
      'amount': amount,
      'onlyUngranted': onlyUngranted,
      'reason': reason,
    });
    return (num.tryParse((data['granted'] ?? 0).toString()) ?? 0).toInt();
  }

  // ---- Try-on model curation -------------------------------------------
  // The admin picks which BrandShoot preset models shoppers can try on.

  /// All BrandShoot preset models (the full catalogue, unfiltered).
  Future<List<Map<String, dynamic>>> getBrandshootModels() =>
      _api.getList('/admin/ai/models', query: {'sub_type': 'photoshoot'});

  /// Model ids currently published to the shopper try-on picker.
  Future<List<String>> getEnabledModelIds() async {
    final s = await _api.getOne('/settings');
    final l = (s['tryonEnabledModelIds'] as List?) ?? const [];
    return l.map((e) => e.toString()).toList();
  }

  /// Publish the chosen models (empty list = fall back to the default filter).
  Future<void> saveEnabledModelIds(List<String> ids) async {
    await _api.put('/settings', {'tryonEnabledModelIds': ids});
  }
}
