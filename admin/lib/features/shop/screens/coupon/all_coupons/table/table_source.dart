import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/coupan/coupan_controller.dart';
import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../common/widgets/icons/table_action_icon_buttons.dart';
import '../../../../../../utils/constants/colors.dart';

class OrderRows extends DataTableSource {
  final controller = CoupanController.instance;

  @override
  DataRow? getRow(int index) {
    print("CoupanRows getRow = $index");
    final coupan = controller.filteredItems[index];
    print("CoupanRows Order = $coupan");

    print("//Coupan $coupan");
    print("//Coupan name ${coupan.name}");
    return DataRow2(
      // onTap: () => Get.toNamed(TRoutes.orderDetails, arguments: coupan),
      selected: controller.selectedRows[index],
      onSelectChanged: (value) =>
          controller.selectedRows[index] = value ?? false,
      cells: [
        DataCell(
          Text(
            coupan.id,
            style: Theme.of(Get.context!)
                .textTheme
                .bodyLarge!
                .apply(color: TColors.primary),
          ),
        ),
        DataCell(
          Text(
            coupan.name,
            style: Theme.of(Get.context!)
                .textTheme
                .bodyLarge!
                .apply(color: TColors.primary),
          ),
        ),
        DataCell(
          Text(
            coupan.percentage,
            style: Theme.of(Get.context!)
                .textTheme
                .bodyLarge!
                .apply(color: TColors.primary),
          ),
        ),
        DataCell(coupan.isActive
            ? const Icon(Icons.check_box_rounded, color: TColors.primary)
            : const Icon(Icons.check_box_outlined)),
        DataCell(Text(coupan.createdAt == null ? '' : coupan.formattedDate)),
        DataCell(
          TTableActionButtons(
            onEditPressed: () =>
                Get.toNamed(TRoutes.editCoupon, arguments: coupan),
            onDeletePressed: () => controller.confirmAndDeleteItem(coupan),
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
