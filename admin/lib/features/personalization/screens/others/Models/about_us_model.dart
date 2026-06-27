import 'package:cloud_firestore/cloud_firestore.dart';

class AboutUsModel {
  final String? id;
  String aboutText;

  AboutUsModel({
    this.id,
    required this.aboutText,
  });

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'AboutText': aboutText,
    };
  }

  factory AboutUsModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return AboutUsModel(
      id: document.id,
      aboutText: data.containsKey('AboutText') ? data['AboutText'] ?? '' : '',
    );
  }
}
