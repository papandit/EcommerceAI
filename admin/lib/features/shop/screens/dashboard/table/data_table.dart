import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/data_table/paginated_data_table.dart';
import '../../../../../../utils/device/device_utility.dart';
import '../../../controllers/order/order_controller.dart';
import 'table_source.dart';

class DashboardOrderTable extends StatelessWidget {
  const DashboardOrderTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OrderController.instance;
    return Obx(
      () {
        // Orders & Selected Rows are Hidden => Just to update the UI => Obx => [ProductRows]
        Visibility(visible: false, child: Text(controller.filteredItems.length.toString()));
        Visibility(visible: false, child: Text(controller.selectedRows.length.toString()));

        // Table
        return TPaginatedDataTable(
          minWidth: 700,
          tableHeight: 500,
          dataRowHeight: TSizes.xl * 1.2,
          sortAscending: controller.sortAscending.value,
          sortColumnIndex: controller.sortColumnIndex.value,
          columns: [
            DataColumn2(label: const Text('Order ID'), onSort: (columnIndex, ascending) => controller.sortById(columnIndex, ascending)),
            const DataColumn2(label: Text('Date')),
            const DataColumn2(label: Text('Items')),
            DataColumn2(label: const Text('Status'), fixedWidth: TDeviceUtils.isMobileScreen(context) ? 120 : null),
            const DataColumn2(label: Text('Amount')),
          ],
          source: OrderRows(),
        );
      },
    );
  }
}
