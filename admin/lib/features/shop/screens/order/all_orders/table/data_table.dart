// import 'package:data_table_2/data_table_2.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../../../common/widgets/data_table/paginated_data_table.dart';
// import '../../../../../../utils/device/device_utility.dart';
// import '../../../../controllers/order/order_controller.dart';
// import 'table_source.dart';

// class OrderTable extends StatelessWidget {
//   const OrderTable({super.key});

//   @override
//   Widget build(BuildContext context) {
//     print("Build tableee");
//     final controller = Get.put(OrderController());
//     controller.sortAscending.value = false;

//     return Obx(
//       () {
//         // Orders & Selected Rows are Hidden => Just to update the UI => Obx => [ProductRows]
//         Visibility(
//             visible: false,
//             child: Text(controller.filteredItems.length.toString()));
//         Visibility(
//             visible: false,
//             child: Text(controller.selectedRows.length.toString()));

//         // Table
//         return TPaginatedDataTable(
//           minWidth: 700,
//           sortAscending: controller.sortAscending.value,
//           sortColumnIndex: controller.sortColumnIndex.value,
//           columns: [
//             const DataColumn2(label: Text('Order ID')),
//             DataColumn2(
//                 label: const Text('Date'),
//                 onSort: (columnIndex, ascending) =>
//                     controller.sortByDate(columnIndex, ascending)),
//             const DataColumn2(label: Text('Items')),
//             DataColumn2(
//                 label: const Text('Status'),
//                 fixedWidth: TDeviceUtils.isMobileScreen(context) ? 120 : null),
//             // const DataColumn2(label: Text('Send Mail')),
//             const DataColumn2(label: Text('Amount')),
//             const DataColumn2(label: Text('Action'), fixedWidth: 100),
//           ],
//           source: OrderRows(),
//         );
//       },
//     );
//   }
// }

//===============================================================================================

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../common/widgets/data_table/paginated_data_table.dart';
import '../../../../../../utils/device/device_utility.dart';
import '../../../../controllers/order/order_controller.dart';
import 'table_source.dart';

class OrderTable extends StatelessWidget {
  const OrderTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderController());
    controller.sortAscending.value = false; // Initialize before build

    return Obx(
      () {
        // Table
        return TPaginatedDataTable(
          minWidth: 1000,
          sortAscending: controller.sortAscending.value,
          sortColumnIndex: controller.sortColumnIndex.value,
          columns: [
            const DataColumn2(label: Text('Order ID')),
            DataColumn2(
                label: const Text('Date'),
                onSort: (columnIndex, ascending) =>
                    controller.sortByDate(columnIndex, ascending)),
            const DataColumn2(label: Text('Items')),
            DataColumn2(
                label: const Text('Status'),
                fixedWidth: TDeviceUtils.isMobileScreen(context) ? 120 : null),
            const DataColumn2(label: Text('Amount')),
            const DataColumn2(label: Text('Update Status'), fixedWidth: 200),
            const DataColumn2(label: Text('Action'), fixedWidth: 120),
          ],
          source: OrderRows(),
        );
      },
    );
  }
}
