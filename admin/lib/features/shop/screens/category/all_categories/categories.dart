import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/categories_desktop.dart';
import 'responsive_screens/categories_mobile.dart';
import 'responsive_screens/categories_tablet.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
        desktop: CategoriesDesktopScreen(),
        tablet: CategoriesTabletScreen(),
        mobile: CategoriesMobileScreen());
  }
}
