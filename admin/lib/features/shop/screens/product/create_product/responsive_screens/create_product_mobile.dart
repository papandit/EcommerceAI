import 'package:cwt_ecommerce_admin_panel/features/shop/screens/product/create_product/widgets/parent_categories_widget.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/product/create_product/widgets/product_department.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/product/create_product/widgets/video_link.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../controllers/product/product_images_controller.dart';
import '../widgets/additional_images.dart';
import '../widgets/attributes_widget.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/brand_widget.dart';
import '../widgets/categories_widget.dart';
import '../widgets/stock_pricing_widget.dart';
import '../widgets/thumbnail_widget.dart';
import '../widgets/title_description.dart';
import '../widgets/variations_widget.dart';

class CreateProductMobileScreen extends StatelessWidget {
  const CreateProductMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductImagesController());

    return Scaffold(
      bottomNavigationBar: const ProductBottomNavigationButtons(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs
              const TBreadcrumbsWithHeading(
                  returnToPreviousScreen: true,
                  heading: 'Create Product',
                  breadcrumbItems: [TRoutes.products, 'Create Product']),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Create Product
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
                        ProductStockAndPricing(),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Attributes
                        ProductAttributes(),
                        const SizedBox(height: TSizes.spaceBtwSections),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Variations
                  const ProductVariations(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Sidebar
                  const ProductThumbnailImage(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Product Images
                  TRoundedContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('All Product Images1',
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
                  // Video Link
                  const VideoLink(),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  // Product Brand
                  const ProductBrand(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Product Department
                  const ProductDepartment(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Product Categories
                  const ProductCategories(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Parent Product Categories
                  const ProductParentCategories(),
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
