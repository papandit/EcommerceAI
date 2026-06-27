class UserModel {
  final String? id;
  String firstName;
  String lastName;
  String userName;
  String email;
  String phoneNumber;
  String profilePicture;
  String role;
  String devicetoken;
  String cartid;
  String wishlistid;
  String Addresslistid;
  bool Verifyotp;
  DateTime? createdAt;
  DateTime? updatedAt;
  // List<OrderModel>? orders;
  // List<AddressModel>? addresses;

  /// Constructor for UserModel.
  UserModel({
    this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.Verifyotp = false,
    this.userName = '',
    this.phoneNumber = '',
    this.profilePicture = '',
    this.role = '',
    this.devicetoken = '',
    this.createdAt,
    this.updatedAt,
    this.cartid = '',
    this.wishlistid = '',
    this.Addresslistid = '',
  });

  /// Helper methods
  // String get fullName => '$firstName $lastName';

  // String get formattedPhoneNo => TFormatter.formatPhoneNumber(phoneNumber);

  // String get formattedDate => TFormatter.formatDate(createdAt);

  // String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);

  /// Static function to create an empty user model.
  static UserModel empty() =>
      UserModel(email: ''); // Default createdAt to current time

  /// Convert model to JSON structure for storing data in Firebase.
  Map<String, dynamic> toJson() {
    return {
      "Uid": id,
      'FirstName': firstName,
      'LastName': lastName,
      'UserName': userName,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'ProfilePicture': profilePicture,
      'Role': role,
      'Devicetoken': devicetoken,
      'Verifyotp': Verifyotp,
      'CreatedAt': createdAt,
      'Cartid': cartid,
      'Wishlistid': wishlistid,
      'Addresslistid': Addresslistid,
      'UpdatedAt': updatedAt = DateTime.now(),
    };
  }

  /// Build from a REST API JSON map (Node/MongoDB backend).
  factory UserModel.fromJson(Map<String, dynamic> data) {
    DateTime? d(dynamic v) => (v is String) ? DateTime.tryParse(v) : null;
    return UserModel(
      id: (data['id'] ?? data['_id'] ?? data['Uid'] ?? '').toString(),
      email: data['Email'] ?? '',
      firstName: data['FirstName'] ?? '',
      lastName: data['LastName'] ?? '',
      userName: data['UserName'] ?? '',
      phoneNumber: data['PhoneNumber'] ?? '',
      profilePicture: data['ProfilePicture'] ?? '',
      role: (data['Role'] ?? '').toString(),
      devicetoken: (data['Devicetoken'] ?? '').toString(),
      Verifyotp: data['Verifyotp'] ?? false,
      cartid: data['Cartid'] ?? '',
      wishlistid: data['Wishlistid'] ?? '',
      Addresslistid: data['Addresslistid'] ?? '',
      createdAt: d(data['CreatedAt'] ?? data['createdAt']),
      updatedAt: d(data['UpdatedAt'] ?? data['updatedAt']),
    );
  }
}
