import 'package:get/get.dart';

import '../../../data/repositories/credits/credit_ledger_model.dart';
import '../../../data/repositories/credits/credit_repository.dart';
import '../../../utils/popups/loaders.dart';

/// Manages the try-on credit costing dashboard (pool-level) and per-user credit
/// history/adjustments shown on the customer detail screen.
class CreditController extends GetxController {
  static CreditController get instance => Get.find();

  final CreditRepository _repo = Get.put(CreditRepository());

  // ---- Costing summary (pool) ----
  final RxBool summaryLoading = false.obs;
  final RxInt purchased = 0.obs;
  final RxInt consumed = 0.obs;
  final RxInt remaining = 0.obs;
  final RxDouble costPerCredit = 0.0.obs;
  final RxString currency = 'INR'.obs;
  final RxDouble estConsumedCost = 0.0.obs;
  final RxDouble estRemainingValue = 0.0.obs;

  // ---- Per-user (customer detail) ----
  final RxBool ledgerLoading = false.obs;
  final RxList<CreditLedgerModel> ledger = <CreditLedgerModel>[].obs;
  final RxInt userBalance = 0.obs;
  final RxBool adjusting = false.obs;

  @override
  void onInit() {
    fetchSummary();
    super.onInit();
  }

  int _int(dynamic v) => (num.tryParse((v ?? 0).toString()) ?? 0).toInt();
  double _double(dynamic v) => (num.tryParse((v ?? 0).toString()) ?? 0).toDouble();

  Future<void> fetchSummary() async {
    try {
      summaryLoading.value = true;
      final d = await _repo.getCostingSummary();
      purchased.value = _int(d['purchased']);
      consumed.value = _int(d['consumed']);
      remaining.value = _int(d['remaining']);
      costPerCredit.value = _double(d['costPerCredit']);
      currency.value = (d['currency'] ?? 'INR').toString();
      estConsumedCost.value = _double(d['estConsumedCost']);
      estRemainingValue.value = _double(d['estRemainingValue']);
    } catch (_) {
      // non-fatal — dashboard just shows last-known / zeros
    } finally {
      summaryLoading.value = false;
    }
  }

  Future<void> loadUserLedger(String userId, {int? currentBalance}) async {
    try {
      ledgerLoading.value = true;
      if (currentBalance != null) userBalance.value = currentBalance;
      ledger.value = await _repo.getUserLedger(userId);
    } catch (_) {
      ledger.clear();
    } finally {
      ledgerLoading.value = false;
    }
  }

  /// Adjust a user's balance then refresh the ledger + costing summary.
  Future<void> adjust(
    String userId, {
    required String op,
    required int amount,
    String reason = '',
  }) async {
    try {
      adjusting.value = true;
      final newBalance =
          await _repo.adjustUserCredits(userId, op: op, amount: amount, reason: reason);
      userBalance.value = newBalance;
      await loadUserLedger(userId);
      await fetchSummary();
      TLoaders.successSnackBar(
          title: 'Credits updated', message: 'Balance is now $newBalance.');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      adjusting.value = false;
    }
  }
}
