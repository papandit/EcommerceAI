import 'dart:convert';
import 'package:get/get.dart';
import '../../../../data/abstract/base_data_table_controller.dart';
import '../../../../data/repositories/order/order_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/order_model.dart';
import 'package:http/http.dart' as http;

class OrderController extends TBaseController<OrderModel> {
  static OrderController get instance => Get.find();
  RxBool isSend = false.obs;
  RxBool statusLoader = false.obs;
  var orderStatus = OrderStatus.delivered.obs;

  final _orderRepository = Get.put(OrderRepository());

  @override
  Future<List<OrderModel>> fetchItems() async {
    final data = await _orderRepository.getAllOrders();
    print("Orders fetched = ${data.length}");
    return data;
  }

  /// Lightweight, reliable status update used by the Orders table "Action"
  /// dropdown. Unlike [updateOrderStatus] it does NOT depend on FCM / EmailJS
  /// (which need a live server key) — it just writes the new status to
  /// Firestore and refreshes the table so order tracking always works.
  Future<void> setOrderStatus(OrderModel order, OrderStatus newStatus) async {
    final previous = order.status;
    try {
      statusLoader.value = true;
      order.status = newStatus;
      updateItemFromLists(order);
      await _orderRepository
          .updateOrderSpecificValue(order.docId, {'status': newStatus.toString()});
      orderStatus.value = newStatus;
      TLoaders.successSnackBar(
          title: 'Order Updated',
          message: 'Status set to ${newStatus.name.capitalize}');
    } catch (e) {
      // Roll back the optimistic UI change on failure.
      order.status = previous;
      updateItemFromLists(order);
      TLoaders.warningSnackBar(title: 'Update failed', message: e.toString());
    } finally {
      statusLoader.value = false;
    }
  }

  /// Save a courier tracking number + URL on an order. Mirrors
  /// [setOrderStatus]: optimistic in-memory update, persisted via
  /// [updateOrderSpecificValue], with rollback on failure.
  Future<void> setTracking(OrderModel order, String number, String url) async {
    final previousNumber = order.trackingNumber;
    final previousUrl = order.trackingUrl;
    try {
      statusLoader.value = true;
      order.trackingNumber = number;
      order.trackingUrl = url;
      updateItemFromLists(order);
      await _orderRepository.updateOrderSpecificValue(
          order.docId, {'trackingNumber': number, 'trackingUrl': url});
      TLoaders.successSnackBar(
          title: 'Tracking Updated',
          message: 'Tracking number saved for this order.');
    } catch (e) {
      // Roll back the optimistic UI change on failure.
      order.trackingNumber = previousNumber;
      order.trackingUrl = previousUrl;
      updateItemFromLists(order);
      TLoaders.warningSnackBar(title: 'Update failed', message: e.toString());
    } finally {
      statusLoader.value = false;
    }
  }

  void sortById(int sortColumnIndex, bool ascending) {
    update();
    sortByProperty(sortColumnIndex, ascending,
        (OrderModel o) => o.totalAmount.toString().toLowerCase());
  }

  void sortByDate(int sortColumnIndex, bool ascending) {
    update();
    sortByProperty(sortColumnIndex, ascending,
        (OrderModel o) => o.orderDate.toString().toLowerCase());
  }

// @override
//   bool containsSearchQuery(ProductModel item, String query) {
//     return item.title.toLowerCase().contains(query.toLowerCase()) ||
//         item.brand!.name.toLowerCase().contains(query.toLowerCase()) ||
//         item.stock.toString().contains(query) ||
//         item.price.toString().contains(query);
//   }
  @override
  bool containsSearchQuery(OrderModel item, String query) {
    return item.id.toLowerCase().contains(query.toLowerCase()) ||
        item.totalAmount.toString().contains(query) ||
        item.orderDate.toString().contains(query);
  }

  @override
  Future<void> deleteItem(OrderModel item) async {
    await _orderRepository.deleteOrder(item.docId);
  }

  @override
  void onInit() {
    super.onInit();

    fetchItems();
    sortAscending.value = false; // Initialize here instead of in the widget
  }

  /// Update Product Status
  Future<void> updateOrderStatus(OrderModel order, OrderStatus newStatus,
      {accessToken, devicetoken}) async {
    try {
      statusLoader.value = true;
      order.status = newStatus;
      print("::// ${order.status}");
      await _orderRepository.updateOrderSpecificValue(
          order.docId, {'status': newStatus.toString()});
      updateItemFromLists(order);
      orderStatus.value = newStatus;
      print("::aaaa ${orderStatus.value}");
      print("::order.email${order.email}");
      sendMessageToFcmTopic(
          status: newStatus, accessToken: accessToken, token: devicetoken);
      // Notify the customer by email (admin CC lookup dropped with Firestore).
      SendMail.sendEmail(
        message: "Your item ${order.status} is added successfully !",
        email: order.email,
        ccEmail: '',
      );

      print("::bbbb");
      TLoaders.successSnackBar(
          title: 'Updated', message: 'Order Status Updated');
    } catch (e) {
      TLoaders.warningSnackBar(title: 'Oh Snap33!', message: e.toString());
    } finally {
      statusLoader.value = false;
    }
  }
//====================================================================================
  // GetServiceKey getServiceKey = GetServiceKey();
  // String accessToken = '';
  // getServerKey() async {
  //   accessToken = await getServiceKey.getServerKeyToken();
  //   print("server token --- $accessToken");
  // }

  Future<void> sendMessageToFcmTopic({token, accessToken, status}) async {
    String serverKey = accessToken;
    print("::serverr1 $serverKey");
    print("::token $token");

    final message = {
      "message": {
        "token": token,
        "notification": {
          "title": 'Your item  $status is added successfully !',
          "body": 'Your item  $status is added successfully !',
        }
      }
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    };
    print("::ppp");
    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/e-commerce-app-2e61e/messages:send'),
      headers: headers,
      body: json.encode(message),
    );

    print("::order body ${response.body}");
    print("::body msg ${response.statusCode}");

    if (response.statusCode == 200) {
      print("::body msg ${response.body}");

      print("Message to topic sent successfully!!");
    } else {
      print("Failed to send message: ${response.body}");
    }
  }

//=====================================================================================
  Future<void> sendPushMessage({fcmtoken, status, accessToken}) async {
    try {
      // print("accessToken33 ${accessToken}");

      String serverKey = accessToken;
      print('serverr11 $serverKey');
      // "AAAA0RJf2UE:APA91bE_M-axKmqqoV5EinizvWP4T9bOkmCXAwU8JPFCEQsVCZXBdgsX2Nq_coDtvo49ULywfLtzorKS0TlB-1LxNQhFZRBrbk6hcoD0fgHy-i3ed0ehx7yDaHxYLzjXAt7vO2XDMIBD";
      await http.post(
        // Uri.parse('https://fcm.googleapis.com/fcm/send'),
        Uri.parse('https://fcm.googleapis.com'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$serverKey'
        },
        body: constructFCMPayload(token: fcmtoken, status: status),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

//=====================================================================================
  String constructFCMPayload({token, status}) {
    return jsonEncode({
      'to': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
      },
      'notification': {
        'title': 'Your item  $status is added successfully !',
        'body': 'Please subscribe, like and share this tutorial !',
      },
    });
  }
}

class SendMail {
  static Future<void> sendEmail({
    // required String name,
    required String email,
    required String ccEmail,
    required String message,
  }) async {
    const serviceId = 'service_c1w80ul';
    const templateId = 'template_0ezv0l6';
    const userId = 'g1Fgn3dH9zXwMlCjY';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          // 'user_name': name,
          'user_email': email,
          'cc_email': ccEmail,
          'user_message': message,
        },
      }),
    );

    // Debugging: Print the response body to see any potential errors
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Show success SnackBar and keep the page as it is
      TLoaders.successSnackBar(
          title: "Email Status", message: "Your Email Send");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Email sent successfully!')),
      // );

      // Optional: Clear the form fields after successful submission
    } else {
      TLoaders.warningSnackBar(
          title: "Email Status", message: 'Email not Send');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to send email.')),
      // );
    }
  }
}
