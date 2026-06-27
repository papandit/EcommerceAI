import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/department/department_controller.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../common/widgets/data_table/paginated_data_table.dart';
import 'table_source.dart';

class DepartMentTable extends StatelessWidget {
  const DepartMentTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DepartMentController());
    return Obx(
      () {
        // Customers & Selected Rows are Hidden => Just to update the UI => Obx => [ProductRows]
        // Categories & Selected Rows are Hidden => Just to update the UI => Obx => [ProductRows]
        Visibility(
            visible: false,
            child: Text(controller.filteredItems.length.toString()));
        Visibility(
            visible: false,
            child: Text(controller.selectedRows.length.toString()));

        // Table
        return TPaginatedDataTable(
          minWidth: 550,
          tableHeight: 640,
          dataRowHeight: kMinInteractiveDimension,
          sortAscending: controller.sortAscending.value,
          sortColumnIndex: controller.sortColumnIndex.value,
          columns: [
            DataColumn2(
                label: const Text('Department'),
                onSort: (columnIndex, ascending) =>
                    controller.sortByName(columnIndex, ascending)),
            // const DataColumn2(
            //   label: Text('Sub Category'),
            // ),
            // const DataColumn2(label: Text('Featured')),
            // const DataColumn2(label: Text('Date')),
            const DataColumn2(label: Text('Action'), fixedWidth: 140),
          ],
          source: DePartMentRows(),
        );
      },
    );
  }
}
