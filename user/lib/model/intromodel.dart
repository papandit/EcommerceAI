// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:EcommerceApp/helper/utillity.dart';

class Intromodel {
  String image;
  String text;
  String btn;
  Intromodel({required this.image, required this.text, required this.btn});
}

List<Intromodel> IntroList = [
  Intromodel(
      image: AppImage.appIcon + "intro1.jpg",
      text: 'View And Exprience Fashion With The Help Of Our Collection',
      btn: ""),
  Intromodel(
      image: AppImage.appIcon + "intro2.jpg",
      text: 'Design Your Self With Our Fabulous Footwear Collection',
      btn: ""),
  Intromodel(
      image: AppImage.appIcon + "intro3.jpg",
      text: 'Explore World Class Top Fashion As Per Your Requirements & Choice',
      btn: ""),
];
