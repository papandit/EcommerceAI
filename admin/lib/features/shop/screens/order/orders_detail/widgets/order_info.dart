// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print

import 'package:cwt_ecommerce_admin_panel/common/widgets/shimmers/shimmer.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/order/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/device/device_utility.dart';
import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../models/order_model.dart';

class OrderInfo extends StatefulWidget {
  const OrderInfo({super.key, required this.order});

  final OrderModel order;

  @override
  State<OrderInfo> createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  late final TextEditingController _trackingNumberController;
  late final TextEditingController _trackingUrlController;

  @override
  void initState() {
    _trackingNumberController =
        TextEditingController(text: widget.order.trackingNumber);
    _trackingUrlController =
        TextEditingController(text: widget.order.trackingUrl);
    super.initState();
  }

  @override
  void dispose() {
    _trackingNumberController.dispose();
    _trackingUrlController.dispose();
    super.dispose();
  }

  // Firebase Cloud Messaging removed. The order status update goes through the
  // backend; the (now-optional) customer push is a no-op with an empty token.
  final String accessToken = '';
  final String? token = null;

  // Future<void> sendMessageToFcmTopic({title, msg}) async {
  //   const String topicName = "app_promotion";
  //   String serverKey = accessToken;

  //   final message = {
  //     "message": {
  //       "token": token,
  //       "data": {
  //         "Title": title,
  //         "Descriptions": msg
  //         // "hello": "This is a Firebase Cloud Messaging device group message!"
  //       }
  //     }
  //   };
  //   //  final message_old = {
  //   //     "to": "/topics/$topicName",
  //   //     "notification": {
  //   //       "title": "A new app is available",
  //   //       "body": "Check out our latest app in the app store.",
  //   //     },
  //   //     "android": {
  //   //       "notification": {
  //   //         "title": "A new Android app is available",
  //   //         "body": "Our latest app is available on Google Play store",
  //   //       },
  //   //     },
  //   //   };

  //   // print("json.encode(message)   ${json.encode(message)}");

  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $serverKey',
  //   };

  //   final response = await http.post(
  //     Uri.parse(
  //         'https://fcm.googleapis.com/v1/projects/e-commerce-app-2e61e/messages:send'),
  //     headers: headers,
  //     body: json.encode(message),
  //   );
  //   if (response.statusCode == 200) {
  //     print("Message to topic sent successfully!!");
  //   } else {
  //     print("Failed to send message: ${response.body}");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    print(':: accessToken22 $accessToken');
    print('::  widget.order.devicetoken ${widget.order.devicetoken}');
    print(':: token $token');
    print(':: oder Model ${widget.order}');
    print('::  widget.order.devicetoken//==  ${widget.order.devicetoken}');
    print('::  widget.order.totalAmount//==  ${widget.order.totalAmount}');
    final controller = Get.put(OrderController());
    controller.orderStatus.value = widget.order.status;
    // print("Maya  widget Token ${widget.order.token}");
    return TRoundedContainer(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Information',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: TSizes.spaceBtwSections),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Date'),
                    Text(widget.order.formattedOrderDate,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Items'),
                    Text('${widget.order.items.length} Items',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              Expanded(
                flex: TDeviceUtils.isMobileScreen(context) ? 2 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Status'),
                    Obx(
                      () {
                        if (controller.statusLoader.value)
                          return const TShimmerEffect(
                              width: double.infinity, height: 55);
                        return TRoundedContainer(
                          radius: TSizes.cardRadiusSm,
                          padding: const EdgeInsets.symmetric(
                              horizontal: TSizes.sm, vertical: 0),
                          backgroundColor: THelperFunctions.getOrderStatusColor(
                                  controller.orderStatus.value)
                              .withValues(alpha: 0.1),
                          child: DropdownButton<OrderStatus>(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            value: controller.orderStatus.value,
                            onChanged: (OrderStatus? newValue) {
                              if (newValue != null) {
                                print("bbb");
                                controller.updateOrderStatus(
                                    widget.order, newValue,
                                    accessToken: accessToken,
                                    devicetoken: widget.order.devicetoken);
                              }
                            },
                            items: OrderStatus.values.map((OrderStatus status) {
                              return DropdownMenuItem<OrderStatus>(
                                value: status,
                                child: Text(
                                  status.name.capitalize.toString(),
                                  style: TextStyle(
                                      color:
                                          THelperFunctions.getOrderStatusColor(
                                              controller.orderStatus.value)),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Total'),
                    Text('₹${widget.order.totalAmount}',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Courier Tracking
          Text('Tracking',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: TSizes.spaceBtwItems),
          TextFormField(
            controller: _trackingNumberController,
            decoration: const InputDecoration(
              hintText: 'Tracking Number',
              label: Text('Tracking Number'),
              prefixIcon: Icon(Icons.local_shipping_rounded),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: _trackingUrlController,
            decoration: const InputDecoration(
              hintText: 'Tracking URL',
              label: Text('Tracking URL'),
              prefixIcon: Icon(Icons.link_rounded),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.statusLoader.value
                    ? null
                    : () => controller.setTracking(
                          widget.order,
                          _trackingNumberController.text.trim(),
                          _trackingUrlController.text.trim(),
                        ),
                child: controller.statusLoader.value
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : const Text('Save Tracking'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
