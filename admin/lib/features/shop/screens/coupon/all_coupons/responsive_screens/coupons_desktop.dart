import 'package:cwt_ecommerce_admin_panel/common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/containers/rounded_container.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/loaders/loader_animation.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/coupan/coupan_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/coupon/all_coupons/table/data_table.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/coupon/all_coupons/widgets/table_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/constants/sizes.dart';

class CouponsDesktopScreen extends StatelessWidget {
  const CouponsDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CoupanController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs
              const TBreadcrumbsWithHeading(
                  heading: 'Coupons', breadcrumbItems: ['Coupons']),
              Obx(() {
                // Show Loader
                if (controller.isLoading.value) return const TLoaderAnimation();

                return const TRoundedContainer(
                  child: Column(
                    children: [
                      // Table Header
                      CouponTableHeader(),
                      SizedBox(height: TSizes.spaceBtwItems),

                      // Table
                    ],
                  ),
                );
              }),
              const CoupanTable(),
              // Table Body
              const SizedBox(height: TSizes.spaceBtwSections),
              const SizedBox(height: TSizes.spaceBtwSections * 5),

              // Center(
              //   child: Column(
              //     children: [
              //       const Image(
              //           image: AssetImage(TImages.couponIllustration),
              //           width: 300,
              //           height: 300),
              //       const SizedBox(height: TSizes.spaceBtwItems),
              //       Text('Coupons Cooking',
              //           style: Theme.of(context).textTheme.headlineLarge),
              //       const SizedBox(height: TSizes.spaceBtwItems),
              //       const Text(
              //         'Hold onto your hats! We\'re brewing up a Coupons feature for both the Admin Panel and the App. 🎉 \nThe Coupons Screen is just around the corner... get ready for some savings magic! 🪄💸',
              //         textAlign: TextAlign.center,
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
