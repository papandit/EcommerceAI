/// One row of the try-on credit ledger (backend: creditLedger.model.js).
class CreditLedgerModel {
  final String id;
  final String type; // signup_grant | admin_grant | admin_set | admin_deduct | tryon_consume | ...
  final int amount; // signed: + added, - consumed
  final int? balanceAfter;
  final String feature;
  final String reason;
  final DateTime? createdAt;

  CreditLedgerModel({
    this.id = '',
    this.type = '',
    this.amount = 0,
    this.balanceAfter,
    this.feature = '',
    this.reason = '',
    this.createdAt,
  });

  factory CreditLedgerModel.fromJson(Map<String, dynamic> data) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return CreditLedgerModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      type: (data['type'] ?? '').toString(),
      amount: (num.tryParse((data['amount'] ?? 0).toString()) ?? 0).toInt(),
      balanceAfter: data['balanceAfter'] == null
          ? null
          : (num.tryParse(data['balanceAfter'].toString()) ?? 0).toInt(),
      feature: (data['feature'] ?? '').toString(),
      reason: (data['reason'] ?? '').toString(),
      createdAt: parseDate(data['CreatedAt'] ?? data['createdAt']),
    );
  }

  /// Human-friendly label for the ledger row's type.
  String get label {
    switch (type) {
      case 'signup_grant':
        return 'Signup bonus';
      case 'admin_grant':
        return 'Admin added';
      case 'admin_set':
        return 'Admin set balance';
      case 'admin_deduct':
        return 'Admin removed';
      case 'tryon_consume':
        return 'Try-on';
      case 'tryon_refund':
        return 'Try-on refund';
      case 'pool_purchase':
        return 'Pool purchase';
      case 'pool_consume':
        return 'Admin generation';
      default:
        return type;
    }
  }
}
