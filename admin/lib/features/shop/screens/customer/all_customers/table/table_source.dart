import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/icons/table_action_icon_buttons.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../controllers/customer/customer_controller.dart';

class CustomerRows extends DataTableSource {
  final controller = CustomerController.instance;

  @override
  DataRow? getRow(int index) {
    final customer = controller.filteredItems[index];
    return DataRow2(
      onTap: () => Get.toNamed(TRoutes.customerDetails, arguments: customer),
      selected: controller.selectedRows[index],
      onSelectChanged: (value) =>
          controller.selectedRows[index] = value ?? false,
      cells: [
        DataCell(
          Row(
            children: [
              // TRoundedImage(
              //   width: 50,
              //   height: 50,
              //   padding: TSizes.sm,
              //   image: customer.profilePicture,
              //   imageType: ImageType.network,
              //   borderRadius: TSizes.borderRadiusMd,
              //   backgroundColor: TColors.primaryBackground,
              // ),
              // const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Text(
                  customer.fullName,
                  style: Theme.of(Get.context!)
                      .textTheme
                      .bodyLarge!
                      .apply(color: TColors.primary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(customer.email)),
        DataCell(Text(customer.phoneNumber)),
        DataCell(
            Text(customer.createdAt == null ? '' : customer.formattedDate)),
        DataCell(
          Row(
            children: [
              TTableActionButtons(
                view: true,
                edit: false,
                // notification: true,
                onViewPressed: () =>
                    Get.toNamed(TRoutes.customerDetails, arguments: customer),
                onDeletePressed: () =>
                    controller.confirmAndDeleteItem(customer),
                // onNotificationPressed: () =>
                //     Get.toNamed(TRoutes.createnotification)
              ),
              IconButton(
                onPressed: () {
                  Get.toNamed(TRoutes.createnotification);
                },
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.blue,
                ),
              ),
            ],
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
