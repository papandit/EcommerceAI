/// A shopper's request to the admin for more try-on credits.
class CreditRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final int amount;
  final String message;
  final String status; // pending | approved | rejected
  final int grantedAmount;
  final String adminNote;
  final DateTime? createdAt;

  CreditRequestModel({
    required this.id,
    this.userId = '',
    this.userName = '',
    this.userEmail = '',
    this.amount = 0,
    this.message = '',
    this.status = 'pending',
    this.grantedAmount = 0,
    this.adminNote = '',
    this.createdAt,
  });

  bool get isPending => status == 'pending';

  static int _int(dynamic v) => (num.tryParse((v ?? 0).toString()) ?? 0).toInt();

  factory CreditRequestModel.fromJson(Map<String, dynamic> d) =>
      CreditRequestModel(
        id: (d['id'] ?? d['_id'] ?? '').toString(),
        userId: (d['userId'] ?? '').toString(),
        userName: (d['userName'] ?? '').toString(),
        userEmail: (d['userEmail'] ?? '').toString(),
        amount: _int(d['amount']),
        message: (d['message'] ?? '').toString(),
        status: (d['status'] ?? 'pending').toString(),
        grantedAmount: _int(d['grantedAmount']),
        adminNote: (d['adminNote'] ?? '').toString(),
        createdAt: DateTime.tryParse(
            (d['createdAt'] ?? d['CreatedAt'] ?? '').toString()),
      );
}
