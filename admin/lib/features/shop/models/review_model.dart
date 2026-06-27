import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwt_ecommerce_admin_panel/utils/formatters/formatter.dart';

class ReviewModel {
  String id;
  String name;
  String email;

  String message;
  String phonenumber;
  DateTime? createdAt;
  DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.phonenumber,
    this.createdAt,
    this.updatedAt,
  });

  /// Static function to create an empty user model.
  static ReviewModel empty() =>
      ReviewModel(id: '', name: '', message: '', phonenumber: '', email: '');
  String get formattedDate => TFormatter.formatDate(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);
  toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'message': message,
      'phonenumber': phonenumber,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt = DateTime.now(),
    };
  }

  factory ReviewModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      // Map JSON Record to the Model
      return ReviewModel(
        id: document.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phonenumber: data['phonenumber'] ?? "",
        //  name: data.containsKey('name') ? data['name'] as String : '',
        message: data.containsKey('message') ? data['message'] as String : '',
        // active: data.containsKey('active') ? data['active'] as String : '',
        createdAt:
            data.containsKey('CreatedAt') ? data['CreatedAt']?.toDate() : null,
        updatedAt:
            data.containsKey('UpdatedAt') ? data['UpdatedAt']?.toDate() : null,
      );
    } else {
      return ReviewModel.empty();
    }
  }
  factory ReviewModel.fromMap(Map<String, dynamic> data) {
    print("Mapping ReviewModel from data: $data");
    print("Mapping ReviewModel from data: ${data['phonenumber'].runtimeType}");

    return ReviewModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phonenumber: data['phonenumber'] ?? '',
      message: data.containsKey('message') ? data['message'] as String : '',
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
