// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors, non_constant_identifier_names, unnecessary_import, sized_box_for_whitespace, unused_local_variable, dead_code, unnecessary_brace_in_string_interps, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'package:EcommerceApp/helper/order_invoice.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/ordermodel.dart';
import 'package:EcommerceApp/view/filterpage.dart';
import 'package:EcommerceApp/view/orderdetails.dart';
import 'package:EcommerceApp/view/searchpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/bottomcontroller.dart';
import 'package:EcommerceApp/viewmodel/myordercontoller.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({super.key});

  @override
  State<MyOrderPage> createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  MyOrderscontroller myOrderscontroller = Get.put(MyOrderscontroller());
  BottomController bottomController = Get.put(BottomController());
  bool searchicon = false;
  List<FirebaseOrderModel>? orderModellist = [];
  FirebaseOrderModel? orderModel;
  var data;
  Future<dynamic> ProductsDataGet() async {
    try {
      final list = await ApiClient.instance.getList('/me/orders');
      orderModellist = list.map((e) => FirebaseOrderModel.fromJson(e)).toList();
      orderModellist!.sort((a, b) => (b.createdate ?? DateTime(1970))
          .compareTo(a.createdate ?? DateTime(1970)));
      myOrderscontroller.isLoader = false;
      if (mounted) setState(() {});
    } catch (e) {
      myOrderscontroller.isLoader = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    setState(() {
      myOrderscontroller.isLoader = true;
    });
    Getorderdata().then(
      (value) {
        ProductsDataGet().onError(
          (error, stackTrace) {
            setState(() {
              myOrderscontroller.isLoader = false;
            });
          },
        ).then(
          (value) {
            orderModellist!.sort((a, b) =>
                a.orderDate!.millisecond.compareTo(b.orderDate!.millisecond));

            for (var element in orderModellist!) {
              }
            setState(() {
              myOrderscontroller.isLoader = false;
            });
            // orderModellist!.sort(compare);
          },
        );
      },
    ).onError(
      (error, stackTrace) {
        setState(() {
          myOrderscontroller.isLoader = false;
        });
      },
    );

    super.initState();
  }

  Future Getorderdata() async {
    final SharedPreferences perfs = await SharedPreferences.getInstance();
    myOrderscontroller.userid = perfs.getString(prefrenceKey.userid) ?? "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return myOrderscontroller.isLoader == true
        ? MediaQuery.of(context).size.width > CommonWidget.headerWidth
            ? Scaffold(
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: AppColor.BgColor,
                  child: SingleChildScrollView(
                    child: StickyHeader(
                      header: CommonWidget()
                          .StickyHeaders(context, Refresh: setState),
                      content: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          CommonWidget().Footer(context)
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Scaffold(
                // appBar: AppBar(),
                body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: AppColor.BgColor,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              ))
        : Scaffold(
            backgroundColor: AppColor.BgColor,
            appBar: !Responsive.isMobile(context) &&
                    (MediaQuery.of(context).size.width -
                            MediaQuery.of(context).size.width * 0.15) >=
                        1000
                ? null
                : AppBar(
                    centerTitle: true,
                    title: Text(
                      "My Orders",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    automaticallyImplyLeading: false,
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: AppColor.BgColor,
                    leading: InkWell(
                        overlayColor: WidgetStatePropertyAll(Colors.white),
                        onTap: () {
                          WebAPPNavigation.navigateTo(context: context);
                        },
                        child: CommonWidget().backicon()),
                  ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Responsive.isMobile(context) ||
                      (MediaQuery.of(context).size.width) <
                          CommonWidget.headerWidth
                  ? Column(
                      children: [
                        // searchfiled(),
                        Flexible(
                          fit: FlexFit.tight,
                          child: MyOrderListview(),
                        )
                      ],
                    )
                  : SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: StickyHeader(
                        header: CommonWidget()
                            .StickyHeaders(context, Refresh: setState),
                        content: Column(
                          children: [
                            CommonWidget().backButton(context),
                            orderModellist == null || orderModellist!.isEmpty
                                ? _emptyOrders()
                                : Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 16),
                                    child: Column(
                                      children: [
                                        Text(
                                          "My Orders",
                                          style: TextStyle(
                                              fontFamily: AppFont.heading,
                                              fontSize: 30,
                                              color: AppColor.ink,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(height: 16),
                                        _orderList(),
                                      ],
                                    ),
                                  ),
                            CommonWidget().Footer(context)
                          ],
                        ),
                      ),
                    ),
            ),
          );
  }

  DataRow Pageview(index) {
    return DataRow(
        onSelectChanged: (value) {
          WebAPPNavigation.navigateToroute(
              context: context,
              routename: '/OrderDetails',
              data: {
                'index': index,
                'ordermodel': orderModellist![index],
              },
              screen: OrderDetails(
                index: index,
                ordermodel: orderModellist![index],
              ));
        },
        cells: [
          DataCell(
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width < 1400
                      ? MediaQuery.of(context).size.width * 0.065
                      : MediaQuery.of(context).size.width * 0.07,
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      orderModellist![index].items == null
                          ? ""
                          : '#${(index + 1)}',
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
                ),
              ],
            ),
          ),
          DataCell(
            CommonWidget().TextWidget(
              text: "${(orderModellist![index].Orderid ?? "")} ",
              weight: FontWeight.w700,
              size: Responsive.isMobile(context) ? 14.0 : 18.0,
              color: AppColor.BlackColor,
            ),
          ),
          DataCell(
            CommonWidget().TextWidget(
              text: orderModellist![index].status == null
                  ? ""
                  : orderModellist![index].status!.contains("OrderStatus.")
                      ? orderModellist![index]
                          .status!
                          .replaceAll("OrderStatus.", "")
                      : "${orderModellist![index].status} ",
              weight: FontWeight.w700,
              size: Responsive.isMobile(context) ? 12.0 : 16.0,
              color: AppColor.BlackColor,
            ),
          ),
          DataCell(
            CommonWidget().TextWidget(
                text: "${orderModellist![index].paymentMethod} ",
                weight: FontWeight.w700,
                size: Responsive.isMobile(context) ? 14.0 : 18.0,
                color: AppColor.BlackColor),
          ),
          DataCell(
            CommonWidget().TextWidget(
                text: "${orderModellist![index].items!.length}",
                size: Responsive.isMobile(context) ? 14.0 : 18.0,
                weight: FontWeight.w500),
          ),
          DataCell(
            CommonWidget().TextWidget(
                text:
                    "₹ ${double.parse(orderModellist![index].totalAmount.toString()).round()} ",
                weight: FontWeight.w700,
                size: Responsive.isMobile(context) ? 14.0 : 18.0,
                color: AppColor.viewallcolor),
          ),
        ]);
  }

  SearchWidget() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        WebAPPNavigation.navigateToroute(
            context: context, routename: '/SearchPage', screen: SearchPage());
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColor.whiteColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/image/search.png"))),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Search Furniture",
                  style: TextStyle(
                      color: AppColor.fontColorgrey,
                      fontSize: 16,
                      fontFamily: AppFont.lato),
                )
              ],
            ),
            InkWell(
              overlayColor: WidgetStatePropertyAll(Colors.white),
              onTap: () {
                WebAPPNavigation.navigateToroute(
                    context: context,
                    routename: '/FilterPage',
                    screen: FilterPage());
              },
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/image/filter.png"))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  TableRow ItemsViews() {
    return TableRow(children: [
      TableCell(
        child: CommonWidget().TextWidget(
            text: " Items ",
            weight: FontWeight.w700,
            size: Responsive.isMobile(context) ? 14.0 : 18.0,
            color: AppColor.BlackColor),
      ),
      TableCell(
        child: CommonWidget().TextWidget(
            text: "Color",
            weight: FontWeight.w700,
            size: Responsive.isMobile(context) ? 14.0 : 18.0,
            color: AppColor.BlackColor),
      ),
      TableCell(
        child: CommonWidget().TextWidget(
            text: "Size",
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

  Widget _emptyOrders() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 90,
            width: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColor.blush, shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_outlined,
                size: 40, color: AppColor.primary),
          ),
          SizedBox(height: 20),
          Text("No orders yet",
              style: TextStyle(
                  fontFamily: AppFont.heading,
                  fontSize: 24,
                  color: AppColor.ink,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(
            "When you place an order, it'll appear here\nwith its status and invoice.",
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 14, height: 1.5, color: AppColor.fontColorgrey),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(int index) {
    final order = orderModellist![index];
    final status = (order.status ?? "pending").replaceAll("OrderStatus.", "");
    Color badge;
    switch (status.toLowerCase()) {
      case "delivered":
        badge = AppColor.activeusercolor;
        break;
      case "shipped":
      case "processing":
        badge = AppColor.lightbluecolor;
        break;
      case "cancelled":
        badge = AppColor.redcolor;
        break;
      default:
        badge = AppColor.gold;
    }
    final statusLabel =
        status.isEmpty ? "Pending" : status[0].toUpperCase() + status.substring(1);

    void openDetails() {
      WebAPPNavigation.navigateToroute(
        context: context,
        routename: '/OrderDetails',
        data: {'index': index, 'ordermodel': order},
        screen: OrderDetails(index: index, ordermodel: order),
      );
    }

    return Container(
      constraints: BoxConstraints(maxWidth: 760),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(18),
        border: Appborder.appborder,
        boxShadow: Appshadow.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${order.Orderid ?? ''}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFont.heading,
                          fontSize: 17,
                          color: AppColor.ink,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      order.orderDate != null
                          ? dateFormat.format(order.orderDate!)
                          : '',
                      style: TextStyle(
                          fontSize: 12.5, color: AppColor.fontColorgrey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: badge.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(100)),
                child: Text(statusLabel,
                    style: TextStyle(
                        color: badge,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ],
          ),
          SizedBox(height: 14),
          Divider(color: AppColor.dividercolor, height: 1),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 16, color: AppColor.fontColorgrey),
                      SizedBox(width: 6),
                      Text("${order.items?.length ?? 0} item(s)",
                          style: TextStyle(
                              fontSize: 13, color: AppColor.fontColorgrey)),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.payments_outlined,
                          size: 16, color: AppColor.fontColorgrey),
                      SizedBox(width: 6),
                      Text(order.paymentMethod ?? '',
                          style: TextStyle(
                              fontSize: 13, color: AppColor.fontColorgrey)),
                    ]),
                  ],
                ),
              ),
              Text(
                "₹ ${double.parse(order.totalAmount.toString()).toStringAsFixed(0)}",
                style: TextStyle(
                    fontSize: 18,
                    color: AppColor.primary,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PressableScale(
                  onTap: () => OrderInvoiceApi.downloadInvoice(order),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.dividercolor)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_rounded,
                            size: 18, color: AppColor.ink),
                        SizedBox(width: 8),
                        Text("Download Invoice",
                            style: TextStyle(
                                color: AppColor.ink,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: PressableScale(
                  onTap: openDetails,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        gradient: AppColor.ctaGradient,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text("View Details",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
          orderModellist!.length, (index) => Center(child: _orderCard(index))),
    );
  }

  Widget MyOrderListview() {
    return orderModellist == null || orderModellist!.isEmpty
        ? _emptyOrders()
        : ListView.builder(
            itemCount: orderModellist!.length,
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) => _orderCard(index),
          );
  }

  searchfiled() {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 58,
              // width: MediaQuery.of(context).size.width * 0.9,
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  padding: EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                      color: AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    controller: myOrderscontroller.searchcontoller,
                    onSaved: (newValue) {
                      setState(() {
                        myOrderscontroller.isLoader = true;
                      });
                      // myOrderscontroller.Searchevent(
                      //         title: myOrderscontroller.searchcontoller.text)
                      //     .then((value) {
                      //   // myOrderscontroller.isloader = false;
                      //   setState(() {});
                      // });
                    },
                    onFieldSubmitted: (value) {
                      setState(() {
                        myOrderscontroller.isLoader = true;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          // myOrderscontroller.isFilter = false;
                        }
                      });

                      // setState(() {
                      //   myOrderscontroller.isloader = true;
                      // });
                      // myOrderscontroller.Searchevent(
                      //         title: myOrderscontroller.searchcontoller.text)
                      //     .then((value) {
                      //   setState(() {});
                      // });
                    },
                    decoration: InputDecoration(
                        suffixIcon: searchicon
                            ? InkWell(
                                overlayColor:
                                    WidgetStatePropertyAll(Colors.white),
                                onTap: () {
                                  if (myOrderscontroller
                                      .searchcontoller.text.isNotEmpty) {
                                    myOrderscontroller.searchcontoller.clear();
                                    // setState(() {
                                    //   myOrderscontroller.isloader = true;
                                    // });
                                    // myOrderscontroller.Searchevent(
                                    //         title: myOrderscontroller
                                    //             .searchcontoller.text)
                                    //     .then((value) {
                                    //   // myOrderscontroller.isloader = false;
                                    //   setState(() {});
                                    // });
                                  }
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Image(
                                        image: AssetImage(AppImage.appIcon +
                                            "searchremove.png")),
                                  ),
                                ),
                              )
                            : InkWell(
                                overlayColor:
                                    WidgetStatePropertyAll(Colors.white),
                                onTap: () {
                                  searchicon = true;
                                },
                                child: Icon(
                                  Icons.arrow_circle_right_outlined,
                                  color: AppColor.fontColorgrey,
                                ),
                              ),
                        prefixIcon: Container(
                          height: 30,
                          width: 30,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Image(
                                image: AssetImage(
                                    AppImage.appIcon + "search.png")),
                          ),
                        ),
                        border: InputBorder.none,
                        hintText: "Search Order",
                        hintStyle: TextStyle(
                            color: AppColor.fontColorgrey,
                            fontFamily: AppFont.lato)),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
