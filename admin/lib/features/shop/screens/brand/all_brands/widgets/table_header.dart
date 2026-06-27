import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../utils/device/device_utility.dart';
import '../../../../controllers/brand/brand_controller.dart';

class BrandTableHeader extends StatelessWidget {
  const BrandTableHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BrandController());
    return Row(
      children: [
        Expanded(
          flex: !TDeviceUtils.isDesktopScreen(context) ? 1 : 3,
          child: Row(
            children: [
              SizedBox(
                  width: 200,
                  child: ElevatedButton(
                      onPressed: () => Get.toNamed(TRoutes.createBrand),
                      child: const Text('Create New Brand'))),
            ],
          ),
        ),
        Expanded(
          flex: TDeviceUtils.isDesktopScreen(context) ? 2 : 1,
          child: TextFormField(
            controller: controller.searchTextController,
            onChanged: (query) => controller.searchQuery(query),
            decoration: const InputDecoration(
                hintText: 'Search Brands',
                prefixIcon: Icon(Iconsax.search_normal)),
          ),
        ),
      ],
    );
  }
}
