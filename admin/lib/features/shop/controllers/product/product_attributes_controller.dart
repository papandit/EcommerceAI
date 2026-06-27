import 'package:cwt_ecommerce_admin_panel/utils/popups/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/product_attribute_model.dart';
import 'product_variations_controller.dart';

class ProductAttributesController extends GetxController {
  static ProductAttributesController get instance => Get.find();

  // Observables for loading state, form key, and product attributes
  final isLoading = false.obs;
  final attributesFormKey = GlobalKey<FormState>();
  final attributesFormKeysizes = GlobalKey<FormState>();
  final attributesFormKeycolors = GlobalKey<FormState>();
  TextEditingController attributeName = TextEditingController();
  TextEditingController attributes = TextEditingController();
  TextEditingController sizes_attributes = TextEditingController();
  TextEditingController colors_attributes = TextEditingController();
  final RxList<ProductAttributeModel> productAttributes =
      <ProductAttributeModel>[].obs;

  // Function to add a new attribute
  // void addNewAttribute() {
  //   // Form Validation
  //   print("fgfg");
  //   if (!attributesFormKey.currentState!.validate()) {
  //     return;
  //   }

  //   // Add Attributes to the List of Attributes
  //   productAttributes.add(ProductAttributeModel(
  //       name: attributeName.text.trim(),
  //       values: attributes.text.trim().split('|').toList()));
  //   print("aaa${attributes.text.trim().split('|')}");
  //   // Clear text fields after adding
  //   attributeName.text = '';
  //   attributes.text = '';
  // }

  void addNewAttribute() {
    // Form Validation
    if (!attributesFormKey.currentState!.validate()) {
      return;
    }

    // Extract only the color codes from the attributes
    List<String> attributeValues = attributes.text.trim().split('|').map((e) {
      // Use a regular expression to extract the color code
      final match = RegExp(r'0x[0-9A-Fa-f]{8}').firstMatch(e);
      print("e = =$e");
      if (match != null) {
        return match.group(0)!;
      } else {
        return e.trim();
      }
    }).toList();
    String tagss = "";
    final match =
        RegExp(r'0x[0-9A-Fa-f]{8}').firstMatch(attributes.text.trim());
    if (match != null) {
      tagss = match.group(0)!;
    } else {
      tagss = attributes.text.trim();
    }

    print("etagss= =$tagss");

    bool isDatain = false;

    if (productAttributes.isNotEmpty) {
      productAttributes.asMap().forEach(
        (index, element) {
          if (element.name!.contains("Tags")) {
            isDatain = true;
            print("element = = ${element.name}");
            print("element = values= ${element.values}");

            productAttributes[index].values!.add(tagss);

            productAttributes[index] = ProductAttributeModel(
                name: productAttributes[index].name,
                values: productAttributes[index].values);
            print("element = valuessss= ${productAttributes[index].values}");
          } else {
            if (!isDatain) {
              isDatain = false;
            }
          }
        },
      );
    }

    if (!isDatain || productAttributes.isEmpty) {
      productAttributes
          .add(ProductAttributeModel(name: "Tags", values: attributeValues));
    }

    // productAttributes
    //     .add(ProductAttributeModel(name: "Tags", values: attributeValues));

    // Debugging output
    print("aaa$attributeValues");

    // Clear text fields after adding
    attributeName.text = '';
    attributes.text = '';
  }

  void addNewsizes() {
    // Form Validation
    if (!attributesFormKeysizes.currentState!.validate()) {
      return;
    }

    // Extract only the color codes from the attributes
    List<String> attributeValues =
        sizes_attributes.text.trim().split('|').map((e) {
      // Use a regular expression to extract the color code
      final match = RegExp(r'0x[0-9A-Fa-f]{8}').firstMatch(e);
      if (match != null) {
        return match.group(0)!;
      } else {
        return e.trim();
      }
    }).toList();

    String sizess = "";
    final match =
        RegExp(r'0x[0-9A-Fa-f]{8}').firstMatch(sizes_attributes.text.trim());
    if (match != null) {
      sizess = match.group(0)!;
    } else {
      sizess = sizes_attributes.text.trim();
    }

    bool isDatain = false;

    if (productAttributes.isNotEmpty) {
      productAttributes.asMap().forEach(
        (index, element) {
          if (element.name!.contains("Sizes")) {
            isDatain = true;
            print("element = = ${element.name}");
            print("element = values= ${element.values}");

            productAttributes[index].values!.add(sizess);

            productAttributes[index] = ProductAttributeModel(
                name: productAttributes[index].name,
                values: productAttributes[index].values);
            print("element = valuessss= ${productAttributes[index].values}");
          } else {
            if (!isDatain) {
              isDatain = false;
            }
          }
        },
      );
    }

    if (!isDatain || productAttributes.isEmpty) {
      productAttributes
          .add(ProductAttributeModel(name: "Sizes", values: attributeValues));
    }

    // productAttributes
    //     .add(ProductAttributeModel(name: "Sizes", values: attributeValues));

    // Debugging output
    print("aaa$attributeValues");

    // Clear text fields after adding
    attributeName.text = '';
    sizes_attributes.text = '';
  }

  void addNewColor() {
    // Form Validation
    if (!attributesFormKeycolors.currentState!.validate()) {
      return;
    }

    // Extract only the color codes from the attributes
    List<String> attributeValues =
        colors_attributes.text.trim().split('|').map((e) {
      // Use a regular expression to extract the color code
      print("e = =$e");
      final match = RegExp(r'0x[0-9A-Fa-f]{8}').firstMatch(e);
      if (match != null) {
        print("match = ${match.group(0)}");
        return match.group(0)!;
      } else {
        print("e = ${e.trim()}");
        return e.trim();
      }
    }).toList();
    final match =
        RegExp(r'0x[0-9A-Fa-f]{8}').firstMatch(colors_attributes.text.trim());
    String Colors = match!.group(0)!;

    bool isDatain = false;

    if (productAttributes.isNotEmpty) {
      productAttributes.asMap().forEach(
        (index, element) {
          if (element.name!.contains("Colors")) {
            isDatain = true;
            print("element = = ${element.name}");
            print("element = values= ${element.values}");

            productAttributes[index].values!.add(Colors);

            productAttributes[index] = ProductAttributeModel(
                name: productAttributes[index].name,
                values: productAttributes[index].values);
            print("element = valuessss= ${productAttributes[index].values}");
          } else {
            if (!isDatain) {
              isDatain = false;
            }
          }
        },
      );
    }

    if (!isDatain || productAttributes.isEmpty) {
      productAttributes
          .add(ProductAttributeModel(name: "Colors", values: attributeValues));
    }

    // Debugging output
    print("aaa$attributeValues");
    print("aaa sd $productAttributes");

    colors_attributes.text = '';
  }

  // Function to remove an attribute
  void removeAttribute(int index, BuildContext context) {
    // Show a confirmation dialog
    TDialogs.defaultDialog(
      context: context,
      onConfirm: () {
        // User confirmed, remove the attribute
        Navigator.of(context).pop();
        productAttributes.removeAt(index);

        // Reset productVariations when removing an attribute
        ProductVariationController.instance.productVariations.value = [];
      },
    );
  }

  void remove_array_item_Attribute(
      int index, int indexIn, BuildContext context) {
    // Show a confirmation dialog
    print("Click = One");
    TDialogs.defaultDialog(
      context: context,
      onConfirm: () {
        // User confirmed, remove the attribute
        Navigator.of(context).pop();
        productAttributes[index].values!.removeAt(indexIn);
        print("Click = two");
        productAttributes[index] = ProductAttributeModel(
            name: productAttributes[index].name,
            values: productAttributes[index].values);

        // Reset productVariations when removing an attribute
        ProductVariationController.instance.productVariations.value = [];

        print("Click =thre ${productAttributes[index].values}");
      },
    );
  }

  // ── Preset size chips (select instead of typing) ────────────────────────
  // Clothing sizes.
  static const List<String> presetSizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    'XXXL'
  ];

  // Footwear sizes (EU / India women's numeric).
  static const List<String> presetFootwearSizes = [
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12'
  ];

  // Footwear sizes (UK women's) — stored with a "UK " prefix so they stay
  // distinct from the numeric EU/India sizes above.
  static const List<String> presetFootwearUKSizes = [
    'UK 2',
    'UK 3',
    'UK 4',
    'UK 5',
    'UK 6',
    'UK 7',
    'UK 8',
    'UK 9'
  ];

  int _sizesIndex() =>
      productAttributes.indexWhere((e) => (e.name ?? '').contains('Sizes'));

  bool isSizeSelected(String size) {
    final i = _sizesIndex();
    return i != -1 && (productAttributes[i].values ?? []).contains(size);
  }

  /// Toggle a preset size on/off in the "Sizes" attribute.
  void toggleSize(String size) {
    final i = _sizesIndex();
    if (i == -1) {
      productAttributes
          .add(ProductAttributeModel(name: 'Sizes', values: [size]));
    } else {
      final vals = List<String>.from(productAttributes[i].values ?? []);
      vals.contains(size) ? vals.remove(size) : vals.add(size);
      if (vals.isEmpty) {
        productAttributes.removeAt(i);
      } else {
        productAttributes[i] =
            ProductAttributeModel(name: 'Sizes', values: vals);
      }
    }
    productAttributes.refresh();
  }

  // Function to reset productAttributes
  void resetProductAttributes() {
    productAttributes.clear();
  }
}
