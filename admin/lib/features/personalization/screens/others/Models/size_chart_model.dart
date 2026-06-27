import 'package:cloud_firestore/cloud_firestore.dart';

class SizeChartModel {
  final String? id;
  String sizechartText;

  SizeChartModel({
    this.id,
    required this.sizechartText,
  });

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'AboutText': sizechartText,
    };
  }

  factory SizeChartModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return SizeChartModel(
      id: document.id,
      sizechartText: data.containsKey('sizechartText') ? data['sizechartText'] ?? '' : '',
    );
  }
}
