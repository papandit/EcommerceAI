// import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/Review/Review_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/review/review_controller.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../common/widgets/data_table/paginated_data_table.dart';
import 'table_source.dart';

class ReviewTable extends StatelessWidget {
  const ReviewTable({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewController());
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
          columns: const [
            DataColumn2(label: Text('Review ID')),
            DataColumn2(label: Text('Name')),
            DataColumn2(label: Text('Phone Number')),
            DataColumn2(
              label: Text('Email'),
            ),
            DataColumn2(label: Text('Date')),
            DataColumn2(label: Text('Message')),
            DataColumn2(label: Text('Action'), fixedWidth: 100),
          ],
          source: ReviewRows(),
        );
      },
    );
  }
}
