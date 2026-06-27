import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/customer/customer_detail_controller.dart';
import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:cwt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../utils/constants/colors.dart';

class CustomerOrdersRows extends DataTableSource {
  final controller = CustomerDetailController.instance;

  @override
  DataRow? getRow(int index) {
    final order = controller.filteredCustomerOrders[index];
    final totalAmount = order.items.fold<double>(
        0, (previousValue, element) => previousValue + element.price);

    print("Print 1 $order");
    return DataRow2(
      onTap: () => Get.toNamed("${TRoutes.orderDetails}?orderId=${order.id}",
          arguments: order),
      selected: controller.selectedRows[index],
      cells: [
        DataCell(
          Text(
            order.Orderid,
            style: Theme.of(Get.context!)
                .textTheme
                .bodyLarge!
                .apply(color: TColors.primary),
          ),
        ),
        DataCell(Text(order.formattedOrderDate)),
        DataCell(Text('${order.items.length} Items')),
        DataCell(
          TRoundedContainer(
            radius: TSizes.cardRadiusSm,
            padding: const EdgeInsets.symmetric(
                vertical: TSizes.sm, horizontal: TSizes.md),
            backgroundColor: THelperFunctions.getOrderStatusColor(order.status)
                .withValues(alpha: 0.1),
            child: Text(
              order.status.name.capitalize.toString(),
              style: TextStyle(
                  color: THelperFunctions.getOrderStatusColor(order.status)),
            ),
          ),
        ),
        DataCell(Text('₹$totalAmount')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => controller.filteredCustomerOrders.length;

  @override
  int get selectedRowCount =>
      controller.selectedRows.where((selected) => selected).length;
}
