import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../utils/device/device_utility.dart';
import '../../../../controllers/customer/customer_controller.dart';

class CustomerTableHeader extends StatelessWidget {
  const CustomerTableHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerController());
    return Row(
      children: [
        Expanded(
            flex: !TDeviceUtils.isDesktopScreen(context) ? 0 : 3,
            child: const SizedBox()),
        Expanded(
          flex: TDeviceUtils.isDesktopScreen(context) ? 2 : 1,
          child: TextFormField(
            controller: controller.searchTextController,
            onChanged: (query) => controller.searchQuery(query),
            decoration: const InputDecoration(
                hintText: 'Search Customers',
                prefixIcon: Icon(Iconsax.search_normal)),
          ),
        ),
      ],
    );
  }
}
