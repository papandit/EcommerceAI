// class ContectusModel {
//   String name;
//   String email;
//   String phone;
//   String message;

//   ContectusModel(
//       {required this.name,
//       required this.email,
//       required this.phone,
//       required this.message});

//   ContectusModel.fromJson(Map<String, dynamic> json)
//       : name = json['name'] ?? '',
//         email = json['email'] ?? '',
//         phone = json['phone'] ?? '',
//         message = json['message'] ?? '';

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['name'] = this.name;
//     if (this.collections != null) {
//       data['collections'] = this.collections!.toJson();
//     }
//     return data;
//   }

//   void displayInfo() {
//     print('Name: $name');
//     print('Email: $email');
//     print('Message: $phone');
//     print('Message: $message');
//   }
// }

import 'package:EcommerceApp/helper/formmerclass.dart';

class ReviewModel {
  String id;
  String userid;
  String name;
  String email;

  String message;
  String phonenumber;
  DateTime? createdAt;
  DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.userid,
    required this.name,
    required this.email,
    required this.message,
    required this.phonenumber,
    this.createdAt,
    this.updatedAt,
  });

  /// Static function to create an empty user model.
  static ReviewModel empty() => ReviewModel(
      id: '', name: '', message: '', phonenumber: '', email: '', userid: '');
  String get formattedDate => TFormatter.formatDate(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);
  toJson() {
    return {
      'id': id,
      'name': name,
      'userid': userid,
      'email': email,
      'message': message,
      'phonenumber': phonenumber,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt = DateTime.now(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> data) {

    return ReviewModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      userid: data['userid'] ?? '',
      email: data['email'] ?? '',
      phonenumber: data['phonenumber'] ?? '',
      message: data.containsKey('message') ? data['message'] as String : '',
      createdAt: data.containsKey('CreatedAt')
          ? (data['CreatedAt'] is String
              ? DateTime.tryParse(data['CreatedAt'])
              : (data['CreatedAt'] is DateTime ? data['CreatedAt'] : null))
          : null,
      updatedAt: data.containsKey('UpdatedAt')
          ? (data['UpdatedAt'] is String
              ? DateTime.tryParse(data['UpdatedAt'])
              : (data['UpdatedAt'] is DateTime ? data['UpdatedAt'] : null))
          : null,
    );
  }
}
