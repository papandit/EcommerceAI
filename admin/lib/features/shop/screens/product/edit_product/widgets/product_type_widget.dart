import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../controllers/product/edit_product_controller.dart';

class ProductTypeWidget extends StatelessWidget {
  const ProductTypeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = EditProductController.instance;

    return Obx(
      () => Row(
        children: [
          Text('Product Type', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: TSizes.spaceBtwItems),
          // Radio button for Single Product Type
          RadioMenuButton(
            value: ProductType.single,
            groupValue: controller.productType.value,
            onChanged: (value) {
              // Update the selected product type in the controller
              controller.productType.value = value ?? ProductType.single;
            },
            child: const Text('Single'),
          ),
          // Radio button for Variable Product Type
          RadioMenuButton(
            value: ProductType.variable,
            groupValue: controller.productType.value,
            onChanged: (value) {
              // Update the selected product type in the controller
              controller.productType.value = value ?? ProductType.single;
            },
            child: const Text('Variable'),
          ),
        ],
      ),
    );
  }
}
