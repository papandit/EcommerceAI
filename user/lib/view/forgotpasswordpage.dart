// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:EcommerceApp/helper/api/api_client.dart';
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

  Future<void> _sendOtp() async {
    final email = _email.text.trim();
    if (!_validEmail(email)) {
      AppToast.show(context, 'Please enter a valid email.', success: false);
      return;
    }
    setState(() => _busy = true);
    try {
      final res =
          await ApiClient.instance.post('/auth/forgot-password', {'email': email});
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
      WebAPPNavigation.navigateToroute(
          context: context, routename: '/LoginPage', screen: LoginPage());
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
      appBar: AppBar(
        backgroundColor: AppColor.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.ink),
          onPressed: () => WebAPPNavigation.navigateTo(context: context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: AppRadius.lg,
                border: Appborder.appborder,
                boxShadow: Appshadow.soft,
              ),
              child: _step == 0 ? _emailStep() : _resetStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(String t, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t,
              style: TextStyle(
                  fontFamily: AppFont.heading,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColor.ink)),
          const SizedBox(height: 6),
          Text(sub,
              style: TextStyle(color: AppColor.fontColorgrey, fontSize: 13.5)),
          const SizedBox(height: 20),
        ],
      );

  Widget _field(String label, TextEditingController c,
      {bool obscure = false, TextInputType? kb}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColor.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: c,
            obscureText: obscure,
            keyboardType: kb,
            cursorColor: AppColor.primary,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColor.blush,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: AppRadius.sm, borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title('Forgot password?',
            'Enter your account email and we\'ll send you a reset code.'),
        _field('Email', _email, kb: TextInputType.emailAddress),
        const SizedBox(height: 6),
        _primary('Send code', _sendOtp),
      ],
    );
  }

  Widget _resetStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title('Reset password',
            'Enter the code sent to ${_email.text.trim()} and choose a new password.'),
        _field('Reset code', _otp, kb: TextInputType.number),
        _field('New password', _pass, obscure: true),
        _field('Confirm new password', _confirm, obscure: true),
        const SizedBox(height: 6),
        _primary('Reset password', _resetPassword),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: _busy ? null : _sendOtp,
            child: Text('Resend code',
                style: TextStyle(color: AppColor.primary)),
          ),
        ),
      ],
    );
  }

  Widget _primary(String label, VoidCallback onTap) {
    return PressableScale(
      onTap: _busy ? () {} : onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: _busy ? null : AppColor.ctaGradient,
          color: _busy ? AppColor.dividercolor : null,
          borderRadius: AppRadius.sm,
        ),
        child: _busy
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColor.primary))
            : Text(label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
      ),
    );
  }
}
