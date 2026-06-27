import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  String? id;
  String imageUrl;
  bool active;
  String targetScreen;

  // Optional promotional overlay content (AJIO-style hero banner).
  // When these are empty the storefront simply shows the image as-is.
  String title;
  String subtitle;
  String buttonText;
  String buttonLink;

  BannerModel({
    this.id,
    required this.imageUrl,
    required this.targetScreen,
    required this.active,
    this.title = '',
    this.subtitle = '',
    this.buttonText = '',
    this.buttonLink = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'active': active,
      'targetScreen': targetScreen,
      'title': title,
      'subtitle': subtitle,
      'buttonText': buttonText,
      'buttonLink': buttonLink,
    };
  }

  /// Build from a REST API JSON map (Node/MongoDB backend).
  factory BannerModel.fromJson(Map<String, dynamic> data) {
    return BannerModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      imageUrl: data['imageUrl'] ?? '',
      active: data['active'] ?? false,
      targetScreen: data['targetScreen'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      buttonText: data['buttonText'] ?? '',
      buttonLink: data['buttonLink'] ?? '',
    );
  }

  factory BannerModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return BannerModel(
      id: snapshot.id,
      imageUrl: data['imageUrl'] ?? '',
      active: data['active'] ?? false,
      targetScreen: data['targetScreen'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      buttonText: data['buttonText'] ?? '',
      buttonLink: data['buttonLink'] ?? '',
    );
  }
}
