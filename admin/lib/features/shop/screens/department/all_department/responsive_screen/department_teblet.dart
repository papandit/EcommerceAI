// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cwt_ecommerce_admin_panel/common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/containers/rounded_container.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/loaders/loader_animation.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/department/department_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/department/all_department/table/data_table.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/screens/department/all_department/widgets/table_header.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DepartmentTebletScreen extends StatelessWidget {
  const DepartmentTebletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DepartMentController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TBreadcrumbsWithHeading(
                  heading: 'Department',
                  breadcrumbItems: ['Product Department']),
              const SizedBox(height: TSizes.spaceBtwSections),
              // Table Body
              Obx(() {
                // Show Loader
                if (controller.isLoading.value) return const TLoaderAnimation();

                return const TRoundedContainer(
                  child: Column(
                    children: [
                      // Table Header
                      DepartMentTableHeader(),
                      SizedBox(height: TSizes.spaceBtwItems),

                      // Table
                      DepartMentTable(),
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
