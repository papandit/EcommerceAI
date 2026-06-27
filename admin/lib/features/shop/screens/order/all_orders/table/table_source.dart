// import 'dart:convert';
// import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
// import 'package:cwt_ecommerce_admin_panel/utils/popups/loaders.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart'
// //     as fln;
// import 'package:get/get.dart';
// import '../../../../../../common/widgets/containers/rounded_container.dart';
// import '../../../../../../common/widgets/icons/table_action_icon_buttons.dart';
// import '../../../../../../utils/constants/colors.dart';
// import '../../../../../../utils/constants/sizes.dart';
// import '../../../../../../utils/helpers/helper_functions.dart';
// import '../../../../controllers/order/order_controller.dart';

// class OrderRows extends DataTableSource {
//   final controller = OrderController.instance;

//   @override
//   DataRow? getRow(int index) {
//     final order = controller.filteredItems[index];

//     return DataRow2(
//       onTap: () => Get.toNamed(TRoutes.orderDetails, arguments: order),
//       selected: controller.selectedRows[index],
//       onSelectChanged: (value) =>
//           controller.selectedRows[index] = value ?? false,
//       cells: [
//         DataCell(
//           Text(
//             order.id,
//             style: Theme.of(Get.context!)
//                 .textTheme
//                 .bodyLarge!
//                 .apply(color: TColors.primary),
//           ),
//         ),
//         DataCell(Text(order.formattedOrderDate)),
//         DataCell(Text('${order.items.length} Items')),
//         DataCell(
//           TRoundedContainer(
//             radius: TSizes.cardRadiusSm,
//             padding: const EdgeInsets.symmetric(
//                 vertical: TSizes.sm, horizontal: TSizes.md),
//             backgroundColor: THelperFunctions.getOrderStatusColor(order.status)
//                 .withOpacity(0.1),
//             child: Text(
//               order.status.name.capitalize.toString(),
//               style: TextStyle(
//                   color: THelperFunctions.getOrderStatusColor(order.status)),
//             ),
//           ),
//         ),
//         DataCell(Text('\₹${order.totalAmount}')),
//         DataCell(
//           TTableActionButtons(
//             view: true,
//             edit: false,
//             onViewPressed: () =>
//                 Get.toNamed(TRoutes.orderDetails, arguments: order),
//             onDeletePressed: () => controller.confirmAndDeleteItem(order),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get rowCount => controller.filteredItems.length;

//   @override
//   int get selectedRowCount =>
//       controller.selectedRows.where((selected) => selected).length;
// }

//  // DataCell(
//         //   Row(
//         //     children: [
//         //       Obx(
//         //         () => controller.isSend.value == false
//         //             ? ElevatedButton(
//         //                 onPressed: () {
//         //                   print("::mail ${order.email}");
//         //                   SendMail.sendEmail(
//         //                     message: "Order Successfully!!",
//         //                     email: "maya.codebuzz@gmail.com",
//         //                     ccEmail: order.email,
//         //                   );
//         //                   controller.isSend.value = true;
//         //                   // Get.toNamed(TRoutes.orderEmail);
//         //                 },
//         //                 child: Text("Send"))
//         //             : Text("Already Send Mail"),
//         //       ),
//         //       const SizedBox(
//         //         width: 5,
//         //       ),
//         //     ],
//         //   ),
//         // ),

import 'package:cwt_ecommerce_admin_panel/common/widgets/containers/rounded_container.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/icons/table_action_icon_buttons.dart';
import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/colors.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/enums.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:cwt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../../../controllers/order/order_controller.dart';
import '../../../../models/order_model.dart';

class OrderRows extends DataTableSource {
  final OrderController controller = OrderController.instance;

  @override
  DataRow? getRow(int index) {
    final order = controller.filteredItems[index];
    print("::// order$order");
    // print("::// indexs${indexs}");
    return DataRow2(
      onTap: () => Get.toNamed(
        "${TRoutes.orderDetails}?orderId=${order.Orderid}",
        arguments: order,
      ),
      selected: controller.selectedRows[index],
      onSelectChanged: (value) {
        // Schedule the state change to happen after the build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.selectedRows[index] = value ?? false;
        });
      },
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
        DataCell(Text('₹${order.totalAmount.round()}')),
        DataCell(_StatusDropdown(order: order)),
        DataCell(
          TTableActionButtons(
            view: true,
            edit: false,
            onViewPressed: () => Get.toNamed(
              "${TRoutes.orderDetails}?orderId=${order.Orderid}",
              arguments: order,
            ),
            onDeletePressed: () => controller.confirmAndDeleteItem(order),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => controller.filteredItems.length;

  @override
  int get selectedRowCount =>
      controller.selectedRows.where((selected) => selected).length;
}

/// Inline status editor shown in the Orders table "Update Status" column.
/// Lets the admin move an order through its tracking stages
/// (Pending → Processing → Shipped → Delivered / Cancelled). The change is
/// written to Firestore and instantly reflected on the customer's order page.
class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final controller = OrderController.instance;
    final color = THelperFunctions.getOrderStatusColor(order.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OrderStatus>(
          value: order.status,
          isDense: true,
          isExpanded: true,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 18),
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
          items: OrderStatus.values
              .map(
                (status) => DropdownMenuItem<OrderStatus>(
                  value: status,
                  child: Text(
                    status.name.capitalize ?? status.name,
                    style: TextStyle(
                      color: THelperFunctions.getOrderStatusColor(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (newStatus) {
            if (newStatus == null || newStatus == order.status) return;
            controller.setOrderStatus(order, newStatus);
          },
        ),
      ),
    );
  }
}
