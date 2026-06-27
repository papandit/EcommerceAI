// ignore_for_file: unnecessary_new, unnecessary_this, unnecessary_brace_in_string_interps

import 'package:EcommerceApp/model/addressmodel.dart';
import 'package:EcommerceApp/model/cartmodels.dart';
import 'package:EcommerceApp/model/cupancode.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class FirebaseOrderModel {
  String? id;
  String? userId;
  String? docId;
  String? Orderid;
  String? devicetoken;
  List<Cartitems>? items;
  Addresslist? addresslist;
  Addresslist? billingAddress;
  Addresslist? shippingAddress;
  bool? billingAddressSameAsShipping;
  String? status;
  num? taxCost;
  String? email;
  var totalAmount;
  num? shippingCost;
  String? subtotal;
  DateTime? createdate;
  DateTime? orderDate;
  DateTime? deliveryDate;
  String? paymentMethod;
  String? timestamp;
  String? trackingNumber;
  String? trackingUrl;
  CoupanModel? coupanModel;
  FirebaseOrderModel(
      {this.id,
      this.userId,
      this.docId,
      this.devicetoken,
      this.items,
      this.Orderid,
      this.addresslist,
      this.billingAddressSameAsShipping,
      this.billingAddress,
      this.shippingAddress,
      this.status,
      this.email,
      this.shippingCost,
      this.taxCost,
      this.timestamp,
      this.totalAmount,
      this.subtotal,
      this.createdate,
      this.deliveryDate,
      this.orderDate,
      this.coupanModel,
      this.paymentMethod});

  FirebaseOrderModel.fromJson(Map<String, dynamic> json) {
    // print("SP json ::12 ${json['devicetoken']}");
    id = json['id'] ?? '';
    userId = json['userId'];
    Orderid = json['Orderid'] ?? '';
    docId = json['docId'] ?? '';
    devicetoken = json['devicetoken'];
    status = json['status'];
    createdate = json['createdate'] is String
        ? DateTime.tryParse(json['createdate'])
        : (json['createdate'] is DateTime ? json['createdate'] : null);
    shippingCost = json['shippingCost'];
    timestamp = json['timestamp'];
    trackingNumber = json['trackingNumber'] ?? '';
    trackingUrl = json['trackingUrl'] ?? '';
    paymentMethod = json['paymentMethod'];
    subtotal = json['subtotal'];
    taxCost = json['taxCost'];
    email = json['email'];
    deliveryDate = json['deliveryDate'] is String
        ? DateTime.tryParse(json['deliveryDate'])
        : (json['deliveryDate'] is DateTime ? json['deliveryDate'] : null);
    orderDate = json['orderDate'] is String
        ? DateTime.tryParse(json['orderDate'])
        : (json['orderDate'] is DateTime ? json['orderDate'] : null);
    totalAmount = json['totalAmount'];
    billingAddressSameAsShipping = json['billingAddressSameAsShipping'];
    if (json['items'] != null) {
      items = <Cartitems>[];
      json['items'].forEach((v) {
        items!.add(new Cartitems.fromJson(v));
      });
    }
    // The backend stores shippingAddress/billingAddress (not "Address"), so
    // fall back to those so the order's address is always available.
    final addrJson =
        json['Address'] ?? json['shippingAddress'] ?? json['billingAddress'];
    addresslist =
        addrJson != null ? new Addresslist.fromJson(addrJson) : null;

    billingAddress = json['billingAddress'] != null
        ? new Addresslist.fromJson(json['billingAddress'])
        : null;
    shippingAddress = json['shippingAddress'] != null
        ? new Addresslist.fromJson(json['shippingAddress'])
        : null;
    coupanModel = json['coupanModel'] != null
        ? new CoupanModel.fromJson(json['coupanModel'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['docId'] = this.docId;
    data['devicetoken'] = this.devicetoken;
    data['status'] = this.status;
    data['subtotal'] = this.subtotal;
    data['Orderid'] = this.Orderid;
    data['email'] = this.email;
    data['deliveryDate'] = this.deliveryDate!.toIso8601String();
    data['orderDate'] = this.orderDate!.toIso8601String();
    data['shippingCost'] = this.shippingCost;
    data['taxCost'] = this.taxCost;
    data['timestamp'] = this.timestamp;
    data['totalAmount'] = this.totalAmount;
    data['createdate'] = this.createdate!.toIso8601String();
    data['paymentMethod'] = this.paymentMethod;
    data['billingAddressSameAsShipping'] = this.billingAddressSameAsShipping;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.addresslist != null) {
      data['Address'] = this.addresslist!.toJson();
    }

    if (this.billingAddress != null) {
      data['billingAddress'] = this.billingAddress!.toJson();
    }
    if (this.shippingAddress != null) {
      data['shippingAddress'] = this.shippingAddress!.toJson();
    }
    if (this.coupanModel != null) {
      data['coupanModel'] = this.coupanModel!.toNewJson();
    }
    return data;
  }
}

// class Cartitemsorder {
//   String? brandname;
//   String? image;
//   String? price;
//   String? productid;
//   String? productname;
//   String? quentity;

//   Cartitemsorder(
//       {this.brandname,
//       this.image,
//       this.price,
//       this.productid,
//       this.productname,
//       this.quentity});

//   Cartitemsorder.fromJson(Map<String, dynamic> json) {
//     print("cart json $json");
//     brandname = json['brandname'];
//     image = json['image'];
//     price = json['price'];
//     productid = json['productid'];
//     productname = json['productname'];
//     quentity = json['quentity'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['brandname'] = this.brandname;
//     data['image'] = this.image;
//     data['price'] = this.price;
//     data['productid'] = this.productid;
//     data['productname'] = this.productname;
//     data['quentity'] = this.quentity;
//     return data;
//   }
// }

// class OrderModel {
//   final String id;
//   final String docId;
//   final String userId;
//   OrderStatus status;
//   final double totalAmount;
//   final double shippingCost;
//   final double taxCost;
//   final DateTime orderDate;
//   final String paymentMethod;
//   final AddressModel? shippingAddress;
//   final AddressModel? billingAddress;
//   final DateTime? deliveryDate;
//   final List<CartItemModel> items;
//   final bool billingAddressSameAsShipping;

//   OrderModel({
//     required this.id,
//     this.userId = '',
//     this.docId = '',
//     required this.status,
//     required this.items,
//     required this.totalAmount,
//     required this.shippingCost,
//     required this.taxCost,
//     required this.orderDate,
//     this.paymentMethod = 'Cash on Delivery',
//     this.billingAddress,
//     this.shippingAddress,
//     this.deliveryDate,
//     this.billingAddressSameAsShipping = true,
//   });

//   String get orderStatusText => status == OrderStatus.delivered
//       ? 'Delivered'
//       : status == OrderStatus.shipped
//           ? 'Shipment on the way'
//           : 'Processing';

//   /// Static function to create an empty user model.
//   static OrderModel empty() => OrderModel(
//         id: '',
//         items: [],
//         orderDate: DateTime.now(),
//         status: OrderStatus.pending,
//         totalAmount: 0,
//         shippingCost: 0,
//         taxCost: 0,
//       );

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'status': status.toString(), // Enum to string
//       'totalAmount': totalAmount,
//       'shippingCost': shippingCost,
//       'taxCost': taxCost,
//       'orderDate': orderDate,
//       'paymentMethod': paymentMethod,
//       'billingAddress': billingAddress?.toJson(), // Convert AddressModel to map
//       'shippingAddress':
//           shippingAddress?.toJson(), // Convert AddressModel to map
//       'deliveryDate': deliveryDate,
//       'billingAddressSameAsShipping': billingAddressSameAsShipping,
//       'items': items
//           .map((item) => item.toJson())
//           .toList(), // Convert CartItemModel to map
//     };
//   }

//   factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
//     final data = snapshot.data() as Map<String, dynamic>;

//     return OrderModel(
//       docId: snapshot.id,
//       id: data.containsKey('id') ? data['id'] as String : '',
//       userId: data.containsKey('userId') ? data['userId'] as String : '',
//       status: data.containsKey('status')
//           ? OrderStatus.values.firstWhere((e) => e.toString() == data['status'])
//           : OrderStatus.pending,
//       // Default status
//       totalAmount:
//           data.containsKey('totalAmount') ? data['totalAmount'] as double : 0.0,
//       shippingCost: data.containsKey('shippingCost')
//           ? (data['shippingCost'] as num).toDouble()
//           : 0.0,
//       taxCost: data.containsKey('taxCost')
//           ? (data['taxCost'] as num).toDouble()
//           : 0.0,
//       orderDate: data.containsKey('orderDate')
//           ? (data['orderDate'] as Timestamp).toDate()
//           : DateTime.now(),
//       // Default to current time
//       paymentMethod: data.containsKey('paymentMethod')
//           ? data['paymentMethod'] as String
//           : '',
//       billingAddressSameAsShipping:
//           data.containsKey('billingAddressSameAsShipping')
//               ? data['billingAddressSameAsShipping'] as bool
//               : true,
//       billingAddress: data.containsKey('billingAddress')
//           ? AddressModel.fromMap(data['billingAddress'] as Map<String, dynamic>)
//           : AddressModel.empty(),
//       shippingAddress: data.containsKey('shippingAddress')
//           ? AddressModel.fromMap(
//               data['shippingAddress'] as Map<String, dynamic>)
//           : AddressModel.empty(),
//       deliveryDate:
//           data.containsKey('deliveryDate') && data['deliveryDate'] != null
//               ? (data['deliveryDate'] as Timestamp).toDate()
//               : null,
//       items: data.containsKey('items')
//           ? (data['items'] as List<dynamic>)
//               .map((itemData) =>
//                   CartItemModel.fromJson(itemData as Map<String, dynamic>))
//               .toList()
//           : [],
//     );
//   }
// }
