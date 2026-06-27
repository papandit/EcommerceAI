import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/view/tryon_page.dart';
import 'package:flutter/material.dart';

/// Open the virtual Try-On page for a product, working on both web (Beamer) and
/// mobile (Navigator). Used by the product card and product detail page.
void openTryOn(BuildContext context, ProductModel p) {
  WebAPPNavigation.navigateToroute(
    context: context,
    routename: '/TryOn/${p.id}',
    data: {
      'productId': p.id,
      'productName': p.title,
      'thumbnail': p.thumbnail,
    },
    screen: TryOnPage(
      productId: p.id,
      productName: p.title,
      thumbnail: p.thumbnail,
    ),
  );
}
