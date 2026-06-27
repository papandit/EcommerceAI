import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/create_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../controllers/brand/brand_controller.dart';

class ProductBrand extends StatelessWidget {
  const ProductBrand({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Get instances of controllers
    final controller = Get.put(CreateProductController());
    final brandController = Get.put(BrandController());

    // Fetch brands if the list is empty
    if (brandController.allItems.isEmpty) {
      brandController.fetchItems();
    }

    return TRoundedContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand label
          Text('Brand', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: TSizes.spaceBtwItems),

          // TypeAheadField for brand selection
          Obx(
            () => brandController.isLoading.value
                ? const TShimmerEffect(width: double.infinity, height: 50)
                : TypeAheadField(
                    builder: (context, ctr, focusNode) {
                      return TextFormField(
                        focusNode: focusNode,
                        controller: controller.brandTextField = ctr,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Select Brand',
                          suffixIcon: Icon(Iconsax.box),
                        ),
                      );
                    },
                    suggestionsCallback: (pattern) {
                      // Return filtered brand suggestions based on the search pattern
                      return brandController.allItems
                          .where((brand) => brand.name.contains(pattern))
                          .toList();
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion.name),
                      );
                    },
                    onSelected: (suggestion) {
                      controller.selectedBrand.value = suggestion;
                      controller.brandTextField.text = suggestion.name;
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
