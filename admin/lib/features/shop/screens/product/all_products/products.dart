import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/products_desktop.dart';
import 'responsive_screens/products_mobile.dart';
import 'responsive_screens/products_tablet.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
        desktop: ProductsDesktopScreen(),
        tablet: ProductsTabletScreen(),
        mobile: ProductsMobileScreen());
  }
}
