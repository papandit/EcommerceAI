import 'package:cwt_ecommerce_admin_panel/common/widgets/icons/table_action_icon_buttons.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/controllers/Otherbrand/other_brand_controller.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';

class OtherBrandRows extends DataTableSource {
  final controller = OtherBrandController.instance;

  @override
  DataRow? getRow(int index) {
    final brand = controller.filteredItems[index];
    return DataRow2(
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
              //   image: brand.image,
              //   imageType: ImageType.network,
              //   borderRadius: TSizes.borderRadiusMd,
              //   backgroundColor: TColors.primaryBackground,
              // ),

              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Text(
                  brand.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(Get.context!)
                      .textTheme
                      .bodyLarge!
                      .apply(color: TColors.primary),
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              // TRoundedImage(
              //   width: 50,
              //   height: 50,
              //   padding: TSizes.sm,
              //   image: brand.image,
              //   imageType: ImageType.network,
              //   borderRadius: TSizes.borderRadiusMd,
              //   backgroundColor: TColors.primaryBackground,
              // ),

              // const SizedBox(width: TSizes.spaceBtwItems),

              Expanded(
                child: Text(
                  brand.subcategory == ''
                      ? brand.category
                      : "${brand.category} (${brand.subcategory})",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(Get.context!)
                      .textTheme
                      .bodyLarge!
                      .apply(color: TColors.primary),
                ),
              ),
              // Container(
              //   height: 80,
              //   width: 80,
              //   decoration: BoxDecoration(
              //       image: DecorationImage(image: NetworkImage(brand.name))),
              //   // child:
              //   // Image.memory(
              //   //   brand.image!,
              //   //   scale: 2,
              //   // )
              // ),
            ],
          ),
        ),
        // DataCell(
        //   Padding(
        //     padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
        //     child: SingleChildScrollView(
        //       scrollDirection: Axis.vertical,
        //       child: Wrap(
        //         spacing: TSizes.xs,
        //         direction: TDeviceUtils.isMobileScreen(Get.context!)
        //             ? Axis.vertical
        //             : Axis.horizontal,
        //         children: brand.brandCategories != null
        //             ? brand.brandCategories!
        //                 .map((e) => Padding(
        //                       padding: EdgeInsets.only(
        //                           bottom:
        //                               TDeviceUtils.isMobileScreen(Get.context!)
        //                                   ? 0
        //                                   : TSizes.xs),
        //                       child: Chip(
        //                           label: Text(e.name),
        //                           padding: const EdgeInsets.all(TSizes.xs)),
        //                     ))
        //                 .toList()
        //             : [const SizedBox()],
        //       ),
        //     ),
        //   ),
        // ),
        DataCell(
          Row(
            children: [
              // TRoundedImage(
              //   width: 50,
              //   height: 50,
              //   padding: TSizes.sm,
              //   image: brand.image,
              //   imageType: ImageType.network,
              //   borderRadius: TSizes.borderRadiusMd,
              //   backgroundColor: TColors.primaryBackground,
              // ),

              // const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Text(
                  brand.about,
                  maxLines: 2,
                  // overflow: TextOverflow.ellipsis,
                  style: Theme.of(Get.context!)
                      .textTheme
                      .bodyLarge!
                      .apply(color: TColors.primary),
                ),
              ),
            ],
          ),
        ),
        // DataCell(brand.isFeatured
        //     ? const Icon(Iconsax.heart_circle_copy, color: TColors.primary)
        //     : const Icon(Iconsax.heart)),
        DataCell(Text(brand.createdAt != null ? brand.formattedDate : '')),
        DataCell(
          TTableActionButtons(
            onEditPressed: () {
              Get.toNamed(
                TRoutes.otheredit,
                arguments: brand,
                parameters: {
                  "category": brand.category,
                  "subcategory": "${brand.subcategory}",
                  // "image": "${brand.image}",
                  "about": brand.about
                },
              );
            },
            onDeletePressed: () => controller.confirmAndDeleteItem(brand),
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
