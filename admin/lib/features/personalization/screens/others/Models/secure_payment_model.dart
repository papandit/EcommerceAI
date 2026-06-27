import 'package:cloud_firestore/cloud_firestore.dart';

class SecurePaymentModel {
  final String? id;
  String securePaymentText;

  SecurePaymentModel({
    this.id,
    required this.securePaymentText,
  });

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'FreeShipText': securePaymentText,
    };
  }

  factory SecurePaymentModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return SecurePaymentModel(
      id: document.id,
      securePaymentText:
          data.containsKey('FreeShipText') ? data['FreeShipText'] ?? '' : '',
    );
  }
}
