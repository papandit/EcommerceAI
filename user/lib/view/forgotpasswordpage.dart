// ignore_for_file: use_build_context_synchronously

import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/auth_shell.dart';
import 'package:EcommerceApp/helper/risponsive.dart';
import 'package:EcommerceApp/helper/utillity.dart';
import 'package:EcommerceApp/helper/webnavigation.dart';
import 'package:EcommerceApp/view/loginpage.dart';
import 'package:flutter/material.dart';

/// Forgot password — 2 steps:
///   1) enter email  -> POST /auth/forgot-password (emails a 6-digit code)
///   2) enter code + new password -> POST /auth/reset-password -> back to login
class ForgotpasswordPage extends StatefulWidget {
  const ForgotpasswordPage({super.key});

  @override
  State<ForgotpasswordPage> createState() => _ForgotpasswordPageState();
}

class _ForgotpasswordPageState extends State<ForgotpasswordPage> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  int _step = 0; // 0 = email, 1 = code + new password
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _validEmail(String s) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s.trim());

  void _backToLogin() => WebAPPNavigation.navigateToroute(
      context: context, routename: '/LoginPage', screen: LoginPage());

  Future<void> _sendOtp() async {
    final email = _email.text.trim();
    if (!_validEmail(email)) {
      AppToast.show(context, 'Please enter a valid email.', success: false);
      return;
    }
    setState(() => _busy = true);
    try {
      final res = await ApiClient.instance
          .post('/auth/forgot-password', {'email': email});
      final devOtp = (res['devOtp'] ?? '').toString();
      setState(() => _step = 1);
      AppToast.show(
        context,
        devOtp.isNotEmpty
            ? 'Email not set up — your code is $devOtp'
            : 'We sent a reset code to your email.',
        success: true,
      );
    } on ApiException catch (e) {
      AppToast.show(context, e.message, success: false);
    } catch (_) {
      AppToast.show(context, 'Network error. Please try again.', success: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final otp = _otp.text.trim();
    final pass = _pass.text;
    if (otp.length < 4) {
      AppToast.show(context, 'Enter the code from your email.', success: false);
      return;
    }
    if (pass.length < 6) {
      AppToast.show(context, 'Password must be at least 6 characters.',
          success: false);
      return;
    }
    if (pass != _confirm.text) {
      AppToast.show(context, 'Passwords do not match.', success: false);
      return;
    }
    setState(() => _busy = true);
    try {
      await ApiClient.instance.post('/auth/reset-password', {
        'email': _email.text.trim(),
        'otp': otp,
        'newPassword': pass,
      });
      AppToast.show(context, 'Password reset! Please sign in.', success: true);
      _backToLogin();
    } on ApiException catch (e) {
      AppToast.show(context, e.message, success: false);
    } catch (_) {
      AppToast.show(context, 'Network error. Please try again.', success: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cream,
      body: AuthShell(
        maxFormWidth: 440,
        leading: Responsive.isMobile(context)
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  onPressed: _backToLogin,
                  icon: Icon(Icons.arrow_back, color: AppColor.ink),
                ),
              )
            : null,
        child: Container(
          padding: const EdgeInsets.fromLTRB(36, 40, 36, 36),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xff781E3C).withValues(alpha: 0.14),
                  blurRadius: 60,
                  offset: const Offset(0, 30))
            ],
          ),
          child: _step == 0 ? _emailStep() : _resetStep(),
        ),
      ),
    );
  }

  Widget _emailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthTitle('Forgot password?', fontSize: 30, align: TextAlign.left),
        const SizedBox(height: 10),
        Text(
          "Enter your account email and we'll send you a reset code.",
          style: TextStyle(
              color: const Color(0xff8C8792), fontSize: 15, height: 1.55),
        ),
        const SizedBox(height: 26),
        AuthField(
          label: 'Email',
          controller: _email,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        AuthPrimaryButton(label: 'Send code', busy: _busy, onTap: _sendOtp, topMargin: 8),
        AuthFooterLink(
          text: '',
          actionLabel: '← Back to login',
          onTap: _backToLogin,
          topMargin: 20,
        ),
      ],
    );
  }

  Widget _resetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthTitle('Reset password', fontSize: 30, align: TextAlign.left),
        const SizedBox(height: 10),
        Text(
          'Enter the code sent to ${_email.text.trim()} and choose a new password.',
          style: TextStyle(
              color: const Color(0xff8C8792), fontSize: 15, height: 1.55),
        ),
        const SizedBox(height: 26),
        AuthField(
          label: 'Reset code',
          controller: _otp,
          hint: '6-digit code',
          keyboardType: TextInputType.number,
        ),
        AuthField(
          label: 'New password',
          controller: _pass,
          hint: 'At least 6 characters',
          obscure: true,
        ),
        AuthField(
          label: 'Confirm new password',
          controller: _confirm,
          hint: 'Re-enter your password',
          obscure: true,
        ),
        AuthPrimaryButton(
            label: 'Reset password', busy: _busy, onTap: _resetPassword, topMargin: 8),
        AuthFooterLink(
          text: "Didn't get the code?",
          actionLabel: 'Resend',
          onTap: () {
            if (!_busy) _sendOtp();
          },
          topMargin: 18,
        ),
      ],
    );
  }
}
