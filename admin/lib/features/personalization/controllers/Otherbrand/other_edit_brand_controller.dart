import 'package:cwt_ecommerce_admin_panel/data/repositories/otherbrands/other_brand_repository.dart';
import 'package:cwt_ecommerce_admin_panel/data/repositories/product/product_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/controllers/Otherbrand/other_brand_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/product_controller.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../media/controllers/media_controller.dart';
import '../../../media/models/image_model.dart';
import '../../models/othre_brand_category_model.dart';
import '../../models/other_brand_model.dart';
import '../../models/other_category_model.dart';

class OtherEditBrandController extends GetxController {
  static OtherEditBrandController get instance => Get.find();

  final loading = false.obs;
  RxString imageURL = ''.obs;
  final isFeatured = false.obs;
  final name = TextEditingController().obs;
  final formKey = GlobalKey<FormState>();
  final repository = Get.put(OtherBrandRepository());
  final List<OtherCategoryModel> selectedCategories =
      <OtherCategoryModel>[].obs;
  final List category = [].obs;

  /// Init Data
  ///
  void init(OtherBrandModel brand) {
    name.value.text = brand.name;
    category.addAll(brand.brandCategories ?? []);
    // selectedCategories.addAll(brand.brandCategories ?? []);
  }

  /// Method to reset fields
  void resetFields() {
    name.value.clear();
    loading(false);
    isFeatured(false);
    imageURL.value = '';
    selectedCategories.clear();
  }

  /// Pick Thumbnail Image from Media
  void pickImage() async {
    final controller = Get.put(MediaController());
    List<ImageModel>? selectedImages = await controller.selectImagesFromMedia();

    // Handle the selected images
    if (selectedImages != null && selectedImages.isNotEmpty) {
      // Set the selected image to the main image or perform any other action
      ImageModel selectedImage = selectedImages.first;
      // Update the main image using the selectedImage
      imageURL.value = selectedImage.url;
    }
  }

  /// Register new Brand
  Future<void> updateBrand(
    OtherBrandModel brand, {
    required String name,
    required String category,
    required String subcategory,
    required String about,
    imageUrl,
    // required Uint8List image,
  }) async {
    try {
      TFullScreenLoader.popUpCircular();

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!formKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      print("11brand.name${brand.name}");
      print("//brand.about== ${brand.about}");
      print("//about== $about");

      // print("11name.text.trim()${name.text.trim()}");
      brand.name = name.toString();
      brand.updatedAt = DateTime.now();
      brand.category = category;
      brand.subcategory = subcategory;
      brand.about = about;
      brand.image = imageUrl;
      print('hhh');
      print("22brand.name ${brand.name}");
      print("22brand.updatedAt ${brand.updatedAt}");
      print("22brand.category ${brand.category}");
      print("22brand.subcategory ${brand.subcategory}");
      print("22brand.about ${brand.about}");
      print("22brand.image ${brand.image}");
      print('iii');
      // Call Repository to Update
      await repository.updateBrand(brand);

      // if (brand.name != name.text.trim()) {
      //   print('fff');
      //   isBrandUpdated = true;

      //   // Map Data
      //   print('ggg');
      //   brand.name = name.text.trim();
      //   brand.updatedAt = DateTime.now();
      //   brand.category = category;
      //   brand.subcategory = subcategory;
      //   brand.about = about;
      //   brand.image = imageUrl;
      //   print('hhh');
      //   print("22brand.name ${brand.name}");
      //   print("22brand.updatedAt ${brand.updatedAt}");
      //   print("22brand.category ${brand.category}");
      //   print("22brand.subcategory ${brand.subcategory}");
      //   print("22brand.about ${brand.about}");
      //   print("22brand.image ${brand.image}");
      //   print('iii');
      //   // Call Repository to Update
      //   await repository.updateBrand(brand);
      // }
      // Update All Data list
      OtherBrandController.instance.updateItemFromLists(brand);

      update();

      // Remove Loader
      TFullScreenLoader.stopLoading();
      // Success Message & Redirect
      Get.back();

      TLoaders.successSnackBar(
          title: 'Congratulations', message: 'Your Record has been updated.');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      print('MMM');
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Update Categories of this Brand
  updateBrandCategories(OtherBrandModel brand) async {
    // Fetch all BrandCategories
    final brandCategories =
        await repository.getSpecificBrandCategories(brand.id);

    // SelectedCategoryIds
    final selectedCategoryIds = selectedCategories.map((e) => e.id);

    // Identify categories to remove
    final categoriesToRemove = brandCategories
        .where((existingCategory) =>
            !selectedCategoryIds.contains(existingCategory.categoryId))
        .toList();

    // Remove unselected categories
    for (var categoryToRemove in categoriesToRemove) {
      await OtherBrandRepository.instance
          .deleteBrandCategory(categoryToRemove.id ?? '');
    }

    // Identify new categories to add
    final newCategoriesToAdd = selectedCategories
        .where((newCategory) => !brandCategories.any((existingCategory) =>
            existingCategory.categoryId == newCategory.id))
        .toList();

    // Add new categories
    for (var newCategory in newCategoriesToAdd) {
      var brandCategory = OtherBrandCategoryModel(
          brandId: brand.id, categoryId: newCategory.id);
      brandCategory.id = await OtherBrandRepository.instance
          .createBrandCategory(brandCategory);
    }

    brand.brandCategories!.assignAll(selectedCategories);
    OtherBrandController.instance.updateItemFromLists(brand);
  }

  /// Update Products of this Brand
  updateBrandInProducts(OtherBrandModel brand) async {
    final productController = Get.put(ProductController());

    // Check if Products are available, if not then fetch them
    if (productController.allItems.isEmpty) {
      await productController.fetchItems();
    }

    // Once products are fetched, Get all products of this brand
    final brandProducts = productController.allItems
        .where(
            (product) => product.brand != null && product.brand!.id == brand.id)
        .toList();
    if (brandProducts.isNotEmpty) {
      // Update Brand in Products
      for (var product in brandProducts) {
        //ahiya comment chhe()()())(&&&&&*********) product.brand = brand;
        await ProductRepository.instance
            .updateProductSpecificValue(product.id, {'Brand': brand.toJson()});
      }

      // Update brand in Local Already Fetched List of Products
      // Todo: Update Products Brand Value in Local List --> Just un comment Line Below
      // productController.updateItemFromLists(brand);
    }
  }
}
