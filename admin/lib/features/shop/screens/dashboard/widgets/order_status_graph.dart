import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/dashboard/dashboard_controller.dart';
import 'package:cwt_ecommerce_admin_panel/utils/device/device_utility.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/containers/circular_container.dart';
import '../../../../../common/widgets/loaders/loader_animation.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class OrderStatusPieChart extends StatelessWidget {
  const OrderStatusPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DashboardController.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => controller.orderStatusData.isNotEmpty
              ? SizedBox(
                  height: 400,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius:
                          TDeviceUtils.isTabletScreen(context) ? 80 : 55,
                      startDegreeOffset: 180,
                      sections: controller.orderStatusData.entries.map((entry) {
                        final OrderStatus status = entry.key;
                        final int count = entry.value;

                        return PieChartSectionData(
                          showTitle: true,
                          color: THelperFunctions.getOrderStatusColor(status),
                          value: count.toDouble(),
                          title: '$count',
                          radius:
                              TDeviceUtils.isTabletScreen(context) ? 80 : 100,
                          titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        );
                      }).toList(),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Handle touch events here if needed
                        },
                        enabled: true,
                      ),
                    ),
                  ),
                )
              : const SizedBox(
                  height: 400,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [TLoaderAnimation()])),
        ),

        // Show Status and Color Meta
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => DataTable(
              columns: const [
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Orders')),
                DataColumn(label: Text('Total')),
              ],
              rows: controller.orderStatusData.entries.map((entry) {
                final OrderStatus status = entry.key;
                final int count = entry.value;
                final double totalAmount = controller.totalAmounts[status]!;
                final String displayStatus =
                    controller.getDisplayStatusName(status);

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          TCircularContainer(
                              width: 20,
                              height: 20,
                              backgroundColor:
                                  THelperFunctions.getOrderStatusColor(status)),
                          Expanded(
                              child: Text(
                            ' $displayStatus',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                        ],
                      ),
                    ),
                    DataCell(Text(count.toString())),
                    DataCell(Text(
                        '₹${totalAmount.toStringAsFixed(2)}')), // Format as needed
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
