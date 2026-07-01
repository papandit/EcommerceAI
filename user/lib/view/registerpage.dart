// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, must_be_immutable

import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/auth_shell.dart';
import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/common_widget.dart';
import 'package:EcommerceApp/helper/prefrence.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/viewmodel/registercontroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key, isdailog = false});
  bool? isdailog;
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterController registerController = Get.put(RegisterController());
  final _nameformKey = GlobalKey<FormState>();
  final _emailformKey = GlobalKey<FormState>();
  final _numberformKey = GlobalKey<FormState>();
  final _passwordformKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cream,
      body: AuthShell(
        leading: Responsive.isMobile(context) ? _backButton() : null,
        child: _form(context),
      ),
    );
  }

  Widget _backButton() => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: IconButton(
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          onPressed: () => WebAPPNavigation.navigateTo(context: context),
          icon: Icon(Icons.arrow_back, color: AppColor.ink),
        ),
      );

  Widget _form(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthTitle('Create Account'),
        const SizedBox(height: 30),
        AuthField(
          label: 'Full Name',
          controller: registerController.namecontoller,
          hint: 'Enter your name',
          validator: registerController.validatename,
          formKey: _nameformKey,
        ),
        AuthField(
          label: 'Email',
          controller: registerController.emailcontoller,
          hint: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          validator: registerController.validateEmail,
          formKey: _emailformKey,
        ),
        AuthField(
          label: 'Phone Number',
          controller: registerController.numbercontoller,
          hint: 'Enter your number',
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: registerController.validatenumber,
          formKey: _numberformKey,
        ),
        AuthField(
          label: 'Password',
          controller: registerController.passwordcontoller,
          hint: 'Enter your password',
          obscure: !registerController.ispasswordvisible,
          validator: registerController.validatePassword,
          formKey: _passwordformKey,
          suffix: AuthPasswordToggle(
            visible: registerController.ispasswordvisible,
            onTap: () => setState(() => registerController.ispasswordvisible =
                !registerController.ispasswordvisible),
          ),
        ),
        AuthPrimaryButton(
          label: 'Sign Up',
          busy: registerController.processloader,
          onTap: _onSignUp,
          topMargin: 12,
        ),
        AuthFooterLink(
          text: 'Already have an account?',
          actionLabel: 'Sign in',
          onTap: () => WebAPPNavigation.navigateTo(context: context),
        ),
      ],
    );
  }

  Future<void> _onSignUp() async {
    if (registerController.processloader) return;
    FocusScope.of(context).unfocus();

    final name = registerController.namecontoller.text.trim();
    final email = registerController.emailcontoller.text.trim();
    final number = registerController.numbercontoller.text.trim();
    final pass = registerController.passwordcontoller.text;

    if (name.isEmpty) {
      AppToast.show(context, 'Please enter your name.', success: false);
      return;
    }
    if (email.isEmpty) {
      AppToast.show(context, 'Please enter your email.', success: false);
      return;
    }
    if (number.isEmpty) {
      AppToast.show(context, 'Please enter your number.', success: false);
      return;
    }
    if (pass.isEmpty) {
      AppToast.show(context, 'Please enter your password.', success: false);
      return;
    }
    if (!(_nameformKey.currentState?.validate() ?? true)) {
      AppToast.show(context, 'Please enter a valid name.', success: false);
      return;
    }
    if (!(_emailformKey.currentState?.validate() ?? true)) {
      AppToast.show(context, 'Please enter a valid email.', success: false);
      return;
    }
    if (!(_numberformKey.currentState?.validate() ?? true)) {
      AppToast.show(context, 'Please enter a valid phone number.',
          success: false);
      return;
    }
    if (!(_passwordformKey.currentState?.validate() ?? true)) {
      AppToast.show(context, 'Please enter a valid password.', success: false);
      return;
    }

    setState(() => registerController.processloader = true);
    await Signup_app(
        emailAddress: email,
        password: pass,
        firstName: name,
        phoneNumber: number);
  }

  Future Signup_app({emailAddress, password, firstName, phoneNumber}) async {
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
      if (!mounted) return;
      setState(() {});
      AppToast.show(context, e.message, success: false);
    } catch (e) {
      registerController.processloader = false;
      if (!mounted) return;
      setState(() {});
      AppToast.show(
          context, 'Registration failed. Please try again.', success: false);
    }
  }
}
