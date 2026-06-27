// ignore_for_file: collection_methods_unrelated_type, invalid_use_of_protected_member
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/category/category_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/department/department_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/create_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../../utils/constants/sizes.dart';

List departmentName = [
  'Popular',
  'Festival',
  'Best Selling',
  'Trending',
  'Buy 3 Get 60% Off',
  'All Under ₹100',
  'Quickship',
];

class ProductDepartment extends StatelessWidget {
  const ProductDepartment({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Get instance of the CategoryController
    final categoriesController = Get.put(CategoryController());
    final createProductController = Get.put(CreateProductController());
    final departMentController = Get.put(DepartMentController());
    departMentController.fetchItems();
    // Fetch categories if the list is empty
    // if (categoriesController.allItems.isEmpty)
    categoriesController.fetchItems();
    // }

    return Obx(
      () => TRoundedContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories label
            Text('Product Department',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: TSizes.spaceBtwItems),

            categoriesController.isLoading.value
                ? const TShimmerEffect(width: double.infinity, height: 50)
                : DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        hintText: 'Select Product Department',
                        labelText: 'Select Product Department',
                        prefixIcon: Icon(Iconsax.bezier)),
                    onChanged: (newValue) {
                      createProductController.departmentname = newValue!;
                    },
                    items: departMentController.departmentName
                        .map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
          ],
        ),
      ),
    );
  }
}
