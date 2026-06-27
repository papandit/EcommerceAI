import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/customer_detail_desktop.dart';
import 'responsive_screens/customer_detail_mobile.dart';
import 'responsive_screens/customer_detail_tablet.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customer = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (customer == null) {
        Get.offAllNamed(TRoutes.dashboard);
      }
    });
    return TSiteTemplate(
      desktop: CustomerDetailDesktopScreen(customer: customer),
      tablet: CustomerDetailTabletScreen(customer: customer),
      mobile: CustomerDetailMobileScreen(customer: customer),
    );
  }
}
