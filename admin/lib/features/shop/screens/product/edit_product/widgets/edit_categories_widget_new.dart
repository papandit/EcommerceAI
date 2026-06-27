// ignore_for_file: unrelated_type_equality_checks, avoid_print

import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/category/category_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/create_product_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../../utils/constants/sizes.dart';

class Edit_ProductCategories extends StatelessWidget {
  const Edit_ProductCategories({
    super.key,
    required this.product,
  });
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    int selectIndex = 0;
    print("++product.categoryName${product.categoryName}");
    // Get instance of the CategoryController
    final categoriesController = Get.put(CategoryController());
    final createproductcontroller = Get.put(CreateProductController());

    // Fetch categories if the list is empty
    // if (categoriesController.allItems.isEmpty) {
    print("isEmpty :: ${categoriesController.allItems}");
    categoriesController.fetchItems().then(
      (value) {
        // value
        //     .forEach((element) => categoriesController.allItems.add(element));
        if (categoriesController.allItems.isEmpty) {
          categoriesController.allItems.addAll(value);

          print("isEmpty11 :: ${categoriesController.allItems}");
        }

        value.asMap().forEach(
          (index, element) {
            if (element.id == product.categoryId) {
              selectIndex = index;

              // createproductcontroller.select_category_id = element.id;
              createproductcontroller.sub_category_datass.clear();
              createproductcontroller.subcategoryname.value = "null";

              print("sub_category_datass = Call");

              for (var element in element.parentId!) {
                  print("sub_category_datass element = $element");
                  createproductcontroller.sub_category_datass.add(element);
                }
            }
          },
        );

        if (value.any((element) => element.name == product.categoryName)) {
          print("product.categoryName = check");
        }

        print("HR :: first.id :: sec ${value.first.id}");
        print(value.length);
        print("++product.categoryName${product.categoryName}");

        print("HR :: last.id :: sec  ${value.last.id}");
        print("HR :: first.id :: sec  ${categoriesController.allItems}");
      },
    );
    // }

    print("productsss = ${product.categoryId}");
    print("product.categoryName = ${product.categoryName}");
    // print("productsss = ${product.}");
    createproductcontroller.select_category_id = product.categoryId.toString();
    createproductcontroller.select_category_name.value =
        product.categoryName.toString();
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
                : categoriesController.allItems.isEmpty
                    ? Container()
                    : DropdownButtonFormField(
                        initialValue: categoriesController.allItems[selectIndex],
                        decoration: const InputDecoration(
                            hintText: 'Select Categories',
                            labelText: 'Select Categories',
                            prefixIcon: Icon(Iconsax.bezier)),
                        onChanged: (value) {
                          createproductcontroller.select_category_id =
                              value!.id;
                          print(
                              "subcategoryname ss= ${createproductcontroller.subcategoryname}");
                          createproductcontroller.sub_category_datass.clear();
                          print(
                              "sub_category_datass clear = ${createproductcontroller.sub_category_datass}");
                          createproductcontroller.subcategoryname.value =
                              "null";
                          createproductcontroller.subcategoryname_new.value =
                              "null";
                          print(
                              "subcategoryname clear = ${createproductcontroller.subcategoryname}");
                          print(
                              "sub_category_datass clear = ${createproductcontroller.sub_category_datass}");
                          // createproductcontroller.subcategoryname.value = null;
                          // createproductcontroller
                          //     .formFieldState_data.currentState!
                          //     .reset();
                          for (var element in value.parentId!) {
                              print("sub_category_datass element = $element");
                              createproductcontroller.sub_category_datass
                                  .add(element);
                            }

                          createproductcontroller
                              .formFieldState_data.currentState!
                              .reset();
                          print("Checksp =length check");
                          print(
                              "Checksp =length ${CreateProductController.instance.sub_category_datass.length}");
                        },
                        items: categoriesController.allItems
                            .map((item) => DropdownMenuItem(
                                  value: item,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
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
