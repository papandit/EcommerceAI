// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_interpolation_to_compose_strings, non_constant_identifier_names, unnecessary_import, sized_box_for_whitespace, avoid_unnecessary_containers, must_be_immutable, unused_local_variable, use_build_context_synchronously, avoid_print, unnecessary_brace_in_string_interps, deprecated_member_use, empty_catches, unused_catch_clause, dead_code, avoid_function_literals_in_foreach_calls

import 'dart:convert';
import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/serverkey.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/addressmodel.dart';
import 'package:EcommerceApp/model/cartmodels.dart';
import 'package:EcommerceApp/model/cupancode.dart';
import 'package:EcommerceApp/model/ordermodel.dart';
import 'package:EcommerceApp/view/addaddress.dart';
import 'package:EcommerceApp/view/myorder.dart';
import 'package:EcommerceApp/view/successpage.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:EcommerceApp/viewmodel/shoppingcontroller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/api/user_data_api.dart';
import 'package:EcommerceApp/helper/payment/razorpay_checkout.dart' as rzpweb;
import 'package:url_launcher/url_launcher.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:http/http.dart' as http;
import 'package:EcommerceApp/viewmodel/checkoutcontroller.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class CheckoutPage extends StatefulWidget {
  CheckoutPage(
      {super.key,
      this.finalamount,
      this.deliveryfee,
      this.shippingcost,
      this.cartitems,
      this.copunmodel,
      this.subtotal,
      this.discountsubtotal});
  int? finalamount;
  int? shippingcost;
  int? deliveryfee;
  List<Cartitems>? cartitems;
  double? subtotal;
  double? discountsubtotal;
  CoupanModel? copunmodel;
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  CheckoutController checkoutController = CheckoutController();
  ShoppingDetailController shoppingDetailController =
      Get.put(ShoppingDetailController());
  String cash_free_create_url = 'https://sandbox.cashfree.com/pg/orders';
  String cash_free_statuscheck_url = 'https://sandbox.cashfree.com/pg/orders/';
  String Order_id = '';
  // TODO: load Cashfree keys from secure config — do not commit real keys.
  String Client_Secret = 'YOUR_CASHFREE_CLIENT_SECRET';
  String Client_ID = 'YOUR_CASHFREE_CLIENT_ID';
  String api_version = '2023-08-01';
  String shiprocket_api_url = 'https://apiv2.shiprocket.in/v1/external/orders/create/adhoc';
  String shiprocket_token = '';
  // String shiprocket_email = 'Jenishcodebuzz@gmail.com'; // Replace with your Shiprocket email

  // String shiprocket_password = 'Jenish@1234'; // Replace with your Shiprocket password
  bool isloader = false;
  CFPaymentGatewayService cfPaymentGatewayService = CFPaymentGatewayService();
  String cartId = '';
  List<Map<String, dynamic>> basic = [];
  List<String> basic_new = [];
  final Map<String, dynamic> someMap = {};
  int selection = 0;
  bool paymentisloader = false;
  CoupanModel copunmodel = CoupanModel.empty();
  Homecontoller homecontoller = Get.put(Homecontoller());

  GetCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homecontoller.cartdata = prefs.getString(prefrenceKey.cartdata) ?? "";
    setState(() {});
    if (homecontoller.cartdata.isNotEmpty) {

      homecontoller.MyCart =
          FirebaseCartModel.fromJson(jsonDecode(homecontoller.cartdata));
    }
    setState(() {});
    if (homecontoller.MyCart.cartitems != null) {
      CommonWidget.cartitems = homecontoller.MyCart.cartitems!.length;
      setState(() {});
    }
  }

  Future taxmanagement() async {
    try {
      final s = await ApiClient.instance.getOne('/settings');
      shoppingDetailController.taxpayment =
          double.tryParse((s['taxRate'] ?? 0).toString()) ?? 0;
      shoppingDetailController.shippingcost =
          (num.tryParse((s['shippingCost'] ?? 0).toString()) ?? 0).toInt();
      if (mounted) setState(() {});
    } catch (_) {}
    return;
  }




  String razorpayKey = '';
  Future getShipRocketIdPassword() async {
    try {
      final value = await ApiClient.instance.getOne('/settings');
      shoppingDetailController.shiprocketid =
          (value['shiprocketid'] ?? '').toString();
      shoppingDetailController.shiprocketpassword =
          (value['shiprocketpassword'] ?? '').toString();
      razorpayKey = (value['razorpaykey'] ?? value['razorpayKey'] ?? '')
          .toString()
          .trim();
      if (mounted) setState(() {});
    } catch (_) {}
  }




  Future DataTranster() async {
    if (widget.cartitems != null) {
      CommonWidget.cartitemsdata = widget.cartitems ?? [];

      CommonWidget.deliveryfee = widget.deliveryfee ?? 0;
      CommonWidget.shippingcost = widget.shippingcost ?? 0;
      checkoutController.cartitems = widget.cartitems ?? [];
      checkoutController.finalamount = widget.finalamount ?? 0;
      checkoutController.deliveryfee = widget.deliveryfee ?? 0;
      checkoutController.shippingcost = widget.shippingcost ?? 0;
      shoppingDetailController.subtotal = widget.subtotal ?? 0;
      shoppingDetailController.discountedsubtotal =
          widget.discountsubtotal ?? 0.0;
      shoppingDetailController.subtotal = widget.subtotal ?? 0.0;

      if (widget.copunmodel != null && widget.copunmodel!.name.isNotEmpty) {
        CommonWidget.finalamount =
            (shoppingDetailController.discountedsubtotal +
                    shoppingDetailController.shippingcost +
                    (shoppingDetailController.discountedsubtotal *
                        (shoppingDetailController.taxpayment * 0.01)))
                .round();
      } else {
        CommonWidget.finalamount = (shoppingDetailController.subtotal +
                shoppingDetailController.shippingcost +
                (shoppingDetailController.subtotal *
                    (shoppingDetailController.taxpayment * 0.01)))
            .round();
      }

      setState(() {});
      print(
          "123443 shippingcost copunmodel subtotal :: ${shoppingDetailController.subtotal}");
      print(
          "123443 shippingcost copunmodel discountedsubtotal :: ${shoppingDetailController.discountedsubtotal}");
      print(
          "123443 shippingcost copunmodel discountedsubtotal :: ${shoppingDetailController.taxpayment}");
      print(
          "123443 shippingcost TEX :: ${(shoppingDetailController.subtotal * (shoppingDetailController.taxpayment * 0.01)).round()}");
      print(
          "123443 shippingcost TEX :: ${(shoppingDetailController.discountedsubtotal * (shoppingDetailController.taxpayment * 0.01)).round()}");

      if (widget.copunmodel != null && widget.copunmodel!.name.isNotEmpty) {
        copunmodel = widget.copunmodel!;
        checkoutController.copunmodel = widget.copunmodel!;
        setState(() {});
        // shoppingDetailController.discountedsubtotal = widget.subtotal ?? 0;
      }
      setState(() {});
      print(
          "123443 shippingcost TEX 09 :: ${(shoppingDetailController.subtotal * (shoppingDetailController.taxpayment * 0.01)).round()}");
    }
  }

  @override
  void initState() {
    getServerKey();
    taxmanagement().then(
      (value) {
        DataTranster();
      },
    );
    GetCart();
    getShipRocketIdPassword();

    checkoutController.isloader = true;
    checkoutController.paymentisloader = false;
    perfrence_verify();
    Addressget().then(
      (value) {
        setState(() {});
        isloader = false;
        checkoutController.isloader = false;
        setState(() {});
      },
    );
    cfPaymentGatewayService.setCallback(verifyPayment, onError);

    super.initState();
  }

  perfrence_verify() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    checkoutController.userid = prefs.getString(prefrenceKey.userid) ?? '';
    checkoutController.Name = prefs.getString(
          "customername",
        ) ??
        "";
    checkoutController.Number = prefs.getString("customernumber") ?? "";
    // setState(() {});
    // isloader = false;
    // checkoutController.isloader = false;
    // setState(() {});

    try {
      final me = await ApiClient.instance.getOne('/auth/me');
      checkoutController.email = (me['Email'] ?? me['email'] ?? '').toString();
      if (mounted) setState(() {});
    } catch (_) {}
    return checkoutController.email;
  }

  void verifyPayment(String orderId) {
    Cashfree_CompletePaymetnAPI();
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    WebAPPNavigation.navigateToroute(
        context: context,
        routename: '/SuccessPage',
        data: {'isSuccess': false},
        screen: SuccessPage(
          isSuccess: false,
        ));

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
                setState(() {
                  isloader = true;
                });
              } else {
                CommonToast(
                    context: context,
                    title: 'Something went wrong!',
                    alignCenter: true);
                WebAPPNavigation.navigateToroute(
                    context: context,
                    routename: '/SuccessPage',
                    data: {'isSuccess': false},
                    screen: SuccessPage(
                      isSuccess: false,
                    ));
              }
            } else {
              CommonToast(
                  context: context,
                  title: 'Something went wrong!',
                  alignCenter: true);
              WebAPPNavigation.navigateToroute(
                  context: context,
                  routename: '/SuccessPage',
                  data: {'isSuccess': false},
                  screen: SuccessPage(
                    isSuccess: false,
                  ));
            }
          } else {
            WebAPPNavigation.navigateToroute(
                context: context,
                routename: '/SuccessPage',
                data: {'isSuccess': false},
                screen: SuccessPage(
                  isSuccess: false,
                ));
            CommonToast(
                context: context,
                title: 'Something went wrong!',
                alignCenter: true);
          }
        } else {
          WebAPPNavigation.navigateToroute(
              context: context,
              routename: '/SuccessPage',
              data: {'isSuccess': false},
              screen: SuccessPage(
                isSuccess: false,
              ));
          CommonToast(
              context: context,
              title: response.reasonPhrase,
              alignCenter: true);
        }
      });
    } catch (e) {
      WebAPPNavigation.navigateToroute(
          context: context,
          routename: '/SuccessPage',
          data: {'isSuccess': false},
          screen: SuccessPage(
            isSuccess: false,
          ));
      CommonToast(
          context: context, title: 'Check My connection', alignCenter: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      "HARDIKSS Access Token :: ${accessToken}",
    );
    print(
      "HARDIKSS Token :: ${token}",
    );
    return isloader || checkoutController.isloader
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
                        content:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          CommonWidget().backButton(context),
                          CommonWidget().checkoutSteps(context, 1),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width * 0.48,
                                color: AppColor.BgColor,
                                child: Column(
                                  children: [
                                    shopingtext(),
                                    address(),
                                  ],
                                ),
                              ),
                              Container(
                                  height: MediaQuery.of(context).size.height,
                                  width:
                                      MediaQuery.of(context).size.width * 0.48,
                                  color: AppColor.BgColor,
                                  child: bottomwidget()),
                            ],
                          ),
                          CommonWidget().Footer(context)
                        ]),
                      ),
                    )),
              )
            : Scaffold(
                backgroundColor: AppColor.BgColor,
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    "Checkout",
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          shopingtext(),
                          address(),
                        ],
                      ),
                    )),
                bottomNavigationBar: bottomwidget(),
              );
  }

  var data;

  Future Addressget() async {
    checkoutController.addresslist.clear();
    final SharedPreferences perfs = await SharedPreferences.getInstance();
    checkoutController.userid = perfs.getString(prefrenceKey.userid) ?? '';
    checkoutController.devicetoken =
        perfs.getString(prefrenceKey.devicetoken) ?? '';
    if (mounted) setState(() {});
    try {
      final list = await UserDataApi.getAddresses();
      for (final v in list) {
        checkoutController.addresslist.add(Addresslist.fromJson(v));
      }
      // Pre-select the first saved address so it's ready ("direct select")
      // and the order's address index is always valid.
      if (checkoutController.addresslist.isNotEmpty &&
          checkoutController.selectedOption < 1) {
        checkoutController.selectedOption = 1;
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Widget addadress() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        WebAPPNavigation.navigateToroute(
            context: context,
            routename: '/DeliveryAdressadds',
            screen: DeliveryAdress(
              addaddress: true,
              onBack: () {
                Addressget();
              },
            ));
      },
      child: Container(
        // height: 50,
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 0.45
            : MediaQuery.of(context).size.width * 0.20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: AppColor.ctaGradient,
            borderRadius: MediaQuery.of(context).size.width <= 700
                ? BorderRadius.circular(12)
                : BorderRadius.circular(14)),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 12),
              child: Text(
                '+ Add New Address',
                style: TextStyle(
                    color: AppColor.whiteColor,
                    fontWeight: FontWeight.w600,
                    fontSize: !Responsive.isMobile(context) ? 16 : 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  address() {
    return Flexible(
        fit: FlexFit.tight,
        flex: 1,
        child: ListView.builder(
          itemCount: checkoutController.addresslist.length,
          itemBuilder: (context, index) {
            return InkWell(
              overlayColor: WidgetStatePropertyAll(Colors.white),
              onTap: () {
                setState(() {
                  checkoutController.selectedOption = index + 1;
                  selection = index;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(15)),
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: Radio(
                        value: index + 1,
                        activeColor: AppColor.BlackColor,
                        fillColor: MaterialStatePropertyAll(
                            checkoutController.selectedOption == index + 1
                                ? AppColor.BlackColor
                                : AppColor.fontColorgrey),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        groupValue: checkoutController.selectedOption,
                        onChanged: (value) {
                          checkoutController.selectedOption = value!;
                          setState(() {});
                        },
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                checkoutController.addresslist[index].name ??
                                    'TITLE',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  height: 1.1,
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                checkoutController.addresslist[index].street ??
                                    'ADDRESS',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.fontColorgrey),
                              ),
                            ),
                            Text(
                              checkoutController
                                      .addresslist[index].phoneNumber ??
                                  '7897948461',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.fontColorgrey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    checkoutController.selectedOption != index + 1
                        ? SizedBox()
                        : InkWell(
                            overlayColor: WidgetStatePropertyAll(Colors.white),
                            onTap: () {
                              WebAPPNavigation.navigateToroute(
                                  context: context,
                                  routename: '/DeliveryAdress',
                                  data: {
                                    'index': index,
                                    'addresslist':
                                        checkoutController.addresslist
                                  },
                                  screen: DeliveryAdress(
                                    index: index,
                                    addresslist: checkoutController.addresslist,
                                    onBack: () {
                                      Addressget();
                                      //add for mobile
                                    },
                                  ));
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                height: 22,
                                width: 22,
                                child: Center(
                                  child: Image.asset(
                                    AppImage.appIcon + "edit.png",
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Paymentmethod() {
    return Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Method",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  paymentlist({methodname, image, ontap}) {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: ontap,
      child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(bottom: 10, top: 10),
          decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColor.BgColor,
                ),
                child: Image.asset(
                  image,
                  height: 25,
                  width: 25,
                ),
              ),
              Text(
                methodname,
                style: TextStyle(
                  color: AppColor.btnColorblack,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ],
          )),
    );
  }

  shopingtext() {
    return Padding(
        padding: EdgeInsets.only(top: 24.0, bottom: 8),
        child: Align(
            alignment: Responsive.isMobile(context)
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: addadress()));
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    showAlertDialog(context, "Payment Failed",
        "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.message.toString()}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    AddOrder(FirebaseOrderModel(
            email: checkoutController.email,
            subtotal: shoppingDetailController.subtotal.round().toString(),
            createdate: DateTime.now(),
            shippingCost: shoppingDetailController.shippingcost
            // .toString()
            ,
            status: "pending",
            taxCost: shoppingDetailController.discountedsubtotal != 0.0
                ? (shoppingDetailController.discountedsubtotal *
                        (shoppingDetailController.taxpayment * 0.01))
                    .round()
                : (shoppingDetailController.subtotal *
                        (shoppingDetailController.taxpayment * 0.01))
                    .round(),
            // .toString()

            totalAmount: CommonWidget.finalamount
            // .toString()
            ,
            devicetoken: checkoutController.devicetoken,
            userId: checkoutController.userid,
            addresslist: checkoutController
                .addresslist[(checkoutController.selectedOption - 1)],
            shippingAddress: checkoutController
                .addresslist[(checkoutController.selectedOption - 1)],
            billingAddress: checkoutController
                .addresslist[(checkoutController.selectedOption - 1)],
            billingAddressSameAsShipping: true,
            deliveryDate: DateTime.now(),
            orderDate: DateTime.now(),
            timestamp: DateTime.now().toIso8601String(),
            id: '',
            docId: '',
            coupanModel: copunmodel,
            paymentMethod: "RozerPay",
            items: widget.cartitems))
        .then(
      (value) async {

        SharedPreferences prefs = await SharedPreferences.getInstance();
        homecontoller.cartdata =
            JsonEncoder().convert(FirebaseCartModel().toJson());
        setState(() {});
        prefs.setString(prefrenceKey.cartdata, homecontoller.cartdata);
        Order_id = value;
        
        // Call Shiprocket API to create shipping order
        await callShiprocketAPI(Order_id);

        // Cart is already cleared by AddOrder() via the API.
        CommonWidget.cartitems = 0;
        setState(() {});
        showAlertDialog(
            context, "Payment Successful", "Thank You For Purchase..");
      },
    );
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
  }

  // Builds the order payload from the current checkout state for the given
  // payment method (COD / RazorPay / Stripe).
  FirebaseOrderModel _buildOrder(String paymentMethod) {
    // Pick the selected address safely (selectedOption is 1-based). Clamp so a
    // stale/zero selection can never throw a RangeError (which would silently
    // abort Place Order).
    final list = checkoutController.addresslist;
    final addr = list[(checkoutController.selectedOption - 1).clamp(0, list.length - 1)];
    return FirebaseOrderModel(
      email: checkoutController.email,
      subtotal: shoppingDetailController.subtotal.round().toString(),
      createdate: DateTime.now(),
      shippingCost: shoppingDetailController.shippingcost,
      status: "pending",
      taxCost: shoppingDetailController.discountedsubtotal != 0.0
          ? (shoppingDetailController.discountedsubtotal *
                  (shoppingDetailController.taxpayment * 0.01))
              .round()
          : (shoppingDetailController.subtotal *
                  (shoppingDetailController.taxpayment * 0.01))
              .round(),
      devicetoken: checkoutController.devicetoken,
      totalAmount: CommonWidget.finalamount,
      userId: checkoutController.userid,
      timestamp: DateTime.now().toIso8601String(),
      addresslist: addr,
      shippingAddress: addr,
      billingAddress: addr,
      billingAddressSameAsShipping: true,
      deliveryDate: DateTime.now(),
      orderDate: DateTime.now(),
      coupanModel: copunmodel,
      id: '',
      docId: '',
      paymentMethod: paymentMethod,
      items: widget.cartitems,
    );
  }

  // Shows the success animation dialog and routes to Home / My Orders.
  // Final "are you sure" confirmation before the order is placed.
  void _confirmAndPlaceOrder() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColor.BgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("Confirm your order",
            style: TextStyle(
                fontWeight: FontWeight.w700, color: AppColor.ink)),
        content: Text(
          "Please review your delivery address and items.\n\nTotal payable: ₹${CommonWidget.finalamount}\n\nDo you want to place this order?",
          style: TextStyle(color: AppColor.fontColorgrey, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
            child: Text("Cancel",
                style: TextStyle(color: AppColor.fontColorgrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(ctx, rootNavigator: true).pop();
              _runSelectedPayment();
            },
            child: const Text("Place Order",
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _runSelectedPayment() {
    // Any synchronous failure here (e.g. building the order payload) must be
    // shown, not swallowed by the button callback — otherwise Place Order looks
    // like it does nothing.
    try {
      final opt = checkoutController.paymentselectedOption;
      if (opt == 1) {
        _placeCodOrder();
      } else if (opt == 2) {
        _payWithRazorpay();
      } else if (opt == 3) {
        _payWithStripe();
      } else {
        showAlertDialog(context, "Select payment", "Please choose a payment method.");
      }
    } catch (e) {
      showAlertDialog(context, "Could not place order", e.toString());
    }
  }

  // COD order → place, then success animation → My Orders.
  void _placeCodOrder() {
    AddOrder(_buildOrder("COD")).then((value) async {
      final prefs = await SharedPreferences.getInstance();
      homecontoller.cartdata =
          JsonEncoder().convert(FirebaseCartModel().toJson());
      prefs.setString(prefrenceKey.cartdata, homecontoller.cartdata);
      homecontoller.MyCart = FirebaseCartModel();
      Order_id = value;
      CommonWidget.cartitems = 0;
      try {
        await callShiprocketAPI(Order_id);
      } catch (_) {}
      if (mounted) setState(() {});
      _showOrderPlaced();
    }).catchError((e) {
      showAlertDialog(context, "Order failed", e.toString());
    });
  }

  bool _orderRedirected = false;
  void _goToMyOrders() {
    WebAPPNavigation.navigateToroute(
        context: context,
        routename: '/MyOrderPage',
        screen: MyOrderPage());
  }

  void _showOrderPlaced() {
    _orderRedirected = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OrderPlacedDialog(
        orderId: Order_id,
        onContinue: () {
          _orderRedirected = true;
          Navigator.of(ctx, rootNavigator: true).pop();
          Future.delayed(const Duration(milliseconds: 200), () {
            WebAPPNavigation.navigateToroute(
                context: context,
                routename: '/HomePage',
                screen: BottomBar(pageindex: 0));
          });
        },
        onViewOrders: () {
          _orderRedirected = true;
          Navigator.of(ctx, rootNavigator: true).pop();
          Future.delayed(const Duration(milliseconds: 200), _goToMyOrders);
        },
      ),
    );
    // Auto-redirect to My Orders after the success animation if the shopper
    // doesn't tap anything.
    Future.delayed(const Duration(seconds: 3), () {
      if (!_orderRedirected && mounted) {
        _orderRedirected = true;
        Navigator.of(context, rootNavigator: true).maybePop();
        Future.delayed(const Duration(milliseconds: 200), _goToMyOrders);
      }
    });
  }

  // Razorpay success → place the order, then show the success animation.
  void handlePaymentSuccessResponse2(String paymentId) {
    AddOrder(_buildOrder("RazorPay")).then((value) async {
      Order_id = value;
      CommonWidget.cartitems = 0;
      try {
        await callShiprocketAPI(Order_id);
      } catch (_) {}
      if (mounted) setState(() {});
      _showOrderPlaced();
    });
  }

  // Places the order directly and shows the success flow — used when an online
  // gateway isn't configured so every payment option still completes.
  void _acceptOnlineFallback(String method) {
    AddOrder(_buildOrder(method)).then((value) async {
      Order_id = value;
      CommonWidget.cartitems = 0;
      try {
        await callShiprocketAPI(Order_id);
      } catch (_) {}
      if (mounted) setState(() {});
      _showOrderPlaced();
    });
  }

  // Razorpay: create the order server-side, open checkout, verify the
  // signature on the backend, then confirm. Falls back to accepting the order
  // if Razorpay isn't configured/reachable.
  Future<void> _payWithRazorpay() async {
    if (razorpayKey.isEmpty || !rzpweb.RazorpayCheckout.isSupported) {
      _acceptOnlineFallback("Online");
      return;
    }
    try {
      final res = await ApiClient.instance
          .post('/payments/razorpay/order', {'amount': CommonWidget.finalamount});
      final String rzpOrderId = (res['orderId'] ?? '').toString();
      final String key = (res['key'] ?? razorpayKey).toString();
      rzpweb.RazorpayCheckout.open(
        key: key,
        orderId: rzpOrderId,
        amountPaise: (CommonWidget.finalamount * 100).round(),
        name: CommonWidget.storeName,
        description: "Order Payment",
        email: checkoutController.email,
        contact: checkoutController.Number,
        onSuccess: (result) async {
          try {
            final v =
                await ApiClient.instance.post('/payments/razorpay/verify', {
              'razorpay_order_id': result['razorpay_order_id'],
              'razorpay_payment_id': result['razorpay_payment_id'],
              'razorpay_signature': result['razorpay_signature'],
            });
            if (v['valid'] == true) {
              handlePaymentSuccessResponse2(
                  result['razorpay_payment_id'] ?? '');
            } else {
              showAlertDialog(context, "Verification failed",
                  "Your payment could not be verified. If money was deducted it will be refunded.");
            }
          } catch (e) {
            showAlertDialog(context, "Verification error", e.toString());
          }
        },
        onFailure: (reason) {
          if (reason != 'cancelled') {
            showAlertDialog(context, "Payment Failed", reason);
          }
        },
      );
    } catch (e) {
      // Razorpay order couldn't be created (not configured/reachable) → accept.
      _acceptOnlineFallback("Online");
    }
  }

  // Stripe: record the order, then redirect to Stripe Checkout (hosted page).
  // If Stripe isn't configured, the order is still placed (accepted).
  Future<void> _payWithStripe() async {
    String createdId = '';
    try {
      createdId = await AddOrder(_buildOrder("Stripe"));
      Order_id = createdId;
      CommonWidget.cartitems = 0;
      final res = await ApiClient.instance.post('/payments/stripe/session', {
        'amount': CommonWidget.finalamount,
        'email': checkoutController.email,
        'orderId': createdId,
      });
      final url = (res['url'] ?? '').toString();
      if (url.isEmpty) {
        // Stripe not configured — order already placed, show success.
        if (mounted) setState(() {});
        _showOrderPlaced();
        return;
      }
      await launchUrl(Uri.parse(url), webOnlyWindowName: '_self');
    } catch (e) {
      // Order was already created above — treat as accepted and show success.
      if (mounted) setState(() {});
      _showOrderPlaced();
    }
  }

  showAlertDialog(BuildContext context, String title, String message) {
    AlertDialog alert = AlertDialog(
      backgroundColor: AppColor.BgColor,
      title: Center(
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              Order_id,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColor.BlackColor,
                fontSize: 17,
              ),
            ),
          ),
          title == "Payment Successful"
              ? SvgPicture.asset(
                  'assets/image/Confirmed.svg',
                  height: MediaQuery.of(context).size.height * .35,
                  width: MediaQuery.of(context).size.height * .4,
                )
              : SvgPicture.asset(
                  'assets/image/errorshow.svg',
                  height: MediaQuery.of(context).size.height * .35,
                  width: MediaQuery.of(context).size.height * .3,
                ),
          Center(
            child: Text(
              message,
              // "Thank You For Purchase..",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                overlayColor: WidgetStatePropertyAll(Colors.white),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.black)),
                )),
            child: Text(
              title == "Payment Successful" ? "Back To Home" : "Back",
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              if (title == "Payment Successful" || title == "Order Placed") {

                setState(() {
                  CommonWidget.cartitems = 0;
                });
                WebAPPNavigation.navigateToroute(
                    context: context,
                    routename: '/HomePage',
                    screen: BottomBar(
                      pageindex: 0,
                    ));
              } else {
                Navigator.pop(context);
              }
            },
          ),
        )
        // continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  CODshowAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {
        if (title == "Payment Successful" || title == "Order Placed") {
          WebAPPNavigation.navigateToroute(
              context: context,
              routename: '/HomePage',
              screen: BottomBar(
                pageindex: 0,
              ));
        } else {
          WebAPPNavigation.navigateTo(context: context);
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: AppColor.BgColor,
      title: Center(
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              Order_id,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColor.BlackColor,
                fontSize: 17,
              ),
            ),
          ),
          title == "Payment Successful"
              ? SvgPicture.asset(
                  'assets/image/Confirmed.svg',
                  height: MediaQuery.of(context).size.height * .35,
                  width: MediaQuery.of(context).size.height * .4,
                )
              : SvgPicture.asset(
                  'assets/image/errorshow.svg',
                  height: MediaQuery.of(context).size.height * .35,
                  width: MediaQuery.of(context).size.height * .3,
                ),
          Center(
            child: Text(
              message,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                overlayColor: WidgetStatePropertyAll(Colors.white),
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.black)),
                )),
            child: Text(
              "Back To Home",
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              if (title == "Payment Successful" || title == "Order Placed") {

                setState(() {
                  CommonWidget.cartitems = 0;
                });
                WebAPPNavigation.navigateToroute(
                    context: context,
                    routename: '/HomePage',
                    screen: BottomBar(
                      pageindex: 0,
                    ));
              } else {
                WebAPPNavigation.navigateTo(context: context);
              }
            },
          ),
        )
        // continueButton,
      ],
    );
    // AlertDialog alert = AlertDialog(
    //   backgroundColor: AppColor.BgColor,
    //   title: Text(
    //     title,
    //     style: TextStyle(
    //         fontSize: 18,
    //         fontWeight: FontWeight.w600,
    //         color: AppColor.BlackColor),
    //   ),
    //   content: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(
    //         "Thank You",
    //         style: TextStyle(
    //             color: AppColor.BlackColor,
    //             fontSize: 16,
    //             fontWeight: FontWeight.w500),
    //       ),
    //       Text(
    //         message,
    //         style: TextStyle(color: AppColor.BlackColor),
    //       ),
    //     ],
    //   ),
    //   actions: [
    //     continueButton,
    //   ],
    // );
    // // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Order Summary",
                style: TextStyle(
                    fontFamily: AppFont.heading,
                    color: AppColor.ink,
                    fontSize: 20,
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
                    style:
                        TextStyle(fontSize: 16, color: AppColor.fontColorgrey),
                  ),
                  Text(
                    "₹ ${shoppingDetailController.discountedsubtotal != 0.0 ? shoppingDetailController.discountedsubtotal.toStringAsFixed(0) : shoppingDetailController.subtotal.toStringAsFixed(0)}",
                    style:
                        TextStyle(fontSize: 16, color: AppColor.viewallcolor),
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
                    style:
                        TextStyle(fontSize: 16, color: AppColor.fontColorgrey),
                  ),
                  Text(
                    "₹ ${shoppingDetailController.shippingcost}",
                    style:
                        TextStyle(fontSize: 16, color: AppColor.viewallcolor),
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
                    style:
                        TextStyle(fontSize: 16, color: AppColor.fontColorgrey),
                  ),
                  Text(
                    '${shoppingDetailController.discountedsubtotal != 0.0 ? (shoppingDetailController.discountedsubtotal * (shoppingDetailController.taxpayment * 0.01)).round() : (shoppingDetailController.subtotal * (shoppingDetailController.taxpayment * 0.01)).round()}', //  "${((isdiscount == true ? shoppingDetailController.discountedsubtotal : (shoppingDetailController.subtotal)) * (shoppingDetailController.taxpayment * 0.01)).toStringAsFixed(0)}",

                    style:
                        TextStyle(fontSize: 16, color: AppColor.viewallcolor),
                  ),
                ],
              ),
            ),

            // Padding(
            //   padding: EdgeInsets.symmetric(vertical: 2.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         "Delivery Fee",
            //         style:
            //             TextStyle(fontSize: 16, color: AppColor.fontColorgrey),
            //       ),
            //       Text(
            //         "₹ ${CommonWidget.deliveryfee}",
            //         style:
            //             TextStyle(fontSize: 16, color: AppColor.viewallcolor),
            //       ),
            //     ],
            //   ),
            // ),
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
                  "Total ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "₹ ${CommonWidget.finalamount}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.viewallcolor),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Radio(
                    value: 1,
                    activeColor: AppColor.primary,
                    fillColor: MaterialStatePropertyAll(
                        checkoutController.paymentselectedOption == 1
                            ? AppColor.primary
                            : AppColor.fontColorgrey),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    groupValue: checkoutController.paymentselectedOption,
                    onChanged: (value) {
                      checkoutController.paymentselectedOption = value!;
                      setState(() {});
                    },
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        "COD (Cash On Delivery)",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1.1,
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Radio(
                    value: 2,
                    activeColor: AppColor.primary,
                    fillColor: MaterialStatePropertyAll(
                        checkoutController.paymentselectedOption == 2
                            ? AppColor.primary
                            : AppColor.fontColorgrey),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    groupValue: checkoutController.paymentselectedOption,
                    onChanged: (value) {
                      checkoutController.paymentselectedOption = value!;
                      setState(() {});
                    },
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        'Payment With Bank OR UPI',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1.1,
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,

                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Radio(
                    value: 3,
                    activeColor: AppColor.primary,
                    fillColor: MaterialStatePropertyAll(
                        checkoutController.paymentselectedOption == 3
                            ? AppColor.primary
                            : AppColor.fontColorgrey),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    groupValue: checkoutController.paymentselectedOption,
                    onChanged: (value) {
                      checkoutController.paymentselectedOption = value!;
                      setState(() {});
                    },
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        'Pay with Card (Stripe)',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1.1,
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              overlayColor: WidgetStatePropertyAll(Colors.white),
              onTap: () {
                // CODshowAlertDialog(
                //     context, "Order Placed", "Order ID: 6887454564564564");
                print(
                    "paymentselectedOption :: ${checkoutController.paymentselectedOption}");
                if (checkoutController.paymentselectedOption == 0) {
                  showAlertDialog(
                      context, "ERROR", "Please Select Payment Method");
                } else if (checkoutController.addresslist.isEmpty) {
                  showAlertDialog(context, "ERROR", "No Address Founded");
                } else {
                  // Final confirmation before placing the order.
                  _confirmAndPlaceOrder();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                margin: EdgeInsets.only(
                  top: 24,
                ),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: AppColor.ctaGradient),
                child: checkoutController.paymentisloader == true
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColor.whiteColor,
                        ),
                      )
                    : Text(
                        "Place Order",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColor.whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> getVacDates(String s) => [
        for (final timeline in jsonDecode(s)['timeline'])
          timeline['date'] as String
      ];
      
  // Function to get Shiprocket token
  Future<String> getShiprocketToken() async {
    try {
      // If we already have a token, return it
      if (shiprocket_token.isNotEmpty) {
        return shiprocket_token;
      }
      
      // Otherwise, get a new token
      var response = await http.post(
        Uri.parse('https://apiv2.shiprocket.in/v1/external/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          


        },
        body: jsonEncode({
          
          // 'email': shiprocket_email,
          // 'password': shiprocket_password,

          'email' : shoppingDetailController.shiprocketid,
          'password': shoppingDetailController.shiprocketpassword,

          // 'email': "myextraemail232006@gmail.com",
          // 'password': "!Yu91arcrVVChm&&",

          // 'email': "darshan.codebuzz@gmail.com",
          // 'password': "shiprocket@RV@2003",


          //  'email': "piyush.codebuzz@gmail.com",
          // 'password': "India12345",

          //  'email': "sp1@gmail.com",
          // 'password': "",
        }),
      );
      
      
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        shiprocket_token = responseData['token'];
        // print("Token: ${shiprocket_token.substring(0, 20)}...");
        print("shiprocket token ${shiprocket_token}"); // Print first part of token for debugging
        return shiprocket_token;
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  
  }

//   Future<String> getShiprocketToken() async {
//   final url = Uri.parse('https://apiv2.shiprocket.in/v1/external/auth/login');
//   final headers = {'Content-Type': 'application/json'};
//   final body = jsonEncode({
//     // 'email': shiprocket_email,
//     // 'password': shiprocket_password,

//     'email': "info@tavisi.in",
//     'password': "India12345",


//   });

//   final response = await http.post(url, headers: headers, body: body);

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     final token = data['token'];
//     print("---> $token");
//     // Optionally store token somewhere here
//     return token; // ✅ RETURN token
//   } else {
//     print("Authentication failed: ${response.body}");
//     throw Exception('Authentication failed with status ${response.statusCode}');
//     // ✅ THROW if not successful
//   }
// }

      
  Future<void> callShiprocketAPI(String orderId) async {
    try {
      setState(() {
        checkoutController.paymentisloader = true;
      });
      
      // First, get the authentication token
      String token = await getShiprocketToken();
      if (token.isEmpty) {
        return;
      }
      
      // Get the selected address
      Addresslist selectedAddress = checkoutController.addresslist[(checkoutController.selectedOption - 1)];
      
      // Format current date and time for order_date
      String orderDate = DateTime.now().toString().substring(0, 16).replaceAll('T', ' ');
      
      // Prepare order items
      List<Map<String, dynamic>> orderItems = [];
      for (var item in checkoutController.cartitems) {
        orderItems.add({
          "name": item.title ?? "Product",
          "sku": item.productId ?? "SKU${item.productId}",
          "units": item.quantity ?? 1,
          "selling_price": double.parse(item.price.toString()),
          "discount": "",
          "tax": "",
          "hsn": 441122 // Default HSN code
        });
      }
      
      // Calculate subtotal
      double subTotal = 0;
      for (var item in checkoutController.cartitems) {
        subTotal += (double.parse(item.price.toString()) * (item.quantity ?? 1));
      }
      
      // Prepare request body
      Map<String, dynamic> requestBody = {
        "order_id": orderId,
        "order_date": orderDate,
        "pickup_location": "First floor, Sharam Complex G Tower opposite Savita Hospital,, Parivaar Char Rasta, Waghodia Rd,, Vadodara, Gujarat, India, 390019", // Try a common pickup location name
        "comment": "Order from E-commerce App",
        "billing_customer_name": selectedAddress.name ?? "Customer",
        "billing_last_name": "", // Not available in your address model
        "billing_address": selectedAddress.street ?? "",
        "billing_address_2": "",
        "billing_city": selectedAddress.city ?? "",
        "billing_pincode": selectedAddress.postalCode ?? "",
        "billing_state": selectedAddress.state ?? "",
        "billing_country": "india", // Hardcoded to India as required by Shiprocket
        "billing_email": checkoutController.email ?? "",
        "billing_phone": selectedAddress.phoneNumber ?? "",
        "shipping_is_billing": true,
        "shipping_customer_name": selectedAddress.name ?? "Customer",
        "shipping_last_name": "",
        "shipping_address": selectedAddress.street ?? "",
        "shipping_address_2": "",
        "shipping_city": selectedAddress.city ?? "",
        "shipping_pincode": selectedAddress.postalCode ?? "",
        "shipping_country": "India", // Hardcoded to India as required by Shiprocket
        "shipping_state": selectedAddress.state ?? "",
        "shipping_email": checkoutController.email ?? "",
        "shipping_phone": selectedAddress.phoneNumber ?? "",
        "order_items": orderItems,
        "payment_method": checkoutController.paymentselectedOption == 1 ? "COD" : "Prepaid",
        "shipping_charges": shoppingDetailController.shippingcost,
        "giftwrap_charges": 0,
        "transaction_charges": 0,
        "total_discount": 0,
        "sub_total": subTotal.round(),
        "length": 10,
        "breadth": 15,
        "height": 20,
        "weight": 2.5
      };
      
      
      // Make API call with the token
      var response = await http.post(
        Uri.parse(shiprocket_api_url),
          // Uri.parse("https://apiv2.shiprocket.in/v1/external/auth/login"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(requestBody),
      );
      
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        // Handle successful order creation
      } else if (response.statusCode == 403) {
        
        // Continue with the checkout process despite the Shiprocket error
      } else if (response.statusCode == 422) {
        var responseData = jsonDecode(response.body);
        
        // Print specific validation errors if available
        if (responseData.containsKey('errors')) {
          responseData['errors'].forEach((field, errors) {
          });
        }
        
        // Continue with the checkout process despite the Shiprocket error
      } else {
        // Handle error but continue with checkout
      }
    } catch (e) {
    } finally {
      setState(() {
        checkoutController.paymentisloader = false;
      });
    }
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

  String? token;
  // static final _firebaseMessaging = FirebaseMessaging.instance;
  // Future getDeviceToken({int maxRetires = 3}) async {
  //   try {
  //     // String? token;
  //     if (kIsWeb) {
  //       // get the device fcm token
  //       token = await _firebaseMessaging.getToken(
  //           vapidKey:
  //               "BHsAr74qLIi6GxniUI79x0bppGhlR80ZcU-bmusB7ZNDkycuiaRoVNNDp8L8wjLkgYIhRfGsvj_aRz2GxvBe0MY");
  //       setState(() {});
  //       print("for web device token: $token");
  //     } else {
  //       // get the device fcm token
  //       token = await _firebaseMessaging.getToken();
  //       print("for android device token: $token");
  //     }
  //     // saveTokentoFirestore(token: token!);
  //     return token;
  //   } catch (e) {
  //     print("failed to get device token");
  //     if (maxRetires > 0) {
  //       print("try after 10 sec");
  //       await Future.delayed(Duration(seconds: 10));
  //       return getDeviceToken(maxRetires: maxRetires - 1);
  //     } else {
  //       return null;
  //     }
  //   }
  // }

  GetServiceKey getServiceKey = GetServiceKey();
  String accessToken = '';
  getServerKey() async {
    accessToken = await getServiceKey.getServerKeyToken();
  }

  Future<void> sendMessageToFcmTopic({token, accessToken, status}) async {
    const String topicName = "Order Purchase";
    String serverKey = accessToken;
    final message = {
      "message": {
        "token": token,
        "data": {
          "Title": 'Order Added !!',
          "Descriptions": '${checkoutController.Name} is Order from Website'
          // "hello": "This is a Firebase Cloud Messaging device group message!"
        }
      }
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverKey',
    };

    final response = await http.post(
      Uri.parse(
          // 'https://fcm.googleapis.com/fcm/send'),
          'https://fcm.googleapis.com/v1/projects/e-commerce-app-2e61e/messages:send'),
      headers: headers,
      body: json.encode(message),
    );
    if (response.statusCode == 200) {

    } else {
    }
  }

  Future<String> AddOrder(FirebaseOrderModel order) async {
    try {
      final data = await ApiClient.instance.post('/orders', order.toJson());
      final orderid = (data['id'] ?? data['_id'] ?? '').toString();
      // Clear the user's cart after a successful order.
      try {
        await UserDataApi.saveCart([]);
        homecontoller.MyCart = FirebaseCartModel();
        CommonWidget.cartitems = 0;
      } catch (_) {}
      if (mounted) setState(() {});
      return orderid;
    } catch (e) {
      throw e.toString();
    }
  }
}

/// Animated "Order Placed" success dialog shown after a COD order is created.
class OrderPlacedDialog extends StatefulWidget {
  final String orderId;
  final VoidCallback onViewOrders;
  final VoidCallback onContinue;
  const OrderPlacedDialog({
    super.key,
    required this.orderId,
    required this.onViewOrders,
    required this.onContinue,
  });

  @override
  State<OrderPlacedDialog> createState() => _OrderPlacedDialogState();
}

class _OrderPlacedDialogState extends State<OrderPlacedDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..forward();
    super.initState();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width > 600;
    return Dialog(
      backgroundColor: AppColor.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: wide ? 430 : MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
              child: Container(
                height: 100,
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    gradient: AppColor.ctaGradient, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 58),
              ),
            ),
            const SizedBox(height: 26),
            FadeTransition(
              opacity: CurvedAnimation(
                  parent: _c, curve: const Interval(0.45, 1.0)),
              child: Column(
                children: [
                  Text(
                    "Order Placed!",
                    style: TextStyle(
                        fontFamily: AppFont.heading,
                        fontSize: 27,
                        fontWeight: FontWeight.w600,
                        color: AppColor.ink),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Thank you for your order — we're getting it ready for you.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColor.fontColorgrey),
                  ),
                  if (widget.orderId.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: AppColor.blush,
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(
                        "Order ID: ${widget.orderId}",
                        style: TextStyle(
                            fontSize: 12.5,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: PressableScale(
                    onTap: widget.onContinue,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColor.dividercolor)),
                      child: Text("Continue Shopping",
                          style: TextStyle(
                              color: AppColor.ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PressableScale(
                    onTap: widget.onViewOrders,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          gradient: AppColor.ctaGradient,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Text("View Orders",
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
      ),
    );
  }
}
