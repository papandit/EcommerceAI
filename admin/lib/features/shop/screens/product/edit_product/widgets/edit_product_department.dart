// ignore_for_file: collection_methods_unrelated_type, invalid_use_of_protected_member
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/category/category_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/department/department_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/edit_product_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/product_model.dart';
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

class EditProductDepartment extends StatelessWidget {
  const EditProductDepartment({
    super.key,
    required this.product,
  });
  final ProductModel product;
  @override
  Widget build(BuildContext context) {
    // Get instance of the CategoryController
    final categoriesController = Get.put(CategoryController());
    final editProductController = Get.put(EditProductController());
    final departMentController = Get.put(DepartMentController());
    departMentController.fetchItems();
    // Fetch categories if the list is empty
    if (categoriesController.allItems.isEmpty) {
      // departMentController.fetchData();
      categoriesController.fetchItems();
    }

    print("product.departmentname = ${product.departmentname}");
    if (product.departmentname!.isEmpty) {
      editProductController.departmentname = "null";
    } else {
      editProductController.departmentname = product.departmentname!;
    }

    return Obx(
      () {
        // Ensure unique department names
        List<String> uniqueDepartmentNames =
            departMentController.departmentName.toSet().toList();

        // Ensure selected department is valid
        String? selectedDepartment =
            editProductController.departmentname == "null"
                ? null
                : uniqueDepartmentNames
                        .contains(editProductController.departmentname)
                    ? editProductController.departmentname
                    : null;

        String? lastDepartment = editProductController.departmentname == "null"
            ? null
            : departMentController.oldDepartmentName
                    .contains(editProductController.departmentname)
                ? editProductController.departmentname
                : null;

        return TRoundedContainer(
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
                      initialValue: selectedDepartment,
                      decoration: const InputDecoration(
                          hintText: 'Select Product Department',
                          labelText: 'Select Product Department',
                          prefixIcon: Icon(Iconsax.bezier)),
                      onChanged: (newValue) {
                        editProductController.departmentname = newValue!;
                      },
                      items: uniqueDepartmentNames
                          .map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
              if (lastDepartment != null) ...[
                const SizedBox(height: TSizes.spaceBtwItems),
                Text('Last Department',
                    style: Theme.of(context).textTheme.headlineSmall),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    lastDepartment,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ]
            ],
          ),
        );
      },
    );
  }
}
