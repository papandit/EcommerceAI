/// A home hero banner, managed from the admin "Banners" section.
/// `imageUrl` is required; the rest are optional promo-overlay fields
/// (title / subtitle / Shop Now button) that the admin can fill in.
class HomeBanner {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String buttonText;
  final String buttonLink;

  HomeBanner({
    this.imageUrl = '',
    this.title = '',
    this.subtitle = '',
    this.buttonText = '',
    this.buttonLink = '',
  });

  factory HomeBanner.fromMap(Map<String, dynamic> data) {
    return HomeBanner(
      imageUrl: data['imageUrl']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      subtitle: data['subtitle']?.toString() ?? '',
      buttonText: data['buttonText']?.toString() ?? '',
      buttonLink: data['buttonLink']?.toString() ?? '',
    );
  }

  bool get hasOverlay =>
      title.isNotEmpty || subtitle.isNotEmpty || buttonText.isNotEmpty;
}
