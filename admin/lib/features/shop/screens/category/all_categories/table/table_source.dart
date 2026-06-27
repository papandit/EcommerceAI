import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:cwt_ecommerce_admin_panel/utils/device/device_utility.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../common/widgets/icons/table_action_icon_buttons.dart';
import '../../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../controllers/category/category_controller.dart';

class CategoryRows extends DataTableSource {
  final controller = CategoryController.instance;

  @override
  DataRow? getRow(int index) {
    final category = controller.filteredItems[index];

    // controller.fetchData();
    // final parentCategory = controller.allItems
    //     .firstWhereOrNull((item) => item.id == category.parentId);
    // print("Data = ${controller.allItems.last.parentId}");
    final parentCategory = controller.allItems[index].parentId;

    // var json = jsonEncode(parentCategory);
    // var data = jsonDecode(json);
    print("Parent Categories Data = ${controller.allItems[index].parentId}");
    print("Parent Categories $parentCategory");

    return DataRow2(
      selected: controller.selectedRows[index],
      onSelectChanged: (value) =>
          controller.selectedRows[index] = value ?? false,
      cells: [
        DataCell(
          Row(
            children: [
              TRoundedImage(
                width: 50,
                height: 50,
                padding: TSizes.sm,
                image: category.image,
                imageType: ImageType.network,
                borderRadius: TSizes.borderRadiusMd,
                backgroundColor: TColors.primaryBackground,
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(Get.context!)
                      .textTheme
                      .bodyLarge!
                      .apply(color: TColors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Wrap(
                spacing: TSizes.xs,
                direction: TDeviceUtils.isMobileScreen(Get.context!)
                    ? Axis.vertical
                    : Axis.horizontal,
                children: parentCategory != null
                    ? parentCategory
                        .where((e) => e['name'] is String)
                        .map((e) => Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      TDeviceUtils.isMobileScreen(Get.context!)
                                          ? 0
                                          : TSizes.xs),
                              child: Chip(
                                  backgroundColor: TColors.primary,
                                  label: Text(
                                    // "${e['name']}",
                                    // ignore: prefer_if_null_operators
                                    e['name'] == null ? '' : e['name'],
                                    style: const TextStyle(color: TColors.white),
                                  ),
                                  padding: const EdgeInsets.all(TSizes.xs)),
                            ))
                        .toList()
                    : [
                        const SizedBox(
                          child: Text("bbb"),
                        )
                      ],
              ),
            ),
          ),
        ),
        // DataCell(category.isFeatured
        //     ? const Icon(Iconsax.heart_circle_copy, color: TColors.primary)
        //     : const Icon(Iconsax.heart)),
        DataCell(
            Text(category.createdAt == null ? '' : category.formattedDate)),
        DataCell(TTableActionButtons(
          onEditPressed: () =>
              Get.toNamed(TRoutes.editCategory, arguments: category),
          onDeletePressed: () => controller.confirmAndDeleteItem(category),
        )),
      ],
    );
  }

  List<Widget> getTextWidgets(data) {
    List<Widget> widgets = [];
    for (int i = 0; i < data.length; i++) {
      if (data.last == data[i]) {
        widgets.add(Text(data[i]));
      } else {
        widgets.add(Text(data[i] + ", "));
      }
    }
    return widgets;
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => controller.filteredItems.length;

  @override
  int get selectedRowCount =>
      controller.selectedRows.where((selected) => selected).length;
}
