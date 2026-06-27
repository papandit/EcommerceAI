// ignore_for_file: must_be_immutable, deprecated_member_use, prefer_final_fields

import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/view/forgotpasswordpage.dart';
import 'package:EcommerceApp/view/registerpage.dart';
import 'package:flutter/material.dart';
import 'package:EcommerceApp/model/userdataset.dart';
import 'package:EcommerceApp/viewmodel/homecontroller.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:EcommerceApp/viewmodel/logincontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginDialog {
  static Future<bool> showLoginDialog(BuildContext context, Function refresh) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, Function backcall) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              content: Logindailog(
                refresh: () {
                  refresh.call();
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
    return Future.value(true);
  }
}
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_unnecessary_containers, non_constant_identifier_names, sized_box_for_whitespace, prefer_interpolation_to_compose_strings, unnecessary_import, sort_child_properties_last, avoid_print, await_only_futures, prefer_typing_uninitialized_variables, unused_local_variable, unnecessary_null_comparison, avoid_web_libraries_in_flutter, unnecessary_brace_in_string_interps

class Logindailog extends StatefulWidget {
  Function? refresh;
  BuildContext? context;
  Logindailog({
    super.key,
    this.refresh,
    this.context,
  });

  @override
  State<Logindailog> createState() => _LoginPageState();
}

class _LoginPageState extends State<Logindailog> {
  LoginController loginController = Get.put(LoginController());
  Homecontoller homecontoller = Get.put(Homecontoller());
  final _emailformKey = GlobalKey<FormState>();
  final _passwordformKey = GlobalKey<FormState>();
  var datas;

  @override
  void initState() {
    super.initState();
  }

  bool googlelogin = false;
  @override
  Widget build(BuildContext context) {
    context = widget.context ?? context;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        PlatformInfo().isWeb() == true || Responsive.isMobile(context)
            ? null
            : CommonWidget().showExitPopup(context);
      },
      child: MediaQuery.of(context).size.width > 600
          ? Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 450),
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Column(
                            crossAxisAlignment: PlatformInfo().isWeb() == true
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              Welcomewidget(),
                              emailTextfeildwidget(),
                              passwordTextfeildwidget(),
                              Forgetpassword(),
                              SigninBtn(),
                              // GoogleBtn(),
                              SingupWidget(),
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
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Welcomewidget(),
                    emailTextfeildwidget(),
                    passwordTextfeildwidget(),
                    Forgetpassword(),
                    SigninBtn(),
                    SingupWidget(),
                  ],
                ),
              ),
            ),
    );
  }

  String? token;

  Widget Vector() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: SvgPicture.asset("assets/image/Mobile login-bro.svg",
          semanticsLabel: 'Acme Logo'),
    );
  }

  static Widget Welcomewidget() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Login",
            style: TextStyle(
                fontSize: 26,
                color: AppColor.BlackColor,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget emailTextfeildwidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Email",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.BlackColor,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _emailformKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                controller: loginController.emailLogincontoller,
                validator: loginController.validateEmail,
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
                    border: InputBorder.none,
                    fillColor: AppColor.imagebg,
                    hintText: "Enter Your Email",
                    hintStyle: TextStyle()),
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

  Widget passwordTextfeildwidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Password",
            style: TextStyle(
                fontSize: 16,
                color: AppColor.BlackColor,
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Form(
              key: _passwordformKey,
              autovalidateMode: AutovalidateMode.always,
              child: TextFormField(
                obscureText: !loginController.ispasswordvisible,
                controller: loginController.passwordLogincontoller,
                validator: loginController.validatePassword,
                cursorColor: AppColor.fontblack,
                // textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                    suffixIcon: InkWell(
                      overlayColor: WidgetStatePropertyAll(Colors.white),
                      onTap: () {
                        loginController.ispasswordvisible =
                            !loginController.ispasswordvisible;
                        setState(() {});
                      },
                      child: Icon(
                        loginController.ispasswordvisible == false
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
                    hintStyle: TextStyle()),
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

  Widget Forgetpassword() {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.white),
            onTap: () {
              WebAPPNavigation.navigateToroute(
                  context: context,
                  routename: '/ForgotpasswordPage',
                  screen: ForgotpasswordPage());
            },
            child: Text(
              "Forgot Password",
              style: TextStyle(
                color: AppColor.BgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget SigninBtn() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      onTap: () async {
        if (loginController.processloader == false) {
          loginController.processloader = true;
          setState(() {});
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild!.unfocus();
          }
          if (loginController.emailLogincontoller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Email',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            loginController.processloader = false;
            setState(() {});
          } else if (loginController.passwordLogincontoller.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Password',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            loginController.processloader = false;
            setState(() {});
          } else if (!_emailformKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Valid Email',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            loginController.processloader = false;
            setState(() {});
          } else if (!_passwordformKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please Enter Valid Password',
                  style: TextStyle(color: AppColor.whiteColor),
                ),
                backgroundColor: Colors.red,
              ),
            );
            loginController.processloader = false;
            setState(() {});
          } else {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();

            Signin_app(
                emailAddress: loginController.emailLogincontoller.text,
                password: loginController.passwordLogincontoller.text);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        margin: EdgeInsets.only(right: 20, left: 20, top: 20, bottom: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColor.BlackColor),
        child: loginController.processloader == true
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.whiteColor,
                ),
              )
            : Text(
                "Sign In",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColor.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  List<UserModel>? userModelList;
  bool crateentry = false;

  // Google Sign-In removed — auth is email/password via the MongoDB backend.
  Widget GoogleBtn() => const SizedBox.shrink();

  Future<void> showLoginDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: SvgPicture.asset(
                      "assets/image/Mobile login-bro.svg",
                      semanticsLabel: 'Login Illustration',
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 450),
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Welcomewidget(),
                            emailTextfeildwidget(),
                            passwordTextfeildwidget(),
                            Forgetpassword(),
                            SigninBtn(),
                            // GoogleBtn(),
                            SingupWidget(),
                          ],
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
    );
  }

  Widget SingupWidget() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don’t Have An Account?",
              style: TextStyle(
                color: AppColor.fontColorgrey,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: InkWell(
                overlayColor: WidgetStatePropertyAll(Colors.white),
                onTap: () {
                  WebAPPNavigation.navigateToroute(
                      context: context,
                      routename: '/RegisterPage',
                      data: {'isdailog': true},
                      screen: RegisterPage(
                        isdailog: true,
                      ));
                },
                child: Text(
                  "Sign Up ",
                  style: TextStyle(
                    color: AppColor.BlackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future success() async {
    await ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 500),
        content: Text('Sucess'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future fail({error}) async {
    await ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 500),
        content: Text('$error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future Signin_app({emailAddress, password}) async {
    try {
      // Email/password login against the Node/MongoDB backend (JWT).
      final data = await ApiClient.instance.post('/auth/login', {
        'email': emailAddress,
        'password': password,
      });
      await ApiClient.instance.saveSession(data);
      final user = (data['user'] ?? {}) as Map;
      final userId = (user['id'] ?? user['_id'] ?? '').toString();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool(prefrenceKey.isLogin, true);
      prefs.setString(prefrenceKey.userid, userId);

      homecontoller.userid = userId;
      CommonWidget.userModel =
          UserModel.fromJson(Map<String, dynamic>.from(user));

      await success();
      loginController.processloader = false;
      setState(() {});
      Future.delayed(
        Duration(seconds: 1),
        () {
          CommonWidget.UnverifyedUser = false;
          loginController.emailLogincontoller.clear();
          loginController.passwordLogincontoller.clear();
          setState(() {});
          Navigator.pop(context);
          widget.refresh!.call();
        },
      );
    } on ApiException catch (e) {
      loginController.processloader = false;
      setState(() {});
      await fail(error: e.message);
    } catch (e) {
      loginController.processloader = false;
      setState(() {});
      await fail(error: "Error: Login failed");
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
