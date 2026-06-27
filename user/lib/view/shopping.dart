// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, unnecessary_new, non_constant_identifier_names, use_key_in_widget_constructors, library_private_types_in_public_api, unnecessary_import, must_be_immutable, unnecessary_string_interpolations, sized_box_for_whitespace, avoid_print, unnecessary_this, avoid_function_literals_in_foreach_calls, unnecessary_brace_in_string_interps, unused_local_variable, empty_catches, unused_catch_clause, dead_code, prefer_final_fields, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'package:EcommerceApp/helper/loginshow.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/cartmodels.dart';
import 'package:EcommerceApp/model/cupancode.dart';
import 'package:EcommerceApp/view/checkoutpage.dart';
import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/api/user_data_api.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/bottomcontroller.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:EcommerceApp/viewmodel/shoppingcontroller.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class ShoppingPage extends StatefulWidget {
  Function? refersh;
  ShoppingPage({
    this.refersh,
    super.key,
  });
  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  ShoppingDetailController shoppingDetailController =
      Get.put(ShoppingDetailController());
  BottomController bottomController = Get.put(BottomController());
  Homecontoller homecontoller = Get.put(Homecontoller());
  CoupanModel coupanModel = CoupanModel.empty();

  void refersh() {
    setState(() {});
  }

  String cash_free_create_url = 'https://sandbox.cashfree.com/pg/orders';
  String cash_free_statuscheck_url = 'https://sandbox.cashfree.com/pg/orders/';
  String Order_id = '';
  // TODO: load Cashfree keys from secure config — do not commit real keys.
  String Client_Secret = 'YOUR_CASHFREE_CLIENT_SECRET';
  String Client_ID = 'YOUR_CASHFREE_CLIENT_ID';
  String api_version = '2023-08-01';
  bool isloader = false;
  bool NoDataFound = false;
  CFPaymentGatewayService cfPaymentGatewayService = CFPaymentGatewayService();
  String cartId = '';

  var data;

  Future cartitem() async {
    final SharedPreferences perfs = await SharedPreferences.getInstance();
    shoppingDetailController.userid =
        perfs.getString(prefrenceKey.userid) ?? '';
    if (mounted) setState(() {});
    try {
      final items = await UserDataApi.getCart();
      shoppingDetailController.cartitems.clear();
      shoppingDetailController.amountadder.clear();
      for (final c in items) {
        shoppingDetailController.cartitems.add(c);
        shoppingDetailController.amountadder.add(0);
      }
      shoppingDetailController.cartids =
          items.isNotEmpty ? shoppingDetailController.userid : '';
      CommonWidget.cartitems = shoppingDetailController.cartitems.length;
      if (shoppingDetailController.cartids.isEmpty) {
        CommonWidget.cartitems = 0;
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  GetCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var data = jsonDecode(prefs.getString(prefrenceKey.cartdata)!);
    homecontoller.MyCart = FirebaseCartModel.fromJson(data);
    if (shoppingDetailController.MyCart.cartitems != null &&
        shoppingDetailController.MyCart.cartitems!.isNotEmpty) {
      shoppingDetailController.MyCart.cartitems!.forEach((v) {
        Cartitems data_cart = new Cartitems.fromJson(v.toJson());
        // homecontoller.MyCart.cartitems!.add(data_cart);
        shoppingDetailController.amountadder.add(0);
      });
      setState(() {
        shoppingDetailController.cartids = '';
        CommonWidget.cartitems = homecontoller.MyCart.cartitems!.length;

        if (homecontoller.MyCart.cartitems!.isEmpty) {
          CommonWidget.cartitems = 0;
        }
        if (homecontoller.MyCart.cartitems != null) {
          CommonWidget.cartitems = homecontoller.MyCart.cartitems!.length;
          setState(() {});
        }
      });
    }
  }

  Future cartidchecker() async {
    final SharedPreferences perfs = await SharedPreferences.getInstance();
    homecontoller.cartid = perfs.getString('cartid') ?? "";
    homecontoller.accesstoken = perfs.getString('Accesstoken') ?? "";
    setState(() {});
  }

  Future<String>? storeidMethod() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    shoppingDetailController.cartdata =
        preferences.getString(prefrenceKey.cartdata) ?? "";
    setState(() {});
    if (shoppingDetailController.cartdata.isNotEmpty) {
      print(
          "shoppingDetailController.cartdata =123 ${shoppingDetailController.cartdata}");

      shoppingDetailController.MyCart = FirebaseCartModel.fromJson(
          jsonDecode(shoppingDetailController.cartdata));
      setState(() {});
    }
    isloader = false;
    setState(() {});

    return '';
  }

  taxmanagement() async {
    try {
      final s = await ApiClient.instance.getOne('/settings');
      shoppingDetailController.taxpayment =
          double.tryParse((s['taxRate'] ?? 0).toString()) ?? 0;
      shoppingDetailController.shippingcost =
          (num.tryParse((s['shippingCost'] ?? 0).toString()) ?? 0).toInt();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  void initState() {
    taxmanagement();
    shoppingDetailController.cartitems.clear();
    shoppingDetailController.amountadder.clear();
    shoppingDetailController.subtotal = 0;
    isloader = true;
    if (homecontoller.MyCart.cartitems != null) {
      homecontoller.MyCart.cartitems!.clear();
    }

    storeidMethod()?.then((value) {
      GetCart();
    });

    cfPaymentGatewayService.setCallback(verifyPayment, onError);

    super.initState();
  }

  void verifyPayment(String orderId) {
    Cashfree_CompletePaymetnAPI();
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    CommonToast(
        context: context, title: errorResponse.getMessage(), alignCenter: true);
  }

  void Cashfree_CompletePaymetnAPI() {
    try {
      var header = {
        'X-Client-Secret': Client_Secret,
        'X-Client-Id': Client_ID,
        'x-api-version': api_version,
        'Content-Type': 'application/json'
      };
      http
          .get(
        Uri.parse(cash_free_statuscheck_url + Order_id),
        headers: header,
      )
          .then((http.Response response) {
        var responseDecode = json.decode(response.body);
        if (response.statusCode == 200) {
          if (responseDecode != null) {
            if (responseDecode['order_status'] != null) {
              if (responseDecode['order_status'] == 'PAID') {
                // PurchaseCompletedAPI();
                CommonToast(
                    context: context, title: 'We Done it', alignCenter: true);
              } else {
                CommonToast(
                    context: context,
                    title: 'Something went wrong!',
                    alignCenter: true);
              }
            } else {
              CommonToast(
                  context: context,
                  title: 'Something went wrong!',
                  alignCenter: true);
            }
          } else {
            CommonToast(
                context: context,
                title: 'Something went wrong!',
                alignCenter: true);
          }
        } else {
          CommonToast(
              context: context,
              title: response.reasonPhrase,
              alignCenter: true);
        }
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      CommonToast(
          context: context, title: 'Check My connection', alignCenter: true);
    }
  }

  Future inisalmethod() async {
    setState(() {});
    shoppingDetailController.lister.clear();
    setState(() {});
    for (int i = 0; i <= ManumodelList.length; i++) {
      shoppingDetailController.lister.add(1);
    }

    // isloader = true;
    // setState(() {});
  }

  var datas;

  @override
  Widget build(BuildContext context) {
    return isloader == true
        ? MediaQuery.of(context).size.width > CommonWidget.headerWidth
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
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
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
        : homecontoller.MyCart.cartitems == null ||
                homecontoller.MyCart.cartitems!.isEmpty
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
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Text(
                                    'No Data Found',
                                    style: TextStyle(
                                        color: AppColor.BlackColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
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
                    backgroundColor: AppColor.BgColor,
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text(
                        "Cart",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      automaticallyImplyLeading: false,
                      surfaceTintColor: Colors.transparent,
                      backgroundColor: AppColor.BgColor,
                    ),
                    body: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Text(
                          'No Data Found',
                          style: TextStyle(
                              color: AppColor.BlackColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    bottomNavigationBar:
                        homecontoller.MyCart.cartitems == null ||
                                homecontoller.MyCart.cartitems!.isEmpty
                            ? Container(
                                height: 10,
                              )
                            : bottomwidget())
            : MediaQuery.of(context).size.width > CommonWidget.headerWidth
                ? Scaffold(
                    backgroundColor: AppColor.BgColor,
                    body: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: AppColor.BgColor,
                      child: SingleChildScrollView(
                        child: StickyHeader(
                          header: CommonWidget()
                              .StickyHeaders(context, Refresh: setState),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CommonWidget().backButton(context),
                              CommonWidget().checkoutSteps(context, 0),
              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    "My Bag (${homecontoller.MyCart.cartitems?.length ?? 0} ${(homecontoller.MyCart.cartitems?.length ?? 0) == 1 ? 'item' : 'items'})",
                                    style: TextStyle(
                                        fontFamily: AppFont.heading,
                                        fontSize: 30,
                                        color: AppColor.ink,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.46,
                                      color: AppColor.BgColor,
                                      child: PopularListview()),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.46,
                                      color: AppColor.BgColor,
                                      child: homecontoller
                                              .MyCart.cartitems!.isEmpty
                                          ? Container(
                                              height: 10,
                                            )
                                          : bottomwidget()),
                                ],
                              ),
                              CommonWidget().Footer(context)
                            ],
                          ),
                        ),
                      ),
                    ))
                : Scaffold(
                    backgroundColor: AppColor.BgColor,
                    appBar: CommonWidget().Header(
                        context: context,
                        title: "Cart",
                        heart: false,
                        exit: true,
                        leading: false),
                    body: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: PopularListview(),
                    ),
                    bottomNavigationBar: homecontoller.MyCart.cartitems!.isEmpty
                        ? Container(
                            height: 10,
                          )
                        : bottomwidget());
  }

  Future<List<CoupanModel>> Cupuncodes() async {
    try {
      final list = await ApiClient.instance.getList('/coupons');
      return list.map((e) => CoupanModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  CommonToast({required context, required title, required bool alignCenter}) {
    showToast(
      title,
      backgroundColor: const Color(0xff171D1D),
      textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          fontFamily: 'appbarstyle'),
      context: context,
      alignment: alignCenter ? Alignment.center : Alignment.topCenter,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      textPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      position:
          alignCenter ? StyledToastPosition.top : StyledToastPosition.center,
      duration: const Duration(seconds: 4),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }

  bottomwidget() {
    return Container(
      decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DiscountCode(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Order Summary",
                style: TextStyle(
                    fontFamily: AppFont.heading,
                    color: AppColor.ink,
                    fontSize: Responsive.isMobile(context) ? 18 : 22,
                    fontWeight: FontWeight.w600),
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
                  isdiscount == true
                      ? Row(
                          children: [
                            Text(
                              "₹ ${shoppingDetailController.subtotal.toStringAsFixed(2)}",
                              style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.grey,
                                  fontSize:
                                      Responsive.isMobile(context) ? 16 : 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              "₹ ${shoppingDetailController.discountedsubtotal.toStringAsFixed(2)}",
                              style: TextStyle(
                                  fontSize:
                                      Responsive.isMobile(context) ? 16 : 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.viewallcolor),
                            ),
                          ],
                        )
                      : Text(
                          "₹ ${shoppingDetailController.subtotal.toStringAsFixed(2)}",
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
                    "₹ ${shoppingDetailController.shippingcost}",
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
                    "${((isdiscount == true ? shoppingDetailController.discountedsubtotal : (shoppingDetailController.subtotal)) * (shoppingDetailController.taxpayment * 0.01)).toStringAsFixed(2)}",
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
                  "₹ ${shoppingDetailController.finaltotalpayment.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 16 : 20,
                      fontWeight: FontWeight.w600,
                      color: AppColor.viewallcolor),
                ),
              ],
            ),
            InkWell(
              overlayColor: WidgetStatePropertyAll(Colors.white),
              onTap: () {
                if (homecontoller.userid.isEmpty) {
                  LoginDialog.showLoginDialog(context, () {
                    WebAPPNavigation.navigateToroute(
                        context: context,
                        routename: '/CheckoutPage',
                        data: {
                          'deliveryfee': 0,
                          'coupanmodel':
                              coupanModel.id.isEmpty ? null : coupanModel,
                          'finalamount': shoppingDetailController
                              .finaltotalpayment
                              .round(),
                          'shippingcost': shoppingDetailController
                              .finaltotalpayment
                              .round(),
                          'cartitems': homecontoller.MyCart.cartitems!
                              .map((item) => item)
                              .toList(),
                          'subtotal': shoppingDetailController.subtotal,
                          'discountsubtotal': isdiscount == true
                              ? shoppingDetailController.discountedsubtotal
                              : 0.0,
                        },
                        screen: CheckoutPage(
                          deliveryfee: 0,
                          copunmodel:
                              coupanModel.name.isEmpty ? null : coupanModel,
                          cartitems: homecontoller.MyCart.cartitems!
                              .map((item) => item)
                              .toList(),
                          finalamount: shoppingDetailController
                              .finaltotalpayment
                              .round(),
                          shippingcost: shoppingDetailController
                              .finaltotalpayment
                              .round(),
                          subtotal: shoppingDetailController.subtotal,
                          discountsubtotal: isdiscount == true
                              ? shoppingDetailController.discountedsubtotal
                              : 0.0,
                        ));
                  });
                  return;
                } else {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename: '/CheckoutPage',
                      data: {
                        'deliveryfee': 0,
                        'finalamount':
                            shoppingDetailController.finaltotalpayment.round(),
                        'shippingcost':
                            shoppingDetailController.finaltotalpayment.round(),
                        'cartitems': homecontoller.MyCart.cartitems!
                            .map((item) => item)
                            .toList(),
                        'coupanmodel':
                            coupanModel.name.isEmpty ? null : coupanModel,
                        'subtotal': shoppingDetailController.subtotal,
                        'discountsubtotal': isdiscount == true
                            ? shoppingDetailController.discountedsubtotal
                            : 0.0,
                      },
                      screen: CheckoutPage(
                        copunmodel:
                            coupanModel.name.isEmpty ? null : coupanModel,
                        deliveryfee: 0,
                        cartitems: homecontoller.MyCart.cartitems!,
                        finalamount:
                            shoppingDetailController.finaltotalpayment.round(),
                        shippingcost:
                            shoppingDetailController.finaltotalpayment.round(),
                        subtotal: shoppingDetailController.subtotal,
                        discountsubtotal: isdiscount == true
                            ? shoppingDetailController.discountedsubtotal
                            : 0.0,
                      ));
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                margin: EdgeInsets.only(top: 24, bottom: 50),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColor.btnColorblack),
                child: shoppingDetailController.progress_checkout
                    ? Center(
                        child: CircularProgressIndicator(
                        color: AppColor.whiteColor,
                      ))
                    : Text(
                        "Check Out",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColor.whiteColor,
                            fontSize: Responsive.isMobile(context) ? 18 : 22,
                            fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isdiscount = false;
  Widget DiscountCode() {
    return Container(
      height: 50,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.45,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: isdiscount
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${shoppingDetailController.discountCode.text}",
                  style: TextStyle(
                      color: AppColor.BlackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                InkWell(
                  onTap: () {
                    shoppingDetailController.discountedsubtotal = 0.0;
                    shoppingDetailController.subtotal = shoppingDetailController
                        .amountadder
                        .fold(0, (e, t) => e + t);

                    shoppingDetailController.finaltotalpayment =
                        shoppingDetailController.shippingcost.toDouble() +
                            (shoppingDetailController.subtotal +
                                (shoppingDetailController.subtotal *
                                    (shoppingDetailController.taxpayment *
                                        0.01)));

                    setState(() {
                      isdiscount = false;
                    });
                  },
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.redcolor,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColor.whiteColor,
                      size: 18,
                    ),
                  ),
                ),
              ],
            )
          : TextFormField(
              controller: shoppingDetailController.discountCode,
              // validator: loginController.validateEmail,
              cursorColor: AppColor.fontblack,
              decoration: InputDecoration(
                  suffixIcon: InkWell(
                    overlayColor: WidgetStatePropertyAll(AppColor.BgColor),
                    onTap: () async {
                      coupanModel = CoupanModel.empty();
                      setState(() {});
                      Cupuncodes().then(
                        (value) {
                          List<CoupanModel> coupancodes = value;
                          coupancodes.forEach(
                            (element) {
                              if (shoppingDetailController
                                  .discountCode.text.isEmpty) {
                                setState(() {
                                  isdiscount = false;
                                  // shoppingDetailController.finaltotalpayment =
                                  //     shoppingDetailController.finaltotalpaymentold;
                                });
                                return;
                              }
                              if (element.name ==
                                      shoppingDetailController
                                          .discountCode.text &&
                                  element.isActive == true) {
                                isdiscount = true;
                                coupanModel = element;
                                shoppingDetailController
                                        .finalsubtotalpaymentold =
                                    shoppingDetailController.finaltotalpayment;
                                setState(() {});
                                shoppingDetailController.discountedsubtotal =
                                    shoppingDetailController.subtotal -
                                        (shoppingDetailController.subtotal *
                                            (int.parse(element.percentage) /
                                                100));

                                shoppingDetailController.finaltotalpayment =
                                    shoppingDetailController.shippingcost
                                            .toDouble() +
                                        (shoppingDetailController
                                                .discountedsubtotal +
                                            (shoppingDetailController
                                                    .discountedsubtotal *
                                                (shoppingDetailController
                                                        .taxpayment *
                                                    0.01)));
                                print(
                                    "MATCHED COUPANCODE percentage : ${element.percentage}");
                                print(
                                    "MATCHED COUPANCODE finaltotalpaymentold : ${shoppingDetailController.finaltotalpaymentold}");
                                print(
                                    "MATCHED COUPANCODE finaltotalpayment : ${shoppingDetailController.discountedfinaltotalpayment}");
                                isSnackbarShown = true;
                                setState(() {});
                              } else {
                              }
                            },
                          );
                          if (!isdiscount && !isSnackbarShown) {
                            isSnackbarShown =
                                false; // Ensure snackbar shows only once
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Invalid Coupon Code"),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      );
                    },
                    child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColor.BlackColor,
                      ),
                      margin: EdgeInsets.all(6),
                      child: Center(
                        child: Text(
                          "Apply",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColor.BgColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black12)),
                  hintText: "Giftcard or Discount  code",
                  hintStyle: TextStyle(fontFamily: AppFont.lato)),
              style: TextStyle(
                  fontSize: 14,
                  color: AppColor.fontblack,
                  fontWeight: FontWeight.w500),
            ),
    );
  }

  bool isSnackbarShown = false;
  PopularListview() {
    final bool wide =
        MediaQuery.of(context).size.width > CommonWidget.headerWidth;
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 8),
      physics: wide
          ? NeverScrollableScrollPhysics()
          : AlwaysScrollableScrollPhysics(),
      itemCount: homecontoller.MyCart.cartitems!.length,
      itemBuilder: (context, index) {
        return ListTileItemNew(
          index: index,
          this.refersh,
        );
      },
    );
  }

  Future Cashfree_Order_create_Api({
    required CFPaymentGatewayService cfPaymentGatewayService,
    required String order_amount,
    required String customer_name,
    required String customer_email,
    required String customer_phone,
    required BuildContext context,
  }) async {
    var customer_id = "USER123";
    // isLoading.value = true;
    try {
      var header = {
        'X-Client-Secret': Client_Secret,
        'X-Client-Id': Client_ID,
        'x-api-version': api_version,
        'Content-Type': 'application/json'
      };
      var order_data = {
        'order_amount': order_amount,
        'order_currency': 'INR',
        'customer_details': {
          'customer_id': customer_id,
          'customer_name': customer_name,
          'customer_email': customer_email,
          'customer_phone': customer_phone,
        }
      };

      var body = jsonEncode(order_data);

      http
          .post(Uri.parse(cash_free_create_url), headers: header, body: body)
          .then((http.Response response) {
        var responseDecode = json.decode(response.body);

        if (response.statusCode == 200) {
          if (responseDecode != null) {
            if (responseDecode['order_id'] != null) {
              Order_id = responseDecode['order_id'];
              String payment_session_id = responseDecode['payment_session_id'];

              webCheckout(
                  cfPaymentGatewayService, Order_id, payment_session_id);
            } else {}
          } else {
            CommonToast(
                context: context,
                title: 'Something went wrong!',
                alignCenter: true);
          }
          // isLoading.value = false;
        } else {
          // isLoading.value = false;
          CommonToast(
              context: context,
              title: response.reasonPhrase,
              alignCenter: true);
        }
      });
    } catch (e) {
      // isLoading.value = false;
      // ignore: use_build_context_synchronously
      CommonToast(
          context: context, title: 'Check My connection', alignCenter: true);
    }
  }

  webCheckout(CFPaymentGatewayService cfPaymentGatewayService, String orderID,
      String paymentSessionId) async {
    try {
      var session = createSession(orderID, paymentSessionId);
      setState(() {});
      var cfWebCheckout =
          CFWebCheckoutPaymentBuilder().setSession(session!).build();

      cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {}
  }

  CFSession? createSession(String orderID, String paymentSessionId) {
    try {
      var session = CFSessionBuilder()
          .setEnvironment(CFEnvironment.SANDBOX)
          .setOrderId(orderID)
          .setPaymentSessionId(paymentSessionId)
          .build();
      return session;
    } on CFException catch (e) {}
    return null;
  }
}

class ListTileItemNew extends StatefulWidget {
  Function refersh;
  FirebaseCartModel? firebaseCartModel;
  ListTileItemNew(
    this.refersh, {
    super.key,
    this.index,
    this.firebaseCartModel,
  });

  int? index;
  @override
  _ListTileItemNewState createState() => new _ListTileItemNewState();
}

class _ListTileItemNewState extends State<ListTileItemNew> {
  ShoppingDetailController shoppingDetailController =
      Get.put(ShoppingDetailController());
  Homecontoller homecontoller = Get.put(Homecontoller());
  taxmanagement() async {
    try {
      final s = await ApiClient.instance.getOne('/settings');
      if (mounted) {
        setState(() {
          shoppingDetailController.taxpayment =
              double.tryParse((s['taxRate'] ?? 0).toString()) ?? 0;
        });
      }
    } catch (_) {}
  }

  @override
  void initState() {
    taxmanagement();
    Totolcounter().then(
      (value) {
        setState(() {
          shoppingDetailController.subtotal =
              shoppingDetailController.amountadder.fold(0, (e, t) => e + t);
        });
        print(
            "bsdduhvijsdnvjk 03 subtotal ${shoppingDetailController.subtotal}");
        widget.refersh();

        Future.delayed(Duration(seconds: 1), () {
          shoppingDetailController.finaltotalpayment =
              shoppingDetailController.shippingcost.toDouble() +
                  (shoppingDetailController.subtotal +
                      (shoppingDetailController.subtotal *
                          (shoppingDetailController.taxpayment * 0.01)));
          widget.refersh();
          print(
              "bsdduhvijsdnvjk 0301 ${shoppingDetailController.finaltotalpayment}");
          print(
              "bsdduhvijsdnvjk 0301 ${(shoppingDetailController.taxpayment * 0.01)}");
          print(
              "bsdduhvijsdnvjk 0301 ${(shoppingDetailController.subtotal * (shoppingDetailController.taxpayment * 0.01))}");
          setState(() {});
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 500 ? 10 : 20.0,
              vertical: 9),
          decoration: BoxDecoration(
              color: AppColor.whiteColor,
              border: Appborder.appborder,
              boxShadow: Appshadow.soft,
              borderRadius: BorderRadius.circular(18)),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                height: Responsive.isMobile(context) ? 78 : 104,
                width: Responsive.isMobile(context) ? 78 : 104,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColor.blush,
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
                  imageUrl:
                      "${homecontoller.MyCart.cartitems![widget.index!].image}",
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Container(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width < 500 ? 10 : 16,
                      top: 15,
                      bottom: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          '${homecontoller.MyCart.cartitems![widget.index!].title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 1.1,
                            color: Colors.black,
                            fontSize: Responsive.isMobile(context) ? 16 : 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Color : ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize:
                                        Responsive.isMobile(context) ? 11 : 15,
                                    color: AppColor.BlackColor),
                              ),
                              Container(
                                height: 20,
                                width: 20,
                                constraints: BoxConstraints(maxWidth: 40),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(int.parse(homecontoller.MyCart
                                      .cartitems![widget.index!].color!)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                "Size : ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize:
                                        Responsive.isMobile(context) ? 11 : 15,
                                    color: AppColor.BlackColor),
                              ),
                              CommonWidget().TextWidget(
                                  text:
                                      "${homecontoller.MyCart.cartitems![widget.index!].size} ",
                                  weight: FontWeight.w700,
                                  size: Responsive.isMobile(context)
                                      ? 14.0
                                      : 18.0,
                                  color: AppColor.BlackColor),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(
                            "Price : ",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize:
                                    Responsive.isMobile(context) ? 11 : 15,
                                color: AppColor.BlackColor),
                          ),
                          Flexible(
                            child: Text(
                              '₹ ${double.parse(homecontoller.MyCart.cartitems![widget.index!].price!.toString()).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize:
                                    Responsive.isMobile(context) ? 11 : 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.white),
                onTap: () {
                  int sub_quantity =
                      homecontoller.MyCart.cartitems![widget.index!].quantity!;

                  if (sub_quantity == 1) {
                    return;
                  }

                  sub_quantity = sub_quantity - 1;
                  homecontoller.MyCart.cartitems![widget.index!].quantity =
                      sub_quantity;

                  setState(() {
                    widget.refersh();
                  });
                  if (time != null) {
                    if (time!.isActive) {
                      time!.cancel();
                    }
                  }
                  time = Timer(Duration(seconds: 1), () {
                    setState(() {
                      homecontoller.MyCart.cartitems![widget.index!].quantity =
                          sub_quantity;
                    });

                    Update_quantity(false);
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: CircleAvatar(
                    backgroundColor: AppColor.blush,
                    radius: Responsive.isMobile(context) ? 16 : 18,
                    child: Icon(Icons.remove,
                        size: Responsive.isMobile(context) ? 16 : 18,
                        color: AppColor.primary),
                  ),
                ),
              ),
              CommonWidget().TextWidget(
                  text:
                      "${homecontoller.MyCart.cartitems![widget.index!].quantity}",
                  size: Responsive.isMobile(context) ? 14.0 : 18.0,
                  weight: FontWeight.w500),
              InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.white),
                onTap: () {
                  int sub_quantity =
                      homecontoller.MyCart.cartitems![widget.index!].quantity!;
                  setState(() {
                    sub_quantity = sub_quantity + 1;
                  });
                  homecontoller.MyCart.cartitems![widget.index!].quantity =
                      sub_quantity;

                  widget.refersh();
                  setState(() {});
                  print(
                      "sub_quantity 2: cartitems ${homecontoller.MyCart.cartitems![widget.index!].quantity}");
                  if (time != null) {
                    if (time!.isActive) {
                      time!.cancel();
                    }
                  }
                  time = Timer(Duration(seconds: 1), () {
                    setState(() {
                      homecontoller.MyCart.cartitems![widget.index!].quantity =
                          sub_quantity;
                    });
                    print(
                        "sub_quantity 2: Final ${homecontoller.MyCart.cartitems![widget.index!].quantity}");
                    Update_quantity(false);
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: CircleAvatar(
                    backgroundColor: AppColor.primary,
                    radius: Responsive.isMobile(context) ? 16 : 18,
                    child: Icon(Icons.add,
                        size: Responsive.isMobile(context) ? 16 : 18,
                        color: AppColor.whiteColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 25,
          top: 18,
          child: InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.white),
            onTap: () async {
              // print("CAller ${shoppingDetailController.amountadder.length}");
              // shoppingDetailController.progress_checkout = true;
              homecontoller.MyCart.cartitems!.removeAt(widget.index!);
              shoppingDetailController.amountadder.removeAt(widget.index!);

              setState(() {
                widget.refersh();
              });
              await Totolcounter().then(
                (value) {
                  print(
                      "bsdduhvijsdnvjk 03 subtotal ${shoppingDetailController.subtotal}");
                  setState(() {
                    shoppingDetailController.subtotal = shoppingDetailController
                        .amountadder
                        .fold(0, (e, t) => e + t);
                  });
                  print(
                      "bsdduhvijsdnvjk 03 subtotal ${shoppingDetailController.subtotal}");

                  widget.refersh();
                  print(
                      "cartitems :: ${homecontoller.MyCart.cartitems!.length}");

                  shoppingDetailController.finaltotalpayment =
                      shoppingDetailController.shippingcost.toDouble() +
                          (shoppingDetailController.subtotal +
                              (shoppingDetailController.subtotal *
                                  (shoppingDetailController.taxpayment *
                                      0.01)));
                  widget.refersh();
                  setState(() {});
                  UpdateTocart(homecontoller.MyCart).then(
                    (value) {
                      if (homecontoller.MyCart.cartitems == null ||
                          homecontoller.MyCart.cartitems!.isEmpty) {
                        CommonWidget.cartitems =
                            (homecontoller.MyCart.cartitems == null ||
                                    homecontoller.MyCart.cartitems!.isEmpty)
                                ? 0
                                : homecontoller.MyCart.cartitems!.length;
                        setState(() {});
                      }

                      // CommonWidget();

                      widget.refersh();

                      Beamer.of(context).update();
                      setState(() {});
                    },
                  );
                },
              );
            },
            child: Container(
              height: 22,
              width: 22,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Timer? time;

  increment() {
    shoppingDetailController.amountadder[widget.index!] =
        shoppingDetailController.itemcost;

    int add_quantity = 1;

    setState(() {});
  }

  Future<List<CoupanModel>> Cupuncodes() async {
    try {
      final list = await ApiClient.instance.getList('/coupons');
      return list.map((e) => CoupanModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  CoupanModel coupanModel = CoupanModel.empty();

  Update_quantity(bool remove_item) async {
    await Totolcounter().then(
      (value) {
        setState(() {
          shoppingDetailController.subtotal =
              shoppingDetailController.amountadder.fold(0, (e, t) => e + t);
        });

        widget.refersh();
        shoppingDetailController.finaltotalpayment =
            shoppingDetailController.shippingcost.toDouble() +
                (shoppingDetailController.subtotal +
                    (shoppingDetailController.subtotal *
                        (shoppingDetailController.taxpayment * 0.01)));
        widget.refersh();
        setState(() {});
        UpdateTocart(homecontoller.MyCart);
      },
    );
    await Cupuncodes().then(
      (value) {
        List<CoupanModel> coupancodes = value;
        coupancodes.forEach(
          (element) {
            if (shoppingDetailController.discountCode.text.isEmpty) {
              setState(() {
                // shoppingDetailController.finaltotalpayment =
                //     shoppingDetailController.finaltotalpaymentold;
                widget.refersh();
              });
              return;
            }
            if (element.name == shoppingDetailController.discountCode.text &&
                element.isActive == true) {
              setState(() {});
              coupanModel = element;
              shoppingDetailController.finalsubtotalpaymentold =
                  shoppingDetailController.finaltotalpayment;
              setState(() {});
              shoppingDetailController.discountedsubtotal =
                  shoppingDetailController.subtotal -
                      (shoppingDetailController.subtotal *
                          (int.parse(element.percentage) / 100));
              widget.refersh();
              shoppingDetailController.finaltotalpayment =
                  shoppingDetailController.shippingcost.toDouble() +
                      (shoppingDetailController.discountedsubtotal +
                          (shoppingDetailController.discountedsubtotal *
                              (shoppingDetailController.taxpayment * 0.01)));

              setState(() {});
              widget.refersh();
            } else {
            }
          },
        );
      },
    );
  }

  Future<void> UpdateTocart(FirebaseCartModel cart) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homecontoller.cartdata = JsonEncoder().convert(cart.toJson());
    setState(() {});
    prefs.setString(prefrenceKey.cartdata, homecontoller.cartdata);

    // Persist to the backend (MongoDB).
    await UserDataApi.saveCart(cart.cartitems ?? []);

    if (homecontoller.MyCart.cartitems == null ||
        homecontoller.MyCart.cartitems!.isEmpty) {
      homecontoller.MyCart = FirebaseCartModel();
      setState(() {});
      return;
    }
  }

  Future Totolcounter() async {
    print(
        "homecontoller.MyCart.cartitems! 22 :: ${homecontoller.MyCart.cartitems}");
    homecontoller.MyCart.cartitems!.asMap().forEach(
      (index, element) {
        double amount = 0;

        setState(() {
          amount = double.parse(element.price!.toString()) * element.quantity!;
        });
        shoppingDetailController.amountadder[index] = amount;
      },
    );
  }
}
