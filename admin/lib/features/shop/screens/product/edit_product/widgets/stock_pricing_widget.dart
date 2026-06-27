import 'package:cwt_ecommerce_admin_panel/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../controllers/product/edit_product_controller.dart';

class ProductStockAndPricing extends StatelessWidget {
  const ProductStockAndPricing({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = EditProductController.instance;

    return Obx(
      () => controller.productType.value == ProductType.single
          ? Form(
              key: controller.stockPriceFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stock
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.sku,
                          decoration: const InputDecoration(
                              labelText: 'SKU', hintText: 'Add SKU'),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: TSizes.spaceBtwItems),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.stockvalue.isEmpty
                              ? null
                              : controller.stockvalue,
                          validator: (value) {
                            print("value = $value");
                            return TValidator.validateEmptyText(
                                "Weight Type", value);
                          },
                          decoration: const InputDecoration(
                              hintText: 'Stock',
                              labelText: 'Stock',
                              prefixIcon: Icon(Iconsax.bezier)),
                          onChanged: (newValue) {
                            //createProductController.departmentname = newValue!;
                            print("newValue = =$newValue");
                            controller.stockvalue = newValue!;
                            print(
                                "attributeController = =${controller.stockvalue}");
                          },
                          items: controller.instockKey
                              .map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      // Expanded(
                      //   child: TextFormField(
                      //     controller: controller.stock,
                      //     decoration: const InputDecoration(
                      //         labelText: 'Stock',
                      //         hintText: 'Add Stock, only numbers are allowed'),
                      //     validator: (value) =>
                      //         TValidator.validateEmptyText('Stock', value),
                      //     keyboardType: TextInputType.number,
                      //     inputFormatters: <TextInputFormatter>[
                      //       FilteringTextInputFormatter.digitsOnly
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  // FractionallySizedBox(
                  //   widthFactor: 0.45,
                  //   child: TextFormField(
                  //     controller: controller.stock,
                  //     decoration: const InputDecoration(labelText: 'Stock'),
                  //     validator: (value) =>
                  //         TValidator.validateEmptyText('Stock', value),
                  //   ),
                  // ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  // Pricing: Main Price (MRP) + Offer Price => auto Discount %
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Main Price (MRP)
                          Expanded(
                            child: TextFormField(
                              controller: controller.price,
                              decoration: const InputDecoration(
                                  labelText: 'Main Price (MRP)',
                                  hintText: '₹ e.g. 2500'),
                              validator: (value) =>
                                  TValidator.validateEmptyText(
                                      'Main Price', value),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}$')),
                              ],
                            ),
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          // Offer Price
                          Expanded(
                            child: TextFormField(
                              controller: controller.salePrice,
                              decoration: const InputDecoration(
                                  labelText: 'Offer Price',
                                  hintText: '₹ e.g. 1000'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}$')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      AnimatedBuilder(
                        animation: Listenable.merge(
                            [controller.price, controller.salePrice]),
                        builder: (context, _) {
                          final mrp =
                              double.tryParse(controller.price.text.trim()) ?? 0;
                          final offer = double.tryParse(
                                  controller.salePrice.text.trim()) ??
                              0;
                          if (mrp <= 0 || offer <= 0 || offer >= mrp) {
                            return const SizedBox.shrink();
                          }
                          final pct = ((mrp - offer) / mrp * 100).round();
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'Discount: $pct% OFF   •   You save ₹${(mrp - offer).toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Color(0xff2E8B57),
                                  fontWeight: FontWeight.w600),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
