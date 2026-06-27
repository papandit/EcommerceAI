import 'package:cwt_ecommerce_admin_panel/common/widgets/icons/table_action_icon_buttons.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/review/review_controller.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../utils/constants/colors.dart';

class ReviewRows extends DataTableSource {
  final controller = ReviewController.instance;

  @override
  DataRow? getRow(int index) {
    final review = controller.filteredItems[index];

    return DataRow2(
      // onTap: () => Get.toNamed(TRoutes.orderDetails, arguments: review),
      selected: controller.selectedRows[index],
      onSelectChanged: (value) =>
          controller.selectedRows[index] = value ?? false,
      cells: [
        DataCell(
          Text(
            review.id,
            style: Theme.of(Get.context!)
                .textTheme
                .bodyLarge!
                .apply(color: TColors.black),
          ),
        ),
        DataCell(
          Text(
            review.name,
            style: Theme.of(Get.context!)
                .textTheme
                .bodyLarge!
                .apply(color: TColors.black),
          ),
        ),
        DataCell(
          Text(
            review.phonenumber,
            style: Theme.of(Get.context!)
                .textTheme
                .bodyLarge!
                .apply(color: TColors.black),
          ),
        ),
        DataCell(
          Text(
            review.email,
            style: Theme.of(Get.context!)
                .textTheme
                .bodyLarge!
                .apply(color: TColors.black),
          ),
        ),
        // DataCell(review.email
        //     ? const Icon(Icons.check_box_rounded, color: TColors.black)
        //     : const Icon(Icons.check_box_outlined)),
        DataCell(Text(
            '${review.updatedAt?.day}/${review.updatedAt?.month}/${review.updatedAt?.year} / ${review.updatedAt?.hour}:${review.updatedAt?.minute}')),
        DataCell(
          Text(
            review.message,
            style: Theme.of(Get.context!)
                .textTheme
                .bodyLarge!
                .apply(color: TColors.black),
          ),
        ),
        DataCell(
          TTableActionButtons(
            edit: false,
            // onEditPressed: () =>
            //     Get.toNamed(TRoutes.editReview, arguments: review),
            onDeletePressed: () => controller.confirmAndDeleteItem(review),
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
