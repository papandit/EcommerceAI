// import 'package:EcommerceApp/helper/formmerclass.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CoupanModel {
//   String id;
//   String name;
//   String percentage;
//   // final String active;
//   bool isActive;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   // OrderStatus status;

//   CoupanModel({
//     required this.id,
//     required this.name,
//     required this.percentage,
//     // required this.active,
//     this.isActive = false,
//     this.createdAt,
//     this.updatedAt,
//   });

//   /// Static function to create an empty user model.
//   static CoupanModel empty() => CoupanModel(
//       id: '',
//       name: '',
//       percentage: '',
//       // active: '',
//       isActive: false);
//   String get formattedDate => TFormatter.formatDate(createdAt);

//   String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);
//   toJson() {
//     return {
//       'name': name,
//       'percentage': percentage,
//       // 'active': active,
//       'isActive': isActive,
//       'CreatedAt': createdAt,
//       'UpdatedAt': (updatedAt = DateTime.now()).toIso8601String(),
//     };
//   }

//   factory CoupanModel.fromSnapshot(
//       DocumentSnapshot<Map<String, dynamic>> document) {
//     if (document.data() != null) {
//       final data = document.data()!;

//       // Map JSON Record to the Model
//       return CoupanModel(
//         id: document.id,
//         name: data['name'] ?? '',

//         isActive: data['isActive'] ?? false,
//         //  name: data.containsKey('name') ? data['name'] as String : '',
//         percentage:
//             data.containsKey('percentage') ? data['percentage'] as String : '',
//         // active: data.containsKey('active') ? data['active'] as String : '',
//         createdAt:
//             data.containsKey('CreatedAt') ? data['CreatedAt']?.toDate() : null,
//         updatedAt:
//             data.containsKey('UpdatedAt') ? data['UpdatedAt']?.toDate() : null,
//       );
//     } else {
//       return CoupanModel.empty();
//     }
//   }
// }

import 'package:EcommerceApp/helper/formmerclass.dart';

class CoupanModel {
  String id;
  String name;
  String percentage;
  // final String active;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  // OrderStatus status;

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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: false);
  String get formattedDate => TFormatter.formatDate(createdAt);

  String get formattedUpdatedAtDate => TFormatter.formatDate(updatedAt);
  toJson() {
    return {
      'name': name,
      'percentage': percentage,
      // 'active': active,
      'isActive': isActive,
      'CreatedAt': createdAt,

      'UpdatedAt': (updatedAt = DateTime.now()).toIso8601String(),
    };
  }

  toNewJson() {
    return {
      'name': name,
      'percentage': percentage,
      'isActive': isActive,
      'UpdatedAt': (updatedAt = DateTime.now()).toIso8601String(),
    };
  }

  CoupanModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? '',
        name = json['name'] ?? '',
        percentage = json['percentage'] ?? '' {
    // active = json['active'];
    isActive = json['isActive'];
    createdAt = json['CreatedAt'].runtimeType == String
        ? DateTime.parse(json['CreatedAt'])
        : json['CreatedAt'];

    updatedAt = json['UpdatedAt'].runtimeType == String
        ? DateTime.parse(json['UpdatedAt'])
        : json['UpdatedAt'];
  }
}
