import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/category/category_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/product/edit_product/widgets/edit_categories_widget_new.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/product/edit_product/widgets/edit_parent_categories_widget_new.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/product/edit_product/widgets/edit_product_department.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/product/edit_product/widgets/edit_video_link.dart';
import 'package:cwt_ecommerce_admin_panel/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../controllers/product/product_images_controller.dart';
import '../../../../models/product_model.dart';
import '../../create_product/widgets/additional_images.dart';
import '../../create_product/widgets/thumbnail_widget.dart';
import '../widgets/ai_photoshoot_panel.dart';
import '../widgets/attributes_widget.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/brand_widget.dart';

import '../widgets/stock_pricing_widget.dart';
import '../widgets/title_description.dart';
import '../widgets/variations_widget.dart';

class EditProductDesktopScreen extends StatelessWidget {
  const EditProductDesktopScreen({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    print("build");
    final controller = Get.put(ProductImagesController());
    final categoriesController = Get.put(CategoryController());
    categoriesController.fetchItems();
    print("productsss = ${product.categoryId}");
    return Scaffold(
      bottomNavigationBar: ProductBottomNavigationButtons(product: product),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs
              const TBreadcrumbsWithHeading(
                heading: 'Edit Product',
                returnToPreviousScreen: true,
                breadcrumbItems: [TRoutes.products, 'Edit Product'],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Edit Product
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: TDeviceUtils.isTabletScreen(context) ? 2 : 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information
                        const ProductTitleAndDescription(),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Stock & Pricing
                        TRoundedContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Heading
                              Text('Stock & Pricing',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              const SizedBox(height: TSizes.spaceBtwItems),

                              // Product Type
                              // const ProductTypeWidget(),
                              // const SizedBox(
                              //     height: TSizes.spaceBtwInputFields),

                              // Stock
                              const ProductStockAndPricing(),
                              const SizedBox(height: TSizes.spaceBtwSections),

                              // Attributes
                              ProductAttributes(), // Add/Edit/Delete Attributes
                              const SizedBox(height: TSizes.spaceBtwSections),
                            ],
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Variations
                        const ProductVariations(), // Edit/Delete Variations
                      ],
                    ),
                  ),
                  const SizedBox(width: TSizes.defaultSpace),

                  // Sidebar
                  Expanded(
                    child: Column(
                      children: [
                        // Product Thumbnail
                        const ProductThumbnailImage(),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Product Images
                        TRoundedContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('All Product Images',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              const SizedBox(height: TSizes.spaceBtwItems),
                              ProductAdditionalImages(
                                additionalProductImagesURLs:
                                    controller.additionalProductImagesUrls,
                                onTapToAddImages: () =>
                                    controller.selectMultipleProductImages(),
                                onTapToRemoveImage: (index) =>
                                    controller.removeImage(index),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Generate AI model photos (BrandShoot)
                        AiPhotoshootPanel(product: product),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        const EditVideoLink(),
                        const SizedBox(height: TSizes.spaceBtwSections),
                        // Product Brand
                        const ProductBrand(),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Product Categories
                        // EditProductCategories(product: product),
                        // const SizedBox(height: TSizes.spaceBtwSections),
                        // // Product Categories
                        // EditProductSubCategories(product: product),
                        // const SizedBox(height: TSizes.spaceBtwSections),
                        // Product Department
                        EditProductDepartment(product: product),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        //
                        Edit_ProductCategories(product: product),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Parent Product Categories
                        Edit_ProductParentCategories(product: product),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Product Visibility
                        // const ProductVisibilityWidget(),
                        // const SizedBox(height: TSizes.spaceBtwSections),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
