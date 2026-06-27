import 'package:cwt_ecommerce_admin_panel/features/shop/models/order_model.dart';
import 'package:flutter/material.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../widgets/customer_info.dart';
import '../widgets/order_info.dart';
import '../widgets/order_items.dart';
import '../widgets/order_transaction.dart';

class OrderDetailDesktopScreen extends StatelessWidget {
  const OrderDetailDesktopScreen({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    print("Build Order");
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs
              TBreadcrumbsWithHeading(
                  returnToPreviousScreen: true,
                  heading: order.Orderid,
                  breadcrumbItems: const [TRoutes.orders, 'Details']),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Body
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side Order Information
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        // Order Info
                        OrderInfo(order: order),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Items
                        OrderItems(order: order),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Transactions
                        OrderTransaction(order: order)
                      ],
                    ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwSections),

                  // Right Side Order Orders
                  Expanded(
                    child: Column(
                      children: [
                        // Customer Info
                        OrderCustomer(order: order),
                        const SizedBox(height: TSizes.spaceBtwSections),
                        // ElevatedButton(
                        //     onPressed: () {
                        //       Get.to(TableScreen1(
                        //         order: order,
                        //       ));
                        //     },
                        //     child: const Padding(
                        //       padding: const EdgeInsets.all(8.0),
                        //       child: const Text("Invoice Download"),
                        //     ))
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
