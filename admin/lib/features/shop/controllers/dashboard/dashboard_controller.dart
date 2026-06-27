import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/order/order_controller.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/order_model.dart';
import 'package:get/get.dart';

import '../../../../data/abstract/base_data_table_controller.dart';
import '../../../../data/repositories/order/order_repository.dart';
import '../../../../data/repositories/product/product_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/helper_functions.dart';

class DashboardController extends TBaseController<OrderModel> {
  static DashboardController get instance => Get.find();

  final orderController = Get.put(OrderController());
  final RxList<double> weeklySales = <double>[].obs;
  final RxMap<OrderStatus, int> orderStatusData = <OrderStatus, int>{}.obs;
  final RxMap<OrderStatus, double> totalAmounts = <OrderStatus, double>{}.obs;

  // ── Live counts (update in real time from Firestore) ──────────────────
  final RxInt customerCount = 0.obs;
  final RxInt liveOrderCount = 0.obs;
  final RxInt productCount = 0.obs;
  final RxDouble salesTotal = 0.0.obs;

  // Average order value (safe — never NaN).
  double get averageOrderValue =>
      liveOrderCount.value > 0 ? salesTotal.value / liveOrderCount.value : 0.0;

  // ── Real month-over-month growth (this month vs last month) ──────────────
  double _salesInMonth(DateTime ref) => orderController.allItems
      .where((o) =>
          o.orderDate.year == ref.year && o.orderDate.month == ref.month)
      .fold(0.0, (s, o) => s + o.totalAmount);

  int _ordersInMonth(DateTime ref) => orderController.allItems
      .where((o) =>
          o.orderDate.year == ref.year && o.orderDate.month == ref.month)
      .length;

  int _pct(double now, double prev) {
    if (prev == 0) return now > 0 ? 100 : 0;
    return (((now - prev) / prev) * 100).round();
  }

  DateTime get _thisMonth => DateTime.now();
  DateTime get _prevMonth =>
      DateTime(DateTime.now().year, DateTime.now().month - 1, 1);

  int get salesGrowth =>
      _pct(_salesInMonth(_thisMonth), _salesInMonth(_prevMonth));
  int get ordersGrowth => _pct(
      _ordersInMonth(_thisMonth).toDouble(),
      _ordersInMonth(_prevMonth).toDouble());
  int get aovGrowth {
    final n = _ordersInMonth(_thisMonth);
    final p = _ordersInMonth(_prevMonth);
    final aN = n > 0 ? _salesInMonth(_thisMonth) / n : 0.0;
    final aP = p > 0 ? _salesInMonth(_prevMonth) / p : 0.0;
    return _pct(aN, aP);
  }

  // No per-month signup history available from the user list yet.
  int get customersGrowth => 0;

  @override
  void onInit() {
    super.onInit();
    _loadCounts();
  }

  /// Load dashboard counts from the REST API (Node/MongoDB).
  Future<void> _loadCounts() async {
    try {
      final users = await Get.put(UserRepository()).getAllUsers();
      customerCount.value = users.length;
    } catch (_) {}
    try {
      final products = await Get.put(ProductRepository()).getAllProducts();
      productCount.value = products.length;
    } catch (_) {}
    try {
      final orders = await Get.put(OrderRepository()).getAllOrders();
      liveOrderCount.value = orders.length;
      salesTotal.value = orders.fold(0.0, (sum, o) => sum + o.totalAmount);
    } catch (_) {}
  }

  @override
  Future<List<OrderModel>> fetchItems() async {
    // Fetch Orders and ACTUALLY populate the shared OrderController lists.
    // (Previously the awaited result was discarded, so the graphs computed
    //  over an empty list and "Orders Status" stayed stuck on the loader.)
    if (orderController.allItems.isEmpty) {
      final fetched = await orderController.fetchItems();
      orderController.allItems.assignAll(fetched);
      orderController.filteredItems.assignAll(fetched);
      orderController.selectedRows
          .assignAll(List.generate(fetched.length, (index) => false));
    }

    // Reset weeklySales to zeros
    weeklySales.value = List<double>.filled(7, 0.0);

    // Calculate weekly sales
    _calculateWeeklySales();

    // Calculate Order Status counts
    _calculateOrderStatusData();

    return orderController.allItems;
  }

  // Calculate weekly sales
  void _calculateWeeklySales() {
    for (var order in orderController.allItems) {
      final DateTime orderWeekStart =
          THelperFunctions.getStartOfWeek(order.orderDate);

      // Check if the order is within the current week
      if (orderWeekStart.isBefore(DateTime.now()) &&
          orderWeekStart.add(const Duration(days: 7)).isAfter(DateTime.now())) {
        int index = (order.orderDate.weekday - 1) %
            7; // Adjust index based on DateTime weekday representation

        // Ensure the index is non-negative
        index = index < 0 ? index + 7 : index;

        print(
            'OrderDate: ${order.orderDate}, CurrentWeekDay: $orderWeekStart, Index: $index');

        weeklySales[index] += order.totalAmount;
      }
    }

    print('Weekly Sales: $weeklySales');
  }

  // Call this function to calculate Order Status counts
  void _calculateOrderStatusData() {
    // Reset status data
    orderStatusData.clear();

    // Map to store total amounts for each status
    totalAmounts.value = {for (var status in OrderStatus.values) status: 0.0};

    for (var order in orderController.allItems) {
      // Update status count
      final OrderStatus status = order.status;
      orderStatusData[status] = (orderStatusData[status] ?? 0) + 1;

      // Calculate total amounts for each status
      totalAmounts[status] = (totalAmounts[status] ?? 0) + order.totalAmount;
    }

    print('Order Status Data: $orderStatusData');
  }

  String getDisplayStatusName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  @override
  Future<void> deleteItem(OrderModel item) async {}

  @override
  bool containsSearchQuery(OrderModel item, String query) => false;
}
