import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../common/widgets/containers/rounded_container.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/settings_controller.dart';

class SettingsForm extends StatelessWidget {
  const SettingsForm({
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
                          hintText: 'GST %',
                          label: Text('GST Rate (%)'),
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
                          hintText: 'Delivery Charge',
                          label: Text('Delivery Charge (₹)'),
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
                          hintText: 'Free Delivery After (₹)',
                          label: Text('Free Delivery Above (₹)'),
                          prefixIcon: Icon(Iconsax.ship),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                // Razorpay
                Text('Razorpay',
                    style: Theme.of(context).textTheme.titleMedium),
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
                  controller: controller.razorpaysecretController,
                  decoration: const InputDecoration(
                    hintText: 'RazorPay Secret',
                    label: Text('RazorPay Secret'),
                    prefixIcon: Icon(Iconsax.key),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                // Stripe
                Text('Stripe',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.stripepublishableController,
                  decoration: const InputDecoration(
                    hintText: 'Stripe Publishable Key',
                    label: Text('Stripe Publishable Key'),
                    prefixIcon: Icon(Iconsax.key),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.stripesecretController,
                  decoration: const InputDecoration(
                    hintText: 'Stripe Secret Key',
                    label: Text('Stripe Secret Key'),
                    prefixIcon: Icon(Iconsax.key),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.stripewebhooksecretController,
                  decoration: const InputDecoration(
                    hintText: 'whsec_...',
                    label: Text('Stripe Webhook Secret'),
                    prefixIcon: Icon(Iconsax.shield_tick),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                // Email (SMTP)
                Text('Email (SMTP)',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.smtphostController,
                  decoration: const InputDecoration(
                    hintText: 'SMTP Host',
                    label: Text('SMTP Host'),
                    prefixIcon: Icon(Iconsax.global),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.smtpportController,
                  decoration: const InputDecoration(
                    hintText: 'SMTP Port',
                    label: Text('SMTP Port'),
                    prefixIcon: Icon(Iconsax.hashtag),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.smtpuserController,
                  decoration: const InputDecoration(
                    hintText: 'SMTP User',
                    label: Text('SMTP User'),
                    prefixIcon: Icon(Iconsax.user),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.smtppassController,
                  decoration: const InputDecoration(
                    hintText: 'SMTP Password',
                    label: Text('SMTP Password'),
                    prefixIcon: Icon(Iconsax.password_check),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.smtpfromController,
                  decoration: const InputDecoration(
                    hintText: 'SMTP From',
                    label: Text('SMTP From'),
                    prefixIcon: Icon(Iconsax.send_2),
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
                const SizedBox(height: TSizes.spaceBtwSections),

                // BrandShoot AI
                Row(
                  children: [
                    Text('BrandShoot AI',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Obx(
                      () => controller.settings.value.brandshootConfigured
                          ? const Row(
                              children: [
                                Icon(Iconsax.tick_circle,
                                    color: Colors.green, size: 16),
                                SizedBox(width: 4),
                                Text('Configured',
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 12)),
                              ],
                            )
                          : const Text('Not configured',
                              style:
                                  TextStyle(color: Colors.orange, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.brandshootBaseController,
                  decoration: const InputDecoration(
                    hintText: 'https://brandshoot.onewebmart.cloud',
                    label: Text('BrandShoot Base URL'),
                    prefixIcon: Icon(Iconsax.global),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.brandshootKeyController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter a new API key to set/replace it',
                    label: Text('BrandShoot API Key'),
                    prefixIcon: Icon(Iconsax.key),
                    helperText:
                        'For security the saved key is never shown. Leave blank to keep the current key.',
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  controller: controller.tryonMaxUploadBytesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '6000000',
                    label: Text('Max upload (bytes)'),
                    prefixIcon: Icon(Iconsax.gallery),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                // Try-On Credits — the pool the admin buys from BrandShoot, its
                // cost, and the free credits each new shopper gets on signup.
                Text('Try-On Credits',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.purchasedCreditsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0',
                          label: Text('Purchased Credits'),
                          prefixIcon: Icon(Iconsax.coin),
                          helperText: 'Total credits bought from BrandShoot',
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Expanded(
                      child: TextFormField(
                        controller: controller.costPerCreditController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '0.0',
                          label: Text('Cost / Credit'),
                          prefixIcon: Icon(Iconsax.money),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.currencyController,
                        decoration: const InputDecoration(
                          hintText: 'INR',
                          label: Text('Currency'),
                          prefixIcon: Icon(Iconsax.dollar_circle),
                        ),
                      ),
                    ),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    Expanded(
                      child: TextFormField(
                        controller: controller.signupFreeCreditsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '3',
                          label: Text('Free Credits on Signup'),
                          prefixIcon: Icon(Iconsax.gift),
                        ),
                      ),
                    ),
                  ],
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
