import 'package:cwt_ecommerce_admin_panel/features/personalization/controllers/Otherbrand/other_brand_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../common/widgets/loaders/loader_animation.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../other_table/other_data_table.dart';
import '../widgets/other_table_header.dart';

class OtherBrandsTabletScreen extends StatelessWidget {
  const OtherBrandsTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtherBrandController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TBreadcrumbsWithHeading(heading: 'Others', breadcrumbItems: ['Others']),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Table Body
              Obx(() {
                // Show Loader
                if (controller.isLoading.value) return const TLoaderAnimation();

                return const TRoundedContainer(
                  child: Column(
                    children: [
                      // Table Header
                      OtherBrandTableHeader(),
                      SizedBox(height: TSizes.spaceBtwItems),

                      // Table
                      OtherBrandTable(),
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
