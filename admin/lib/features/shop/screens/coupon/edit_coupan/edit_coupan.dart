import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/edit_coupan_desktop.dart';
import 'responsive_screens/edit_coupan_mobile.dart';
import 'responsive_screens/edit_coupan_tablet.dart';

class EditCoupanScreen extends StatelessWidget {
  const EditCoupanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coupan = Get.arguments;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (coupan == null) {
        Get.offAllNamed(TRoutes.dashboard);
      }
    });
    return TSiteTemplate(
      desktop: EditCoupanDesktopScreen(coupan: coupan),
      tablet: EditCoupanTabletScreen(coupan: coupan),
      mobile: EditCoupanMobileScreen(coupan: coupan),
    );
  }
}
