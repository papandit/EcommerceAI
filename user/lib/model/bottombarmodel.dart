class Bottombarmodel {
  String image;
  String text;
  Bottombarmodel({
    required this.image,
    required this.text,
  });
}

List<Bottombarmodel> bottombarList = [
  Bottombarmodel(image: 'assets/image/smarthouse.png', text: 'Home'),
  Bottombarmodel(image: 'assets/image/health.png', text: 'Favourite'),
  Bottombarmodel(image: 'assets/image/ecommerce.png', text: 'Cart'),
  Bottombarmodel(image: 'assets/image/profile.png', text: 'Profile'),
];
