// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable

import 'dart:convert';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/notifications/get_service_key.dart';
import 'package:cwt_ecommerce_admin_panel/utils/popups/loaders.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/notification/create_notification_controller.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:cwt_ecommerce_admin_panel/utils/validators/validation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';

class CreateNotificationForm extends StatefulWidget {
  const CreateNotificationForm({super.key});

  @override
  State<CreateNotificationForm> createState() => _CreateNotificationFormState();
}

class _CreateNotificationFormState extends State<CreateNotificationForm> {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  final createController = Get.put(CreateNotificationController());
  @override
  void initState() {
    // getToken();
    getDeviceToken();
    getServerKey();
    // PushNotifications.getDeviceToken();
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    super.initState();
  }

  String? token;
  Future getDeviceToken({int maxRetires = 3}) async {
    try {
      // String? token;
      if (kIsWeb) {
        // get the device fcm token
        token = await _firebaseMessaging.getToken(
            vapidKey:
                "BHsAr74qLIi6GxniUI79x0bppGhlR80ZcU-bmusB7ZNDkycuiaRoVNNDp8L8wjLkgYIhRfGsvj_aRz2GxvBe0MY");
        setState(() {});
        print("for web device token: $token");
      } else {
        // get the device fcm token
        token = await _firebaseMessaging.getToken();
        print("for android device token: $token");
      }
      // saveTokentoFirestore(token: token!);
      return token;
    } catch (e) {
      print("failed to get device token");
      if (maxRetires > 0) {
        print("try after 10 sec");
        await Future.delayed(Duration(seconds: 10));
        return getDeviceToken(maxRetires: maxRetires - 1);
      } else {
        return null;
      }
    }
  }

  // String? deviceToken;
  // getToken() async {
  //   deviceToken = await FirebaseMessaging.instance.getToken();
  //   print("Device Token $deviceToken");
  // }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    print('Notification Title${notification!.title}');
    print('Notification Title${notification.body}');
  }

  GetServiceKey getServiceKey = GetServiceKey();
  String accessToken = '';
  getServerKey() async {
    accessToken = await getServiceKey.getServerKeyToken();
    print("server token --- $accessToken");
  }

  Future<void> sendMessageToFcmTopic({title, msg}) async {
    const String topicName = "app_promotion";
    String serverKey = accessToken;
    createController.loading.value = true;
    final message = {
      "message": {
        "token": token,
        "data": {"Title": title, "Descriptions": msg}
      }
    };
    print("json.encode(message)   ${json.encode(message)}");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    };

    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/e-commerce-app-2e61e/messages:send'),
      headers: headers,
      body: json.encode(message),
    );
    if (response.statusCode == 200) {
      createController.loading.value = false;
      Get.back();
      TLoaders.successSnackBar(
          title: 'Congratulations',
          message: 'Message to topic sent successfully!!');

      print("Message to topic sent successfully!!");
    } else {
      createController.loading.value = false;
      print("Failed to send message: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("KKK devide web token $token");
    print("KKK Server Key $accessToken");

    return TRoundedContainer(
      width: 500,
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Form(
        key: createController.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TSizes.sm),
            Text('Create New Notification',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Name Text Field
            TextFormField(
              controller: createController.title,
              validator: (value) => TValidator.validateEmptyText('Name', value),
              decoration: const InputDecoration(
                  labelText: 'Title', prefixIcon: Icon(Iconsax.category)),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              controller: createController.descriptions,
              validator: (value) => TValidator.validateEmptyText('Name', value),
              decoration: const InputDecoration(
                  labelText: 'Descriptions',
                  prefixIcon: Icon(Iconsax.notification)),
            ),
            // Name Text Field

            const SizedBox(height: TSizes.spaceBtwInputFields * 2),

            // Image Uploader & Featured Checkbox

            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: createController.loading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Colors.black,
                      ))
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              sendMessageToFcmTopic(
                                  title: createController.title.text,
                                  msg: createController.descriptions.text);
                            },
                            // onPressed: () => createController.createCoupan(),
                            child: const Text('Submit')),
                      ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields * 2),
          ],
        ),
      ),
    );
  }
}
