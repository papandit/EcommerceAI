import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/models/address_model.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/order_model.dart';

import '../../../../utils/formatters/formatter.dart';
import '../../../utils/constants/enums.dart';

/// Model class representing user data.
class UserModel {
  final String? id;
  String firstName;
  String lastName;
  String userName;
  String email;
  String phoneNumber;
  String profilePicture;
  AppRole role;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<OrderModel>? orders;
  List<AddressModel>? addresses;
  String? devicetoken;

  /// Constructor for UserModel.
  UserModel(
      {this.id,
      required this.email,
      this.firstName = '',
      this.lastName = '',
      this.userName = '',
      this.phoneNumber = '',
      this.profilePicture = '',
      this.role = AppRole.user,
      this.createdAt,
      this.updatedAt,
      this.devicetoken});

  /// Helper methods
  String get fullName => '$firstName $lastName';

  String get formattedPhoneNo => TFormatter.formatPhoneNumber(phoneNumber);

  String get formattedDate => TFormatter.formatDate(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);

  /// Static function to create an empty user model.
  static UserModel empty() =>
      UserModel(email: ''); // Default createdAt to current time

  /// Convert model to JSON structure for storing data in Firebase.
  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'UserName': userName,
      'Devicetoken': devicetoken,
      'Email': email,
      'PhoneNumber': phoneNumber,
      'ProfilePicture': profilePicture,
      'Role': role.name.toString(),
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt = DateTime.now(),
    };
  }

  /// Create a UserModel from a REST API JSON map (Node/MongoDB backend).
  /// Mirrors [fromSnapshot] but reads `id` from the body and parses ISO dates.
  factory UserModel.fromJson(Map<String, dynamic> data) {
    DateTime? _date(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return UserModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      firstName: data['FirstName'] ?? '',
      lastName: data['LastName'] ?? '',
      devicetoken: data['Devicetoken'] ?? '',
      userName: data['UserName'] ?? '',
      email: data['Email'] ?? '',
      phoneNumber: data['PhoneNumber'] ?? '',
      profilePicture: data['ProfilePicture'] ?? '',
      role: ((data['Role'] ?? '').toString() == AppRole.admin.name)
          ? AppRole.admin
          : AppRole.user,
      createdAt: _date(data['CreatedAt'] ?? data['createdAt']) ?? DateTime.now(),
      updatedAt: _date(data['UpdatedAt'] ?? data['updatedAt']) ?? DateTime.now(),
    );
  }

  /// Factory method to create a UserModel from a Firebase document snapshot.
  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserModel(
        id: document.id,
        firstName: data.containsKey('FirstName') ? data['FirstName'] ?? '' : '',
        lastName: data.containsKey('LastName') ? data['LastName'] ?? '' : '',
        devicetoken:
            data.containsKey('Devicetoken') ? data['Devicetoken'] ?? '' : '',
        userName: data.containsKey('UserName') ? data['UserName'] ?? '' : '',
        email: data.containsKey('Email') ? data['Email'] ?? '' : '',
        phoneNumber:
            data.containsKey('PhoneNumber') ? data['PhoneNumber'] ?? '' : '',
        profilePicture: data.containsKey('ProfilePicture')
            ? data['ProfilePicture'] ?? ''
            : '',
        role: data.containsKey('Role')
            ? (data['Role'] ?? AppRole.user) == AppRole.admin.name.toString()
                ? AppRole.admin
                : AppRole.user
            : AppRole.user,
        createdAt: data.containsKey('CreatedAt')
            ? data['CreatedAt']?.toDate() ?? DateTime.now()
            : DateTime.now(),
        updatedAt: data.containsKey('UpdatedAt')
            ? data['UpdatedAt']?.toDate() ?? DateTime.now()
            : DateTime.now(),
      );
    } else {
      return empty();
    }
  }
}
