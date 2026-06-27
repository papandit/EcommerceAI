// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers, non_constant_identifier_names, sized_box_for_whitespace, prefer_interpolation_to_compose_strings, unnecessary_import, avoid_print, use_build_context_synchronously, unused_local_variable, avoid_function_literals_in_foreach_calls, unnecessary_null_comparison, unnecessary_string_interpolations, prefer_final_fields, must_be_immutable

import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/userdataset.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/platformcheck.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/viewmodel/registercontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key, isdailog = false});
  bool? isdailog;
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterController registerController = Get.put(RegisterController());
  final _emailformKey = GlobalKey<FormState>();
  final _passwordformKey = GlobalKey<FormState>();
  final _nameformKey = GlobalKey<FormState>();
  final _numberformKey = GlobalKey<FormState>();
  List<UserModel>? userModelList;

  @override
  void initState() {
    super.initState();
  }

  bool googleregister = false;
  String phoneNumber = '';
  String smsCode = '';
  String verificationId = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BgColor,
      appBar: PlatformInfo().isWeb() == true
          ? null
          : AppBar(
              backgroundColor: AppColor.BgColor,
              surfaceTintColor: AppColor.BgColor,
              leading: InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.white),
                onTap: () {
                  WebAPPNavigation.navigateTo(context: context);
                },
                child: CommonWidget().backicon(),
              ),
            ),
      body: !Responsive.isMobile(context)
          ? Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: SvgPicture.asset("assets/image/signupsvg.svg",
                          semanticsLabel: 'Acme Logo'),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 450),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: PlatformInfo().isWeb() == true
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              CreateAccountwidget(),
                              nameTextfeildwidget(),
                              emailTextfeildwidget(),
                              numberTextfeildwidget(),
                              passwordTextfeildwidget(),
                              SignupBtn(),
                              GoogleBtn(),
                              SinginWidget(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Vector(),
                    CreateAccountwidget(),
                    nameTextfeildwidget(),
                    emailTextfeildwidget(),
                    numberTextfeildwidget(),
                    passwordTextfeildwidget(),
                    SignupBtn(),
                    GoogleBtn(),
                    SinginWidget(),
                  ],
                ),
              ),
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
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create Account",
            style: TextStyle(
                fontSize: 26,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
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
                controller: registerController.namecontoller,
                validator: registerController.validatename,
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                controller: registerController.numbercontoller,
                validator: registerController.validatenumber,
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
                controller: registerController.emailcontoller,
                validator: registerController.validateEmail,
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

  passwordTextfeildwidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Password",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.fontblack,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _passwordformKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                obscureText: !registerController.ispasswordvisible,
                controller: registerController.passwordcontoller,
                validator: registerController.validatePassword,
                cursorColor: AppColor.fontblack,
                decoration: InputDecoration(
                    suffixIcon: InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.white),
                      onTap: () {
                        registerController.ispasswordvisible =
                            !registerController.ispasswordvisible;
                        setState(() {});
                      },
                      child: Icon(
                        !registerController.ispasswordvisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 22,
                      ),
                    ),
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
                    hintText: "Enter Your Password",
                    hintStyle: TextStyle(fontFamily: AppFont.lato)),
                style: TextStyle(
                    fontSize: 14,
                    color: AppColor.fontColorgrey,
                    fontWeight: FontWeight.w500),
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
        if (registerController.processloader == false) {
          registerController.processloader = true;
          setState(() {});
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild!.unfocus();
          }
          if (registerController.namecontoller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Name',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            registerController.processloader = false;
            setState(() {});
          } else if (registerController.emailcontoller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Email',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            registerController.processloader = false;
            setState(() {});
          } else if (registerController.numbercontoller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Number',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            registerController.processloader = false;
            setState(() {});
          } else if (registerController.passwordcontoller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Password',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            registerController.processloader = false;
            setState(() {});
          } else if (!_nameformKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Valid Name',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            registerController.processloader = false;
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
            registerController.processloader = false;
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
            registerController.processloader = false;
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
            registerController.processloader = false;
            setState(() {});
          } else {
            Signup_app(
              emailAddress: registerController.emailcontoller.text,
              password: registerController.passwordcontoller.text,
              firstName: registerController.namecontoller.text,
              phoneNumber: registerController.numbercontoller.text,
            );
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
        child: registerController.processloader == true
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.whiteColor,
                ),
              )
            : Text(
                "Sign Up",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColor.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  String? token;

  bool crateentry = false;
  // Google Sign-In removed — auth is email/password via the MongoDB backend.
  GoogleBtn() => const SizedBox.shrink();

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
  Future Signup_app(
      {emailAddress, password, firstName, phoneNumber}) async {
    try {
      // Register on the Node/MongoDB backend (returns JWT + user).
      final data = await ApiClient.instance.post('/auth/register', {
        'email': emailAddress,
        'password': password,
        'firstName': firstName ?? '',
        'phone': phoneNumber ?? '',
      });
      await ApiClient.instance.saveSession(data);
      final user = (data['user'] ?? {}) as Map;
      final userId = (user['id'] ?? user['_id'] ?? '').toString();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool(prefrenceKey.isLogin, true);
      prefs.setString(prefrenceKey.userid, userId);

      registerController.processloader = false;
      CommonWidget.UnverifyedUser = false;
      registerController.emailcontoller.clear();
      registerController.namecontoller.clear();
      registerController.numbercontoller.clear();
      registerController.passwordcontoller.clear();
      if (!mounted) return;
      setState(() {});
      WebAPPNavigation.navigateToroute(
          context: context,
          routename: '/HomePage',
          screen: BottomBar(pageindex: 0));
    } on ApiException catch (e) {
      registerController.processloader = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message), backgroundColor: Colors.red));
    } catch (e) {
      registerController.processloader = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Registration failed. Please try again.'),
          backgroundColor: Colors.red));
    }
  }

}
