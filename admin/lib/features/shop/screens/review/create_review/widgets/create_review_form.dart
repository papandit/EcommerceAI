// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cwt_ecommerce_admin_panel/features/shop/controllers/Review/create_Review_controller.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:cwt_ecommerce_admin_panel/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../../../common/widgets/containers/rounded_container.dart';

class CreateReviewForm extends StatelessWidget {
  const CreateReviewForm({super.key});

  @override
  Widget build(BuildContext context) {
    final createController = Get.put(CreateReviewController());
    return TRoundedContainer(
      width: 500,
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Form(
        key: createController.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TSizes.sm),
            Text('Create New Review',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Name Text Field
            TextFormField(
              controller: createController.name,
              validator: (value) => TValidator.validateEmptyText('Name', value),
              decoration: const InputDecoration(
                  labelText: 'Review Name', prefixIcon: Icon(Iconsax.category)),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              controller: createController.percentage,
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              validator: (value) => TValidator.validateDigit(value),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              decoration: const InputDecoration(
                  labelText: 'Review Percentage',
                  prefixIcon: Icon(Iconsax.category)),
            ),
            // Name Text Field

            const SizedBox(height: TSizes.spaceBtwInputFields * 2),

            // Image Uploader & Featured Checkbox

            const SizedBox(height: TSizes.spaceBtwInputFields),
            Obx(
              () => CheckboxMenuButton(
                value: createController.isActive.value,
                onChanged: (value) =>
                    createController.isActive.value = value ?? false,
                child: const Text('IsActive'),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            const SizedBox(height: TSizes.spaceBtwInputFields * 2),

            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: createController.loading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () => createController.createReview(),
                            child: const Text('Create')),
                      ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields * 2),
          ],
        ),
      ),
    );
  }
}
