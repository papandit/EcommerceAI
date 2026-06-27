import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import 'responsive_screens/order_detail_desktop.dart';
import 'responsive_screens/order_detail_mobile.dart';
import 'responsive_screens/order_detail_tablet.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('OrderDetailScreen :: ${Get.arguments}');
    final order = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (order == null) {
        Get.offAllNamed(TRoutes.dashboard);
      }
    });
    return TSiteTemplate(
      desktop: OrderDetailDesktopScreen(order: order),
      tablet: OrderDetailTabletScreen(order: order),
      mobile: OrderDetailMobileScreen(order: order),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  // final controller = Get.put(OrderDetailController());

  //   return Obx(() {
  //     if (controller.loading.value) {
  //       return const SizedBox();
  //     }

  //     return TSiteTemplate(
  //       desktop: OrderDetailDesktopScreen(order: controller.order.value),
  //       tablet: OrderDetailTabletScreen(order: controller.order.value),
  //       mobile: OrderDetailMobileScreen(order: controller.order.value),
  //     );
  //   });
  // }
}
