// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_interpolation_to_compose_strings, non_constant_identifier_names, unnecessary_import, sized_box_for_whitespace, avoid_unnecessary_containers, must_be_immutable, unused_local_variable, use_build_context_synchronously, avoid_print, unnecessary_brace_in_string_interps, deprecated_member_use, empty_catches, unused_catch_clause, dead_code

import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/addressmodel.dart';
import 'package:EcommerceApp/view/addaddress.dart';

import 'package:EcommerceApp/viewmodel/shoppingcontroller.dart';

import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/api/user_data_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/checkoutcontroller.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:razorpay_web/razorpay_web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class DeliveryAdressadd extends StatefulWidget {
  const DeliveryAdressadd({
    super.key,
  });

  @override
  State<DeliveryAdressadd> createState() => _DeliveryAdressaddState();
}

class _DeliveryAdressaddState extends State<DeliveryAdressadd> {
  CheckoutController checkoutController = CheckoutController();
  ShoppingDetailController shoppingDetailController =
      Get.put(ShoppingDetailController());
  String cash_free_create_url = 'https://sandbox.cashfree.com/pg/orders';
  String cash_free_statuscheck_url = 'https://sandbox.cashfree.com/pg/orders/';
  String Order_id = '';
  String api_version = '2023-08-01';
  bool isloader = false;
  CFPaymentGatewayService cfPaymentGatewayService = CFPaymentGatewayService();
  String cartId = '';
  List<Map<String, dynamic>> basic = [];
  List<String> basic_new = [];
  final Map<String, dynamic> someMap = {};
  int selection = 0;
  bool paymentisloader = false;
  @override
  void initState() {
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

    try {
      final me = await ApiClient.instance.getOne('/auth/me');
      checkoutController.email = (me['Email'] ?? me['email'] ?? '').toString();
      if (mounted) setState(() {});
    } catch (_) {}
    return checkoutController.email;
  }

  @override
  Widget build(BuildContext context) {
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
                // appBar: AppBar(
                //   centerTitle: true,
                //   title: Text(
                //     "Shipping To",
                //     style: TextStyle(
                //          fontWeight: FontWeight.w600),
                //   ),
                //   automaticallyImplyLeading: false,
                //   surfaceTintColor: Colors.transparent,
                //   backgroundColor: AppColor.BgColor,
                // ),
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width * 0.48,
                                child: Center(
                                  child: SvgPicture.asset(
                                      "assets/image/Addressvector.svg",
                                      semanticsLabel: 'Acme Logo'),
                                ),
                              ),
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
                    "Address Details",
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
                // bottomNavigationBar: bottomwidget(),
              );
  }

  var data;

  Future Addressget() async {
    checkoutController.addresslist.clear();
    final SharedPreferences perfs = await SharedPreferences.getInstance();
    checkoutController.userid = perfs.getString(prefrenceKey.userid) ?? '';
    try {
      final list = await UserDataApi.getAddresses();
      for (final v in list) {
        checkoutController.addresslist.add(Addresslist.fromJson(v));
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Widget addadress() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      borderRadius: BorderRadius.circular(14),
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
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: AppColor.ctaGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: Appshadow.soft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_location_alt_outlined,
                color: AppColor.whiteColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Add New Address',
              style: TextStyle(
                  color: AppColor.whiteColor,
                  fontWeight: FontWeight.w700,
                  fontSize: !Responsive.isMobile(context) ? 16 : 14),
            ),
          ],
        ),
      ),
    );
  }

  address() {
    if (checkoutController.addresslist.isEmpty) {
      return Flexible(
        fit: FlexFit.tight,
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off_outlined,
                  size: 46, color: AppColor.fontColorgrey),
              const SizedBox(height: 12),
              Text("No saved addresses yet",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColor.ink)),
              const SizedBox(height: 4),
              Text("Add one above to get it delivered.",
                  style:
                      TextStyle(fontSize: 13, color: AppColor.fontColorgrey)),
            ],
          ),
        ),
      );
    }
    return Flexible(
      fit: FlexFit.tight,
      flex: 1,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 6, bottom: 8),
        itemCount: checkoutController.addresslist.length,
        itemBuilder: (context, index) {
          final a = checkoutController.addresslist[index];
          final bool selected =
              checkoutController.selectedOption == index + 1;
          return InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                checkoutController.selectedOption = index + 1;
                selection = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selected ? AppColor.blush : AppColor.whiteColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: selected ? AppColor.primary : AppColor.blushDeep,
                    width: selected ? 1.6 : 1),
                boxShadow: selected ? Appshadow.soft : [],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selection indicator
                  Container(
                    height: 22,
                    width: 22,
                    margin: const EdgeInsets.only(top: 2, right: 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColor.primary : Colors.transparent,
                      border: Border.all(
                          color: selected
                              ? AppColor.primary
                              : AppColor.fontColorgrey,
                          width: 2),
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name ?? 'Address',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColor.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 16, color: AppColor.fontColorgrey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                [
                                  a.street,
                                  a.city,
                                  a.state,
                                  a.postalCode
                                ]
                                    .where((e) =>
                                        (e ?? '').toString().trim().isNotEmpty)
                                    .join(', '),
                                style: TextStyle(
                                    height: 1.35,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.fontColorgrey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.call_outlined,
                                size: 15, color: AppColor.fontColorgrey),
                            const SizedBox(width: 6),
                            Text(
                              a.phoneNumber ?? '',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.fontColorgrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Edit
                  InkWell(
                    overlayColor: WidgetStatePropertyAll(Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      WebAPPNavigation.navigateToroute(
                          context: context,
                          routename: '/DeliveryAdress',
                          data: {
                            'index': index,
                            'addresslist': checkoutController.addresslist
                          },
                          screen: DeliveryAdress(
                            index: index,
                            addresslist: checkoutController.addresslist,
                            onBack: () {
                              Addressget();
                            },
                          ));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColor.blushDeep),
                      ),
                      child: Icon(Icons.edit_outlined,
                          size: 16, color: AppColor.primary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {}

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
  }

  showAlertDialog(BuildContext context, String title, String message) {
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
      title: Text(title),
      content: Text(message),
      actions: [
        continueButton,
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
      title: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.BlackColor),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Thank You",
            style: TextStyle(
                color: AppColor.BlackColor,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          Text(
            message,
            style: TextStyle(color: AppColor.BlackColor),
          ),
        ],
      ),
      actions: [
        continueButton,
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
}
