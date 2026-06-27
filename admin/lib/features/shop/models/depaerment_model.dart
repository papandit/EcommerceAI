import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  String id;
  String deptName;
  String lastname;

  // Not Mapped
  List<DepartmentModel>? childCategories;

  DepartmentModel({
    required this.id,
    required this.deptName,
    required this.lastname,
  });

  /// Empty Helper Function
  static DepartmentModel empty() => DepartmentModel(
        id: '',
        deptName: '',
        lastname: '',
      );

  /// Convert model to JSON structure for Firebase storage
  Map<String, dynamic> toJson() {
    return {
      'dept_name': deptName,
      'last_name': lastname,
    };
  }

  /// Build from a REST API JSON map (Node/MongoDB backend).
  factory DepartmentModel.fromJson(Map<String, dynamic> data) {
    return DepartmentModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      deptName: data['dept_name'] ?? '',
      lastname: data['last_name'] ?? '',
    );
  }

  /// Map JSON document snapshot from Firebase to DepartmentModel
  factory DepartmentModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data != null) {
      return DepartmentModel(
        id: document.id,
        deptName: data['dept_name'] ?? '',
        lastname: data['last_name'] ?? '',
      );
    } else {
      return DepartmentModel.empty();
    }
  }

  get name => null;
}
