import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../utils/constants/sizes.dart';
import '../../../../../common/widgets/layouts/templates/login_template.dart';
import '../../../../../routes/routes.dart';
import '../../../controllers/forget_password_controller.dart';

class ResetPasswordDesktopScreen extends StatelessWidget {
  const ResetPasswordDesktopScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    // Keep the email available (e.g. after a web refresh on this route).
    if (controller.email.text.isEmpty && email.isNotEmpty) {
      controller.email.text = email;
    }

    return Scaffold(
      body: TLoginTemplate(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () => Get.offAllNamed(TRoutes.login),
                      icon: const Icon(CupertinoIcons.clear)),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              Text('Reset password',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                'Enter the code sent to ${controller.email.text} and choose a new password.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              Form(
                key: controller.resetPasswordFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.otp,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.trim().length < 4) ? 'Enter the code' : null,
                      decoration: const InputDecoration(
                          labelText: 'Reset code',
                          prefixIcon: Icon(Icons.pin_outlined)),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    TextFormField(
                      controller: controller.newPassword,
                      obscureText: true,
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'At least 6 characters' : null,
                      decoration: const InputDecoration(
                          labelText: 'New password',
                          prefixIcon: Icon(Icons.lock_outline)),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    TextFormField(
                      controller: controller.confirmPassword,
                      obscureText: true,
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'At least 6 characters' : null,
                      decoration: const InputDecoration(
                          labelText: 'Confirm new password',
                          prefixIcon: Icon(Icons.lock_outline)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => controller.resetPassword(),
                    child: const Text('Reset Password')),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                    onPressed: () =>
                        controller.resendPasswordResetEmail(controller.email.text),
                    child: const Text('Resend code')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
