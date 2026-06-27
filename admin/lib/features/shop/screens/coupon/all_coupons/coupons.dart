import 'package:flutter/material.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/coupons_desktop.dart';
import 'responsive_screens/coupons_mobile.dart';
import 'responsive_screens/coupons_tablet.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TSiteTemplate(
        desktop: CouponsDesktopScreen(),
        tablet: CouponsTabletScreen(),
        mobile: CouponsMobileScreen());
  }
}
