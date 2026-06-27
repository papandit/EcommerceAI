// ignore_for_file: avoid_print

import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/category/category_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/create_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../../utils/constants/sizes.dart';

class ProductCategories extends StatelessWidget {
  const ProductCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Get instance of the CategoryController
    final categoriesController = Get.put(CategoryController());
    final createproductcontroller = Get.put(CreateProductController());

    // Fetch categories if the list is empty
    if (categoriesController.allItems.isEmpty) {
      categoriesController.fetchItems();
    }

    return TRoundedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories label
          Text('Categories', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: TSizes.spaceBtwItems),

          // MultiSelectDialogField for selecting categories
          Obx(
            () => categoriesController.isLoading.value
                ? const TShimmerEffect(width: double.infinity, height: 50)
                : DropdownButtonFormField(
                    decoration: const InputDecoration(
                        hintText: 'Select Categories',
                        labelText: 'Select Categories',
                        prefixIcon: Icon(Iconsax.bezier)),
                    onChanged: (value) {
                      print("Checksp id = ${value!.id}");
                      print("Checksp 12222 = ${value.parentId}");
                      createproductcontroller.select_category_id =
                          value.id.toString();
                      createproductcontroller.select_category_name.value =
                          value.name.toString();
                      value.id.toString();
                      print(
                          "HR ::  select_category_id ${createproductcontroller.select_category_id}");
                      print(
                          "HR ::  select_category_NAme ${createproductcontroller.select_category_name}");
                      print("HR :: value.id.toString() ${value.id.toString()}");
                      createproductcontroller.sub_category_datass.clear();

                      for (var element in value.parentId!) {
                          print("sub_category_datass element = $element");
                          createproductcontroller.sub_category_datass
                              .add(element);
                        }
                      createproductcontroller.formFieldState_data.currentState!
                          .reset();
                      print("Checksp =length check");
                      print(
                          "Checksp =length ${CreateProductController.instance.sub_category_datass.length}");
                    },
                    items: categoriesController.allItems
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [Text(item.name)]),
                            ))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
