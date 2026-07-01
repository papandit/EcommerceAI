// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, avoid_print

import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/auth_shell.dart';
import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/platformcheck.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/view/forgotpasswordpage.dart';
import 'package:EcommerceApp/view/registerpage.dart';
import 'package:EcommerceApp/viewmodel/logincontroller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  LoginPage({super.key, this.refresh});
  void Function()? refresh;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginController loginController = Get.put(LoginController());
  final _emailformKey = GlobalKey<FormState>();
  final _passwordformKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool mobile = Responsive.isMobile(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        PlatformInfo().isWeb() == true || mobile
            ? null
            : CommonWidget().showExitPopup(context);
      },
      child: Scaffold(
        backgroundColor: AppColor.cream,
        body: AuthShell(child: _form(context)),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthTitle('Login'),
        const SizedBox(height: 34),
        AuthField(
          label: 'Email',
          controller: loginController.emailLogincontoller,
          hint: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          validator: loginController.validateEmail,
          formKey: _emailformKey,
        ),
        AuthField(
          label: 'Password',
          controller: loginController.passwordLogincontoller,
          hint: 'Enter your password',
          obscure: !loginController.ispasswordvisible,
          validator: loginController.validatePassword,
          formKey: _passwordformKey,
          suffix: AuthPasswordToggle(
            visible: loginController.ispasswordvisible,
            onTap: () => setState(() => loginController.ispasswordvisible =
                !loginController.ispasswordvisible),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            onTap: () => WebAPPNavigation.navigateToroute(
                context: context,
                routename: '/ForgotpasswordPage',
                screen: ForgotpasswordPage()),
            child: Text('Forgot password?',
                style: TextStyle(
                    color: const Color(0xff6E6870),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        ),
        AuthPrimaryButton(
          label: 'Sign In',
          busy: loginController.processloader,
          onTap: _onSignIn,
        ),
        AuthGoogleButton(
          onTap: () =>
              AppToast.show(context, 'Please use email login.', success: false),
        ),
        AuthFooterLink(
          text: "Don't have an account?",
          actionLabel: 'Sign up',
          onTap: () {
            CommonWidget.isRegister = true;
            WebAPPNavigation.navigateToroute(
                context: context,
                routename: '/RegisterPage',
                screen: RegisterPage());
          },
        ),
      ],
    );
  }

  Future<void> _onSignIn() async {
    if (loginController.processloader) return;
    FocusScope.of(context).unfocus();

    final email = loginController.emailLogincontoller.text.trim();
    final pass = loginController.passwordLogincontoller.text;
    if (email.isEmpty) {
      AppToast.show(context, 'Please enter your email.', success: false);
      return;
    }
    if (pass.isEmpty) {
      AppToast.show(context, 'Please enter your password.', success: false);
      return;
    }
    if (!(_emailformKey.currentState?.validate() ?? true)) {
      AppToast.show(context, 'Please enter a valid email.', success: false);
      return;
    }
    if (!(_passwordformKey.currentState?.validate() ?? true)) {
      AppToast.show(context, 'Please enter a valid password.', success: false);
      return;
    }

    setState(() => loginController.processloader = true);
    await Signin_app(emailAddress: email, password: pass);
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

      loginController.processloader = false;
      CommonWidget.UnverifyedUser = false;
      loginController.emailLogincontoller.clear();
      loginController.passwordLogincontoller.clear();
      if (!mounted) return;
      setState(() {});
      AppToast.show(context, 'Signed in.', success: true);
      Future.delayed(Duration(seconds: 1), () {
        if (!kIsWeb || CommonWidget.isRegister == true) {
          CommonWidget.isRegister = false;
          if (!mounted) return;
          setState(() {});
          WebAPPNavigation.navigateToroute(
              routename: '/HomePage', context: context, screen: BottomBar());
        } else {
          html.window.history.back();
          widget.refresh?.call();
        }
      });
    } on ApiException catch (e) {
      loginController.processloader = false;
      if (!mounted) return;
      setState(() {});
      AppToast.show(context, e.message, success: false);
    } catch (e) {
      loginController.processloader = false;
      if (!mounted) return;
      setState(() {});
      AppToast.show(context, 'Login failed. Please try again.', success: false);
    }
  }
}
