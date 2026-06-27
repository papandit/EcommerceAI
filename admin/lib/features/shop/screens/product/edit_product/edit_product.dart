import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/layouts/templates/site_layout.dart';
import '../../../controllers/product/edit_product_controller.dart';
import 'responsive_screens/edit_product_desktop.dart';
import 'responsive_screens/edit_product_mobile.dart';

class EditProductScreen extends StatelessWidget {
  const EditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProductController());
    final product = Get.arguments;

    return Obx(() {
      if (controller.loading.value) {
        return const SizedBox();
      }
      controller.initProductData(controller.product.value);
      return TSiteTemplate(
          desktop: EditProductDesktopScreen(product: controller.product.value),
          mobile: EditProductMobileScreen(product: controller.product.value));
    });
  }
}
