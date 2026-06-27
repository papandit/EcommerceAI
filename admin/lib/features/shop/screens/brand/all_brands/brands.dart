import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/brands_desktop.dart';
import 'responsive_screens/brands_mobile.dart';
import 'responsive_screens/brands_tablet.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
        desktop: BrandsDesktopScreen(),
        tablet: BrandsTabletScreen(),
        mobile: BrandsMobileScreen());
  }
}
