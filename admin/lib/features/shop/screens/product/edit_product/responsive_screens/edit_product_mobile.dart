import 'package:cwt_ecommerce_admin_panel/features/shop/screens/product/edit_product/widgets/edit_categories_widget_new.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/product/edit_product/widgets/edit_parent_categories_widget_new.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/product/edit_product/widgets/edit_video_link.dart';
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
import '../widgets/attributes_widget.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/brand_widget.dart';

import '../widgets/stock_pricing_widget.dart';
import '../widgets/title_description.dart';
import '../widgets/variations_widget.dart';

class EditProductMobileScreen extends StatelessWidget {
  const EditProductMobileScreen({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductImagesController());

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
                returnToPreviousScreen: true,
                heading: 'Edit Product',
                breadcrumbItems: [TRoutes.products, 'Edit Product'],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Edit Product
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProductTitleAndDescription(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Stock & Pricing
                  TRoundedContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading
                        Text('Stock & Pricing',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        // Product Type
                        // const ProductTypeWidget(),
                        // const SizedBox(height: TSizes.spaceBtwInputFields),

                        // Stock
                        const ProductStockAndPricing(),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Attributes
                        ProductAttributes(), // Edit/Delete Attributes
                        const SizedBox(height: TSizes.spaceBtwSections),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Variations
                  const ProductVariations(), // Edit/Delete Variations
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Sidebar
                  const ProductThumbnailImage(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Product Images
                  TRoundedContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('All Product Images',
                            style: Theme.of(context).textTheme.headlineSmall),
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

                  const EditVideoLink(),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  // Product Brand
                  const ProductBrand(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // // Product Categories
                  // EditProductCategories(product: product),
                  // const SizedBox(height: TSizes.spaceBtwSections),

                  // // Product Categories
                  // EditProductSubCategories(product: product),
                  // const SizedBox(height: TSizes.spaceBtwSections),

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
            ],
          ),
        ),
      ),
    );
  }
}
