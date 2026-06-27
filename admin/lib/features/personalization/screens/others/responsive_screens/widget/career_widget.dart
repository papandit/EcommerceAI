// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_field

import 'package:cwt_ecommerce_admin_panel/common/widgets/breadcrumbs/breadcrumb_with_heading.dart';
import 'package:cwt_ecommerce_admin_panel/common/widgets/containers/rounded_container.dart';
import 'package:cwt_ecommerce_admin_panel/features/personalization/screens/others/other_controller.dart';
import 'package:cwt_ecommerce_admin_panel/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

// ignore: must_be_immutable
class CareerWidget extends StatelessWidget {
  OthersController _otherCoontroller = Get.put(OthersController());

  CareerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TBreadcrumbsWithHeading(
                heading: 'Career', breadcrumbItems: ['Career']),
            SizedBox(height: TSizes.spaceBtwSections),
            TRoundedContainer(
              width: 500,
              padding: EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  SizedBox(height: TSizes.sm),
                  Text('Career',
                      style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: TSizes.spaceBtwSections),
                  TextFormField(
                    controller: _otherCoontroller.aboutusController,
                    decoration: InputDecoration(
                        labelText: 'Career', prefixIcon: Icon(Iconsax.ship)),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields * 2),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () => _otherCoontroller.career(),
                        child: const Text('Create')),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
