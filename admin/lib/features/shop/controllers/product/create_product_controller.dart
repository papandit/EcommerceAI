// ignore_for_file: curly_braces_in_flow_control_structures, non_constant_identifier_names, prefer_final_fields, unused_field, avoid_print, unnecessary_brace_in_string_interps, unnecessary_null_in_if_null_operators

import 'package:cwt_ecommerce_admin_panel/features/shop/models/product_attribute_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import necessary controllers, models, and utility classes
import '../../../../data/repositories/product/product_repository.dart';
import '../../../../features/shop/controllers/product/product_attributes_controller.dart';
import '../../../../features/shop/controllers/product/product_controller.dart';
import '../../../../features/shop/controllers/product/product_images_controller.dart';
import '../../../../features/shop/controllers/product/product_variations_controller.dart';
import '../../../../features/shop/models/brand_model.dart';
import '../../../../features/shop/models/category_model.dart';
import '../../../../features/shop/models/product_category_model.dart';
import '../../../../features/shop/models/product_model.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';

class CreateProductController extends GetxController {
  // Singleton instance
  static CreateProductController get instance => Get.find();
  ProductController _productController = Get.put(ProductController());

  // Observables for loading state and product details
  final isLoading = false.obs;
  final productType = ProductType.single.obs;
  final productVisibility = ProductVisibility.hidden.obs;

  // Controllers and keys
  final stockPriceFormKey = GlobalKey<FormState>();
  final productRepository = Get.put(ProductRepository());
  final titleDescriptionFormKey = GlobalKey<FormState>();
  final linkFormKey = GlobalKey<FormState>();
  final formFieldState_data = GlobalKey<FormFieldState>();

  // Text editing controllers for input fields
  TextEditingController title = TextEditingController();
  TextEditingController stock = TextEditingController();
  TextEditingController sku = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController salePrice = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController brandTextField = TextEditingController();
  TextEditingController linkController = TextEditingController();
  RxList<Map<String, dynamic>> sub_category_datass =
      <Map<String, dynamic>>[].obs;
  String select_category_id = "";
  RxString select_category_name = ''.obs;
  RxString subcategoryname = "".obs;
  RxString subcategoryid = "null".obs;
  RxString subcategoryname_new = "".obs;
  String departmentname = "";
  String stockvalue = "InStock";

  List sub_category_data = [].obs;
  RxString selectedCategoriess = "".obs;
  // Rx observables for selected brand and categories
  final Rx<BrandModel?> selectedBrand = Rx<BrandModel?>(null);
  final Rx<CategoryModel?> selectedCategoriesId = Rx<CategoryModel?>(null);
  final RxList<CategoryModel> selectedCategories = <CategoryModel>[].obs;

  final RxList<CategoryModel> selectedSubCategories = <CategoryModel>[].obs;

  // Flags for tracking different tasks
  RxBool thumbnailUploader = false.obs;
  RxBool additionalImagesUploader = false.obs;
  RxBool productDataUploader = false.obs;
  RxBool categoriesRelationshipUploader = false.obs;

  // Function to create a new product
  Future<void> createProduct() async {
    try {
      // Show progress dialog
      showProgressDialog();

      List<String> colors_list = [];
      List<String> sizes_list = [];
      List<String> tags_list = [];

      for (var element in ProductAttributesController.instance.productAttributes) {
          if (element.name!.contains("Colors")) {
            print("Colors =name = ${element.name}");
            print("Colors =length = ${element.values!.length}");
            print("Colors = values= ${element.values!.first}");
            colors_list.addAll(element.values!);
          } else if (element.name!.contains("Sizes")) {
            sizes_list.addAll(element.values!);
          } else if (element.name!.contains("Tags")) {
            tags_list.addAll(element.values!);
          }
        }
      print("Colors =colors_list length = ${colors_list.length}");
      print("Colors =colors_list = ${colors_list}");

      print("Colors =sizes_list length = ${sizes_list.length}");
      print("Colors =sizes_list = ${sizes_list}");

      print("Colors =tags_list length = ${tags_list.length}");
      print("Colors =tags_list = ${tags_list}");

      List<ProductAttributeModel> final_productAttributes =
          <ProductAttributeModel>[];

      final_productAttributes
          .add(ProductAttributeModel(name: "Colors", values: colors_list));

      final_productAttributes
          .add(ProductAttributeModel(name: "Sizes", values: sizes_list));
      final_productAttributes
          .add(ProductAttributeModel(name: "Tags", values: tags_list));
      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validate title and description form
      if (titleDescriptionFormKey.currentState != null &&
          !titleDescriptionFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
            title: 'Incomplete details',
            message: 'Please add a product Title and Description.');
        return;
      }

      // Validate stock and pricing form if ProductType = Single
      if (productType.value == ProductType.single &&
          stockPriceFormKey.currentState != null &&
          !stockPriceFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
            title: 'Incomplete pricing',
            message:
                'Please select Stock and enter the Main Price in the Stock & Pricing section.');
        return;
      }

      // Sub-category is OPTIONAL — only some categories have sub-categories.
      // (The Sub Categories dropdown only appears when the chosen category
      // actually has sub-categories defined.)
      if (select_category_id.isEmpty)
        throw 'Select a Category for this product';
      if (departmentname == "") throw 'Select Department for this product';
      if (selectedBrand.value == null) throw 'Select Brand for this product';
      // if (linkController.text.isEmpty) throw 'Select Link for this product';

      // Ensure a brand is selected
      // if (selectedBrand.value == null) throw 'Select Brand for this product';

      // Check variation data if ProductType = Variable
      if (productType.value == ProductType.variable &&
          ProductVariationController.instance.productVariations.isEmpty) {
        throw 'There are no variations for the Product Type Variable. Create some variations or change Product type.';
      }
      if (productType.value == ProductType.variable) {
        final variationCheckFailed = ProductVariationController
            .instance.productVariations
            .any((element) =>
                element.price.isNaN ||
                element.price < 0 ||
                element.salePrice.isNaN ||
                element.salePrice < 0 ||
                element.stock.isNaN ||
                element.stock < 0 ||
                element.image.value.isEmpty);

        if (variationCheckFailed)
          throw 'Variation data is not accurate. Please recheck variations';
      }

      // Upload Product Thumbnail Image
      thumbnailUploader.value = true;
      final imagesController = ProductImagesController.instance;
      if (imagesController.selectedThumbnailImageUrl.value == null)
        throw 'Select Product Thumbnail Image';
      // A blob:/data: URL means the image preview is showing but the upload to
      // Firebase Storage never completed (usually because Storage rules are not
      // published). Saving it would create a product with a broken image.
      final _thumb = imagesController.selectedThumbnailImageUrl.value!;
      if (_thumb.startsWith('blob:') || _thumb.startsWith('data:'))
        throw 'Thumbnail upload did not finish. Please re-upload the image (and make sure Firebase Storage rules are published), then save.';

      // Additional Product Images
      additionalImagesUploader.value = true;

      // Product Variation Images
      final variations = ProductVariationController.instance.productVariations;
      if (productType.value == ProductType.single && variations.isNotEmpty) {
        // If admin added variations and then changed the Product Type, remove all variations
        ProductVariationController.instance.resetAllValues();
        variations.value = [];
      }

      // print("selectedBrand.value ${selectedBrand.value}");
      // print("selectedCategoriesId ${selectedCategoriesId.value!.id}");
      print("selectedCategoriesId check");
      print("selectedCategoriesId ${select_category_id}");
      print("selectedCategoriesName ${select_category_name}");
      // select_category_id;
      // Map Product Data to ProductModel

      final newRecord = ProductModel(
        id: '',
        sku: sku.text.trim(),
        isFeatured: true,
        stockvalue: stockvalue,
        title: title.text.trim(),
        brand: selectedBrand.value ?? null,
        productVariations: variations,
        description: description.text.trim(),
        productType: productType.value.toString(),
        stock: int.tryParse(stock.text.trim()) ?? 0,
        price: double.tryParse(price.text.trim()) ?? 0,
        images: imagesController.additionalProductImagesUrls,
        link: linkController.text.trim(),
        // salePrice stores the discount % derived from Main Price + Offer Price.
        salePrice: _discountPct(),
        thumbnail: imagesController.selectedThumbnailImageUrl.value ?? '',
        productAttributes: final_productAttributes,
        date: DateTime.now(),
        subCategoryName: subcategoryname.value,
        subCategoryId: subcategoryid.value,
        departmentname: departmentname,
        categoryId: select_category_id,
        categoryName: select_category_name.value,
        timestamp: DateTime.now().toIso8601String(),
      );
      print(":::timestamp${newRecord.timestamp}");
      // imagesController.additionalProductImagesUrls
      //     .add(linkController.text.trim());
      print("::Maya imageLink${imagesController.additionalProductImagesUrls}");
      print("newRecord = check");
      print(selectedSubCategories);
      print("newRecord = ${newRecord.toJson()}");
      // Call Repository to Create New Product
      productDataUploader.value = true;
      newRecord.id = await ProductRepository.instance.createProduct(newRecord);

      // Register product categories if any
      if (selectedCategories.isNotEmpty) {
        if (newRecord.id.isEmpty) throw 'Error storing data. Try again';

        // Loop through selected Product Categories
        categoriesRelationshipUploader.value = true;
        for (var category in selectedCategories) {
          // Map Data
          final productCategory = ProductCategoryModel(
              productId: newRecord.id, categoryId: category.id);
          await ProductRepository.instance
              .createProductCategory(productCategory);
        }
      }

      // Update Product List
      _productController.addItemToLists(newRecord);

      // // Update UI Listeners
      update();

      // Reset Form
      resetValues();

      // Close the Progress Loader
      TFullScreenLoader.stopLoading();
      // Success popup → then redirect to All Products.
      _showSuccessAndRedirect();
    } catch (e) {
      print("E = ${e}");
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  // Reset form values and flags
  void resetValues() {
    isLoading.value = false;
    productType.value = ProductType.single;
    productVisibility.value = ProductVisibility.hidden;
    stockPriceFormKey.currentState?.reset();
    titleDescriptionFormKey.currentState?.reset();
    title.clear();
    description.clear();
    sku.clear();
    stock.clear();
    price.clear();
    salePrice.clear();
    brandTextField.clear();
    selectedBrand.value = null;
    selectedCategories.clear();
    sub_category_datass.clear();
    subcategoryname.value = "";
    subcategoryid.value = "null";
    departmentname = "";
    select_category_id = "";
    select_category_name = "".obs;
    ProductVariationController.instance.resetAllValues();
    ProductAttributesController.instance.resetProductAttributes();

    // Reset Upload Flags
    thumbnailUploader.value = false;
    additionalImagesUploader.value = false;
    productDataUploader.value = false;
    categoriesRelationshipUploader.value = false;
  }

  // Show the progress dialog
  void showProgressDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Creating Product'),
          content: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(TImages.creatingProductIllustration,
                    height: 200, width: 200),
                const SizedBox(height: TSizes.spaceBtwItems),
                buildCheckbox('Thumbnail Image', thumbnailUploader),
                buildCheckbox('Additional Images', additionalImagesUploader),
                buildCheckbox('Product Data, Attributes & Variations',
                    productDataUploader),
                buildCheckbox(
                    'Product Categories', categoriesRelationshipUploader),
                const SizedBox(height: TSizes.spaceBtwItems),
                const Text('Sit Tight, Your product is uploading...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build a checkbox widget
  Widget buildCheckbox(String label, RxBool value) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(seconds: 2),
          child: value.value
              ? const Icon(CupertinoIcons.checkmark_alt_circle_fill,
                  color: Colors.blue)
              : const Icon(CupertinoIcons.checkmark_alt_circle),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        Text(label),
      ],
    );
  }

  /// Discount % derived from Main Price (price) and Offer Price (salePrice
  /// field is reused as the offer-price input).
  double _discountPct() {
    final mrp = double.tryParse(price.text.trim()) ?? 0;
    final offer = double.tryParse(salePrice.text.trim()) ?? 0;
    if (mrp > 0 && offer > 0 && offer < mrp) {
      return double.parse((((mrp - offer) / mrp) * 100).toStringAsFixed(2));
    }
    return 0.0;
  }

  /// Success popup, then redirect to the All Products list.
  void _showSuccessAndRedirect() {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                color: Color(0xff2E8B57), size: 64),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text('Uploaded Successfully',
                style: Theme.of(Get.context!).textTheme.headlineSmall),
            const SizedBox(height: TSizes.sm),
            const Text('Your product has been created.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offNamed(TRoutes.products);
            },
            child: const Text('Go to All Products'),
          ),
        ],
      ),
    );
  }

  // Show completion dialog
  // void showCompletionDialog() {
  //   Get.dialog(
  //     AlertDialog(
  //       title: const Text('Congratulations'),
  //       actions: [
  //         TextButton(
  //             onPressed: () {
  //               Get.back();
  //               Get.back();
  //               // Get.back();
  //               // Get.back();
  //             },
  //             child: const Text('Go to Products'))
  //       ],
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Image.asset(TImages.productsIllustration, height: 200, width: 200),
  //           const SizedBox(height: TSizes.spaceBtwItems),
  //           Text('Congratulations',
  //               style: Theme.of(Get.context!).textTheme.headlineSmall),
  //           const SizedBox(height: TSizes.spaceBtwItems),
  //           const Text('Your Product has been Created'),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  void showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Congratulations'),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('Go to Products'))
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(TImages.productsIllustration, height: 200, width: 200),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text('Congratulations',
                style: Theme.of(Get.context!).textTheme.headlineSmall),
            const SizedBox(height: TSizes.spaceBtwItems),
            const Text('Your Product has been Created'),
          ],
        ),
      ),
    );
  }
}
