import 'package:get/get.dart';

import '../../../data/repositories/credits/credit_ledger_model.dart';
import '../../../data/repositories/credits/credit_repository.dart';
import '../../../data/repositories/credits/credit_request_model.dart';
import '../../../data/repositories/credits/credit_user_model.dart';
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
  // Distribution aggregates
  final RxInt totalUsers = 0.obs;
  final RxInt allocated = 0.obs;
  final RxInt grantedTotal = 0.obs;
  final RxInt usedTotal = 0.obs;
  final RxDouble avgPerUser = 0.0.obs;
  final RxDouble estAllocatedCost = 0.0.obs;
  final RxBool savingPool = false.obs;

  // ---- Per-user (customer detail) ----
  final RxBool ledgerLoading = false.obs;
  final RxList<CreditLedgerModel> ledger = <CreditLedgerModel>[].obs;
  final RxInt userBalance = 0.obs;
  final RxBool adjusting = false.obs;

  // ---- Distribution table (all users) ----
  final RxBool usersLoading = false.obs;
  final RxList<CreditUserModel> users = <CreditUserModel>[].obs;
  final RxString userSearch = ''.obs;

  // ---- Shopper credit requests (admin inbox) ----
  final RxBool requestsLoading = false.obs;
  final RxList<CreditRequestModel> requests = <CreditRequestModel>[].obs;
  final RxInt pendingCount = 0.obs;
  final RxString requestFilter = 'all'.obs;

  // ---- Try-on model curation ----
  final RxBool modelsLoading = false.obs;
  final RxList<Map<String, dynamic>> brandshootModels = <Map<String, dynamic>>[].obs;
  final RxSet<String> enabledModelIds = <String>{}.obs;
  final RxBool savingModels = false.obs;

  @override
  void onInit() {
    fetchSummary();
    super.onInit();
  }

  /// Load everything the Credits screen needs.
  Future<void> loadAll() async {
    await Future.wait([
      fetchSummary(),
      fetchUsers(),
      fetchRequests(),
      fetchModels(),
    ]);
  }

  /// Save the pool total / price per credit, then refresh the dashboard.
  Future<void> savePool({
    int? purchasedCredits,
    double? costPerCredit,
    String? currency,
  }) async {
    try {
      savingPool.value = true;
      await _repo.setPool(
        purchasedCredits: purchasedCredits,
        costPerCredit: costPerCredit,
        currency: currency,
      );
      await fetchSummary();
      TLoaders.successSnackBar(
          title: 'Pool updated', message: 'Credit pool and pricing saved.');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      savingPool.value = false;
    }
  }

  // ---- Users -------------------------------------------------------------

  Future<void> fetchUsers() async {
    try {
      usersLoading.value = true;
      users.value = await _repo.getUsers(search: userSearch.value);
    } catch (e) {
      users.clear();
    } finally {
      usersLoading.value = false;
    }
  }

  /// Add / set / deduct a user's credits straight from the distribution table.
  Future<void> adjustUser(String userId,
      {required String op, required int amount, String reason = ''}) async {
    try {
      adjusting.value = true;
      final newBalance = await _repo.adjustUserCredits(userId,
          op: op, amount: amount, reason: reason);
      final i = users.indexWhere((u) => u.id == userId);
      if (i != -1) {
        users[i].tryonCredits = newBalance;
        users.refresh();
      }
      await fetchSummary();
      TLoaders.successSnackBar(
          title: 'Credits updated', message: 'Balance is now $newBalance.');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      adjusting.value = false;
    }
  }

  /// Bulk-distribute credits to everyone (or only to users who never got any).
  Future<void> grantAll(int amount, {bool onlyUngranted = false}) async {
    try {
      adjusting.value = true;
      final n = await _repo.grantAll(amount: amount, onlyUngranted: onlyUngranted);
      await fetchUsers();
      await fetchSummary();
      TLoaders.successSnackBar(
          title: 'Credits distributed',
          message: 'Gave $amount credit(s) to $n user(s).');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      adjusting.value = false;
    }
  }

  // ---- Requests ----------------------------------------------------------

  Future<void> fetchRequests() async {
    try {
      requestsLoading.value = true;
      final r = await _repo.getRequests(status: requestFilter.value);
      requests.value = r.items;
      pendingCount.value = r.pendingCount;
    } catch (e) {
      requests.clear();
    } finally {
      requestsLoading.value = false;
    }
  }

  Future<void> handleRequest(String id,
      {required String action, int? amount, String note = ''}) async {
    try {
      await _repo.handleRequest(id, action: action, amount: amount, note: note);
      await fetchRequests();
      await fetchUsers();
      await fetchSummary();
      TLoaders.successSnackBar(
        title: action == 'approve' ? 'Approved' : 'Rejected',
        message: action == 'approve'
            ? 'Credits granted to the shopper.'
            : 'The request was rejected.',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> deleteRequest(String id) async {
    try {
      await _repo.deleteRequest(id);
      await fetchRequests();
      TLoaders.successSnackBar(title: 'Deleted', message: 'Request removed.');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  // ---- Model curation ----------------------------------------------------

  Future<void> fetchModels() async {
    try {
      modelsLoading.value = true;
      final results = await Future.wait([
        _repo.getBrandshootModels(),
        _repo.getEnabledModelIds(),
      ]);
      brandshootModels.value = results[0] as List<Map<String, dynamic>>;
      enabledModelIds.assignAll(results[1] as List<String>);
    } catch (e) {
      brandshootModels.clear();
    } finally {
      modelsLoading.value = false;
    }
  }

  void toggleModel(String id) {
    if (enabledModelIds.contains(id)) {
      enabledModelIds.remove(id);
    } else {
      enabledModelIds.add(id);
    }
  }

  Future<void> saveModels() async {
    try {
      savingModels.value = true;
      await _repo.saveEnabledModelIds(enabledModelIds.toList());
      TLoaders.successSnackBar(
        title: 'Saved',
        message: enabledModelIds.isEmpty
            ? 'No models selected — shoppers see the default women models.'
            : '${enabledModelIds.length} model(s) published to try-on.',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      savingModels.value = false;
    }
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
      totalUsers.value = _int(d['totalUsers']);
      allocated.value = _int(d['allocated']);
      grantedTotal.value = _int(d['grantedTotal']);
      usedTotal.value = _int(d['usedTotal']);
      avgPerUser.value = _double(d['avgPerUser']);
      estAllocatedCost.value = _double(d['estAllocatedCost']);
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
