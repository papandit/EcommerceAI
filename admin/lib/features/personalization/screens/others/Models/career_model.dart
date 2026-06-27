import 'package:cloud_firestore/cloud_firestore.dart';

class CareerModel {
  final String? id;
  String careerText;

  CareerModel({
    this.id,
    required this.careerText,
  });

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CareerText': careerText,
    };
  }

  factory CareerModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return CareerModel(
      id: document.id,
      careerText: data.containsKey('CareerText') ? data['CareerText'] ?? '' : '',
    );
  }
}
