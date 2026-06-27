import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/product/product_controller.dart';
import 'package:cwt_ecommerce_admin_panel/utils/device/device_utility.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/data_table/paginated_data_table.dart';
import 'table_source.dart';

class ProductsTable extends StatelessWidget {
  const ProductsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    return Obx(
      () {
        // Products & Selected Rows are Hidden => Just to update the UI => Obx => [ProductRows]
        Visibility(
            visible: false,
            child: Text(controller.filteredItems.length.toString()));
        Visibility(
            visible: false,
            child: Text(controller.selectedRows.length.toString()));

        // Table
        return TPaginatedDataTable(
          minWidth: 1000,
          sortAscending: controller.sortAscending.value,
          sortColumnIndex: controller.sortColumnIndex.value,
          columns: [
            DataColumn2(
              label: const Text('Product'),
              fixedWidth: !TDeviceUtils.isDesktopScreen(context) ? 300 : 400,
              onSort: (columnIndex, ascending) =>
                  controller.sortByName(columnIndex, ascending),
            ),
            // DataColumn2(
            //   label: const Text('Stock'),
            //   onSort: (columnIndex, ascending) =>
            //       controller.sortByStock(columnIndex, ascending),
            // ),
            const DataColumn2(label: Text('Department')),
            const DataColumn2(label: Text('Brand')),
            DataColumn2(
              label: const Text('Price'),
              onSort: (columnIndex, ascending) =>
                  controller.sortByPrice(columnIndex, ascending),
            ),
            const DataColumn2(label: Text('Rating')),
            const DataColumn2(label: Text('Date')),
            const DataColumn2(label: Text('Action'), fixedWidth: 100),
          ],
          source: ProductsRows(),
        );
      },
    );
  }
}
