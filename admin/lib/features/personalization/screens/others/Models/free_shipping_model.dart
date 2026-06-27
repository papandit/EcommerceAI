import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingModel {
  final String? id;
  String freeshipText;

  ShippingModel({
    this.id,
    required this.freeshipText,
  });

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'FreeShipText': freeshipText,
    };
  }

  factory ShippingModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ShippingModel(
      id: document.id,
      freeshipText:
          data.containsKey('FreeShipText') ? data['FreeShipText'] ?? '' : '',
    );
  }
}
