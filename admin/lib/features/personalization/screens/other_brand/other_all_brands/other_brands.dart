import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/other_brand/other_all_brands/responsive_screens/other_brands_desktop.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/other_brand/other_all_brands/responsive_screens/other_brands_mobile.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/other_brand/other_all_brands/responsive_screens/other_brands_tablet.dart';
import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';

class OtherBrandsScreen extends StatelessWidget {
  const OtherBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
        desktop: OtherBrandsDesktopScreen(),
        tablet: OtherBrandsTabletScreen(),
        mobile: OtherBrandsMobileScreen());
  }
}
