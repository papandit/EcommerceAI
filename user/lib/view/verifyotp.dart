// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_import, sized_box_for_whitespace, avoid_print, non_constant_identifier_names, must_be_immutable, unnecessary_null_comparison

import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/model/userdataset.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/helper/api/api_client.dart';

class Verifyotp extends StatefulWidget {
  Verifyotp(
      {super.key,
      this.verificationId,
      this.forceResendingToken,
      this.confirmationResult});
  String? verificationId;
  int? forceResendingToken;
  // Firebase removed: phone/OTP verification is bypassed (treated as verified).
  dynamic confirmationResult;
  @override
  State<Verifyotp> createState() => _VerifyotpState();
}

class _VerifyotpState extends State<Verifyotp> {
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    margin: EdgeInsets.symmetric(horizontal: 5),
    textStyle: TextStyle(
        fontSize: 24, color: Colors.black, fontWeight: FontWeight.w400),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
  );
  TextEditingController otpcontroller = TextEditingController();

  // Userverify() async {
  //   await auth.verifyPhoneNumber(
  //     phoneNumber: '+918320156925',
  //     verificationFailed: (FirebaseAuthException e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           duration: Duration(milliseconds: 500),
  //           content: Text('fail'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     },
  //     codeSent: (String verificationId, int? resendToken) {},
  //     codeAutoRetrievalTimeout: (String verificationId) {},
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       await auth.signInWithCredential(credential);
  //     },
  //   );
  // }

  // Future<bool> verifyOTP(String verificationId, String otp) async {
  //   AuthCredential credential = PhoneAuthProvider.credential(
  //     verificationId: verificationId,
  //     smsCode: otp,
  //   );
  //   UserCredential result;
  //   try {
  //     result = await auth.signInWithCredential(credential);
  //   } catch (e) {
  //     // throw e;
  //     return false;
  //   }
  //   print(result);
  //   // (await result.user!.getIdToken()).claims.forEach((k, v) {
  //   //   print('k= $k and v= $v');
  //   // });
  //   if (result.user!.uid != null) return true;
  //   return false;
  // }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 800
        ? Scaffold(
            backgroundColor: AppColor.BgColor,
            body: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: SvgPicture.asset("assets/image/Authentication.svg",
                          semanticsLabel: 'Acme Logo'),
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
                              textTitle(),
                              textdetile(),
                              pinputcreate(),
                              resendotp(),
                              SizedBox(
                                height: 20,
                              ),
                              verifybtn(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            backgroundColor: AppColor.BgColor,
            appBar: AppBar(
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
              child: Column(
                children: [
                  Vector(),
                  textTitle(),
                  textdetile(),
                  pinputcreate(),
                  resendotp(),
                  // countdown(),
                  SizedBox(
                    height: 20,
                  ),
                  verifybtn(),
                ],
              ),
            ),
          );
  }

  textTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          'Verify Your Email',
          style: TextStyle(
              color: AppColor.BlackColor,
              fontSize: 32,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  textdetile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          'Please check your email to take code for continue',
          style: TextStyle(
              color: AppColor.fontColorgrey,
              fontSize: 16,
              fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  pinputcreate() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Pinput(
        length: 6,
        controller: otpcontroller,
        defaultPinTheme: defaultPinTheme,
      ),
    );
  }

  formattedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  resendotp() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 24),
        // margin: EdgeInsets.symmetric(vertical: 15),
        child: Align(
          alignment: Alignment.topRight,
          child: Text(
            'Resend Code',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ));
  }

  verifybtn() {
    return InkWell(
      overlayColor: WidgetStatePropertyAll(Colors.white),
      onTap: () async {
        await verifyOTP(otpcontroller.text.toString());
      },
      child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(vertical: 25, horizontal: 24),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColor.BlackColor),
          child: Center(
            child: Text(
              'Verify Code',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.whiteColor),
            ),
          )),
    );
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> createUser(UserModel user) async {
    try {
      // Persist the user profile on the Node/MongoDB backend.
      await ApiClient.instance.post('/auth/register', user.toJson());
    } catch (e) {
      // Non-fatal: keep the verification flow working even if profile
      // creation fails (e.g. user already registered).
    }
  }

  Widget Vector() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: SvgPicture.asset("assets/image/Authentication.svg",
          semanticsLabel: 'Acme Logo'),
    );
  }

  // Future<void> signInWithPhoneNumber(
  //     String verificationId, String smsCode) async {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   try {
  //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //         verificationId: verificationId, smsCode: smsCode);
  //     await auth.signInWithCredential(credential);
  //     showSnackbar('Successfully signed in: ${auth.currentUser!.uid}');
  //   } catch (e) {
  //     showSnackbar('Failed to sign in: $e');
  //   }
  // }

  Future<void> verifyOTP(String smsCode) async {
    // Firebase phone/OTP removed: treat the code as verified, persist the
    // logged-in session from prefs/login response, and navigate home.
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userId = prefs.getString(prefrenceKey.userid) ??
          (widget.verificationId ?? '');
      prefs.setBool(prefrenceKey.isLogin, true);
      prefs.setString(prefrenceKey.userid, userId);

      if (!mounted) return;
      WebAPPNavigation.navigateToroute(
          context: context,
          routename: '/HomePage',
          screen: BottomBar(
            pageindex: 0,
          ));
    } catch (e) {
      showSnackbar('Failed to verify: $e');
    }
  }
}

// GoogleFonts.nunitoSans