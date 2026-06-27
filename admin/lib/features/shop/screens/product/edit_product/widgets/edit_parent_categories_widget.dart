import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/category/category_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/edit_product_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/product_model.dart';
import 'package:cwt_ecommerce_admin_panel/utils/helpers/cloud_helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../models/category_model.dart';

class EditProductSubCategories extends StatelessWidget {
  const EditProductSubCategories({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    print("product.id =  =${product.id}");
    final productController = EditProductController.instance;

    return TRoundedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories label
          Text('Sub Categories',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: TSizes.spaceBtwItems),

          // MultiSelectDialogField for selecting categories
          FutureBuilder(
              future: productController.loadSelectedCategories(product.id),
              builder: (context, snapshot) {
                final widget = TCloudHelperFunctions.checkMultiRecordState(
                    snapshot: snapshot);
                if (widget != null) return widget;

                return MultiSelectDialogField(
                  buttonText: const Text("Select Sub Categories"),
                  title: const Text("Sub Categories"),
                  initialValue: List<CategoryModel>.from(productController
                      .selectedCategories
                      .map((element) => element.toString())),
                  items: CategoryController.instance.allItems
                      .map((category) => MultiSelectItem(
                            category,
                            category.name,
                          ))
                      .toList(),
                  listType: MultiSelectListType.CHIP,
                  onConfirm: (values) {
                    productController.selectedCategories.assignAll(values);
                  },
                );
              }),
        ],
      ),
    );
  }
}
