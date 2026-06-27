import 'package:get/get.dart';

import '../../../features/shop/models/order_model.dart';
import '../../services/api/api_client.dart';

class OrderRepository extends GetxController {
  static OrderRepository get instance => Get.find();

  final ApiClient _api = ApiClient.instance;

  // Get all orders (newest first; parsed defensively).
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final list = await _api.getList('/orders');
      final orders = <OrderModel>[];
      for (final doc in list) {
        try {
          orders.add(OrderModel.fromJson(doc));
        } catch (e) {
          // Skip a malformed order rather than failing the whole screen.
          print("Skipping unparseable order: $e");
        }
      }
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      return orders;
    } catch (e) {
      throw e.toString();
    }
  }

  // Fetch order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final data = await _api.getOne('/orders/$orderId');
      if (data.isEmpty) throw 'Order not found';
      return OrderModel.fromJson(data);
    } catch (e) {
      throw e.toString();
    }
  }

  // Store a new order
  Future<void> addOrder(OrderModel order) async {
    try {
      await _api.post('/orders', order.toJson());
    } catch (e) {
      throw e.toString();
    }
  }

  // Update specific value(s) of an order (e.g. status, delivery date)
  Future<void> updateOrderSpecificValue(
      String orderId, Map<String, dynamic> data) async {
    try {
      await _api.put('/orders/$orderId', data);
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete an order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _api.delete('/orders/$orderId');
    } catch (e) {
      throw e.toString();
    }
  }
}
