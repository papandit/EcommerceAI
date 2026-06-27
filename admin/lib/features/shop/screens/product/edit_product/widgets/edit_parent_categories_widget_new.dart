// ignore_for_file: collection_methods_unrelated_type, invalid_use_of_protected_member, camel_case_types

import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/category/category_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/create_product_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../../utils/constants/sizes.dart';

// class Edit_ProductParentCategories extends StatelessWidget {
//   const Edit_ProductParentCategories({
//     super.key,
//     required this.product,
//   });
//   final ProductModel product;
//   @override
//   Widget build(BuildContext context) {
//     // Get instance of the CategoryController
//     final categoriesController = Get.put(CategoryController());
//     final createProductController = Get.put(CreateProductController());

//     // Fetch categories if the list is empty
//     if (categoriesController.allItems.isEmpty) {
//       categoriesController.fetchItems();
//     }
//     createProductController.subcategoryname.value = product.subCategoryName!;
//     createProductController.subcategoryname_new.value =
//         product.subCategoryName!;

//     print(
//         "subcategoryname  select_category_id=  =${createProductController.select_category_id}");
//     print("subcategoryname =  =${createProductController.subcategoryname}");
//     print(
//         "subcategoryname = value  =${createProductController.subcategoryname_new.value}");
//     print(
//         "subcategoryname = value  =${createProductController.sub_category_datass}");

//     return Obx(
//       () => Visibility(
//         visible: CreateProductController.instance.sub_category_datass.isNotEmpty
//             ? true
//             : false,
//         child: TRoundedContainer(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Categories label
//               Text('Sub Categories',
//                   style: Theme.of(context).textTheme.headlineSmall),
//               const SizedBox(height: TSizes.spaceBtwItems),

//               categoriesController.isLoading.value
//                   ? const TShimmerEffect(width: double.infinity, height: 50)
//                   : DropdownButtonFormField<String>(
//                       key: createProductController.formFieldState_data,
//                       value: createProductController
//                                   .subcategoryname_new.value ==
//                               "null"
//                           ? null
//                           : createProductController.subcategoryname_new.value,
//                       decoration: const InputDecoration(
//                           hintText: 'Select Sub Categories',
//                           labelText: 'Select Sub Categories',
//                           prefixIcon: Icon(Iconsax.bezier)),
//                       onChanged: (newValue) {
//                         createProductController.subcategoryname.value =
//                             newValue!;
//                         createProductController.sub_category_datass.forEach(
//                           (element) {
//                             if (element['name'] == newValue) {
//                               createProductController.subcategoryid.value =
//                                   element['id'];
//                             }
//                           },
//                         );
//                         print(
//                             "subb ${createProductController.subcategoryname_new.value}");
//                       },
//                       items: createProductController.sub_category_datass
//                           .map<DropdownMenuItem<String>>(
//                               (Map<String, dynamic> value) {
//                         return DropdownMenuItem<String>(
//                           value: value['name'].toString(),
//                           child: Text(value['name']),
//                         );
//                       }).toList(),
//                     )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// // }
// class Edit_ProductParentCategories extends StatefulWidget {
//   const Edit_ProductParentCategories({
//     super.key,
//     required this.product,
//   });
//   final ProductModel product;

//   @override
//   State<Edit_ProductParentCategories> createState() =>
//       _Edit_ProductParentCategoriesState();
// }

// class _Edit_ProductParentCategoriesState
//     extends State<Edit_ProductParentCategories> {
//   final categoriesController = Get.put(CategoryController());
//   final createProductController = Get.put(CreateProductController());

//   @override
//   void initState() {
//     super.initState();

//     // Fetch categories
//     categoriesController.fetchItems().then((_) {
//       setState(() {}); // Ensure UI rebuild happens safely after fetching
//     });

//     // Set initial values
//     if (createProductController.subcategoryname.value.isEmpty) {
//       createProductController.subcategoryname.value = "null";
//     } else {
//       createProductController.subcategoryname.value =
//           widget.product.subCategoryName!;
//     }
//     if (createProductController.subcategoryname_new.value.isEmpty) {
//       createProductController.subcategoryname_new.value = "null";
//     } else {
//       createProductController.subcategoryname_new.value =
//           widget.product.subCategoryName!;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     categoriesController.fetchItems()
//     return Obx(
//       () => Visibility(
//         visible: createProductController.sub_category_datass.isNotEmpty,
//         child: TRoundedContainer(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Sub Categories',
//                   style: Theme.of(context).textTheme.headlineSmall),
//               const SizedBox(height: TSizes.spaceBtwItems),
//               categoriesController.isLoading.value
//                   ? const TShimmerEffect(width: double.infinity, height: 50)
//                   : DropdownButtonFormField<String>(
//                       key: createProductController.formFieldState_data,
//                       value: createProductController.sub_category_datass.any(
//                               (element) =>
//                                   element['name'] ==
//                                   createProductController
//                                       .subcategoryname_new.value)
//                           ? createProductController.subcategoryname_new.value
//                           : null,
//                       decoration: const InputDecoration(
//                         hintText: 'Select Sub Categories',
//                         labelText: 'Select Sub Categories',
//                         prefixIcon: Icon(Iconsax.bezier),
//                       ),
//                       onChanged: (newValue) {
//                         createProductController.subcategoryname.value =
//                             newValue!;
//                         for (var element
//                             in createProductController.sub_category_datass) {
//                           if (element['name'] == newValue) {
//                             createProductController.subcategoryid.value =
//                                 element['id'];
//                           }
//                         }
//                       },
//                       items: createProductController.sub_category_datass
//                           .map<DropdownMenuItem<String>>(
//                               (Map<String, dynamic> value) {
//                         return DropdownMenuItem<String>(
//                           value: value['name'].toString(),
//                           child: Text(value['name']),
//                         );
//                       }).toList(),
//                     )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class Edit_ProductParentCategories extends StatelessWidget {
  const Edit_ProductParentCategories({
    super.key,
    required this.product,
  });
  final ProductModel product;
  @override
  Widget build(BuildContext context) {
    // Get instance of the CategoryController

    final categoriesController = Get.put(CategoryController());
    final createProductController = Get.put(CreateProductController());

    // print("CheckData sub 1 ${categoriesController.allItems}");

    // Fetch categories if the list is empty
    // if (categoriesController.allItems.isEmpty) {
    //   categoriesController.fetchItems();
    // }
    // print("CheckData sub 2 ${categoriesController.allItems.length}");

    createProductController.subcategoryname.value = product.subCategoryName!;
    createProductController.subcategoryname_new.value =
        product.subCategoryName!;

    print("CheckData sub 3 ${createProductController.subcategoryname.value}");
    print("CheckData sub 4 ${createProductController.sub_category_datass}");
    print(
        "CheckData sub 5 ${createProductController.subcategoryname_new.value}");

    // print(
    //     "subcategoryname  select_category_id=  =${createProductController.select_category_id}");
    // print("subcategoryname =  =${createProductController.subcategoryname}");
    // print(
    //     "subcategoryname = value  =${createProductController.subcategoryname_new.value}");

    // print(
    //     "CheckData sub 4 ${createProductController.subcategoryname_new.value}");
    // print("CheckData sub 5 ${createProductController.sub_category_datass}");
    // // createProductController.sub_category_datass.value = [];
    // print(
    //     "CheckData sub 6 ${createProductController.sub_category_datass.length}");

    return Obx(
      () => Visibility(
        visible: CreateProductController.instance.sub_category_datass.isNotEmpty
            ? true
            : false,
        // visible: true,
        child: TRoundedContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories label
              Text('Sub Categories',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: TSizes.spaceBtwItems),

              // MultiSelectDialogField for selecting categories
              categoriesController.isLoading.value
                  ? const TShimmerEffect(width: double.infinity, height: 50)
                  : DropdownButtonFormField<String>(
                      // key: createProductController.formFieldState_data,
                      initialValue: createProductController
                                  .subcategoryname_new.value ==
                              "null"
                          ? null
                          : createProductController.subcategoryname_new.value,
                      decoration: const InputDecoration(
                          hintText: 'Select Sub Categories',
                          labelText: 'Select Sub Categories',
                          prefixIcon: Icon(Iconsax.bezier)),
                      onChanged: (newValue) {
                        createProductController.subcategoryname.value =
                            newValue!;
                        for (var element in createProductController.sub_category_datass) {
                            if (element['name'] == newValue) {
                              createProductController.subcategoryid.value =
                                  element['id'];
                            }
                          }
                        print(
                            "subb ${createProductController.subcategoryname_new.value}");
                      },
                      items: createProductController.sub_category_datass
                          .map<DropdownMenuItem<String>>(
                              (Map<String, dynamic> value) {
                        return DropdownMenuItem<String>(
                          value: value['name'].toString(),
                          child: Text(value['name']),
                        );
                      }).toList(),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
