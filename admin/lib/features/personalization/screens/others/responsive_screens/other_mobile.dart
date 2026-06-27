// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cwt_ecommerce_admin_panel/common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/containers/rounded_container.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class OtherMobileScreen extends StatelessWidget {
  const OtherMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TBreadcrumbsWithHeading(
                  heading: 'Others', breadcrumbItems: ['Others']),
              SizedBox(height: TSizes.spaceBtwSections),
              TRoundedContainer(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Free Shipping',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
                    Text('Secure Payment',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
                    Text('Special Campaigns',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
                    Text('Customer Service',
                        style: Theme.of(context).textTheme.headlineSmall),

                    // Explore
                    SizedBox(height: TSizes.spaceBtwSections),
                    Text('EXPLORE',
                        style: Theme.of(context).textTheme.headlineLarge),
                    Divider(),
                    Text('About Us',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
                    Text('Contact Us',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
                    Text('Size Chart',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
                    Text('Career',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),

                    // Policies
                    SizedBox(height: TSizes.spaceBtwSections),
                    Text('POLICIES',
                        style: Theme.of(context).textTheme.headlineLarge),
                    Divider(),
                    Text('T&C',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
                    Text('Privacy Policy',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
                    Text('Cancellation Policy',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
                    Text('Return & Refunds',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
                    Text('Exchange Policy',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
                    Text('Order Tracking',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
                    Text('Shipping & COD',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Divider(),
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
