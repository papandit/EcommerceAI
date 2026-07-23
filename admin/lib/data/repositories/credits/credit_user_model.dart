/// A user row in the admin "distribute credits" table.
class CreditUserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String profilePicture;
  final String role;
  int tryonCredits;
  final int grantedTotal;
  final int consumedTotal;

  CreditUserModel({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.profilePicture = '',
    this.role = 'user',
    this.tryonCredits = 0,
    this.grantedTotal = 0,
    this.consumedTotal = 0,
  });

  String get fullName {
    final n = '$firstName $lastName'.trim();
    return n.isEmpty ? email : n;
  }

  static int _int(dynamic v) => (num.tryParse((v ?? 0).toString()) ?? 0).toInt();

  factory CreditUserModel.fromJson(Map<String, dynamic> d) => CreditUserModel(
        id: (d['id'] ?? d['_id'] ?? '').toString(),
        firstName: (d['FirstName'] ?? '').toString(),
        lastName: (d['LastName'] ?? '').toString(),
        email: (d['Email'] ?? '').toString(),
        profilePicture: (d['ProfilePicture'] ?? '').toString(),
        role: (d['Role'] ?? 'user').toString(),
        tryonCredits: _int(d['tryonCredits']),
        grantedTotal: _int(d['creditsGrantedTotal']),
        consumedTotal: _int(d['creditsConsumedTotal']),
      );
}
