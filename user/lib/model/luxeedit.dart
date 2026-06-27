/// Storefront model for the admin-managed "Luxe Edit" home section.
class LuxeTile {
  final String image;
  final String label;
  final String link;
  LuxeTile({this.image = '', this.label = '', this.link = ''});

  factory LuxeTile.fromMap(Map<String, dynamic> d) => LuxeTile(
        image: d['image']?.toString() ?? '',
        label: d['label']?.toString() ?? '',
        link: d['link']?.toString() ?? '',
      );
}

class LuxeEditModel {
  final String backgroundImage;
  final String title;
  final String subtitle;
  final String buttonText;
  final String buttonLink;
  final bool active;
  final List<LuxeTile> tiles;

  LuxeEditModel({
    this.backgroundImage = '',
    this.title = '',
    this.subtitle = '',
    this.buttonText = '',
    this.buttonLink = '',
    this.active = false,
    this.tiles = const [],
  });

  factory LuxeEditModel.fromMap(Map<String, dynamic> d) => LuxeEditModel(
        backgroundImage: d['backgroundImage']?.toString() ?? '',
        title: d['title']?.toString() ?? '',
        subtitle: d['subtitle']?.toString() ?? '',
        buttonText: d['buttonText']?.toString() ?? '',
        buttonLink: d['buttonLink']?.toString() ?? '',
        active: d['active'] == true,
        tiles: d['tiles'] is List
            ? (d['tiles'] as List)
                .map((e) => LuxeTile.fromMap(Map<String, dynamic>.from(e)))
                .toList()
            : const [],
      );

  /// Tiles that actually have an image to show.
  List<LuxeTile> get visibleTiles =>
      tiles.where((t) => t.image.isNotEmpty).toList();

  bool get hasContent => backgroundImage.isNotEmpty || visibleTiles.isNotEmpty;
}
