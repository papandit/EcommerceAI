import 'package:cwt_ecommerce_admin_panel/common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/containers/rounded_container.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/loaders/loader_animation.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/notifications/all_notification/table/data_table.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/notifications/all_notification/widgets/table_header.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/coupan/coupan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/constants/sizes.dart';

class NotificationDesktopScreen extends StatelessWidget {
  const NotificationDesktopScreen({super.key});

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
                  heading: 'Notification', breadcrumbItems: ['Notification']),
              Obx(() {
                // Show Loader
                if (controller.isLoading.value) return const TLoaderAnimation();

                return const TRoundedContainer(
                  child: Column(
                    children: [
                      // Table Header
                      NotificationTableHeader(),
                      SizedBox(height: TSizes.spaceBtwItems),

                      // Table
                    ],
                  ),
                );
              }),
              const NotificationTable(),
              // Table Body
              const SizedBox(height: TSizes.spaceBtwSections),
              const SizedBox(height: TSizes.spaceBtwSections * 5),
            ],
          ),
        ),
      ),
    );
  }
}
