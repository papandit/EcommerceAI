import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/coupan/coupan_controller.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/data_table/paginated_data_table.dart';
import '../../../../../../utils/device/device_utility.dart';
import 'table_source.dart';

class CoupanTable extends StatelessWidget {
  const CoupanTable({super.key});

  @override
  Widget build(BuildContext context) {
    print("Build tableee");
    final controller = Get.put(CoupanController());
    controller.sortAscending.value = false;

    return Obx(
      () {
        // Orders & Selected Rows are Hidden => Just to update the UI => Obx => [ProductRows]
        Visibility(
            visible: false,
            child: Text(controller.filteredItems.length.toString()));
        Visibility(
            visible: false,
            child: Text(controller.selectedRows.length.toString()));

        // Table
        return TPaginatedDataTable(
          minWidth: 700,
          sortAscending: controller.sortAscending.value,
          sortColumnIndex: controller.sortColumnIndex.value,
          columns: [
            const DataColumn2(label: Text('Coupan ID')),
            const DataColumn2(label: Text('Name')),
            const DataColumn2(label: Text('Percentage')),
            DataColumn2(
                label: const Text('Active'),
                fixedWidth: TDeviceUtils.isMobileScreen(context) ? 120 : null),
            const DataColumn2(label: Text('Date')),
            const DataColumn2(label: Text('Action'), fixedWidth: 100),
          ],
          source: OrderRows(),
        );
      },
    );
  }
}
