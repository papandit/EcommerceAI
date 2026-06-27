import 'package:cloud_firestore/cloud_firestore.dart';

/// A single small tile in the "Luxe Edit" home section (image + label + link).
class LuxeTile {
  String image;
  String label;
  String link;

  LuxeTile({this.image = '', this.label = '', this.link = ''});

  Map<String, dynamic> toJson() =>
      {'image': image, 'label': label, 'link': link};

  factory LuxeTile.fromMap(Map<String, dynamic> d) => LuxeTile(
        image: d['image']?.toString() ?? '',
        label: d['label']?.toString() ?? '',
        link: d['link']?.toString() ?? '',
      );
}

/// Admin-managed "Luxe Edit" promotional section: a large background banner
/// (title + subtitle + Shop Now) plus four small editable tiles.
class LuxeEditModel {
  String backgroundImage;
  String title;
  String subtitle;
  String buttonText;
  String buttonLink;
  bool active;
  List<LuxeTile> tiles;

  LuxeEditModel({
    this.backgroundImage = '',
    this.title = '',
    this.subtitle = '',
    this.buttonText = '',
    this.buttonLink = '',
    this.active = true,
    List<LuxeTile>? tiles,
  }) : tiles = tiles ?? [];

  Map<String, dynamic> toJson() => {
        'backgroundImage': backgroundImage,
        'title': title,
        'subtitle': subtitle,
        'buttonText': buttonText,
        'buttonLink': buttonLink,
        'active': active,
        'tiles': tiles.map((e) => e.toJson()).toList(),
      };

  factory LuxeEditModel.fromMap(Map<String, dynamic> data) => LuxeEditModel(
        backgroundImage: data['backgroundImage']?.toString() ?? '',
        title: data['title']?.toString() ?? '',
        subtitle: data['subtitle']?.toString() ?? '',
        buttonText: data['buttonText']?.toString() ?? '',
        buttonLink: data['buttonLink']?.toString() ?? '',
        active: data['active'] == true,
        tiles: data['tiles'] is List
            ? (data['tiles'] as List)
                .map((e) => LuxeTile.fromMap(Map<String, dynamic>.from(e)))
                .toList()
            : [],
      );

  factory LuxeEditModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = (snapshot.data() as Map<String, dynamic>?) ?? {};
    return LuxeEditModel.fromMap(data);
  }
}
