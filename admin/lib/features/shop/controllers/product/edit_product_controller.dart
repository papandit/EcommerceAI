// ignore_for_file: non_constant_identifier_names

import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/category/category_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/create_product_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

class EditProductController extends GetxController {
  // Singleton instance
  List instockKey = ["InStock", "OutStock"];

  static EditProductController get instance => Get.find();
  final createproductcontroller = Get.put(CreateProductController());
  // Observables for loading state and product details
  final isLoading = false.obs;
  final selectedCategoriesLoader = false.obs;
  final productType = ProductType.single.obs;
  final productVisibility = ProductVisibility.hidden.obs;

  // Controllers and keys
  final variationsController = Get.put(ProductVariationController());
  final attributesController = Get.put(ProductAttributesController());
  final imagesController = Get.put(ProductImagesController());
  final productRepository = Get.put(ProductRepository());
  final stockPriceFormKey = GlobalKey<FormState>();
  final titleDescriptionFormKey = GlobalKey<FormState>();
  final linkFormKey = GlobalKey<FormState>();

  // Text editing controllers for input fields
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController sku = TextEditingController();
  TextEditingController stock = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController salePrice = TextEditingController();
  TextEditingController brandTextField = TextEditingController();
  TextEditingController linkTextField = TextEditingController();
  List sub_category_data = [].obs;

  // Rx observables for selected brand and categories
  final Rx<BrandModel?> selectedBrand = Rx<BrandModel?>(null);
  final RxList<CategoryModel> selectedCategories = <CategoryModel>[].obs;
  final List<CategoryModel> alreadyAddedCategories = <CategoryModel>[];

  // Flags for tracking different tasks
  RxBool thumbnailUploader = true.obs;
  RxBool productDataUploader = false.obs;
  RxBool additionalImagesUploader = true.obs;
  RxBool categoriesRelationshipUploader = false.obs;
  String departmentname = "";
  String stockvalue = "InStock";

  var data;
  // Initialize Product Data
  void initProductData(ProductModel product) {
    try {
      isLoading.value = true; // Set loading state while initializing data

      // Basic Information
      title.text = product.title;
      description.text = product.description ?? '';
      linkTextField.text = product.link ?? '';
      stockvalue = product.stockvalue ?? '';
      sku.text = product.sku ?? '';
      productType.value = product.productType == ProductType.single.toString()
          ? ProductType.single
          : ProductType.variable;

      // Stock & Pricing (assuming productType and productVisibility are handled elsewhere)
      if (product.productType == ProductType.single.toString()) {
        stock.text = product.sku.toString();
        stock.text = product.stock.toString();
        price.text = product.price.toString();
        // salePrice field is reused as the OFFER PRICE. Derive it from the
        // stored discount % so editing shows the actual selling price.
        final double mrpInit = double.tryParse(product.price.toString()) ?? 0;
        final double pctInit =
            double.tryParse(product.salePrice.toString()) ?? 0;
        salePrice.text = (mrpInit > 0 && pctInit > 0)
            ? (mrpInit - (mrpInit * pctInit / 100)).toStringAsFixed(0)
            : '';
      }

      // Product Brand
      selectedBrand.value = product.brand;
      brandTextField.text = product.brand?.name ?? '';

      data = product.categoryId ?? "";
      // Product Thumbnail and Images
      if (product.images != null) {
        // Set the first image as the thumbnail
        imagesController.selectedThumbnailImageUrl.value = product.thumbnail;

        // Add the images to additionalProductImagesUrl
        imagesController.additionalProductImagesUrls
            .assignAll(product.images ?? []);
      }

      // Product Attributes & Variations (assuming you have a method to fetch variations in ProductVariationController)
      attributesController.productAttributes
          .assignAll(product.productAttributes ?? []);
      variationsController.productVariations
          .assignAll(product.productVariations ?? []);
      variationsController
          .initializeVariationControllers(product.productVariations ?? []);

      isLoading.value =
          false; // Set loading state back to false after initialization

      update();
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchOrderDetails();
  }

  RxBool loading = true.obs;
  Rx<ProductModel> product = ProductModel.empty().obs;

  /// Fetch order details by orderId from URL
  Future<void> fetchOrderDetails() async {
    try {
      loading.value = true;

      // Get orderId from URL parameters
      String? orderId = Get.parameters['productId'];
      if (orderId == null) {
        TLoaders.errorSnackBar(title: "Error", message: "Order ID not found!");
        return;
      }

      // Fetch order details
      final fetchedOrder = await productRepository.getOrderById(orderId);
      if (fetchedOrder != null) {
        product.value = fetchedOrder;
      } else {
        TLoaders.errorSnackBar(title: "Error", message: "Order not found!");
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap!", message: e.toString());
    } finally {
      loading.value = false;
    }
  }

  Future<List<CategoryModel>> loadSelectedCategories(String productId) async {
    selectedCategoriesLoader.value = true;
    // Product Categories
    print("//product Id$productId");
    final productCategories =
        await productRepository.getProductCategories(productId);

    print("productCategories$productCategories");

    final categoriesController = Get.put(CategoryController());
    print("aaa");

    // if (categoriesController.allItems.isEmpty) {
    //   print("bbb");

    //   await categoriesController.fetchItems();
    //   print("111");
    // }
    // if (categoriesController.allItems.isEmpty)
    await categoriesController.fetchItems();
    print("cccc");

    final categoriesIds = productCategories.map((e) => e.categoryId).toList();
    print("categoriesIds$categoriesIds");
    final categories = categoriesController.allItems
        .where((element) => categoriesIds.contains(element.id))
        .toList();
    print("//categories$categories");
    selectedCategories.assignAll(categories);
    alreadyAddedCategories.assignAll(categories);
    selectedCategoriesLoader.value = false;
    print("33categories$categories");

    return categories;
  }

  // Function to create a new product
  Future<void> editProduct(ProductModel product) async {
    try {
      // Show progress dialog
      showProgressDialog();
//===================================================================================

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validate title and description form
      if (!titleDescriptionFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validate stock and pricing form if ProductType = Single
      if (productType.value == ProductType.single &&
          !stockPriceFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Ensure a brand is selected
      // if (selectedBrand.value == null) throw 'Select Brand for this product';

      // Check variation data if ProductType = Variable
      if (productType.value == ProductType.variable &&
          ProductVariationController.instance.productVariations.isEmpty) {
        throw 'There are no variations for the Product Type Variable. Create some variations or change Product type.';
      }
      if (productType.value == ProductType.variable) {
        final variationCheckFailed =
            ProductVariationController.instance.productVariations.any(
          (element) =>
              element.price.isNaN ||
              element.price < 0 ||
              element.salePrice.isNaN ||
              element.salePrice < 0 ||
              element.stock.isNaN ||
              element.stock < 0,
        );

        if (variationCheckFailed) {
          throw 'Variation data is not accurate. Please recheck variations';
        }
      }

      // if (createproductcontroller.select_category_id == "")
      //   throw 'Select Category for this product';

      print("subb new = = ${createproductcontroller.subcategoryname}");
      // Sub-category is optional (only some categories have sub-categories).
// createproductcontroller.sub_category_datass.isEmpty
      // Upload Product Thumbnail Image
      final imagesController = ProductImagesController.instance;
      if (imagesController.selectedThumbnailImageUrl.value == null ||
          imagesController.selectedThumbnailImageUrl.value!.isEmpty) {
        throw 'Upload Product Thumbnail Image';
      }

      // Upload Product Variation Images if any
      var variations = ProductVariationController.instance.productVariations;
      if (productType.value == ProductType.single && variations.isNotEmpty) {
        // If admin added variations and then changed the Product Type, remove all variations
        ProductVariationController.instance.resetAllValues();
        variations.value = [];
      }

      print("subb== ${createproductcontroller.subcategoryname}");
      print("subb ${createproductcontroller.subcategoryname_new.value}");
      print("departmentname $departmentname");
      print("sku.text.trim(); ${sku.text.trim()}");

      product.sku = sku.text.trim();
      product.isFeatured = true;
      product.title = title.text.trim();
      product.brand = selectedBrand.value;
      product.description = description.text.trim();
      product.link = linkTextField.text.trim();
      product.productType = productType.value.toString();
      product.stock = int.tryParse(stock.text.trim()) ?? 0;
      product.stockvalue = stockvalue;
      product.images = imagesController.additionalProductImagesUrls;
      // Main Price + Offer Price => stored price (MRP) and discount %.
      final double mrpSave = double.tryParse(price.text.trim()) ?? 0;
      final double offerSave = double.tryParse(salePrice.text.trim()) ?? 0;
      product.price = mrpSave;
      product.salePrice =
          (mrpSave > 0 && offerSave > 0 && offerSave < mrpSave)
              ? double.parse(
                  (((mrpSave - offerSave) / mrpSave) * 100).toStringAsFixed(2))
              : 0.0;
      product.thumbnail =
          imagesController.selectedThumbnailImageUrl.value ?? '';
      product.productAttributes =
          ProductAttributesController.instance.productAttributes;
      product.productVariations = variations;
      product.categoryId = createproductcontroller.select_category_id;

      product.subCategoryName = createproductcontroller.subcategoryname.value;
      product.subCategoryId = createproductcontroller.subcategoryid.value;
      product.departmentname = departmentname;
      product.timestamp = DateTime.now().toIso8601String();
      // Call Repository to Update New Product
      productDataUploader.value = true;
      await ProductRepository.instance.updateProduct(product);

      // Register product categories if any
      if (selectedCategories.isNotEmpty) {
        // Loop through selected Product Categories
        categoriesRelationshipUploader.value = true;

        // Get the existing category IDs
        List<String> existingCategoryIds =
            alreadyAddedCategories.map((category) => category.id).toList();

        for (var category in selectedCategories) {
          // Check if the category is not already associated with the product
          if (!existingCategoryIds.contains(category.id)) {
            // Map Data
            final productCategory = ProductCategoryModel(
                productId: product.id, categoryId: category.id);
            await ProductRepository.instance
                .createProductCategory(productCategory);
          }
        }

        // Remove categories not selected by the user`
        for (var existingCategoryId in existingCategoryIds) {
          // Check if the category is not present in the selected categories
          if (!selectedCategories
              .any((category) => category.id == existingCategoryId)) {
            // Remove the association
            await ProductRepository.instance
                .removeProductCategory(product.id, existingCategoryId);
          }
        }
      }

      // Update Product List
      ProductController.instance.updateItemFromLists(product);

      // Reset Form Values
      // resetValues();

      // Close the Progress Loader
      TFullScreenLoader.stopLoading();

      // Success popup → then redirect to All Products.
      _showSuccessAndRedirect();
    } catch (e) {
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
    stock.clear();
    price.clear();
    salePrice.clear();
    brandTextField.clear();
    selectedBrand.value = null;
    selectedCategories.clear();
    sub_category_data.clear();
    createproductcontroller.subcategoryname.value = "null";
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
          title: const Text('Updating Product'),
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

  // Show completion dialog
  /// Success popup, then redirect to the All Products list.
  void _showSuccessAndRedirect() {
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xff2E8B57), size: 64),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text('Saved Successfully',
                style: Theme.of(Get.context!).textTheme.headlineSmall),
            const SizedBox(height: TSizes.sm),
            const Text('Your product has been updated.'),
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
