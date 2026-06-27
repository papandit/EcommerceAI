import 'package:cwt_ecommerce_admin_panel/common/widgets/images/t_rounded_image.dart';
import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/enums.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/icons/table_action_icon_buttons.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../controllers/product/product_controller.dart';

class ProductsRows extends DataTableSource {
  final controller = ProductController.instance;

  @override
  DataRow? getRow(int index) {
    final product = controller.filteredItems[index];

    return DataRow2(
      selected: controller.selectedRows[index],
      onTap: () => Get.toNamed("${TRoutes.editProduct}?productId=${product.id}",
          arguments: product),
      onSelectChanged: (value) =>
          controller.selectedRows[index] = value ?? false,
      cells: [
        DataCell(
          Row(
            children: [
              TRoundedImage(
                width: 50,
                height: 50,
                padding: TSizes.xs,
                image: product.thumbnail,
                imageType: ImageType.network,
                borderRadius: TSizes.borderRadiusMd,
                backgroundColor: TColors.primaryBackground,
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Flexible(
                  child: Text(product.title,
                      style: Theme.of(Get.context!)
                          .textTheme
                          .bodyLarge!
                          .apply(color: TColors.primary))),
            ],
          ),
        ),
        // DataCell(Text(controller.getProductStockTotal(product))),
        DataCell(Text(controller.getProductDepartment(product))),
        DataCell(
          Row(
            children: [
              // TRoundedImage(
              //   width: 35,
              //   height: 35,
              //   padding: TSizes.xs,
              //   borderRadius: TSizes.borderRadiusMd,
              //   backgroundColor: TColors.primaryBackground,
              //   imageType:
              //       product.brand != null ? ImageType.network : ImageType.asset,
              //   image: product.brand != null
              //       ? product.brand!.image
              //       : TImages.defaultImage,
              // ),
              // const SizedBox(width: TSizes.spaceBtwItems),
              Flexible(
                  child: Text(product.brand != null ? product.brand!.name : '',
                      style: Theme.of(Get.context!)
                          .textTheme
                          .bodyLarge!
                          .apply(color: TColors.primary))),
            ],
          ),
        ),
        DataCell(Text('₹${controller.getProductPrice(product)}')),
        DataCell(
          Obx(() {
            final count = controller.productRatingCounts[product.id] ?? 0;
            if (count == 0) {
              return Text(
                'No ratings',
                style: Theme.of(Get.context!).textTheme.bodySmall!.apply(
                      color: Colors.grey,
                    ),
              );
            }
            final average = controller.productRatings[product.id] ?? 0.0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: TSizes.iconSm,
                  color: Color(0xffF5A623),
                ),
                const SizedBox(width: TSizes.xs),
                Text(average.toStringAsFixed(1)),
                const SizedBox(width: TSizes.xs),
                Text(
                  '($count)',
                  style: Theme.of(Get.context!).textTheme.bodySmall!.apply(
                        color: Colors.grey,
                      ),
                ),
              ],
            );
          }),
        ),
        DataCell(Text(product.formattedDate)),
        DataCell(
          TTableActionButtons(
            onEditPressed: () => Get.toNamed(
                "${TRoutes.editProduct}?productId=${product.id}",
                arguments: product),
            onDeletePressed: () => controller.confirmAndDeleteItem(product),
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
