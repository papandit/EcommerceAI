import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/data_table/paginated_data_table.dart';
import '../../../../controllers/customer/customer_controller.dart';
import 'table_source.dart';

class CustomerTable extends StatelessWidget {
  const CustomerTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerController());
    return Obx(
      () {
        // Customers & Selected Rows are Hidden => Just to update the UI => Obx => [ProductRows]
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
            DataColumn2(
                label: const Text('Customer'),
                onSort: (columnIndex, ascending) =>
                    controller.sortByName(columnIndex, ascending)),
            const DataColumn2(label: Text('Email')),
            const DataColumn2(label: Text('Phone Number')),
            const DataColumn2(label: Text('Registered')),
            const DataColumn2(label: Text('Action'), fixedWidth: 150),
          ],
          source: CustomerRows(),
        );
      },
    );
  }
}
