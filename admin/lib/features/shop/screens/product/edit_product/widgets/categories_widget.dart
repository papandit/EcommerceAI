// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/category/category_controller.dart';
// import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/create_product_controller.dart';
// import 'package:cwt_ecommerce_admin_panel/features/shop/models/category_model.dart';
// import 'package:cwt_ecommerce_admin_panel/features/shop/models/product_model.dart';
// import 'package:cwt_ecommerce_admin_panel/utils/helpers/cloud_helper_functions.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:multi_select_flutter/multi_select_flutter.dart';

// import '../../../../../../common/widgets/containers/rounded_container.dart';
// import '../../../../../../common/widgets/shimmers/shimmer.dart';
// import '../../../../../../utils/constants/sizes.dart';

// class EditProductCategories extends StatelessWidget {
//   const EditProductCategories({
//     required this.product,
//     super.key,
//   });
//   final ProductModel product;
//   @override
//   Widget build(BuildContext context) {
//     final productController = EditProductController.instance;
//     // Get instance of the CategoryController
//     final categoriesController = Get.put(CategoryController());
//     final createproductcontroller = Get.put(CreateProductController());

//     // Fetch categories if the list is empty
//     if (categoriesController.allItems.isEmpty) {
//       categoriesController.fetchItems();
//     }

//     return TRoundedContainer(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Categories label
//           Text('Categories11',
//               style: Theme.of(context).textTheme.headlineSmall),
//           const SizedBox(height: TSizes.spaceBtwItems),

//           // MultiSelectDialogField for selecting categories
//           Obx(
//             () => categoriesController.isLoading.value
//                 ? const TShimmerEffect(width: double.infinity, height: 50)
//                 : DropdownButtonFormField(
//                     value: List<CategoryModel>.from(
//                         productController.selectedCategories),
//                     decoration: const InputDecoration(
//                         hintText: 'Select Categories',
//                         labelText: 'Select Categories',
//                         prefixIcon: Icon(Iconsax.bezier)),
//                     onChanged: (value) {
//                       // print("Checksp id = ${value!.id}");
//                       // print("Checksp 12222 = ${value!.parentId}");
//                       productController.selectedCategories = value;
//                       print(
//                           "++productController.selectedCategories ${productController.selectedCategories}");
//                       // createproductcontroller.select_category_id =
//                       //     value.id.toString();
//                       createproductcontroller.sub_category_datass.clear();

//                       // value.parentId!.forEach(
//                       //   (element) {
//                       //     createproductcontroller.sub_category_datass
//                       //         .add(element);
//                       //   },
//                       // );
//                       print("Checksp =length check");
//                       print(
//                           "Checksp =length ${CreateProductController.instance.sub_category_datass.length}");
//                     },
//                     items: categoriesController.allItems
//                         .map((item) => DropdownMenuItem(
//                               value: item,
//                               child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [Text(item.name)]),
//                             ))
//                         .toList(),
//                   ),

//             // : MultiSelectDialogField(
//             //     buttonText: const Text("Select Categories"),
//             //     title: const Text("Categories"),
//             //     items: categoriesController.allItems
//             //         .map((category) =>
//             //             MultiSelectItem(category, category.name))
//             //         .toList(),
//             //     listType: MultiSelectListType.CHIP,
//             //     onConfirm: (values) {
//             //       CreateProductController.instance.selectedCategories
//             //           .assignAll(values);
//             //     },
//             //   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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

class EditProductCategories extends StatelessWidget {
  const EditProductCategories({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final productController = EditProductController.instance;

    return TRoundedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories label
          Text('Categories', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: TSizes.spaceBtwItems),

          // MultiSelectDialogField for selecting categories
          FutureBuilder(
              future: productController.loadSelectedCategories(product.id),
              builder: (context, snapshot) {
                final widget = TCloudHelperFunctions.checkMultiRecordState(
                    snapshot: snapshot);
                if (widget != null) return widget;
                print("++snap data${snapshot.data}");
                return MultiSelectDialogField(
                  buttonText: const Text("Select Categories"),
                  title: const Text("Categories"),
                  initialValue: List<CategoryModel>.from(
                      productController.selectedCategories),
                  items: CategoryController.instance.allItems.map((category) {
                    return MultiSelectItem(category, category.name);
                  }).toList(),
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
