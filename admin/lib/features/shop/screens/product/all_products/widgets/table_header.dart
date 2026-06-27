import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/product_controller.dart';
import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../utils/device/device_utility.dart';

class ProductTableHeader extends StatelessWidget {
  const ProductTableHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    return Row(
      children: [
        Expanded(
          flex: !TDeviceUtils.isDesktopScreen(context) ? 1 : 3,
          child: Row(
            children: [
              SizedBox(
                width: 140,
                child: ElevatedButton(
                    onPressed: () => Get.toNamed(TRoutes.createProduct),
                    child: const Text('Add Product')),
              ),
            ],
          ),
        ),
        Expanded(
          flex: TDeviceUtils.isDesktopScreen(context) ? 2 : 1,
          child: TextFormField(
            controller: controller.searchTextController,
            onChanged: (query) => controller.searchQuery(query),
            decoration: const InputDecoration(
                hintText: 'Search', prefixIcon: Icon(Iconsax.search_normal)),
          ),
        ),
      ],
    );
  }
}
