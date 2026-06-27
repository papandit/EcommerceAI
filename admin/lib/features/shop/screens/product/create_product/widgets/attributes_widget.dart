// ignore_for_file: prefer_const_constructors

import 'package:cwt_ecommerce_admin_panel/common/widgets/images/t_rounded_image.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/create_product_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/product_attributes_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/product_variations_controller.dart';
import 'package:cwt_ecommerce_admin_panel/utils/device/device_utility.dart';
import 'package:cwt_ecommerce_admin_panel/utils/validators/validation.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/image_strings.dart';
import '../../../../../../utils/constants/sizes.dart';

class ProductAttributes extends StatelessWidget {
  ProductAttributes({
    super.key,
  });

  // Controllers
  final attributeController = Get.put(ProductAttributesController());
  final variationController = Get.put(ProductVariationController());

  @override
  Widget build(BuildContext context) {
    final productController = CreateProductController.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider based on product type
        Obx(() => productController.productType.value == ProductType.single
            ? const Divider(color: TColors.primaryBackground)
            : const SizedBox.shrink()),
        Obx(() => productController.productType.value == ProductType.single
            ? const SizedBox(height: TSizes.spaceBtwSections)
            : const SizedBox.shrink()),

        Text('Add Product Attributes',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Form to add new attribute
        Form(
          key: attributeController.attributesFormKey,
          child: TDeviceUtils.isDesktopScreen(context)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text('Add Product Tags',
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Expanded(
                      flex: 2,
                      child: _buildAttributes(attributeController, context),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    _buildAddAttributeButton(attributeController),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text('Add Product Tags',
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    _buildAttributes(attributeController, context),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    _buildAddAttributeButton(attributeController),
                  ],
                ),
        ),
        const SizedBox(height: TSizes.spaceBtwSections),

        Form(
          key: attributeController.attributesFormKeysizes,
          child: TDeviceUtils.isDesktopScreen(context)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text('Add Product Sizes',
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Expanded(
                      flex: 2,
                      child:
                          _builSizes_Attributes(attributeController, context),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    _buildAddSizesButton(attributeController),
                  ],
                )
              : Column(
                  children: [
                    Text('Add Product Sizes',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    _builSizes_Attributes(attributeController, context),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    _buildAddSizesButton(attributeController),
                  ],
                ),
        ),
        const SizedBox(height: TSizes.spaceBtwSections),

        Form(
          key: attributeController.attributesFormKeycolors,
          child: TDeviceUtils.isDesktopScreen(context)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text('Add Product Colors',
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Expanded(
                      flex: 2,
                      child:
                          _buildColors_Attributes(attributeController, context),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    _buildAddColorsButton(attributeController),
                  ],
                )
              : Column(
                  children: [
                    // _buildAttributeName(attributeController),
                    Text('Add Product Colors',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    _buildColors_Attributes(attributeController, context),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    _buildAddColorsButton(attributeController),
                  ],
                ),
        ),
        const SizedBox(height: TSizes.spaceBtwSections),
        // List of added attributes
        Text('All Attributes',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Display added attributes in a rounded container
        TRoundedContainer(
          backgroundColor: TColors.primaryBackground,
          child: Obx(
            () => attributeController.productAttributes.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    itemCount: attributeController.productAttributes.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: TSizes.spaceBtwItems),
                    itemBuilder: (_, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: TColors.white,
                          borderRadius:
                              BorderRadius.circular(TSizes.borderRadiusLg),
                        ),
                        child: ListTile(
                          title: Text(attributeController
                                  .productAttributes[index].name ??
                              ''),
                          subtitle: ListView.separated(
                              shrinkWrap: true,
                              itemCount: attributeController
                                  .productAttributes[index].values!.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: TSizes.spaceBtwItems),
                              itemBuilder: (_, indexIn) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        print("Click = ");
                                        attributeController
                                            .remove_array_item_Attribute(
                                                index, indexIn, context);
                                      },
                                      icon: const Icon(Iconsax.close_square,
                                          color: TColors.grey),
                                    ),
                                    Text(attributeController
                                        .productAttributes[index]
                                        .values![indexIn]
                                        .toString()),
                                  ],
                                );
                              }),
                          trailing: IconButton(
                            onPressed: () => attributeController
                                .removeAttribute(index, context),
                            icon:
                                const Icon(Iconsax.trash, color: TColors.error),
                          ),
                        ),
                      );
                    },
                  )
                : const Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TRoundedImage(
                              width: 150,
                              height: 80,
                              imageType: ImageType.asset,
                              image: TImages.defaultAttributeColorsImageIcon),
                        ],
                      ),
                      SizedBox(height: TSizes.spaceBtwItems),
                      Text('There are no attributes added for this product'),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: TSizes.spaceBtwSections),

        // Generate Variations Button
        Obx(
          () => productController.productType.value == ProductType.variable &&
                  variationController.productVariations.isEmpty
              ? Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      icon: const Icon(Iconsax.activity),
                      label: const Text('Generate Variations'),
                      onPressed: () => variationController
                          .generateVariationsConfirmation(context),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  SizedBox _buildAddSizesButton(ProductAttributesController controller) {
    return SizedBox(
      width: 100,
      child: ElevatedButton.icon(
        onPressed: () {
          controller.addNewsizes();
        },
        icon: const Icon(Iconsax.add),
        style: ElevatedButton.styleFrom(
          foregroundColor: TColors.black,
          backgroundColor: TColors.secondary,
          side: const BorderSide(color: TColors.secondary),
        ),
        label: const Text('Add'),
      ),
    );
  }

  // Build button to add a new attribute
  SizedBox _buildAddAttributeButton(ProductAttributesController controller) {
    return SizedBox(
      width: 100,
      child: ElevatedButton.icon(
        onPressed: () {
          controller.addNewAttribute();
        },
        icon: const Icon(Iconsax.add),
        style: ElevatedButton.styleFrom(
          foregroundColor: TColors.black,
          backgroundColor: TColors.secondary,
          side: const BorderSide(color: TColors.secondary),
        ),
        label: const Text('Add'),
      ),
    );
  }

  SizedBox _buildAddColorsButton(ProductAttributesController controller) {
    return SizedBox(
      width: 100,
      child: ElevatedButton.icon(
        onPressed: () {
          controller.addNewColor();
        },
        icon: const Icon(Iconsax.add),
        style: ElevatedButton.styleFrom(
          foregroundColor: TColors.black,
          backgroundColor: TColors.secondary,
          side: const BorderSide(color: TColors.secondary),
        ),
        label: const Text('Add'),
      ),
    );
  }

  // Build text form field for attribute name
  TextFormField _buildAttributeName(ProductAttributesController controller) {
    return TextFormField(
      controller: controller.attributeName,
      validator: (value) =>
          TValidator.validateEmptyText('Attribute Name', value),
      decoration: const InputDecoration(
          labelText: 'Attribute Name', hintText: 'Sizes, Tags'),
    );
  }

  // Build text form field for attribute values
  SizedBox _buildAttributes(ProductAttributesController controller, context) {
    // Color selectedColor;
    return SizedBox(
      height: 80,
      child: TextFormField(
        expands: true,
        maxLines: null,
        textAlign: TextAlign.start,
        controller: controller.attributes,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        validator: (value) =>
            TValidator.validateEmptyText('Attributes Field', value),
        decoration: InputDecoration(
          labelText: 'Add Tags',
          hintText: 'Add attributes separated by |  Example: Best | Super',
          alignLabelWithHint: true,
          // suffixIcon: IconButton(
          //     onPressed: () {
          //       colorPickerDialog(controller, context);
          //     },
          //     icon: Icon(Icons.color_lens))
        ),
      ),
    );
  }

  Widget _sizeChip(ProductAttributesController controller, String s) {
    final sel = controller.isSizeSelected(s);
    return InkWell(
      onTap: () => controller.toggleSize(s),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: sel ? Colors.black : TColors.borderPrimary),
        ),
        child: Text(
          s,
          style: TextStyle(
              color: sel ? Colors.white : TColors.textPrimary,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _builSizes_Attributes(
      ProductAttributesController controller, context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Clothing sizes — tap to select (no typing needed).
        const Text('Clothing Sizes',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: TSizes.sm),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ProductAttributesController.presetSizes
                .map((s) => _sizeChip(controller, s))
                .toList(),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        // Footwear sizes.
        const Text('Footwear Sizes',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: TSizes.sm),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ProductAttributesController.presetFootwearSizes
                .map((s) => _sizeChip(controller, s))
                .toList(),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        // Footwear sizes (UK).
        const Text('Footwear Sizes (UK)',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: TSizes.sm),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ProductAttributesController.presetFootwearUKSizes
                .map((s) => _sizeChip(controller, s))
                .toList(),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        // Optional: still allow typing custom sizes separated by |
        SizedBox(
          height: 70,
          child: TextFormField(
            expands: true,
            maxLines: null,
            textAlign: TextAlign.start,
            controller: controller.sizes_attributes,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              labelText: 'Custom Sizes (optional)',
              hintText: 'Type custom sizes separated by |  e.g. Free | 28 | 30',
              alignLabelWithHint: true,
            ),
          ),
        ),
      ],
    );
  }

  SizedBox _buildColors_Attributes(
      ProductAttributesController controller, context) {
    // Color selectedColor;
    return SizedBox(
      height: 80,
      child: TextFormField(
        expands: true,
        maxLines: null,
        readOnly: true,
        textAlign: TextAlign.start,
        controller: controller.colors_attributes,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        onTap: () {
          colorPickerDialog(controller, context);
        },
        validator: (value) =>
            TValidator.validateEmptyText('Attributes Field', value),
        decoration: InputDecoration(
            labelText: 'Select Colors',
            hintText: 'Add Colors attributes',
            alignLabelWithHint: true,
            suffixIcon: IconButton(
                onPressed: () {
                  colorPickerDialog(controller, context);
                },
                icon: Icon(Icons.color_lens))),
      ),
    );
  }

  Future<bool> colorPickerDialog(
      ProductAttributesController controller, context) async {
    return ColorPicker(
      onColorChanged: (value) {
        // Fetch color name and code
        // String colorNameAndCode = ColorTools.materialNameAndARGBCode(value);
        // String colorNameAndCode = ColorTools.materialName(value);
        String colorNameAndCode = ColorTools.materialNameAndCode(value);
        // controller.attributes.text = value.toString();
        // Set the text field with the color name and code
        controller.colors_attributes.text = colorNameAndCode;
        // print(colorNameAndCode);
      },
      // onColorChanged: (value) {
      //   controller.attributes.text = value.toString();
      //   print(value);
      // },
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
      // customColorSwatchesAndNames: colorsNameMap,
    ).showPickerDialog(
      context,
      // New in version 3.0.0 custom transitions support.
      transitionBuilder: (BuildContext context, Animation<double> a1,
          Animation<double> a2, Widget widget) {
        final double curvedValue =
            Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }


}
