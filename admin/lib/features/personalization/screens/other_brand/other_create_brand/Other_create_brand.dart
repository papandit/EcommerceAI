import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/other_brand/other_create_brand/responsive_screens/Other_create_brand_tablet.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/other_brand/other_create_brand/responsive_screens/other_create_brand_desktop.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/other_brand/other_create_brand/responsive_screens/other_create_brand_mobile.dart';
import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';

class OtherCreateBrandScreen extends StatelessWidget {
  const OtherCreateBrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
      desktop: OtherCreateBrandDesktopScreen(),
      tablet: OtherCreateBrandTabletScreen(),
      mobile: OtherCreateBrandMobileScreen(),
    );
  }
}
