import 'package:flutter/material.dart';

import '../../../../../../common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import '../../../../../../utils/constants/image_strings.dart';
import '../../../../../../utils/constants/sizes.dart';

class CouponsMobileScreen extends StatelessWidget {
  const CouponsMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs
              const TBreadcrumbsWithHeading(
                  heading: 'Coupons', breadcrumbItems: ['Coupons']),
              const SizedBox(height: TSizes.spaceBtwSections * 5),

              Center(
                child: Column(
                  children: [
                    const Image(
                        image: AssetImage(TImages.couponIllustration),
                        width: 300,
                        height: 300),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Text('Coupons Cooking',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    const Text(
                      'Hold onto your hats! We\'re brewing up a Coupons feature for both the Admin Panel and the App. 🎉 \nThe Coupons Screen is just around the corner... get ready for some savings magic! 🪄💸',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
