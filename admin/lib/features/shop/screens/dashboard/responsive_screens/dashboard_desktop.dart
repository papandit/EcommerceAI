import 'package:cwt_ecommerce_admin_panel/common/widgets/texts/page_heading.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../common/widgets/icons/t_circular_icon.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/dashboard/dashboard_controller.dart';
import '../table/data_table.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/order_status_graph.dart';
import '../widgets/quick_actions.dart';
import '../widgets/weekly_sales.dart';

class DashboardDesktopScreen extends StatelessWidget {
  const DashboardDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TPageHeading(heading: 'Dashboard'),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Quick Actions
              const TDashboardQuickActions(),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Card Stats
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => TDashboardCard(
                        headingIcon: Iconsax.note,
                        headingIconColor: Colors.blue,
                        headingIconBgColor: Colors.blue.withValues(alpha: 0.1),
                        stats: controller.salesGrowth,
                        context: context,
                        title: 'Sales total',
                        subTitle:
                            '₹${controller.salesTotal.value.toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Expanded(
                    child: Obx(
                      () => TDashboardCard(
                        headingIcon: Iconsax.external_drive,
                        headingIconColor: Colors.green,
                        headingIconBgColor: Colors.green.withValues(alpha: 0.1),
                        stats: controller.aovGrowth,
                        context: context,
                        title: 'Average Order Value',
                        subTitle:
                            '₹${controller.averageOrderValue.toStringAsFixed(2)}',
                        icon: Iconsax.arrow_down,
                        color: TColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Expanded(
                    child: Obx(
                      () => TDashboardCard(
                        headingIcon: Iconsax.box,
                        headingIconColor: Colors.deepPurple,
                        headingIconBgColor: Colors.deepPurple.withValues(alpha: 0.1),
                        stats: controller.ordersGrowth,
                        context: context,
                        title: 'Total Orders',
                        subTitle: '${controller.liveOrderCount.value}',
                      ),
                    ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Expanded(
                    child: Obx(
                      () => TDashboardCard(
                        headingIcon: Iconsax.user,
                        headingIconColor: Colors.deepOrange,
                        headingIconBgColor:
                            Colors.deepOrange.withValues(alpha: 0.1),
                        context: context,
                        title: 'Customers',
                        subTitle: '${controller.customerCount.value}',
                        stats: controller.customersGrowth,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Graphs
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        // Weekly Sales Graph
                        const TWeeklySalesGraph(),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Orders
                        TRoundedContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  TCircularIcon(
                                    icon: Iconsax.box,
                                    backgroundColor:
                                        Colors.deepPurple.withValues(alpha: 0.1),
                                    color: Colors.deepPurple,
                                    size: TSizes.md,
                                  ),
                                  const SizedBox(width: TSizes.spaceBtwItems),
                                  Text('Recent Orders',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall),
                                ],
                              ),
                              const SizedBox(height: TSizes.spaceBtwSections),
                              const DashboardOrderTable(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwSections),
                  Expanded(
                    child: TRoundedContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TCircularIcon(
                                icon: Iconsax.status,
                                backgroundColor: Colors.amber.withValues(alpha: 0.1),
                                color: Colors.amber,
                                size: TSizes.md,
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems),
                              Text('Orders Status',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                            ],
                          ),
                          const SizedBox(height: TSizes.spaceBtwSections),
                          const OrderStatusPieChart(),
                        ],
                      ),
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
