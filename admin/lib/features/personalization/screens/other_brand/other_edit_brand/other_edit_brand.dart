import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/other_brand/other_edit_brand/responsive_screens/other_edit_brand_desktop.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/other_brand/other_edit_brand/responsive_screens/other_edit_brand_mobile.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/other_brand/other_edit_brand/responsive_screens/other_edit_brand_tablet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';

class OtherEditBrandScreen extends StatelessWidget {
  const OtherEditBrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = Get.arguments;
    return TSiteTemplate(
      desktop: OtherEditBrandDesktopScreen(brand: brand),
      tablet: OtherEditBrandTabletScreen(brand: brand),
      mobile: OtherEditBrandMobileScreen(brand: brand),
    );
  }
}
