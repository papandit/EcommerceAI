import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwt_ecommerce_admin_panel/utils/formatters/formatter.dart';

class CoupanModel {
  String id;
  String name;
  String percentage;
  bool isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  CoupanModel({
    required this.id,
    required this.name,
    required this.percentage,

    // required this.active,
    this.isActive = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Static function to create an empty user model.
  static CoupanModel empty() => CoupanModel(
      id: '',
      name: '',
      percentage: '',
      // active: '',
      isActive: false);
  String get formattedDate => TFormatter.formatDate(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);
  toJson() {
    return {
      'name': name,
      'percentage': percentage,
      'isActive': isActive,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt = DateTime.now(),
    };
  }

  factory CoupanModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      // Map JSON Record to the Model
      return CoupanModel(
        id: document.id,
        name: data['name'] ?? '',

        isActive: data['isActive'] ?? false,
        //  name: data.containsKey('name') ? data['name'] as String : '',
        percentage:
            data.containsKey('percentage') ? data['percentage'] as String : '',
        // active: data.containsKey('active') ? data['active'] as String : '',
        createdAt:
            data.containsKey('CreatedAt') ? data['CreatedAt']?.toDate() : null,
        updatedAt:
            data.containsKey('UpdatedAt') ? data['UpdatedAt']?.toDate() : null,
      );
    } else {
      return CoupanModel.empty();
    }
  }

  /// Build from a REST API JSON map (Node/MongoDB backend), keeping the id.
  factory CoupanModel.fromJson(Map<String, dynamic> data) {
    DateTime? _date(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return CoupanModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      name: data['name'] ?? '',
      isActive: data['isActive'] ?? false,
      percentage: (data['percentage'] ?? '').toString(),
      createdAt: _date(data['CreatedAt'] ?? data['createdAt']),
      updatedAt: _date(data['UpdatedAt'] ?? data['updatedAt']),
    );
  }

  factory CoupanModel.fromMap(Map<String, dynamic> data) {
    print("Mapping CoupanModel from data: $data");
    print("Mapping CoupanModel from data: ${data['Startdate'].runtimeType}");

    return CoupanModel(
      id: "",
      name: data['name'] ?? '',
      isActive: data['isActive'] ?? false,
      //  name: data.containsKey('name') ? data['name'] as String : '',
      percentage:
          data.containsKey('percentage') ? data['percentage'] as String : '',
      // active: data.containsKey('active') ? data['active'] as String : '',
      createdAt: data.containsKey('CreatedAt')
          ? data['CreatedAt'].runtimeType == String
              ? DateTime.parse(data['CreatedAt'])
              : data['CreatedAt']?.toDate()
          : null,
      updatedAt: data.containsKey('UpdatedAt')
          ? data['UpdatedAt'].runtimeType == String
              ? DateTime.parse(data['UpdatedAt'])
              : data['UpdatedAt']?.toDate()
          : null,
    );
  }
}

class Review {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Review({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.message,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method to create a Review object from a Firestore document
  factory Review.fromMap(Map<String, dynamic> data, String documentId) {
    return Review(
      id: documentId,
      userId: data['userid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phonenumber'] ?? '',
      message: data['message'] ?? '',
      createdAt: data['CreatedAt'] != null
          ? (data['CreatedAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['UpdatedAt'] != null
          ? (data['UpdatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Method to convert Review object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userid': userId,
      'name': name,
      'email': email,
      'phonenumber': phoneNumber,
      'message': message,
      'CreatedAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'UpdatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
