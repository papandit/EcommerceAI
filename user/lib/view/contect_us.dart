// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers, non_constant_identifier_names, sized_box_for_whitespace, prefer_interpolation_to_compose_strings, unnecessary_import, avoid_print, use_build_context_synchronously, unused_local_variable, avoid_function_literals_in_foreach_calls, unnecessary_null_comparison, unnecessary_string_interpolations, prefer_final_fields

import 'dart:async';
import 'dart:convert';
import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/cartmodels.dart';
import 'package:EcommerceApp/model/contectus_model.dart';
import 'package:EcommerceApp/model/userdataset.dart';
import 'package:EcommerceApp/view/verifyotp.dart';
import 'package:EcommerceApp/viewmodel/contectuscontroller.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class ContectUs extends StatefulWidget {
  const ContectUs({super.key});

  @override
  State<ContectUs> createState() => _ContectUsState();
}

class _ContectUsState extends State<ContectUs> {
  Contectuscontroller contectuscontroller = Get.put(Contectuscontroller());
  final _emailformKey = GlobalKey<FormState>();
  final _passwordformKey = GlobalKey<FormState>();
  final _nameformKey = GlobalKey<FormState>();
  final _numberformKey = GlobalKey<FormState>();
  List<UserModel>? userModelList;

  Future<List<UserModel>> UsercheckDataGet() async {
    return <UserModel>[];
  }

  // const recaptchaVerifier =
  //     firebase.auth.RecaptchaVerifier('sign-in-button', {
  //   size: 'invisible',
  // });
  // Future<void> _onNavigationDelegateExample() {
  //   final String contentBase64 = base64Encode(
  //     const Utf8Encoder().convert(
  //         '<html><body><iframe width="600" height="450" style="border:0" loading="lazy" allowfullscreen referrerpolicy="no-referrer-when-downgrade" src="https://www.google.com/maps/embed/v1/place?key=AIzaSyA0qSfN8NTXP5SEjc-xYlhYhdGsLUFOfYk&q=Space+Needle,Seattle+WA"></iframe></body></html>'),
  //   );
  //   return controller!.loadRequest(
  //     Uri.parse('data:text/html;base64,$contentBase64'),
  //   );
  // }

  Future<String> AddReview(ReviewModel review) async {
    try {
      final data = await ApiClient.instance.post('/reviews', review.toJson());
      if (mounted) setState(() {});
      return (data['id'] ?? data['_id'] ?? '').toString();
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  @override
  void initState() {
    print(
        "SSSS jhvhjbvdhhdsbvjhdsbvjhsbvdsbvhbdsvhubsh++++++++++++++++++++++++++++++++");
    // _onNavigationDelegateExample();
    super.initState();
  }

  // final RecaptchaVerifier recaptchaVerifier = RecaptchaVerifier(
  //   onSuccess: () {
  //     print('reCAPTCHA Completed!');
  //   },
  //   onError: (FirebaseAuthException error) {
  //     print('reCAPTCHA Failed: $error');
  //   },
  //   onExpired: () {
  //     print('reCAPTCHA Expired. Please try again.');
  //   },
  //   auth: FirebaseAuthWeb.instance,
  // );
  // WebViewController controller
  //     //  = WebViewController();
  //     = WebViewController()
  //       ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //       ..setNavigationDelegate(
  //         NavigationDelegate(
  //           onProgress: (int progress) {
  //             // Update loading bar.
  //           },
  //           onPageStarted: (String url) {},
  //           onPageFinished: (String url) {},
  //           onHttpError: (HttpResponseError error) {
  //             print("snvsjnvdjsnvsdjnsd");
  //           },
  //           onWebResourceError: (WebResourceError error) {
  //             print("snvsjnvdjsnvsdjnsd  1222 ");
  //           },
  //           // onNavigationRequest: (NavigationRequest request) {
  //           //   if (request.url.startsWith('https://www.youtube.com/')) {
  //           //     return NavigationDecision.prevent;
  //           //   }
  //           //   return NavigationDecision.navigate;
  //           // },
  //         ),
  //       )
  //       // Uri.dataFromString('<html><body><iframe src="https://www.youtube.com/embed/abc"></iframe></body></html>', mimeType: 'text/html').toString()
  //       ..loadRequest(Uri.dataFromString(
  //           '<html><body><iframe src="https://www.youtube.com/embed/abc"></iframe></body></html>',
  //           mimeType: 'text/html'));
  bool googleregister = false;
  String phoneNumber = '';
  String smsCode = '';
  String verificationId = '';

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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

  @override
  Widget build(BuildContext context) {
    final bool wide =
        MediaQuery.of(context).size.width > CommonWidget.headerWidth;

    final Widget bodyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hero(),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal:
                  wide ? MediaQuery.of(context).size.width * 0.08 : 16,
              vertical: wide ? 44 : 28),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _infoColumn()),
                    SizedBox(width: 36),
                    Expanded(flex: 6, child: _formCard()),
                  ],
                )
              : Column(
                  children: [
                    _formCard(),
                    SizedBox(height: 24),
                    _infoColumn(),
                  ],
                ),
        ),
      ],
    );

    if (wide) {
      return Scaffold(
        backgroundColor: AppColor.BgColor,
        body: SingleChildScrollView(
          child: StickyHeader(
            header: CommonWidget().StickyHeaders(context, Refresh: setState),
            content: Column(
              children: [
                bodyContent,
                CommonWidget().Footer(context),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.BgColor,
      appBar:
          CommonWidget().Header(context: context, title: "Contact Us", heart: false),
      endDrawer: CommonWidget().Drowers(context),
      body: SingleChildScrollView(child: bodyContent),
    );
  }

  Widget _hero() {
    final bool wide =
        MediaQuery.of(context).size.width > CommonWidget.headerWidth;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: AppColor.roseGradient),
          padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("WE'D LOVE TO HEAR FROM YOU",
                  style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 10),
              Text("Get in Touch",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: AppFont.heading,
                      fontSize: 38,
                      color: AppColor.ink,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 540),
                child: Text(
                  "Questions about an order, sizing or a style? Send us a note and our team will get back to you shortly.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15, height: 1.5, color: AppColor.fontColorgrey),
                ),
              ),
            ],
          ),
        ),
        if (wide)
          Positioned(
            top: 16,
            left: 16,
            child: CommonWidget().heroBackArrow(context),
          ),
      ],
    );
  }

  Widget _infoColumn() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.dividercolor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Contact Information",
              style: TextStyle(
                  fontFamily: AppFont.heading,
                  fontSize: 22,
                  color: AppColor.ink,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 20),
          _contactInfoRow(Icons.location_on_outlined, "VISIT US",
              "447, Ramkrupa Soc., Matavadi Chok, Bhuj - 350005"),
          SizedBox(height: 18),
          _contactInfoRow(Icons.call_outlined, "CALL US", "99999 99999"),
          SizedBox(height: 18),
          _contactInfoRow(Icons.mail_outline, "EMAIL US", "Test@gmail.com"),
          SizedBox(height: 18),
          _contactInfoRow(Icons.schedule_outlined, "HOURS",
              "Mon – Sat · 10:00 AM – 8:00 PM"),
          SizedBox(height: 22),
          _mapsButton(),
          SizedBox(height: 22),
          Text("FOLLOW US",
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  color: AppColor.fontColorgrey,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Row(
            children: [
              _socialIcon("assets/image/facebook.svg", () {
                CommonWidget()
                    .launchFacebook("https://facebook.com", "https://facebook.com");
              }),
              SizedBox(width: 12),
              _socialIcon("assets/image/instagram.svg", () {
                CommonWidget().launchFacebook(
                    "https://instagram.com", "https://instagram.com");
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(String asset, VoidCallback onTap) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 46,
        width: 46,
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: AppColor.blush, shape: BoxShape.circle),
        child: SvgPicture.asset(asset, height: 20, width: 20),
      ),
    );
  }

  Widget _mapsButton() {
    return PressableScale(
      onTap: () {
        const mapUrl =
            "https://www.google.com/maps/search/?api=1&query=Matavadi+Chok+Bhuj";
        CommonWidget().launchFacebook(mapUrl, mapUrl);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, color: AppColor.primary, size: 20),
            SizedBox(width: 10),
            Text("Open in Google Maps",
                style: TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _formCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.dividercolor),
        boxShadow: [Appshadow.card],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CreateAccountwidget(),
          nameTextfeildwidget(),
          emailTextfeildwidget(),
          numberTextfeildwidget(),
          MessageTextfeildwidget(),
          SignupBtn(),
        ],
      ),
    );
  }

  Widget Vector() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: SvgPicture.asset("assets/image/signupsvg.svg",
          semanticsLabel: 'Acme Logo'),
    );
  }

  CreateAccountwidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Send us a message",
            style: TextStyle(
                fontFamily: AppFont.heading,
                fontSize: 24,
                color: AppColor.ink,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            "Fill in the form below and we'll be in touch soon.",
            style: TextStyle(
                fontSize: 14, height: 1.5, color: AppColor.fontColorgrey),
          ),
        ],
      ),
    );
  }

  Widget _contactInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: AppColor.blush,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColor.primary, size: 22),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.8,
                    color: AppColor.fontColorgrey,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: AppColor.ink,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget GeustRegister() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        WebAPPNavigation.navigateToroute(
            context: context,
            routename: '/HomePage',
            screen: BottomBar(
              pageindex: 0,
            ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.whiteColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 25,
              width: 25,
              margin: EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(AppImage.appIcon + "profile.png"))),
            ),
            Text(
              "Continue As Guest",
              style: TextStyle(
                  color: AppColor.fontblack,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  nameTextfeildwidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Full Name",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _nameformKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: contectuscontroller.namecontoller,
                validator: contectuscontroller.validatename,
                cursorColor: AppColor.fontblack,
                decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: AppColor.imagebg,
                    border: InputBorder.none,
                    hintText: "Enter Your Name",
                    hintStyle: TextStyle(fontFamily: AppFont.lato)),
                style: TextStyle(
                    fontSize: 14,
                    color: AppColor.fontblack,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  numberTextfeildwidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Phone Number",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _numberformKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: contectuscontroller.numbercontoller,
                validator: contectuscontroller.validatenumber,
                keyboardType: TextInputType.phone,
                cursorColor: AppColor.fontblack,
                maxLength: 10,
                decoration: InputDecoration(
                    counterText: "",
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: AppColor.imagebg,
                    border: InputBorder.none,
                    hintText: "Enter Your Number",
                    hintStyle: TextStyle(fontFamily: AppFont.lato)),
                style: TextStyle(
                    fontSize: 14,
                    color: AppColor.fontblack,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  emailTextfeildwidget() {
    return Container(
      // color: AppColor.BlackColor,
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Email",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _emailformKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: contectuscontroller.emailcontoller,
                validator: contectuscontroller.validateEmail,
                keyboardType: TextInputType.emailAddress,
                cursorColor: AppColor.fontblack,
                decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: AppColor.imagebg,
                    border: InputBorder.none,
                    hintText: "Enter Your Email",
                    hintStyle: TextStyle(fontFamily: AppFont.lato)),
                style: TextStyle(
                    fontSize: 14,
                    color: AppColor.fontblack,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  MessageTextfeildwidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Message",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Container(
            height: 120,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Form(
                key: _passwordformKey,
                autovalidateMode: AutovalidateMode.always,
                child:
                    // TextField(
                    //   controller: contectuscontroller.passwordcontoller,
                    //   keyboardType: TextInputType.multiline,
                    //   maxLines: 4,
                    //   decoration: InputDecoration(
                    //       hintText: "Enter Remarks",
                    //       focusedBorder: OutlineInputBorder(
                    //           borderSide:
                    //               BorderSide(width: 1, color: Colors.redAccent))),
                    // ),

                    TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                  controller: contectuscontroller.passwordcontoller,
                  cursorColor: AppColor.fontblack,
                  decoration: InputDecoration(
                      isDense: true,
                      // contentPadding:
                      //     EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: AppColor.imagebg,
                      border: InputBorder.none,
                      hintText: "Enter Your Message",
                      hintStyle: TextStyle(fontFamily: AppFont.lato)),
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColor.fontColorgrey,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SignupBtn() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        if (contectuscontroller.processloader == false) {
          contectuscontroller.processloader = true;
          setState(() {});
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild!.unfocus();
          }
          if (contectuscontroller.namecontoller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Name',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            contectuscontroller.processloader = false;
            setState(() {});
          } else if (contectuscontroller.emailcontoller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Email',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            contectuscontroller.processloader = false;
            setState(() {});
          } else if (contectuscontroller.numbercontoller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Number',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            contectuscontroller.processloader = false;
            setState(() {});
          } else if (contectuscontroller.passwordcontoller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Message',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            contectuscontroller.processloader = false;
            setState(() {});
          } else if (!_nameformKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Your Message',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            contectuscontroller.processloader = false;
            setState(() {});
          } else if (!_emailformKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter  Valid Email',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            contectuscontroller.processloader = false;
            setState(() {});
          } else if (!_passwordformKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter  Valid Password',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            contectuscontroller.processloader = false;
            setState(() {});
          } else if (!_numberformKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter  Valid Phone Number',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            contectuscontroller.processloader = false;
            setState(() {});
          } else {
            AddReview(ReviewModel(
                    id: '',
                    userid: homecontoller.userid,
                    name: contectuscontroller.namecontoller.text,
                    email: contectuscontroller.emailcontoller.text,
                    message: contectuscontroller.passwordcontoller.text,
                    phonenumber: contectuscontroller.numbercontoller.text))
                .then(
              (value) {
                contectuscontroller.emailcontoller.clear();
                contectuscontroller.namecontoller.clear();
                contectuscontroller.passwordcontoller.clear();
                contectuscontroller.numbercontoller.clear();
                contectuscontroller.processloader = false;
                setState(() {});
              },
            );
            // contectuscontroller.emailcontoller.clear();
            // contectuscontroller.namecontoller.clear();
            // contectuscontroller.passwordcontoller.clear();
            // contectuscontroller.numbercontoller.clear();
            // contectuscontroller.processloader = false;
            // setState(() {});
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.only(right: 24, left: 24, top: 14, bottom: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColor.btnColorblack),
        child: contectuscontroller.processloader == true
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.whiteColor,
                ),
              )
            : Text(
                "Submit Message",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColor.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  bool crateentry = false;
  GoogleBtn() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Use email login')),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: AppColor.imagebg),
        child: googleregister
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.BlackColor,
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 25,
                      width: 25,
                      margin: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage(AppImage.appIcon + "Google.png"))),
                    ),
                    Text(
                      "Sign Up With Google",
                      style: TextStyle(
                          color: AppColor.fontblack,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  SinginWidget() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already Have An Account?",
              style: TextStyle(
                color: AppColor.fontColorgrey,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.white),
                onTap: () {
                  WebAPPNavigation.navigateTo(context: context);
                },
                child: Text(
                  "Sign In",
                  style: TextStyle(
                      color: AppColor.fontblack, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String userid = '';
  Future Signup_app({emailAddress, password}) async {
    try {
      final data = await ApiClient.instance.post('/auth/register', {
        'email': emailAddress,
        'password': password,
      });
      ApiClient.instance.saveSession(data);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final uid = (data['user']?['id'] ?? data['user']?['_id'] ?? '').toString();
      prefs.setString(prefrenceKey.userid, uid);
      prefs.setBool(prefrenceKey.isLogin, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          contectuscontroller.processloader = false;
        });
      }
    }
  }

  void sendOTP(String phoneNumber, codeSent, verificationFailed) {
    // OTP/phone verification bypassed (no Firebase).
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('sucess')),
      );
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await ApiClient.instance.post('/auth/register', user.toJson());
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    // OTP/phone verification bypassed (no Firebase) — treat as verified.
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString(prefrenceKey.userid) ?? '';
      contectuscontroller.processloader = false;
      if (mounted) setState(() {});
      WebAPPNavigation.navigateToroute(
          context: context,
          routename: '/Verifyotp',
          data: {
            'verificationId': uid,
          },
          screen: Verifyotp(
            verificationId: uid,
          ));
      showSnackbar('OTP sent to your phone.');
    } catch (e) {
      showSnackbar('Failed to send OTP: $e');
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    // OTP/phone verification bypassed (no Firebase) — treat as verified.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(prefrenceKey.userid) ?? '';
    setState(() {
      verificationId = uid;
    });
    showSnackbar('OTP sent to your phone.');
    WebAPPNavigation.navigateToroute(
        context: context,
        routename: '/Verifyotp',
        data: {
          'verificationId': verificationId
        },
        screen: Verifyotp(
          verificationId: verificationId,
        ));

    contectuscontroller.emailcontoller.clear();
    contectuscontroller.namecontoller.clear();
    contectuscontroller.numbercontoller.clear();
    contectuscontroller.passwordcontoller.clear();
    setState(() {});
    contectuscontroller.processloader = false;
    setState(() {});
  }
}
