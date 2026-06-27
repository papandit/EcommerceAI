// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cwt_ecommerce_admin_panel/common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/containers/rounded_container.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/loaders/loader_animation.dart';

import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/review/review_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/review/all_review/table/data_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/constants/sizes.dart';

class ReviewDesktopScreen extends StatelessWidget {
  const ReviewDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs
              const TBreadcrumbsWithHeading(
                  heading: 'Reviews', breadcrumbItems: ['Reviews']),
              // Table Body
              Obx(() {
                // Show Loader
                if (controller.isLoading.value) return const TLoaderAnimation();

                return TRoundedContainer(
                  child: Column(
                    children: [
                      // Table Header
                      const ReviewTable(),

                      const SizedBox(height: TSizes.spaceBtwSections * 5),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
