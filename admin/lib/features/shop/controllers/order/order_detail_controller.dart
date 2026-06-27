import 'package:cwt_ecommerce_admin_panel/data/repositories/order/order_repository.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/order_model.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/user/user_repository.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/models/user_model.dart';

class OrderDetailController extends GetxController {
  static OrderDetailController get instance => Get.find();
  final _orderRepository = Get.put(OrderRepository());
  RxBool loading = true.obs;
  Rx<OrderModel> order = OrderModel.empty().obs;
  Rx<UserModel> customer = UserModel.empty().obs;

  /// Fetch order details by orderId from URL
  Future<void> fetchOrderDetails() async {
    try {
      loading.value = true;

      // Get orderId from URL parameters
      String? orderId = Get.parameters['orderId'];
      if (orderId == null) {
        TLoaders.errorSnackBar(title: "Error", message: "Order ID not found!");
        return;
      }

      // Fetch order details
      final fetchedOrder = await _orderRepository.getOrderById(orderId);
      if (fetchedOrder != null) {
        order.value = fetchedOrder;
      } else {
        TLoaders.errorSnackBar(title: "Error", message: "Order not found!");
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: "Oh Snap!", message: e.toString());
    } finally {
      loading.value = false;
    }
  }

  /// -- Load customer orders
  Future<void> getCustomerOfCurrentOrder() async {
    try {
      // Show loader while loading categories
      loading.value = true;
      // Fetch customer orders & addresses
      final user =
          await UserRepository.instance.fetchUserDetails(order.value.userId);

      customer.value = user;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      loading.value = false;
    }
  }
}
