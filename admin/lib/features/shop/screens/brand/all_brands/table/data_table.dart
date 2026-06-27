import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/data_table/paginated_data_table.dart';
import '../../../../../../utils/device/device_utility.dart';
import '../../../../controllers/brand/brand_controller.dart';
import 'table_source.dart';

class BrandTable extends StatelessWidget {
  const BrandTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BrandController());
    return Obx(
      () {
        // Categories & Selected Rows are Hidden => Just to update the UI => Obx => [ProductRows]
        Visibility(
            visible: false,
            child: Text(controller.filteredItems.length.toString()));
        Visibility(
            visible: false,
            child: Text(controller.selectedRows.length.toString()));

        final lgTable = controller.filteredItems.any((element) =>
            element.brandCategories != null &&
            element.brandCategories!.length > 2);
        // Table
        return TPaginatedDataTable(
          minWidth: 700,
          dataRowHeight: lgTable ? 96 : 64,
          tableHeight: lgTable ? 96 * 11.5 : 760,
          sortAscending: controller.sortAscending.value,
          sortColumnIndex: controller.sortColumnIndex.value,
          columns: [
            DataColumn2(
                label: const Text('Brand'),
                fixedWidth:
                    TDeviceUtils.isMobileScreen(Get.context!) ? null : 200,
                onSort: (columnIndex, ascending) =>
                    controller.sortByName(columnIndex, ascending)),
            const DataColumn2(label: Text('Categories')),
            // DataColumn2(
            //     label: const Text('Featured'),
            //     fixedWidth:
            //         TDeviceUtils.isMobileScreen(Get.context!) ? null : 100),
            DataColumn2(
                label: const Text('Date'),
                fixedWidth:
                    TDeviceUtils.isMobileScreen(Get.context!) ? null : 200),
            DataColumn2(
                label: const Text('Action'),
                fixedWidth:
                    TDeviceUtils.isMobileScreen(Get.context!) ? null : 100),
          ],
          source: BrandRows(),
        );
      },
    );
  }
}
