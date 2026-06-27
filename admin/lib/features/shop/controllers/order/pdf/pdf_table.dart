// import 'package:cwt_ecommerce_admin_panel/common/widgets/containers/rounded_container.dart';
// import 'package:cwt_ecommerce_admin_panel/common/widgets/data_table/paginated_data_table.dart';
// import 'package:cwt_ecommerce_admin_panel/common/widgets/icons/table_action_icon_buttons.dart';
// import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/notifications/all_notification/table/table_source.dart';
// import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/order/order_controller.dart';
// import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/order/pdf/cutomer_model.dart';
// import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/order/pdf/pdf_service.dart';
// import 'package:cwt_ecommerce_admin_panel/features/shop/models/order_model.dart';
// import 'package:cwt_ecommerce_admin_panel/routes/routes.dart';
// import 'package:cwt_ecommerce_admin_panel/utils/constants/colors.dart';
// import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
// import 'package:cwt_ecommerce_admin_panel/utils/device/device_utility.dart';
// import 'package:cwt_ecommerce_admin_panel/utils/helpers/helper_functions.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';

// // class TableScreen extends StatefulWidget {
// //   //  TableScreen({Key? key}) : super(key: key,);
// //   const TableScreen({super.key, required this.order});
// //   final OrderModel order;
// //   @override
// //   State<TableScreen> createState() => _TableScreenState();
// // }

// // class _TableScreenState extends State<TableScreen> {
// //   final OrderController controller1 = OrderController.instance;
// //   int indexs = 0;
// //   @override
// //   void initState() {
// //     callMethod();
// //     super.initState();
// //   }

// //   void callMethod() {
// //     controller1.filteredItems.asMap().forEach(
// //       (index, element) {
// //         print("widget.order.id${widget.order.id}");
// //         print("element.id${element.id}");
// //         if (widget.order.id == element.id) {
// //           indexs = index;
// //           setState(() {});
// //         }
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         padding: const EdgeInsets.all(8),
// //         margin: const EdgeInsets.all(8),
// //         decoration: BoxDecoration(
// //           border: Border.all(width: 1, color: Colors.grey),
// //         ),
// //         child: SingleChildScrollView(
// //           child: DataTable(
// //             columns: const [
// //               DataColumn(label: Text("formattedDeliveryDate")),
// //               DataColumn(label: Text("deliveryDate")),
// //               DataColumn(label: Text("email")),
// //               DataColumn(label: Text("orderDate")),
// //               DataColumn(label: Text("totalAmount")),
// //             ],
// //             // rows: [
// //             //   DataRow(cells: [
// //             //     DataCell(Text(widget.order.id)),
// //             //     DataCell(Text(widget.order.formattedOrderDate)),
// //             //     DataCell(Text(widget.order.email)),
// //             //     DataCell(Text(widget.order.formattedDeliveryDate)),
// //             //     DataCell(Text(widget.order.shippingAddress!.city)),
// //             //     DataCell(Text("${widget.order.totalAmount}")),
// //             //   ])
// //             // ]
// //             rows: [
// //               DataRow(cells: [
// //                 DataCell(Text(
// //                     controller1.filteredItems[indexs].formattedDeliveryDate)),
// //                 DataCell(
// //                     Text("${controller1.filteredItems[indexs].deliveryDate}")),
// //                 DataCell(Text(controller1.filteredItems[indexs].email)),
// //                 DataCell(
// //                     Text("${controller1.filteredItems[indexs].orderDate}")),
// //                 DataCell(
// //                     Text("${controller1.filteredItems[indexs].totalAmount}")),
// //               ])
// //             ]
// //             // .map((customer) => DataRow(cells: [
// //             //       DataCell(Text(customer.formattedDeliveryDate)),
// //             //       DataCell(Text("${customer.deliveryDate}")),
// //             //       DataCell(Text(customer.email)),
// //             //       DataCell(Text("${customer.orderDate}")),
// //             //       DataCell(Text("${customer.totalAmount}")),
// //             //     ]))
// //             // .toList()
// //             ,
// //           ),
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: () {
// //           PdfService().printCustomersPdf([controller1.filteredItems[indexs]]);
// //         },
// //         child: const Icon(Icons.print),
// //       ),
// //     );
// //   }
// // }

// class TableScreen1 extends StatefulWidget {
//   const TableScreen1({super.key, required this.order});
//   final OrderModel order;
//   @override
//   State<TableScreen1> createState() => _TableScreen1State();
// }

// class _TableScreen1State extends State<TableScreen1> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           PdfService().printCustomersPdf(widget.order);
//         },
//         child: const Icon(Icons.print),
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(8),
//         margin: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           border: Border.all(width: 1, color: Colors.grey),
//         ),
//         child: SingleChildScrollView(
//           child: DataTable(
//             columns: const [
//               DataColumn(label: Text("formattedDeliveryDate")),
//               DataColumn(label: Text("deliveryDate")),
//               DataColumn(label: Text("email")),
//               DataColumn(label: Text("orderDate")),
//               DataColumn(label: Text("totalAmount")),
//             ],
          
//             rows: [
//               DataRow(cells: [
//                 DataCell(Text(widget.order.formattedDeliveryDate)),
//                 DataCell(Text(widget.order.deliveryDate.toString())),
//                 DataCell(Text(widget.order.email)),
//                 DataCell(Text(widget.order.orderDate.toString())),
//                 DataCell(Text(widget.order.totalAmount.toString())),
//               ])
//             ]
//             // .map((customer) => DataRow(cells: [
//             //       DataCell(Text(customer.formattedDeliveryDate)),
//             //       DataCell(Text("${customer.deliveryDate}")),
//             //       DataCell(Text(customer.email)),
//             //       DataCell(Text("${customer.orderDate}")),
//             //       DataCell(Text("${customer.totalAmount}")),
//             //     ]))
//             // .toList()
//             ,
//           ),
//         ),
//       ),
//     );
//   }
// }

































// // class TableScreen extends StatefulWidget {
// //   //  TableScreen({Key? key}) : super(key: key,);
// //   const TableScreen({super.key, required this.order});
// //   final OrderModel order;
// //   @override
// //   State<TableScreen> createState() => _TableScreenState();
// // }

// // class _TableScreenState extends State<TableScreen> {
// //   final OrderController controller1 = OrderController.instance;
// //   int indexs = 0;
// //   @override
// //   void initState() {
// //     callMethod();
// //     super.initState();
// //   }

// //   void callMethod() {
// //     controller1.filteredItems.asMap().forEach(
// //       (index, element) {
// //         print("widget.order.id${widget.order.id}");
// //         print("element.id${element.id}");
// //         if (widget.order.id == element.id) {
// //           indexs = index;
// //           setState(() {});
// //         }
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         padding: const EdgeInsets.all(8),
// //         margin: const EdgeInsets.all(8),
// //         decoration: BoxDecoration(
// //           border: Border.all(width: 1, color: Colors.grey),
// //         ),
// //         child: SingleChildScrollView(
// //           child: DataTable(
// //             columns: const [
// //               DataColumn(label: Text("formattedDeliveryDate")),
// //               DataColumn(label: Text("deliveryDate")),
// //               DataColumn(label: Text("email")),
// //               DataColumn(label: Text("orderDate")),
// //               DataColumn(label: Text("totalAmount")),
// //             ],
// //             // rows: [
// //             //   DataRow(cells: [
// //             //     DataCell(Text(widget.order.id)),
// //             //     DataCell(Text(widget.order.formattedOrderDate)),
// //             //     DataCell(Text(widget.order.email)),
// //             //     DataCell(Text(widget.order.formattedDeliveryDate)),
// //             //     DataCell(Text(widget.order.shippingAddress!.city)),
// //             //     DataCell(Text("${widget.order.totalAmount}")),
// //             //   ])
// //             // ]
// //             rows: [
// //               DataRow(cells: [
// //                 DataCell(Text(
// //                     controller1.filteredItems[indexs].formattedDeliveryDate)),
// //                 DataCell(
// //                     Text("${controller1.filteredItems[indexs].deliveryDate}")),
// //                 DataCell(Text(controller1.filteredItems[indexs].email)),
// //                 DataCell(
// //                     Text("${controller1.filteredItems[indexs].orderDate}")),
// //                 DataCell(
// //                     Text("${controller1.filteredItems[indexs].totalAmount}")),
// //               ])
// //             ]
// //             // .map((customer) => DataRow(cells: [
// //             //       DataCell(Text(customer.formattedDeliveryDate)),
// //             //       DataCell(Text("${customer.deliveryDate}")),
// //             //       DataCell(Text(customer.email)),
// //             //       DataCell(Text("${customer.orderDate}")),
// //             //       DataCell(Text("${customer.totalAmount}")),
// //             //     ]))
// //             // .toList()
// //             ,
// //           ),
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: () {
// //           PdfService().printCustomersPdf([controller1.filteredItems[indexs]]);
// //         },
// //         child: const Icon(Icons.print),
// //       ),
// //     );
// //   }
// // }
