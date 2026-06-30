// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_unnecessary_containers, avoid_print, must_be_immutable, unnecessary_import, non_constant_identifier_names, deprecated_member_use

import 'dart:ui';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/model/ordermodel.dart';
import 'package:EcommerceApp/view/myorder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/bottomcontroller.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class OrderDetails extends StatefulWidget {
  OrderDetails({super.key, this.ordermodel, this.index});
  FirebaseOrderModel? ordermodel;
  int? index;
  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final pdf = pw.Document();

  // Variables to store invoice data
  final String companyName = "Liquid Web Dedicated Server";
  final String fromName = "Hardik Vadiya";
  final String fromAddress = "123 Street Address, Bhuj, Gujarat, 390445";
  final String toName = "E-Commerce Web App";
  final String toEmail = "spdadmin@gmail.com";
  final String toPhone = "+123456789";
  final String invoiceNumber = "456";
  final String invoiceDate = "September 4, 2024";
  final String dueDate = "September 18, 2024";
  final String transactionId = "9876543210";
  final List<Map<String, dynamic>> items = [];

  final String totalAmount = "125.00";

  BottomController bottomController = Get.put(BottomController());
  FirebaseOrderModel? orderdetails;
  int orderindex = 0;
  @override
  void initState() {
    orderdetails = widget.ordermodel;
    orderindex = widget.index ?? 0;
    for (var element in (widget.ordermodel?.items ?? [])) {
      final qty = element.quantity ?? 1;
      final price = double.tryParse(element.price.toString()) ?? 0;
      items.add(
        {
          "item": element.title,
          "color": element.color,
          "size": element.size,
          "price": price.toStringAsFixed(0),
          "quantity": qty,
          "totalPrice": (price * qty).toStringAsFixed(0),
        },
      );
    }
    super.initState();
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  companyName,
                  style: pw.TextStyle(
                    fontSize: 24,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text("From: spdadmin@gmail.com"),
                pw.Text(fromAddress),
                pw.SizedBox(height: 10),
                pw.Text("To: ${orderdetails!.email}"),
                pw.Text("Email: ${orderdetails!.email}"),
                pw.Text("Phone: ${orderdetails?.addresslist?.phoneNumber ?? ''}"),
                pw.SizedBox(height: 20),
                pw.Text("Invoice #: $invoiceNumber"),
                pw.Text(
                    "Created: ${DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal())}"),
                pw.Text(
                    "Due:${DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal())}"),
                pw.SizedBox(height: 20),
                pw.Text("Transaction ID: $transactionId"),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  tableWidth: pw.TableWidth.max,
                  columnWidths: {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                    2: pw.FlexColumnWidth(1),
                    3: pw.FlexColumnWidth(1),
                    4: pw.FlexColumnWidth(1),
                    5: pw.FlexColumnWidth(1),
                  },
                  // defaultColumnWidth: pw.IntrinsicColumnWidth(flex: 1),
                  headers: [
                    'Item',
                    'Color',
                    'Size',
                    'Price',
                    'Quantity',
                    'Total Price'
                  ],
                  data: items.map((item) {
                    return [
                      item['item'],
                      pw.Container(
                        width: 20,
                        height: 15,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(int.parse(item['color'])),
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      item['size'],
                      item['price'],
                      item['quantity'],
                      item['totalPrice'],
                    ];
                  }).toList(),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Shipping Cost',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '${orderdetails!.shippingCost}.00',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ]),
                pw.SizedBox(height: 20),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'GST Amount',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '${orderdetails!.taxCost}.00',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ]),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Total: ${double.parse(orderdetails!.totalAmount.toString()).toStringAsFixed(0)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _createAndDownloadPdf(BuildContext context) async {
    try {
      final pdfData = await _generatePdf(PdfPageFormat.a4);

      // For Flutter Web, trigger download
      await Printing.sharePdf(bytes: pdfData, filename: 'invoice.pdf');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Guard against a missing order (e.g. opened directly / page reload) so the
    // page shows a friendly state instead of crashing on a null order.
    if (orderdetails == null) {
      return Scaffold(
        backgroundColor: AppColor.BgColor,
        appBar: AppBar(
          backgroundColor: AppColor.BgColor,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColor.ink),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 56, color: AppColor.fontColorgrey),
              const SizedBox(height: 12),
              Text("Order details aren't available.",
                  style: TextStyle(
                      fontSize: 16,
                      color: AppColor.ink,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => WebAPPNavigation.navigateToroute(
                    context: context,
                    routename: '/MyOrderPage',
                    screen: MyOrderPage()),
                child: Text("Go to My Orders",
                    style: TextStyle(color: AppColor.primary)),
              ),
            ],
          ),
        ),
      );
    }
    return MediaQuery.of(context).size.width > CommonWidget.headerWidth
        ? Scaffold(
            backgroundColor: AppColor.BgColor,
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: AppColor.BgColor,
              child: SingleChildScrollView(
                child: StickyHeader(
                  header:
                      CommonWidget().StickyHeaders(context, Refresh: setState),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(child: _orderTracker()),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              margin: EdgeInsets.only(right: 10),
                              width: MediaQuery.of(context).size.width * 0.65,
                              color: AppColor.BgColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.68,
                                    child: DataTable(
                                      columns: [
                                        DataColumn(
                                          label: Text(
                                            'Items',
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Color',
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Size',
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Price',
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Quantity',
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Total Price',
                                          ),
                                        ),
                                      ],
                                      showCheckboxColumn: false,
                                      border: TableBorder(
                                          horizontalInside:
                                              BorderSide(color: Colors.black38),
                                          left:
                                              BorderSide(color: Colors.black38),
                                          right:
                                              BorderSide(color: Colors.black38),
                                          top: BorderSide(
                                              color: Colors.black38, width: 3),
                                          bottom: BorderSide(
                                              color: Colors.black38, width: 3),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      dataRowHeight: 130,
                                      checkboxHorizontalMargin: 10,
                                      rows: List.generate(
                                          (orderdetails!.items?.length ?? 0),
                                          (index) => Pageview(index)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              )),
                          Container(
                              // height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width * 0.28,
                              color: AppColor.BgColor,
                              child: bottomwidget()),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      CommonWidget().Footer(context)
                    ],
                  ),
                ),
              ),
            ))
        : Scaffold(
            backgroundColor: AppColor.BgColor,
            appBar: AppBar(
              centerTitle: true,
              leading: InkWell(
                  overlayColor: WidgetStatePropertyAll(Colors.white),
                  onTap: () {
                    WebAPPNavigation.navigateTo(context: context);
                  },
                  child: CommonWidget().backicon()),
              title: Text(
                "Order Detail",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              automaticallyImplyLeading: false,
              surfaceTintColor: Colors.transparent,
              backgroundColor: AppColor.BgColor,
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [_orderTracker(), PopularListview(), bottomwidget()],
                ),
              ),
            ),
          );
  }

  // ── Order tracking timeline ─────────────────────────────────────────────
  // Maps the order's status (written by the admin panel) to a visual stage:
  //   pending -> Order Placed | processing -> Packed | shipped -> Shipped
  //   delivered -> Delivered  | cancelled -> dedicated banner
  Widget _orderTracker() {
    final raw = (orderdetails?.status ?? 'pending')
        .replaceAll('OrderStatus.', '')
        .trim()
        .toLowerCase();
    final bool cancelled = raw == 'cancelled';

    const steps = ['Order Placed', 'Packed', 'Shipped', 'Delivered'];
    const stepIcons = [
      Icons.receipt_long_outlined,
      Icons.inventory_2_outlined,
      Icons.local_shipping_outlined,
      Icons.home_rounded,
    ];

    int current;
    switch (raw) {
      case 'processing':
        current = 1;
        break;
      case 'shipped':
        current = 2;
        break;
      case 'delivered':
        current = 3;
        break;
      default:
        current = 0;
    }

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 1100),
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(20),
        border: Appborder.appborder,
        boxShadow: Appshadow.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_outlined,
                  color: AppColor.primary, size: 20),
              SizedBox(width: 8),
              Text(
                "Track Your Order",
                style: TextStyle(
                    fontFamily: AppFont.heading,
                    fontSize: 20,
                    color: AppColor.ink,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            "Order #${orderdetails?.Orderid ?? ''}",
            style: TextStyle(fontSize: 12.5, color: AppColor.fontColorgrey),
          ),
          SizedBox(height: 26),
          cancelled
              ? _cancelledBanner()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(steps.length * 2 - 1, (i) {
                    if (i.isOdd) {
                      final leftStep = i ~/ 2;
                      final done = leftStep < current;
                      return Expanded(
                        child: Container(
                          height: 3,
                          margin: EdgeInsets.only(top: 21),
                          decoration: BoxDecoration(
                            color: done ? AppColor.primary : AppColor.blushDeep,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }
                    final idx = i ~/ 2;
                    return _stepNode(
                        steps[idx], stepIcons[idx], idx < current, idx == current);
                  }),
                ),
        ],
      ),
    );
  }

  Widget _stepNode(String label, IconData icon, bool done, bool active) {
    final bool filled = done || active;
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Container(
            height: 44,
            width: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: filled ? AppColor.ctaGradient : null,
              color: filled ? null : AppColor.blush,
              border: Border.all(
                  color: filled ? Colors.transparent : AppColor.blushDeep,
                  width: 1.5),
              boxShadow: active
                  ? [
                      BoxShadow(
                          color: AppColor.primary.withOpacity(0.35),
                          blurRadius: 12,
                          spreadRadius: 1)
                    ]
                  : null,
            ),
            child: Icon(done ? Icons.check_rounded : icon,
                color: filled ? Colors.white : AppColor.primary, size: 22),
          ),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11.5,
                height: 1.2,
                color: filled ? AppColor.ink : AppColor.fontColorgrey,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _cancelledBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.redcolor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.redcolor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined, color: AppColor.redcolor),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "This order was cancelled. If this is a mistake, please contact support.",
              style: TextStyle(
                  color: AppColor.redcolor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  ordercall() {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 15),
      color: AppColor.whiteColor,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "In Publishing And Graphic Design, Lorem Ipsum Is A Placeholder Text Commonly",
            ),
          ),
          Divider(
            color: AppColor.dividercolor,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Text(
                  "Manage Who Can Access",
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded)
            ],
          ),
        ],
      ),
    );
  }

  DataRow Pageview(index) {
    return DataRow(cells: [
      DataCell(
        Row(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              height: Responsive.isMobile(context) ? 70 : 100,
              width: Responsive.isMobile(context) ? 70 : 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppColor.imagebg,
              ),
              child: CachedNetworkImage(
                fit: BoxFit.contain,
                imageBuilder: (context, imageProvider) {
                  return Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.contain),
                        borderRadius: BorderRadius.circular(10)),
                  );
                },
                imageUrl: orderdetails!.items == null
                    ? ""
                    : orderdetails!.items![index].image ?? "",
                placeholder: (context, url) => Container(
                  height: Responsive.isMobile(context) ? 70 : 100,
                  width: Responsive.isMobile(context) ? 70 : 100,
                  child: Center(
                      child: CircularProgressIndicator(
                    color: AppColor.BlackColor,
                  )),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width < 1400
                  ? MediaQuery.of(context).size.width * 0.065
                  : MediaQuery.of(context).size.width * 0.1,
              padding: EdgeInsets.only(left: 16, top: 15, bottom: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      orderdetails!.items == null
                          ? ""
                          : '${orderdetails!.items![index].title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1.1,
                        color: Colors.black,
                        fontSize: Responsive.isMobile(context) ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    orderdetails!.items == null
                        ? ""
                        : '${orderdetails!.items![index].brandName}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: Responsive.isMobile(context) ? 11 : 15,
                        color: AppColor.fontColorgrey),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      DataCell(
        Container(
          height: 20,
          width: 40,
          constraints: BoxConstraints(maxWidth: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(
                (int.tryParse(orderdetails!.items![index].color ?? "") ?? 0xff000000)),
          ),
        ),
      ),
      DataCell(
        CommonWidget().TextWidget(
            text: "${orderdetails!.items![index].size} ",
            weight: FontWeight.w700,
            size: Responsive.isMobile(context) ? 14.0 : 18.0,
            color: AppColor.viewallcolor),
      ),
      DataCell(
        CommonWidget().TextWidget(
            text:
                "₹ ${double.parse((orderdetails!.items![index].price ?? 0).toString()).toStringAsFixed(0)} ",
            weight: FontWeight.w700,
            size: Responsive.isMobile(context) ? 14.0 : 18.0,
            color: AppColor.viewallcolor),
      ),
      DataCell(
        Row(
          children: [
            CommonWidget().TextWidget(
                text: "    ",
                size: Responsive.isMobile(context) ? 14.0 : 18.0,
                weight: FontWeight.w500),
            CommonWidget().TextWidget(
                text: "${orderdetails!.items![index].quantity}",
                size: Responsive.isMobile(context) ? 14.0 : 18.0,
                weight: FontWeight.w500),
          ],
        ),
      ),
      DataCell(
        CommonWidget().TextWidget(
            text:
                "₹ ${(double.parse((orderdetails!.items![index].price ?? 0).toString()) * (orderdetails!.items![index].quantity ?? 1)).toStringAsFixed(0)} ",
            weight: FontWeight.w700,
            size: Responsive.isMobile(context) ? 14.0 : 18.0,
            color: AppColor.viewallcolor),
      ),
    ]);
  }

  bottomwidget() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
          color: AppColor.imagebg, borderRadius: BorderRadius.circular(20)),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Order Summary",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 16 : 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            orderdetails == null || orderdetails!.Orderid == null
                ? Container()
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order Id",
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 16 : 20,
                              color: AppColor.fontColorgrey),
                        ),
                        Text(
                          orderdetails!.Orderid ?? "",
                          style: TextStyle(
                            color: AppColor.viewallcolor,
                            fontSize: Responsive.isMobile(context) ? 16 : 20,
                          ),
                        ),
                      ],
                    ),
                  ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Subtotal",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 16 : 20,
                        color: AppColor.fontColorgrey),
                  ),
                  Text(
                    "₹ ${orderdetails!.subtotal}",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 16 : 20,
                        color: AppColor.viewallcolor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shipping Cost",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 16 : 20,
                        color: AppColor.fontColorgrey),
                  ),
                  Text(
                    "₹ ${orderdetails!.shippingCost}",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 16 : 20,
                        color: AppColor.viewallcolor),
                  ),
                ],
              ),
            ),
            orderdetails!.coupanModel == null
                ? Container()
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Discount",
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 16 : 20,
                              color: AppColor.fontColorgrey),
                        ),
                        Text(
                          "₹ ${((double.parse(orderdetails!.subtotal ?? "0") * int.parse((orderdetails!.coupanModel!.percentage.isEmpty ? "0" : orderdetails!.coupanModel!.percentage))) * 0.01).toStringAsFixed(0)}",
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 16 : 20,
                              color: AppColor.viewallcolor),
                        ),
                      ],
                    ),
                  ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "GST Amount",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 16 : 20,
                        color: AppColor.fontColorgrey),
                  ),
                  Text(
                    "₹ ${orderdetails!.taxCost}",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 16 : 20,
                        color: AppColor.viewallcolor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 4.0),
              child: Divider(
                color: AppColor.imagebg,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Payment",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.isMobile(context) ? 16 : 20,
                  ),
                ),
                Text(
                  "₹ ${double.parse(orderdetails!.totalAmount.toString()).round()}",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 16 : 20,
                      fontWeight: FontWeight.w600,
                      color: AppColor.viewallcolor),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Divider(
              color: AppColor.BlackColor,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Contect Info",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 16 : 22,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Email : ",
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 16 : 20,
                    ),
                  ),
                  Text(
                    "${orderdetails!.email}",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 16 : 20,
                        color: AppColor.viewallcolor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Phone : ",
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 16 : 20,
                    ),
                  ),
                  Text(
                    "+91 ${orderdetails?.addresslist?.phoneNumber ?? ''}",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 16 : 20,
                        color: AppColor.viewallcolor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order Type : ",
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 16 : 20,
                    ),
                  ),
                  Text(
                    orderdetails!.status == null
                        ? ""
                        : orderdetails!.status!.contains("OrderStatus.")
                            ? orderdetails!.status!
                                .replaceAll("OrderStatus.", "")
                            : "${orderdetails!.status} ",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 16 : 20,
                        color: AppColor.viewallcolor),
                  ),
                ],
              ),
            ),
            if ((orderdetails?.trackingNumber ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tracking No : ",
                      style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 16 : 20),
                    ),
                    Flexible(
                      child: InkWell(
                        onTap: () async {
                          final u = (orderdetails?.trackingUrl ?? '').trim();
                          if (u.isNotEmpty) {
                            await launchUrl(Uri.parse(u),
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text(
                          orderdetails!.trackingNumber!,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 16 : 20,
                              fontWeight: FontWeight.w600,
                              color: AppColor.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Divider(
              color: AppColor.BlackColor,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Shipping Address",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 16 : 22,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                "${orderdetails?.addresslist?.street ?? ''}",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 16 : 20,
                    color: AppColor.fontColorgrey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                "${orderdetails?.addresslist?.phoneNumber ?? ''}",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 16 : 20,
                    color: AppColor.fontColorgrey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                "${orderdetails?.addresslist?.city ?? ''}",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 16 : 20,
                    color: AppColor.fontColorgrey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                "${orderdetails?.addresslist?.state ?? ''}",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 16 : 20,
                    color: AppColor.fontColorgrey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                "${orderdetails?.addresslist?.postalCode ?? ''}",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 16 : 20,
                    color: AppColor.fontColorgrey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                "India",
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 16 : 20,
                    color: AppColor.fontColorgrey),
              ),
            ),
           Center(
  child: InkWell(
    onTap: () => _createAndDownloadPdf(context),
    child: Container(
      height: 70,
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white12,
      ),
      alignment: Alignment.center, // Optional: centers the text within the container
      child: Text(
        "Download",
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    ),
  ),
),


      

            
          ],
        ),
      ),
    );
  }

  TableRow ItemsViews() {
    return TableRow(children: [
      TableCell(
        child: CommonWidget().TextWidget(
            text: "Items ",
            weight: FontWeight.w700,
            size: Responsive.isMobile(context) ? 14.0 : 18.0,
            color: AppColor.BlackColor),
      ),
      TableCell(
        child: CommonWidget().TextWidget(
            text: "Price",
            weight: FontWeight.w700,
            size: Responsive.isMobile(context) ? 14.0 : 18.0,
            color: AppColor.BlackColor),
      ),
      TableCell(
        child: CommonWidget().TextWidget(
            text: "Quantity",
            size: Responsive.isMobile(context) ? 14.0 : 18.0,
            weight: FontWeight.w700),
      ),
      TableCell(
        child: CommonWidget().TextWidget(
            text: "Total Price ",
            weight: FontWeight.w700,
            size: Responsive.isMobile(context) ? 14.0 : 18.0,
            color: AppColor.viewallcolor),
      ),
    ]);
  }

  Widget PopularListview() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: (orderdetails!.items?.length ?? 0),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 13),
          decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(15)),
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: MediaQuery.of(context).size.width < 800
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: Responsive.isMobile(context) ? 70 : 100,
                      width: Responsive.isMobile(context) ? 70 : 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: AppColor.imagebg,
                      ),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        },
                        imageUrl: (orderdetails!.items![index].image ?? ""),
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: AppColor.BlackColor,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    SizedBox(width: 10), // Adds spacing
                    Expanded(
                      // Ensures proper width handling
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${orderdetails!.items![index].title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              height: 1.1,
                              color: Colors.black,
                              fontSize: Responsive.isMobile(context) ? 16 : 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${orderdetails!.items![index].brandName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize:
                                      Responsive.isMobile(context) ? 11 : 15,
                                  color: AppColor.fontColorgrey,
                                ),
                              ),
                              CommonWidget().TextWidget(
                                text:
                                    "₹ ${double.parse(orderdetails!.items![index].price.toString()).toStringAsFixed(0)} ",
                                weight: FontWeight.w700,
                                size:
                                    Responsive.isMobile(context) ? 14.0 : 18.0,
                                color: AppColor.viewallcolor,
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text("Qty: "),
                              Text(
                                "${orderdetails!.items![index].quantity}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              CommonWidget().TextWidget(
                                text:
                                    "₹ ${((orderdetails!.items![index].price ?? 0) * (orderdetails!.items![index].quantity ?? 1)).toStringAsFixed(0)}",
                                weight: FontWeight.w700,
                                size:
                                    Responsive.isMobile(context) ? 14.0 : 18.0,
                                color: AppColor.viewallcolor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )

              //  Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Container(
              //         height: Responsive.isMobile(context) ? 70 : 100,
              //         width: Responsive.isMobile(context) ? 70 : 100,
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(15),
              //           color: AppColor.imagebg,
              //         ),
              //         child: CachedNetworkImage(
              //           fit: BoxFit.cover,
              //           imageBuilder: (context, imageProvider) {
              //             return Container(
              //               decoration: BoxDecoration(
              //                   image: DecorationImage(
              //                       image: imageProvider, fit: BoxFit.cover),
              //                   borderRadius: BorderRadius.circular(10)),
              //             );
              //           },
              //           imageUrl: (orderdetails!.items![index].image ?? ""),
              //           placeholder: (context, url) => Center(
              //               child: CircularProgressIndicator(
              //             color: AppColor.BlackColor,
              //           )),
              //           errorWidget: (context, url, error) => Icon(Icons.error),
              //         ),
              //       ),
              //       Padding(
              //         padding: const EdgeInsets.only(left: 7.0),
              //         child: Column(
              //           // crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Padding(
              //               padding: EdgeInsets.only(bottom: 2.0),
              //               child: Container(
              //                 width: MediaQuery.of(context).size.width * 0.7,
              //                 child: Text(
              //                   '${orderdetails!.items![index].title}',
              //                   maxLines: 1,
              //                   overflow: TextOverflow.ellipsis,
              //                   style: TextStyle(
              //                     height: 1.1,
              //                     color: Colors.black,
              //                     fontSize:
              //                         Responsive.isMobile(context) ? 16 : 20,
              //                     fontWeight: FontWeight.w600,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //               crossAxisAlignment: CrossAxisAlignment.center,
              //               mainAxisSize: MainAxisSize.max,
              //               children: [
              //                 Text(
              //                   '${orderdetails!.items![index].brandName}',
              //                   style: TextStyle(
              //                       fontWeight: FontWeight.w700,
              //                       fontSize:
              //                           Responsive.isMobile(context) ? 11 : 15,
              //                       color: AppColor.fontColorgrey),
              //                 ),
              //                 CommonWidget().TextWidget(
              //                     text:
              //                         "₹ ${double.parse(orderdetails!.items![index].price.toString()).toStringAsFixed(0)} ",
              //                     weight: FontWeight.w700,
              //                     size: Responsive.isMobile(context)
              //                         ? 14.0
              //                         : 18.0,
              //                     color: AppColor.viewallcolor),
              //                 Row(
              //                   children: [
              //                     CommonWidget().TextWidget(
              //                         text: "Qty : ",
              //                         size: Responsive.isMobile(context)
              //                             ? 14.0
              //                             : 18.0,
              //                         weight: FontWeight.w500),
              //                     CommonWidget().TextWidget(
              //                         text:
              //                             "${orderdetails!.items![index].quantity}",
              //                         size: Responsive.isMobile(context)
              //                             ? 14.0
              //                             : 18.0,
              //                         weight: FontWeight.w500),
              //                   ],
              //                 ),
              //                 CommonWidget().TextWidget(
              //                     text:
              //                         "₹ ${double.parse(((orderdetails!.items![index].price ?? 0) * (orderdetails!.items![index].quantity ?? 1).toDouble()).toString()).toStringAsFixed(0)} ",
              //                     weight: FontWeight.w700,
              //                     size: Responsive.isMobile(context)
              //                         ? 14.0
              //                         : 18.0,
              //                     color: AppColor.viewallcolor),
              //               ],
              //             )
              //           ],
              //         ),
              //       ),
              //     ],
              //   )

              : Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: Responsive.isMobile(context) ? 70 : 100,
                          width: Responsive.isMobile(context) ? 70 : 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: AppColor.imagebg,
                          ),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(10)),
                              );
                            },
                            imageUrl: (orderdetails!.items![index].image ?? ""),
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                              color: AppColor.BlackColor,
                            )),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          padding:
                              EdgeInsets.only(left: 16, top: 15, bottom: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 2.0),
                                child: Text(
                                  '${orderdetails!.items![index].title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    height: 1.1,
                                    color: Colors.black,
                                    fontSize:
                                        Responsive.isMobile(context) ? 16 : 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${orderdetails!.items![index].brandName}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize:
                                        Responsive.isMobile(context) ? 11 : 15,
                                    color: AppColor.fontColorgrey),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    CommonWidget().TextWidget(
                        text:
                            "₹ ${double.parse(orderdetails!.items![index].price.toString()).toStringAsFixed(0)} ",
                        weight: FontWeight.w700,
                        size: Responsive.isMobile(context) ? 14.0 : 18.0,
                        color: AppColor.viewallcolor),
                    Spacer(),
                    Row(
                      children: [
                        CommonWidget().TextWidget(
                            text: "Qty : ",
                            size: Responsive.isMobile(context) ? 14.0 : 18.0,
                            weight: FontWeight.w500),
                        CommonWidget().TextWidget(
                            text: "${orderdetails!.items![index].quantity}",
                            size: Responsive.isMobile(context) ? 14.0 : 18.0,
                            weight: FontWeight.w500),
                      ],
                    ),
                    Spacer(),
                    CommonWidget().TextWidget(
                        text:
                            "₹ ${double.parse(((orderdetails!.items![index].price ?? 0) * (orderdetails!.items![index].quantity ?? 1).toDouble()).toString()).toStringAsFixed(0)} ",
                        weight: FontWeight.w700,
                        size: Responsive.isMobile(context) ? 14.0 : 18.0,
                        color: AppColor.viewallcolor),
                  ],
                ),
        );
      },
    );
  }
}
