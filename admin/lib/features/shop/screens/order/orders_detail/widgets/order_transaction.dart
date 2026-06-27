import 'package:cwt_ecommerce_admin_panel/utils/device/device_utility.dart';
import 'package:flutter/material.dart';

import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/image_strings.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../models/order_model.dart';

class OrderTransaction extends StatelessWidget {
  const OrderTransaction({
    super.key,
    required this.order,
  });

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transactions',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Adjust as per your needs
          Row(
            children: [
              Expanded(
                flex: TDeviceUtils.isMobileScreen(context) ? 2 : 1,
                child: Row(
                  children: [
                    const TRoundedImage(
                        imageType: ImageType.asset, image: TImages.payment),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              order.paymentMethod == "COD"
                                  ? ' Cash'
                                  : ' Online',
                              style: Theme.of(context).textTheme.titleLarge),
                          // Adjust your Payment Method Fee if any
                          Text('',
                              style: Theme.of(context).textTheme.labelMedium),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date',
                        style: Theme.of(context).textTheme.labelMedium),
                    Text(order.formattedOrderDate,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total',
                        style: Theme.of(context).textTheme.labelMedium),
                    Text('₹${order.totalAmount}',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
