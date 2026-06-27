import 'package:cwt_ecommerce_admin_panel/features/shop/screens/banner/edit_banner/responsive_screens/edit_brand_tablet.dart';
import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/edit_banner_desktop.dart';
import 'responsive_screens/edit_banner_mobile.dart';

class EditBannerScreen extends StatelessWidget {
  const EditBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final banner = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (banner == null) {
        Get.offAllNamed(TRoutes.dashboard);
      }
    });

    return TSiteTemplate(
      desktop: EditBannerDesktopScreen(banner: banner),
      tablet: EditBannerTabletScreen(banner: banner),
      mobile: EditBannerMobileScreen(banner: banner),
    );
  }
}
