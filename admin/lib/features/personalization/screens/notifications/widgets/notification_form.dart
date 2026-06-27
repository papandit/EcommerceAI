import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/settings_controller.dart';

class NotificationForm extends StatelessWidget {
  const NotificationForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = SettingsController.instance;
    return Column(
      children: [
        // App Settings
        TRoundedContainer(
          padding: const EdgeInsets.symmetric(
              vertical: TSizes.lg, horizontal: TSizes.md),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('App Settings',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: TSizes.spaceBtwSections),

                // App Name
                TextFormField(
                  controller: controller.appNameController,
                  decoration: const InputDecoration(
                    hintText: 'App Name',
                    label: Text('App Name'),
                    prefixIcon: Icon(Iconsax.user),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Email and Phone
                Row(
                  children: [
                    // First Name
                    Expanded(
                      child: TextFormField(
                        controller: controller.taxController,
                        decoration: const InputDecoration(
                          hintText: 'Tax %',
                          label: Text('Tax Rate (%)'),
                          prefixIcon: Icon(Iconsax.tag),
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    // Last Name
                    Expanded(
                      child: TextFormField(
                        controller: controller.shippingController,
                        decoration: const InputDecoration(
                          hintText: 'Shipping Cost',
                          label: Text('Shipping Cost (\$)'),
                          prefixIcon: Icon(Iconsax.ship),
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    // Last Name
                    Expanded(
                      child: TextFormField(
                        controller: controller.freeShippingThresholdController,
                        decoration: const InputDecoration(
                          hintText: 'Free Shipping After (\$)',
                          label: Text('Free Shipping Threshold (\$)'),
                          prefixIcon: Icon(Iconsax.ship),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.razorpaykeyController,
                  decoration: const InputDecoration(
                    hintText: 'RazorPay Key',
                    label: Text('RazorPay Key'),
                    prefixIcon: Icon(Iconsax.key),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.shiprocketController,
                  decoration: const InputDecoration(
                    hintText: 'Shiprocket',
                    label: Text('Shiprocket'),
                    prefixIcon: Icon(Icons.local_shipping_rounded),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: () => controller.loading.value
                          ? () {}
                          : controller.updateSettingInformation(),
                      child: controller.loading.value
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : const Text('Update App Settings'),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
