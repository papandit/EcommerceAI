import 'package:cloud_firestore/cloud_firestore.dart';

class ContactUsModel {
  final String? id;
  String contactText;

  ContactUsModel({
    this.id,
    required this.contactText,
  });

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'AboutText': contactText,
    };
  }

  factory ContactUsModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ContactUsModel(
      id: document.id,
      contactText: data.containsKey('ContactText') ? data['contactText'] ?? '' : '',
    );
  }
}
