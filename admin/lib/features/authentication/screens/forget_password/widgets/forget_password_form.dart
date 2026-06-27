import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/constants/text_strings.dart';
import '../../../../../../utils/validators/validation.dart';
import '../../../controllers/forget_password_controller.dart';

class ForgetPasswordForm extends StatelessWidget {
  const ForgetPasswordForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Headings
        IconButton(
            onPressed: () => Get.back(), icon: const Icon(Iconsax.arrow_left)),
        const SizedBox(height: TSizes.spaceBtwItems),
        Text(TTexts.forgetPasswordTitle,
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: TSizes.spaceBtwItems),
        Text(TTexts.forgetPasswordSubTitle,
            style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: TSizes.spaceBtwSections * 2),

        /// Text field
        Form(
          key: controller.forgetPasswordFormKey,
          child: TextFormField(
            controller: controller.email,
            validator: TValidator.validateEmail,
            decoration: const InputDecoration(
                labelText: TTexts.email,
                prefixIcon: Icon(Iconsax.direct_right)),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwSections),

        /// Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () => controller.sendPasswordResetEmail(),
              child: const Text(TTexts.submit)),
        ),
        const SizedBox(height: TSizes.spaceBtwSections * 2),
      ],
    );
  }
}
