import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cwt_ecommerce_admin_panel/features/shop/models/coupan_model.dart';

import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../personalization/models/address_model.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String docId;
  final String userId;
  final String email;
  final String Orderid;
  final String devicetoken;
  String trackingNumber;
  String trackingUrl;
  String? timestamp;
  OrderStatus status;
  final double totalAmount;
  final double shippingCost;
  final double taxCost;
  final DateTime orderDate;
  final String paymentMethod;
  final AddressModel? shippingAddress;
  final AddressModel? billingAddress;
  final DateTime? deliveryDate;
  final List<CartItemModel> items;
  final bool billingAddressSameAsShipping;
  final CoupanModel? couponmodel;

  OrderModel({
    required this.id,
    this.userId = '',
    this.email = '',
    this.devicetoken = '',
    this.docId = '',
    this.Orderid = '',
    this.trackingNumber = '',
    this.trackingUrl = '',
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.shippingCost,
    required this.taxCost,
    required this.orderDate,
    this.paymentMethod = 'Cash on Delivery',
    this.billingAddress,
    this.timestamp,
    this.shippingAddress,
    this.deliveryDate,
    this.couponmodel,
    this.billingAddressSameAsShipping = true,
  });

  String get formattedOrderDate => THelperFunctions.getFormattedDate(orderDate);

  String get formattedDeliveryDate => deliveryDate != null
      ? THelperFunctions.getFormattedDate(deliveryDate!)
      : '';

  String get orderStatusText => status == OrderStatus.delivered
      ? 'Delivered'
      : status == OrderStatus.shipped
          ? 'Shipment on the way'
          : 'Processing';

  /// Static function to create an empty user model.
  static OrderModel empty() => OrderModel(
        id: '',
        items: [],
        orderDate: DateTime.now(),
        timestamp: Timestamp.now().toString(),
        status: OrderStatus.pending,
        totalAmount: 0,
        shippingCost: 0,
        taxCost: 0,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'docId': docId,
      'userId': userId,
      'email': email,
      'Orderid': Orderid,
      'devicetoken': devicetoken,
      'trackingNumber': trackingNumber,
      'trackingUrl': trackingUrl,
      'status': status.toString(), // Enum to string
      'totalAmount': totalAmount,
      'shippingCost': shippingCost,
      'taxCost': taxCost,
      'orderDate': orderDate,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp ?? Timestamp.now().toString(),
      'billingAddress': billingAddress?.toJson(), // Convert AddressModel to map
      'shippingAddress':
          shippingAddress?.toJson(), // Convert AddressModel to map
      'deliveryDate': deliveryDate,
      'billingAddressSameAsShipping': billingAddressSameAsShipping,
      'coupanModel': couponmodel,
      'items': items
          .map((item) => item.toJson())
          .toList(), // Convert CartItemModel to map
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Defensive parse helpers. The storefront and the admin write orders with
  // slightly different field TYPES (e.g. totalAmount is an int on the front,
  // status is a bare string "pending"). A single bad cast used to throw and
  // wipe the WHOLE order list, so every field below is parsed safely.
  // ─────────────────────────────────────────────────────────────────────────

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static OrderStatus _parseStatus(dynamic raw) {
    if (raw == null) return OrderStatus.pending;
    final s = raw.toString().replaceAll('OrderStatus.', '').trim().toLowerCase();
    return OrderStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == s,
      orElse: () => OrderStatus.pending,
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _parseDateNullable(dynamic raw) {
    if (raw == null) return null;
    return _parseDate(raw);
  }

  static AddressModel _safeAddress(dynamic raw) {
    try {
      if (raw is Map) {
        return AddressModel.fromMap(Map<String, dynamic>.from(raw));
      }
    } catch (_) {}
    return AddressModel.empty();
  }

  static List<CartItemModel> _safeItems(dynamic raw) {
    try {
      if (raw is List) {
        final out = <CartItemModel>[];
        for (final itemData in raw) {
          try {
            if (itemData is Map) {
              out.add(CartItemModel.fromJson(Map<String, dynamic>.from(itemData)));
            }
          } catch (_) {}
        }
        return out;
      }
    } catch (_) {}
    return [];
  }

  static CoupanModel? _safeCoupon(dynamic raw) {
    try {
      if (raw is Map) {
        return CoupanModel.fromMap(Map<String, dynamic>.from(raw));
      }
    } catch (_) {}
    return CoupanModel.empty();
  }

  /// Build from a REST API JSON map (Node/MongoDB). Reuses the same defensive
  /// parsers as [fromSnapshot]; id/docId come from the body's id/_id.
  factory OrderModel.fromJson(Map<String, dynamic> data) {
    final id = (data['id'] ?? data['_id'] ?? '').toString();
    return OrderModel(
      docId: id,
      id: id,
      userId: data['userId']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      devicetoken: data['devicetoken']?.toString() ?? '',
      trackingNumber: data['trackingNumber']?.toString() ?? '',
      trackingUrl: data['trackingUrl']?.toString() ?? '',
      status: _parseStatus(data['status']),
      Orderid: data['Orderid']?.toString() ?? '',
      totalAmount: _toDouble(data['totalAmount']),
      timestamp: data['timestamp']?.toString() ?? '',
      shippingCost: _toDouble(data['shippingCost']),
      taxCost: _toDouble(data['taxCost']),
      orderDate: _parseDate(data['orderDate'] ?? data['createdAt']),
      paymentMethod: data['paymentMethod']?.toString() ?? '',
      billingAddressSameAsShipping: data['billingAddressSameAsShipping'] == true,
      billingAddress: _safeAddress(data['billingAddress']),
      shippingAddress: _safeAddress(data['shippingAddress'] ?? data['Address']),
      deliveryDate: _parseDateNullable(data['deliveryDate']),
      couponmodel: _safeCoupon(data['coupanModel']),
      items: _safeItems(data['items']),
    );
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = (snapshot.data() as Map<String, dynamic>?) ?? {};

    return OrderModel(
      docId: snapshot.id,
      id: data['id']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      devicetoken: data['devicetoken']?.toString() ?? '',
      trackingNumber: data['trackingNumber']?.toString() ?? '',
      trackingUrl: data['trackingUrl']?.toString() ?? '',
      status: _parseStatus(data['status']),
      Orderid: data['Orderid']?.toString() ?? '',
      totalAmount: _toDouble(data['totalAmount']),
      timestamp: data['timestamp']?.toString() ?? Timestamp.now().toString(),
      shippingCost: _toDouble(data['shippingCost']),
      taxCost: _toDouble(data['taxCost']),
      orderDate: _parseDate(data['orderDate'] ?? data['createdate']),
      paymentMethod: data['paymentMethod']?.toString() ?? '',
      billingAddressSameAsShipping:
          data['billingAddressSameAsShipping'] == true,
      billingAddress: _safeAddress(data['billingAddress']),
      shippingAddress:
          _safeAddress(data['shippingAddress'] ?? data['Address']),
      deliveryDate: _parseDateNullable(data['deliveryDate']),
      couponmodel: _safeCoupon(data['coupanModel']),
      items: _safeItems(data['items']),
    );
  }
}
