import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../routes/routes.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../personalization/models/user_model.dart';
import '../../../../controllers/customer/customer_detail_controller.dart';
import '../widgets/customer_info.dart';
import '../widgets/customer_orders.dart';
import '../widgets/shipping_address.dart';

class CustomerDetailTabletScreen extends StatelessWidget {
  const CustomerDetailTabletScreen({super.key, required this.customer});

  final UserModel customer;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerDetailController());
    controller.customer.value = customer;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs
              TBreadcrumbsWithHeading(
                  returnToPreviousScreen: true, heading: customer.fullName, breadcrumbItems: const [TRoutes.customers, 'Details']),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Body
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Right Side Customer Information
                  Expanded(
                    child: Column(
                      children: [
                        // Customer Info
                        CustomerInfo(customer: customer),
                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Shipping Address
                        const ShippingAddress(),
                      ],
                    ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwSections),

                  // Left Side Customer Orders
                  const Expanded(flex: 2, child: CustomerOrders()),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
